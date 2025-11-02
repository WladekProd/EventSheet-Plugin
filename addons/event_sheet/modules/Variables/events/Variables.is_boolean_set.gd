const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"variable_name": {
			"order": 0,
			"name": "Variable Name",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is boolean set",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Check if a boolean variable is set to true."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Variables",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {variable_name}:""".format({
		"variable_name": _params["variable_name"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{variable_name} is set""".format({
		"variable_name": _params["variable_name"]["value"],
	})
