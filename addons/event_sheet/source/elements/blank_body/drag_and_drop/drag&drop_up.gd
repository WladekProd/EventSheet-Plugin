@tool
extends Panel

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var blank_body_event: VBoxContainer = $"../../../../.."

@onready var drop_bg: Panel = $"../../DropBackground"

func _ready() -> void:
	modulate = Color.TRANSPARENT
	mouse_filter = MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if ESUtils.is_dragging:
		if ESUtils.dragging_data and blank_body_event != ESUtils.dragging_data:
			mouse_filter = MOUSE_FILTER_STOP
	else:
		if mouse_filter == MOUSE_FILTER_STOP:
			mouse_filter = MOUSE_FILTER_IGNORE
			modulate = Color.TRANSPARENT
			drop_bg.visible = false

func _on_mouse_entered() -> void:
	if ESUtils.is_dragging:
		if ESUtils.dragging_data and blank_body_event != ESUtils.dragging_data:
			modulate = Color.WHITE
			drop_bg.visible = true

func _on_mouse_exited() -> void:
	if ESUtils.dragging_data and blank_body_event != ESUtils.dragging_data and ESUtils.is_dragging:
		modulate = Color.TRANSPARENT
		drop_bg.visible = false

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if ESUtils.dragging_data and blank_body_event != ESUtils.dragging_data:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	blank_body_event.dragged_block.emit(data, self.blank_body_event, Types.MoveBlock.UP)
