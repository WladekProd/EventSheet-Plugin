@tool
extends Resource
class_name BlockResource

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@export var id: String = ""
var sub_blocks: Array[BlockResource]

@export var level: int = 0
@export var block_expand: Types.SubBlocksState = Types.SubBlocksState.NONE
@export var block_type: Types.BlockType = Types.BlockType.STANDART:
	set (p_block_type):
		block_type = p_block_type
		notify_property_list_changed()

# Variables: EVENT
var events: Array[EventResource]
var actions: Array[ActionResource]

# Variables: VARIABLE
var variable_type: Types.VariableType = Types.VariableType.NUMBER
var variable_is_global: bool = true
var variable_name: String
var variable_value: String

# Variables: GROUP
var group_name: String = "Group"
var group_description: String = "Description"

# Variables: COMMENT
var comment_text: String = "// "

# Метод для динамического управления видимостью свойств
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	# Для STANDART блока показываем события и действия
	if block_type == Types.BlockType.STANDART:
		properties.append({
			"name": "events",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "EventResource",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "actions",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "ActionResource",
			"usage": PROPERTY_USAGE_DEFAULT
		})

	# Для VARIABLE блока показываем переменную
	elif block_type == Types.BlockType.VARIABLE:
		properties.append({
			"name": "variable_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(Types.VariableType.keys()),
			"usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "variable_is_global",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "variable_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "variable_value",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	# Для GROUP блока показываем имя группы и подблоки
	elif block_type == Types.BlockType.GROUP:
		properties.append({
			"name": "group_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "group_description",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	# Для COMMENT блока показываем текст коммента
	elif block_type == Types.BlockType.COMMENT:
		properties.append({
			"name": "comment_text",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	# Для STANDART и GROUP показываем подблоки
	if block_type == Types.BlockType.STANDART or block_type == Types.BlockType.GROUP:
		properties.append({
			"name": "sub_blocks",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "BlockResource",
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return properties

func get_class() -> String:
	return "BlockResource"
