
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"text": {
			"order": 0,
			"name": "Text",
			"type": {
				"name": "string",
				"data": []
			},
			"value": '""'
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Print",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Debug console print."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """print({text})""".format({
		"text": _params["text"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Print: {text}""".format({
		"text": _params["text"]["value"]
	})
