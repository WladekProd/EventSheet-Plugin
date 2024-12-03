@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")
const UUID = preload("res://addons/event_sheet/source/utils/event_sheet_uuid.gd")
const WindowClass = preload("res://addons/event_sheet/source/elements/window/window.gd")

var theme_colors: Dictionary = {
	"base_color": EditorInterface.get_editor_theme().get_color("base_color", "Editor"),
	"accent_color": EditorInterface.get_editor_theme().get_color("accent_color", "Editor"),
}

@onready var _popup_menu: PopupMenu = $PopupMenu
@onready var _window: Control = $Window
@onready var block_items: VBoxContainer = $VBoxContainer/HSplitContainer/ScrollContainer/Control/Blocks
@onready var code_editor: CodeEdit = $VBoxContainer/HSplitContainer/CodeEdit

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
	"general": ["Add Event", "Add Blank Event", "Add Group"]
}
const events: Dictionary = {}
const actions: Dictionary = {}




func _input(event: InputEvent) -> void:
	if visible and ESUtils.is_plugin_screen and !_window.visible and !ESUtils.is_editing:
		if event is InputEventKey:
			if event.keycode == KEY_CTRL and event.pressed:
				ESUtils.is_ctrl_pressed = true
			else:
				ESUtils.is_ctrl_pressed = false
			if !event.ctrl_pressed:
				if !event.shift_pressed:
					ESUtils.is_split_pressed = false
					if event.keycode == KEY_E and event.pressed:
						# Добавить или создать эвент
						if ESUtils.selected_items.size() == 1:
							var selected_item = ESUtils.selected_items[0].object
							var selected_block
							if selected_item is VBoxContainer:
								selected_block = selected_item.block_resource
							_window.show_add_window("event", "standart", selected_block)
						else:
							if ESUtils.selected_items.size() > 1:
								ESUtils.unselect_all()
							_window.show_add_window("event", "standart")
					if event.keycode == KEY_A and event.pressed and ESUtils.selected_items.size() == 1:
						# Добавить событие
						var selected_item = ESUtils.selected_items[0].object
						var selected_block
						if selected_item is VBoxContainer:
							selected_block = selected_item.block_resource
						_window.show_add_window("action", "standart", selected_block)
					if event.keycode == KEY_G and event.pressed:
						# Создать группу
						_window.show_add_group()
					if event.keycode == KEY_Q and event.pressed:
						# Создать комментарий
						_on_finish_data({
							"block_type": "comment",
							"block_condition_type": "",
							"block_data": { "comment_text": "test" }
						}, {})
					if event.keycode == KEY_V and event.pressed:
						# Создать переменную
						_window.show_add_variable()
					if event.keycode == KEY_DELETE and event.pressed and !ESUtils.selected_items.is_empty():
						# Удалить блок
						remove_data()
				else: pass
			else:
				if event.keycode == KEY_C and event.pressed:
					if ESUtils.selected_items.size() > 0:
						ESUtils.clipboard_items.clear()
						for item in ESUtils.selected_items:
							
							ESUtils.clipboard_items.append(item.object.data)
							
							#if item.class == "Block":
								#var _resource: BlockResource = ESUtils.deep_duplicate_block(item.object.block_resource)
								#ESUtils.clipboard_items.append(_resource)
							#else:
								#ESUtils.clipboard_items.append(item.object.resource)
						
						DisplayServer.clipboard_set(str(ESUtils.clipboard_items))
				if event.keycode == KEY_V and event.pressed:
					if ESUtils.clipboard_items.size() > 0:
						paste_data()
				
				if !event.shift_pressed: pass
				else: pass
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# Выделить блок
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
			if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and has_hover:
				# Создать блок
				_window.show_add_window(Types.ConditionType.EVENTS, Types.BlockType.STANDART)

func _ready() -> void:
	#if !EditorInterface.get_editor_settings().settings_changed.is_connected(_on_editor_settings_change):
		#EditorInterface.get_editor_settings().settings_changed.connect(_on_editor_settings_change)
	if !_window.finish_data.is_connected(_on_finish_data):
		_window.finish_data.connect(_on_finish_data)
	ESUtils.selected_items.clear()
	ESUtils.is_editing = false
	ESUtils.is_dragging = false
	ESUtils.dragging_data = {}
	#code_editor.text = result_script
	#_on_editor_settings_change()

func _process(delta: float) -> void:
	pass




# Кэшированные элементы интерфейса для блоков
var block_body := preload("res://addons/event_sheet/elements/blocks/empty_block.tscn")
var event_body := preload("res://addons/event_sheet/elements/blocks/conditions/event.tscn")
var action_body := preload("res://addons/event_sheet/elements/blocks/conditions/action.tscn")

# Загрузить Event Sheet
func load_event_sheet():
	ESUtils.selected_items.clear()
	ESUtils.is_editing = false
	ESUtils.is_dragging = false
	ESUtils.dragging_data = {}
	
	for item in block_items.get_children():
		item.queue_free()
		item.free()
	
	for block in event_sheet_data.blocks:
		ESUtils.create_blocks(self, block)
	
	block_items.update_lines()

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
	#generate_code()

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
	#generate_code()

var function_contents: Dictionary = {
	"globals": [],
	"_init": { "params": [], "body": ["pass"] },
}

#func generate_code():
	#result_script = ""
	#function_contents = {
		#"globals": [],
		#"_init": {"params": [], "body": [
			#"set_process_input(true)",
			#"set_process_unhandled_input(true)",
			#"set_physics_process(true)",
			##"_ready()"
		#]},
	#}
	#
	#if current_scene:
		#result_script += "extends {0}\n\n".format([str(current_scene.get_class())])
	#else:
		#result_script += "extends Node\n\n"
	#
	#for block in event_sheet_data:
		#process_block(block)
	#
	## Добавляем глобальные переменные
	#for global_var in function_contents["globals"]:
		#result_script += "{0}\n".format([global_var])
	#
	## Добавляем содержимое всех функций в итоговый скрипт
	#for func_name in function_contents.keys():
		#if func_name == "globals":  # Пропускаем блок глобальных переменных
			#continue
		#
		#var func_data = function_contents[func_name]
		#var func_params = str(", ").join(func_data["params"])
		#var func_body = func_data["body"]
		#
		#var func_content = "\nfunc {0}({1}):\n".format([func_name, func_params])
		#for line in func_body:
			#func_content += "\t{0}\n".format([line])
		#result_script += func_content
	#
	#code_editor.text = result_script
	#
	#var _script = GDScript.new()
	#_script.source_code = result_script
	#current_scene.final_script = _script

#func process_block(block: BlockResource, sub_block_index: int = 1, parent_func_name: String = "_init"):
	#var func_name: String = parent_func_name
	#var is_stipulation: bool
	#
	#var _spaces: String
	#if func_name != "_init": 
		#_spaces = "\t".repeat(sub_block_index - 2) if sub_block_index >= 2 else ""
	#else: 
		#_spaces = "\t".repeat(sub_block_index - 1) if sub_block_index >= 2 else ""
	#
	#if block.block_type == Types.BlockType.VARIABLE:
		#if sub_block_index <= 1:
			#var _var_template = "var {0} = {1}".format([block.variable_name, str(block.variable_value)]).strip_edges()
			#if not function_contents["globals"].has(_var_template):
				#function_contents["globals"].append(_var_template)
		#else:
			#var _var_template = _spaces + "var {0} = {1}".format([block.variable_name, str(block.variable_value)]).strip_edges()
			#if not function_contents[parent_func_name]["body"].has(_var_template):
				#function_contents[parent_func_name]["body"].append(_var_template)
	#elif block.block_type == Types.BlockType.STANDART:
		#for event: EventResource in block.events:
			#var _script = event.gd_script
			#var _template: String = _script.get_template(event.parameters).strip_edges()
			#
			#if _template.begins_with("func"):
				#var _split_template: PackedStringArray = _template.split(" ")
				#func_name = _split_template[1].substr(0, _split_template[1].find("("))
				#
				## Извлечение параметров функции
				#var param_start = _template.find("(") + 1
				#var param_end = _template.find(")")
				#var func_params = _template.substr(param_start, param_end - param_start).split(", ")
				#
				## Проверка на существование функции и создание списка, если функция новая
				#if !function_contents.has(func_name):
					#function_contents[func_name] = { "params": func_params, "body": [] }
				#continue
			#
			#if _template.begins_with("if"):
				#var _if_template: String = _spaces + "{0}".format([_template])
				#
				#if func_name.is_empty(): 
					#func_name = "_init"
				#
				#if function_contents.has(func_name):
					#function_contents[func_name]["body"].append(_if_template)
					#sub_block_index += 1
				#
				#is_stipulation = true
		#
		#for action: ActionResource in block.actions:
			#var _object_name: String
			#if action.pick_object and action.pick_object.object != null:
				#var _object_node: Node = get_node(action.pick_object.object)
				#var _object_path = '$"{0}"'.format([str(current_scene.get_path_to(_object_node))])
				#_object_name = str(action.pick_object.name).to_snake_case()
				#var _var_template = "@onready var {0}".format([_object_name, str(_object_path)]).strip_edges()
				#if not function_contents["globals"].has(_var_template):
					#function_contents["globals"].append(_var_template)
				#
				#var _init_template = "{0} = {1}".format([_object_name, str(_object_path)]).strip_edges()
				#if not function_contents["_init"]["body"].has(_init_template):
					#function_contents["_init"]["body"].insert(0, _init_template)
			#
			#var _script = action.gd_script
			#var _template: String = _script.get_template(action.parameters).strip_edges()
			#var _split_template: PackedStringArray = _template.split("\n")
			#
			#var _action_spaces: String = _spaces + "\t" if is_stipulation else ""
			#
			#if block.events.is_empty() and sub_block_index > 1:
				#_action_spaces += "\t"
			#
			#if func_name.is_empty(): 
				#func_name = "_init"
			#
			## Если функция существует, добавляем действие к её содержимому
			#if function_contents.has(func_name):
				#if _split_template.size() > 1:
					#for line in _split_template:
						#function_contents[func_name]["body"].append(_action_spaces + line.format({ "object": _object_name }))
				#else:
					#function_contents[func_name]["body"].append(_action_spaces + _template.format({ "object": _object_name }))
	#
	#if function_contents.has(func_name):
		#if function_contents[func_name]["body"].size() == 0:
			#function_contents[func_name]["body"].append("pass")
		#else:
			#function_contents[func_name]["body"].erase("pass")
	#
	#for sub_block in block.sub_blocks:
		#process_block(sub_block, sub_block_index + 1, func_name)

# Event Sheet Inputs
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
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
			var mouse_pos = Vector2i(event.global_position) + get_window().position
			_popup_menu.clear()
			for item in popup_menus["general"]:
				if item == "":
					_popup_menu.add_separator()
				else:
					_popup_menu.add_item(item)
			_popup_menu.set_size(Vector2(0, 0))
			_popup_menu.set_position(mouse_pos)
			_popup_menu.show()

# Popup Menu Pressed
func _on_popup_menu_index_pressed(index: int) -> void:
	if current_popup_menu == "general":
		match index:
			0: _window.show_add_window(Types.ConditionType.EVENTS, Types.BlockType.STANDART)
			1: pass # add_blank_body()
			2: _window.show_add_group()

# Editor Bar Pressed
func _on_editor_bar_pressed(id: int) -> void:
	match id:
		0: _window.show_editor_settings()

# Scene Bar Pressed
func _on_scene_bar_pressed(id: int) -> void:
	match id:
		0: pass

func _on_add_action(block):
	_window.show_add_window("action", "standart", block)

func _on_finish_data(finish_data: Dictionary, block = {}):
	print(finish_data)
	#print(block)
	
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
	#generate_code()

#func _on_editor_settings_change():
	#code_editor.visible = ESUtils.get_setting("code_editor_enable")

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
