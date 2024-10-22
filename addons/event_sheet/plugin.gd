@tool
extends EditorPlugin

var inspector_elements

const EventSheet = preload("res://addons/event_sheet/elements/EventSheet/event_sheet.tscn")
var event_sheet_instance

const PLUGIN_PATH := "plugins/event_sheet/shortcut"
var shortcut_res: Shortcut = preload("res://addons/event_sheet/default_shortcut.tres")
var shortcut: Shortcut

func _enter_tree():
	inspector_elements = preload("res://addons/event_sheet/source/elements/inspector/inspector.gd").new()
	inspector_elements.open_event_sheet_editor.connect(open_event_sheet_editor)
	add_inspector_plugin(inspector_elements)
	
	add_autoload_singleton("WES", "res://addons/event_sheet/source/Autoload.gd")
	shortcut = set_shortcut(PLUGIN_PATH, shortcut_res)
	
	event_sheet_instance = EventSheet.instantiate()
	EditorInterface.get_editor_main_screen().add_child(event_sheet_instance)
	_make_visible(false)

func _exit_tree():
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
	return EditorInterface.get_editor_theme().get_icon("Favorites", "EditorIcons")

func set_shortcut(project_setting_path: String, resource: Shortcut) -> Shortcut:
	EditorInterface.get_editor_settings().set_setting(PLUGIN_PATH, resource)
	return resource

func open_event_sheet_editor(data: Array[BlockResource] = [], scene = null):
	print(scene)
	print(data)
	event_sheet_instance.event_sheet_data = data
	event_sheet_instance.current_scene = scene
	EditorInterface.set_main_screen_editor(_get_plugin_name())
