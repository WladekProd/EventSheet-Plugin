@tool
extends VBoxContainer

@export var blank_body_event: VBoxContainer

@onready var action_items: VBoxContainer = $MarginContainer/Action/VBoxContainer

func _ready() -> void:
	pass



func update_y_size(y_size: float):
	if action_items:
		action_items.size.y = y_size
		action_items.custom_minimum_size.y = y_size

func _on_items_child_entered_tree(node: Node) -> void:
	if blank_body_event and action_items:
		blank_body_event.update_y_size(action_items.size.y)

func _on_items_child_exiting_tree(node: Node) -> void:
	if blank_body_event and action_items:
		blank_body_event.update_y_size(action_items.size.y)
