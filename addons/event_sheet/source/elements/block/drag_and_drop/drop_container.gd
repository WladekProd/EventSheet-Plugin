@tool
extends Control

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var background: Panel = $DropBackground
@onready var drag_up: Panel = $VBoxContainer/DropUp
@onready var drag_down: Panel = $VBoxContainer/HBoxContainer/DropDown
@onready var drag_sub: Panel = $VBoxContainer/HBoxContainer/DropSub

@export var drop_object: Node
@export var drop_class: String = ""
@export_flags("Up:4", "Down:8", "Sub:16") var drop_types: int = 0:
	set (p_drop_types):
		drop_types = p_drop_types
		_update_buttons()

func _ready() -> void:
	add_to_group("Drag&Drop")
	mouse_filter = MOUSE_FILTER_IGNORE
	modulate = Color.TRANSPARENT
	drag_up.modulate = Color.TRANSPARENT
	drag_down.modulate = Color.TRANSPARENT
	drag_sub.modulate = Color.TRANSPARENT
	_update_buttons()

func _update_buttons():
	if drag_up == null or drag_down == null or drag_sub == null:
		return
	
	drag_up.visible = (drop_types & 4) != 0
	drag_down.visible = (drop_types & 8) != 0
	drag_sub.visible = (drop_types & 16) != 0
	
	drag_up.mouse_filter = Control.MOUSE_FILTER_IGNORE if !ESUtils.is_dragging else Control.MOUSE_FILTER_STOP
	drag_down.mouse_filter = Control.MOUSE_FILTER_IGNORE if !ESUtils.is_dragging else Control.MOUSE_FILTER_STOP
	drag_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE if !ESUtils.is_dragging else Control.MOUSE_FILTER_STOP


func _on_drop_up_mouse_entered() -> void:
	if ESUtils.is_dragging:
		if ESUtils.dragging_data and ESUtils.dragging_data.class == drop_class and ESUtils.dragging_data.object != drop_object:
			if "is_selected" in drop_object and drop_object.is_selected: return
			if "button_pressed" in drop_object and drop_object.button_pressed: return
			modulate = Color.WHITE
			drag_up.modulate = Color.WHITE

func _on_drop_down_mouse_entered() -> void:
	if ESUtils.is_dragging:
		if ESUtils.dragging_data and ESUtils.dragging_data.class == drop_class and ESUtils.dragging_data.object != drop_object:
			if "is_selected" in drop_object and drop_object.is_selected: return
			if "button_pressed" in drop_object and drop_object.button_pressed: return
			modulate = Color.WHITE
			drag_down.modulate = Color.WHITE

func _on_drop_sub_mouse_entered() -> void:
	if ESUtils.is_dragging:
		if ESUtils.dragging_data and ESUtils.dragging_data.class == drop_class and ESUtils.dragging_data.object != drop_object:
			if "is_selected" in drop_object and drop_object.is_selected: return
			if "button_pressed" in drop_object and drop_object.button_pressed: return
			modulate = Color.WHITE
			drag_sub.modulate = Color.WHITE


func _on_drop_up_mouse_exited() -> void:
	modulate = Color.TRANSPARENT
	drag_up.modulate = Color.TRANSPARENT

func _on_drop_down_mouse_exited() -> void:
	modulate = Color.TRANSPARENT
	drag_down.modulate = Color.TRANSPARENT

func _on_drop_sub_mouse_exited() -> void:
	modulate = Color.TRANSPARENT
	drag_sub.modulate = Color.TRANSPARENT
