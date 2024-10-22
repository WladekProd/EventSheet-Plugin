@tool
extends VBoxContainer

@export var blank_body_event: VBoxContainer

@onready var action_items: VBoxContainer = $MarginContainer/Action/VBoxContainer

signal add_action_button_up

func _ready() -> void:
	pass


func update_y_size():
	if action_items and blank_body_event:
		var y_size = blank_body_event.event_items.size.y
		action_items.custom_minimum_size.y = y_size
		action_items.size.y = y_size

func _on_v_box_container_resized() -> void:
	update_y_size()

func _on_add_action_button_up() -> void:
	add_action_button_up.emit()
