@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var items_list: GridContainer = $MarginContainer/ScrollContainer/Items

var item_template := preload("res://addons/event_sheet/elements/window/pick_object_frame/item.tscn")

signal frame_result

func update_frame(current_scene, condition_type: Types.ConditionType, finish_button_instance: Button, frame: Types.WindowFrame, frame_data: Dictionary = {}):
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		var pick_object_data: Array = []
		
		var system_item: Dictionary = {
			"icon": load("res://addons/event_sheet/resources/icons/system.svg"),
			"disable_color": false,
			"name": "System",
			"type": "System",
			"object": null,
			"condition_type": condition_type,
		}
		pick_object_data.append(system_item)
		
		if current_scene:
			for item: Node in current_scene.get_children():
				var icon: Texture2D
				
				if item is Node2D:
					icon = item.texture if "texture" in item else EditorInterface.get_editor_theme().get_icon(item.get_class(), "EditorIcons")
				
				var node_item: Dictionary = {
					"icon": icon,
					"disable_color": true,
					"name": item.name,
					"type": "Node",
					"object": item,
					"condition_type": condition_type,
				}
				pick_object_data.append(node_item)
		
		for item in pick_object_data:
			var _icon: Texture2D = item["icon"]
			var _disable_color: bool = item["disable_color"]
			var _name: String = item["name"]
			
			var item_button: Button = item_template.instantiate()
			item_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			item_button.text = _name
			item_button.icon = _icon
			item_button.disable_color = _disable_color
			
			if !item_button.button_down.is_connected(_on_select_item):
				item_button.button_down.connect(_on_select_item.bind(item, frame))
			
			items_list.add_child(item_button)

func _on_select_item(data, frame: Types.WindowFrame):
	frame_result.emit(data, frame, false)
