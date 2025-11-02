const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"comparison": {
			"order": 0,
			"name": "Comparison",
			"type": {
				"name": "select",
				"data": ["=", "≠", "<", "≤", ">", "≥"]
			},
			"value": "="
		},
		"angle": {
			"order": 1,
			"name": "Angle (degrees)",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare rotation",
		"category": Types.Category.ANGLE,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Compare object rotation with value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node2D",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var comparison = _params.get("comparison", {}).get("value", "=")
	var angle = _params.get("angle", {}).get("value", "0")
	var op = comparison
	match comparison:
		"≠": op = "!="
		"≤": op = "<="
		"≥": op = ">="
	return "rotation_degrees %s %s" % [op, angle]

static func get_info(_params: Dictionary = params()) -> String:
	var comparison = _params.get("comparison", {}).get("value", "=")
	var angle = _params.get("angle", {}).get("value", "0")
	return "Rotation %s %s degrees" % [comparison, angle]

static func execute(_params: Dictionary, context: Node = null) -> bool:
	if not context or not context is Node2D:
		return false
	var comparison = _params.get("comparison", {}).get("value", "=")
	var angle = float(_params.get("angle", {}).get("value", "0"))
	var rotation = context.rotation_degrees
	
	match comparison:
		"=": return rotation == angle
		"≠": return rotation != angle
		"<": return rotation < angle
		"≤": return rotation <= angle
		">": return rotation > angle
		"≥": return rotation >= angle
		_: return false

static func execute_typed(typed_params, context: Node = null) -> bool:
	if not context or not context is Node2D:
		return false
	var comparison_param = typed_params.get_parameter("comparison")
	var angle_param = typed_params.get_parameter("angle")
	
	if not comparison_param or not angle_param:
		return false
	
	var comparison = comparison_param.get_typed_value()
	var angle = angle_param.get_typed_value()
	if angle is String and angle.is_valid_float():
		angle = float(angle)
	
	var rotation = context.rotation_degrees
	
	match comparison:
		"=": return rotation == angle
		"≠": return rotation != angle
		"<": return rotation < angle
		"≤": return rotation <= angle
		">": return rotation > angle
		"≥": return rotation >= angle
		_: return false