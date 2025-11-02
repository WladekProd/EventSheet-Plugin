const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"visible": {
			"order": 0,
			"name": "Visible",
			"type": {
				"name": "select",
				"data": ["true", "false"]
			},
			"value": "true"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Set visible",
		"category": Types.Category.APPEARANCE,
		"icon": preload("res://addons/event_sheet/resources/icons/show.svg"),
		"change_icon_color": true,
		"description": "Set object visibility."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Node",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var visible = _params.get("visible", {}).get("value", "true")
	return "visible = %s" % visible

static func get_info(_params: Dictionary = params()) -> String:
	var visible = _params.get("visible", {}).get("value", "true")
	return "Set visible: %s" % visible

static func execute(_params: Dictionary, context: Node = null):
	if not context:
		return
	var visible_str = _params.get("visible", {}).get("value", "true")
	context.visible = visible_str == "true"

static func execute_typed(typed_params, context: Node = null):
	if not context:
		return
	var visible_param = typed_params.get_parameter("visible")
	if visible_param:
		var visible_value = visible_param.get_typed_value()
		if visible_value is String:
			context.visible = visible_value == "true"
		else:
			context.visible = bool(visible_value)