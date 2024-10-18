extends Resource
class_name ActionResource

const Types = preload("res://addons/event_sheet/source/Types.gd")

@export var action_name: String
@export var action_group: Types.Group = Types.Group.SYSTEM
@export var action_category: Types.Category = Types.Category.MAIN
@export var action_script: GDScript
@export var action_params: Array[String]
