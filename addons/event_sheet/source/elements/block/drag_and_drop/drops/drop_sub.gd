@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var drag_and_drop: Control = $"../../.."

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	for selected_item in ESUtils.selected_items:
		if selected_item.object == drag_and_drop.drop_object or "is_selected" in drag_and_drop.drop_object and drag_and_drop.drop_object.is_selected:
			return false
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	drag_and_drop.drop_object.drop_data.emit(data, drag_and_drop.drop_object, Types.MoveBlock.SUB)
