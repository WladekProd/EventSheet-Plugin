@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

@onready var comment_text: LineEdit = $CommentButton/MarginContainer/HBoxContainer/Comment
@onready var comment_button: Button = $CommentButton

@export var color: Color:
	set (p_color):
		if p_color != color:
			color = p_color

var block_body

var is_focused: bool = false

var data: Dictionary:
	set (p_data):
		data = p_data
		comment_text.text = block_body.data.parameters.comment_text

func _input(event: InputEvent) -> void:
	if comment_text.editable and ESUtils.is_plugin_screen:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !is_focused:
				if comment_button.is_hovered():
					EditorInterface.get_selection().clear()
					comment_button.grab_focus()
				ESUtils.is_editing = false
				block_body.data.parameters.comment_text = comment_text.text
				ESUtils.save_event_sheet_data()
				comment_text.editable = false
				comment_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if event is InputEventKey:
			if event.keycode == KEY_ENTER and event.pressed:
				ESUtils.is_editing = false
				block_body.data.parameters.comment_text = comment_text.text
				ESUtils.save_event_sheet_data()
				comment_text.editable = false
				comment_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
			elif event.keycode == KEY_ESCAPE and event.pressed:
				ESUtils.is_editing = false
				comment_text.text = block_body.data.parameters.comment_text
				comment_text.editable = false
				comment_text.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")

func _on_theme_changed() -> void:
	var accent_color: Color = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	if color != accent_color:
		color = accent_color

func _on_gui_input(event: InputEvent) -> void:
	if !comment_text.editable and ESUtils.is_plugin_screen:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
				ESUtils.is_editing = true
				comment_text.editable = true
				comment_text.mouse_filter = Control.MOUSE_FILTER_STOP
				comment_text.select_all()
				comment_text.grab_focus()

func _on_comment_mouse_entered() -> void:
	is_focused = true

func _on_comment_mouse_exited() -> void:
	is_focused = false

#func _on_focus_entered() -> void:
	#empty_block.panel.focus_entered.emit()
#
#func _on_focus_exited() -> void:
	#empty_block.panel.focus_exited.emit()
