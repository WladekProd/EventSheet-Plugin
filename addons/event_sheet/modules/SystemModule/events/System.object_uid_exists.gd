const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"object": {
			"order": 0,
			"name": "Object",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Object UID exists",
		"category": Types.Category.HIERARCHY,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Check if an object exists and is valid."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if get_node_or_null("{object}") != null:""".format({
		"object": _params["object"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Object {object} exists""".format({
		"object": _params["object"]["value"],
	})
