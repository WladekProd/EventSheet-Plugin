@tool
extends Node

# Менеджер таймеров для EventSheet
static var instance: TimerManager
static var timer_signals: Dictionary = {}

func _ready():
	instance = self

# Подключение к сигналу таймера
static func connect_timer_signal(timer_node: Timer, block: Dictionary, context: Node):
	if not timer_node or not timer_node.timeout.is_connected(_on_timer_timeout):
		var timer_id = str(timer_node.get_instance_id())
		timer_signals[timer_id] = {
			"block": block,
			"context": context
		}
		timer_node.timeout.connect(_on_timer_timeout.bind(timer_id, timer_node))
		print("TimerManager: Подключен таймер ", timer_id)

# Обработка сигнала таймера
static func _on_timer_timeout(timer_id: String, timer_node: Timer):
	if timer_signals.has(timer_id):
		var timer_data = timer_signals[timer_id]
		print("TimerManager: Таймер ", timer_id, " сработал")
		EventSheetRuntime.execute_block_actions(timer_data.block, timer_data.context)
		
		# Если таймер one_shot, удаляем из списка
		if timer_node.one_shot:
			timer_signals.erase(timer_id)

# Очистка всех подключений
static func clear_all_connections():
	timer_signals.clear()