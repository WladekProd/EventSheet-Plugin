@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var panel: Panel = $MarginContainer/Panel
@onready var content_items = $MarginContainer/Content

@export var color: Color = Color(0, 0, 0, 0.1):
	set (p_color):
		if p_color != color:
			color = p_color
			if panel:
				var _panel: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
				_panel.bg_color = color
				_panel.draw_center = true
				panel.add_theme_stylebox_override("panel", _panel)

var action_content := preload("res://addons/event_sheet/elements/blank_body/content/blank_actions.tscn")

var content
var blank_body_left: VBoxContainer
var blank_body_type: Types.BlockType = -1:
	set (p_blank_body_type):
		if p_blank_body_type != blank_body_type:
			blank_body_type = p_blank_body_type
			match blank_body_type:
				Types.BlockType.STANDART:
					if content_items:
						var _action_content = action_content.instantiate()
						content_items.add_child(_action_content)
						content = _action_content
						if !content.add_action_button.button_up.is_connected(_on_add_action_button_up):
							content.add_action_button.button_up.connect(_on_add_action_button_up)
						if !content.resized.is_connected(_on_content_resized):
							content.resized.connect(_on_content_resized)
						color = Color(0, 0, 0, 0.15)
				Types.BlockType.GROUP:
					color = Color(1, 1, 1, 0.055)

var block: BlockResource

signal add_action_button_up

func _ready() -> void:
	pass

func update_y_size():
	if content and blank_body_left and blank_body_left.content:
		var y_size = blank_body_left.content.size.y
		content.custom_minimum_size.y = y_size
		content.size.y = y_size

func _on_content_resized() -> void:
	update_y_size()
	if blank_body_left: blank_body_left.update_y_size()

func _on_add_action_button_up() -> void:
	add_action_button_up.emit(block)
