@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

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
	FIRST_CONDITION,
	SECOND_CONDITION,
	FINISH_CONDITION,
	
	ADD_GROUP,
}
var first_condition_frame: Node = load("res://addons/event_sheet/elements/window/first_condition_frame/first_condition_frame.tscn").instantiate()
var second_condition_frame: Node = load("res://addons/event_sheet/elements/window/second_condition_frame/second_condition_frame.tscn").instantiate()
var finish_condition_frame: Node = load("res://addons/event_sheet/elements/window/finish_condition_frame/finish_condition_frame.tscn").instantiate()
var add_group_frame: Node = load("res://addons/event_sheet/elements/window/add_group_frame/add_group_frame.tscn").instantiate()
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
@onready var finish_button_instance: Button = $WindowPanel/MarginContainer/VBoxContainer/Buttons/Finish
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
var finish_button: bool = true:
	set(p_finish_button):
		if p_finish_button != finish_button:
			finish_button = p_finish_button
			update_configuration_warnings()
			update_window()

@onready var window_panel: Panel = $WindowPanel
var standart_window_size: Vector2 = Vector2(620, 376)

var current_block: BlockResource = null
var current_resource_button = null

var first_condition_data: Dictionary
var second_condition_data: Dictionary
var finish_condition_data: Dictionary
signal finish_data



func update_window():
	if window_title and window_title_instance: window_title_instance.text = window_title
	
	if cancel_button_instance: cancel_button_instance.visible = cancel_button
	if help_button_instance: help_button_instance.visible = help_button
	if back_button_instance: back_button_instance.visible = back_button
	if next_button_instance: next_button_instance.visible = next_button
	if finish_button_instance: finish_button_instance.visible = finish_button
	
	if window_frame_instance:
		for child in window_frame_instance.get_children():
			window_frame_instance.remove_child(child)
		match window_frame:
			WindowType.FIRST_CONDITION:
				window_frame_instance.add_child(first_condition_frame)
				first_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = true
				back_button = false
				next_button = true
				finish_button = false
			WindowType.SECOND_CONDITION:
				window_frame_instance.add_child(second_condition_frame)
				second_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = true
				back_button = true
				next_button = true
				finish_button = false
			WindowType.FINISH_CONDITION:
				finish_condition_frame.finished_button_up = finish_button_instance
				window_frame_instance.add_child(finish_condition_frame)
				finish_condition_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = false
				back_button = true
				next_button = false
				finish_button = true
			WindowType.ADD_GROUP:
				add_group_frame.finish_button_up = finish_button_instance
				window_frame_instance.add_child(add_group_frame)
				add_group_frame.owner = window_frame_instance.get_owner()
				cancel_button = true
				help_button = false
				back_button = false
				next_button = false
				finish_button = true
			WindowType.NONE:
				cancel_button = false
				help_button = false
				back_button = false
				next_button = false
				finish_button = false
				pass

func show_window(new_title: String = "", new_window_frame: WindowType = WindowType.FIRST_CONDITION, window_size: Vector2 = standart_window_size):
	window_title = new_title
	window_frame = new_window_frame
	window_panel.set_size(window_size)
	window_panel.set_position((size / 2) - (window_size / 2))
	visible = true
	
	match window_frame:
		WindowType.FIRST_CONDITION:
			if !first_condition_frame.focused_condition.is_connected(_on_first_condition_focused):
				first_condition_frame.focused_condition.connect(_on_first_condition_focused)
			return first_condition_frame
		WindowType.SECOND_CONDITION:
			if !second_condition_frame.focused_condition.is_connected(_on_second_condition_focused):
				second_condition_frame.focused_condition.connect(_on_second_condition_focused)
			return second_condition_frame
		WindowType.FINISH_CONDITION:
			if !finish_condition_frame.finished_condition.is_connected(_on_finished_condition):
				finish_condition_frame.finished_condition.connect(_on_finished_condition)
			return finish_condition_frame
		WindowType.ADD_GROUP:
			if !add_group_frame.finished.is_connected(_on_finished_group):
				add_group_frame.finished.connect(_on_finished_group)
			add_group_frame.clear_frame()
			return add_group_frame
	return null

func close_window():
	if window_frame_instance:
		window_frame = WindowType.NONE
	visible = false



func add_group(current_scene):
	current_block = null
	current_resource_button = null
	var title: String = "Add group"
	var window_content = show_window(title, WindowType.ADD_GROUP, Vector2(330, 210))

func _on_finished_group(data: Dictionary):
	finish_data.emit(data, current_block)
	current_block = null
	current_resource_button = null
	close_window()


# Parse First Conditions
func parse_first_conditions(current_scene, conditions_type: Types.ConditionType) -> Array:
	var conditions: Array = []
	
	var system_condition: Dictionary = {
		"icon": load("res://addons/event_sheet/resources/icons/system.svg"),
		"disable_color": false,
		"name": "System",
		"type": "System",
		"conditions_type": conditions_type,
		"resources": {}
	}
	conditions.append(system_condition)
	
	if current_scene:
		for item: Node in current_scene.get_children():
			if item is Node2D:
				var icon: Texture2D = item.texture if "texture" in item else EditorInterface.get_editor_theme().get_icon(item.get_class(), "EditorIcons")
				var condition: Dictionary = {
					"icon": icon,
					"disable_color": true,
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
								var resource_copy: EventResource = resource_instance.duplicate(true)
								conditions[category].append(resource_copy)
				if condition_data["conditions_type"] == Types.ConditionType.ACTIONS:
					for category in Types.Category.values():
						conditions[category] = []
						for resource in resource_files["actions"]:
							var resource_instance: ActionResource = load(resource)
							if resource_instance.action_category == category:
								var resource_copy: ActionResource = resource_instance.duplicate(true)
								conditions[category].append(resource_copy)
			"Node2D":
				var resource_files: Dictionary = find_tres_files_in_paths([
					"res://addons/event_sheet/modules/Node2D/",
					"res://addons/event_sheet/modules/General/",
				], sub_dirs)
				if condition_data["conditions_type"] == Types.ConditionType.EVENTS:
					for category in Types.Category.values():
						conditions[category] = []
						for resource in resource_files["events"]:
							var resource_instance: EventResource = load(resource)
							if resource_instance.event_category == category:
								var resource_copy: EventResource = resource_instance.duplicate(true)
								conditions[category].append(resource_copy)
				if condition_data["conditions_type"] == Types.ConditionType.ACTIONS:
					for category in Types.Category.values():
						conditions[category] = []
						for resource in resource_files["actions"]:
							var resource_instance: ActionResource = load(resource)
							if resource_instance.action_category == category:
								var resource_copy: ActionResource = resource_instance.duplicate(true)
								conditions[category].append(resource_copy)
	
	condition_data["resources"] = conditions
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
func add_condition(current_scene, cur_block: BlockResource = null, conditions_type: Types.ConditionType = Types.ConditionType.EVENTS):
	var conditions: Array = parse_first_conditions(current_scene, conditions_type)
	var title: String = "Add condition"
	var window_content = show_window(title, WindowType.FIRST_CONDITION)
	window_content.update_items_list(conditions)
	current_block = cur_block
	current_resource_button = null
	first_condition_data.clear()
	second_condition_data.clear()
	finish_condition_data.clear()
	finish_condition_frame.finished_data = {
		"type": Types.BlockType.STANDART,
		"data": {
			"condition": null,
			"resource": null
		}
	}

func change_condition(cur_resource, resource_button):
	current_resource_button = resource_button
	
	first_condition_data.clear()
	second_condition_data.clear()
	finish_condition_data.clear()
	
	first_condition_data = cur_resource.conditions.first_condition_data
	second_condition_data = cur_resource.conditions.second_condition_data
	second_condition_data.data["resource"] = cur_resource
	
	var title: String
	var data = second_condition_data.data
	match data.conditions_type:
		Types.ConditionType.EVENTS:
			title = "Parameters for '{0}': {1}".format([data.name, cur_resource.event_name])
		Types.ConditionType.ACTIONS:
			title = "Parameters for '{0}': {1}".format([data.name, cur_resource.action_name])
	var window_content = show_window(title, WindowType.FINISH_CONDITION)
	window_content.update_items_list(data)

# First Condition Focused
func _on_first_condition_focused(condition_data: Dictionary):
	if condition_data and !condition_data["button"].gui_input.is_connected(_on_first_selected_condition_input):
		condition_data["button"].gui_input.connect(_on_first_selected_condition_input.bind(condition_data))
	first_condition_data = condition_data
# First Condition Double-click
func _on_first_selected_condition_input(event: InputEvent, condition_data: Dictionary):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			_on_next_button_up(condition_data)

# Second Condition Focused
func _on_second_condition_focused(condition_data: Dictionary):
	if condition_data and !condition_data["button"].gui_input.is_connected(_on_second_selected_condition_input):
		condition_data["button"].gui_input.connect(_on_second_selected_condition_input.bind(condition_data))
	second_condition_data = condition_data
# Second Condition Double-click
func _on_second_selected_condition_input(event: InputEvent, condition_data: Dictionary):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			_on_next_button_up(condition_data)

# Last Condition Finished
func _on_finished_condition(condition_data: Dictionary):
	_on_next_button_up(condition_data)

func _on_next_button_up(condition_data: Dictionary = {}) -> void:
	match window_frame:
		WindowType.FIRST_CONDITION:
			if condition_data.size() > 0: first_condition_data = condition_data
			if first_condition_data and !second_condition_data.has(first_condition_data["button"]):
				second_condition_data[first_condition_data["button"]] = parse_second_conditions(first_condition_data["data"])
			if first_condition_data.size() > 0:
				var title: String = "Add '{0}' condition".format([first_condition_data["data"].name])
				var window_content = show_window(title, window_frame + 1)
				window_content.update_items_list(second_condition_data[first_condition_data["button"]])
		WindowType.SECOND_CONDITION:
			if condition_data.size() > 0: second_condition_data = condition_data
			if second_condition_data.size() > 0 and second_condition_data.has("data"):
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
			if condition_data.size() > 0: finish_condition_data = condition_data
			if finish_condition_data.size() > 0:
				
				var _first = first_condition_data.duplicate(true)
				_first.data.erase("resources")
				var _second = second_condition_data.duplicate(true)
				_second.data.erase("resource")
				
				var conditions: Dictionary = {
					"first_condition_data": _first,
					"second_condition_data": _second
				}
				finish_condition_data.data.resource.conditions = conditions
				
				if current_resource_button:
					current_resource_button.resource = finish_condition_data.data.resource
				else:
					finish_data.emit(finish_condition_data, current_block)
				
				current_block = null
				current_resource_button = null
				close_window()

func _on_cancel_button_up() -> void:
	first_condition_data = {}
	second_condition_data = {}
	close_window()

func _on_back_button_up() -> void:
	match window_frame:
		WindowType.SECOND_CONDITION:
				var title: String = "Add condition"
				show_window(title, window_frame - 1)
		WindowType.FINISH_CONDITION:
				var title: String = "Add '{0}' condition".format([first_condition_data["data"].name])
				show_window(title, window_frame - 1)

func _on_theme_changed() -> void:
	var base_color: Color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	
	if window_panel:
		var _style: StyleBoxFlat = window_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if _style.bg_color != base_color:
			_style.bg_color = base_color
			_style.draw_center = true
			window_panel.add_theme_stylebox_override("panel", _style)
