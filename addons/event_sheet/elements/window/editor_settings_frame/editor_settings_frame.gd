@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")
const Plugin = preload("res://addons/event_sheet/plugin.gd")

@onready var parameter_items: VBoxContainer = $MarginContainer/ScrollContainer/Parameters
@onready var code_editor_enable: HBoxContainer = $MarginContainer/ScrollContainer/Parameters/code_editor_enable
@onready var animations_enable: HBoxContainer = $MarginContainer/ScrollContainer/Parameters/animations_enable
@onready var animations_speed: HBoxContainer = $MarginContainer/ScrollContainer/Parameters/animations_speed

var finish_button_instance: Button
var settings_path = Plugin.PLUGIN_SETTINGS_PATH
var settings = EditorInterface.get_editor_settings()

signal frame_result

func _ready() -> void:
	parameter_items.fix_items_size()
	
	if finish_button_instance:
		for item in finish_button_instance.button_up.get_connections():
			finish_button_instance.button_up.disconnect(item.callable)
		finish_button_instance.button_up.connect(_on_submit)
	
	if !settings.has_setting(settings_path + "/code_editor_enable"):
		settings.set_setting(settings_path + "/code_editor_enable", true)
	code_editor_enable_change(settings.get_setting(settings_path + "/code_editor_enable"))
	
	if !settings.has_setting(settings_path + "/animations_enable"):
		settings.set_setting(settings_path + "/animations_enable", true)
	animations_enable_change(settings.get_setting(settings_path + "/animations_enable"))
	
	if !settings.has_setting(settings_path + "/animations_speed"):
		settings.set_setting(settings_path + "/animations_speed", 1.0)
	animations_speed_value_change(settings.get_setting(settings_path + "/animations_speed"))

func _on_code_editor_enable_toggled(toggled_on: bool) -> void:
	code_editor_enable_change(toggled_on)
func code_editor_enable_change(toggled_on: bool):
	var label_name: Label = code_editor_enable.get_child(0)
	var label_value: Label = code_editor_enable.get_child(1)
	var controller: CheckButton = code_editor_enable.get_child(2)
	controller.button_pressed = toggled_on
	label_value.text = "({0})".format([str(toggled_on if toggled_on else false)])
	settings.set_setting(settings_path + "/code_editor_enable", toggled_on)

func _on_animations_enable_toggled(toggled_on: bool) -> void:
	animations_enable_change(toggled_on)
func animations_enable_change(toggled_on: bool):
	var label_name: Label = animations_enable.get_child(0)
	var label_value: Label = animations_enable.get_child(1)
	var controller: CheckButton = animations_enable.get_child(2)
	controller.button_pressed = toggled_on
	label_value.text = "({0})".format([str(toggled_on if toggled_on else false)])
	settings.set_setting(settings_path + "/animations_enable", toggled_on)

func _on_animations_speed_value_changed(value: float) -> void:
	animations_speed_value_change(value)
func animations_speed_value_change(value: float):
	var label_name: Label = animations_speed.get_child(0)
	var label_value: Label = animations_speed.get_child(1)
	var controller: HSlider = animations_speed.get_child(2)
	controller.value = value
	label_value.text = "({0}s)".format([str(snapped(value, 0.1) if value > 0 else "0.0")])
	settings.set_setting(settings_path + "/animations_speed", snapped(value, 0.1))



func _on_submit() -> void:
	frame_result.emit()
