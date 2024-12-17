@tool
extends Node

signal open_event_sheet

@export var event_sheet_file: JSON
var global_block_id: int = 0
@export var final_script: GDScript

# Run the ready script at game startup
func _ready() -> void:
	if !Engine.is_editor_hint():
		set_script(final_script)

# Add the button to open “Event Sheet” to the object tree
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

func _process(delta: float) -> void:
	if ESUtils.scene_tree_editor_tree: update_scene_tree(ESUtils.scene_tree_editor_tree.get_root())
