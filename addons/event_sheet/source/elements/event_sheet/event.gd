@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _event_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event

var resource: EventResource

func _ready() -> void:
	_icon.texture = resource.event_icon
	_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	_category_name.text = Types.CATEGORY_NAMES[resource.event_category]
	_event_string.text = resource.event_name
