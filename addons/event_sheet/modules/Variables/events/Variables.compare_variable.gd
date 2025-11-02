const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"variable_name": {
			"order": 0,
			"name": "Variable Name",
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
				"data": ["==", "!=", "<", "<=", ">", ">="]
			},
			"value": "=="
		},
		"value": {
			"order": 2,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		},
		"scope": {
			"order": 3,
			"name": "Scope",
			"type": {
				"name": "select",
				"data": ["Global", "Local"]
			},
			"value": "Global"
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Compare Variable",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/local.svg"),
		"change_icon_color": true,
		"description": "Compare variable with value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Variables",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value = _params.get("value", {}).get("value", "0")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	var scope_enum = "0" if scope == "Global" else "1"  # Use numeric values
	
	return "(Engine.has_singleton(\"VariableManager\") and Engine.get_singleton(\"VariableManager\").get_variable(\"%s\", %s) %s %s)" % [var_name, scope_enum, comparison, value]

static func get_info(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value = _params.get("value", {}).get("value", "0")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	return """{scope} variable "{var_name}" {comparison} {value}""".format({
		"var_name": var_name,
		"comparison": comparison,
		"value": value,
		"scope": scope
	})

static func execute(_params: Dictionary, context: Node = null) -> bool:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var comparison = _params.get("comparison", {}).get("value", "==")
	var value = _params.get("value", {}).get("value", "0")
	var scope_str = _params.get("scope", {}).get("value", "Global")
	
	if var_name.is_empty():
		return false
	
	if not Engine.has_singleton("VariableManager"):
		return false
	
	var scope = 0 if scope_str == "Global" else 1  # Use numeric values
	var var_value = Engine.get_singleton("VariableManager").get_variable(var_name, scope)
	
	if var_value == null:
		return false
	
	# Преобразуем оба значения к одному типу
	var converted_var_value = var_value
	var converted_value = value
	
	# Преобразуем в число, если возможно
	if var_value is String and var_value.is_valid_float():
		converted_var_value = float(var_value)
	if value is String and value.is_valid_float():
		converted_value = float(value)
	
	# Преобразуем в булево, если возможно
	if var_value is String and var_value.to_lower() in ["true", "false"]:
		converted_var_value = var_value.to_lower() == "true"
	if value is String and value.to_lower() in ["true", "false"]:
		converted_value = value.to_lower() == "true"
	
	match comparison:
		"==": return converted_var_value == converted_value
		"!=": return converted_var_value != converted_value
		"<": return converted_var_value < converted_value
		"<=": return converted_var_value <= converted_value
		">": return converted_var_value > converted_value
		">=": return converted_var_value >= converted_value
		_: return false
