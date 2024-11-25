@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@export var drop_object: Node
@export var drop_class: String = ""

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if "_drag_and_drop" in data and data._drag_and_drop.drop_class == drop_class:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.drop_data.emit(data, drop_object, Types.MoveBlock.CONTENT)
