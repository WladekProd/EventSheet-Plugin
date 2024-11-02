@tool
extends Resource
class_name ActionResource

const Types = preload("res://addons/event_sheet/source/types.gd")

var id: int = 0

@export var name: String
@export var icon: Texture2D
@export var description: String
@export var group: Types.Group = Types.Group.SYSTEM
@export var category: Types.Category = Types.Category.MAIN

@export var gd_script: GDScript:
	set(p_gd_script):
		gd_script = p_gd_script
		update_params()

@export var parameters: Dictionary = {}
@export var conditions: Dictionary = {}

func update_params():
	if gd_script == null:
		parameters = {}
	if gd_script and gd_script.has_method("params"):
		var params: Dictionary = gd_script.params()
		if params.size() > 0: parameters = params
		else: parameters = {}

func get_template() -> String:
	if gd_script and gd_script.has_method("get_template"):
		return gd_script.get_template(parameters)
	return ""
