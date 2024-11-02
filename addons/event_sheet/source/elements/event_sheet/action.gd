@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _action_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Action

signal change_content
signal context_menu

var resource: ActionResource:
	set (p_resource):
		resource = p_resource
		_icon.texture = resource.action_icon
		_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
		_category_name.text = Types.CATEGORY_NAMES[resource.action_category]
		var _info_string: String = resource.action_script.get_info(resource.action_params)
		_action_string.text = _info_string

func _ready() -> void:
	pass

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			change_content.emit(resource, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.emit()

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if _icon and _icon.modulate != accent_color:
		_icon.modulate = accent_color
