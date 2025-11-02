const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"value": {
			"order": 0,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"min_value": {
			"order": 1,
			"name": "Min Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"max_value": {
			"order": 2,
			"name": "Max Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"inclusive": {
			"order": 3,
			"name": "Inclusive",
			"type": {
				"name": "select",
				"data": [
					"Inclusive",
					"Exclusive"
				]
			},
			"value": "Inclusive"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is between values",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Check if a value is between two other values."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	if _params.inclusive.value == "Inclusive":
		return """if {value} >= {min_value} and {value} <= {max_value}:""".format({
			"value": _params["value"]["value"],
			"min_value": _params["min_value"]["value"],
			"max_value": _params["max_value"]["value"],
		})
	else:
		return """if {value} > {min_value} and {value} < {max_value}:""".format({
			"value": _params["value"]["value"],
			"min_value": _params["min_value"]["value"],
			"max_value": _params["max_value"]["value"],
		})

static func get_info(_params: Dictionary = params()) -> String:
	if _params.inclusive.value == "Inclusive":
		return """{value} is between {min_value} and {max_value} (inclusive)""".format({
			"value": _params["value"]["value"],
			"min_value": _params["min_value"]["value"],
			"max_value": _params["max_value"]["value"],
		})
	else:
		return """{value} is between {min_value} and {max_value} (exclusive)""".format({
			"value": _params["value"]["value"],
			"min_value": _params["min_value"]["value"],
			"max_value": _params["max_value"]["value"],
		})
