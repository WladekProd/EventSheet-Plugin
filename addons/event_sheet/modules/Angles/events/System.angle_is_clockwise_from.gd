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

static func execute(_params: Dictionary, context: Node = null) -> bool:
	var angle_a = float(_params.get("angle_a", {}).get("value", "0"))
	var angle_b = float(_params.get("angle_b", {}).get("value", "0"))
	
	angle_a = fmod(angle_a, 360.0)
	if angle_a < 0: angle_a += 360.0
	angle_b = fmod(angle_b, 360.0)
	if angle_b < 0: angle_b += 360.0
	
	var diff = angle_a - angle_b
	if diff < 0: diff += 360.0
	return diff <= 180.0

static func execute_typed(typed_params, context: Node = null) -> bool:
	var angle_a_param = typed_params.get_parameter("angle_a")
	var angle_b_param = typed_params.get_parameter("angle_b")
	
	if not angle_a_param or not angle_b_param:
		return false
	
	var angle_a = angle_a_param.get_typed_value()
	var angle_b = angle_b_param.get_typed_value()
	
	if angle_a is String and angle_a.is_valid_float():
		angle_a = float(angle_a)
	if angle_b is String and angle_b.is_valid_float():
		angle_b = float(angle_b)
	
	angle_a = fmod(angle_a, 360.0)
	if angle_a < 0: angle_a += 360.0
	angle_b = fmod(angle_b, 360.0)
	if angle_b < 0: angle_b += 360.0
	
	var diff = angle_a - angle_b
	if diff < 0: diff += 360.0
	return diff <= 180.0
