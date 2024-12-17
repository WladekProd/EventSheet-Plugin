@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

var sub_level: int = 0
var line_number: int = 0

# Update Event Blocks
func update_events(root_event: VBoxContainer = self):
	var parent: VBoxContainer
	if "expand" in root_event.get_parent():
		parent = root_event.get_parent()
		sub_level = parent.level
	else:
		parent = root_event
		sub_level = 0
	update_child_events(parent)

# Update child event blocks
func update_child_events(node: Node, index: int = 0) -> void:
	node.level = sub_level + index
	if "expand" in node: node.expand = node.expand
	for child in node.get_children():
		if child is VBoxContainer and "expand" in child:
			update_child_events(child, index + 1)

# Update lines numbering
func update_lines():
	line_number = 0
	update_line()

# Update child lines
func update_line(node: Node = self):
	if node is VBoxContainer and "type" in node:
		if node.type != "comment" or node.type != "variable":
			node.block_number = line_number
	for child in node.get_children():
		if child is VBoxContainer and "type" in child:
			if child.type == "comment" or child.type == "variable":
				continue
			line_number += 1
			update_line(child)
