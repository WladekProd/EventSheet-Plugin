@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/Types.gd")
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



# Add New Blank Body
func add_blank_body() -> Dictionary:
	var blank_body_event_instance: VBoxContainer = load("res://addons/event_sheet/elements/Blank Body/blank_body_event.tscn").instantiate()
	var blank_body_action_instance: VBoxContainer = load("res://addons/event_sheet/elements/Blank Body/blank_body_action.tscn").instantiate()
	
	blank_body_event_instance.blank_body_action = blank_body_action_instance
	blank_body_action_instance.blank_body_event = blank_body_event_instance
	
	event_items.add_child(blank_body_event_instance)
	blank_body_event_instance.owner = event_items.get_owner()
	
	action_items.add_child(blank_body_action_instance)
	blank_body_action_instance.owner = action_items.get_owner()
	
	return { "event": blank_body_event_instance, "action": blank_body_action_instance}

# Add New Data Body
func add_data_body(data: Dictionary):
	print(data)
	var blank_body: Dictionary = add_blank_body()
	var parameters: Dictionary = data.parameters
	var condition_type: Types.ConditionType = data.condition
	
	match condition_type:
		Types.ConditionType.EVENTS:
			var resource: EventResource = data.resource
			var event_instance: Button = load("res://addons/event_sheet/elements/Event/event.tscn").instantiate()
			
			event_instance._icon.texture = resource.event_icon
			event_instance._category_name.text = str(resource.event_category)
			event_instance._event_string.text = resource.event_name
			
			blank_body["event"].event_items.add_child(event_instance)
		Types.ConditionType.ACTIONS:
			var resource: ActionResource = data.resource
			var action_instance: Button = load("res://addons/event_sheet/elements/Action/action.tscn").instantiate()
			
			action_instance._icon.texture = resource.action_icon
			action_instance._category_name.text = str(resource.action_category)
			action_instance._action_string.text = resource.action_name
			
			blank_body["action"].action_items.add_child(action_instance)

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
			1: add_blank_body()

func _on_finish_data(data: Dictionary):
	add_data_body(data)
