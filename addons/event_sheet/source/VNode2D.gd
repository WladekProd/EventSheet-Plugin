extends Node2D
class_name VNode2D

const Types = preload("res://addons/event_sheet/source/Types.gd")
const Generation = preload("res://addons/event_sheet/source/Generation.gd")

@export var event_sheet: Array[BlockResource]
var final_script: Node

func _init() -> void:
	#if final_script: final_script.call("__init")
	pass

func _ready() -> void:
	var code: String = Generation.generate_code(event_sheet)
	
	$CodeEdit.text = code
	
	#var script = GDScript.new()
	#script.source_code = code
	#script.reload()
	#final_script = script.new()
	#final_script.set_meta("cur_scene", self)
	#
	#if final_script: final_script.call("__ready")

func _process(delta: float) -> void:
	#if final_script: final_script.call("__process", delta)
	pass
