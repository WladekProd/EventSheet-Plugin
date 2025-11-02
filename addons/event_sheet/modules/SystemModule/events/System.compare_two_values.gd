const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"value_a": {
			"order": 0,
			"name": "Value A",
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
		"value_b": {
			"order": 2,
			"name": "Value B",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare two values",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Compare two values using various operators."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {value_a} {comparison} {value_b}:""".format({
		"value_a": _params["value_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"value_b": _params["value_b"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{value_a} {comparison} {value_b}""".format({
		"value_a": _params["value_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"value_b": _params["value_b"]["value"],
	})
