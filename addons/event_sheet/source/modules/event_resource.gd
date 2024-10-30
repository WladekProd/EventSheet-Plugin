@tool
extends Resource
class_name EventResource

const Types = preload("res://addons/event_sheet/source/types.gd")

var id: int = 0

@export var event_name: String
@export var event_icon: Texture2D
@export var event_description: String
@export var event_type: Types.EventType = Types.EventType.STANDART
@export var event_group: Types.Group = Types.Group.SYSTEM
@export var event_category: Types.Category = Types.Category.MAIN

@export var event_script: GDScript:
	set(p_event_script):
		event_script = p_event_script
		update_params()

@export var event_params: Dictionary = {}

func update_params():
	if event_script == null:
		event_params = {}
	if event_script and event_script.has_method("params"):
		var params: Dictionary = event_script.params()
		if params.size() > 0: event_params = params
		else: event_params = {}

func get_template() -> String:
	if event_script and event_script.has_method("get_template"):
		return event_script.get_template(event_params)
	return ""
