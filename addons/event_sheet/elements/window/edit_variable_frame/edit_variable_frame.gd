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
	
	current_data = frame_data[Types.WindowFrame.EDIT_VARIABLE].parameters if frame_data[Types.WindowFrame.EDIT_VARIABLE] else {}
	if !current_data:
		current_data = {
			"variable_is_global": true,
			"variable_name": "",
			"variable_type": "Number",
			"variable_value": "",
		}
	
	if finish_button_instance:
		for item in finish_button_instance.button_up.get_connections():
			finish_button_instance.button_up.disconnect(item.callable)
		finish_button_instance.button_up.connect(_on_submit.bind(current_data, current_frame))
	
	for item in parameter_items.get_children():
		if item.name == "variable_name":
			var line_edit: LineEdit = item.get_child(1)
			line_edit.text = current_data["variable_name"]
			
			if line_edit.text_changed.is_connected(_on_parameter_edited):
				line_edit.text_changed.disconnect(_on_parameter_edited)
			line_edit.text_changed.connect(_on_parameter_edited)
		if item.name == "variable_type":
			var line_edit: OptionButton = item.get_child(1)
			
			for key in Types.VariableType.keys():
				line_edit.add_item(key, Types.VariableType[key])
			
			if line_edit.item_selected.is_connected(_on_item_selected):
				line_edit.item_selected.disconnect(_on_item_selected)
			line_edit.item_selected.connect(_on_item_selected)
		if item.name == "variable_value":
			var line_edit: LineEdit = item.get_child(1)
			line_edit.text = current_data["variable_value"]
		
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
		var parameter_value = child.get_child(1)
		
		if current_data:
			if parameter_value is LineEdit: current_data[parameter_name] = parameter_value.text
			if parameter_value is OptionButton: current_data[parameter_name] = parameter_value.get_selected_id()

func _on_item_selected(index: int):
	_on_parameter_edited("")

func _on_submit(data, frame: Types.WindowFrame):
	frame_result.emit(data, frame, true, false)
