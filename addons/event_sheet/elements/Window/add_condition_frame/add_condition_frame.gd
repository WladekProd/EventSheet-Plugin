@tool
extends Control

@onready var items_list: GridContainer = $MarginContainer/ScrollContainer/Items

var item_template: PackedScene = load("res://addons/event_sheet/elements/Window/add_condition_frame/add_condition_item.tscn")

signal focused_condition

func update_items_list(conditions: Array = []) -> void:
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		if conditions.size() > 0:
			for condition in conditions:
				var _icon: Texture2D = condition["icon"]
				var _icon_color: Color = condition["icon_color"]
				var _name: String = condition["name"]
				
				var p_item_template: Button = item_template.instantiate()
				p_item_template.text = _name
				p_item_template.icon = _icon
				if _icon_color:
					p_item_template.add_theme_color_override("icon_normal_color", _icon_color)
					p_item_template.add_theme_color_override("icon_focus_color", _icon_color)
					p_item_template.add_theme_color_override("icon_pressed_color", _icon_color)
					p_item_template.add_theme_color_override("icon_hover_color", _icon_color)
				if !p_item_template.focus_entered.is_connected(_on_select_condition_focus_entered):
					p_item_template.focus_entered.connect(_on_select_condition_focus_entered.bind({
						"button": p_item_template,
						"data": condition
					}))
				items_list.add_child(p_item_template)
				p_item_template.owner = items_list.get_owner()

func _on_select_condition_focus_entered(condition_data: Dictionary):
	focused_condition.emit(condition_data)
