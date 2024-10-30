
const Types = preload("res://addons/event_sheet/source/types.gd")

static func params() -> Dictionary:
	return {
		"object": {
			"order": 0,
			"name": "Object",
			"type": Types.STANDART_TYPES.SELECT_NODE,
			"value": ""
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """
print({object})
""".format({
		"object": params["object"]["value"]
	})

static func get_info(params: Dictionary = params()) -> String:
	return """Set position to: {object}""".format({
		"object": str(params["object"]["value"])
	})
