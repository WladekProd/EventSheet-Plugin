@tool
extends VBoxContainer

var search_field: LineEdit
var variables_list: ItemList
var add_button: Button
var delete_button: Button
var scope_filter: OptionButton
var selected_variable: String = ""

func _ready():
	_setup_ui()
	_connect_signals()
	_refresh_variables()

func _connect_signals():
	if VariableManager and not VariableManager.variable_changed.is_connected(_on_variable_changed):
		VariableManager.variable_changed.connect(_on_variable_changed)

func _on_variable_changed(name: String, value: Variant, scope):
	_refresh_variables()

func _setup_ui():
	var title = Label.new()
	title.text = "Variables"
	add_child(title)
	
	search_field = LineEdit.new()
	search_field.placeholder_text = "Search variables..."
	search_field.text_changed.connect(_refresh_variables)
	add_child(search_field)
	
	scope_filter = OptionButton.new()
	scope_filter.add_item("All")
	scope_filter.add_item("Global") 
	scope_filter.add_item("Local")
	scope_filter.item_selected.connect(_refresh_variables)
	add_child(scope_filter)
	
	variables_list = ItemList.new()
	variables_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	variables_list.item_selected.connect(_on_variable_selected)
	variables_list.item_activated.connect(_on_variable_edit)
	add_child(variables_list)
	
	var buttons = HBoxContainer.new()
	
	add_button = Button.new()
	add_button.text = "Add"
	add_button.pressed.connect(_on_add_variable)
	buttons.add_child(add_button)
	
	var edit_button = Button.new()
	edit_button.text = "Edit"
	edit_button.pressed.connect(_on_edit_selected)
	buttons.add_child(edit_button)
	
	delete_button = Button.new()
	delete_button.text = "Delete"
	delete_button.disabled = true
	delete_button.pressed.connect(_on_delete_variable)
	buttons.add_child(delete_button)
	
	add_child(buttons)

func _refresh_variables(arg = null):
	if not variables_list:
		return
	
	variables_list.clear()
	var search_text = search_field.text.to_lower() if search_field else ""
	var scope_index = scope_filter.selected if scope_filter else 0
	
	if scope_index == 0 or scope_index == 1:
		if not VariableManager:
			return
		var global_vars = VariableManager.get_all_variables(0) # GLOBAL
		for var_name in global_vars:
			if search_text.is_empty() or var_name.to_lower().contains(search_text):
				var var_data = global_vars[var_name]
				var display_text = "%s = %s (Global)" % [var_name, str(var_data.value)]
				variables_list.add_item(display_text)
				variables_list.set_item_metadata(variables_list.get_item_count() - 1, {
					"name": var_name,
					"scope": 0 # GLOBAL
				})
	
	if scope_index == 0 or scope_index == 2:
		if not VariableManager:
			return
		var local_vars = VariableManager.get_all_variables(1) # LOCAL
		for var_name in local_vars:
			if search_text.is_empty() or var_name.to_lower().contains(search_text):
				var var_data = local_vars[var_name]
				var display_text = "%s = %s (Local)" % [var_name, str(var_data.value)]
				variables_list.add_item(display_text)
				variables_list.set_item_metadata(variables_list.get_item_count() - 1, {
					"name": var_name,
					"scope": 1 # LOCAL
				})

func _on_variable_selected(index: int):
	if index >= 0:
		var metadata = variables_list.get_item_metadata(index)
		selected_variable = metadata.name
		delete_button.disabled = false

func _on_variable_edit(index: int):
	if index >= 0:
		var metadata = variables_list.get_item_metadata(index)
		_edit_variable(metadata)

func _on_edit_selected():
	var selected_items = variables_list.get_selected_items()
	if selected_items.size() > 0:
		var metadata = variables_list.get_item_metadata(selected_items[0])
		_edit_variable(metadata)

func _edit_variable(metadata: Dictionary):
	var current_value = VariableManager.get_variable(metadata.name, metadata.scope)
	
	# Создаем простое окно редактирования
	var edit_window = Window.new()
	edit_window.title = "Edit Variable: " + metadata.name
	edit_window.size = Vector2i(320, 240)
	edit_window.unresizable = true
	
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Поле ввода названия
	var name_label = Label.new()
	name_label.text = "Variable name:"
	vbox.add_child(name_label)
	
	var name_input = LineEdit.new()
	name_input.text = metadata.name
	vbox.add_child(name_input)
	
	# Поле ввода значения
	var value_label = Label.new()
	value_label.text = "Variable value:"
	vbox.add_child(value_label)
	
	var value_input = LineEdit.new()
	value_input.text = str(current_value)
	vbox.add_child(value_input)
	
	# Кнопки
	var buttons_container = HBoxContainer.new()
	
	var ok_button = Button.new()
	ok_button.text = "OK"
	ok_button.pressed.connect(func():
		var new_name = name_input.text.strip_edges()
		var new_value = value_input.text.strip_edges()
		
		if new_name.is_empty():
			return
		
		# Автоопределение типа
		if new_value.is_valid_float():
			new_value = float(new_value)
		elif new_value.to_lower() in ["true", "false"]:
			new_value = new_value.to_lower() == "true"
		
		# Если имя изменилось, переименовываем переменную
		if new_name != metadata.name:
			VariableManager.rename_variable(metadata.name, new_name, metadata.scope)
		
		# Обновляем значение
		VariableManager.set_variable(new_name, new_value, metadata.scope)
		_refresh_variables()
		edit_window.queue_free()
	)
	buttons_container.add_child(ok_button)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(func(): edit_window.queue_free())
	buttons_container.add_child(cancel_button)
	
	vbox.add_child(buttons_container)
	
	margin.add_child(vbox)
	edit_window.add_child(margin)
	
	# Check if window already has a parent before adding to root
	if not edit_window.get_parent():
		get_tree().root.add_child(edit_window)
	edit_window.popup_centered()
	
	# Обработка закрытия окна
	edit_window.close_requested.connect(func(): edit_window.queue_free())
	
	# Фокус на поле ввода после небольшой задержки
	get_tree().process_frame.connect(func(): value_input.grab_focus(), CONNECT_ONE_SHOT)

func _on_add_variable():
	# Создаем окно добавления переменной
	var add_window = Window.new()
	add_window.title = "Add Variable"
	add_window.size = Vector2i(320, 280)
	add_window.unresizable = true
	
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Имя переменной
	var name_label = Label.new()
	name_label.text = "Variable name:"
	vbox.add_child(name_label)
	
	var name_input = LineEdit.new()
	name_input.placeholder_text = "variable_name"
	vbox.add_child(name_input)
	
	# Значение
	var value_label = Label.new()
	value_label.text = "Initial value:"
	vbox.add_child(value_label)
	
	var value_input = LineEdit.new()
	value_input.placeholder_text = "0"
	vbox.add_child(value_input)
	
	# Область видимости
	var scope_label = Label.new()
	scope_label.text = "Scope:"
	vbox.add_child(scope_label)
	
	var scope_option = OptionButton.new()
	scope_option.add_item("Global")
	scope_option.add_item("Local")
	vbox.add_child(scope_option)
	
	# Кнопки
	var buttons_container = HBoxContainer.new()
	
	var ok_button = Button.new()
	ok_button.text = "Add"
	ok_button.pressed.connect(func():
		var var_name = name_input.text.strip_edges()
		var var_value = value_input.text.strip_edges()
		var var_scope = 0 if scope_option.selected == 0 else 1 # GLOBAL : LOCAL
		
		# Debug output removed for production
		
		if not var_name.is_empty():
			if var_value.is_empty():
				var_value = ""
			
			# Автоопределение типа - строки остаются строками
			if var_value.is_valid_float():
				var_value = float(var_value)
			elif var_value.to_lower() in ["true", "false"]:
				var_value = var_value.to_lower() == "true"
			# Иначе оставляем как строку
			
			VariableManager.set_variable(var_name, var_value, var_scope)
			_refresh_variables()
		
		add_window.queue_free()
	)
	buttons_container.add_child(ok_button)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(func(): add_window.queue_free())
	buttons_container.add_child(cancel_button)
	
	vbox.add_child(buttons_container)
	
	margin.add_child(vbox)
	add_window.add_child(margin)
	
	# Check if window already has a parent before adding to root
	if not add_window.get_parent():
		get_tree().root.add_child(add_window)
	add_window.popup_centered()
	
	# Обработка закрытия окна
	add_window.close_requested.connect(func(): add_window.queue_free())
	
	# Фокус на поле имени после небольшой задержки
	get_tree().process_frame.connect(func(): name_input.grab_focus(), CONNECT_ONE_SHOT)

func _on_delete_variable():
	if not selected_variable.is_empty():
		var selected_items = variables_list.get_selected_items()
		if selected_items.size() > 0:
			var index = selected_items[0]
			var metadata = variables_list.get_item_metadata(index)
			VariableManager.remove_variable(metadata.name, metadata.scope)
			_refresh_variables()
		selected_variable = ""
		delete_button.disabled = true

func _show_input_dialog(title: String, prompt: String, default_text: String):
	# Простой ввод через консоль для избежания проблем с диалогами
	print("[%s] %s (default: %s)" % [title, prompt, default_text])
	return default_text
