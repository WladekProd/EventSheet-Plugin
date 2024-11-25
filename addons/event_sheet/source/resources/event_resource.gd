@tool
extends Resource
class_name EventResource

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@export var id: String = ""

@export var name: String
@export var icon: Texture2D
@export var icon_path: String
@export var description: String
@export var type: Types.EventType = Types.EventType.STANDART
@export var group: Types.Group = Types.Group.SYSTEM
@export var category: Types.Category = Types.Category.MAIN

@export var gd_script: GDScript:
	set(p_gd_script):
		gd_script = p_gd_script
		update_params()

@export var parameters: Dictionary = {}
@export var pick_object: Dictionary = {}

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

func get_class() -> String:
	return "EventResource"
