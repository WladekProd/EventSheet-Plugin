@tool
extends Node

var global_variables: Dictionary = {}
var local_variables: Dictionary = {}
var variables_file_path: String = "user://event_sheet_variables.json"

enum VariableType {
	NUMBER,
	STRING,
	BOOLEAN,
	VECTOR2
}

enum VariableScope {
	GLOBAL,
	LOCAL
}

signal variable_changed(name: String, value: Variant, scope: VariableScope)

func _ready():
	load_variables()

func create_variable(name: String, type: VariableType, scope: VariableScope, initial_value: Variant = null):
	var default_value = get_default_value(type)
	var value = initial_value if initial_value != null else default_value

	var variable_data = {
		"name": name,
		"type": type,
		"scope": scope,
		"value": value,
		"default": default_value
	}

	match scope:
		VariableScope.GLOBAL:
			global_variables[name] = variable_data
		VariableScope.LOCAL:
			local_variables[name] = variable_data

	variable_changed.emit(name, value, scope)
	save_variables()

func set_variable(name: String, value: Variant, scope = VariableScope.GLOBAL):
	# Convert numeric scope to enum if needed
	if scope is int:
		scope = VariableScope.GLOBAL if scope == 0 else VariableScope.LOCAL
	
	# Debug output removed for production
	
	var variables = global_variables if scope == VariableScope.GLOBAL else local_variables

	if variables.has(name):
		variables[name].value = convert_value(value, variables[name].type)
		variable_changed.emit(name, variables[name].value, scope)
	else:
		var detected_type = detect_type(value)
		create_variable(name, detected_type, scope, value)
	save_variables()

func get_variable(name: String, scope = VariableScope.GLOBAL) -> Variant:
	# Convert numeric scope to enum if needed
	if scope is int:
		scope = VariableScope.GLOBAL if scope == 0 else VariableScope.LOCAL
	
	var variables = global_variables if scope == VariableScope.GLOBAL else local_variables

	if variables.has(name):
		return variables[name].value

	var other_variables = local_variables if scope == VariableScope.GLOBAL else global_variables
	if other_variables.has(name):
		return other_variables[name].value

	return null

func has_variable(name: String, scope: VariableScope = VariableScope.GLOBAL) -> bool:
	var variables = global_variables if scope == VariableScope.GLOBAL else local_variables
	return variables.has(name)

func get_all_variables(scope = VariableScope.GLOBAL) -> Dictionary:
	# Convert numeric scope to enum if needed
	if scope is int:
		scope = VariableScope.GLOBAL if scope == 0 else VariableScope.LOCAL
	
	return global_variables if scope == VariableScope.GLOBAL else local_variables

func get_default_value(type: VariableType) -> Variant:
	match type:
		VariableType.NUMBER: return 0.0
		VariableType.STRING: return ""
		VariableType.BOOLEAN: return false
		VariableType.VECTOR2: return Vector2.ZERO
		_: return null

func detect_type(value: Variant) -> VariableType:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT: return VariableType.NUMBER
		TYPE_STRING: return VariableType.STRING
		TYPE_BOOL: return VariableType.BOOLEAN
		TYPE_VECTOR2: return VariableType.VECTOR2
		_: return VariableType.STRING

func convert_value(value: Variant, type: VariableType) -> Variant:
	match type:
		VariableType.NUMBER:
			if value is String:
				return float(value) if value.is_valid_float() else 0.0
			return float(value)
		VariableType.STRING:
			return str(value)
		VariableType.BOOLEAN:
			if value is String:
				return value.to_lower() in ["true", "1", "yes"]
			return bool(value)
		VariableType.VECTOR2:
			if value is String:
				var parts = value.split(",")
				if parts.size() >= 2:
					return Vector2(float(parts[0]), float(parts[1]))
			return Vector2(value) if value is Vector2 else Vector2.ZERO
		_:
			return value

func clear_local_variables():
	local_variables.clear()

func remove_variable(name: String, scope = VariableScope.GLOBAL):
	# Convert numeric scope to enum if needed
	if scope is int:
		scope = VariableScope.GLOBAL if scope == 0 else VariableScope.LOCAL
	
	var variables = global_variables if scope == VariableScope.GLOBAL else local_variables
	if variables.has(name):
		variables.erase(name)
		variable_changed.emit(name, null, scope)
		save_variables()

func rename_variable(old_name: String, new_name: String, scope = VariableScope.GLOBAL):
	# Convert numeric scope to enum if needed
	if scope is int:
		scope = VariableScope.GLOBAL if scope == 0 else VariableScope.LOCAL
	
	var variables = global_variables if scope == VariableScope.GLOBAL else local_variables
	if variables.has(old_name) and not variables.has(new_name):
		var var_data = variables[old_name]
		var_data.name = new_name
		variables[new_name] = var_data
		variables.erase(old_name)
		# Emit signal for both removal and addition
		variable_changed.emit(old_name, null, scope)  # Removal
		variable_changed.emit(new_name, var_data.value, scope)  # Addition
		save_variables()

func reset_all():
	global_variables.clear()
	local_variables.clear()
	save_variables()

func save_variables():
	var data = {
		"global_variables": global_variables,
		"local_variables": local_variables
	}
	
	var file = FileAccess.open(variables_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_variables():
	if not FileAccess.file_exists(variables_file_path):
		return
	
	var file = FileAccess.open(variables_file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			if data.has("global_variables"):
				global_variables = data.global_variables
			if data.has("local_variables"):
				local_variables = data.local_variables
