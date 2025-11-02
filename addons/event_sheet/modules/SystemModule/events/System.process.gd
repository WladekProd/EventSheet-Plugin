
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
	return "true"  # Process всегда выполняется

static func get_info(_params: Dictionary = params()) -> String:
	var process_type = _params.get("process", {}).get("value", "Process")
	return process_type

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null) -> bool:
	return true  # Process всегда выполняется

# Типизированное выполнение
static func execute_typed(typed_params, context: Node = null) -> bool:
	return true  # Process всегда выполняется
