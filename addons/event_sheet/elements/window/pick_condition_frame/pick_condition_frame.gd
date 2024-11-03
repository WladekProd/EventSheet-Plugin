@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

var category_item_template := preload("res://addons/event_sheet/elements/window/pick_condition_frame/category_item.tscn")
var item_template := preload("res://addons/event_sheet/elements/window/pick_condition_frame/item.tscn")

signal frame_result

func update_frame(current_scene, condition_type: Types.ConditionType, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}):
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		var pick_object_data: Dictionary = frame_data[Types.WindowFrame.PICK_OBJECT]
		var pick_condition_data: Dictionary = {}
		
		var sub_dirs: Array = ["actions", "events"]
		var resource_files: Dictionary = ESUtils.find_tres_files_in_paths([
			"res://addons/event_sheet/modules/{0}".format([pick_object_data.type]),
			"res://addons/event_sheet/modules/General",
		], sub_dirs)
		
		var files_data
		if pick_object_data.condition_type == Types.ConditionType.EVENTS:
			files_data = resource_files["events"]
		if pick_object_data.condition_type == Types.ConditionType.ACTIONS:
			files_data = resource_files["actions"]
		
		for category in Types.Category.values():
			pick_condition_data[category] = []
			for resource in files_data:
				var resource_instance = load(resource)
				if resource_instance.category == category:
					pick_condition_data[category].append(resource_instance)

		var _icon: Texture2D = pick_object_data.icon
		var _disable_color: bool = pick_object_data.disable_color
		var _name: String = pick_object_data.name
		var _type: String = pick_object_data.type
		var _condition_type: Types.ConditionType = pick_object_data.condition_type
		
		if pick_condition_data.size() > 0:
			for category: Types.Category in pick_condition_data:
				var item_category: VBoxContainer = category_item_template.instantiate()
				
				var category_label: Label = item_category.get_child(0).get_child(0)
				match category:
					Types.Category.MAIN: category_label.text = "Main"
					Types.Category.VARIABLE: category_label.text = "Variable"
					Types.Category.INPUT: category_label.text = "Input"
					_: category_label.text = "Other"
				
				var category_items: GridContainer = item_category.get_child(1)
				
				if pick_condition_data[category].size() <= 0:
					continue
				
				for item in pick_condition_data[category]:
					var item_button: Button = item_template.instantiate()
					item_button.name = item.name
					item_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					item_button.text = item.name
					item_button.icon = item.icon
					item_button.disable_color = _disable_color
					if !item_button.gui_input.is_connected(_on_select_item):
						item_button.gui_input.connect(_on_select_item.bind(item, frame))
					category_items.add_child(item_button)
				
				items_list.add_child(item_category)

func _on_select_item(event: InputEvent, data, frame: Types.WindowFrame):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			var new_data = data.duplicate(true)
			frame_result.emit(new_data, frame, false, true)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var new_data = data.duplicate(true)
			frame_result.emit(new_data, frame, false, false)
