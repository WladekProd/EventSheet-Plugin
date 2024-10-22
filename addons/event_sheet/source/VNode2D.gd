@tool
extends Node2D
class_name VNode2D

const Types = preload("res://addons/event_sheet/source/types.gd")
const Generation = preload("res://addons/event_sheet/source/Generation.gd")

signal open_event_sheet

@export var event_sheet_data: Array[BlockResource]
#var final_script: Node

func _add_inspector_elements() -> Array:
	var elements = []
	elements.push_back({
		"type": "title",
		#"icon": EditorInterface.get_editor_theme().get_icon("Node2D", "EditorIcons"),
		"text": "[b]Event Sheet[/b]",
		"tint": Color.PALE_GREEN
	})
	elements.push_back({
		"type": "text",
		"text": "Object with visual script Event Sheet\nClick “Open Event Sheet” to edit",
		"alignment": HORIZONTAL_ALIGNMENT_CENTER,
		"tint": Color.WHITE
	})
	elements.push_back({
		"type": "button",
		"name": "Open Event Sheet",
		"tint": Color.HOT_PINK,
		"data": event_sheet_data,
		"scene": self
	})
	return elements

func _init() -> void:
	#if final_script: final_script.call("__init")
	pass

func _ready() -> void:
	#var code: String = Generation.generate_code(event_sheet)
	#
	#$CodeEdit.text = code
	
	#var script = GDScript.new()
	#script.source_code = code
	#script.reload()
	#final_script = script.new()
	#final_script.set_meta("cur_scene", self)
	#
	#if final_script: final_script.call("__ready")
	pass

func _process(delta: float) -> void:
	#if final_script: final_script.call("__process", delta)
	pass
