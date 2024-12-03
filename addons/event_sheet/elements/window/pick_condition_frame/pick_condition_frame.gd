@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

var category_item_template := preload("res://addons/event_sheet/elements/window/pick_condition_frame/category_item.tscn")
var item_template := preload("res://addons/event_sheet/elements/window/pick_condition_frame/item.tscn")

var current_frame: Types.WindowFrame

signal frame_result

func update_frame(current_scene, condition_type: String, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}, window_search: LineEdit = null):
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		var pick_object_data: Dictionary = frame_data[Types.WindowFrame.PICK_OBJECT]
		var pick_condition_data: Dictionary = {}
		current_frame = frame
		
		var _icon: Texture2D = load(pick_object_data.icon)
		var _disable_color: bool = pick_object_data.disable_color
		var _name: String = pick_object_data.name
		var _type: String = pick_object_data.type
		var _condition_type: String = pick_object_data.condition_type
		
		var object_path_or_type = pick_object_data.path if pick_object_data.path else pick_object_data.type
		var script_files: Dictionary = ESUtils.find_gd_files_in_paths([
			"res://addons/event_sheet/modules/",
		], object_path_or_type)
		
		var files_data
		if pick_object_data.condition_type == "event":
			files_data = script_files["events"]
		if pick_object_data.condition_type == "action":
			files_data = script_files["actions"]
		
		for category in Types.Category.values():
			pick_condition_data[category] = []
			for script in files_data:
				var script_instance = load(script)
				var script_metadata: Dictionary = script_instance.get_condition_metadata()
				if script_metadata.category == category:
					pick_condition_data[category].append(script)
		
		if pick_condition_data.size() > 0:
			for category: Types.Category in pick_condition_data:
				var item_category: VBoxContainer = category_item_template.instantiate()
				
				var category_label: Label = item_category.get_child(0).get_child(0)
				
				category_label.text = str(Types.CATEGORY_NAMES[category])
				
				var category_items: GridContainer = item_category.get_child(1)
				
				if pick_condition_data[category].size() <= 0:
					continue
				
				for script in pick_condition_data[category]:
					var script_instance = load(script)
					var item = script_instance.get_condition_metadata(object_path_or_type if object_path_or_type is NodePath else "")
					
					var item_button: Button = item_template.instantiate()
					if pick_object_data.condition_type == "event":
						var _object = str(object_path_or_type) if object_path_or_type is NodePath else ""
						item_button.data = ESUtils.Data.create_event(item.name, "standart", script, _object, script_instance.params())
					if pick_object_data.condition_type == "action":
						var _object = str(object_path_or_type) if object_path_or_type is NodePath else ""
						item_button.data = ESUtils.Data.create_action(item.name, "standart", script, _object, script_instance.params())
					item_button.name = item.name
					item_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					item_button.text = item.name
					item_button.icon = item.icon
					item_button.disable_color = !item.change_icon_color
					if !item_button.gui_input.is_connected(_on_select_item):
						item_button.gui_input.connect(_on_select_item.bind(item_button.data, frame))
					category_items.add_child(item_button)
				
				items_list.add_child(item_category)
		
		if window_search.text_changed.is_connected(_on_search):
			window_search.text_changed.disconnect(_on_search)
		window_search.text_changed.connect(_on_search)

func select_item(frame_data: Dictionary = {}, is_new_data: bool = false, grab: bool = false):
	if items_list.get_child_count() > 0:
		var first_item: Button
		
		for category in items_list.get_children():
			var category_items: GridContainer = category.get_child(1)
			for item in category_items.get_children():
				if item.visible:
					first_item = item
					break
			if first_item:
				break
		
		if !is_new_data:
			if frame_data and frame_data.has(current_frame) and frame_data[current_frame]:
				for category in items_list.get_children():
					var category_items: GridContainer = category.get_child(1)
					for item in category_items.get_children():
						if item.text == frame_data[current_frame]["name"]:
							first_item = item
							break
					if first_item:
						break
		
		if first_item:
			if grab: first_item.grab_focus()
			var new_data = first_item.data.duplicate(true)
			frame_result.emit(new_data, current_frame, false, false)

func _on_search(query: String):
	var search_query = query.to_lower()
	if query.is_empty():
		for category in items_list.get_children():
			category.visible = true
			var category_items: GridContainer = category.get_child(1)
			for item in category_items.get_children():
				item.visible = true
		select_item({}, true)
		return

	for category in items_list.get_children():
		var category_visible = false
		var category_items: GridContainer = category.get_child(1)
		for item in category_items.get_children():
			var item_text = item.text.to_lower()
			item.visible = item_text.find(search_query) != -1
			if item.visible:
				category_visible = true
		category.visible = category_visible
	select_item({}, true)

func _on_select_item(event: InputEvent, data, frame: Types.WindowFrame):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			var new_data = data.duplicate(true)
			frame_result.emit(new_data, frame, false, true)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var new_data = data.duplicate(true)
			frame_result.emit(new_data, frame, false, false)
