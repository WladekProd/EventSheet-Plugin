@tool
extends RefCounted

static func compile_to_gdscript(event_sheet_data: Dictionary) -> GDScript:
	var script = GDScript.new()
	var code = generate_script_code(event_sheet_data)
	script.source_code = code
	script.reload()
	return script

static func generate_script_code(data: Dictionary) -> String:
	var code_lines = []
	
	code_lines.append("@tool")
	code_lines.append("extends Node2D")
	code_lines.append("")
	
	# Добавляем типизированные переменные
	_add_typed_variables(code_lines, data)
	
	# Добавляем методы жизненного цикла
	_add_lifecycle_methods(code_lines, data)
	
	return "\n".join(code_lines)

static func _add_typed_variables(code_lines: Array, data: Dictionary):
	code_lines.append("# Типизированные переменные")
	
	var variables = _extract_variables(data)
	for var_name in variables:
		var var_data = variables[var_name]
		var type_hint = _get_type_hint(var_data.type)
		var default_value = _get_default_value(var_data.type)
		code_lines.append("var %s: %s = %s" % [var_name, type_hint, default_value])
	
	code_lines.append("")

static func _add_lifecycle_methods(code_lines: Array, data: Dictionary):
	var blocks = data.get("blocks", [])
	
	var ready_blocks = []
	var process_blocks = []
	
	for block in blocks:
		var events = block.get("events", [])
		var has_condition = false
		
		for event in events:
			var event_name = event.get("name", "")
			if event_name == "Ready":
				ready_blocks.append(block)
			elif event_name in ["Every tick", "Process"]:
				process_blocks.append(block)
			elif event_name == "Compare two values":
				has_condition = true
		
		# Если есть условие сравнения, добавляем в process
		if has_condition and block not in process_blocks:
			process_blocks.append(block)
	
	# Генерируем _ready
	if ready_blocks.size() > 0:
		var has_await = _check_for_await(ready_blocks)
		if has_await:
			code_lines.append("func _ready():")
			_compile_async_blocks(code_lines, ready_blocks, 1)
		else:
			code_lines.append("func _ready():")
			for block in ready_blocks:
				_compile_block(code_lines, block, 1)
		code_lines.append("")
	
	# Генерируем _process
	if process_blocks.size() > 0:
		code_lines.append("func _process(delta: float):")
		for block in process_blocks:
			_compile_block(code_lines, block, 1)
		code_lines.append("")

static func _compile_block(code_lines: Array, block: Dictionary, indent: int):
	var events = block.get("events", [])
	var actions = block.get("actions", [])
	var indent_str = ""
	for i in indent:
		indent_str += "\t"
	
	# Компилируем условия
	if events.size() > 0:
		var condition_code = _compile_conditions(events)
		if condition_code != "" and condition_code != "true":
			code_lines.append("%sif %s:" % [indent_str, condition_code])
			indent += 1
			indent_str = ""
			for i in indent:
				indent_str += "\t"
	
	# Компилируем действия
	if actions.size() > 0:
		for action in actions:
			var action_code = _compile_action(action)
			if action_code != "":
				code_lines.append("%s%s" % [indent_str, action_code])
	else:
		# Если нет действий, добавляем pass
		code_lines.append("%spass" % indent_str)

static func _compile_conditions(events: Array) -> String:
	var conditions = []
	
	for event in events:
		var condition = _compile_condition(event)
		if condition != "" and condition != "true":
			conditions.append(condition)
	
	if conditions.size() == 0:
		return "true"
	elif conditions.size() == 1:
		return conditions[0]
	else:
		return "(" + ") and (".join(conditions) + ")"

static func _compile_condition(event: Dictionary) -> String:
	var script_path = event.get("script", "")
	var params = event.get("parameters", {})
	
	if script_path.is_empty():
		print("Warning: Empty script path in condition")
		return ""
	
	if not ResourceLoader.exists(script_path):
		print("Warning: Script not found: ", script_path)
		return ""
	
	var script = load(script_path)
	if not script:
		print("Warning: Failed to load script: ", script_path)
		return ""
	
	if not script.has_method("get_template"):
		print("Warning: Script missing get_template method: ", script_path)
		return ""
	
	var converted_params = _convert_params_to_typed(params)
	return script.get_template(converted_params)

static func _compile_action(action: Dictionary) -> String:
	var script_path = action.get("script", "")
	var params = action.get("parameters", {})
	
	if script_path.is_empty():
		print("Warning: Empty script path in action")
		return ""
	
	if not ResourceLoader.exists(script_path):
		print("Warning: Script not found: ", script_path)
		return ""
	
	var script = load(script_path)
	if not script:
		print("Warning: Failed to load script: ", script_path)
		return ""
	
	if not script.has_method("get_template"):
		print("Warning: Script missing get_template method: ", script_path)
		return ""
	
	var converted_params = _convert_params_to_typed(params)
	return script.get_template(converted_params)

static func _convert_params_to_typed(params: Dictionary) -> Dictionary:
	var typed_params = {}
	
	for key in params:
		var param = params[key]
		var value = param.get("value", "")
		var type_name = param.get("type", {}).get("name", "string")
		
		typed_params[key] = {
			"value": _convert_to_typed_value(value, type_name),
			"type": type_name
		}
	
	return typed_params

static func _convert_to_typed_value(value, type_name: String):
	match type_name:
		"float", "number":
			if value is String and value.is_valid_float():
				return float(value)
			elif value is float or value is int:
				return float(value)
			return 0.0
		"boolean":
			if value is String:
				return value.to_lower() in ["true", "1"]
			return bool(value)
		"vector2":
			if value is String:
				var parts = value.split(",")
				if parts.size() >= 2:
					return Vector2(float(parts[0]), float(parts[1]))
			return Vector2.ZERO
		_:
			return str(value)

static func _extract_variables(data: Dictionary) -> Dictionary:
	var variables = {}
	var blocks = data.get("blocks", [])
	
	for block in blocks:
		var actions = block.get("actions", [])
		for action in actions:
			if action.get("name", "") == "Set variable":
				var params = action.get("parameters", {})
				var var_name = params.get("variable", {}).get("value", "")
				var var_value = params.get("value", {}).get("value", "")
				
				if var_name != "":
					variables[var_name] = {
						"type": _detect_type(var_value),
						"value": var_value
					}
	
	return variables

static func _detect_type(value: String) -> String:
	if value.is_valid_float():
		return "number"
	elif value.to_lower() in ["true", "false"]:
		return "boolean"
	elif "," in value:
		return "vector2"
	else:
		return "string"

static func _get_type_hint(type_name: String) -> String:
	match type_name:
		"number": return "float"
		"boolean": return "bool"
		"vector2": return "Vector2"
		_: return "String"

static func _get_default_value(type_name: String) -> String:
	match type_name:
		"number": return "0.0"
		"boolean": return "false"
		"vector2": return "Vector2.ZERO"
		_: return '""'

static func _check_for_await(blocks: Array) -> bool:
	for block in blocks:
		var events = block.get("events", [])
		for event in events:
			if event.get("name", "") == "Wait":
				return true
	return false

static func _compile_async_blocks(code_lines: Array, blocks: Array, indent: int):
	var indent_str = ""
	for i in indent:
		indent_str += "\t"
	
	for block in blocks:
		var events = block.get("events", [])
		var actions = block.get("actions", [])
		
		# Проверяем на wait событие
		var wait_event = null
		for event in events:
			if event.get("name", "") == "Wait":
				wait_event = event
				break
		
		if wait_event:
			# Генерируем await
			var wait_code = _compile_condition(wait_event)
			code_lines.append("%s%s" % [indent_str, wait_code])
			
			# Генерируем действия
			for action in actions:
				var action_code = _compile_action(action)
				if action_code != "":
					code_lines.append("%s%s" % [indent_str, action_code])
		else:
			# Обычный блок
			_compile_block(code_lines, block, indent)