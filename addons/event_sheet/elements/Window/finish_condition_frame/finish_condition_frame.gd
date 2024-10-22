@tool
extends Control

const Types = preload("res://addons/event_sheet/source/Types.gd")

@onready var condition_description: Label = $MarginContainer/ScrollContainer/VBoxContainer/ConditionDescription
@onready var items_list: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/Parameters

signal finished_condition
var finished_button_up: Button

func update_items_list(conditions: Dictionary = {}) -> void:
	if !finished_button_up.button_up.is_connected(_on_finished_button_up):
		finished_button_up.button_up.connect(_on_finished_button_up)
	
	if items_list:
		for child in items_list.get_children():
			items_list.remove_child(child)
		
		if conditions.size() > 0:
			var _icon: Texture2D = conditions["icon"]
			var _icon_color: Color = conditions["icon_color"]
			var _name: String = conditions["name"]
			var _type: String = conditions["type"]
			var _conditions_type: Types.ConditionType = conditions["conditions_type"]
			var _resource = conditions["resource"]
			var finished_data: Dictionary = {
				"data": {
					"parameters": {},
					"condition": _conditions_type,
					"resource": _resource
				}
			}
			
			if _resource is EventResource:
				condition_description.text = "{0}: {1}".format([_name, _resource.event_description])
				
				var event_script = _resource.event_script.new()
				if event_script.params.size() <= 0:
					finished_condition.emit(finished_data)
				
				var index = 0
				for key: String in event_script.params:
					#var value = _resource.event_params[index]
					var string_item_template: HBoxContainer = load("res://addons/event_sheet/elements/Window/finish_condition_frame/finish_condition_string_patameter.tscn").instantiate()
					#var number_item_template: PackedScene = load("res://addons/event_sheet/elements/Window/finish_condition_frame/finish_condition_number_patameter.tscn")
					
					var parameter_name: Label = string_item_template.get_child(0)
					parameter_name.text = key
					
					items_list.add_child(string_item_template)
					string_item_template.owner = items_list.get_owner()
					
					index += 1
			
			if _resource is ActionResource:
				condition_description.text = "{0}: {1}".format([_name, _resource.action_description])
				
				var action_script = _resource.action_script.new()
				if action_script.params.size() <= 0:
					finished_condition.emit(finished_data)
				
				var index = 0
				for key: String in action_script.params:
					#var value = _resource.event_params[index]
					var string_item_template: HBoxContainer = load("res://addons/event_sheet/elements/Window/finish_condition_frame/finish_condition_string_patameter.tscn").instantiate()
					#var number_item_template: PackedScene = load("res://addons/event_sheet/elements/Window/finish_condition_frame/finish_condition_number_patameter.tscn")
					
					var parameter_name: Label = string_item_template.get_child(0)
					parameter_name.text = key
					
					items_list.add_child(string_item_template)
					string_item_template.owner = items_list.get_owner()
					
					index += 1
	
	items_list.fix_items_size()

func _on_finished_button_up(condition_data: Dictionary):
	finished_condition.emit(condition_data)
