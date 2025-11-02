const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"value_a": {
			"order": 0,
			"name": "Value A",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		},
		"comparison": {
			"order": 1,
			"name": "Comparison",
			"type": {
				"name": "select",
				"data": [
					"==",
					"!=",
					"<",
					"<=",
					">",
					">=",
				]
			},
			"value": "=="
		},
		"value_b": {
			"order": 2,
			"name": "Value B",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare two values",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Compare two values using various operators."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value_b = _params.get("value_b", {}).get("value", "0")
	return """if {value_a} {comparison} {value_b}:""".format({
		"value_a": value_a,
		"comparison": comparison,
		"value_b": value_b
	})

static func get_info(_params: Dictionary = params()) -> String:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value_b = _params.get("value_b", {}).get("value", "0")
	return """{value_a} {comparison} {value_b}""".format({
		"value_a": value_a,
		"comparison": comparison,
		"value_b": value_b
	})

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null) -> bool:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value_b = _params.get("value_b", {}).get("value", "0")
	
	var a = float(value_a) if value_a.is_valid_float() else value_a
	var b = float(value_b) if value_b.is_valid_float() else value_b
	
	match comparison:
		"==": return a == b
		"!=": return a != b
		"<": return a < b
		"<=": return a <= b
		">": return a > b
		">=": return a >= b
		_: return false
