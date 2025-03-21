@tool
extends EditorPlugin

const PLUGIN_SETTINGS_PATH := "plugins/event_sheet"
const EventSheet = preload("res://addons/event_sheet/elements/event_sheet/event_sheet.tscn")
var event_sheet_instance

func _enter_tree():
	add_autoload_singleton("EventSheetUtils", "res://addons/event_sheet/source/utils/event_sheet_utils.gd")
	
	ESUtils.undo_redo = get_undo_redo()
	
	if !scene_changed.is_connected(_on_scene_change):
		scene_changed.connect(_on_scene_change)
	
	if !main_screen_changed.is_connected(_on_screen_change):
		main_screen_changed.connect(_on_screen_change)
	
	if ESUtils.scene_tree_editor_tree and !ESUtils.scene_tree_editor_tree.button_clicked.is_connected(_on_scene_tree_button_clicked):
		ESUtils.scene_tree_editor_tree.button_clicked.connect(_on_scene_tree_button_clicked)
	
	event_sheet_instance = EventSheet.instantiate()
	EditorInterface.get_editor_main_screen().add_child(event_sheet_instance)
	_make_visible(false)

func _exit_tree():
	if scene_changed.is_connected(_on_scene_change):
		scene_changed.disconnect(_on_scene_change)
	
	if main_screen_changed.is_connected(_on_screen_change):
		main_screen_changed.disconnect(_on_screen_change)
	
	if ESUtils.scene_tree_editor_tree and ESUtils.scene_tree_editor_tree.button_clicked.is_connected(_on_scene_tree_button_clicked):
		ESUtils.scene_tree_editor_tree.button_clicked.disconnect(_on_scene_tree_button_clicked)
	
	remove_autoload_singleton("EventSheetUtils")
	
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

func _on_scene_change(scene: Node) -> void:
	#if "EventSheet" in scene:
		##print('Changed scene to %s' % (scene.name if scene else "empty"))
		#if ESUtils.is_plugin_screen:
			##open_event_sheet_editor(scene.event_sheet_data, scene)
			#print(scene.name)
	pass

func _on_screen_change(screen_name: String) -> void:
	ESUtils.is_plugin_screen = screen_name == _get_plugin_name()

# Open the “Event Sheet” editor by clicking on the button in the object tree
func _on_scene_tree_button_clicked(item, column: int, id: int, mouse_button_index: int):
	if column == 0 and id == 100 and mouse_button_index == MOUSE_BUTTON_LEFT:
		var node = get_node(item.get_metadata(0))
		open_event_sheet_editor(node.event_sheet_file, node)

func open_event_sheet_editor(event_sheet_file: JSON = null, node = null):
	if event_sheet_instance.current_node != node:
		event_sheet_instance.event_sheet_file = event_sheet_file
		event_sheet_instance.event_sheet_data = event_sheet_file.data
		event_sheet_instance.current_node = node
		event_sheet_instance.load_event_sheet()
	EditorInterface.set_main_screen_editor(_get_plugin_name())
