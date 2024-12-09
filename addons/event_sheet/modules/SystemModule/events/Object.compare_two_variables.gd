
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"variable_a": {
			"order": 0,
			"name": "Variable A",
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
					">",
				]
			},
			"value": "=="
		},
		"variable_b": {
			"order": 2,
			"name": "Variable B",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare two variables",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Compare two variables description."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": ESUtils.get_node_name(object_path),
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {variable_a} {comparison} {variable_b}:""".format({
		"variable_a": _params["variable_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"variable_b": _params["variable_b"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{variable_a} {comparison} {variable_b}""".format({
		"variable_a": _params["variable_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"variable_b": _params["variable_b"]["value"],
	})
