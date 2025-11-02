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

static func execute(_params: Dictionary, context: Node = null) -> bool:
	var angle = float(_params.get("angle", {}).get("value", "0"))
	var min_angle = float(_params.get("min_angle", {}).get("value", "0"))
	var max_angle = float(_params.get("max_angle", {}).get("value", "360"))
	
	return angle >= min_angle and angle <= max_angle

static func execute_typed(typed_params, context: Node = null) -> bool:
	var angle_param = typed_params.get_parameter("angle")
	var min_param = typed_params.get_parameter("min_angle")
	var max_param = typed_params.get_parameter("max_angle")
	
	if not angle_param or not min_param or not max_param:
		return false
	
	var angle = angle_param.get_typed_value()
	var min_angle = min_param.get_typed_value()
	var max_angle = max_param.get_typed_value()
	
	if angle is String and angle.is_valid_float():
		angle = float(angle)
	if min_angle is String and min_angle.is_valid_float():
		min_angle = float(min_angle)
	if max_angle is String and max_angle.is_valid_float():
		max_angle = float(max_angle)
	
	return angle >= min_angle and angle <= max_angle
