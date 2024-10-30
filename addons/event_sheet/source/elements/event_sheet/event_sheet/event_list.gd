@tool
extends VBoxContainer

var sub_level: int = 0
var line_number: int = 0

func update_events(root_event: VBoxContainer = self):
	var parent: VBoxContainer
	
	if !root_event.get_parent().has_method("sub_blocks_visible"):
		parent = root_event
		sub_level = 0
	else:
		parent = root_event.get_parent()
		sub_level = int(parent.name.split(" | ")[1])
	
	update_child_events(parent)

func update_child_events(node: Node, index: int = 0) -> void:
	node.name = "{0} | {1}".format([node.block.id, sub_level + index])
	node.fix_margin_container()

	for child in node.get_children():
		if child is VBoxContainer and child.has_method("sub_blocks_visible"):
			update_child_events(child, index + 1)

func update_lines():
	line_number = 0
	update_line()

func update_line(node: Node = self):
	
	if node is VBoxContainer and node.has_method("sub_blocks_visible"):
		node.block_number.text = str(line_number)
	
	for child in node.get_children():
		if child is VBoxContainer and child.has_method("sub_blocks_visible"):
			line_number += 1
			update_line(child)
