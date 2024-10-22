extends Resource
class_name EventResource

const Types = preload("res://addons/event_sheet/source/Types.gd")

@export var event_name: String
@export var event_icon: Texture2D
@export var event_description: String
@export var event_type: Types.BlockType = Types.BlockType.EVENT
@export var event_group: Types.Group = Types.Group.SYSTEM
@export var event_category: Types.Category = Types.Category.MAIN
@export var event_script: GDScript
@export var event_params: Array[String]
