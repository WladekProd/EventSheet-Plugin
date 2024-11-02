extends Node

enum VariableType {
	NUMBER,
	STRING,
	BOOLEAN,
}

enum EventType {
	STANDART,
	SINGLE_EVENT,
	FUNCTION,
	CYCLE,
}

enum BlockType {
	STANDART,
	VARIABLE,
	GROUP,
}
enum SubBlocksState {
	NONE,
	VISIBLE,
	HIDDEN,
}

enum ConditionType {
	EVENTS,
	ACTIONS,
}

enum Group {
	NONE,
	SYSTEM,
}
const GROUP_NAMES = {
	Group.NONE: "None",
	Group.SYSTEM: "System",
}

enum Category {
	MAIN,
	VARIABLE,
	INPUT,
}
const CATEGORY_NAMES = {
	Category.MAIN: "Main",
	Category.VARIABLE: "Variable",
	Category.INPUT: "Input"
}

enum MoveBlock {
	UP,
	SUB,
	DOWN,
}

# Parameter Types
enum STANDART_TYPES {
	STRING,
	NUMBER,
	OPEN_FILE,
	SELECT_NODE,
}

enum STIPULATION {
	EQUALS,
	UNEVEN,
	MORE,
	LESS,
}
const STIPULATION_SYMBOL = {
	STIPULATION.EQUALS: "==",
	STIPULATION.UNEVEN: "!=",
	STIPULATION.MORE: ">",
	STIPULATION.LESS: "<"
}

enum WindowFrame {
	PICK_OBJECT,
	PICK_CONDITION,
	CHANGE_PARAMETERS,
	EDIT_GROUP,
	EDIT_FUNCTION,
	EDIT_VARIABLE,
}

class EventSheet:
	@export var data: Dictionary = {}

	func _init():
		data = {}

class Event:
	@export var event: EventResource

class Action:
	@export var action: ActionResource
