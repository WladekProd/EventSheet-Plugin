@tool
extends TextureRect

@onready var blank_body_event: VBoxContainer = $"../../../../../.."

func _get_drag_data(at_position: Vector2) -> VBoxContainer:
	ESUtils.is_dragging = true
	ESUtils.dragging_data = blank_body_event
	return blank_body_event

func _notification(what:int)->void:
	if what == Node.NOTIFICATION_DRAG_END:
		# if get_viewport().gui_is_drag_successful():
		ESUtils.is_dragging = false
		ESUtils.dragging_data = null
