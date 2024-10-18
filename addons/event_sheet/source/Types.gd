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

enum Group {
	NONE,
	SYSTEM,
}

enum Category {
	MAIN,
	VARIABLE,
	INPUT,
}

class EventSheet:
	@export var data: Dictionary = {}

	func _init():
		data = {}

class Event:
	@export var event: EventResource

class Action:
	@export var action: ActionResource
