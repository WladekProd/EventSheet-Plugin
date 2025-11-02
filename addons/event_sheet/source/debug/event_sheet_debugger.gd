@tool
extends Node

var breakpoints: Dictionary = {}
var call_stack: Array = []
var execution_log: Array = []
var is_debugging: bool = false

signal breakpoint_hit(block_id: String)
signal execution_step(block_id: String, action: String)
signal error_occurred(error_msg: String, block_id: String)

enum DebugLevel {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

func set_breakpoint(block_id: String, enabled: bool = true):
	breakpoints[block_id] = enabled

func check_breakpoint(block_id: String) -> bool:
	return breakpoints.get(block_id, false)

func debug_block_start(block_id: String, block_data: Dictionary):
	if not is_debugging:
		return

	call_stack.push_back({
		"block_id": block_id,
		"type": block_data.get("type", "unknown"),
		"timestamp": Time.get_unix_time_from_system()
	})

	log_execution("Block started: " + block_id, DebugLevel.INFO)

	if check_breakpoint(block_id):
		breakpoint_hit.emit(block_id)

func debug_block_end(block_id: String):
	if not is_debugging:
		return

	if call_stack.size() > 0:
		call_stack.pop_back()

	log_execution("Block ended: " + block_id, DebugLevel.INFO)

func debug_condition(condition_id: String, condition_data: Dictionary, result: bool):
	if not is_debugging:
		return

	var msg = "Condition '%s': %s" % [condition_data.get("name", "Unknown"), "TRUE" if result else "FALSE"]
	log_execution(msg, DebugLevel.INFO)

	execution_step.emit(condition_id, msg)

func debug_action(action_id: String, action_data: Dictionary):
	if not is_debugging:
		return

	var msg = "Action '%s' executed" % action_data.get("name", "Unknown")
	log_execution(msg, DebugLevel.INFO)

	execution_step.emit(action_id, msg)

func log_error(error_msg: String, block_id: String = ""):
	var log_entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"level": DebugLevel.ERROR,
		"message": error_msg,
		"block_id": block_id,
		"call_stack": call_stack.duplicate()
	}

	execution_log.append(log_entry)

	if execution_log.size() > 1000:
		execution_log = execution_log.slice(500)

	print_rich("[color=red][EventSheet Error][/color] %s" % error_msg)

	error_occurred.emit(error_msg, block_id)

func log_execution(message: String, level: DebugLevel = DebugLevel.INFO):
	if not is_debugging:
		return

	var log_entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"level": level,
		"message": message,
		"call_stack": call_stack.duplicate()
	}

	execution_log.append(log_entry)

	if execution_log.size() > 1000:
		execution_log = execution_log.slice(500)

func get_execution_log() -> Array:
	return execution_log

func clear_debug_data():
	execution_log.clear()
	call_stack.clear()

func set_debugging(enabled: bool):
	is_debugging = enabled
	if not enabled:
		clear_debug_data()
