@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var items_list: GridContainer = $MarginContainer/ScrollContainer/Items

var item_template := preload("res://addons/event_sheet/elements/window/pick_object_frame/item.tscn")

var current_frame: Types.WindowFrame

signal frame_result

func update_frame(current_scene, condition_type: String, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}, window_search: LineEdit = null):
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		var pick_object_data: Array = []
		current_frame = frame
		
		var system_items: Array = ESUtils.Data.get_static_objects(condition_type)
		for item in system_items:
			if ESUtils.has_class(item.type, current_scene.event_sheet_file):
				pick_object_data.append(item)
		
		if current_scene: get_all_child_nodes(current_scene, condition_type, pick_object_data)
		
		for item in pick_object_data:
			var _icon: Texture2D = load(item["icon"])
			var _disable_color: bool = item["disable_color"]
			var _name: String = item["name"]
			var _is_current: bool = item["is_current"] if item.has("is_current") else false
			
			var item_button: Button = item_template.instantiate()
			item_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			item_button.data = item
			item_button.text = _name
			item_button.icon = _icon
			item_button.disable_color = _disable_color
			
			if !item_button.gui_input.is_connected(_on_select_item):
				item_button.gui_input.connect(_on_select_item.bind(item, frame))
			
			items_list.add_child(item_button)
			item_button.get_node("Current").visible = _is_current
		
		if window_search.text_changed.is_connected(_on_search):
			window_search.text_changed.disconnect(_on_search)
		window_search.text_changed.connect(_on_search)
		
		select_item(frame_data, false, true)

func get_all_child_nodes(child: Node, condition_type: String, pick_object_data):
	var icon_path = ESUtils.get_node_icon(child.get_path())
	print(icon_path)
	#if child is Node2D:
		#icon = child.texture if "texture" in child else EditorInterface.get_editor_theme().get_icon(child.get_class(), "EditorIcons")
	
	
	var node_item: Dictionary = {
		"icon": icon_path,
		"disable_color": true,
		"name": child.name,
		"type": child.get_class(),
		"path": ESUtils.current_scene.get_path_to(child),
		"condition_type": condition_type,
		"is_current": (child == ESUtils.current_scene)
	}
	pick_object_data.append(node_item)
	for _child in child.get_children():
		get_all_child_nodes(_child, condition_type, pick_object_data)

func select_item(frame_data: Dictionary = {}, is_new_data: bool = false, grab: bool = false):
	if items_list.get_child_count() > 0:
		var first_item: Button
		
		for item in items_list.get_children():
			if item.visible:
				first_item = item
				break
		
		if !is_new_data:
			if frame_data and frame_data.has(current_frame) and frame_data[current_frame]:
				for item in items_list.get_children():
					if item.text == frame_data[current_frame]["name"]:
						first_item = item
						break
		
		if first_item:
			if grab: first_item.grab_focus()
			frame_result.emit(first_item.data, current_frame, false, false)

func _on_search(query: String):
	var search_query = query.to_lower()
	if query.is_empty():
		for item in items_list.get_children():
			item.visible = true
		select_item({}, true)
		return
	
	for item in items_list.get_children():
		var item_text = item.get("text").to_lower()
		item.visible = item_text.find(search_query) != -1
	select_item({}, true)

func _on_select_item(event: InputEvent, data, frame: Types.WindowFrame):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			frame_result.emit(data, frame, false, true)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			frame_result.emit(data, frame, false, false)
