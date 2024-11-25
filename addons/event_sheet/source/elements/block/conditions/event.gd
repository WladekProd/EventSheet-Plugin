@tool
extends Button

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _object_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _parameters_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event
@onready var _parameters_string_rich: RichTextLabel = $MarginContainer/HBoxContainer/HSplitContainer/EventRich
@onready var _drag_and_drop: Control = $"MarginContainer/Drag&Drop"

var id: String
var empty_block

var is_dragged: bool = false
var is_hovered: bool = false

signal drop_data

var resource: EventResource:
	set (p_resource):
		resource = p_resource
		
		if resource.pick_object.has("object") and resource.pick_object.object != null:
			if resource.pick_object.has("icon"): _icon.texture = resource.pick_object.icon
			if resource.pick_object.has("name"): _object_name.text = resource.pick_object.name
		else:
			_icon.texture = resource.icon
			_object_name.text = resource.pick_object.name
		
		var _info_string: String = resource.gd_script.get_info(resource.parameters)
		_parameters_string.text = _info_string
		_parameters_string_rich.text = _info_string
		if is_instance_valid(self): _on_theme_changed()

func _ready() -> void:
	pass

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ESUtils.is_dragging_finished = false
			if !button_pressed:
				_select()
			else: is_dragged = true
		elif event.is_released():
			if !ESUtils.is_ctrl_pressed and !is_hovered:
				is_dragged = true
			if is_dragged:
				ESUtils.unselect_all()
			ESUtils.is_dragging_finished = true
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			empty_block.change.emit(resource, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			empty_block.context_menu.emit()

func _on_theme_changed() -> void:
	if resource and resource.pick_object and !resource.pick_object.object:
		var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
		if _icon and _icon.modulate != accent_color:
			_icon.modulate = accent_color
	else:
		if _icon and _icon.modulate != Color.WHITE:
			_icon.modulate = Color.WHITE

func _select() -> void:
	if ESUtils.is_ctrl_pressed and ESUtils.selection_is_equal_to_type(resource):
		ESUtils.unselect_all()
	
	if button_pressed:
		for i in ESUtils.selected_items.size():
			if ESUtils.selected_items[i].number == get_index():
				ESUtils.selected_items.remove_at(i)
				button_pressed = false
				return
	
	EditorInterface.get_selection().clear()
	
	if !ESUtils.has_item_in_select(self) and !button_pressed:
		ESUtils.selected_items.append({ "number": get_index(), "object": self, "class": "Event" })
		ESUtils.sort_selected_items_by_block_number()
	
	ESUtils.selected_class = get_class()
	ESUtils.hovered_select = self
	button_pressed = true
	is_hovered = true

func _on_mouse_entered() -> void:
	if button_pressed:
		is_hovered = true
		ESUtils.hovered_select = self

func _on_mouse_exited() -> void:
	if button_pressed:
		is_hovered = false
		ESUtils.hovered_select = null

func _get_drag_data(at_position: Vector2) -> Button:
	ESUtils.is_dragging = true
	ESUtils.dragging_data = {
		"object": self,
		"class": "Event"
	}
	return self
