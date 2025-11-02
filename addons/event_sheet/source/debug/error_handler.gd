@tool
extends Node

static var error_count: int = 0
static var last_errors: Array = []

enum ErrorType {
	SCRIPT_NOT_FOUND,
	INVALID_PARAMETERS,
	EXECUTION_FAILED,
	NODE_NOT_FOUND,
	TYPE_MISMATCH,
	RUNTIME_ERROR
}

static func handle_error(error_type: ErrorType, message: String, context: Dictionary = {}):
	error_count += 1
	
	var error_data = {
		"type": error_type,
		"message": message,
		"context": context,
		"timestamp": Time.get_datetime_string_from_system(),
		"stack_trace": get_stack()
	}
	
	last_errors.append(error_data)
	if last_errors.size() > 50:
		last_errors = last_errors.slice(25)
	
	if EventSheetDebugger and EventSheetDebugger.has_method("log_error"):
		EventSheetDebugger.log_error(message, context.get("block_id", ""))
	
	match error_type:
		ErrorType.SCRIPT_NOT_FOUND:
			print_rich("[color=orange][EventSheet Warning][/color] Script not found: %s" % message)
		ErrorType.INVALID_PARAMETERS:
			print_rich("[color=yellow][EventSheet Warning][/color] Invalid parameters: %s" % message)
		ErrorType.EXECUTION_FAILED:
			print_rich("[color=red][EventSheet Error][/color] Execution failed: %s" % message)
		ErrorType.NODE_NOT_FOUND:
			print_rich("[color=orange][EventSheet Warning][/color] Node not found: %s" % message)
		ErrorType.TYPE_MISMATCH:
			print_rich("[color=yellow][EventSheet Warning][/color] Type mismatch: %s" % message)
		ErrorType.RUNTIME_ERROR:
			print_rich("[color=red][EventSheet Error][/color] Runtime error: %s" % message)

static func safe_execute(callable: Callable, error_context: Dictionary = {}) -> Variant:
	var result = null
	if callable.is_valid():
		result = callable.call()
	else:
		handle_error(ErrorType.EXECUTION_FAILED, "Invalid callable", error_context)
	return result

static func validate_parameters(params: Dictionary, required_keys: Array) -> bool:
	for key in required_keys:
		if not params.has(key):
			handle_error(ErrorType.INVALID_PARAMETERS, "Missing required parameter: " + key)
			return false
	return true

static func safe_node_access(node_path: NodePath, context: Node) -> Node:
	if not context:
		handle_error(ErrorType.NODE_NOT_FOUND, "Context node is null")
		return null
	
	if not context.has_node(node_path):
		handle_error(ErrorType.NODE_NOT_FOUND, "Node not found: " + str(node_path))
		return null
	
	return context.get_node(node_path)

static func get_error_summary() -> Dictionary:
	return {
		"total_errors": error_count,
		"recent_errors": last_errors.slice(-10) if last_errors.size() > 10 else last_errors
	}