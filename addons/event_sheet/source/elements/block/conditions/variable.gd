@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

var global_icon := load("res://addons/event_sheet/resources/icons/global.svg")
var local_icon := load("res://addons/event_sheet/resources/icons/local.svg")

@onready var variable_icon: TextureRect = $VariableButton/MarginContainer/HBoxContainer/Icon
@onready var variable_text: Label = $VariableButton/MarginContainer/HBoxContainer/Variable

@onready var variable_button: Button = $VariableButton

@export var color: Color:
	set (p_color):
		if p_color != color:
			color = p_color
			if variable_icon:
				variable_icon.modulate = color
			if variable_text:
				variable_text.label_settings.font_color = color

var block_body

var data: Dictionary:
	set (p_data):
		data = p_data
		variable_icon.texture = global_icon if block_body.data.parameters.variable_is_global else local_icon
		variable_text.text = "{0} {1}: {2} = {3}".format([
			"Global" if block_body.data.parameters.variable_is_global else "Local",
			Types.VariableType[str_to_var(block_body.data.parameters.variable_type)],
			block_body.data.parameters.variable_name,
			block_body.data.parameters.variable_value
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
