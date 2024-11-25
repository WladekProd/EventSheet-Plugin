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

var resource: BlockResource:
	set (p_resource):
		resource = p_resource
		group_name.text = empty_block.block_resource.group_name
		group_description.text = empty_block.block_resource.group_description

var empty_block

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
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				empty_block.change_block.emit(empty_block.block_resource, self)
			else:
				empty_block.is_selected = true
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			empty_block.context_menu.emit()

#func _on_focus_entered() -> void:
	#left_body.panel.focus_entered.emit()
#
#func _on_focus_exited() -> void:
	#left_body.panel.focus_exited.emit()
