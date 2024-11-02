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

signal change_group
signal context_menu

var resource: BlockResource:
	set (p_resource):
		resource = p_resource
		group_name.text = resource.group_name
		group_description.text = resource.group_description

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			change_group.emit(resource, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.emit()
