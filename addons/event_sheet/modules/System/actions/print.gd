
const Types = preload("res://addons/event_sheet/source/types.gd")

static func params() -> Dictionary:
	return {
		"text": {
			"order": 0,
			"name": "Text",
			"type": Types.STANDART_TYPES.STRING,
			"value": '""'
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """print({text})""".format({
		"text": params["text"]["value"]
	})

static func get_info(params: Dictionary = params()) -> String:
	return """Print: {text}""".format({
		"text": params["text"]["value"]
	})
