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
		"value": {
			"order": 1,
			"name": "Value",
			"type": {
				"name": "string",
				"data": []
			},
			"value": "0"
		},
		"scope": {
			"order": 2,
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
		"name": "Set Variable",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/global.svg"),
		"change_icon_color": true,
		"description": "Set variable value."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Variables",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "0")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	var scope_enum = "VariableManager.VariableScope.GLOBAL" if scope == "Global" else "VariableManager.VariableScope.LOCAL"
	
	return """VariableManager.set_variable("{var_name}", {value}, {scope})""".format({
		"var_name": var_name,
		"value": value,
		"scope": scope_enum
	})

static func get_info(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "0")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	return """Set {scope} variable "{var_name}" to {value}""".format({
		"var_name": var_name,
		"value": value,
		"scope": scope.to_lower()
	})

static func execute(_params: Dictionary, context: Node = null):
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "0")
	var scope_str = _params.get("scope", {}).get("value", "Global")
	
	if var_name.is_empty():
		return
	
	var scope = VariableManager.VariableScope.GLOBAL if scope_str == "Global" else VariableManager.VariableScope.LOCAL
	
	var converted_value = value
	if value is String:
		if value.is_valid_float():
			converted_value = float(value)
		elif value.to_lower() in ["true", "false"]:
			converted_value = value.to_lower() == "true"
	
	VariableManager.set_variable(var_name, converted_value, scope)