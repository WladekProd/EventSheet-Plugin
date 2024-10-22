
static func params() -> Dictionary:
	return {
		"text": {
			"name": "Text",
			"value": ""
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """print({text.value})""".format(params)
