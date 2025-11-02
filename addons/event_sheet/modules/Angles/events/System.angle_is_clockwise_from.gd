const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"angle_a": {
			"order": 0,
			"name": "Angle A",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"angle_b": {
			"order": 1,
			"name": "Angle B",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is clockwise from",
		"category": Types.Category.ANGLE,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Check if angle A is clockwise from angle B."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg")
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {angle_a} < {angle_b}:""".format({
		"angle_a": _params["angle_a"]["value"],
		"angle_b": _params["angle_b"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{angle_a} is clockwise from {angle_b}""".format({
		"angle_a": _params["angle_a"]["value"],
		"angle_b": _params["angle_b"]["value"],
	})
