@tool

static var function_contents: Dictionary = {
	"globals": [],
	"_init": { "params": [], "body": ["pass"] },
}

# Generating a script from the event table
static func generate_code(event_sheet_class: Variant) -> GDScript:
	event_sheet_class.result_script = ""
	function_contents = {
		"globals": [],
		"_init": {"params": [], "body": [
			"set_process_input(true)",
			"set_process_unhandled_input(true)",
			"set_physics_process(true)",
			"_ready()"
		]},
	}
	
	if ESUtils.current_scene:
		event_sheet_class.result_script += "extends {0}\n\n".format([str(ESUtils.current_scene.get_class())])
	else:
		event_sheet_class.result_script += "extends Node\n\n"
	
	if event_sheet_class.event_sheet_data.has("blocks"):
		for block in event_sheet_class.event_sheet_data.blocks:
			process_block(block)
	
	# Добавляем глобальные переменные
	for global_var in function_contents["globals"]:
		event_sheet_class.result_script += "{0}\n".format([global_var])
	
	# Добавляем содержимое всех функций в итоговый скрипт
	for func_name in function_contents.keys():
		if func_name == "globals":  # Пропускаем блок глобальных переменных
			continue
		
		var func_data = function_contents[func_name]
		var func_params = str(", ").join(func_data["params"])
		var func_body = func_data["body"]
		
		var func_content = "\nfunc {0}({1}):\n".format([func_name, func_params])
		for line in func_body:
			func_content += "\t{0}\n".format([line])
		event_sheet_class.result_script += func_content
	
	event_sheet_class.code_editor.text = event_sheet_class.result_script
	
	var _script = GDScript.new()
	_script.source_code = event_sheet_class.result_script
	
	return _script

# Processing each block
static func process_block(block: Dictionary, sub_block_index: int = 1, parent_func_name: String = "_init"):
	var func_name: String = parent_func_name
	var is_stipulation: bool
	
	var _spaces: String
	if func_name != "_init": 
		_spaces = "\t".repeat(sub_block_index - 2) if sub_block_index >= 2 else ""
	else: 
		_spaces = "\t".repeat(sub_block_index - 1) if sub_block_index >= 2 else ""
	
	if block.has("type") and block.type == "variable":
		if sub_block_index <= 1:
			var _var_template = "var {0} = {1}".format([block.parameters.variable_name, str(block.parameters.variable_value)]).strip_edges()
			if not function_contents["globals"].has(_var_template):
				function_contents["globals"].append(_var_template)
		else:
			var _var_template = _spaces + "var {0} = {1}".format([block.parameters.variable_name, str(block.parameters.variable_value)]).strip_edges()
			if not function_contents[parent_func_name]["body"].has(_var_template):
				function_contents[parent_func_name]["body"].append(_var_template)
	elif block.has("type") and block.type == "standart":
		for event: Dictionary in block.events:
			var _script = load(event.script)
			var _template: String = _script.get_template(event.parameters).strip_edges()
			
			if _template.begins_with("func"):
				var _split_template: PackedStringArray = _template.split(" ")
				func_name = _split_template[1].substr(0, _split_template[1].find("("))
				
				# Извлечение параметров функции
				var param_start = _template.find("(") + 1
				var param_end = _template.find(")")
				var func_params = _template.substr(param_start, param_end - param_start).split(", ")
				
				# Проверка на существование функции и создание списка, если функция новая
				if !function_contents.has(func_name):
					function_contents[func_name] = { "params": func_params, "body": [] }
				continue
			
			if _template.begins_with("if"):
				var _if_template: String = _spaces + "{0}".format([_template])
				
				if func_name.is_empty(): 
					func_name = "_init"
				
				if function_contents.has(func_name):
					function_contents[func_name]["body"].append(_if_template)
					sub_block_index += 1
				
				is_stipulation = true
		
		for action: Dictionary in block.actions:
			var _object_name: String
			if action.object and action.object.path != null and action.object.type != "System":
				var _object_node: Node = ESUtils.current_scene.get_node(action.object.path)
				var _object_path = '$"{0}"'.format([str(ESUtils.current_scene.get_path_to(_object_node))])
				_object_name = str(action.object.name).to_snake_case()
				
				# Проверяем, есть ли уже глобальная переменная с таким именем и другим _object_path
				var unique_name = _object_name
				var index = 1
				while true:
					var found = false
					for global_var in function_contents["globals"]:
						if global_var.begins_with("@onready var {0} =".format([unique_name])) and not global_var.ends_with(_object_path):
							found = true
							break
					if found:
						unique_name = "{0}_{1}".format([_object_name, index])
						index += 1
					else:
						break
				
				_object_name = unique_name
				var _var_template = "@onready var {0} = {1}".format([_object_name, str(_object_path)]).strip_edges()
				
				if not function_contents["globals"].has(_var_template):
					function_contents["globals"].append(_var_template)
			
			var _script = load(action.script)
			var _template: String = _script.get_template(action.parameters).strip_edges()
			var _split_template: PackedStringArray = _template.split("\n")
			
			var _action_spaces: String = _spaces + "\t" if is_stipulation else ""
			
			if block.events.is_empty() and sub_block_index > 1:
				_action_spaces += "\t"
			
			if func_name.is_empty(): 
				func_name = "_init"
			
			# Если функция существует, добавляем действие к её содержимому
			if function_contents.has(func_name):
				if _split_template.size() > 1:
					for line in _split_template:
						function_contents[func_name]["body"].append(_action_spaces + line.format({ "object": _object_name }))
				else:
					function_contents[func_name]["body"].append(_action_spaces + _template.format({ "object": _object_name }))
	
	if function_contents.has(func_name):
		if function_contents[func_name]["body"].size() == 0:
			function_contents[func_name]["body"].append("pass")
		else:
			function_contents[func_name]["body"].erase("pass")
	
	if block.has("childrens"):
		for sub_block in block.childrens:
			process_block(sub_block, sub_block_index + 1, func_name)
