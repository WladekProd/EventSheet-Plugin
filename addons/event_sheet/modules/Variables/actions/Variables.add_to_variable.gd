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
			"value": "1"
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
		"name": "Add to Variable",
		"category": Types.Category.VARIABLE,
		"icon": preload("res://addons/event_sheet/resources/icons/global.svg"),
		"change_icon_color": true,
		"description": "Add value to variable."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Variables",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "1")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	var scope_enum = "0" if scope == "Global" else "1"  # Use numeric values
	
	return """if Engine.has_singleton(\"VariableManager\"): Engine.get_singleton(\"VariableManager\").set_variable(\"{var_name}\", Engine.get_singleton(\"VariableManager\").get_variable(\"{var_name}\", {scope}) + {value}, {scope})""".format({
		"var_name": var_name,
		"value": value,
		"scope": scope_enum
	})

static func get_info(_params: Dictionary = params()) -> String:
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "1")
	var scope = _params.get("scope", {}).get("value", "Global")
	
	return """Add {value} to {scope} variable "{var_name}" """.format({
		"var_name": var_name,
		"value": value,
		"scope": scope.to_lower()
	})

static func execute(_params: Dictionary, context: Node = null):
	var var_name = _params.get("variable_name", {}).get("value", "")
	var value = _params.get("value", {}).get("value", "1")
	var scope_str = _params.get("scope", {}).get("value", "Global")
	
	if var_name.is_empty():
		return
	
	if not Engine.has_singleton("VariableManager"):
		return
	
	var scope = 0 if scope_str == "Global" else 1  # Use numeric values
	var current_value = Engine.get_singleton("VariableManager").get_variable(var_name, scope)
	
	# Преобразуем текущее значение
	if current_value == null:
		current_value = 0
	elif current_value is String and current_value.is_valid_float():
		current_value = float(current_value)
	elif current_value is String:
		current_value = 0
	
	# Преобразуем добавляемое значение
	var add_value = value
	if value is String and value.is_valid_float():
		add_value = float(value)
	elif value is String:
		add_value = 0
	
	Engine.get_singleton("VariableManager").set_variable(var_name, current_value + add_value, scope)
