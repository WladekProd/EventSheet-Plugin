@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _event_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event

var resource: EventResource:
	set (p_resource):
		if p_resource != resource:
			resource = p_resource
			_icon.texture = resource.event_icon
			_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
			_category_name.text = Types.CATEGORY_NAMES[resource.event_category]
			var _info_string: String = resource.event_script.get_info(resource.event_params)
			_event_string.text = _info_string

func _ready() -> void:
	pass

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if _icon and _icon.modulate != accent_color:
		_icon.modulate = accent_color
