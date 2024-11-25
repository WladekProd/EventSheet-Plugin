
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"rotation": {
			"order": 0,
			"name": "Rotation",
			"type": Types.STANDART_TYPES.STRING,
			"value": "0"
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """
{object}.set_rotation({rotation})
""".format({
		"rotation": _params["rotation"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set rotation: {rotation} degrees""".format({
		"rotation": _params["rotation"]["value"]
	})
