
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"text": {
			"order": 0,
			"name": "Text",
			"type": {
				"name": "string",
				"data": []
			},
			"value": '""'
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Print",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Debug console print."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var text_value = _params.get("text", {}).get("value", '""')
	return """print({text})""".format({
		"text": text_value
	})

static func get_info(_params: Dictionary = params()) -> String:
	var text_value = _params.get("text", {}).get("value", '""')
	return """Print: {text}""".format({
		"text": text_value
	})

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null):
	var text_value = _params.get("text", {}).get("value", '""')
	if text_value.begins_with('"') and text_value.ends_with('"'):
		text_value = text_value.substr(1, text_value.length() - 2)
	print(text_value)
