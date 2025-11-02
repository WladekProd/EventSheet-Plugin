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
		"_init": {"params": [], "body": ["pass"]},
	}

	if ESUtils.current_scene:
		event_sheet_class.result_script += "extends {0}\n\n".format([str(ESUtils.current_scene.get_class())])
	else:
		event_sheet_class.result_script += "extends Node\n\n"

	if event_sheet_class.event_sheet_data.has("blocks"):
		for block in event_sheet_class.event_sheet_data.blocks:
			process_block(block)

	# Add local variables to _ready function
	if VariableManager:
		var local_vars = VariableManager.get_all_variables(1)  # LOCAL
		if not local_vars.is_empty():
			if not function_contents.has("_ready"):
				function_contents["_ready"] = {"params": [], "body": []}
			
			for var_name in local_vars:
				var var_data = local_vars[var_name]
				var var_line = "var {0} = {1}".format([var_name, _format_value(var_data.value)])
				function_contents["_ready"]["body"].insert(0, var_line)
	
	# Add processing setup to _ready if it exists, otherwise create it
	if function_contents.has("_ready"):
		if not function_contents["_ready"]["body"].has("set_process_input(true)"):
			function_contents["_ready"]["body"].append("set_process_input(true)")
			function_contents["_ready"]["body"].append("set_process_unhandled_input(true)")
			function_contents["_ready"]["body"].append("set_physics_process(true)")
	else:
		function_contents["_ready"] = {
			"params": [],
			"body": [
				"set_process_input(true)",
				"set_process_unhandled_input(true)",
				"set_physics_process(true)"
			]
		}
	
	# Ensure _process function exists if we have @onready variables
	if function_contents["globals"] and not function_contents.has("_process"):
		function_contents["_process"] = {
			"params": ["delta: float"],
			"body": ["pass"]
		}

	# Добавляем переменные из VariableManager
	if VariableManager:
		var global_vars = VariableManager.get_all_variables(0)  # GLOBAL
		for var_name in global_vars:
			var var_data = global_vars[var_name]
			var var_line = "var {0} = {1}".format([var_name, _format_value(var_data.value)])
			event_sheet_class.result_script += "{0}\n".format([var_line])
	
	# Добавляем глобальные переменные из блоков
	for global_var in function_contents["globals"]:
		event_sheet_class.result_script += "{0}\n".format([global_var])

	# Добавляем содержимое всех функций в итоговый скрипт
	for func_name in function_contents.keys():
		if func_name == "globals":  # Пропускаем блок глобальных переменных
			continue

		var func_data = function_contents[func_name]
		var func_params = str(", ").join(func_data["params"])
		var func_body = func_data["body"]

		var func_content = "\nfunc %s(%s):\n" % [func_name, func_params]
		if func_body.is_empty():
			func_content += "\tpass\n"
		else:
			for line in func_body:
				func_content += "\t{0}\n".format([line])
		event_sheet_class.result_script += func_content

	event_sheet_class.code_editor.text = event_sheet_class.result_script

	var _script = GDScript.new()
	_script.source_code = event_sheet_class.result_script
	return _script

# Format value for script generation
static func _format_value(value: Variant) -> String:
	match typeof(value):
		TYPE_STRING:
			return '"%s"' % value
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [value.x, value.y]
		_:
			return str(value)

# Process a block and generate code for it
static func process_block(block: Dictionary, sub_block_index: int = 0, parent_func_name: String = "", has_if_condition: bool = false):
	if block.is_empty():
		return
	
	var _spaces = ""
	for i in sub_block_index:
		_spaces += "\t"

	var func_name = parent_func_name

	if block.has("type") and block.type == "variable":
		if parent_func_name and function_contents.has(parent_func_name):
			var var_template = "var {0} = {1}".format([block.get("name", "variable"), block.get("value", "null")])
			if not function_contents[parent_func_name]["body"].has(var_template):
				function_contents[parent_func_name]["body"].append(var_template)
	elif block.has("type") and block.type == "standart":
		# Обработка событий
		if block.has("events"):
			for event: Dictionary in block.events:
				if event.has("script") and ResourceLoader.exists(event.script):
					var _script = load(event.script)
					if _script and _script.has_method("get_template"):
						var _template: String = _script.get_template(event.get("parameters", {})).strip_edges()
						
						if _template.begins_with("func"):
							var _split_template: PackedStringArray = _template.split(" ")
							if _split_template.size() > 1:
								func_name = _split_template[1].substr(0, _split_template[1].find("("))
								# Извлечение параметров функции
								var param_start = _template.find("(") + 1
								var param_end = _template.find(")")
								var func_params = _template.substr(param_start, param_end - param_start).split(", ")
								# Проверка на существование функции
								if !function_contents.has(func_name):
									function_contents[func_name] = { "params": func_params, "body": [] }
						elif _template.begins_with("if"):
							var _if_template: String = _spaces + _template + ":"
							if func_name.is_empty():
								func_name = "_process"
								if !function_contents.has(func_name):
									function_contents[func_name] = { "params": ["delta: float"], "body": [] }
							# Проверяем, что такого условия еще нет
							var condition_exists = false
							for existing_line in function_contents[func_name]["body"]:
								if existing_line.strip_edges() == _if_template.strip_edges():
									condition_exists = true
									break
							if not condition_exists:
								function_contents[func_name]["body"].append(_if_template)
							has_if_condition = true

		# Обработка действий
		if block.has("actions"):
			for action: Dictionary in block.actions:
				var _object_name: String = ""
				
				# Обработка объектов (Node2D, Sprite2D и т.д.)
				if action.has("object") and action.object.has("path") and action.object.path != null and action.object.get("type", "") != "System":
					if ESUtils.current_scene and ESUtils.current_scene.has_node(action.object.path):
						var _object_node: Node = ESUtils.current_scene.get_node(action.object.path)
						var _object_path = '$"{0}"'.format([str(ESUtils.current_scene.get_path_to(_object_node))])
						_object_name = str(action.object.name).to_snake_case()

						# Создаем уникальное имя переменной
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
						var _var_template = "@onready var {0} = {1}".format([_object_name, str(_object_path)])

						if not function_contents["globals"].has(_var_template):
							function_contents["globals"].append(_var_template)

				# Обработка скрипта действия
				if action.has("script") and ResourceLoader.exists(action.script):
					var _script = load(action.script)
					if _script and _script.has_method("get_template"):
						var _template: String = _script.get_template(action.get("parameters", {})).strip_edges()
						var _split_template: PackedStringArray = _template.split("\n")

						# Определяем отступы и функцию
						var _action_spaces: String = _spaces
						if has_if_condition:
							_action_spaces += "\t"

						if func_name.is_empty():
							func_name = "_ready"
							if !function_contents.has(func_name):
								function_contents[func_name] = { "params": [], "body": [] }

						# Добавляем проверку для @onready переменных
						if _object_name and func_name != "_ready":
							function_contents[func_name]["body"].append(_action_spaces + "if {0}:".format([_object_name]))
							_action_spaces += "\t"
						
						# Добавляем код действия
						if _split_template.size() > 1:
							for line in _split_template:
								if line.strip_edges():
									function_contents[func_name]["body"].append(_action_spaces + line.format({ "object": _object_name }))
						else:
							function_contents[func_name]["body"].append(_action_spaces + _template.format({ "object": _object_name }))

	# Убеждаемся, что у всех функций есть тело
	for func_key in function_contents.keys():
		if func_key != "globals" and function_contents[func_key]["body"].size() == 0:
			function_contents[func_key]["body"].append("pass")

	if block.has("childrens"):
		for sub_block in block.childrens:
			process_block(sub_block, sub_block_index + (1 if has_if_condition else 0) + 1, func_name, has_if_condition)
