@tool
extends Control

@export var block: VBoxContainer

func _get_drag_data(at_position: Vector2) -> VBoxContainer:
	ESUtils.is_dragging = true
	ESUtils.dragging_data = {
		"object": block,
		"class": "Block"
	}
	return block
