
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"action": {
			"order": 1,
			"name": "Action name",
			"type": {
				"name": "select",
				"data": ESUtils.get_input_actions_data()
			},
			"value": '0'
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is action pressed",
		"category": Types.Category.INPUT,
		"icon": preload("res://addons/event_sheet/resources/icons/input.svg"),
		"change_icon_color": true,
		"description": "Input events."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if event.is_action_pressed("{action}"):""".format({
		"action": _params["action"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Is action pressed: {action}""".format({
		"action": _params["action"]["value"]
	})
