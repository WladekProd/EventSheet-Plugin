@tool
extends Node
class_name EventSheetRuntime

const EventSheetErrorHandler = preload("res://addons/event_sheet/source/utils/event_sheet_error_handler.gd")

static var instance: EventSheetRuntime
static var variables: Dictionary = {}
static var conditions_cache: Dictionary = {}
static var actions_cache: Dictionary = {}

signal condition_executed(condition_name: String, result: bool)
signal action_executed(action_name: String)

func _ready():
	instance = self

# Выполнение блока событий
static func execute_block(block_data: Dictionary, context: Node = null) -> bool:
	# Пропускаем пустые блоки
	if block_data.is_empty():
		return false
	
	# Проверяем наличие событий и действий
	var events = block_data.get("events", [])
	var actions = block_data.get("actions", [])
	
	# Если нет ни событий, ни действий - пропускаем
	if events.is_empty() and actions.is_empty():
		return false
	
	var block_id = block_data.get("uuid", "unknown")
	EventSheetDebugger.debug_block_start(block_id, block_data)
	
	var all_conditions_met = true
	
	# Проверяем все события
	for event in events:
		var condition_result = execute_condition(event, context)
		EventSheetDebugger.debug_condition(event.get("uuid", ""), event, condition_result)
		if not condition_result:
			all_conditions_met = false
			break
	
	# Если все условия выполнены или нет событий, выполняем действия
	if (all_conditions_met and not events.is_empty()) or (events.is_empty() and not actions.is_empty()):
		for action in actions:
			execute_action(action, context)
			EventSheetDebugger.debug_action(action.get("uuid", ""), action)
	
	EventSheetDebugger.debug_block_end(block_id)
	return (all_conditions_met and not events.is_empty()) or (events.is_empty() and not actions.is_empty())

# Выполнение условия
static func execute_condition(condition_data: Dictionary, context: Node = null) -> bool:
	if not condition_data.has("script"):
		EventSheetErrorHandler.handle_error(EventSheetErrorHandler.ErrorType.INVALID_PARAMETERS, "Condition missing script", {"condition": condition_data})
		return false
	
	var script_path = condition_data.script
	
	if not conditions_cache.has(script_path):
		if ResourceLoader.exists(script_path):
			conditions_cache[script_path] = load(script_path)
		else:
			EventSheetErrorHandler.handle_error(EventSheetErrorHandler.ErrorType.SCRIPT_NOT_FOUND, "Script not found: " + script_path)
			return false
	
	var condition_script = conditions_cache[script_path]
	if not condition_script or not condition_script.has_method("execute"):
		return evaluate_condition_fallback(condition_data, context)
	
	var result = EventSheetErrorHandler.safe_execute(func(): return condition_script.execute(condition_data.get("parameters", {}), context))
	if result == null:
		return false
	
	if instance:
		instance.condition_executed.emit(condition_data.get("name", "Unknown"), result)
	
	return result

# Выполнение действия
static func execute_action(action_data: Dictionary, context: Node = null):
	if not action_data.has("script"):
		EventSheetErrorHandler.handle_error(EventSheetErrorHandler.ErrorType.INVALID_PARAMETERS, "Action missing script", {"action": action_data})
		return
	
	var script_path = action_data.script
	
	if not actions_cache.has(script_path):
		if ResourceLoader.exists(script_path):
			actions_cache[script_path] = load(script_path)
		else:
			EventSheetErrorHandler.handle_error(EventSheetErrorHandler.ErrorType.SCRIPT_NOT_FOUND, "Script not found: " + script_path)
			return
	
	var action_script = actions_cache[script_path]
	if not action_script or not action_script.has_method("execute"):
		execute_action_fallback(action_data, context)
		return
	
	EventSheetErrorHandler.safe_execute(func(): action_script.execute(action_data.get("parameters", {}), context))
	
	if instance:
		instance.action_executed.emit(action_data.get("name", "Unknown"))

# Резервное выполнение условий
static func evaluate_condition_fallback(condition_data: Dictionary, context: Node = null) -> bool:
	if not condition_data.has("script"):
		return false
	
	var script_path = condition_data.script
	if not ResourceLoader.exists(script_path):
		return false
	
	var script = load(script_path)
	if not script.has_method("get_template"):
		return false
	
	var template = script.get_template(condition_data.get("parameters", {}))
	return evaluate_expression(template, context)

# Резервное выполнение действий
static func execute_action_fallback(action_data: Dictionary, context: Node = null):
	if not action_data.has("script"):
		return
	
	var script_path = action_data.script
	if not ResourceLoader.exists(script_path):
		return
	
	var script = load(script_path)
	if not script.has_method("get_template"):
		return
	
	var template = script.get_template(action_data.get("parameters", {}))
	execute_code(template, context)

# Выполнение кода
static func execute_code(code: String, context: Node = null):
	if not context:
		return
	
	var expression = Expression.new()
	var error = expression.parse(code)
	if error != OK:
		print("EventSheet Runtime Error: ", expression.get_error_text())
		return
	
	expression.execute([], context)

# Оценка выражения
static func evaluate_expression(expression_text: String, context: Node = null) -> bool:
	if not context:
		return false
	
	var expression = Expression.new()
	var error = expression.parse(expression_text)
	if error != OK:
		return false
	
	var result = expression.execute([], context)
	return bool(result)

# Управление переменными
static func set_variable(name: String, value: Variant):
	variables[name] = value

static func get_variable(name: String, default_value: Variant = null) -> Variant:
	return variables.get(name, default_value)

static func has_variable(name: String) -> bool:
	return variables.has(name)

static func clear_cache():
	conditions_cache.clear()
	actions_cache.clear()