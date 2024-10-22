extends Node

enum VariableType {
	NUMBER,
	STRING,
	BOOLEAN,
}

enum BlockType {
	EVENT,
	SINGLE_EVENT,
	FUNCTION,
	CYCLE,
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

class EventSheet:
	@export var data: Dictionary = {}

	func _init():
		data = {}

class Event:
	@export var event: EventResource

class Action:
	@export var action: ActionResource
