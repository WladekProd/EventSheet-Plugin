const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"expression": {
			"order": 0,
			"name": "Expression",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Evaluate expression",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/code.svg"),
		"change_icon_color": true,
		"description": "Evaluate a mathematical or logical expression."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {expression}:""".format({
		"expression": _params["expression"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Evaluate: {expression}""".format({
		"expression": _params["expression"]["value"],
	})
