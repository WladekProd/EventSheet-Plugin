extends Node

static var code_template: String = """
extends Node

func __init() -> void:
	{init}

func __ready() -> void:
	{ready}

func __process(delta: float) -> void:
	{process}

func __input(event: InputEvent) -> void:
	{input}

"""

# Generate GDScript from Event Sheet
static func generate_code(event_sheet: Array[BlockResource]) -> String:
	var final_code: String = "extends Node\n\n"
	var existing_functions: Dictionary = {}
	var last_function: String = "__init"
	
	for block in event_sheet:
		final_code += process_block(block, existing_functions, last_function)
	
	for func_name in existing_functions.keys():
		final_code += existing_functions[func_name] + "\n"
	
	return final_code

# Рекурсивная функция для обработки блока и его под-блоков
static func process_block(block: BlockResource, existing_functions: Dictionary, last_function: String, indent_level: int = 0) -> String:
	var final_code: String = ""
	var global_variables_lines: Array[String] = []
	var local_variables_lines: Array[String] = []
	var action_lines: Array[String] = []
	
	# Обрабатываем переменных
	for variable in block.variables:
		var variable_template: String = variable.call("get_template")
		if variable.variable_is_global: global_variables_lines.append(variable_template)
		else: local_variables_lines.append(variable_template)
		if !existing_functions.has("global_variables"):
			existing_functions["global_variables"] = ""
	
	# Обрабатываем действия блока
	for action in block.actions:
		if action.gd_script:
			var gd_script: GDScript = action.gd_script
			var instance = RefCounted.new()
			instance.set_script(gd_script)

			var parameters: Dictionary = action.parameters
			var gd_script_params: Dictionary = instance.get("params")
			var param_index = 0
			for key in gd_script_params:
				if parameters and parameters.size() > 0:
					if param_index <= parameters.size() - 1:
						gd_script_params[key] = parameters[param_index]
						param_index += 1

			var gd_script_template: String = instance.call("get_template").format(gd_script_params)
			action_lines.append(gd_script_template)
	
	# Обрабатываем события блока
	var event_index = 0
	for event in block.events:
		if event.gd_script:
			var gd_script: GDScript = event.gd_script
			var instance = RefCounted.new()
			instance.set_script(gd_script)

			var parameters: Dictionary = event.parameters
			var gd_script_params: Dictionary = instance.get("params")
			var param_index = 0
			for key in gd_script_params:
				if parameters and parameters.size() > 0:
					if param_index <= parameters.size() - 1:
						gd_script_params[key] = parameters[param_index]
						param_index += 1

			var gd_script_template: String = instance.call("get_template").strip_edges()
			var stripped_template: String = gd_script_template.replace("\t", "")
			var func_name: String = stripped_template.get_slice("(", 0).get_slice(" ", 1)

			# Проверка на наличие функции, условия и т.д.
			if stripped_template.begins_with("func"):
				if existing_functions.has(func_name):
					for action_line in action_lines:
						existing_functions[func_name] += "\t".repeat(indent_level + 1) + action_line + "\n"
				else:
					existing_functions[func_name] = "\t".repeat(indent_level) + gd_script_template.format(gd_script_params) + "\n"
					for action_line in action_lines:
						existing_functions[func_name] += "\t".repeat(indent_level + 1) + action_line + "\n"
				last_function = func_name
			else:
				if last_function == "__init":
					if existing_functions.has("__init"):
						var replace_action: String = ""
						existing_functions["__init"] += "\t".repeat(indent_level) + gd_script_template + "\n"
						for action_line in action_lines:
							if action_line: replace_action += "\t".repeat(indent_level + 1) + action_line + "\n"
						
						if block.sub_blocks.size() <= 0 and action_lines.size() <= 0:
							existing_functions["__init"] += "\t".repeat(indent_level + 1) + "pass" + "\n"
						else:
							existing_functions["__init"] += replace_action
					else:
						existing_functions["__init"] = "\t".repeat(indent_level) + "func __init() -> void:" + "\n"
						for action_line in action_lines:
							existing_functions["__init"] += "\t".repeat(indent_level + 1) + action_line + "\n"
				else:
					if existing_functions.has(last_function):
						var replace_action: String = ""
						
						existing_functions[last_function] += "\t".repeat(indent_level + event_index) + gd_script_template + "\n"
						
						for action_line in action_lines:
							if action_line:
								replace_action += "\t".repeat(indent_level + event_index) + action_line + "\n"
						
						# New System
						if block.sub_blocks.size() <= 0 and event_index >= block.events.size() - 1 and action_lines.size() <= 0:
							existing_functions[last_function] += "\t".repeat(indent_level + event_index + 1) + "pass" + "\n"
						else:
							existing_functions[last_function] += replace_action
						
						if block.sub_blocks.size() > 0 or block.events.size() > 0:
							event_index += 1
						
						# Old System
						#if block.sub_blocks.size() <= 0 and event_index >= block.events.size() - 1 and action_lines.size() <= 0:
							#existing_functions[last_function] += "\t".repeat(indent_level + event_index + 1) + "pass" + "\n"
						#else:
							#existing_functions[last_function] += replace_action

	# Generate Variables
	if block.events.size() <= 0 and block.actions.size() <= 0 and block.variables.size() > 0:
		var replace_global_vars: String = ""
		for var_line in global_variables_lines: if var_line: replace_global_vars += var_line + "\n"
		existing_functions["global_variables"] += replace_global_vars
		
		var replace_local_vars: String = ""
		for var_line in local_variables_lines: if var_line: replace_local_vars += "\t".repeat(indent_level) + var_line + "\n"
		if existing_functions.has(last_function):
			existing_functions[last_function] += replace_local_vars

	if block.events.size() <= 0 and block.actions.size() > 0:
		var replace_action: String = ""
		for action_line in action_lines: if action_line: replace_action = action_line
		existing_functions[last_function] += "\t".repeat(indent_level) + replace_action + "\n"
	
	# Обрабатываем подблоки рекурсивно
	for sub_block in block.sub_blocks:
		final_code += process_block(sub_block, existing_functions, last_function, indent_level + 1)
	
	return final_code
