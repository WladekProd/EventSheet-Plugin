extends Node

# Data types for variables
const VariableType: Array = [
	"Number",
	"String",
	"Boolean",
	"Class",
]

# Class data types (includes)
const ClassType: Array = [
	"Debug",
	"Input",
	"Array",
]

# Types of blocks
enum BlockType {
	STANDART,
	VARIABLE,
	COMMENT,
	GROUP,
}

# Types of conditions
enum ConditionType {
	EVENTS,
	ACTIONS,
}

# Types of categories
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

# Types of block movement
enum MoveBlock {
	NONE = 0,
	UP = 1 << 0,
	SUB = 1 << 1,
	DOWN = 1 << 2,
	CONTENT = 1 << 3,
}

# Types of windows
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
