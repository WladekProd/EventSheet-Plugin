
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"x": {
			"order": 0,
			"name": "X",
			"type": Types.STANDART_TYPES.STRING,
			"value": "0"
		},
		"y": {
			"order": 1,
			"name": "Y",
			"type": Types.STANDART_TYPES.STRING,
			"value": "0"
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """
{object}.set_position(Vector2({x}, {y}))
""".format({
		"x": _params["x"]["value"],
		"y": _params["y"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set position: {x}, {y}""".format({
		"x": _params["x"]["value"],
		"y": _params["y"]["value"],
	})
