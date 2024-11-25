
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"text": {
			"order": 0,
			"name": "Text",
			"type": Types.STANDART_TYPES.STRING,
			"value": '""'
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """print({text})""".format({
		"text": _params["text"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Print: {text}""".format({
		"text": _params["text"]["value"]
	})
