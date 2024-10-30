@tool
extends Resource
class_name ActionResource

const Types = preload("res://addons/event_sheet/source/types.gd")

var id: int = 0

@export var action_name: String
@export var action_icon: Texture2D
@export var action_description: String
@export var action_group: Types.Group = Types.Group.SYSTEM
@export var action_category: Types.Category = Types.Category.MAIN

@export var action_script: GDScript:
	set(p_action_script):
		action_script = p_action_script
		update_params()

@export var action_params: Dictionary

func update_params():
	if action_script == null:
		action_params = {}
	if action_script and action_script.has_method("params"):
		var params: Dictionary = action_script.params()
		if params.size() > 0: action_params = params
		else: action_params = {}

func get_template() -> String:
	if action_script and action_script.has_method("get_template"):
		return action_script.get_template(action_params)
	return ""
