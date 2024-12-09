
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"x": {
			"order": 0,
			"name": "X",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		},
		"y": {
			"order": 1,
			"name": "Y",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Set position",
		"category": Types.Category.TRANSFORM,
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false,
		"description": "Set object position to coords."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"condition_name": "Set position",
		"condition_icon": {},
		"name": ESUtils.get_node_name(object_path),
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """{object}.set_position(Vector2({x}, {y}))""".format({
		"x": _params["x"]["value"],
		"y": _params["y"]["value"]
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Set position: {x}, {y}""".format({
		"x": _params["x"]["value"],
		"y": _params["y"]["value"],
	})
