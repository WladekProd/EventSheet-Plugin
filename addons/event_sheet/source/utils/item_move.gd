
# Move up
static func move_up(event_sheet, selected_array: Array, to: Variant) -> void:
	for item in selected_array:
		var from = item.object
		match item.class:
			"Block":
				var from_data = from.data
				var to_data = to.data
				
				var from_parent = from.get_parent() if "data" in from.get_parent() else null
				var to_parent = to.get_parent() if "data" in to.get_parent() else null
				
				var from_root: VBoxContainer = get_root_body(event_sheet, from)
				var to_root: VBoxContainer = get_root_body(event_sheet, to)
				
				if ESUtils.is_descendant_of(to_data, from_data):
					print("You can't move a block into its sub-blocks or under itself.")
					return
				
				if to_parent:
					var to_index = to.get_index()
					if from_parent == to_parent:
						if from.get_index() > to_index - 1:
							pass
						elif from.get_index() - 1 < to_index:
							to_index -= 1
						elif from.get_index() - 1 == to_index:
							continue
					
					if from_parent: from_parent.data.childrens.erase(from_data)
					else: event_sheet.event_sheet_file.data.blocks.erase(from_data)
					
					var index = to_parent.data.childrens.find(to_data)
					from_data.level = to_data.level
					if index >= 0: to_parent.data.childrens.insert(index, from_data)
					
					from.reparent(to_parent)
					to_parent.move_child(from, to_index)
				else:
					var to_index = to.get_index()
					if from_parent == to_parent:
						if from.get_index() > to_index - 1:
							pass
						elif from.get_index() - 1 < to_index:
							to_index -= 1
						elif from.get_index() - 1 == to_index:
							continue
					
					if from_parent: from_parent.data.childrens.erase(from_data)
					else: event_sheet.event_sheet_file.data.blocks.erase(from_data)
					
					var index = event_sheet.event_sheet_file.data.blocks.find(to_data)
					from_data.level = to_data.level
					if index >= 0: event_sheet.event_sheet_file.data.blocks.insert(index, from_data)
					
					from.reparent(event_sheet.block_items)
					event_sheet.block_items.move_child(from, to_index)
				
				update_blocks(event_sheet, from, to, from_root, to_root)
			"Event":
				if from.data == to.data: continue
				if !from or !to: continue
				
				var to_index = to.get_index()
				if from.block_body == to.block_body:
					if from.get_index() > to_index - 1:
						pass
					elif from.get_index() - 1 < to_index:
						to_index -= 1
					elif from.get_index() - 1 == to_index:
						continue
				
				from.block_body.data.events.erase(from.data)
				
				var index = to.block_body.data.events.find(to.data)
				if index >= 0: to.block_body.data.events.insert(index, from.data)
				
				from.reparent(to.block_body.block_events)
				to.block_body.block_events.move_child(from, to_index)
				from.block_body = to.block_body
			"Action":
				if from.data == to.data: continue
				if !from or !to: continue
				
				var to_index = to.get_index()
				if from.block_body == to.block_body:
					if from.get_index() > to_index - 1:
						pass
					elif from.get_index() - 1 < to_index:
						to_index -= 1
					elif from.get_index() - 1 == to_index:
						continue
				
				from.block_body.data.actions.erase(from.data)
				
				var index = to.block_body.data.actions.find(to.data)
				if index >= 0: to.block_body.data.actions.insert(index, from.data)
				
				from.reparent(to.block_body.block_actions)
				to.block_body.block_actions.move_child(from, to_index)
				from.block_body = to.block_body

# Move down
static func move_down(event_sheet, selected_array: Array, to: Variant) -> void:
	for item in selected_array:
		var from = item.object
		match item.class:
			"Block":
				var from_data = from.data
				var to_data = to.data
				
				var from_parent = from.get_parent() if "data" in from.get_parent() else null
				var to_parent = to.get_parent() if "data" in to.get_parent() else null
				
				var from_root: VBoxContainer = get_root_body(event_sheet, from)
				var to_root: VBoxContainer = get_root_body(event_sheet, to)
				
				if ESUtils.is_descendant_of(to_data, from_data):
					print("You can't move a block into its sub-blocks or under itself.")
					return
				
				if to_parent:
					var to_index = to.get_index()
					if from_parent == to_parent:
						if from.get_index() == to_index + 1:
							continue
						elif from.get_index() > to_index + 1:
							to_index += 1
					else: to_index += 1
					
					if from_parent: from_parent.data.childrens.erase(from_data)
					else: event_sheet.event_sheet_file.data.blocks.erase(from_data)
					
					var index = to_parent.data.childrens.find(to_data)
					from_data.level = to_data.level
					if index >= 0: to_parent.data.childrens.insert(index + 1, from_data)
					
					from.reparent(to_parent)
					to_parent.move_child(from, to_index)
				else:
					var to_index = to.get_index()
					if from_parent == to_parent:
						if from.get_index() == to_index + 1:
							continue
						elif from.get_index() > to_index + 1:
							to_index += 1
					else: to_index += 1
					
					if from_parent: from_parent.data.childrens.erase(from_data)
					else: event_sheet.event_sheet_file.data.blocks.erase(from_data)
					
					var index = event_sheet.event_sheet_file.data.blocks.find(to_data)
					from_data.level = to_data.level
					if index >= 0: event_sheet.event_sheet_file.data.blocks.insert(index + 1, from_data)
					
					from.reparent(event_sheet.block_items)
					event_sheet.block_items.move_child(from, to_index)
				
				update_blocks(event_sheet, from, to, from_root, to_root)
			"Event":
				if from.data == to.data: continue
				if !from or !to: continue
				
				var to_index = to.get_index()
				if from.block_body == to.block_body:
					if from.get_index() == to_index + 1:
						continue
					elif from.get_index() > to_index + 1:
						to_index += 1
				else:
					to_index += 1
				
				from.block_body.data.events.erase(from.data)
				
				var index = to.block_body.data.events.find(to.data)
				if index >= 0: to.block_body.data.events.insert(index + 1, from.data)
				
				from.reparent(to.block_body.block_events)
				to.block_body.block_events.move_child(from, to_index)
				from.block_body = to.block_body
			"Action":
				if from.data == to.data: continue
				if !from or !to: continue
				
				var to_index = to.get_index()
				if from.block_body == to.block_body:
					if from.get_index() == to_index + 1:
						continue
					elif from.get_index() > to_index + 1:
						to_index += 1
				else:
					to_index += 1
				
				from.block_body.data.actions.erase(from.data)
				
				var index = to.block_body.data.actions.find(to.data)
				if index >= 0: to.block_body.data.actions.insert(index + 1, from.data)
				
				from.reparent(to.block_body.block_actions)
				to.block_body.block_actions.move_child(from, to_index)
				from.block_body = to.block_body

# Move to child
static func move_sub_or_content(event_sheet, selected_array: Array, to: Variant) -> void:
	for item in selected_array:
		var from = item.object
		match item.class:
			"Block":
				var from_data = from.data
				var to_data = to.data
				
				var from_parent = from.get_parent() if "data" in from.get_parent() else null
				var to_parent = to.get_parent() if "data" in to.get_parent() else null
				
				var from_root: VBoxContainer = get_root_body(event_sheet, from)
				var to_root: VBoxContainer = get_root_body(event_sheet, to)
				
				if ESUtils.is_descendant_of(to_data, from_data):
					print("You can't move a block into its sub-blocks or under itself.")
					return
				
				if from_parent: from_parent.data.childrens.erase(from_data)
				else: event_sheet.event_sheet_file.data.blocks.erase(from_data)
				
				from_data.level = to_data.level + 1
				to_data.childrens.append(from_data)
				
				from.reparent(to)
				update_blocks(event_sheet, from, to, from_root, to_root)
			"Event":
				var from_data = from.data
				var from_block = from.block_body
				
				var to_data = to.data
				
				if from_block == to: continue
				
				from_block.data.events.erase(from_data)
				to.data.events.append(from_data)
				
				from.reparent(to.block_events)
				to.block_events.move_child(from, to.block_events.get_child_count())
				from.block_body = to
			"Action":
				var from_data = from.data
				var from_block = from.block_body
				
				var to_data = to.data
				
				if from_block == to: continue
				
				from_block.data.actions.erase(from_data)
				to.data.actions.append(from_data)
				
				from.reparent(to.block_actions)
				to.block_actions.move_child(from, to.block_actions.get_child_count())
				from.block_body = to

# To get the root item
static func get_root_body(event_sheet, block) -> VBoxContainer:
	var _root_block_uuid: String = ESUtils.get_root_block(block.data.uuid, event_sheet.event_sheet_data.blocks)
	var _root_block_body: VBoxContainer = ESUtils.get_block_body(_root_block_uuid, event_sheet.block_items)
	return _root_block_body if _root_block_body and "data" in _root_block_body else null

# Update the hierarchy
static func update_hierarchy(root_block) -> void:
	if root_block is VBoxContainer and "data" in root_block:
		if "expand" in root_block: root_block.expand = root_block.expand
	for child in root_block.get_children():
		update_hierarchy(child)

# Update the blocks
static func update_blocks(event_sheet, from, to, from_root, to_root) -> void:
	if from_root and to_root:
		update_hierarchy(from_root)
		update_hierarchy(to_root)
	else:
		to.expand = to.expand
		from.expand = from.expand
	event_sheet.block_items.update_events(from)
	event_sheet.block_items.update_lines()
