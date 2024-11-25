
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"skew": {
			"order": 0,
			"name": "Skew",
			"type": Types.STANDART_TYPES.STRING,
			"value": "0"
		}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """
{object}.set_skew({skew})
""".format({
		"skew": _params["skew"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set skew: {skew} degrees""".format({
		"skew": _params["skew"]["value"]
	})
