@tool
extends EditorInspectorPlugin

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

var title_template = load("res://addons/event_sheet/elements/inspector/title.tscn")

signal open_event_sheet_editor

func _can_handle(object: Object) -> bool:
	return object.has_method('_add_inspector_elements')

func _parse_begin(object: Object) -> void:
	var elements_data = object._add_inspector_elements()
	for element_data in elements_data:
		var type = element_data.get("type", null)
		match type:
			"title":
				var title_instance: Panel = title_template.instantiate()
				
				var icon = element_data.get("icon", null)
				var text = element_data.get("text", "Title")
				var tint = element_data.get("tint", Color.WHITE)
				
				title_instance.get_child(0).get_child(0).texture = icon
				if icon: title_instance.get_child(0).get_child(0).visible = true
				else: title_instance.get_child(0).get_child(0).visible = false
				title_instance.get_child(0).get_child(1).text = text
				title_instance.modulate = tint
				
				add_custom_control(title_instance)
			"text":
				var text = element_data.get("text", "Text")
				var alignment = element_data.get("alignment", HORIZONTAL_ALIGNMENT_LEFT)
				var tint = element_data.get("tint", Color.WHITE)
				
				var label = Label.new()
				label.horizontal_alignment = alignment
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.autowrap_mode = TextServer.AUTOWRAP_WORD
				label.text = text
				label.modulate = tint
				
				add_custom_control(label)
			"button":
				var name = element_data.get("name", "Button")
				var tint = element_data.get("tint", Color.WHITE)
				var icon = element_data.get("icon", null)
				var data = element_data.get("data", [])
				var scene = element_data.get("scene", null)
				
				var button = Button.new()
				button.text = name
				button.modulate = tint
				if icon:
					button.icon = icon
					button.expand_icon = true
				button.pressed.connect(_open_event_sheet_editor.bind(data, scene))
				
				add_custom_control(button)
			_: pass

func _open_event_sheet_editor(data, scene = null):
	open_event_sheet_editor.emit(data, scene)
