@tool
extends Button

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var _object_name: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var _parameters_string: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event
@onready var _parameters_string_rich: RichTextLabel = $MarginContainer/HBoxContainer/HSplitContainer/EventRich
@onready var _drag_and_drop: Control = $"MarginContainer/Drag&Drop"

var uuid: String
var block_body

var is_dragged: bool = false
var is_hovered: bool = false

signal drop_data

var data: Dictionary:
	set (p_data):
		if !p_data.is_empty():
			data = p_data
			
			uuid = data.uuid
			type = data.type
			
			match type:
				"standart":
					var _script = load(data.script)
					var _object = data.object.path
					var _parameters = data.parameters
					
					var _info_string: String = _script.get_info(data.parameters)
					_parameters_string.text = _info_string
					_parameters_string_rich.text = _info_string
					
					var _object_metadata: Dictionary = _script.get_object_metadata(_object)
					var _condition_metadata: Dictionary = _script.get_condition_metadata()
					if _object_metadata.icon:
						change_icon_color = _object_metadata.change_icon_color
						_icon.texture = _object_metadata.icon
					elif _condition_metadata.icon:
						change_icon_color = _condition_metadata.change_icon_color
						_icon.texture = _condition_metadata.icon
					else:
						_icon.texture = null
					
					_object_name.text = _object_metadata.name
		
		if is_instance_valid(self): _on_theme_changed()

var change_icon_color: bool = false

var type: String

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
			block_body.change.emit(data, self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			block_body.context_menu.emit()

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if change_icon_color: if _icon: _icon.modulate = accent_color
	else: if _icon: _icon.modulate = Color.WHITE

func _select() -> void:
	if ESUtils.is_ctrl_pressed and ESUtils.selection_is_equal_to_type(data):
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
