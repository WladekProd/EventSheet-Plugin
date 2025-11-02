const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"value": {
			"order": 0,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"type": {
			"order": 1,
			"name": "Type",
			"type": {
				"name": "select",
				"data": [
					"TYPE_NIL",
					"TYPE_BOOL",
					"TYPE_INT",
					"TYPE_FLOAT",
					"TYPE_STRING",
					"TYPE_VECTOR2",
					"TYPE_VECTOR2I",
					"TYPE_RECT2",
					"TYPE_RECT2I",
					"TYPE_VECTOR3",
					"TYPE_VECTOR3I",
					"TYPE_TRANSFORM2D",
					"TYPE_VECTOR4",
					"TYPE_VECTOR4I",
					"TYPE_PLANE",
					"TYPE_QUATERNION",
					"TYPE_AABB",
					"TYPE_BASIS",
					"TYPE_TRANSFORM3D",
					"TYPE_PROJECTION",
					"TYPE_COLOR",
					"TYPE_STRING_NAME",
					"TYPE_NODE_PATH",
					"TYPE_RID",
					"TYPE_OBJECT",
					"TYPE_CALLABLE",
					"TYPE_SIGNAL",
					"TYPE_DICTIONARY",
					"TYPE_ARRAY",
					"TYPE_PACKED_BYTE_ARRAY",
					"TYPE_PACKED_INT32_ARRAY",
					"TYPE_PACKED_INT64_ARRAY",
					"TYPE_PACKED_FLOAT32_ARRAY",
					"TYPE_PACKED_FLOAT64_ARRAY",
					"TYPE_PACKED_STRING_ARRAY",
					"TYPE_PACKED_VECTOR2_ARRAY",
					"TYPE_PACKED_VECTOR3_ARRAY",
					"TYPE_PACKED_COLOR_ARRAY"
				]
			},
			"value": "TYPE_NIL"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Is value type",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Check the type of a value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """if typeof({value}) == {type}:""".format({
		"value": _params["value"]["value"],
		"type": _params["type"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """{value} is of type {type}""".format({
		"value": _params["value"]["value"],
		"type": _params["type"]["value"],
	})
