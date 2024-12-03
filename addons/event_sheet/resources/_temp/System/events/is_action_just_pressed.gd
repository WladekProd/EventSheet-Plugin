
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"action": {
			"order": 0,
			"name": "Action",
			"type": Types.STANDART_TYPES.STRING,
			"value": '""'
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if Input.is_action_just_pressed({action}):""".format({
		"action": _params["action"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Is action just pressed: {action}""".format({
		"action": _params["action"]["value"]
	})
