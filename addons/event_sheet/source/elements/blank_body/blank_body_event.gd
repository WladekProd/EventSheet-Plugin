@tool
extends VBoxContainer

@export var blank_body_action: VBoxContainer

@onready var margin_container: MarginContainer = $MarginContainer
@onready var show_hide_button: Button = $MarginContainer/Event/HBoxContainer/ShowHide
@onready var event_items: VBoxContainer = $MarginContainer/Event/HBoxContainer/VBoxContainer

const standart_margin: int = 15
@export var sub_block_index: int = 1:
	set (p_sub_block_index):
		if p_sub_block_index != sub_block_index:
			sub_block_index = p_sub_block_index
			fix_margin_container()

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



func update_y_size(y_size: float):
	if event_items:
		event_items.size.y = y_size
		event_items.custom_minimum_size.y = y_size

func _on_items_child_entered_tree(node: Node) -> void:
	if blank_body_action and event_items:
		blank_body_action.update_y_size(event_items.size.y)

func _on_items_child_exiting_tree(node: Node) -> void:
	if blank_body_action and event_items:
		blank_body_action.update_y_size(event_items.size.y)
