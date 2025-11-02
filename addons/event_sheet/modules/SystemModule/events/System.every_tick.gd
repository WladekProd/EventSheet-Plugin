const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Every tick",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/time.svg"),
		"change_icon_color": true,
		"description": "Execute every frame in the _process function."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	return """func _process(delta: float) -> void:""".format({ })

static func get_info(_params: Dictionary = params()) -> String:
	return """Every tick""".format({ })
