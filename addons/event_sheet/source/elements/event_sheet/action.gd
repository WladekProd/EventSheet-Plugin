@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _action_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Action

var resource: ActionResource

func _ready() -> void:
	_icon.texture = resource.action_icon
	_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	_category_name.text = Types.CATEGORY_NAMES[resource.action_category]
	_action_string.text = resource.action_name
