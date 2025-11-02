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
		},
		"max_difference": {
			"order": 2,
			"name": "Max Difference",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is within angle",
		"category": Types.Category.ANGLE,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Check if the angle difference between two angles is within a maximum value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg")
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if abs({angle_a} - {angle_b}) <= {max_difference}:""".format({
		"angle_a": _params["angle_a"]["value"],
		"angle_b": _params["angle_b"]["value"],
		"max_difference": _params["max_difference"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Angle difference between {angle_a} and {angle_b} is within {max_difference}""".format({
		"angle_a": _params["angle_a"]["value"],
		"angle_b": _params["angle_b"]["value"],
		"max_difference": _params["max_difference"]["value"],
	})
