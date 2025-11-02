const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"x": {
			"order": 0,
			"name": "X",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		},
		"y": {
			"order": 1,
			"name": "Y",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		},
		"tolerance": {
			"order": 2,
			"name": "Tolerance",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "1"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is at position",
		"category": Types.Category.TRANSFORM,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Check if object is at specified position within tolerance."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node2D",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var x = _params.get("x", {}).get("value", "0")
	var y = _params.get("y", {}).get("value", "0")
	var tolerance = _params.get("tolerance", {}).get("value", "1")
	return "position.distance_to(Vector2(%s, %s)) <= %s" % [x, y, tolerance]

static func get_info(_params: Dictionary = params()) -> String:
	var x = _params.get("x", {}).get("value", "0")
	var y = _params.get("y", {}).get("value", "0")
	return "Is at position (%s, %s)" % [x, y]

static func execute(_params: Dictionary, context: Node = null) -> bool:
	if not context or not context is Node2D:
		return false
	var x = float(_params.get("x", {}).get("value", "0"))
	var y = float(_params.get("y", {}).get("value", "0"))
	var tolerance = float(_params.get("tolerance", {}).get("value", "1"))
	
	return context.position.distance_to(Vector2(x, y)) <= tolerance

static func execute_typed(typed_params, context: Node = null) -> bool:
	if not context or not context is Node2D:
		return false
	var x_param = typed_params.get_parameter("x")
	var y_param = typed_params.get_parameter("y")
	var tolerance_param = typed_params.get_parameter("tolerance")
	
	if not x_param or not y_param or not tolerance_param:
		return false
	
	var x = x_param.get_typed_value()
	var y = y_param.get_typed_value()
	var tolerance = tolerance_param.get_typed_value()
	
	if x is String and x.is_valid_float():
		x = float(x)
	if y is String and y.is_valid_float():
		y = float(y)
	if tolerance is String and tolerance.is_valid_float():
		tolerance = float(tolerance)
	
	return context.position.distance_to(Vector2(x, y)) <= tolerance