
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"width": {
			"order": 0,
			"name": "Width",
			"type": Types.STANDART_TYPES.STRING,
			"value": "1"
		},
		"height": {
			"order": 1,
			"name": "Height",
			"type": Types.STANDART_TYPES.STRING,
			"value": "1"
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """
{object}.set_scale(Vector2({width}, {height}))
""".format({
		"width": _params["width"]["value"],
		"height": _params["height"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set scale: {width}, {height}""".format({
		"width": _params["width"]["value"],
		"height": _params["height"]["value"],
	})
