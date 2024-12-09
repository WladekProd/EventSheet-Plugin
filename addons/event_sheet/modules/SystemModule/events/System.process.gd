
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"process": {
			"order": 0,
			"name": "Process",
			"type": {
				"name": "select",
				"data": [
					"Process",
					"Physics process",
				]
			},
			"value": "Process"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Process",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "On process for game."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	if _params.process.value == "Process":
		return """func _process(delta: float) -> void:""".format({ })
	else:
		return """func _physics_process(delta: float) -> void:""".format({ })

static func get_info(_params: Dictionary = params()) -> String:
	if _params.process.value == "Process":
		return """Process""".format({ })
	else:
		return """Physics process""".format({ })
