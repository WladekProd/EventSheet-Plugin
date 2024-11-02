@tool
extends EditorPlugin

var inspector_elements

const EventSheet = preload("res://addons/event_sheet/elements/event_sheet/event_sheet.tscn")
var event_sheet_instance

const PLUGIN_PATH := "plugins/event_sheet/shortcut"
var shortcut_res: Shortcut = preload("res://addons/event_sheet/default_shortcut.tres")
var shortcut: Shortcut

func _enter_tree():
	if !ESUtils.scene_tree_editor_tree.button_clicked.is_connected(_on_scene_tree_button_clicked):
		ESUtils.scene_tree_editor_tree.button_clicked.connect(_on_scene_tree_button_clicked)
	
	inspector_elements = preload("res://addons/event_sheet/source/elements/inspector/inspector.gd").new()
	if !inspector_elements.open_event_sheet_editor.is_connected(open_event_sheet_editor):
		inspector_elements.open_event_sheet_editor.connect(open_event_sheet_editor)
	add_inspector_plugin(inspector_elements)
	
	add_autoload_singleton("WES", "res://addons/event_sheet/source/Autoload.gd")
	shortcut = set_shortcut(PLUGIN_PATH, shortcut_res)
	
	event_sheet_instance = EventSheet.instantiate()
	EditorInterface.get_editor_main_screen().add_child(event_sheet_instance)
	_make_visible(false)

func _exit_tree():
	if ESUtils.scene_tree_editor_tree.button_clicked.is_connected(_on_scene_tree_button_clicked):
		ESUtils.scene_tree_editor_tree.button_clicked.disconnect(_on_scene_tree_button_clicked)
	
	if inspector_elements.open_event_sheet_editor.is_connected(open_event_sheet_editor):
		inspector_elements.open_event_sheet_editor.disconnect(open_event_sheet_editor)
	
	if is_instance_valid(inspector_elements):
		remove_inspector_plugin(inspector_elements)
		inspector_elements = null
	
	remove_autoload_singleton("WES")
	shortcut = null
	EditorInterface.get_editor_settings().erase(PLUGIN_PATH)
	
	if event_sheet_instance:
		event_sheet_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if event_sheet_instance:
		event_sheet_instance.visible = visible

func _get_plugin_name():
	return "EventSheet"

func _get_plugin_icon():
	return load("res://addons/event_sheet/resources/icons/event_sheet_small.png")

func set_shortcut(project_setting_path: String, resource: Shortcut) -> Shortcut:
	EditorInterface.get_editor_settings().set_setting(PLUGIN_PATH, resource)
	return resource

func _on_scene_tree_button_clicked(item, column: int, id: int, mouse_button_index: int):
	if column == 0 and id == 100 and mouse_button_index == MOUSE_BUTTON_LEFT:
		var node = get_node(item.get_metadata(0))
		open_event_sheet_editor(node.event_sheet_data, node)

func open_event_sheet_editor(data: Array[BlockResource] = [], scene = null):
	event_sheet_instance.event_sheet_data = data
	event_sheet_instance.current_scene = scene
	event_sheet_instance.load_event_sheet()
	EditorInterface.set_main_screen_editor(_get_plugin_name())
