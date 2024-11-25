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

var resource: BlockResource:
	set (p_resource):
		resource = p_resource
		variable_icon.texture = global_icon if empty_block.block_resource.variable_is_global else local_icon
		variable_text.text = "{0} {1}: {2} = {3}".format([
			"Global" if empty_block.block_resource.variable_is_global else "Local",
			Types.VariableType.find_key(empty_block.block_resource.variable_type),
			empty_block.block_resource.variable_name,
			empty_block.block_resource.variable_value
		])

var empty_block

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			empty_block.change_content.emit(empty_block.block_resource, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			empty_block.context_menu.emit()

#func _on_focus_entered() -> void:
	#left_body.panel.focus_entered.emit()
#
#func _on_focus_exited() -> void:
	#left_body.panel.focus_exited.emit()
