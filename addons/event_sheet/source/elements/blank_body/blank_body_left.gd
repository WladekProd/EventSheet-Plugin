@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/types.gd")

@onready var panel: PanelContainer = $MarginContainer/HBoxContainer/MarginContainer2/Content

@onready var block_margin: MarginContainer = $MarginContainer
@onready var sub_block_margin: MarginContainer = $MarginContainer/HBoxContainer/MarginContainer
@onready var block_number: Label = $MarginContainer/HBoxContainer/MarginContainer/Number
@onready var show_hide_button: Button = $MarginContainer/HBoxContainer/ShowHide
@onready var sub_block_line: VSeparator = $MarginContainer/HBoxContainer/VSeparator
@onready var selected_panel: Panel = $MarginContainer/HBoxContainer/MarginContainer2/Selected
@onready var content_items = $MarginContainer/HBoxContainer/MarginContainer2/Content/Items

@export var color: Color = Color(1, 1, 1, 0.05):
	set (p_color):
		if p_color != color:
			color = p_color
			if panel:
				var _panel: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
				_panel.bg_color = color
				_panel.draw_center = true
				panel.add_theme_stylebox_override("panel", _panel)

var event_content := preload("res://addons/event_sheet/elements/blank_body/content/blank_events.tscn")
var group_content := preload("res://addons/event_sheet/elements/blank_body/content/blank_group.tscn")

var content
var blank_body_right: VBoxContainer
var blank_body_type: Types.BlockType = -1:
	set (p_blank_body_type):
		if p_blank_body_type != blank_body_type:
			blank_body_type = p_blank_body_type
			match blank_body_type:
				Types.BlockType.STANDART:
					if content_items:
						var _event_content = event_content.instantiate()
						content_items.add_child(_event_content)
						content = _event_content
						if !content.resized.is_connected(_on_content_resized):
							content.resized.connect(_on_content_resized)
						color = Color(1, 1, 1, 0.05)
				Types.BlockType.GROUP:
					if content_items:
						var _group_content = group_content.instantiate()
						content_items.add_child(_group_content)
						content = _group_content
						color = Color(1, 1, 1, 0.055)

var block: BlockResource:
	set (p_block):
		block = p_block
		fix_margin_container()

var is_mouse_entered: bool = false
var is_selected: bool = false

signal dragged_block

@export var sub_blocks_state: Types.SubBlocksState = Types.SubBlocksState.NONE:
	set (p_sub_blocks_state):
		sub_blocks_state = p_sub_blocks_state
		if show_hide_button:
			match sub_blocks_state:
				Types.SubBlocksState.NONE:
					show_hide_button.disabled = block.sub_blocks.is_empty()
					show_hide_button.icon = null if block.sub_blocks.is_empty() else load("res://addons/event_sheet/resources/icons/hide.svg")
					sub_blocks_visible(true)
				Types.SubBlocksState.VISIBLE:
					show_hide_button.disabled = false
					show_hide_button.icon = load("res://addons/event_sheet/resources/icons/hide.svg")
					sub_blocks_visible(true)
				Types.SubBlocksState.HIDDEN:
					show_hide_button.disabled = false
					show_hide_button.icon = load("res://addons/event_sheet/resources/icons/show.svg")
					sub_blocks_visible(false)

func _ready() -> void:
	fix_margin_container()
	show_hide_button.icon = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_selected = is_mouse_entered
			selected_panel.visible = is_selected

func update_y_size():
	if content and blank_body_right and blank_body_right.content:
		var y_size = blank_body_right.content.size.y
		content.custom_minimum_size.y = y_size
		content.size.y = y_size

func fix_margin_container():
	var split_name = name.split(" | ")
	var block_level: int
	
	if split_name.size() > 1:
		block_level = int(split_name[1])
	
	var space: float = (show_hide_button.size.x + sub_block_line.size.x)
	var fix_space: float = (space * block_level)
	sub_block_margin.add_theme_constant_override("margin_right", fix_space)

func sub_blocks_visible(_visible: bool = true):
	for event_child in get_children():
		if event_child is VBoxContainer:
			event_child.visible = _visible
			event_child.blank_body_right.visible = _visible

func update_sub_block_line_size():
	if sub_block_line and block_margin and content and block:
		match sub_blocks_state:
			Types.SubBlocksState.NONE:
				sub_block_line.visible = false if block.sub_blocks.is_empty() else true
			Types.SubBlocksState.VISIBLE:
				sub_block_line.visible = true
			Types.SubBlocksState.HIDDEN:
				sub_block_line.visible = false
		var line_stylebox: StyleBoxFlat = sub_block_line.get_theme_stylebox("separator").duplicate()
		line_stylebox.border_width_top = (content.size.y + block_margin.get_theme_constant("margin_top"))
		line_stylebox.expand_margin_bottom = (size.y - block_margin.get_theme_constant("margin_top"))
		sub_block_line.add_theme_stylebox_override("separator", line_stylebox)

func _on_resized() -> void:
	update_sub_block_line_size()

func _on_content_resized() -> void:
	update_y_size()
	if blank_body_right: blank_body_right.update_y_size()

func _on_show_hide_pressed() -> void:
	sub_blocks_state = Types.SubBlocksState.HIDDEN if sub_blocks_state == Types.SubBlocksState.NONE or sub_blocks_state == Types.SubBlocksState.VISIBLE else Types.SubBlocksState.VISIBLE
	block.sub_blocks_state = sub_blocks_state
