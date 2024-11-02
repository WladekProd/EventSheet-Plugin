@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

var second_condition_item := preload("res://addons/event_sheet/elements/window/second_condition_frame/second_condition_item.tscn")
var second_condition_button := preload("res://addons/event_sheet/elements/window/second_condition_frame/second_condition_item_button.tscn")

signal focused_condition

func update_items_list(conditions: Dictionary = {}) -> void:
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		if conditions.size() > 0:
			var _icon: Texture2D = conditions["icon"]
			var _disable_color: bool = conditions["disable_color"]
			var _name: String = conditions["name"]
			var _type: String = conditions["type"]
			var _conditions_type: Types.ConditionType = conditions["conditions_type"]
			var _resources: Dictionary = conditions["resources"]
		
			if _resources.size() > 0:
				for category: Types.Category in _resources:
					var category_template: VBoxContainer = second_condition_item.instantiate()
					
					var category_label: Label = category_template.get_child(0).get_child(0)
					match category:
						Types.Category.MAIN: category_label.text = "Main"
						Types.Category.VARIABLE: category_label.text = "Variable"
						Types.Category.INPUT: category_label.text = "Input"
					
					var category_items: GridContainer = category_template.get_child(1)
					
					if _resources[category].size() <= 0:
						continue
					
					for resource in _resources[category]:
						var res = resource
						var item_button_template: Button = second_condition_button.instantiate()
						item_button_template.name = res.name
						item_button_template.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
						item_button_template.text = res.name
						item_button_template.icon = res.icon
						item_button_template.disable_color = _disable_color
						var _conditions = {
							"button": {
								"instance": item_button_template,
								"name": item_button_template.name
							},
							"data": {
								"icon": _icon,
								"disable_color": _disable_color,
								"name": _name,
								"type": _type,
								"conditions_type": _conditions_type,
								"resource": res
							}
						}
						if !item_button_template.focus_entered.is_connected(_on_select_condition_focus_entered):
							item_button_template.focus_entered.connect(_on_select_condition_focus_entered.bind(_conditions))
						category_items.add_child(item_button_template)
						item_button_template.owner = category_items.get_owner()
					
					items_list.add_child(category_template)
					category_template.owner = items_list.get_owner()

func _on_select_condition_focus_entered(condition_data: Dictionary):
	focused_condition.emit(condition_data)
