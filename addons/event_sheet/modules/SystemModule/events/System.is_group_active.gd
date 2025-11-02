const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"group_name": {
			"order": 0,
			"name": "Group Name",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is group active",
		"category": Types.Category.HIERARCHY,
		"icon": preload("res://addons/event_sheet/resources/icons/group.svg"),
		"change_icon_color": true,
		"description": "Check if a group contains any nodes."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if get_tree().get_nodes_in_group("{group_name}").size() > 0:""".format({
		"group_name": _params["group_name"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Group "{group_name}" is active""".format({
		"group_name": _params["group_name"]["value"],
	})
