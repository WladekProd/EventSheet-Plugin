const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"angle": {
			"order": 0,
			"name": "Angle (degrees)",
			"type": {
				"name": "float",
				"data": []
			},
			"value": 90.0
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Rotate by angle",
		"category": Types.Category.ANGLE,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Rotate object by specified angle in degrees."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node2D",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var angle = _params.get("angle", {}).get("value", 90.0)
	return "rotation_degrees += %s" % str(angle)

static func get_info(_params: Dictionary = params()) -> String:
	var angle = _params.get("angle", {}).get("value", 90.0)
	return "Rotate by %s degrees" % str(angle)

static func execute(_params: Dictionary, context: Node = null):
	if not context or not context is Node2D:
		return
	var angle = _params.get("angle", {}).get("value", 90.0)
	if angle is String:
		angle = float(angle)
	context.rotation_degrees += angle

static func execute_typed(typed_params, context: Node = null):
	if not context or not context is Node2D:
		return
	var angle_param = typed_params.get_parameter("angle")
	if angle_param:
		var angle = angle_param.get_typed_value()
		if angle is String and angle.is_valid_float():
			angle = float(angle)
		context.rotation_degrees += angle