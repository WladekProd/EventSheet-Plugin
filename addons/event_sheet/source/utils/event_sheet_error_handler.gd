@tool
extends RefCounted
class_name EventSheetErrorHandler

enum ErrorType {
	INVALID_PARAMETERS,
	SCRIPT_NOT_FOUND,
	EXECUTION_ERROR,
	UNKNOWN
}

static func handle_error(error_type: ErrorType, message: String, context: Dictionary = {}):
	var error_text = "[EventSheet Error] %s: %s" % [ErrorType.keys()[error_type], message]
	if not context.is_empty():
		error_text += " Context: %s" % str(context)
	
	print_rich("[color=red]%s[/color]" % error_text)
	
	# Log to debugger if available
	if EventSheetDebugger:
		EventSheetDebugger.log_error(message, context.get("block_id", ""))

static func safe_execute(callable: Callable) -> Variant:
	var result = null
	# Simple error handling without try/catch
	if callable.is_valid():
		result = callable.call()
	else:
		handle_error(ErrorType.EXECUTION_ERROR, "Invalid callable")
	return result