@tool
extends VBoxContainer

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

var sub_level: int = 0
var line_number: int = 0

func update_events(root_event: VBoxContainer = self):
	var parent: VBoxContainer
	if "block_expand" in root_event.get_parent():
		parent = root_event.get_parent()
		sub_level = parent.block_level
	else:
		parent = root_event
		sub_level = 0
	update_child_events(parent)

func update_child_events(node: Node, index: int = 0) -> void:
	node.block_level = sub_level + index
	for child in node.get_children():
		if child is VBoxContainer and "block_expand" in child:
			update_child_events(child, index + 1)



func update_lines():
	line_number = 0
	update_line()

func update_line(node: Node = self):
	if node is VBoxContainer and "block_type" in node:
		if node.block_type != Types.BlockType.COMMENT or node.block_type != Types.BlockType.VARIABLE:
			node.block_number = line_number
	for child in node.get_children():
		if child is VBoxContainer and "block_type" in child:
			if child.block_type == Types.BlockType.COMMENT or child.block_type == Types.BlockType.VARIABLE:
				continue
			line_number += 1
			update_line(child)
