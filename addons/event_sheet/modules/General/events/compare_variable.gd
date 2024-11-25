
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"variable_a": {
			"order": 0,
			"name": "Variable A",
			"type": Types.STANDART_TYPES.STRING,
			"value": ""
		},
		"comparison": {
			"order": 1,
			"name": "Comparison",
			"type": Types.STIPULATION,
			"value": Types.STIPULATION_SYMBOL[Types.STIPULATION.EQUALS]
		},
		"variable_b": {
			"order": 2,
			"name": "Variable B",
			"type": Types.STANDART_TYPES.STRING,
			"value": ""
		}
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
