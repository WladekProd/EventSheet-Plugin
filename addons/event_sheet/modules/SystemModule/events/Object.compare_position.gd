
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"pos_a": {
			"order": 0,
			"name": "Position A",
			"type": Types.STANDART_TYPES.STRING,
			"value": ""
		},
		"comparison": {
			"order": 1,
			"name": "Comparison",
			"type": Types.STIPULATION,
			"value": Types.STIPULATION_SYMBOL[Types.STIPULATION.EQUALS]
		},
		"pos_b": {
			"order": 2,
			"name": "Position B",
			"type": Types.STANDART_TYPES.STRING,
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare position",
		"category": Types.Category.MAIN,
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false,
		"description": "Compare two object positions."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": ESUtils.get_node_name(object_path),
		"icon": ESUtils.get_node_icon_texture(object_path),
		"change_icon_color": false
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if {pos_a} {comparison} {pos_b}:""".format({
		"pos_a": _params["pos_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"pos_b": _params["pos_b"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{pos_a} {comparison} {pos_b}""".format({
		"pos_a": _params["pos_a"]["value"],
		"comparison": _params["comparison"]["value"],
		"pos_b": _params["pos_b"]["value"],
	})
