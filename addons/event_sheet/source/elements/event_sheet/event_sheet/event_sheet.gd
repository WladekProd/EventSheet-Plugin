@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/types.gd")
const WindowClass = preload("res://addons/event_sheet/source/elements/window/window.gd")

var theme_colors: Dictionary = {
	"base_color": EditorInterface.get_editor_theme().get_color("base_color", "Editor"),
	"accent_color": EditorInterface.get_editor_theme().get_color("accent_color", "Editor"),
}

@onready var _popup_menu: PopupMenu = $PopupMenu
@onready var _window: Control = $Window
@onready var split_container: HSplitContainer = $HSplitContainer/ScrollContainer/HBoxContainer/HSplitContainer
@onready var code_editor: CodeEdit = $HSplitContainer/CodeEdit
@onready var event_items: VBoxContainer = $HSplitContainer/ScrollContainer/HBoxContainer/HSplitContainer/Events
@onready var action_items: VBoxContainer = $HSplitContainer/ScrollContainer/HBoxContainer/HSplitContainer/Actions

var result_script: String = ""

var event_sheet_data: Array[BlockResource]
var current_scene:
	set(p_current_scene):
		if p_current_scene != current_scene:
			if p_current_scene is VNode2D: current_scene = p_current_scene as VNode2D
			elif p_current_scene is VNode3D: current_scene = p_current_scene as VNode3D
			else: current_scene = null
			print("gbid: {0}".format([current_scene.global_block_id]))
			update_configuration_warnings()

var current_popup_menu: String = "general"
var popup_menus: Dictionary = {
	"general": ["Add Event", "Add Blank Event", "Add Group"]
}
const events: Dictionary = {}
const actions: Dictionary = {}





func _ready() -> void:
	if !_window.finish_data.is_connected(_on_finish_data):
		_window.finish_data.connect(_on_finish_data)
	ESUtils.is_dragging = false
	ESUtils.dragging_data = null
	code_editor.text = result_script

func _process(delta: float) -> void:
	pass




# Загрузить Event Sheet
func load_event_sheet():
	for item in event_items.get_children():
		item.queue_free()
	for item in action_items.get_children():
		item.queue_free()
	
	# Load Blocks
	for block in event_sheet_data:
		update_block(block)
	# Fix Visible
	for block in event_sheet_data:
		update_block(block)
	# Generate Code
	generate_code()

# Кэшированные элементы интерфейса для блоков
var blank_body_left_scene := preload("res://addons/event_sheet/elements/blank_body/blank_body_left.tscn")
var blank_body_right_scene := preload("res://addons/event_sheet/elements/blank_body/blank_body_right.tscn")
var event_scene := preload("res://addons/event_sheet/elements/conditions/event.tscn")
var action_scene := preload("res://addons/event_sheet/elements/conditions/action.tscn")

var temp_block_id: int

func add_data(data: Dictionary, to_block: BlockResource = null):
	var _data_type: Types.BlockType = data["type"]
	var _data: Dictionary = data["data"]
	var new_block: BlockResource
	
	if !to_block:
		new_block = BlockResource.new()
		new_block.id = current_scene.global_block_id if current_scene else temp_block_id
		new_block.block_type = _data_type
		if _data_type == Types.BlockType.GROUP:
			new_block.group_name = _data.group_name
			new_block.group_description = _data.group_description
		event_sheet_data.append(new_block)
	else:
		new_block = to_block

	# Добавляем ресурсы для событий и действий
	if _data_type == Types.BlockType.STANDART:
		if _data.condition == Types.ConditionType.EVENTS:
			var new_event: EventResource = _data.resource
			new_event.id = new_block.events.size()
			new_block.events.append(new_event)
		elif _data.condition == Types.ConditionType.ACTIONS:
			var new_action: ActionResource = _data.resource
			new_action.id = new_block.actions.size()
			new_block.actions.append(new_action)

	if current_scene:
		current_scene.global_block_id += 1
	else:
		temp_block_id += 1

	# Перерисовываем только новый блок
	update_block(new_block, to_block.level if to_block else 0)
	generate_code()

func update_block(block: BlockResource, block_level: int = 0, parent_left_body: VBoxContainer = null, parent_right_body: VBoxContainer = null):
	var left_body: VBoxContainer = ESUtils.find_block_body(event_items, block.id, "VBoxContainer")
	var right_body: VBoxContainer = ESUtils.find_block_body(action_items, block.id, "VBoxContainer")

	#print(block.id)
	#print(left_body)
	#print(right_body)

	block.level = block_level
	block.sub_blocks_state = Types.SubBlocksState.NONE

	if !left_body and !right_body:
		left_body = blank_body_left_scene.instantiate()
		right_body = blank_body_right_scene.instantiate()
		
		if parent_left_body: parent_left_body.add_child(left_body)
		else: event_items.add_child(left_body)
		
		if parent_right_body: parent_right_body.add_child(right_body)
		else: action_items.add_child(right_body)
		
		# Block ID | Block Level
		left_body.name = "{0} | {1}".format([block.id, block.level])
		left_body.blank_body_right = right_body
		left_body.dragged_block.connect(_drop_data_block)
		
		# Block ID | Block Level
		right_body.name = "{0} | {1}".format([block.id, block.level])
		right_body.blank_body_left = left_body
		right_body.add_action_button_up.connect(_on_add_action_button_up.bind())
	
	left_body.block = block
	left_body.blank_body_type = block.block_type
	left_body.sub_blocks_state = block.sub_blocks_state
	
	right_body.block = block
	right_body.blank_body_type = block.block_type
	
	# Добавляем события и действия
	if block.block_type == Types.BlockType.STANDART:
		for event in block.events:
			var event_item: Button = ESUtils.find_block_body(left_body.content_items, event.id, "Button")
			if !event_item:
				event_item = event_scene.instantiate()
				event_item.name = str(event.id)
				left_body.content.add_child(event_item)
				left_body.content.move_child(event_item, left_body.content.get_child_count() - 1)
				event_item.change_content.connect(_on_change_content)
				event_item.context_menu.connect(_on_context_menu)
			event_item.resource = event
		
		for action in block.actions:
			var action_item: Button = ESUtils.find_block_body(right_body.content_items, action.id, "Button")
			if !action_item:
				action_item = action_scene.instantiate()
				action_item.name = str(action.id)
				right_body.content.add_child(action_item)
				right_body.content.move_child(action_item, right_body.content.get_child_count() - 2)
				action_item.change_content.connect(_on_change_content)
				action_item.context_menu.connect(_on_context_menu)
			action_item.resource = action
	
	# Обновление групповых данных
	if block.block_type == Types.BlockType.GROUP:
		left_body.content.resource = block
		if !left_body.content.change_group.is_connected(_on_change_content):
			left_body.content.change_group.connect(_on_change_content)
		if !left_body.content.context_menu.is_connected(_on_context_menu):
			left_body.content.context_menu.connect(_on_context_menu)
	
	event_items.update_lines()
	
	# Рекурсивная обработка подблоков
	for sub_block in block.sub_blocks:
		update_block(sub_block, block_level + 1, left_body, right_body)

func update_block_hierarchy(root_block: BlockResource):
	update_block(root_block, root_block.level)



var function_contents: Dictionary = {
	"_init": []
}

func generate_code():
	print("generate code")
	result_script = ""
	function_contents = {
		"_init": []
	}
	
	if current_scene:
		result_script += "extends {0}\n".format([str(current_scene.get_class())])
	else:
		result_script += "extends Node\n"
	
	for block in event_sheet_data:
		process_block(block)
	
	# Добавляем содержимое всех функций в итоговый скрипт
	for func_name in function_contents.keys():
		var func_content = "\nfunc {0}():\n\t".format([func_name])
		for line in function_contents[func_name]:
			func_content += "{0}\n\t".format([line])
		result_script += func_content
	
	code_editor.text = result_script

func process_block(block: BlockResource, sub_block_index: int = 1, parent_func_name: String = "_init"):
	var func_name: String = parent_func_name
	var is_stipulation: bool
	
	var _spaces: String
	if func_name != "_init": _spaces = "\t".repeat(sub_block_index - 2) if sub_block_index >= 2 else ""
	else: _spaces = "\t".repeat(sub_block_index - 1) if sub_block_index >= 2 else ""
	
	if block.block_type == Types.BlockType.STANDART:
		for event: EventResource in block.events:
			var _script = event.gd_script
			var _template: String = _script.get_template(event.parameters).strip_edges()
			
			if _template.begins_with("func"):
				var _split_template: PackedStringArray = _template.split(" ")
				func_name = _split_template[1].substr(0, _split_template[1].find("("))
				
				# Проверка на существование функции и создание списка, если функция новая
				if func_name == "_ready" or func_name == "_process" or func_name == "_input":
					if !function_contents.has(func_name):
						function_contents[func_name] = []
					continue
			
			if _template.begins_with("if"):
				var _if_template: String = _spaces + "{0}".format([_template])
				
				if func_name.is_empty(): func_name = "_init"
				
				if function_contents.has(func_name):
					function_contents[func_name].append(_if_template)
				
				is_stipulation = true
		
		for action: ActionResource in block.actions:
			var _script = action.gd_script
			var _template: String = _script.get_template(action.parameters).strip_edges()
			var _split_template: PackedStringArray = _template.split("\n")
			
			var _action_spaces: String = _spaces + "\t" if is_stipulation else ""
			
			if func_name.is_empty(): func_name = "_init"
			
			# Если функция существует, добавляем действие к её содержимому
			if function_contents.has(func_name):
				if _split_template.size() > 1:
					for line in _split_template:
						function_contents[func_name].append(_action_spaces + line)
				else:
					function_contents[func_name].append(_action_spaces + _template)
				
	
	for sub_block in block.sub_blocks:
		process_block(sub_block, sub_block_index + 1, func_name)

# Event Sheet Inputs
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Event Sheet - Double Click
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			_window.add_condition(current_scene, null, Types.ConditionType.EVENTS)
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
			0: _window.add_condition(current_scene, null, Types.ConditionType.EVENTS)
			1: pass # add_blank_body()
			2: _window.add_group(current_scene)

func _on_add_action_button_up(block):
	_window.add_condition(current_scene, block, Types.ConditionType.ACTIONS)

func _on_finish_data(finish_data: Dictionary, block: BlockResource = null):
	add_data(finish_data, block)

func _on_change_content(resource, resource_button):
	_window.change_condition(current_scene, resource, resource_button)

func _on_context_menu():
	print("event context")

# Drag and Drop
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

# Если блок перетащить на event sheet
func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Получаем from объекты
	var from_block: BlockResource = data.block
	var from_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, from_block)
	var from_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, from_block)
	var from_left: VBoxContainer = data
	var from_right: VBoxContainer = ESUtils.find_block_body(action_items, from_block.id, "VBoxContainer")
	
	# Удаление блока из родительского контейнера, если он не корневой
	if from_block_parent:
		from_block_parent.sub_blocks.erase(from_block)
	else:
		event_sheet_data.erase(from_block)
	
	from_block.level = 0
	event_sheet_data.insert(event_sheet_data.size(), from_block)
	
	# Перемещение
	from_left.reparent(event_items)
	from_right.reparent(action_items)
	event_items.move_child(from_left, event_items.get_child_count())
	action_items.move_child(from_right, event_items.get_child_count())
	
	from_left.name = "{0} | {1}".format([from_block.id, 0])
	from_right.name = "{0} | {1}".format([from_block.id, 0])
	
	# Обновление блоков
	update_block_hierarchy(from_block)
	update_block_hierarchy(from_block_root)
	
	event_items.update_events(from_left)
	event_items.update_lines()
	
	generate_code()

# Если блок перетащить на другой блок
func _drop_data_block(from_left: Variant, to_left: Variant, move_block: Types.MoveBlock) -> void:

	# Получаем from объекты
	var from_block: BlockResource = from_left.block
	var from_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, from_block)
	var from_right: VBoxContainer = ESUtils.find_block_body(action_items, from_block.id, "VBoxContainer")

	# Получаем to объекты
	var to_block: BlockResource = to_left.block
	var to_block_parent: BlockResource = ESUtils.find_parent_block(event_sheet_data, to_block)
	var to_right: VBoxContainer = ESUtils.find_block_body(action_items, to_block.id, "VBoxContainer")
	
	# Проверяем, не является ли to_block потомком from_block
	if ESUtils.is_descendant_of(to_block, from_block):
		print("Нельзя перемещать блок в свои подблоки или под самого себя.")
		return
	
	# Удаление блока из родительского контейнера, если он не корневой
	if from_block_parent:
		from_block_parent.sub_blocks.erase(from_block)
	else:
		event_sheet_data.erase(from_block)
	
	# Перемещение в зависимости от move_block
	match move_block:
		Types.MoveBlock.UP:
			if to_block_parent:
				var index = to_block_parent.sub_blocks.find(to_block)
				from_block.level = to_block.level
				if index >= 0: to_block_parent.sub_blocks.insert(index, from_block)
				from_left.reparent(to_left.get_parent())
				from_right.reparent(to_right.get_parent())
				
				var to_index = to_left.get_index()
				to_left.get_parent().move_child(from_left, to_index)
				to_right.get_parent().move_child(from_right, to_index)
				from_left.name = "{0} | {1}".format([from_block.id, from_block.level])
				from_right.name = "{0} | {1}".format([from_block.id, from_block.level])
			else:
				var index = event_sheet_data.find(to_block)
				from_block.level = 0
				if index >= 0: event_sheet_data.insert(index, from_block)
				from_left.reparent(event_items)
				from_right.reparent(action_items)
				
				var to_index = to_left.get_index()
				event_items.move_child(from_left, to_index)
				action_items.move_child(from_right, to_index)
				from_left.name = "{0} | {1}".format([from_block.id, 0])
				from_right.name = "{0} | {1}".format([from_block.id, 0])
		Types.MoveBlock.DOWN:
			if to_block_parent:
				var index = to_block_parent.sub_blocks.find(to_block)
				from_block.level = to_block.level
				if index >= 0: to_block_parent.sub_blocks.insert(index + 1, from_block)
				from_left.reparent(to_left.get_parent())
				from_right.reparent(to_right.get_parent())
				
				var to_index = to_left.get_index() + 1
				to_left.get_parent().move_child(from_left, to_index)
				to_right.get_parent().move_child(from_right, to_index)
				from_left.name = "{0} | {1}".format([from_block.id, from_block.level])
				from_right.name = "{0} | {1}".format([from_block.id, from_block.level])
			else:
				var index = event_sheet_data.find(to_block)
				from_block.level = 0
				if index >= 0: event_sheet_data.insert(index + 1, from_block)
				from_left.reparent(event_items)
				from_right.reparent(action_items)
				
				var to_index = to_left.get_index() + 1
				event_items.move_child(from_left, to_index)
				action_items.move_child(from_right, to_index)
				from_left.name = "{0} | {1}".format([from_block.id, 0])
				from_right.name = "{0} | {1}".format([from_block.id, 0])
		Types.MoveBlock.SUB:
			from_block.level = to_block.level + 1
			to_block.sub_blocks.append(from_block)
			from_left.reparent(to_left)
			from_right.reparent(to_right)
			from_left.name = "{0} | {1}".format([from_block.id, from_block.level])
			from_right.name = "{0} | {1}".format([from_block.id, from_block.level])
	
	var from_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, from_block)
	var to_block_root: BlockResource = ESUtils.find_root_block(event_sheet_data, to_block)
	
	# Обновление блоков
	update_block_hierarchy(to_block_root)
	update_block_hierarchy(from_block_root)
	
	event_items.update_events(from_left)
	event_items.update_lines()
	
	generate_code()

func _on_theme_changed() -> void:
	var background_color: Color = EditorInterface.get_editor_theme().get_color("background", "Editor")
	
	var _style: StyleBoxFlat = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if _style.bg_color != background_color:
		_style.bg_color = background_color
		_style.draw_center = true
		add_theme_stylebox_override("panel", _style)
