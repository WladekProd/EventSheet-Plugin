const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"string": {
			"order": 0,
			"name": "String",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"pattern": {
			"order": 1,
			"name": "Regex Pattern",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Test regex",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/code.svg"),
		"change_icon_color": true,
		"description": "Test if a string matches a regular expression pattern."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if RegEx.new().compile("{pattern}").search({string}) != null:""".format({
		"string": _params["string"]["value"],
		"pattern": _params["pattern"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Test regex: {string} matches {pattern}""".format({
		"string": _params["string"]["value"],
		"pattern": _params["pattern"]["value"],
	})
