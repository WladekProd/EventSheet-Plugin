const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"value": {
			"order": 0,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is number NaN",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Check if a number is NaN (Not a Number)."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if is_nan({value}):""".format({
		"value": _params["value"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{value} is NaN""".format({
		"value": _params["value"]["value"],
	})
