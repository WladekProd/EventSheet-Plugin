@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var event_sheet: = $".."
@onready var window_panel: Panel = $WindowPanel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var window_title: Label = $WindowPanel/MarginContainer/VBoxContainer/HBoxContainer/Title/WindowName
@onready var search_line: LineEdit = $WindowPanel/MarginContainer/VBoxContainer/HBoxContainer/Search/Search
@onready var search_button: TextureRect = $WindowPanel/MarginContainer/VBoxContainer/HBoxContainer/Search/SearchButton
@onready var search_animation: AnimationPlayer = $WindowPanel/MarginContainer/VBoxContainer/HBoxContainer/Search/SearchAnimator
@onready var window_frame_instance: Panel = $WindowPanel/MarginContainer/VBoxContainer/Panel

@onready var cancel_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Cancel
@onready var help_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Help
@onready var back_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Back
@onready var next_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Next
@onready var finish_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Finish

var pick_object_frame := preload("res://addons/event_sheet/elements/window/pick_object_frame/pick_object_frame.tscn")
var pick_condition_frame := preload("res://addons/event_sheet/elements/window/pick_condition_frame/pick_condition_frame.tscn")
var change_parameters_frame := preload("res://addons/event_sheet/elements/window/change_parameters_frame/change_parameters_frame.tscn")
var edit_group_frame := preload("res://addons/event_sheet/elements/window/edit_group_frame/edit_group_frame.tscn")
var edit_variable_frame := preload("res://addons/event_sheet/elements/window/edit_variable_frame/edit_variable_frame.tscn")
var editor_settings_frame := preload("res://addons/event_sheet/elements/window/editor_settings_frame/editor_settings_frame.tscn")

var current_data_body
var current_condition_type: String
var current_block_type: String
var current_block: Dictionary
var current_frame: Types.WindowFrame
var frame_data: Dictionary = {
	Types.WindowFrame.PICK_OBJECT: null,
	Types.WindowFrame.PICK_CONDITION: null,
	Types.WindowFrame.CHANGE_PARAMETERS: null,
	Types.WindowFrame.EDIT_GROUP: null,
	Types.WindowFrame.EDIT_VARIABLE: null,
}

var search_opened: bool = false
var search_focused: bool = false

signal finish_data

func _input(event: InputEvent) -> void:
	if visible and ESUtils.is_plugin_screen:
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
				_on_cancel_button_up()
			if event.keycode == KEY_ENTER and event.pressed:
				_on_next_button_up()
			if event.keycode == KEY_BACKSPACE and event.pressed and !search_opened and search_line.visible and search_button.visible:
				search_line.text = ""
				search_line.text_changed.emit("")
			var unicode: int
			if not event.shift_pressed: unicode = event.keycode | 0x20
			else: unicode = event.keycode
			if unicode > 20 and unicode < 40_000:
				if search_line.visible and search_button.visible and !search_opened:
					if ESUtils.get_setting("animations_enable"):
						search_button.modulate = Color.WHITE
						search_line.custom_minimum_size = Vector2(150, 12)
						search_line.modulate = Color.WHITE
						search_animation.play("show_search", -1, ESUtils.get_setting("animations_speed"))
					else:
						search_button.modulate = Color.TRANSPARENT
						search_line.custom_minimum_size = Vector2(150, 12)
						search_line.modulate = Color.WHITE
					search_line.grab_focus()
					search_opened = true
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !search_focused:
				if search_opened:
					if ESUtils.get_setting("animations_enable"):
						search_button.modulate = Color.WHITE
						search_line.custom_minimum_size = Vector2(150, 12)
						search_line.modulate = Color.WHITE
						search_animation.play("hide_search", -1, ESUtils.get_setting("animations_speed"))
					else:
						search_button.modulate = Color.WHITE
						search_line.custom_minimum_size = Vector2(0, 12)
						search_line.modulate = Color.TRANSPARENT
					search_opened = false

# Очистить окно
func clear_window():
	if window_frame_instance.get_child_count() > 0:
		window_frame_instance.get_child(0).queue_free()

# Обновить кнопки
func update_buttons():
	if next_button_instance:
		next_button_instance.disabled = !frame_data[current_frame] and current_frame < Types.WindowFrame.CHANGE_PARAMETERS

# Показать окно добавления
func show_add_window(condition_type: String, block_type: String = "standart", \
	block: Dictionary = {}, frame: Types.WindowFrame = Types.WindowFrame.PICK_OBJECT, window_size: Vector2 = Vector2(620, 376)):
	clear_window()
	
	current_condition_type = condition_type
	current_block_type = block_type
	current_block = block
	current_frame = frame
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	window_panel.pivot_offset = window_size / 2
	
	if !visible:
		if ESUtils.get_setting("animations_enable"):
			animation_player.play("show_window", -1, ESUtils.get_setting("animations_speed"))
		else:
			visible = true
	
	update_buttons()
	
	var frame_instance
	
	match frame:
		Types.WindowFrame.PICK_OBJECT:
			window_title.text = "Add condition"
			search_line.visible = true
			search_button.visible = true
			search_line.text = ""
			frame_instance = pick_object_frame.instantiate()
			cancel_button_instance.visible = true
			help_button_instance.visible = true
			back_button_instance.visible = false
			next_button_instance.visible = true
			finish_button_instance.visible = false
		Types.WindowFrame.PICK_CONDITION:
			window_title.text = "Add '{0}' condition".format([frame_data[Types.WindowFrame.PICK_OBJECT].name])
			search_line.visible = true
			search_button.visible = true
			search_line.text = ""
			frame_instance = pick_condition_frame.instantiate()
			cancel_button_instance.visible = true
			help_button_instance.visible = true
			back_button_instance.visible = true
			next_button_instance.visible = true
			finish_button_instance.visible = false
		Types.WindowFrame.CHANGE_PARAMETERS:
			window_title.text = "Parameters for '{0}': {1}".format([frame_data[Types.WindowFrame.PICK_OBJECT].name, frame_data[Types.WindowFrame.PICK_CONDITION].name])
			search_line.visible = false
			search_button.visible = false
			search_line.text = ""
			frame_instance = change_parameters_frame.instantiate()
			cancel_button_instance.visible = true
			help_button_instance.visible = true
			back_button_instance.visible = true
			next_button_instance.visible = false
			finish_button_instance.visible = true
	
	window_frame_instance.add_child(frame_instance)
	if frame_instance.frame_result.is_connected(_on_frame_result):
		frame_instance.frame_result.disconnect(_on_frame_result)
	frame_instance.frame_result.connect(_on_frame_result)
	frame_instance.update_frame(event_sheet.current_node, condition_type, finish_button_instance, current_frame, frame_data, search_line)

func show_add_group(block: Dictionary = {}, window_size: Vector2 = Vector2(330, 210)):
	clear_window()
	
	current_block_type = "group"
	current_block = block
	current_frame = Types.WindowFrame.EDIT_GROUP
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	window_panel.pivot_offset = window_size / 2
	
	if !visible:
		if ESUtils.get_setting("animations_enable"):
			animation_player.play("show_window", -1, ESUtils.get_setting("animations_speed"))
		else:
			visible = true
	
	update_buttons()
	
	var frame_instance = edit_group_frame.instantiate()
	window_title.text = "Add group"
	search_line.visible = false
	search_button.visible = false
	cancel_button_instance.visible = true
	help_button_instance.visible = false
	back_button_instance.visible = false
	next_button_instance.visible = false
	finish_button_instance.visible = true
	
	window_frame_instance.add_child(frame_instance)
	
	if frame_instance.frame_result.is_connected(_on_frame_result):
		frame_instance.frame_result.disconnect(_on_frame_result)
	
	frame_instance.frame_result.connect(_on_frame_result)
	frame_instance.update_frame(event_sheet.current_node, "group", finish_button_instance, current_frame, frame_data)

func show_add_variable(block: Dictionary = {}, window_size: Vector2 = Vector2(330, 230)):
	clear_window()
	
	current_block_type = "variable"
	current_block = block
	current_frame = Types.WindowFrame.EDIT_VARIABLE
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	window_panel.pivot_offset = window_size / 2
	
	if !visible:
		if ESUtils.get_setting("animations_enable"):
			animation_player.play("show_window", -1, ESUtils.get_setting("animations_speed"))
		else:
			visible = true
	
	update_buttons()
	
	var frame_instance = edit_variable_frame.instantiate()
	window_title.text = "Add variable"
	search_line.visible = false
	search_button.visible = false
	cancel_button_instance.visible = true
	help_button_instance.visible = false
	back_button_instance.visible = false
	next_button_instance.visible = false
	finish_button_instance.visible = true
	
	window_frame_instance.add_child(frame_instance)
	
	if frame_instance.frame_result.is_connected(_on_frame_result):
		frame_instance.frame_result.disconnect(_on_frame_result)
	
	frame_instance.frame_result.connect(_on_frame_result)
	frame_instance.update_frame(event_sheet.current_node, "variable", finish_button_instance, current_frame, frame_data)

func show_change_window(data: Dictionary = {}, data_body: Variant = null):
	clear_window()
	
	current_data_body = data_body
	
	if data.class == "block" and data.type != "standart":
		current_block = data
		if data.type == "group":
			frame_data = {
				Types.WindowFrame.EDIT_GROUP: data,
			}
			current_frame = Types.WindowFrame.EDIT_GROUP
			show_add_group(current_block)
		elif data.type == "variable":
			frame_data = {
				Types.WindowFrame.EDIT_VARIABLE: data,
			}
			current_frame = Types.WindowFrame.EDIT_VARIABLE
			show_add_variable(current_block)
		return
	else:
		frame_data = {
			Types.WindowFrame.PICK_OBJECT: data.object,
			Types.WindowFrame.PICK_CONDITION: data,
			Types.WindowFrame.CHANGE_PARAMETERS: data,
		}
		current_block = data_body.block_body.data
		current_frame = Types.WindowFrame.CHANGE_PARAMETERS
		if data.class == "event": current_condition_type = "event"
		elif data.class == "action": current_condition_type = "action"
		current_block_type = "standart"
		
		if !data.parameters.is_empty():
			show_add_window(current_condition_type, current_block_type, current_block, Types.WindowFrame.CHANGE_PARAMETERS)
		else:
			show_add_window(current_condition_type, current_block_type, current_block, Types.WindowFrame.PICK_CONDITION)

func show_editor_settings(window_size: Vector2 = Vector2(725, 475)):
	clear_window()
	
	current_frame = Types.WindowFrame.EDITOR_SETTINGS
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	window_panel.pivot_offset = window_size / 2
	
	if !visible:
		if ESUtils.get_setting("animations_enable"):
			animation_player.play("show_window", -1, ESUtils.get_setting("animations_speed"))
		else:
			visible = true
	
	var frame_instance = editor_settings_frame.instantiate()
	frame_instance.finish_button_instance = finish_button_instance
	window_title.text = "Editor Settings"
	search_line.visible = false
	search_button.visible = false
	cancel_button_instance.visible = false
	help_button_instance.visible = false
	back_button_instance.visible = false
	next_button_instance.visible = false
	finish_button_instance.visible = true
	
	if frame_instance.frame_result.is_connected(_on_cancel_button_up):
		frame_instance.frame_result.disconnect(_on_cancel_button_up)
	frame_instance.frame_result.connect(_on_cancel_button_up)
	
	window_frame_instance.add_child(frame_instance)

# Скрыть окно
func hide_window():
	if ESUtils.get_setting("animations_enable"):
		if search_opened:
			search_button.modulate = Color.WHITE
			search_line.custom_minimum_size = Vector2(150, 12)
			search_line.modulate = Color.WHITE
			search_animation.play("hide_search", -1, ESUtils.get_setting("animations_speed"))
		animation_player.play("hide_window", -1, ESUtils.get_setting("animations_speed"))
	else:
		search_button.modulate = Color.WHITE
		search_line.custom_minimum_size = Vector2(0, 12)
		search_line.modulate = Color.TRANSPARENT
		visible = false
	search_opened = false
	search_focused = false





func _on_frame_result(data, frame: Types.WindowFrame, finish: bool = false, next_frame: bool = false) -> void:
	if finish:
		if current_data_body:
			finish_data.emit({
				"block_type": current_block_type,
				"block_condition_type": current_condition_type,
				"block_data": data,
				"current_data_body": current_data_body
			}, current_block)
		else:
			finish_data.emit({
				"block_type": current_block_type,
				"block_condition_type": current_condition_type,
				"block_data": data
			}, current_block)
		_on_cancel_button_up()
	else:
		if frame_data[frame] != null:
			if frame_data[frame].has("name") and frame_data[frame].name != data.name:
				frame_data[frame] = data
			if next_frame: _on_next_button_up()
			update_buttons()
			return
		frame_data[frame] = data
		if next_frame: _on_next_button_up()
		update_buttons()

func _on_cancel_button_up() -> void:
	current_data_body = null
	frame_data = {
		Types.WindowFrame.PICK_OBJECT: null,
		Types.WindowFrame.PICK_CONDITION: null,
		Types.WindowFrame.CHANGE_PARAMETERS: null,
		Types.WindowFrame.EDIT_GROUP: null,
		Types.WindowFrame.EDIT_VARIABLE: null,
	}
	hide_window()

func _on_help_button_up() -> void:
	pass

func _on_back_button_up() -> void:
	if current_frame > Types.WindowFrame.PICK_OBJECT:
		show_add_window(current_condition_type, current_block_type, current_block, current_frame - 1)
	update_buttons()

func _on_next_button_up() -> void:
	if !next_button_instance.disabled:
		if current_frame < Types.WindowFrame.CHANGE_PARAMETERS:
			if current_frame == Types.WindowFrame.PICK_CONDITION:
				if frame_data[Types.WindowFrame.PICK_CONDITION]:
					frame_data[Types.WindowFrame.PICK_CONDITION].object = frame_data[Types.WindowFrame.PICK_OBJECT]
					if frame_data[Types.WindowFrame.PICK_CONDITION].parameters.is_empty():
						_on_frame_result(frame_data[Types.WindowFrame.PICK_CONDITION], current_frame, true, false)
						return
			show_add_window(current_condition_type, current_block_type, current_block, current_frame + 1)
			if search_opened and search_line.visible or search_button.visible: search_line.grab_focus()
	update_buttons()

func _on_theme_changed() -> void:
	var base_color: Color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	
	if window_panel:
		var _style: StyleBoxFlat = window_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if _style.bg_color != base_color:
			_style.bg_color = base_color
			_style.draw_center = true
			window_panel.add_theme_stylebox_override("panel", _style)

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"hide_window":
			if window_frame_instance.get_child_count() > 0:
				window_frame_instance.get_child(0).queue_free()

func _on_animation_started(anim_name: StringName) -> void:
	pass

func _on_search_mouse_entered() -> void:
	search_focused = true

func _on_search_mouse_exited() -> void:
	search_focused = false

func _on_search_button_gui_input(event: InputEvent) -> void:
	if visible and ESUtils.is_plugin_screen:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !search_opened:
				if ESUtils.get_setting("animations_enable"):
					search_button.modulate = Color.WHITE
					search_line.custom_minimum_size = Vector2(150, 12)
					search_line.modulate = Color.WHITE
					search_animation.play("show_search")
				else:
					search_button.modulate = Color.TRANSPARENT
					search_line.custom_minimum_size = Vector2(150, 12)
					search_line.modulate = Color.WHITE
				search_line.grab_focus()
				search_opened = true
