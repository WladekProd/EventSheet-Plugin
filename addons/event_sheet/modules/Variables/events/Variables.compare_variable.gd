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
		},
		"comparison": {
			"order": 1,
			"name": "Comparison",
			"type": {
				"name": "select",
				"data": [
					"==",
					"!=",
					"<",
					"<=",
					">",
					">=",
				]
			},
			"value": "=="
		},
		"value": {
			"order": 2,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare variable",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Compare a variable with a value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Variables",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {variable_name} {comparison} {value}:""".format({
		"variable_name": _params["variable_name"]["value"],
		"comparison": _params["comparison"]["value"],
		"value": _params["value"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{variable_name} {comparison} {value}""".format({
		"variable_name": _params["variable_name"]["value"],
		"comparison": _params["comparison"]["value"],
		"value": _params["value"]["value"],
	})
