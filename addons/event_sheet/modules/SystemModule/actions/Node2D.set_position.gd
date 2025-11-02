
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
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Set position",
		"category": Types.Category.TRANSFORM,
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false,
		"description": "Set object position to coords."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"condition_name": "Set position",
		"condition_icon": {},
		"name": ESUtils.get_node_name(object_path),
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false
	}

static func get_template(_params: Dictionary = params()) -> String:
	var x_value = _params.get("x", {}).get("value", "0")
	var y_value = _params.get("y", {}).get("value", "0")
	return """{object}.position = Vector2({x}, {y})""".format({
		"x": x_value,
		"y": y_value
	})

static func get_info(_params: Dictionary = params()) -> String:
	var x_value = _params.get("x", {}).get("value", "0")
	var y_value = _params.get("y", {}).get("value", "0")
	return """Set position: {x}, {y}""".format({
		"x": x_value,
		"y": y_value
	})

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null):
	if not context or not context is Node2D:
		return
	
	var x_value = _params.get("x", {}).get("value", "0")
	var y_value = _params.get("y", {}).get("value", "0")
	
	var x = float(x_value) if x_value.is_valid_float() else 0.0
	var y = float(y_value) if y_value.is_valid_float() else 0.0
	
	context.position = Vector2(x, y)
