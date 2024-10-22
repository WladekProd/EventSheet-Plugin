@tool
extends Control

const Types = preload("res://addons/event_sheet/source/Types.gd")

@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

signal focused_condition

func update_items_list(conditions: Dictionary = {}) -> void:
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		if conditions.size() > 0:
			var _icon: Texture2D = conditions["icon"]
			var _icon_color: Color = conditions["icon_color"]
			var _name: String = conditions["name"]
			var _type: String = conditions["type"]
			var _conditions_type: Types.ConditionType = conditions["conditions_type"]
			var _resources: Dictionary = conditions["resources"]
		
			if _resources.size() > 0:
				for category: Types.Category in _resources:
					var category_template: VBoxContainer = load("res://addons/event_sheet/elements/Window/next_condition_frame/next_condition_item.tscn").instantiate()
					
					var category_label: Label = category_template.get_child(0).get_child(0)
					match category:
						Types.Category.MAIN: category_label.text = "Main"
						Types.Category.VARIABLE: category_label.text = "Variable"
						Types.Category.INPUT: category_label.text = "Input"
					
					var category_items: GridContainer = category_template.get_child(1)
					
					if _resources[category].size() <= 0:
						continue
					
					for resource in _resources[category]:
						if resource is EventResource:
							var res: EventResource = resource
							var item_button_template: Button = load("res://addons/event_sheet/elements/Window/next_condition_frame/next_condition_item_button.tscn").instantiate()
							item_button_template.text = res.event_name
							item_button_template.icon = res.event_icon
							if _icon_color:
								item_button_template.add_theme_color_override("icon_normal_color", _icon_color)
								item_button_template.add_theme_color_override("icon_focus_color", _icon_color)
								item_button_template.add_theme_color_override("icon_pressed_color", _icon_color)
								item_button_template.add_theme_color_override("icon_hover_color", _icon_color)
							if !item_button_template.focus_entered.is_connected(_on_select_condition_focus_entered):
								item_button_template.focus_entered.connect(_on_select_condition_focus_entered.bind({
									"button": item_button_template,
									"data": {
										"icon": _icon,
										"icon_color": _icon_color,
										"name": _name,
										"type": _type,
										"conditions_type": _conditions_type,
										"resource": res
									}
								}))
							category_items.add_child(item_button_template)
							item_button_template.owner = category_items.get_owner()
						if resource is ActionResource:
							var res: ActionResource = resource
							var item_button_template: Button = load("res://addons/event_sheet/elements/Window/next_condition_frame/next_condition_item_button.tscn").instantiate()
							item_button_template.name = res.action_name
							item_button_template.icon = res.action_icon
							if _icon_color:
								item_button_template.add_theme_color_override("icon_normal_color", _icon_color)
								item_button_template.add_theme_color_override("icon_focus_color", _icon_color)
								item_button_template.add_theme_color_override("icon_pressed_color", _icon_color)
								item_button_template.add_theme_color_override("icon_hover_color", _icon_color)
							if !item_button_template.focus_entered.is_connected(_on_select_condition_focus_entered):
								item_button_template.focus_entered.connect(_on_select_condition_focus_entered.bind({
									"button": item_button_template,
									"data": {
										"icon": _icon,
										"icon_color": _icon_color,
										"name": _name,
										"type": _type,
										"conditions_type": _conditions_type,
										"resource": res
									}
								}))
							category_items.add_child(item_button_template)
							item_button_template.owner = category_items.get_owner()
					
					items_list.add_child(category_template)
					category_template.owner = items_list.get_owner()

func _on_select_condition_focus_entered(condition_data: Dictionary):
	focused_condition.emit(condition_data)
