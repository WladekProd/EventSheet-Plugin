
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return { }

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Input",
		"category": Types.Category.INPUT,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Input events."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """func _input(event: InputEvent) -> void:""".format({ })

static func get_info(_params: Dictionary = params()) -> String:
	return """Input""".format({ })
