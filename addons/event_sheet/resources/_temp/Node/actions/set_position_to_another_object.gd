
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"object": {
			"order": 0,
			"name": "Object",
			"type": Types.STANDART_TYPES.SELECT_NODE,
			"value": ""
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """
print({object})
""".format({
		"object": _params["object"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set position to: [img=15]{object}[/img] {name}""".format({
		"object": ESUtils.get_node_icon(_params["object"]["value"]),
		"name": ESUtils.get_node_name(_params["object"]["value"]),
	})
