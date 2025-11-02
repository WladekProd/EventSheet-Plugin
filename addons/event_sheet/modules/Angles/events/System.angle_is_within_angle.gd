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

static func execute(_params: Dictionary, context: Node = null) -> bool:
	var angle_a = float(_params.get("angle_a", {}).get("value", "0"))
	var angle_b = float(_params.get("angle_b", {}).get("value", "0"))
	var max_diff = float(_params.get("max_difference", {}).get("value", "10"))
	
	return abs(angle_a - angle_b) <= max_diff

static func execute_typed(typed_params, context: Node = null) -> bool:
	var angle_a_param = typed_params.get_parameter("angle_a")
	var angle_b_param = typed_params.get_parameter("angle_b")
	var max_diff_param = typed_params.get_parameter("max_difference")
	
	if not angle_a_param or not angle_b_param or not max_diff_param:
		return false
	
	var angle_a = angle_a_param.get_typed_value()
	var angle_b = angle_b_param.get_typed_value()
	var max_diff = max_diff_param.get_typed_value()
	
	if angle_a is String and angle_a.is_valid_float():
		angle_a = float(angle_a)
	if angle_b is String and angle_b.is_valid_float():
		angle_b = float(angle_b)
	if max_diff is String and max_diff.is_valid_float():
		max_diff = float(max_diff)
	
	return abs(angle_a - angle_b) <= max_diff
