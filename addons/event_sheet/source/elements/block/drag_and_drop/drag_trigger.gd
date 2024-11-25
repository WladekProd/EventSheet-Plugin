@tool
extends Control

#@onready var panel: PanelContainer = $"../../../../.."
@export var block: VBoxContainer

func _get_drag_data(at_position: Vector2) -> VBoxContainer:
	ESUtils.is_dragging = true
	ESUtils.dragging_data = {
		"object": block,
		"class": "Block"
	}
	return block

#func _on_gui_input(event: InputEvent) -> void:
	#panel.gui_input.emit(event)
