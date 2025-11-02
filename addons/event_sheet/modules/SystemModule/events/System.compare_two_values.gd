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
			"value": "0"
		},
		"comparison": {
			"order": 1,
			"name": "Comparison",
			"type": {
				"name": "select",
				"data": ["=", "≠", "<", "≤", ">", "≥"]
			},
			"value": "="
		},
		"value_b": {
			"order": 2,
			"name": "Value B",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare two values",
		"category": Types.Category.MAIN,
		"icon": preload("res://addons/event_sheet/resources/icons/system.svg"),
		"change_icon_color": true,
		"description": "Compare two values with specified operator."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "System",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "=")
	var value_b = _params.get("value_b", {}).get("value", "0")
	
	# Конвертируем символы сравнения
	var op = comparison
	match comparison:
		"≠": op = "!="
		"≤": op = "<="
		"≥": op = ">="
	
	return "%s %s %s" % [value_a, op, value_b]

static func get_info(_params: Dictionary = params()) -> String:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "=")
	var value_b = _params.get("value_b", {}).get("value", "0")
	
	return "Compare: %s %s %s" % [value_a, comparison, value_b]

# Прямое выполнение в рантайме
static func execute(_params: Dictionary, context: Node = null) -> bool:
	var value_a = _params.get("value_a", {}).get("value", "0")
	var comparison = _params.get("comparison", {}).get("value", "=")
	var value_b = _params.get("value_b", {}).get("value", "0")
	
	# Пытаемся преобразовать в числа
	var a = float(value_a) if value_a.is_valid_float() else value_a
	var b = float(value_b) if value_b.is_valid_float() else value_b
	
	match comparison:
		"=": return a == b
		"≠": return a != b
		"<": return a < b
		"≤": return a <= b
		">": return a > b
		"≥": return a >= b
		_: return false

# Типизированное выполнение
static func execute_typed(typed_params, context: Node = null) -> bool:
	var value_a_param = typed_params.get_parameter("value_a")
	var comparison_param = typed_params.get_parameter("comparison")
	var value_b_param = typed_params.get_parameter("value_b")
	
	if not value_a_param or not comparison_param or not value_b_param:
		return false
	
	var a = value_a_param.get_typed_value()
	var comparison = comparison_param.get_typed_value()
	var b = value_b_param.get_typed_value()
	
	# Автоматическое преобразование типов для сравнения
	if a is String and a.is_valid_float():
		a = float(a)
	if b is String and b.is_valid_float():
		b = float(b)
	
	match comparison:
		"=": return a == b
		"≠": return a != b
		"<": return a < b
		"≤": return a <= b
		">": return a > b
		"≥": return a >= b
		_: return false