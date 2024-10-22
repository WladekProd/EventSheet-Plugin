@tool
extends VBoxContainer

@export var blank_body_action: VBoxContainer

@onready var margin_container: MarginContainer = $MarginContainer
@onready var show_hide_button: Button = $MarginContainer/Event/HBoxContainer/ShowHide
@onready var selected_panel: Panel = $MarginContainer/Selected
@onready var event_items: VBoxContainer = $MarginContainer/Event/HBoxContainer/VBoxContainer

var block: BlockResource
var is_mouse_entered: bool = false
var is_selected: bool = false

signal dragged_block

const standart_margin: int = 15
@export var sub_block_index: int = 1:
	set (p_sub_block_index):
		if p_sub_block_index != sub_block_index:
			sub_block_index = p_sub_block_index
			fix_margin_container()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_selected = is_mouse_entered
			selected_panel.visible = is_selected

func _ready() -> void:
	fix_margin_container()

func fix_margin_container():
	if sub_block_index > 0 and margin_container:
		margin_container.add_theme_constant_override("margin_left", standart_margin * sub_block_index)
	if get_child_count() > 1 and get_child(1):
		var child: VBoxContainer = get_child(1)
	if show_hide_button:
		show_hide_button.disabled = !(get_child_count() > 1)
		if !show_hide_button.disabled: show_hide_button.icon = load("res://addons/event_sheet/resources/icons/hide.svg")
		else: show_hide_button.icon = null

func _on_show_hide_toggled(toggled_on: bool) -> void:
	if get_child_count() > 1 and get_child(1):
		var child: VBoxContainer = get_child(1)
		child.visible = !toggled_on
		if toggled_on: show_hide_button.icon = load("res://addons/event_sheet/resources/icons/show.svg")
		else: show_hide_button.icon = load("res://addons/event_sheet/resources/icons/hide.svg")


func update_y_size():
	if event_items and blank_body_action:
		var y_size = blank_body_action.action_items.size.y
		event_items.custom_minimum_size.y = y_size
		event_items.size.y = y_size

func _on_v_box_container_resized() -> void:
	update_y_size()

func _on_panel_mouse_entered() -> void:
	is_mouse_entered = true

func _on_panel_mouse_exited() -> void:
	is_mouse_entered = false

func _get_drag_data(at_position: Vector2) -> VBoxContainer:
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	dragged_block.emit(data, self)
