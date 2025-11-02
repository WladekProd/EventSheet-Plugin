const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"seconds": {
			"order": 0,
			"name": "Seconds",
			"type": {
				"name": "float",
				"data": []
			},
			"value": 0.05
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Wait",
		"category": Types.Category.TIME,
		"icon": preload("res://addons/event_sheet/resources/icons/time.svg"),
		"change_icon_color": true,
		"description": "Wait for specified time in seconds."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var seconds = _params.get("seconds", {}).get("value", "1.0")
	return "await get_tree().create_timer(%s).timeout" % seconds

static func get_info(_params: Dictionary = params()) -> String:
	var seconds = _params.get("seconds", {}).get("value", "1.0")
	return "Wait %s seconds" % seconds

static func execute(_params: Dictionary, context: Node = null) -> bool:
	return true

static func execute_typed(typed_params, context: Node = null) -> bool:
	return true