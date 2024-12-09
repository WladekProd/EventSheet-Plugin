@tool
extends Node

signal open_event_sheet

@export var event_sheet_file: JSON
var global_block_id: int = 0
@export var final_script: GDScript

#@export var button: bool:
	#set (p_button):
		#button = p_button
		#
		#var test = ESUtils.find_child_by_class(ESUtils.scene_tree_editor, 'SceneTreeEditor')
		#var top_menu: HBoxContainer = ESUtils.scene_tree_dock.get_children()[0]
		#
		#var _add_event_button: Button = top_menu.get_node_or_null("AddEventSheetButton")
		#if _add_event_button:
			#_add_event_button.free()
		#
		#var add_event_sheed_button: Button = top_menu.get_children()[top_menu.get_child_count() - 2].duplicate()
		#add_event_sheed_button.name = "AddEventSheetButton"
		#top_menu.add_child(add_event_sheed_button)
		#top_menu.move_child(add_event_sheed_button, top_menu.get_child_count() - 2)

var _changed_item: TreeItem = null
func update_scene_tree(item: TreeItem):
	var _button_index: int
	if _changed_item != null:
		_button_index = _changed_item.get_button_by_id(0, 100)
		return
	if _changed_item == null or _button_index == -1:
		if item:
			var node: Node = get_node(item.get_metadata(0))
			var icon: ImageTexture = item.get_icon(0)
			var text: String = item.get_text(0)
			if "_changed_item" in node:
				var buttons: Array = []
				for button_id in range(item.get_button_count(0) - 1, -1, -1):
					buttons.append({
						"texture": item.get_button(0, button_id),
						"color": item.get_button_color(0, button_id),
						"id": item.get_button_id(0, button_id),
						"tooltip": item.get_button_tooltip_text(0, button_id),
						"disabled": item.is_button_disabled(0, button_id)
					})
					item.erase_button(0, button_id)
				buttons.reverse()
				var index: int = 0
				for button in buttons:
					if button.texture == EditorInterface.get_editor_theme().get_icon("Script", "EditorIcons"):
						item.add_button(0, load("res://addons/event_sheet/resources/icons/event_sheet_small.png"), 100)
						item.set_button_color(0, index, button.color)
						item.set_button_tooltip_text(0, index, "Open in EventSheet")
						_changed_item = item
					else:
						item.add_button(0, button.texture, button.id)
						item.set_button_tooltip_text(0, index, button.tooltip)
						item.set_button_color(0, index, button.color)
						item.set_button_disabled(0, index, button.disabled)
					index += 1
		for child in item.get_children():
			update_scene_tree(child)

func _ready() -> void:
	if !Engine.is_editor_hint():
		set_script(final_script)

func _process(delta: float) -> void:
	if ESUtils.scene_tree_editor_tree: update_scene_tree(ESUtils.scene_tree_editor_tree.get_root())
