@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var group_icon: TextureRect = $GroupButton/MarginContainer/HBoxContainer/Icon
@onready var group_name: Label = $GroupButton/MarginContainer/HBoxContainer/VBoxContainer/Name
@onready var group_description: Label = $GroupButton/MarginContainer/HBoxContainer/VBoxContainer/Description

@onready var group_button: Button = $GroupButton

@export var color: Color:
	set (p_color):
		if p_color != color:
			color = p_color
			if group_icon:
				group_icon.modulate = color

var block_body

var data: Dictionary:
	set (p_data):
		data = p_data
		group_name.text = block_body.data.parameters.group_name
		group_description.text = block_body.data.parameters.group_description

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if group_button.is_hovered():
				EditorInterface.get_selection().clear()
				group_button.grab_focus()

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.double_click:
				block_body.change.emit(block_body.data, block_body)
			else:
				block_body._select()
				block_body.is_hovered = false
				ESUtils.hovered_select = null
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			block_body.context_menu.emit()
