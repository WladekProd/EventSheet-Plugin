const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"angle": {
			"order": 0,
			"name": "Angle",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"min_angle": {
			"order": 1,
			"name": "Min Angle",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"max_angle": {
			"order": 2,
			"name": "Max Angle",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is between angles",
		"category": Types.Category.ANGLE,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Check if an angle is between two other angles."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg")
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {angle} >= {min_angle} and {angle} <= {max_angle}:""".format({
		"angle": _params["angle"]["value"],
		"min_angle": _params["min_angle"]["value"],
		"max_angle": _params["max_angle"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{angle} is between {min_angle} and {max_angle}""".format({
		"angle": _params["angle"]["value"],
		"min_angle": _params["min_angle"]["value"],
		"max_angle": _params["max_angle"]["value"],
	})
