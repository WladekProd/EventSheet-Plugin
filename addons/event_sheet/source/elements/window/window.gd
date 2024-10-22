@tool
extends Control

const Types = preload("res://addons/event_sheet/source/Types.gd")

@onready var window_title_instance: Label = $WindowPanel/MarginContainer/VBoxContainer/WindowName
@export var window_title: String = "":
	set(p_window_title):
		if p_window_title != window_title:
			window_title = p_window_title
			update_configuration_warnings()
			update_window()

@onready var window_frame_instance: Panel = $WindowPanel/MarginContainer/VBoxContainer/Panel
enum WindowType {
	NONE,
	ADD_CONDITION,
	NEXT_CONDITION,
	FINISH_CONDITION,
}
var add_condition_frame: Node = load("res://addons/event_sheet/elements/Window/add_condition_frame/add_condition_frame.tscn").instantiate()
var next_condition_frame: Node = load("res://addons/event_sheet/elements/Window/next_condition_frame/next_condition_frame.tscn").instantiate()
var finish_condition_frame: Node = load("res://addons/event_sheet/elements/Window/finish_condition_frame/finish_condition_frame.tscn").instantiate()
@export var window_frame: WindowType:
	set(p_window_frame):
		if p_window_frame != window_frame:
			window_frame = p_window_frame
			update_configuration_warnings()
			update_window()

@onready var cancel_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Cancel
@onready var help_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Help
@onready var back_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Back
@onready var next_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Next
var cancel_button: bool = true:
	set(p_cancel_button):
		if p_cancel_button != cancel_button:
			cancel_button = p_cancel_button
			update_configuration_warnings()
			update_window()
var help_button: bool = true:
	set(p_help_button):
		if p_help_button != help_button:
			help_button = p_help_button
			update_configuration_warnings()
			update_window()
var back_button: bool = true:
	set(p_back_button):
		if p_back_button != back_button:
			back_button = p_back_button
			update_configuration_warnings()
			update_window()
var next_button: bool = true:
	set(p_next_button):
		if p_next_button != next_button:
			next_button = p_next_button
			update_configuration_warnings()
			update_window()

signal finish_data

func update_window():
	if window_title and window_title_instance: window_title_instance.text = window_title
	
	if cancel_button_instance: cancel_button_instance.visible = cancel_button
	if help_button_instance: help_button_instance.visible = help_button
	if back_button_instance: back_button_instance.visible = back_button
	if next_button_instance: next_button_instance.visible = next_button
	
	if window_frame_instance:
		for child in window_frame_instance.get_children():
			window_frame_instance.remove_child(child)
		match window_frame:
			WindowType.ADD_CONDITION:
				window_frame_instance.add_child(add_condition_frame)
				add_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = true
				back_button = false
				next_button = true
			WindowType.NEXT_CONDITION:
				window_frame_instance.add_child(next_condition_frame)
				next_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = true
				back_button = true
				next_button = true
			WindowType.FINISH_CONDITION:
				finish_condition_frame.finished_button_up = next_button_instance
				window_frame_instance.add_child(finish_condition_frame)
				finish_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = false
				back_button = true
				next_button = true
			WindowType.NONE:
				cancel_button = false
				help_button = false
				back_button = false
				next_button = false
				pass

func show_window(new_title: String = "", new_window_frame: WindowType = WindowType.ADD_CONDITION):
	window_title = new_title
	window_frame = new_window_frame
	visible = true
	
	match window_frame:
		WindowType.ADD_CONDITION:
			if !add_condition_frame.focused_condition.is_connected(_on_condition_focused):
				add_condition_frame.focused_condition.connect(_on_condition_focused)
			return add_condition_frame
		WindowType.NEXT_CONDITION:
			if !next_condition_frame.focused_condition.is_connected(_on_second_condition_focused):
				next_condition_frame.focused_condition.connect(_on_second_condition_focused)
			return next_condition_frame
		WindowType.FINISH_CONDITION:
			if !finish_condition_frame.finished_condition.is_connected(_on_finished_condition):
				finish_condition_frame.finished_condition.connect(_on_finished_condition)
			return finish_condition_frame
	return null

func close_window():
	if window_frame_instance:
		window_frame = WindowType.NONE
	visible = false



# Parse First Conditions
func parse_first_conditions(current_scene, conditions_type: Types.ConditionType) -> Array:
	var conditions: Array = []
	
	var system_condition: Dictionary = {
		"icon": load("res://addons/event_sheet/resources/icons/system.svg"),
		"icon_color": EditorInterface.get_editor_theme().get_color("accent_color", "Editor"),
		"name": "System",
		"type": "System",
		"conditions_type": conditions_type,
		"resources": {}
	}
	conditions.append(system_condition)
	
	if current_scene:
		for item: Node in current_scene.get_children():
			if item is Node2D:
				var condition: Dictionary = {
					"icon": item.texture,
					"icon_color": Color.WHITE,
					"name": item.name,
					"type": "Node2D",
					"object": item,
					"conditions_type": conditions_type,
					"resources": {}
				}
				conditions.append(condition)
	
	return conditions
# Parse Second Conditions
func parse_second_conditions(condition_data: Dictionary) -> Dictionary:
	var conditions: Dictionary = {}
	
	if condition_data and condition_data["type"]:
		var sub_dirs: Array = ["actions", "events"]
		match condition_data["type"]:
			"System":
				var resource_files: Dictionary = find_tres_files_in_paths([
					"res://addons/event_sheet/modules/System",
					"res://addons/event_sheet/modules/General",
				], sub_dirs)
				if condition_data["conditions_type"] == Types.ConditionType.EVENTS:
					for category in Types.Category.values():
						conditions[category] = []
						for resource in resource_files["events"]:
							var resource_instance: EventResource = load(resource)
							if resource_instance.event_category == category:
								conditions[category].append(resource_instance)
				if condition_data["conditions_type"] == Types.ConditionType.ACTIONS:
					for category in Types.Category.values():
						conditions[category] = []
						for resource in resource_files["actions"]:
							var resource_instance: ActionResource = load(resource)
							if resource_instance.action_category == category:
								conditions[category].append(resource_instance)
			"Node2D":
				#var resource_files: Dictionary = find_tres_files_in_paths([
					#"res://addons/event_sheet/modules/Node2D/",
					#"res://addons/event_sheet/modules/General/",
				#], sub_dirs)
				pass
	
	condition_data["resources"] = conditions
	print(condition_data)
	return condition_data
# Scan Files in Folders
func find_tres_files_in_paths(resource_paths: Array, sub_dirs: Array) -> Dictionary:
	var tres_files: Dictionary = {"actions": [], "events": []}
	for path in resource_paths:
		for sub_dir in sub_dirs:
			var full_sub_dir_path: String = "{0}/{1}".format([path, sub_dir])
			var dir = DirAccess.open(full_sub_dir_path)
			if dir:
				dir.list_dir_begin()
				var file_name: String = dir.get_next()
				while file_name != "":
					if file_name != "." and file_name != "..":
						var full_path: String = "{0}/{1}".format([full_sub_dir_path, file_name])
						if dir.current_is_dir():
							# Рекурсивно обрабатываем вложенные папки
							var sub_tres_files: Dictionary = find_tres_files_in_paths([full_path], sub_dirs)
							for category in tres_files.keys():
								tres_files[category].append_array(sub_tres_files[category])
						elif file_name.ends_with(".tres"):
							tres_files[sub_dir].append(full_path)
					file_name = dir.get_next()
				dir.list_dir_end()
	return tres_files

# Show 'Add Condition' Window
func add_condition(current_scene, conditions_type: Types.ConditionType = Types.ConditionType.EVENTS):
	var conditions: Array = parse_first_conditions(current_scene, conditions_type)
	var title: String = "Add condition"
	var window_content = show_window(title, WindowType.ADD_CONDITION)
	window_content.update_items_list(conditions)

var first_condition_data: Dictionary
var second_condition_data: Dictionary
var finish_condition_data: Dictionary

# First Condition Focused
func _on_condition_focused(condition_data: Dictionary):
	if condition_data and !condition_data["button"].gui_input.is_connected(_on_selected_condition_input):
		condition_data["button"].gui_input.connect(_on_selected_condition_input.bind(condition_data))
	first_condition_data = condition_data
	print("first")
# First Condition Double-click
func _on_selected_condition_input(event: InputEvent, condition_data: Dictionary):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			first_condition_data = condition_data
			_on_next_button_up()

# Second Condition Focused
func _on_second_condition_focused(condition_data: Dictionary):
	if condition_data and !condition_data["button"].gui_input.is_connected(_on_second_selected_condition_input):
		condition_data["button"].gui_input.connect(_on_second_selected_condition_input.bind(condition_data))
	second_condition_data = condition_data
	print("second")
# Second Condition Double-click
func _on_second_selected_condition_input(event: InputEvent, condition_data: Dictionary):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			second_condition_data = condition_data
			_on_next_button_up()

# Last Condition Finished
func _on_finished_condition(condition_data: Dictionary):
	print("finish")
	finish_condition_data = condition_data

func _on_next_button_up() -> void:
	match window_frame:
		WindowType.ADD_CONDITION:
			if first_condition_data.size() > 0:
				print("next first")
				var data = first_condition_data["data"]
				var conditions: Dictionary = parse_second_conditions(data)
				var title: String = "Add '{0}' condition".format([data.name])
				var window_content = show_window(title, window_frame + 1)
				window_content.update_items_list(conditions)
		WindowType.NEXT_CONDITION:
			if second_condition_data.size() > 0:
				print("next second")
				var data = second_condition_data["data"]
				var title: String
				match data.conditions_type:
					Types.ConditionType.EVENTS:
						title = "Parameters for '{0}': {1}".format([data.name, data.resource.event_name])
					Types.ConditionType.ACTIONS:
						title = "Parameters for '{0}': {1}".format([data.name, data.resource.action_name])
				var window_content = show_window(title, window_frame + 1)
				window_content.update_items_list(data)
		WindowType.FINISH_CONDITION:
			if finish_condition_data.size() > 0:
				print("next finish")
				var data = finish_condition_data["data"]
				finish_data.emit(data)
				close_window()

func _on_cancel_button_up() -> void:
	first_condition_data = {}
	second_condition_data = {}
	close_window()

func _on_back_button_up() -> void:
	match window_frame:
		WindowType.NEXT_CONDITION:
				var title: String = "Add condition"
				show_window(title, window_frame - 1)
		WindowType.FINISH_CONDITION:
				var title: String = "Add '{0}' condition".format([first_condition_data["data"].name])
				show_window(title, window_frame - 1)
