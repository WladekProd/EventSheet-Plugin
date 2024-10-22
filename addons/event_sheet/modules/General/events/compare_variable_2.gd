
static func params() -> Dictionary:
	return {
		"variable_a": {
			"name": "Variable 1",
			"value": ""
		},
		"comparison": {
			"name": "Comparison",
			"value": ""
		},
		"variable_b": {
			"name": "Variable 2",
			"value": ""
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """if {variable_a.value} {comparison.value} {variable_b.value}:""".format(params)
