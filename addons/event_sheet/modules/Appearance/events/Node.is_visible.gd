const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is visible",
		"category": Types.Category.APPEARANCE,
		"icon": preload("res://addons/event_sheet/resources/icons/show.svg"),
		"change_icon_color": true,
		"description": "Check if object is visible."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return "if visible:"

static func get_info(_params: Dictionary = params()) -> String:
	return "Is visible"

static func execute(_params: Dictionary, context: Node = null) -> bool:
	if not context:
		return false
	return context.visible

static func execute_typed(typed_params, context: Node = null) -> bool:
	if not context:
		return false
	return context.visible