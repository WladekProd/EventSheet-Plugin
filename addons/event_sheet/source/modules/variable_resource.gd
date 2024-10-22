extends Resource
class_name VariableResource

const Types = preload("res://addons/event_sheet/source/types.gd")

@export var variable_icon: Texture2D
@export var variable_type: Types.VariableType = Types.VariableType.NUMBER
@export var variable_is_global: bool = true
@export var variable_name: String
@export var variable_value: String

func get_template() -> String:
	var type: String = ""
	match variable_type:
		Types.VariableType.NUMBER: type = "float"
		Types.VariableType.STRING: type = "String"
		Types.VariableType.BOOLEAN: type = "bool"
	return """var {0}: {1} = {2}""".format([variable_name, type, variable_value])
