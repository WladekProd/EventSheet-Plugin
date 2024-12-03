
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return { }

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Ready",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "On start for game."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """func _ready() -> void:""".format({ })

static func get_info(_params: Dictionary = params()) -> String:
	return """Ready""".format({ })
