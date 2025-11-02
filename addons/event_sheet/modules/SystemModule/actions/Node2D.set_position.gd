const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"x": {
			"order": 0,
			"name": "X",
			"type": {
				"name": "number",
				"data": []
			},
			"value": "0"
		},
		"y": {
			"order": 1,
			"name": "Y",
			"type": {
				"name": "number",
				"data": []
			},
			"value": "0"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Set position",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/move.svg"),
		"change_icon_color": true,
		"description": "Set the position of a Node2D object."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node2D",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var x_value = _params.get("x", {}).get("value", "0")
	var y_value = _params.get("y", {}).get("value", "0")
	
	return "self.position = Vector2(%s, %s)" % [x_value, y_value]

static func get_info(_params: Dictionary = params()) -> String:
	var x_value = _params.get("x", {}).get("value", "0")
	var y_value = _params.get("y", {}).get("value", "0")
	
	return "Set position to (%s, %s)" % [x_value, y_value]

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null):
	if not context or not context is Node2D:
		return
	
	var x_value = float(_params.get("x", {}).get("value", "0"))
	var y_value = float(_params.get("y", {}).get("value", "0"))
	
	context.position = Vector2(x_value, y_value)

# Типизированное выполнение
static func execute_typed(typed_params, context: Node = null):
	if not context or not context is Node2D:
		return
	
	var x_param = typed_params.get_parameter("x")
	var y_param = typed_params.get_parameter("y")
	
	if not x_param or not y_param:
		return
	
	var x_value = x_param.get_typed_value()
	var y_value = y_param.get_typed_value()
	
	context.position = Vector2(x_value, y_value)