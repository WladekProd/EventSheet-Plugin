@tool
extends VBoxContainer

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

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color
