@tool
extends Node
class_name ESUtils

static var base_control = EditorInterface.get_base_control()
static var scene_tree_dock = base_control.find_children("Scene", "", true, false)[0]
static var scene_tree_editor = ESUtils.find_child_by_class(scene_tree_dock, 'SceneTreeEditor')
static var scene_tree_editor_tree: Tree = ESUtils.find_child_by_class(scene_tree_editor, 'Tree')

static var is_plugin_screen: bool = false
static var is_dragging: bool = false
static var dragging_data: VBoxContainer = null




static func find_tres_files_in_paths(resource_paths: Array, sub_dirs: Array) -> Dictionary:
	var tres_files: Dictionary = {"actions": [], "events": []}
	for path in resource_paths:
		for sub_dir in sub_dirs:
			var full_sub_dir_path: String = "{0}/{1}".format([path, sub_dir])
			var dir = DirAccess.open(full_sub_dir_path)
			if dir:
				dir.list_dir_begin()
				var file_name: String = dir.get_next()
				while file_name != "":
					if file_name != "." and file_name != "..":
						var full_path: String = "{0}/{1}".format([full_sub_dir_path, file_name])
						if dir.current_is_dir():
							# Рекурсивно обрабатываем вложенные папки
							var sub_tres_files: Dictionary = find_tres_files_in_paths([full_path], sub_dirs)
							for category in tres_files.keys():
								tres_files[category].append_array(sub_tres_files[category])
						elif file_name.ends_with(".tres"):
							tres_files[sub_dir].append(full_path)
					file_name = dir.get_next()
				dir.list_dir_end()
	return tres_files

static func find_child_by_class(node:Node, cls:String):
	for child in node.get_children():
		if child.get_class() == cls:
			return child


static func get_all_items(tree: Tree) -> Array:
	var items = []
	var root = tree.get_root()
	_collect_items(root, items)
	return items


static func _collect_items(item: TreeItem, items: Array) -> void:
	while item:
		items.append(item)
		if item.get_child_count() > 0:
			_collect_items(item.get_first_child(), items)
		item = item.get_next()


# Найти родительский блок
static func find_parent_block(event_sheet_data: Array[BlockResource], block: BlockResource) -> BlockResource:
	for potential_parent in event_sheet_data:
		if potential_parent.sub_blocks.has(block):
			return potential_parent
		
		# Рекурсивно проверяем суб-блоки
		var parent = find_parent_block(potential_parent.sub_blocks, block)
		if parent != null:
			return parent
	
	return null

# Найти root блок
static func find_root_block(event_sheet_data: Array[BlockResource], block: BlockResource) -> BlockResource:
	var current_block = block
	var parent_block = find_parent_block(event_sheet_data, current_block)
	
	# Поднимаемся по иерархии до корневого блока
	while parent_block != null:
		current_block = parent_block
		parent_block = find_parent_block(event_sheet_data, current_block)
	
	return current_block

# Найти визуальное тело блока
static func find_block_body(parent: Node, target_id: int, expected_type: String) -> Variant:
	if parent.get_class() == expected_type and parent.name.split(" | ")[0] == str(target_id):
		return parent
	
	for child in parent.get_children():
		var result = find_block_body(child, target_id, expected_type)
		if result != null:
			return result
	
	return null


# Проверить перемещён ли текущий блок в свои-же дочерние блоки
static func is_descendant_of(block: BlockResource, potential_ancestor: BlockResource) -> bool:
	if block == potential_ancestor:
		return true
	
	for sub_block in potential_ancestor.sub_blocks:
		if is_descendant_of(block, sub_block):
			return true
	
	return false
