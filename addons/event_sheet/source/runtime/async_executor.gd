@tool
extends RefCounted

# Асинхронный исполнитель для EventSheet
static var active_timers: Dictionary = {}
static var timer_counter: int = 0

# Выполнение блока с ожиданием
static func execute_wait_block(block: Dictionary, context: Node) -> void:
	var wait_time = 1.0
	var timer_id = "timer_" + str(timer_counter)
	timer_counter += 1
	
	# Получаем время ожидания
	for event in block.get("events", []):
		if event.get("name") == "Wait":
			var seconds_param = event.get("parameters", {}).get("seconds", {})
			wait_time = float(seconds_param.get("value", "1.0"))
			break
	
	print("AsyncExecutor: Запуск таймера ", timer_id, " на ", wait_time, " сек")
	
	# Создаем таймер
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	context.add_child(timer)
	
	# Сохраняем в активных таймерах
	active_timers[timer_id] = {
		"timer": timer,
		"block": block,
		"context": context
	}
	
	# Подключаем сигнал
	timer.timeout.connect(_on_timer_timeout.bind(timer_id))
	timer.start()

# Обработка завершения таймера
static func _on_timer_timeout(timer_id: String):
	if not active_timers.has(timer_id):
		return
	
	var timer_data = active_timers[timer_id]
	var timer = timer_data.timer
	var block = timer_data.block
	var context = timer_data.context
	
	print("AsyncExecutor: Таймер ", timer_id, " завершен, выполнение действий")
	
	# Выполняем действия блока
	EventSheetRuntime.execute_block_actions(block, context)
	
	# Очищаем таймер
	timer.queue_free()
	active_timers.erase(timer_id)

# Очистка всех таймеров
static func clear_all_timers():
	for timer_id in active_timers.keys():
		var timer_data = active_timers[timer_id]
		timer_data.timer.queue_free()
	active_timers.clear()
	timer_counter = 0