@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _action_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Action

var resource: ActionResource:
	set (p_resource):
		if p_resource != resource:
			resource = p_resource
			_icon.texture = resource.action_icon
			_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
			_category_name.text = Types.CATEGORY_NAMES[resource.action_category]
			var _info_string: String = resource.action_script.get_info(resource.action_params)
			_action_string.text = _info_string

func _ready() -> void:
	pass

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if _icon and _icon.modulate != accent_color:
		_icon.modulate = accent_color
