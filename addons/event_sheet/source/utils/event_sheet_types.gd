extends Node

const VariableType: Array = [
	"Number",
	"String",
	"Boolean",
	"Class",
]

const ClassType: Array = [
	"Debug",
	"Input",
	"Array",
]

#enum VariableType {
	#NUMBER,
	#STRING,
	#BOOLEAN,
	#CLASS,
#}

enum EventType {
	STANDART,
	SINGLE_EVENT,
	FUNCTION,
	CYCLE,
}

enum BlockType {
	STANDART,
	VARIABLE,
	COMMENT,
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
	TRANSFORM,
	ANIMATION,
	MANIPULATION,
	APPEARANCE,
	HIERARCHY,
	VARIABLE,
	ZORDER,
	INPUT,
	TIME,
	MISK,
}
const CATEGORY_NAMES = {
	Category.MAIN: "Main",
	Category.TRANSFORM: "Transform",
	Category.ANIMATION: "Animation",
	Category.MANIPULATION: "Manipulation",
	Category.APPEARANCE: "Appearance",
	Category.HIERARCHY: "Hierarchy",
	Category.VARIABLE: "Variable",
	Category.ZORDER: "Z-Order",
	Category.INPUT: "Input",
	Category.TIME: "Time",
	Category.MISK: "Misk",
}

enum MoveBlock {
	NONE = 0,
	UP = 1 << 0,
	SUB = 1 << 1,
	DOWN = 1 << 2,
	CONTENT = 1 << 3,
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
	EDIT_CLASS,
	EDITOR_SETTINGS,
}
