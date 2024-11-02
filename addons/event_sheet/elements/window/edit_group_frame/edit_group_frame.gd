@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var parameter_items: VBoxContainer = $MarginContainer/ScrollContainer/Parameters

var finish_button_up: Button
var frame_data: Dictionary
signal finished

func _ready() -> void:
	parameter_items.fix_items_size()

func update_frame():
	if frame_data.is_empty():
		frame_data = {
			"type": Types.BlockType.GROUP,
			"resource": null,
			"data": {
				"group_name": "",
				"group_description": ""
			}
		}
	else: frame_data = frame_data
	
	if finish_button_up:
		for item in finish_button_up.button_up.get_connections():
			finish_button_up.button_up.disconnect(item.callable)
		finish_button_up.button_up.connect(_on_finished_button_up)
	
	for item in parameter_items.get_children():
		var line_edit: LineEdit = item.get_child(1)
		if item.name == "group_name":
			line_edit.text = frame_data.data["group_name"]
		if item.name == "group_description":
			line_edit.text = frame_data.data["group_description"]
		if line_edit.text_changed.is_connected(_on_parameter_edited):
			line_edit.text_changed.disconnect(_on_parameter_edited)
		line_edit.text_changed.connect(_on_parameter_edited)

func _on_parameter_edited(new_text: String):
	for child in parameter_items.get_children():
		var parameter_name: String = child.name
		var parameter_value: LineEdit = child.get_child(1)
		frame_data.data[parameter_name] = parameter_value.text
		if frame_data.resource:
			frame_data.resource[parameter_name] = parameter_value.text

func _on_finished_button_up():
	finished.emit(frame_data)
