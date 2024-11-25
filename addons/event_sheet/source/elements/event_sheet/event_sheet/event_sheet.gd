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

var event_sheet_data: Array[BlockResource]
var current_scene: Node:
	set(p_current_scene):
		if p_current_scene != current_scene:
			if p_current_scene is VNode2D: current_scene = p_current_scene as VNode2D
			elif p_current_scene is VNode3D: current_scene = p_current_scene as VNode3D
			else: current_scene = null
			ESUtils.current_scene = current_scene
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
							_window.show_add_window(Types.ConditionType.EVENTS, Types.BlockType.STANDART, selected_block)
						else:
							if ESUtils.selected_items.size() > 1:
								ESUtils.unselect_all()
							_window.show_add_window(Types.ConditionType.EVENTS, Types.BlockType.STANDART)
					if event.keycode == KEY_A and event.pressed and ESUtils.selected_items.size() == 1:
						# Добавить событие
						var selected_item = ESUtils.selected_items[0].object
						var selected_block
						if selected_item is VBoxContainer:
							selected_block = selected_item.block_resource
						_window.show_add_window(Types.ConditionType.ACTIONS, Types.BlockType.STANDART, selected_block)
					if event.keycode == KEY_G and event.pressed:
						# Создать группу
						_window.show_add_group()
					if event.keycode == KEY_Q and event.pressed:
						# Создать комментарий
						add_data({
							"block_type": Types.BlockType.COMMENT,
							"block_data": {
								"comment_text": "test"
							}
						}, null)
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
							if item.class == "Block":
								var _resource: BlockResource = ESUtils.deep_duplicate_block(item.object.block_resource)
								ESUtils.clipboard_items.append(_resource)
							else:
								ESUtils.clipboard_items.append(item.object.resource)
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
var empty_block := preload("res://addons/event_sheet/elements/blocks/empty_block.tscn")
var event_instance := preload("res://addons/event_sheet/elements/blocks/conditions/event.tscn")
var action_instance := preload("res://addons/event_sheet/elements/blocks/conditions/action.tscn")

# Загрузить Event Sheet
func load_event_sheet():
	ESUtils.selected_items.clear()
	ESUtils.is_editing = false
	ESUtils.is_dragging = false
	ESUtils.dragging_data = {}
	
	for item in block_items.get_children():
		item.queue_free()
		item.free()
	
	if block_items.get_child_count(true) == 0:
		for block in event_sheet_data:
			load_block(block)
		generate_code()

# Рекурсивно загрузить саб-блоки из Event Sheet
func load_block(block: BlockResource, block_level: int = 0, parent_item: VBoxContainer = null):
	if block == null: return
	
	var _empty_block = ESUtils.create_block(self, block.block_type, block, parent_item, false, false, true)
	_empty_block = ESUtils.update_block(self, _empty_block, block_level)
	
	for sub_block in block.sub_blocks:
		load_block(sub_block, block_level + 1, _empty_block)

func remove_data():
	ESUtils.undo_redo.create_action("Remove Blocks")
	for item in ESUtils.selected_items:
		if !item.has("object") or !item.has("class"):
			continue
		var _item_object: Control = item.object
		if _item_object:
			var _item_index: int = ESUtils.find_index(_item_object, event_sheet_data)
			var _parent_item_resource: BlockResource = ESUtils.get_parent_block_resource(_item_object, _item_object.get_parent())
			ESUtils.undo_redo.add_do_method(ESUtils, "remove_item", _item_object, event_sheet_data)
			ESUtils.undo_redo.add_undo_method(ESUtils, "add_item", _item_object, _item_index, _item_object.get_parent(), event_sheet_data)
			ESUtils.undo_redo.add_do_method(self, "update_block", _parent_item_resource, _parent_item_resource.level if _parent_item_resource else 0)
			ESUtils.undo_redo.add_undo_method(self, "update_block", _parent_item_resource, _parent_item_resource.level if _parent_item_resource else 0)
			ESUtils.undo_redo.add_undo_reference(_item_object)
			
	ESUtils.undo_redo.commit_action()
	
	ESUtils.unselect_all()
	generate_code()

func paste_data():
	var _selected_item = ESUtils.selected_items[0] if ESUtils.selected_items.size() > 0 else null
	var _to_block: BlockResource = null
	
	for _resource in ESUtils.clipboard_items:
		if _selected_item != null:
			_to_block = _selected_item.object.block_resource if _selected_item.class == "Block" else _selected_item.object.empty_block.block_resource
			
			if _selected_item.class == "Block":
				if _selected_item.object.block_type == Types.BlockType.STANDART or _selected_item.object.block_type == Types.BlockType.GROUP:
					_to_block = _to_block
				else:
					_to_block = null
		
		if _resource is BlockResource:
			var _duplicated_block: BlockResource = ESUtils.deep_duplicate_block(_resource)
			if _to_block:
				_to_block.sub_blocks.append(_duplicated_block)
			else:
				event_sheet_data.append(_duplicated_block)
				update_block(_duplicated_block)
		else:
			var _duplicated_condition = ESUtils.deep_duplicate_condition(_resource)
			if _to_block:
				if _duplicated_condition is EventResource: _to_block.events.append(_duplicated_condition)
				elif _duplicated_condition is ActionResource: _to_block.actions.append(_duplicated_condition)
			else:
				return
	
	if _to_block: update_block(_to_block, _to_block.level)
	
	ESUtils.unselect_all()
	generate_code()

func add_data(data: Dictionary, to_block: BlockResource = null):
	var _data_type = data.block_type
	var _data = data.block_data
	
	var _new_block_item: VBoxContainer = null
	if to_block != null:
		_new_block_item = ESUtils.find_empty_block(block_items, to_block.id, "VBoxContainer")
	else:
		_new_block_item = ESUtils.create_block(self, _data_type, _data)
	var _new_block: BlockResource = _new_block_item.block_resource
	
	if _data_type == Types.BlockType.STANDART:
		if _data is EventResource:
			if data.has("button"):
				var _event_uuid: String = data.button.id
				var _event_index: int = ESUtils.find_index_by_id(_new_block.events, _event_uuid)
				_data.id = _event_uuid
				_new_block.events[_event_index] = _data
			else:
				ESUtils.create_event(self, _new_block_item, _data)
		elif _data is ActionResource:
			if data.has("button"):
				var _action_uuid: String = data.button.id
				var _action_index: int = ESUtils.find_index_by_id(_new_block.actions, _action_uuid)
				_data.id = _action_uuid
				_new_block.actions[_action_index] = _data
			else:
				ESUtils.create_action(self, _new_block_item, _data)
	
	update_block(_new_block, to_block.level if to_block else 0)
	generate_code()

func update_block(block: BlockResource, block_level: int = 0, parent_empty_block: VBoxContainer = null):
	if block == null: return
	
	var _empty_block = ESUtils.find_empty_block(block_items, block.id, "VBoxContainer")
	if _empty_block == null:
		_empty_block = ESUtils.create_block(self, block.block_type, block, parent_empty_block, false, false, true)
	_empty_block = ESUtils.update_block(self, _empty_block, block_level)
	
	for sub_block in block.sub_blocks:
		update_block(sub_block, block_level + 1, _empty_block)

func update_block_hierarchy(root_block: BlockResource):
	update_block(root_block, root_block.level)



var function_contents: Dictionary = {
	"globals": [],
	"_init": { "params": [], "body": ["pass"] },
}

func generate_code():
	result_script = ""
	function_contents = {
		"globals": [],
		"_init": {"params": [], "body": [
			"set_process_input(true)",
			"set_process_unhandled_input(true)",
			"set_physics_process(true)",
			#"_ready()"
		]},
	}
	
	if current_scene:
		result_script += "extends {0}\n\n".format([str(current_scene.get_class())])
	else:
		result_script += "extends Node\n\n"
	
	for block in event_sheet_data:
		process_block(block)
	
	# Добавляем глобальные переменные
	for global_var in function_contents["globals"]:
		result_script += "{0}\n".format([global_var])
	
	# Добавляем содержимое всех функций в итоговый скрипт
	for func_name in function_contents.keys():
		if func_name == "globals":  # Пропускаем блок глобальных переменных
			continue
		
		var func_data = function_contents[func_name]
		var func_params = str(", ").join(func_data["params"])
		var func_body = func_data["body"]
		
		var func_content = "\nfunc {0}({1}):\n".format([func_name, func_params])
		for line in func_body:
			func_content += "\t{0}\n".format([line])
		result_script += func_content
	
	code_editor.text = result_script
	
	var _script = GDScript.new()
	_script.source_code = result_script
	current_scene.final_script = _script

func process_block(block: BlockResource, sub_block_index: int = 1, parent_func_name: String = "_init"):
	var func_name: String = parent_func_name
	var is_stipulation: bool
	
	var _spaces: String
	if func_name != "_init": 
		_spaces = "\t".repeat(sub_block_index - 2) if sub_block_index >= 2 else ""
	else: 
		_spaces = "\t".repeat(sub_block_index - 1) if sub_block_index >= 2 else ""
	
	if block.block_type == Types.BlockType.VARIABLE:
		if sub_block_index <= 1:
			var _var_template = "var {0} = {1}".format([block.variable_name, str(block.variable_value)]).strip_edges()
			if not function_contents["globals"].has(_var_template):
				function_contents["globals"].append(_var_template)
		else:
			var _var_template = _spaces + "var {0} = {1}".format([block.variable_name, str(block.variable_value)]).strip_edges()
			if not function_contents[parent_func_name]["body"].has(_var_template):
				function_contents[parent_func_name]["body"].append(_var_template)
	elif block.block_type == Types.BlockType.STANDART:
		for event: EventResource in block.events:
			var _script = event.gd_script
			var _template: String = _script.get_template(event.parameters).strip_edges()
			
			if _template.begins_with("func"):
				var _split_template: PackedStringArray = _template.split(" ")
				func_name = _split_template[1].substr(0, _split_template[1].find("("))
				
				# Извлечение параметров функции
				var param_start = _template.find("(") + 1
				var param_end = _template.find(")")
				var func_params = _template.substr(param_start, param_end - param_start).split(", ")
				
				# Проверка на существование функции и создание списка, если функция новая
				if !function_contents.has(func_name):
					function_contents[func_name] = { "params": func_params, "body": [] }
				continue
			
			if _template.begins_with("if"):
				var _if_template: String = _spaces + "{0}".format([_template])
				
				if func_name.is_empty(): 
					func_name = "_init"
				
				if function_contents.has(func_name):
					function_contents[func_name]["body"].append(_if_template)
					sub_block_index += 1
				
				is_stipulation = true
		
		for action: ActionResource in block.actions:
			var _object_name: String
			if action.pick_object and action.pick_object.object != null:
				var _object_node: Node = get_node(action.pick_object.object)
				var _object_path = '$"{0}"'.format([str(current_scene.get_path_to(_object_node))])
				_object_name = str(action.pick_object.name).to_snake_case()
				var _var_template = "@onready var {0}".format([_object_name, str(_object_path)]).strip_edges()
				if not function_contents["globals"].has(_var_template):
					function_contents["globals"].append(_var_template)
				
				var _init_template = "{0} = {1}".format([_object_name, str(_object_path)]).strip_edges()
				if not function_contents["_init"]["body"].has(_init_template):
					function_contents["_init"]["body"].insert(0, _init_template)
			
			var _script = action.gd_script
			var _template: String = _script.get_template(action.parameters).strip_edges()
			var _split_template: PackedStringArray = _template.split("\n")
			
			var _action_spaces: String = _spaces + "\t" if is_stipulation else ""
			
			if block.events.is_empty() and sub_block_index > 1:
				_action_spaces += "\t"
			
			if func_name.is_empty(): 
				func_name = "_init"
			
			# Если функция существует, добавляем действие к её содержимому
			if function_contents.has(func_name):
				if _split_template.size() > 1:
					for line in _split_template:
						function_contents[func_name]["body"].append(_action_spaces + line.format({ "object": _object_name }))
				else:
					function_contents[func_name]["body"].append(_action_spaces + _template.format({ "object": _object_name }))
	
	if function_contents.has(func_name):
		if function_contents[func_name]["body"].size() == 0:
			function_contents[func_name]["body"].append("pass")
		else:
			function_contents[func_name]["body"].erase("pass")
	
	for sub_block in block.sub_blocks:
		process_block(sub_block, sub_block_index + 1, func_name)

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
	_window.show_add_window(Types.ConditionType.ACTIONS, Types.BlockType.STANDART, block)

func _on_finish_data(finish_data: Dictionary, block: BlockResource = null):
	add_data(finish_data, block)

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

func _on_change_content(resource, resource_button):
	_window.show_change_window(resource, resource_button)

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

# Если блок перетащить на event sheet
func _drop_data(at_position: Vector2, data: Variant) -> void:
	
	var selected_item
	var from_block: BlockResource
	
	for item in ESUtils.sort_selected_items_by_block_number():
		selected_item = item.object
		if selected_item is VBoxContainer:
			# Получаем from объекты
			from_block = selected_item.block_resource
			var from_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, from_block)
			var from_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, from_block)
			var from_empty_block: VBoxContainer = selected_item
			
			# Удаление блока из родительского контейнера, если он не корневой
			if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
			else: event_sheet_data.erase(from_block)
			
			from_block.level = 0
			event_sheet_data.insert(event_sheet_data.size(), from_block)
			
			# Перемещение
			selected_item.reparent(block_items)
			block_items.move_child(selected_item, block_items.get_child_count())
			
			# Обновление блоков
			update_block_hierarchy(from_block)
			update_block_hierarchy(from_block_root)
			block_items.update_events(selected_item)
			block_items.update_lines()
	
	ESUtils.unselect_all()
	generate_code()

# Если блок перетащить на другой блок
func _drop_data_block(from_empty_block: Variant, to_empty_block: Variant, move_type: Types.MoveBlock) -> void:
	var sorted_selected_array: Array = ESUtils.sort_selected_items_by_block_number()
	if move_type == Types.MoveBlock.DOWN:
		sorted_selected_array.reverse()

	for item in sorted_selected_array:
		var selected_item = item.object
		if selected_item is VBoxContainer:

			# Получаем from объекты
			var from_block: BlockResource = selected_item.block_resource
			var from_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, from_block)
			
			# Получаем to объекты
			var to_block: BlockResource = to_empty_block.block_resource
			var to_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, to_block)
			
			var from_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, from_block)
			var to_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, to_block)
			
			# Проверяем, не является ли to_block потомком from_block
			if ESUtils.is_descendant_of(to_block, from_block):
				print("Нельзя перемещать блок в свои подблоки или под самого себя.")
				return
			
			# Перемещение в зависимости от move_type
			match move_type:
				Types.MoveBlock.UP:
					if to_block_parent:
						var to_index = to_empty_block.get_index()
						if from_block_parent == to_block_parent:
							if selected_item.get_index() > to_index - 1:
								pass
							elif selected_item.get_index() - 1 < to_index:
								to_index -= 1
							elif selected_item.get_index() - 1 == to_index:
								continue
						
						if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
						else: event_sheet_data.erase(from_block)
						
						var index = to_block_parent.sub_blocks.find(to_block)
						from_block.level = to_block.level
						if index >= 0: to_block_parent.sub_blocks.insert(index, from_block)
						selected_item.reparent(to_empty_block.get_parent())
						
						to_empty_block.get_parent().move_child(selected_item, to_index)
					else:
						var to_index = to_empty_block.get_index()
						if from_block_parent == to_block_parent:
							if selected_item.get_index() > to_index - 1:
								pass
							elif selected_item.get_index() - 1 < to_index:
								to_index -= 1
							elif selected_item.get_index() - 1 == to_index:
								continue
						
						if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
						else: event_sheet_data.erase(from_block)
						
						var index = event_sheet_data.find(to_block)
						from_block.level = to_block.level
						if index >= 0: event_sheet_data.insert(index, from_block)
						selected_item.reparent(block_items)
						
						block_items.move_child(selected_item, to_index)
				Types.MoveBlock.DOWN:
					if to_block_parent:
						var to_index = to_empty_block.get_index()
						if from_block_parent == to_block_parent:
							if selected_item.get_index() == to_index + 1:
								continue
							elif selected_item.get_index() > to_index + 1:
								to_index += 1
						else: to_index += 1
						
						if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
						else: event_sheet_data.erase(from_block)
						
						var index = to_block_parent.sub_blocks.find(to_block)
						from_block.level = to_block.level
						if index >= 0: to_block_parent.sub_blocks.insert(index + 1, from_block)
						selected_item.reparent(to_empty_block.get_parent())
						
						to_empty_block.get_parent().move_child(selected_item, to_index)
					else:
						var to_index = to_empty_block.get_index()
						if from_block_parent == to_block_parent:
							if selected_item.get_index() == to_index + 1:
								continue
							elif selected_item.get_index() > to_index + 1:
								to_index += 1
						else: to_index += 1
						
						if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
						else: event_sheet_data.erase(from_block)
						
						var index = event_sheet_data.find(to_block)
						from_block.level = to_block.level
						if index >= 0: event_sheet_data.insert(index + 1, from_block)
						selected_item.reparent(block_items)
						
						block_items.move_child(selected_item, to_index)
				Types.MoveBlock.SUB:
					if from_block_parent: from_block_parent.sub_blocks.erase(from_block)
					else: event_sheet_data.erase(from_block)
					
					from_block.level = to_block.level + 1
					to_block.sub_blocks.append(from_block)
					selected_item.reparent(to_empty_block)
			
			# Обновление блоков
			update_block_hierarchy(from_block_root)
			update_block_hierarchy(to_block_root)
			block_items.update_events(selected_item)
			block_items.update_lines()
	
	ESUtils.unselect_all()
	generate_code()

func _drop_data_event(from_event: Variant, to_event: Variant, move_type: Types.MoveBlock):
	var sorted_selected_array: Array = ESUtils.sort_selected_items_by_block_number()
	if move_type == Types.MoveBlock.DOWN or move_type == Types.MoveBlock.CONTENT:
		sorted_selected_array.reverse()
	
	for item in sorted_selected_array:
		var selected_item = item.object
		
		var from_res: EventResource = selected_item.resource
		var to_res: EventResource = to_event.resource if to_event is Button else null
		
		var from_block: BlockResource = selected_item.empty_block.block_resource
		var to_block: BlockResource = to_event.empty_block.block_resource if to_event is Button else to_event.block_resource
		
		if selected_item is Button:
			match move_type:
				Types.MoveBlock.CONTENT:
					if selected_item.empty_block == to_event: continue
					
					from_block.events.erase(from_res)
					to_block.events.append(from_res)
					
					selected_item.reparent(to_event.block_events)
					to_event.block_events.move_child(selected_item, to_event.block_events.get_child_count())
					selected_item.empty_block = to_event
				Types.MoveBlock.UP:
					if from_res == to_res: continue
					if !from_block or !to_block: continue
					
					var to_index = to_event.get_index()
					if selected_item.empty_block == to_event.empty_block:
						if selected_item.get_index() > to_index - 1:
							pass
						elif selected_item.get_index() - 1 < to_index:
							to_index -= 1
						elif selected_item.get_index() - 1 == to_index:
							continue
					
					from_block.events.erase(from_res)
					
					var index = to_block.events.find(to_res)
					if index >= 0: to_block.events.insert(index, from_res)
					
					selected_item.reparent(to_event.get_parent())
					to_event.empty_block.block_events.move_child(selected_item, to_index)
					selected_item.empty_block = to_event.empty_block
				Types.MoveBlock.DOWN:
					if from_res == to_res: continue
					if !from_block or !to_block: continue
					
					var to_index = to_event.get_index()
					if selected_item.empty_block == to_event.empty_block:
						if selected_item.get_index() == to_index + 1:
							continue
						elif selected_item.get_index() > to_index + 1:
							to_index += 1
					else:
						to_index += 1
					
					from_block.events.erase(from_res)
					
					var index = to_block.events.find(to_res)
					if index >= 0: to_block.events.insert(index + 1, from_res)
					
					selected_item.reparent(to_event.get_parent())
					to_event.empty_block.block_events.move_child(selected_item, to_index)
					selected_item.empty_block = to_event.empty_block
	
	ESUtils.unselect_all()
	generate_code()

func _drop_data_action(from_action: Variant, to_action: Variant, move_type: Types.MoveBlock):
	var sorted_selected_array: Array = ESUtils.sort_selected_items_by_block_number()
	if move_type == Types.MoveBlock.DOWN or move_type == Types.MoveBlock.CONTENT:
		sorted_selected_array.reverse()
	
	for item in sorted_selected_array:
		var selected_item = item.object
		
		var from_res: ActionResource = selected_item.resource
		var to_res: ActionResource = to_action.resource if to_action is Button else null
		
		var from_block: BlockResource = selected_item.empty_block.block_resource
		var to_block: BlockResource = to_action.empty_block.block_resource if to_action is Button else to_action.block_resource
		
		if selected_item is Button:
			match move_type:
				Types.MoveBlock.CONTENT:
					if selected_item.empty_block == to_action: continue
					
					from_block.actions.erase(from_res)
					to_block.actions.append(from_res)
					
					selected_item.reparent(to_action.block_actions)
					to_action.block_actions.move_child(selected_item, to_action.block_actions.get_child_count())
					selected_item.empty_block = to_action
				Types.MoveBlock.UP:
					if from_res == to_res: continue
					if !from_block or !to_block: continue
					
					var to_index = to_action.get_index()
					if selected_item.empty_block == to_action.empty_block:
						if selected_item.get_index() > to_index - 1:
							pass
						elif selected_item.get_index() - 1 < to_index:
							to_index -= 1
						elif selected_item.get_index() - 1 == to_index:
							continue
					
					from_block.actions.erase(from_res)
					
					var index = to_block.actions.find(to_res)
					if index >= 0: to_block.actions.insert(index, from_res)
					
					selected_item.reparent(to_action.get_parent())
					to_action.empty_block.block_actions.move_child(selected_item, to_index)
					selected_item.empty_block = to_action.empty_block
				Types.MoveBlock.DOWN:
					if from_res == to_res: continue
					if !from_block or !to_block: continue
					
					var to_index = to_action.get_index()
					if selected_item.empty_block == to_action.empty_block:
						if selected_item.get_index() == to_index + 1:
							continue
						elif selected_item.get_index() > to_index + 1:
							to_index += 1
					else:
						to_index += 1
					
					from_block.actions.erase(from_res)
					
					var index = to_block.actions.find(to_res)
					if index >= 0: to_block.actions.insert(index + 1, from_res)
					
					selected_item.reparent(to_action.get_parent())
					to_action.empty_block.block_actions.move_child(selected_item, to_index)
					selected_item.empty_block = to_action.empty_block
	
	ESUtils.unselect_all()
	generate_code()

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
