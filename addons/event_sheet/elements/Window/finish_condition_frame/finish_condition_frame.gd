@tool
extends Control

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var condition_description: Label = $MarginContainer/ScrollContainer/VBoxContainer/ConditionDescription
@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/Parameters

signal finished_condition
var finished_button_up: Button
var finished_data: Dictionary = {
	"data": {
		"condition": null,
		"resource": null
	}
}

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
			
			finished_data.data.condition = _conditions_type
			finished_data.data.resource = conditions["resource"]
			
			var _resource = finished_data.data.resource
			if _resource is EventResource:
				condition_description.text = "{0}: {1}".format([_name, _resource.event_description])
				
				if _resource.event_params.size() <= 0:
					finished_condition.emit(finished_data)
					return
				else:
					for p_key in _resource.event_params.keys():
						var p_name: String = _resource.event_params[p_key].name
						var p_value: String = _resource.event_params[p_key].value
					
						var string_item_template: HBoxContainer = load("res://addons/event_sheet/elements/window/finish_condition_frame/finish_condition_string_patameter.tscn").instantiate()
						string_item_template.name = p_key
						
						var parameter_name: Label = string_item_template.get_child(0)
						parameter_name.text = p_name
						
						var parameter_value: LineEdit = string_item_template.get_child(1)
						parameter_value.text_changed.connect(_on_parameter_edited)
						parameter_value.text = p_value
						
						items_list.add_child(string_item_template)
						string_item_template.owner = items_list.get_owner()
			
			if _resource is ActionResource:
				condition_description.text = "{0}: {1}".format([_name, _resource.action_description])
				
				if _resource.action_params.size() <= 0:
					finished_condition.emit(finished_data)
					return
				else:
					for p_key in _resource.action_params.keys():
						var p_name: String = _resource.action_params[p_key].name
						var p_value: String = _resource.action_params[p_key].value
					
						var string_item_template: HBoxContainer = load("res://addons/event_sheet/elements/window/finish_condition_frame/finish_condition_string_patameter.tscn").instantiate()
						string_item_template.name = p_key
						
						var parameter_name: Label = string_item_template.get_child(0)
						parameter_name.text = p_name
						
						var parameter_value: LineEdit = string_item_template.get_child(1)
						parameter_value.text_changed.connect(_on_parameter_edited)
						parameter_value.text = p_value
						
						items_list.add_child(string_item_template)
						string_item_template.owner = items_list.get_owner()
			
			if !finished_button_up.button_up.is_connected(_on_finished_button_up):
				finished_button_up.button_up.connect(_on_finished_button_up)
	
	items_list.fix_items_size()

func _on_parameter_edited(new_text: String):
	for child in items_list.get_children():
		var parameter_name: String = child.name
		var parameter_value: LineEdit = child.get_child(1)
		if finished_data.data.resource is EventResource:
			finished_data.data.resource.event_params[parameter_name].value = parameter_value.text
		if finished_data.data.resource is ActionResource:
			finished_data.data.resource.action_params[parameter_name].value = parameter_value.text

func _on_finished_button_up():
	finished_condition.emit(finished_data)
