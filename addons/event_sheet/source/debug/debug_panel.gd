@tool
extends VBoxContainer

var debug_toggle: Button
var clear_log: Button
var log_list: ItemList

func _ready():
	EventSheetDebugger.execution_step.connect(_on_execution_step)
	EventSheetDebugger.error_occurred.connect(_on_error_occurred)
	EventSheetDebugger.breakpoint_hit.connect(_on_breakpoint_hit)

	_setup_ui()

func _setup_ui():
	# Создаем простой интерфейс программно
	var toolbar = HBoxContainer.new()
	
	debug_toggle = Button.new()
	debug_toggle.text = "Enable Debug"
	debug_toggle.toggle_mode = true
	debug_toggle.toggled.connect(_on_debug_toggled)
	toolbar.add_child(debug_toggle)
	
	clear_log = Button.new()
	clear_log.text = "Clear Log"
	clear_log.pressed.connect(_on_clear_log)
	toolbar.add_child(clear_log)
	
	add_child(toolbar)
	
	log_list = ItemList.new()
	log_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(log_list)

func _on_debug_toggled(enabled: bool):
	if EventSheetDebugger:
		EventSheetDebugger.set_debugging(enabled)
		debug_toggle.text = "Disable Debug" if enabled else "Enable Debug"

func _on_clear_log():
	if EventSheetDebugger:
		EventSheetDebugger.clear_debug_data()
		_update_log()



func _on_execution_step(block_id: String, action: String):
	if log_list:
		log_list.add_item("[%s] %s: %s" % [Time.get_datetime_string_from_system(), block_id, action])
		log_list.scroll_to_item(log_list.get_item_count() - 1)

func _on_error_occurred(error_msg: String, block_id: String):
	if log_list:
		log_list.add_item("[ERROR] %s: %s" % [block_id, error_msg])
		log_list.scroll_to_item(log_list.get_item_count() - 1)

func _on_breakpoint_hit(block_id: String):
	if log_list:
		log_list.add_item("[BREAKPOINT] Hit breakpoint at: %s" % block_id)
		log_list.scroll_to_item(log_list.get_item_count() - 1)

func _update_log():
	if not log_list or not EventSheetDebugger:
		return
	
	log_list.clear()
	var logs = EventSheetDebugger.get_execution_log()
	for log_entry in logs:
		var level_text = ""
		match log_entry.level:
			2: # ERROR
				level_text = "[ERROR]"
			1: # WARNING
				level_text = "[WARN]"
			_:
				level_text = "[INFO]"
		
		log_list.add_item("%s %s %s" % [log_entry.timestamp, level_text, log_entry.message])
