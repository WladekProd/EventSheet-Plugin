const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "On timeout",
		"category": Types.Category.TIME,
		"icon": preload("res://addons/event_sheet/resources/icons/time.svg"),
		"change_icon_color": true,
		"description": "Triggered when timer reaches timeout."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Timer",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return "true"  # Timer события обрабатываются через сигналы

static func get_info(_params: Dictionary = params()) -> String:
	return "On timeout"

static func execute(_params: Dictionary, context: Node = null) -> bool:
	return true

static func execute_typed(typed_params, context: Node = null) -> bool:
	return true