@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

var group_item := preload("res://addons/event_sheet/elements/blocks/conditions/group.tscn")
var comment_item := preload("res://addons/event_sheet/elements/blocks/conditions/comment.tscn")
var variable_item := preload("res://addons/event_sheet/elements/blocks/conditions/variable.tscn")
var class_item := preload("res://addons/event_sheet/elements/blocks/conditions/class.tscn")

# Standart block elements
@onready var block_margin: MarginContainer = $MarginContainer/Block/MarginContainer
@onready var block_number_text: Label = $MarginContainer/Block/MarginContainer/Number
@onready var block_expand_button: Button = $MarginContainer/Block/Expand
@onready var block_line: VSeparator = $MarginContainer/Block/Line
@onready var block_select: PanelContainer = $MarginContainer/Block/BlockSelect
@onready var block_body: Container = $MarginContainer/Block/BlockSelect/HSplitContainer
@onready var block_drag_button: TextureRect = $MarginContainer/Block/BlockSelect/HSplitContainer/Events/Content/Events/DragTrigger
@onready var block_events: VBoxContainer = $MarginContainer/Block/BlockSelect/HSplitContainer/Events/Content/Events/Items
@onready var block_events_panel: PanelContainer = $MarginContainer/Block/BlockSelect/HSplitContainer/Events/Content
@onready var block_actions: VBoxContainer = $MarginContainer/Block/BlockSelect/HSplitContainer/Actions/Content/HBoxContainer/Actions/Items
@onready var block_actions_panel: PanelContainer = $MarginContainer/Block/BlockSelect/HSplitContainer/Actions/Content
@onready var block_split: TextureButton = $MarginContainer/Block/BlockSelect/HSplitContainer/Actions/Content/HBoxContainer/VSplit
@onready var block_add_action_button: Button = $MarginContainer/Block/BlockSelect/HSplitContainer/Actions/Content/HBoxContainer/Actions/MarginContainer/AddAction

@onready var other_body: MarginContainer = $MarginContainer/Block/BlockSelect/Other
@onready var other_drag_button: TextureRect = $MarginContainer/Block/BlockSelect/Other/Content/Other/DragTrigger
@onready var other_drop_container: Control = $MarginContainer/Block/BlockSelect/Other/DropContainer
@onready var other_items: VBoxContainer = $MarginContainer/Block/BlockSelect/Other/Content/Other/Items
@onready var other_panel: PanelContainer = $MarginContainer/Block/BlockSelect/Other/Content

# Block variables
var uuid: String

var block_number: int = 0:
	set (p_block_number):
		block_number = p_block_number
		block_number_text.text = str(block_number)

var is_hovered: bool = false

@export var data: Dictionary:
	set (p_data):
		data = p_data
		if !data.is_empty():
			
			uuid = data.uuid
			type = data.type
			level = data.level
			
			match type:
				"standart":
					expand = data.expand
				"variable":
					expand = false
				"class":
					expand = false
				"comment":
					expand = false
				"group":
					expand = data.expand
			
			if other_items != null and other_items.get_child_count() > 0:
				if other_items.get_child(0) != null:
					other_items.get_child(0).data = data
			_on_theme_changed()

@export var type: String = "standart":
	set (p_type):
		type = p_type
		if block_body != null and other_body != null:
			match type:
				"standart":
					block_body.visible = true
					other_body.queue_free()
					if other_items.get_child_count() >= 1: other_items.get_child(0).queue_free()
					other_drop_container.drop_types = 28
				_:
					block_body.queue_free()
					other_body.visible = true
					if other_items.get_child_count() >= 1: other_items.get_child(0).queue_free()
					other_drop_container.drop_types = 28

					if type == "group":
						var _group = group_item.instantiate()
						other_items.add_child(_group)
						_group.block_body = self
						_group.data = data
						other_drop_container.drop_types = 28
					elif type == "comment":
						var _comment = comment_item.instantiate()
						other_items.add_child(_comment)
						_comment.block_body = self
						_comment.data = data
						other_drop_container.drop_types = 12
					elif type == "variable":
						var _variable = variable_item.instantiate()
						other_items.add_child(_variable)
						_variable.block_body = self
						_variable.data = data
						other_drop_container.drop_types = 12
					elif type == "class":
						var _class = class_item.instantiate()
						other_items.add_child(_class)
						_class.block_body = self
						_class.data = data
						other_drop_container.drop_types = 12
		_on_theme_changed()

@export var level: int = 0:
	set (p_level):
		level = p_level
		if block_margin != null:
			block_margin.add_theme_constant_override("margin_right", (block_expand_button.size.x + block_line.size.x) * level)
		if !data.is_empty():
			data.level = level
		update_split_container()

@export var expand: bool:
	set (p_expand):
		expand = p_expand
		if block_expand_button != null and !data.is_empty():
			if !data.has("childrens") or data.childrens.is_empty():
				block_expand_button.disabled = true
				block_expand_button.modulate = Color.TRANSPARENT
				block_line.modulate = Color.TRANSPARENT
			else:
				block_expand_button.disabled = false
				if expand:
					block_expand_button.icon = load("res://addons/event_sheet/resources/icons/hide.svg")
					block_expand_button.modulate = Color.WHITE
					block_line.modulate = Color.WHITE
				else:
					block_expand_button.icon = load("res://addons/event_sheet/resources/icons/show.svg")
					block_expand_button.modulate = Color.WHITE
					block_line.modulate = Color.TRANSPARENT
			
			for _child in get_children():
				if _child is VBoxContainer:
					_child.visible = expand

@export var events_color: Color = Color.WEB_MAROON:
	set (p_events_color):
		events_color = p_events_color
		if block_body != null and block_events_panel:
			var stylebox: StyleBoxFlat = block_events_panel.get_theme_stylebox("panel")
			stylebox.bg_color = events_color
@export var actions_color: Color = Color.CRIMSON:
	set (p_actions_color):
		actions_color = p_actions_color
		if block_body != null and block_actions_panel:
			var stylebox: StyleBoxFlat = block_actions_panel.get_theme_stylebox("panel")
			stylebox.bg_color = actions_color
@export var other_color: Color = Color.CORAL:
	set (p_other_color):
		other_color = p_other_color
		if other_body != null and other_panel:
			var stylebox: StyleBoxFlat = other_panel.get_theme_stylebox("panel")
			stylebox.bg_color = other_color

@export var is_selected: bool = false:
	set (p_is_selected):
		is_selected = p_is_selected
		if block_body != null and block_events_panel:
			block_events_panel.material.set("shader_parameter/is_active", is_selected)
		if block_body != null and block_actions_panel:
			block_actions_panel.material.set("shader_parameter/is_active", is_selected)
		if other_body != null and other_panel:
			other_panel.material.set("shader_parameter/is_active", is_selected)

signal select
signal change
signal add_action
signal drop_data

func _ready() -> void:
	add_to_group("blocks")
	update_split_container()

func update_split_container():
	if block_body != null:
		if get_tree().get_node_count_in_group("splits") > 0:
			var _first_node = get_tree().get_first_node_in_group("splits")
			block_body.drag_offset = _first_node.drag_offset
			block_body.column_sizes = _first_node.column_sizes
		block_body.padding = block_margin.get_theme_constant("margin_right")

func _select():
	if ESUtils.is_ctrl_pressed:
		if ESUtils.selection_is_equal_to_type(data): ESUtils.unselect_all()
		if is_selected: return
	
	if !ESUtils.has_item_in_select(self) and !is_selected:
		ESUtils.selected_items.append({ "number": block_number, "object": self, "class": "Block" })
		ESUtils.sort_selected_items_by_block_number()
	
	EditorInterface.get_selection().clear()
	
	ESUtils.selected_class = get_class()
	ESUtils.hovered_select = self
	is_selected = true
	is_hovered = true
	select_all_childs()
	
	print(ESUtils.selected_items)

func select_all_childs(parent: VBoxContainer = self):
	for child_empty_block in parent.get_children():
		if "is_selected" in child_empty_block:
			if child_empty_block.is_selected:
				ESUtils.unselect_item(child_empty_block.uuid)
			child_empty_block.is_selected = is_selected
			select_all_childs(child_empty_block)

func _on_select_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ESUtils.is_dragging_finished = false
			_select()
		elif event.is_released():
			ESUtils.is_dragging_finished = true
			
			select.emit({ "body": self, "type": type, "data": data })

func _on_block_resized() -> void:
	if block_line != null and !ESUtils.is_split_pressed:
		var _stylebox_line: StyleBoxLine = block_line.get_theme_stylebox("separator")
		_stylebox_line.grow_begin = -(block_select.size.y + $MarginContainer.get_theme_constant("margin_top"))
		_stylebox_line.grow_end = (size.y - $MarginContainer.get_theme_constant("margin_top"))

func _on_expand_pressed() -> void:
	expand = !expand
	data.expand = expand

func _on_add_action_button_up() -> void:
	add_action.emit(data)

func _on_theme_changed() -> void:
	var _events_color: Color = EditorInterface.get_editor_theme().get_color("dark_color_1", "Editor")
	var _actions_color: Color = EditorInterface.get_editor_theme().get_color("dark_color_3", "Editor")
	var _other_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	
	var _select_events_color: Color = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	var _select_actions_color: Color = EditorInterface.get_editor_theme().get_color("disabled_bg_color", "Editor")
	var _select_other_color: Color = EditorInterface.get_editor_theme().get_color("icon_pressed_color", "Editor")
	
	events_color = _events_color
	actions_color = _actions_color
	other_color = _other_color
	
	if type == "group":
		other_color.a = 0.2
	elif type == "comment":
		other_color.a = 0.1
	elif type == "variable":
		other_color.a = 0.0
	elif type == "class":
		other_color.a = 0.0

func _on_v_split_mouse_entered() -> void:
	ESUtils.is_split_hovered = true

func _on_v_split_mouse_exited() -> void:
	ESUtils.is_split_hovered = false

func _on_mouse_entered() -> void:
	if is_selected:
		is_hovered = true
		ESUtils.hovered_select = self

func _on_mouse_exited() -> void:
	if is_selected:
		is_hovered = false
		ESUtils.hovered_select = null

func _on_child_entered_tree(node: Node) -> void:
	if "block_type" in node:
		node.visible = true if expand else false
