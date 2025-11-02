@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")
const UUID = preload("res://addons/event_sheet/source/utils/event_sheet_uuid.gd")
const WindowClass = preload("res://addons/event_sheet/source/elements/window/window.gd")
const ScriptGeneration = preload("res://addons/event_sheet/source/elements/event_sheet/script_generation.gd")


var theme_colors: Dictionary = {
	"base_color": EditorInterface.get_editor_theme().get_color("base_color", "Editor"),
	"accent_color": EditorInterface.get_editor_theme().get_color("accent_color", "Editor"),
}

@onready var _popup_menu: PopupMenu = $PopupMenu
@onready var _window: Control = $Window
@onready var block_items: VBoxContainer = $VBoxContainer/HSplitContainer/ScrollContainer/Control/Blocks
@onready var code_editor: CodeEdit = $VBoxContainer/HSplitContainer/CodeEdit
@onready var debug_panel: Control = null
@onready var variables_panel: Control = null

var result_script: String = ""

var event_sheet_file: JSON
var event_sheet_data: Dictionary
var current_node: Node:
	set(p_current_node):
		if p_current_node != current_node:
			current_node = p_current_node
			ESUtils.current_scene = current_node
			update_configuration_warnings()
var selected_content: Array = []
var has_hover: bool

var current_popup_menu: String = "general"
var popup_menus: Dictionary = {
	"general": ["Add Event", "Add Action", "", "Add Group", "Add Comment", "", "Paste"]
}





func _input(event: InputEvent) -> void:
	if visible and ESUtils.is_plugin_screen and _window and !_window.visible and !ESUtils.is_editing:
		if event is InputEventKey:
			if event.keycode == KEY_CTRL:
				ESUtils.is_ctrl_pressed = event.pressed
			if event.keycode == KEY_DELETE and event.pressed and !ESUtils.selected_items.is_empty():
				remove_data()
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				# Check if mouse is over the event sheet area
				var scroll_container = $VBoxContainer/HSplitContainer/ScrollContainer
				var local_pos = scroll_container.global_position
				var size = scroll_container.size
				var mouse_pos = event.global_position
				
				if (mouse_pos.x >= local_pos.x and mouse_pos.x <= local_pos.x + size.x and 
					mouse_pos.y >= local_pos.y and mouse_pos.y <= local_pos.y + size.y):
					_show_context_menu(event.global_position)
					get_viewport().set_input_as_handled()
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if !ESUtils.selected_items.is_empty():
					if ESUtils.is_ctrl_pressed:
						return
					if ESUtils.has_item_in_select(ESUtils.hovered_select):
						return
					if !ESUtils.is_dragging_finished:
						return
					ESUtils.unselect_all()
					if ESUtils.hovered_select and ESUtils.hovered_select is VBoxContainer:
						ESUtils.hovered_select._select()

func _ready() -> void:
	if !_window.finish_data.is_connected(_on_finish_data):
		_window.finish_data.connect(_on_finish_data)
	
	# Connect popup menu signal (already connected in .tscn)
	# Connect scroll container gui_input
	var scroll_container = $VBoxContainer/HSplitContainer/ScrollContainer
	if not scroll_container.gui_input.is_connected(_on_scroll_container_gui_input):
		scroll_container.gui_input.connect(_on_scroll_container_gui_input)
	
	# Connect to variable changes to regenerate code
	if Engine.has_singleton("VariableManager"):
		var vm = Engine.get_singleton("VariableManager")
		if vm and vm.has_signal("variable_changed") and not vm.variable_changed.is_connected(_on_variable_changed):
			vm.variable_changed.connect(_on_variable_changed)
	
	ESUtils.selected_items.clear()
	ESUtils.is_editing = false
	ESUtils.is_dragging = false
	ESUtils.dragging_data = {}
	
	# Инициализация систем
	_setup_variables_panel()

func _process(delta: float) -> void:
	pass

# Cached visual elements for blocks
var block_body := preload("res://addons/event_sheet/elements/blocks/empty_block.tscn")
var event_body := preload("res://addons/event_sheet/elements/blocks/conditions/event.tscn")
var action_body := preload("res://addons/event_sheet/elements/blocks/conditions/action.tscn")

# Load Event Sheet
func load_event_sheet():
	ESUtils.selected_items.clear()
	ESUtils.is_editing = false
	ESUtils.is_dragging = false
	ESUtils.dragging_data = {}
	
	for item in block_items.get_children():
		item.queue_free()
	
	if event_sheet_data and event_sheet_data.has("blocks"):
		for block in event_sheet_data.blocks:
			ESUtils.create_blocks(self, block)
	
	if block_items.has_method("update_lines"):
		block_items.update_lines()
	generate_code()

# Delete selected block
func remove_data():
	ESUtils.undo_redo.create_action("Remove Blocks")
	for item in ESUtils.selected_items:
		if !item.has("object") or !item.has("class"):
			continue
		var _item_object = item.object
		if _item_object:
			ESUtils.undo_redo.add_do_method(ESUtils, "_remove_item", self, _item_object.get_parent(), _item_object)
			ESUtils.undo_redo.add_undo_method(ESUtils, "_add_item", self, _item_object.get_parent(), _item_object)
			ESUtils.undo_redo.add_undo_reference(_item_object)
	ESUtils.undo_redo.commit_action()
	
	ESUtils.unselect_all()
	generate_code()

# Paste copied items
func paste_data():
	ESUtils.undo_redo.create_action("Remove Blocks")
	
	var object: Object = Object.new()
	object.set_meta("clipboard_array", str_to_var(DisplayServer.clipboard_get()))
	var _to_block = null
	var _selected_item = ESUtils.selected_items[0] if ESUtils.selected_items.size() > 0 else null
	if _selected_item != null:
		_to_block = _selected_item.object.data if _selected_item.class == "Block" else _selected_item.object.block_body.data
		if _selected_item.class == "Block":
			_to_block = _to_block if _selected_item.object.type == "standart" or _selected_item.object.type == "group" else {}
	object.set_meta("to_block", _to_block)
	
	ESUtils.undo_redo.add_do_method(ESUtils, "_paste_items", self, object)
	ESUtils.undo_redo.add_undo_method(ESUtils, "_remove_items", self, object)
	ESUtils.undo_redo.add_undo_reference(object)
	
	ESUtils.undo_redo.commit_action()
	
	ESUtils.save_event_sheet_data()
	ESUtils.unselect_all()
	generate_code()

# Generate a script from the event sheet
func generate_code():
	if current_node:
		var _script = ScriptGeneration.generate_code(self)
		current_node.final_script = _script

# Event Sheet Inputs
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if !selected_content.is_empty():
				selected_content.clear()
			for item in get_tree().get_nodes_in_group("selectable"):
				if item is Button:
					item.button_pressed = false
				if item is VBoxContainer:
					item.panel_pressed = false
			EditorInterface.get_selection().clear()
			grab_focus()
		
		# Event Sheet - Right Click
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(event.global_position)

# Popup Menu Pressed
func _on_popup_menu_index_pressed(index: int) -> void:
	var item_text = _popup_menu.get_item_text(index)
	
	match item_text:
		"Copy":
			ESUtils.clipboard_items.clear()
			for item in ESUtils.selected_items:
				ESUtils.clipboard_items.append(item.object.data)
			DisplayServer.clipboard_set(str(ESUtils.clipboard_items))
		"Delete":
			remove_data()
		"Add Event":
			_handle_context_action("event")
		"Add Action":
			_handle_context_action("action")
		"Add Group":
			_window.show_add_group()
		"Add Comment":
			_handle_context_comment()
		"Paste":
			_handle_context_paste()

# Handle context-aware actions
func _handle_context_action(action_type: String):
	var context_block = get_meta("context_block", {})
	if not context_block.is_empty():
		_window.show_add_window(action_type, "standart", context_block)
	elif ESUtils.selected_items.size() == 1:
		var selected_item = ESUtils.selected_items[0].object
		var selected_block = {}
		if selected_item is VBoxContainer:
			selected_block = selected_item.block_resource if selected_item.has_method("block_resource") else {}
		_window.show_add_window(action_type, "standart", selected_block)
	else:
		_window.show_add_window(action_type, "standart", {})

# Handle context-aware comment creation
func _handle_context_comment():
	_on_finish_data({
		"block_type": "comment",
		"block_condition_type": "",
		"block_data": { "comment_text": "New comment" }
	}, {})

# Handle context-aware paste
func _handle_context_paste():
	if ESUtils.clipboard_items.size() > 0:
		# Set context block for paste operation
		var context_block = get_meta("context_block", {})
		if not context_block.is_empty():
			# Select the context block temporarily for paste
			ESUtils.selected_items.clear()
			# Find the visual block and select it
			var visual_block = _find_visual_block_by_data(context_block)
			if visual_block:
				ESUtils.selected_items.append({"object": visual_block, "class": "Block"})
		paste_data()

# Find visual block by data
func _find_visual_block_by_data(block_data: Dictionary) -> VBoxContainer:
	if block_data.has("uuid"):
		return ESUtils.get_block_body(block_data.uuid, block_items)
	return null

# Editor Bar Pressed
func _on_editor_bar_pressed(id: int) -> void:
	match id:
		0: _window.show_editor_settings()
		1: _show_debug_window()
		2: _toggle_variables_panel()

# Scene Bar Pressed
func _on_scene_bar_pressed(id: int) -> void:
	match id:
		0: # Add Event
			_window.show_add_window("event", "standart")
		1: # Add Group
			_window.show_add_group()
		2: # Add Variable
			_window.show_add_variable()
		3: # Add Comment
			_on_finish_data({
				"block_type": "comment",
				"block_condition_type": "",
				"block_data": { "comment_text": "New comment" }
			}, {})


func _on_add_action(block):
	_window.show_add_window("action", "standart", block)

# When receiving data from the add window
func _on_finish_data(finish_data: Dictionary, block = {}):
	if finish_data.block_data.has("parameters"):
		for param_name in finish_data.block_data.parameters:
			finish_data.block_data.parameters[param_name].type.data = []
	if finish_data.has("current_data_body") and finish_data.current_data_body:
		# Change data
		var _uuid = finish_data.current_data_body.uuid
		var _current_data = ESUtils.find_data(_uuid, block)
		
		if !_current_data.is_empty():
			match finish_data.block_type:
				"standart":
					var _dir = block[_current_data.dir]
					var _index = _dir.find(_current_data.item)
					if _index != -1:
						_dir[_index] = finish_data.block_data
						finish_data.current_data_body.data = _dir[_index]
				_:
					finish_data.current_data_body.data.parameters = finish_data.block_data
					finish_data.current_data_body.data = finish_data.current_data_body.data
	else:
		# Create new
		var _block_data: Dictionary = block
		var _block_body: VBoxContainer
		
		match finish_data.block_type:
			"standart":
				if block.is_empty():
					_block_data = ESUtils.Data.create_block(finish_data.block_type, 0)
					_block_body = ESUtils.create_block(self, _block_data)
					ESUtils.create_condition(self, _block_body, finish_data.block_condition_type, finish_data.block_data)
					event_sheet_data.blocks.append(_block_data)
				else:
					_block_body = ESUtils.get_block_body(_block_data.uuid, block_items)
					ESUtils.create_condition(self, _block_body, finish_data.block_condition_type, finish_data.block_data)
				
				match finish_data.block_condition_type:
					"event":
						_block_body.data.events.append(finish_data.block_data)
					"action":
						_block_body.data.actions.append(finish_data.block_data)
			_:
				if block.is_empty():
					_block_data = ESUtils.Data.create_block(finish_data.block_type, 0, finish_data.block_data)
					_block_body = ESUtils.create_block(self, _block_data)
					event_sheet_data.blocks.append(_block_data)
	
	ESUtils.save_event_sheet_data()
	generate_code()

# Cancel selection when clicking on an empty area
func _on_select_content(data: Dictionary):
	if !ESUtils.is_ctrl_pressed:
		selected_content.clear()
		if !data.is_empty():
			selected_content.append(data)
		for item in get_tree().get_nodes_in_group("selectable"):
			if item is Button:
				var button: Button = item
				if button.button_pressed: if !button.is_hovered(): button.button_pressed = false
				else: if button.is_hovered(): button.button_pressed = true
			if item is VBoxContainer:
				var panel: VBoxContainer = item
				if panel.panel_pressed:
					if !panel.is_hovered:
						panel.panel_pressed = false
				else:
					if panel.is_hovered:
						panel.panel_pressed = true
	else:
		if !data.is_empty():
			selected_content.append(data)

func _on_change_content(data: Dictionary, data_body: Variant):
	_window.show_change_window(data, data_body)

func _on_add_content():
	if selected_content.size() == 1:
		_window.show_add_window(Types.ConditionType.EVENTS, Types.BlockType.STANDART, selected_content[0].resource_button.block)

func _on_context_menu():
	print("event context")

# Drag and Drop
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if ESUtils.dragging_data and ESUtils.dragging_data.class == "Block":
		return true
	return false

const ItemMove = preload("res://addons/event_sheet/source/utils/item_move.gd")

# If you move a block to another block
func _drop_data_block(from_item: Variant, to_item: Variant, move_type: Types.MoveBlock) -> void:
	var sorted_selected_array: Array = ESUtils.sort_selected_items_by_block_number()
	if move_type == Types.MoveBlock.DOWN:
		sorted_selected_array.reverse()
	match move_type:
		Types.MoveBlock.UP:
			ItemMove.move_up(self, sorted_selected_array, to_item)
		Types.MoveBlock.DOWN:
			ItemMove.move_down(self, sorted_selected_array, to_item)
		_:
			ItemMove.move_sub_or_content(self, sorted_selected_array, to_item)
	ESUtils.unselect_all()
	ESUtils.save_event_sheet_data()
	generate_code()

#func _on_editor_settings_change():
	#code_editor.visible = ESUtils.get_setting("code_editor_enable")

# Отладка через консоль
func toggle_debug(enabled: bool):
	if EventSheetDebugger and EventSheetDebugger.has_method("set_debugging"):
		EventSheetDebugger.set_debugging(enabled)
	print("EventSheet Debug: ", "Enabled" if enabled else "Disabled")

func clear_debug_log():
	if EventSheetDebugger and EventSheetDebugger.has_method("clear_debug_data"):
		EventSheetDebugger.clear_debug_data()
	print("EventSheet Debug: Log cleared")

# Показ окна отладки
func _show_debug_window():
	# Простое окно без диалогов
	var debug_window = Window.new()
	debug_window.title = "EventSheet Debugger"
	debug_window.size = Vector2i(600, 400)
	debug_window.unresizable = false
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	
	# Кнопки управления
	var hbox = HBoxContainer.new()
	var debug_btn = Button.new()
	debug_btn.text = "Toggle Debug"
	debug_btn.pressed.connect(func(): toggle_debug(!(EventSheetDebugger and EventSheetDebugger.has_method("is_debugging") and EventSheetDebugger.is_debugging)))
	hbox.add_child(debug_btn)
	
	var clear_btn = Button.new()
	clear_btn.text = "Clear Log"
	clear_btn.pressed.connect(clear_debug_log)
	hbox.add_child(clear_btn)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func(): debug_window.queue_free())
	hbox.add_child(close_btn)
	
	vbox.add_child(hbox)
	
	# Лог отладки
	var log_list = ItemList.new()
	log_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Заполняем лог
	if EventSheetDebugger and EventSheetDebugger.has_method("get_execution_log"):
		var logs = EventSheetDebugger.get_execution_log()
		for log_entry in logs:
			var level_text = ""
			match log_entry.level:
				0: # ERROR
					level_text = "[ERROR]"
				1: # WARNING
					level_text = "[WARN]"
				_:
					level_text = "[INFO]"
			log_list.add_item("%s %s %s" % [log_entry.timestamp, level_text, log_entry.message])
	else:
		log_list.add_item("EventSheetDebugger not available")
	
	vbox.add_child(log_list)
	
	debug_window.add_child(vbox)
	
	# Check if window already has a parent before adding to root
	if not debug_window.get_parent():
		get_tree().root.add_child(debug_window)
	debug_window.popup_centered()

func _setup_variables_panel():
	var panel_script = preload("res://addons/event_sheet/elements/variables/variables_panel.gd")
	variables_panel = VBoxContainer.new()
	variables_panel.set_script(panel_script)
	variables_panel.name = "Variables Panel"
	variables_panel.custom_minimum_size = Vector2(250, 0)
	variables_panel.visible = false
	
	# Добавляем панель слева от основного контента
	var hsplit = $VBoxContainer/HSplitContainer
	hsplit.add_child(variables_panel)
	hsplit.move_child(variables_panel, 0)

func _toggle_variables_panel():
	if variables_panel:
		variables_panel.visible = !variables_panel.visible
		if variables_panel.visible and variables_panel.has_method("_refresh_variables"):
			variables_panel._refresh_variables()

func _on_theme_changed() -> void:
	var background_color: Color = EditorInterface.get_editor_theme().get_color("background", "Editor")
	
	var _style: StyleBoxFlat = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if _style.bg_color != background_color:
		_style.bg_color = background_color
		_style.draw_center = true
		add_theme_stylebox_override("panel", _style)

func _on_scroll_container_mouse_entered() -> void:
	has_hover = true

func _on_scroll_container_mouse_exited() -> void:
	has_hover = false

# Handle variable changes and regenerate code
func _on_variable_changed(name: String, value: Variant, scope):
	if current_node:
		generate_code()

# Show context menu at position
func _show_context_menu(mouse_pos: Vector2):
	# Find block under mouse cursor
	var block_under_mouse = _find_block_under_mouse(mouse_pos)
	
	_popup_menu.clear()
	
	# Add context-sensitive menu items
	if ESUtils.selected_items.size() > 0:
		_popup_menu.add_item("Copy")
		_popup_menu.add_item("Delete")
		_popup_menu.add_separator()
	
	# Add general menu items
	for item in popup_menus["general"]:
		if item == "":
			_popup_menu.add_separator()
		else:
			_popup_menu.add_item(item)
	
	# Store the block under mouse for later use
	set_meta("context_block", block_under_mouse)
	_popup_menu.position = Vector2i(mouse_pos)
	_popup_menu.popup()

# Find block under mouse position
func _find_block_under_mouse(mouse_pos: Vector2) -> Dictionary:
	# Search through all blocks recursively
	return _search_blocks_recursive(block_items, mouse_pos)

func _search_blocks_recursive(container: Node, mouse_pos: Vector2) -> Dictionary:
	if not container:
		return {}
	
	for child in container.get_children():
		if not child:
			continue
			
		if child is VBoxContainer:
			# Check if mouse is over this block
			var block_rect = Rect2(child.global_position, child.size)
			if block_rect.has_point(mouse_pos):
				if child.has_meta("data"):
					return child.get_meta("data")
				elif "data" in child and child.data is Dictionary:
					return child.data
		
		# Search in child containers recursively
		if child.get_child_count() > 0:
			var result = _search_blocks_recursive(child, mouse_pos)
			if not result.is_empty():
				return result
	
	return {}
