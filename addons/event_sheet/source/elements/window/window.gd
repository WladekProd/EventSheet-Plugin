@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var event_sheet: = $".."
@onready var window_panel: Panel = $WindowPanel

@onready var window_title: Label = $WindowPanel/MarginContainer/VBoxContainer/WindowName
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

var current_scene
var current_resource_button
var current_condition_type: Types.ConditionType
var current_block_type: Types.BlockType
var current_block: BlockResource
var current_frame: Types.WindowFrame
var frame_data: Dictionary = {
	Types.WindowFrame.PICK_OBJECT: null,
	Types.WindowFrame.PICK_CONDITION: null,
	Types.WindowFrame.CHANGE_PARAMETERS: null,
}

signal finish_data

# Очистить окно
func clear_window():
	if window_frame_instance.get_child_count() > 0:
		window_frame_instance.get_child(0).queue_free()

# Обновить кнопки
func update_buttons():
	if next_button_instance:
		next_button_instance.disabled = !frame_data[current_frame] and current_frame < Types.WindowFrame.CHANGE_PARAMETERS

# Показать окно добавления
func show_add_window(condition_type: Types.ConditionType, block_type: Types.BlockType = Types.BlockType.STANDART, \
	block: BlockResource = null, frame: Types.WindowFrame = Types.WindowFrame.PICK_OBJECT, window_size: Vector2 = Vector2(620, 376)):
	clear_window()
	
	current_scene = event_sheet.current_scene
	current_condition_type = condition_type
	current_block_type = block_type
	current_block = block
	current_frame = frame
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	visible = true
	
	update_buttons()
	
	var frame_instance
	
	match frame:
		Types.WindowFrame.PICK_OBJECT:
			frame_instance = pick_object_frame.instantiate()
			cancel_button_instance.visible = true
			help_button_instance.visible = true
			back_button_instance.visible = false
			next_button_instance.visible = true
			finish_button_instance.visible = false
		Types.WindowFrame.PICK_CONDITION:
			frame_instance = pick_condition_frame.instantiate()
			cancel_button_instance.visible = true
			help_button_instance.visible = true
			back_button_instance.visible = true
			next_button_instance.visible = true
			finish_button_instance.visible = false
		Types.WindowFrame.CHANGE_PARAMETERS:
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
	frame_instance.update_frame(current_scene, condition_type, finish_button_instance, current_frame, frame_data)

# Показать окно редактирования
func show_change_window(resource, resource_button):
	clear_window()
	
	current_scene = event_sheet.current_scene
	current_resource_button = resource_button
	
	if !(resource is BlockResource):
		frame_data = {
			Types.WindowFrame.PICK_OBJECT: resource.pick_object,
			Types.WindowFrame.PICK_CONDITION: resource,
			Types.WindowFrame.CHANGE_PARAMETERS: resource,
		}
		current_block = null
		current_frame = Types.WindowFrame.CHANGE_PARAMETERS
		if resource is EventResource: current_condition_type = Types.ConditionType.EVENTS
		elif resource is ActionResource: current_condition_type = Types.ConditionType.ACTIONS
		current_block_type = Types.BlockType.STANDART
		
		show_add_window(current_condition_type, current_block_type, null, Types.WindowFrame.CHANGE_PARAMETERS)
	else:
		current_block = resource
		current_frame = Types.WindowFrame.EDIT_GROUP
		if resource.block_type == Types.BlockType.GROUP:
			current_block_type = Types.BlockType.GROUP
			
			
		elif resource.block_type == Types.BlockType.VARIABLE:
			current_block_type = Types.BlockType.VARIABLE
			print("variable window")

# Скрыть окно
func hide_window():
	if window_frame_instance.get_child_count() > 0:
		window_frame_instance.get_child(0).queue_free()
	visible = false





func _on_frame_result(data, frame: Types.WindowFrame, finish: bool = false) -> void:
	if finish:
		if current_resource_button:
			current_resource_button.resource = data
		else:
			finish_data.emit({
				"block_type": current_block_type,
				"block_data": data
			}, current_block)
		_on_cancel_button_up()
	else:
		if frame_data[frame] != null:
			if frame_data[frame].name != data.name:
				frame_data[frame] = data
			update_buttons()
			return
		frame_data[frame] = data
		update_buttons()

func _on_cancel_button_up() -> void:
	current_scene = null
	current_block = null
	current_resource_button = null
	frame_data = {
		Types.WindowFrame.PICK_OBJECT: null,
		Types.WindowFrame.PICK_CONDITION: null,
		Types.WindowFrame.CHANGE_PARAMETERS: null,
	}
	hide_window()

func _on_help_button_up() -> void:
	pass

func _on_back_button_up() -> void:
	if current_frame > Types.WindowFrame.PICK_OBJECT:
		show_add_window(current_condition_type, current_block_type, current_block, current_frame - 1)
	update_buttons()

func _on_next_button_up() -> void:
	if current_frame < Types.WindowFrame.CHANGE_PARAMETERS:
		show_add_window(current_condition_type, current_block_type, current_block, current_frame + 1)
	update_buttons()

func _on_theme_changed() -> void:
	var base_color: Color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	
	if window_panel:
		var _style: StyleBoxFlat = window_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if _style.bg_color != base_color:
			_style.bg_color = base_color
			_style.draw_center = true
			window_panel.add_theme_stylebox_override("panel", _style)
