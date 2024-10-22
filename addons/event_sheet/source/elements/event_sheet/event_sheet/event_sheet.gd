@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/types.gd")
const WindowClass = preload("res://addons/event_sheet/source/elements/window/window.gd")

@onready var _popup_menu: PopupMenu = $PopupMenu
@onready var _window: Control = $Window
@onready var event_items: VBoxContainer = $HSplitContainer/ScrollContainer/HSplitContainer/Events
@onready var action_items: VBoxContainer = $HSplitContainer/ScrollContainer/HSplitContainer/Actions

var event_sheet_data: Array[BlockResource]
var current_scene:
	set(p_current_scene):
		if p_current_scene != current_scene:
			if p_current_scene is VNode2D: current_scene = p_current_scene as VNode2D
			elif p_current_scene is VNode3D: current_scene = p_current_scene as VNode3D
			else: current_scene = null
			update_configuration_warnings()
var current_popup_menu: String = "general"
var popup_menus: Dictionary = {
	"general": ["Add Event", "Add Blank Event"]
}
const events: Dictionary = {}
const actions: Dictionary = {}



func _ready() -> void:
	if !_window.finish_data.is_connected(_on_finish_data):
		_window.finish_data.connect(_on_finish_data)

func _process(delta: float) -> void:
	pass



## Add New Blank Body
#func add_blank_body() -> Dictionary:
	#var blank_body_event_instance: VBoxContainer = load("res://addons/event_sheet/elements/Blank Body/blank_body_event.tscn").instantiate()
	#var blank_body_action_instance: VBoxContainer = load("res://addons/event_sheet/elements/Blank Body/blank_body_action.tscn").instantiate()
	#blank_body_action_instance.add_action_button_up.connect(_on_add_action_button_up)
	#
	#blank_body_event_instance.blank_body_action = blank_body_action_instance
	#blank_body_action_instance.blank_body_event = blank_body_event_instance
	#
	#event_items.add_child(blank_body_event_instance)
	#blank_body_event_instance.owner = event_items.get_owner()
	#
	#action_items.add_child(blank_body_action_instance)
	#blank_body_action_instance.owner = action_items.get_owner()
	#
	#return { "event": blank_body_event_instance, "action": blank_body_action_instance}
#
## Add New Data Body
#func add_data_body(data: Dictionary):
	#var blank_body: Dictionary = add_blank_body()
	#var condition_type: Types.ConditionType = data.condition
	#match condition_type:
		#Types.ConditionType.EVENTS:
			#var resource: EventResource = data.resource
			#
			#var event_instance: Button = load("res://addons/event_sheet/elements/Event/event.tscn").instantiate()
			#event_instance.resource = resource
			#
			#var items: VBoxContainer = blank_body["event"].event_items
			#items.add_child(event_instance)
		#Types.ConditionType.ACTIONS:
			#var resource: ActionResource = data.resource
			#
			#var action_instance: Button = load("res://addons/event_sheet/elements/Action/action.tscn").instantiate()
			#action_instance.resource = resource
			#
			#var items: VBoxContainer = blank_body["action"].action_items
			#items.add_child(action_instance)
			#items.move_child(action_instance, items.get_child_count() - 2)



var global_block_id: int = 0
var current_block: BlockResource

func add_data_to_block(data: Dictionary):
	var condition_type: Types.ConditionType = data.condition
	
	match condition_type:
		Types.ConditionType.EVENTS:
			var resource: EventResource = data.resource
			if !current_block:
				var new_block: BlockResource = BlockResource.new()
				new_block.id = global_block_id
				new_block.events.append(resource)
				event_sheet_data.append(new_block)
			else:
				current_block.events.append(resource)
		Types.ConditionType.ACTIONS:
			var resource: ActionResource = data.resource
			if !current_block:
				var new_block: BlockResource = BlockResource.new()
				new_block.id = global_block_id
				new_block.actions.append(resource)
				event_sheet_data.append(new_block)
			else:
				current_block.actions.append(resource)

	global_block_id += 1
	current_block = null
	update_event_sheet()

func update_event_sheet():
	for event in event_items.get_children():
		event_items.remove_child(event)
		event.queue_free()
	for action in action_items.get_children():
		action_items.remove_child(action)
		action.queue_free()
	
	for block in event_sheet_data:
		process_block(block)

var block_level = 0
func process_block(block: BlockResource, index: int = 0, parent_container_event: VBoxContainer = null, parent_container_action: VBoxContainer = null):
	var events: Array[EventResource] = block.events
	var actions: Array[ActionResource] = block.actions
	var sub_blocks: Array[BlockResource] = block.sub_blocks
	
	# Загружаем blank_body для событий и действий
	var blank_body_event: VBoxContainer = load("res://addons/event_sheet/elements/blank_body/blank_body_event.tscn").instantiate()
	var blank_body_action: VBoxContainer = load("res://addons/event_sheet/elements/blank_body/blank_body_action.tscn").instantiate()
	
	blank_body_event.block = block
	blank_body_event.blank_body_action = blank_body_action
	blank_body_action.blank_body_event = blank_body_event

	# Если передан родительский контейнер, добавляем туда; если нет — в корневой event_items/action_items
	if parent_container_event != null:
		blank_body_event.sub_block_index = index + 1
		parent_container_event.add_child(blank_body_event)
	else:
		event_items.add_child(blank_body_event)

	if parent_container_action != null:
		parent_container_action.add_child(blank_body_action)
	else:
		action_items.add_child(blank_body_action)

	# Подключаем сигналы
	blank_body_event.dragged_block.connect(_drop_data_block)
	blank_body_action.add_action_button_up.connect(_on_add_action_button_up.bind(block))
	
	# Добавляем элементы событий
	for event: EventResource in events:
		var event_item: Button = load("res://addons/event_sheet/elements/conditions/event.tscn").instantiate()
		event_item.resource = event
		blank_body_event.event_items.add_child(event_item)
		blank_body_event.event_items.move_child(event_item, blank_body_event.event_items.get_child_count() - 1)
		
	# Добавляем элементы действий
	for action: ActionResource in actions:
		var action_item: Button = load("res://addons/event_sheet/elements/conditions/action.tscn").instantiate()
		action_item.resource = action
		blank_body_action.action_items.add_child(action_item)
		blank_body_action.action_items.move_child(action_item, blank_body_action.action_items.get_child_count() - 2)

	# Рекурсивная обработка подблоков
	if sub_blocks.size() > 0:
		block_level += 1
		for sub_block in sub_blocks:
			# Для каждого подблока вызываем процесс с текущими blank_body в качестве родительских контейнеров
			process_block(sub_block, index + 1, blank_body_event, blank_body_action)

# Event Sheet Inputs
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Event Sheet - Double Click
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			_window.add_condition(current_scene, Types.ConditionType.EVENTS)
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
			0: _window.add_condition(current_scene, Types.ConditionType.EVENTS)
			1: pass # add_blank_body()

func _on_add_action_button_up(block):
	current_block = block
	_window.add_condition(current_scene, Types.ConditionType.ACTIONS)

func _on_finish_data(data: Dictionary):
	add_data_to_block(data)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var result: Dictionary = ESUtils.find_block_and_parent(data.block.id, event_sheet_data)
	var block: BlockResource = result["block"]
	var parent: BlockResource = result["parent"]
	if !parent:
		for _block in event_sheet_data:
			if block.id == _block.id:
				event_sheet_data.erase(_block)
				event_sheet_data.append(block)
	else:
		for _block in parent.sub_blocks:
			if block.id == _block.id:
				parent.sub_blocks.erase(_block)
				event_sheet_data.append(block)
	update_event_sheet()

func _drop_data_block(from_object: Variant, to_object: Variant) -> void:
	var result: Dictionary = ESUtils.find_block_and_parent(from_object.block.id, event_sheet_data)
	var block: BlockResource = result["block"]
	var parent: BlockResource = result["parent"]
	
	# Проверка: блок не должен быть потомком или самим собой
	if ESUtils.is_descendant_of(to_object.block, block):
		print("Нельзя перемещать блок в свои подблоки или под самого себя.")
		return
	
	if !parent:
		for _block in event_sheet_data:
			if block.id == _block.id:
				event_sheet_data.erase(_block)
				to_object.block.sub_blocks.append(block)
	if parent:
		for _block in parent.sub_blocks:
			if block.id == _block.id:
				parent.sub_blocks.erase(_block)
				to_object.block.sub_blocks.append(block)
	update_event_sheet()
