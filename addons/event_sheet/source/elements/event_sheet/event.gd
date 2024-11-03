@tool
extends Button

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _category_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _event_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event

signal select_content
signal change_content
signal context_menu

var parent_block: BlockResource
var resource: EventResource:
	set (p_resource):
		resource = p_resource
		_icon.texture = resource.icon
		_icon.modulate = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
		_category_name.text = Types.CATEGORY_NAMES[resource.category]
		var _info_string: String = resource.gd_script.get_info(resource.parameters)
		_event_string.text = _info_string

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			focus_mode = FOCUS_NONE if !is_hovered() else FOCUS_CLICK

func _ready() -> void:
	pass

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				change_content.emit(resource, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.emit()

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if _icon and _icon.modulate != accent_color:
		_icon.modulate = accent_color

func _on_focus_entered() -> void:
	select_content.emit({ "parent_block": parent_block, "resource": resource, "resource_button": self })

func _on_focus_exited() -> void:
	select_content.emit({})
