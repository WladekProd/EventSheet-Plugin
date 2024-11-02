@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var condition_description: Label = $MarginContainer/ScrollContainer/VBoxContainer/ConditionDescription
@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/Parameters

var string_parameter := preload("res://addons/event_sheet/elements/window/change_parameters_frame/parameters/string.tscn")
var stipulation_parameter := preload("res://addons/event_sheet/elements/window/change_parameters_frame/parameters/stipulation.tscn")
var open_file_patameter := preload("res://addons/event_sheet/elements/window/change_parameters_frame/parameters/open_file.tscn")
var select_node_parameter := preload("res://addons/event_sheet/elements/window/change_parameters_frame/parameters/select_node.tscn")

var resource

signal frame_result

func update_frame(current_scene, condition_type: Types.ConditionType, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}):
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		var pick_object_data: Dictionary = frame_data[Types.WindowFrame.PICK_OBJECT]
		var pick_condition_data = frame_data[Types.WindowFrame.PICK_CONDITION]
		var parameters_data: Dictionary = {}
		
		resource = pick_condition_data
		resource.pick_object = pick_object_data
		
		condition_description.text = "{0}: {1}".format([resource.name, resource.description])
		
		if resource.parameters.size() <= 0:
			frame_result.emit(resource, frame, true)
			return
		else:
			var sorted_keys: Array = resource.parameters.keys()
			sorted_keys.sort_custom(
				func(a: String, b: String) -> bool:
					return resource.parameters[a]["order"] < resource.parameters[b]["order"]
			)
			for p_key in sorted_keys:
				var p_name: String = resource.parameters[p_key].name
				var p_value: String = resource.parameters[p_key].value
				var p_type = resource.parameters[p_key].type
				add_parameter(p_key, p_name, p_value, p_type)
		
		for item in finish_button_instance.button_up.get_connections():
			finish_button_instance.button_up.disconnect(item.callable)
		
		if !finish_button_instance.button_up.is_connected(_on_submit):
			finish_button_instance.button_up.connect(_on_submit.bind(resource, frame))
		
	items_list.fix_items_size()

func add_parameter(p_key, p_name, p_value, p_type):
	match p_type:
		Types.STANDART_TYPES.SELECT_NODE:
			var select_node_item_template: HBoxContainer = select_node_parameter.instantiate()
			select_node_item_template.name = p_key
			
			var parameter_name: Label = select_node_item_template.get_child(0)
			parameter_name.text = p_name
			
			var parameter_value: Button = select_node_item_template.get_child(1)
			parameter_value.button_up.connect(_on_open_node_path.bind(parameter_value))
			parameter_value.node_path = p_value
			
			items_list.add_child(select_node_item_template)
		Types.STANDART_TYPES.OPEN_FILE:
			var open_file_item_template: HBoxContainer = open_file_patameter.instantiate()
			open_file_item_template.name = p_key
			
			var parameter_name: Label = open_file_item_template.get_child(0)
			parameter_name.text = p_name
			
			var parameter_value: Button = open_file_item_template.get_child(1)
			parameter_value.button_up.connect(_on_open_file.bind(parameter_value))
			parameter_value.file_path = p_value
			
			items_list.add_child(open_file_item_template)
		Types.STIPULATION:
			var stipulation_item_template: HBoxContainer = stipulation_parameter.instantiate()
			stipulation_item_template.name = p_key
			
			var parameter_name: Label = stipulation_item_template.get_child(0)
			parameter_name.text = p_name
			
			var parameter_value: OptionButton = stipulation_item_template.get_child(1)
			for i in Types.STIPULATION.values():
				parameter_value.add_item(Types.STIPULATION_SYMBOL[i], i)
			
			parameter_value.item_selected.connect(_on_parameter_selected)
			parameter_value.select(Types.STIPULATION_SYMBOL.find_key(p_value))
			
			items_list.add_child(stipulation_item_template)
		_:
			var string_item_template: HBoxContainer = string_parameter.instantiate()
			string_item_template.name = p_key
			
			var parameter_name: Label = string_item_template.get_child(0)
			parameter_name.text = p_name
			
			var parameter_value: LineEdit = string_item_template.get_child(1)
			parameter_value.text_changed.connect(_on_parameter_edited)
			parameter_value.text = p_value
			
			items_list.add_child(string_item_template)

func save_parameters():
	for child in items_list.get_children():
		var parameter_name: String = child.name
		var parameter_value = child.get_child(1)
		match parameter_value.get_class():
			"LineEdit":
				resource.parameters[parameter_name].value = parameter_value.text
			"OptionButton":
				resource.parameters[parameter_name].value = Types.STIPULATION_SYMBOL[parameter_value.selected]
			"Button":
				if parameter_value.has_method("get_file_path"):
					resource.parameters[parameter_name].value = parameter_value.get_file_path()
				elif parameter_value.has_method("get_node_path"):
					resource.parameters[parameter_name].value = parameter_value.get_node_path()

func _on_open_node_path(parameter_value: Button):
	EditorInterface.popup_node_selector(_on_node_selected.bind(parameter_value), [])

func _on_node_selected(node_path, parameter_value: Button):
	var edited_scene = EditorInterface.get_edited_scene_root()
	var node = edited_scene.get_node(node_path)
	if !node_path.is_empty():
		var node_name = node.name
		var node_icon = EditorInterface.get_editor_theme().get_icon(str(node.get_class()), "EditorIcons")
		parameter_value.node_path = node_path
		parameter_value.set_node_name(node_name)
		parameter_value.set_icon(node_icon)
		save_parameters()

func _on_open_file(parameter_value: Button):
	var dialog: EditorFileDialog = EditorFileDialog.new()
	add_child(dialog)
	dialog.size = get_tree().root.size / 2
	dialog.position = get_tree().root.size / 4
	if dialog.file_selected.is_connected(_on_file_selected):
		dialog.file_selected.disconnect(_on_file_selected)
	dialog.file_selected.connect(_on_file_selected.bind(parameter_value))
	dialog.dialog_hide_on_ok = true
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.set_filters(PackedStringArray(["*.tscn ; Scene Files"]))
	dialog.title = "Open File"
	dialog.visible = true

func _on_file_selected(path: String, parameter_value: Button):
	parameter_value.file_path = path
	save_parameters()

func _on_parameter_selected(index: int):
	save_parameters()

func _on_parameter_edited(new_text: String):
	save_parameters()

func _on_submit(data, frame: Types.WindowFrame):
	frame_result.emit(data, frame, true)
