@tool
extends Resource
class_name BlockResource

const Types = preload("res://addons/event_sheet/source/types.gd")

var id: int = 0
var sub_blocks: Array[BlockResource]

@export var level: int = 0
@export var sub_blocks_state: Types.SubBlocksState = Types.SubBlocksState.NONE
@export var block_type: Types.BlockType = Types.BlockType.STANDART:
	set (p_block_type):
		block_type = p_block_type
		notify_property_list_changed()

# Variables: EVENT
var events: Array[EventResource]
var actions: Array[ActionResource]

# Variables: VARIABLE
var variable: VariableResource

# Variables: GROUP
var group_name: String = "Group"
var group_description: String = "Description"

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
			"name": "variable",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "VariableResource",
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
