const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Every tick",
		"category": Types.Category.TIME,
		"icon": preload("res://addons/event_sheet/resources/icons/time.svg"),
		"change_icon_color": true,
		"description": "Executes every frame (tick)."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return "true"  # Always true for every tick

static func get_info(_params: Dictionary = params()) -> String:
	return "Every tick"

static func execute(_params: Dictionary, context: Node = null) -> bool:
	return true

static func execute_typed(typed_params, context: Node = null) -> bool:
	return true