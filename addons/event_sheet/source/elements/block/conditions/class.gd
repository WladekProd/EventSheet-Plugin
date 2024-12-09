@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var class_icon: TextureRect = $ClassButton/MarginContainer/HBoxContainer/Icon
@onready var class_text: Label = $ClassButton/MarginContainer/HBoxContainer/Variable

@onready var variable_button: Button = $ClassButton

@export var color: Color:
	set (p_color):
		if p_color != color:
			color = p_color
			if class_icon:
				class_icon.modulate = color
			if class_text:
				class_text.label_settings.font_color = color

var block_body

var data: Dictionary:
	set (p_data):
		data = p_data
		class_text.text = "Include class: {0}".format([
			Types.ClassType[str_to_var(block_body.data.parameters.class_value)]
		])

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			block_body.change.emit(block_body.data, block_body)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			block_body.context_menu.emit()
