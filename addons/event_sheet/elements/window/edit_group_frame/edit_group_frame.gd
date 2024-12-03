@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var parameter_items: VBoxContainer = $MarginContainer/ScrollContainer/Parameters

var current_data: Dictionary
var current_frame

signal frame_result

func _ready() -> void:
	parameter_items.fix_items_size()

func update_frame(current_scene, condition_type: String, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}, window_search: LineEdit = null):
	current_frame = frame
	
	current_data = frame_data[Types.WindowFrame.EDIT_GROUP].parameters if frame_data[Types.WindowFrame.EDIT_GROUP] else {}
	
	if current_data.is_empty():
		current_data = {
			"group_name": "",
			"group_description": ""
		}
	
	if finish_button_instance:
		for item in finish_button_instance.button_up.get_connections():
			finish_button_instance.button_up.disconnect(item.callable)
		finish_button_instance.button_up.connect(_on_submit.bind(current_data, current_frame))
	
	for item in parameter_items.get_children():
		var line_edit: LineEdit = item.get_child(1)
		if item.name == "group_name":
			line_edit.text = current_data.group_name
		if item.name == "group_description":
			line_edit.text = current_data.group_description
		if line_edit.text_changed.is_connected(_on_parameter_edited):
			line_edit.text_changed.disconnect(_on_parameter_edited)
		line_edit.text_changed.connect(_on_parameter_edited)

func _input(event: InputEvent) -> void:
	if visible and ESUtils.is_plugin_screen:
		if event is InputEventKey:
			if event.keycode == KEY_ENTER and event.pressed:
				frame_result.emit(current_data, current_frame, true)

func _on_parameter_edited(new_text: String):
	for child in parameter_items.get_children():
		var parameter_name: String = child.name
		var parameter_value: LineEdit = child.get_child(1)
		if current_data:
			current_data[parameter_name] = parameter_value.text

func _on_submit(data, frame: Types.WindowFrame):
	frame_result.emit(data, frame, true, false)
