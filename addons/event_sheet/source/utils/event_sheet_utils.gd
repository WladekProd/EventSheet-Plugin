@tool
extends Node
class_name ESUtils

const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")
const UUID = preload("res://addons/event_sheet/source/utils/event_sheet_uuid.gd")
const Plugin = preload("res://addons/event_sheet/plugin.gd")

static var base_control = EditorInterface.get_base_control() if Engine.is_editor_hint() else null
static var scene_tree_dock = base_control.find_children("Scene", "", true, false)[0] if Engine.is_editor_hint() else null
static var scene_tree_editor = find_child_by_class(scene_tree_dock, 'SceneTreeEditor') if Engine.is_editor_hint() else null
static var scene_tree_editor_tree: Tree = ESUtils.find_child_by_class(scene_tree_editor, 'Tree') if Engine.is_editor_hint() else null

static var current_scene: Node = null
static var is_plugin_screen: bool = false
static var is_ctrl_pressed: bool = false

static var selected_items: Array = []
static var hovered_select: Node
static var selected_class: String = ""

static var clipboard_items: Array = []

static var undo_redo: EditorUndoRedoManager = null

static var is_editing: bool = false
static var is_dragging: bool = false
static var is_dragging_finished: bool = true
static var dragging_data: Dictionary = {}

static var global_split: int = 200
static var max_block_level: int = 0

static var is_split_hovered: bool = false
static var is_split_pressed: bool = false

static var cache_folder: String = "res://addons/event_sheet/~cache/"

static func generate_file_icon(file_path: String, script: Variant, function: String):
	if !FileAccess.file_exists(file_path):
		return false
	EditorInterface.get_resource_previewer().queue_resource_preview(file_path, script, function, null)
	return true

static func save_file_icon(path: String, preview: Texture2D, thumbnail: Texture2D, userdata: Variant) -> Texture2D:
	var _object_path: String = path.get_base_dir().replace("res://", "") + "/"
	var _image_name: String = path.get_file().get_basename() + ".tres"
	var _save_path: String = ensure_trailing_slash(cache_folder) + ensure_trailing_slash(_object_path)
	var _full_save_path: String = _save_path + _image_name
	
	if !FileAccess.file_exists(_full_save_path):
		DirAccess.make_dir_recursive_absolute(_save_path)
		ResourceSaver.save(preview, _full_save_path)
		EditorInterface.get_resource_filesystem().scan()
	
	return preview

static func get_file_icon(object_path: String):
	var _object_path: String = object_path.get_base_dir().replace("res://", "") + "/"
	var _image_name: String = object_path.get_file().get_basename() + ".tres"
	var _image_path: String = ensure_trailing_slash(cache_folder) + ensure_trailing_slash(_object_path) + _image_name
	
	if !FileAccess.file_exists(_image_path):
		if !generate_file_icon(object_path, ESUtils, "save_object_icon"):
			return "res://addons/event_sheet/resources/icons/event_sheet_small.png"
	return _image_path

static func get_node_icon(node_path: NodePath) -> String:
	if ESUtils.current_scene.has_node(node_path):
		var _node = ESUtils.current_scene.get_node(node_path)
		
		if _node is Sprite2D:
			if !_node.texture.resource_path.is_empty():
				return _node.texture.resource_path
		
		var _node_class: String = str(_node.get_class())
		var _node_icon_image = EditorInterface.get_editor_theme().get_icon(_node_class, "EditorIcons").get_image()
		var _node_icon_texture: ImageTexture = ImageTexture.create_from_image(_node_icon_image)
		var _image_name: String = _node_class + ".tres"
		var _save_path: String = ensure_trailing_slash(cache_folder) + ensure_trailing_slash("icons/")
		var _full_save_path: String = _save_path + _image_name
		
		if !FileAccess.file_exists(_full_save_path):
			DirAccess.make_dir_recursive_absolute(_save_path)
			ResourceSaver.save(_node_icon_texture, _full_save_path)
			EditorInterface.get_resource_filesystem().scan()
			return _full_save_path
		
		return _full_save_path if FileAccess.file_exists(_full_save_path) else "res://addons/event_sheet/resources/icons/event_sheet_small.png"
	else:
		return "res://addons/event_sheet/resources/icons/event_sheet_small.png"

static func get_node_name(node_path: NodePath) -> String:
	if ESUtils.current_scene.has_node(node_path):
		var _node = ESUtils.current_scene.get_node(node_path)
		return _node.name
	else:
		return "Null"

static func ensure_trailing_slash(path: String) -> String:
	return path if path.ends_with("/") else path + "/"



static func get_setting(setting_name: String = "") -> Variant:
	var settings := EditorInterface.get_editor_settings()
	var setting_path := Plugin.PLUGIN_SETTINGS_PATH + "/" + setting_name
	match setting_name:
		"code_editor_enable":
			return settings.get_setting(setting_path) if settings.has_setting(setting_path) else true
		"animations_enable":
			return settings.get_setting(setting_path) if settings.has_setting(setting_path) else true
		"animations_speed":
			return settings.get_setting(setting_path) if settings.has_setting(setting_path) else 1.0
	return null

func _notification(what: int) -> void:
	if !Engine.is_editor_hint(): return
	if what == Node.NOTIFICATION_DRAG_END:
		ESUtils.is_dragging = false
		ESUtils.dragging_data = {}
		ESUtils.is_dragging_finished = true
		for node: Control in get_tree().get_nodes_in_group("Drag&Drop"):
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			node._update_buttons()
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		ESUtils.is_dragging_finished = false
		for node: Control in get_tree().get_nodes_in_group("Drag&Drop"):
			if ESUtils.dragging_data and ESUtils.dragging_data.class == node.drop_class:
				node.mouse_filter = Control.MOUSE_FILTER_STOP
				node._update_buttons()

static func has_item_in_select(item: Node) -> bool:
	var _exists = false
	for _item in selected_items:
		if _item["object"] == item:
			_exists = true
			break
	return _exists

static func selection_is_equal_to_type(resource) -> bool:
	if ESUtils.selected_items:
		var _resource
		
		if "block_resource" in ESUtils.selected_items[ESUtils.selected_items.size() - 1].object:
			_resource = ESUtils.selected_items[ESUtils.selected_items.size() - 1].object.block_resource
		if "resource" in ESUtils.selected_items[ESUtils.selected_items.size() - 1].object:
			_resource = ESUtils.selected_items[ESUtils.selected_items.size() - 1].object.resource
		
		if resource.get_class() != _resource.get_class():
			return true
	return false

static func sort_selected_items_by_block_number() -> Array:
	ESUtils.selected_items.sort_custom(func (a, b):
		if a["number"] < b["number"]:
			return true
		return false
	)
	return ESUtils.selected_items

static func unselect_item(id: String):
	for i in range(ESUtils.selected_items.size() - 1, -1, -1):
		var _id = ESUtils.selected_items[i].object.id
		if _id == id:
			ESUtils.selected_items.remove_at(i)
			return

static func unselect_all():
	for item in ESUtils.selected_items:
		var _object = item.object
		if !_object: return
		if _object is VBoxContainer and _object.is_selected:
			_object.is_selected = false
			_object.select_all_childs(_object)
		if _object is Button and _object.button_pressed:
			_object.button_pressed = false
			_object.is_dragged = false
	ESUtils.selected_items.clear()

static func deep_duplicate_block(block_resource: Resource) -> Resource:
	if block_resource == null:
		return null

	# Глубокое дублирование текущего блока
	var duplicated_resource: BlockResource = block_resource.duplicate(true)

	# Глубокое дублирование событий
	var duplicated_events: Array[EventResource] = []
	for event in duplicated_resource.events:
		if event != null:
			var duplicated_event: EventResource = event.duplicate(true)
			duplicated_events.append(duplicated_event)
	duplicated_resource.events = duplicated_events

	# Глубокое дублирование действий
	var duplicated_actions: Array[ActionResource] = []
	for action in duplicated_resource.actions:
		if action != null:
			var duplicated_action: ActionResource = action.duplicate(true)
			duplicated_actions.append(duplicated_action)
	duplicated_resource.actions = duplicated_actions

	# Рекурсивное глубокое дублирование вложенных блоков
	var duplicated_sub_blocks: Array[BlockResource] = []
	for sub_block in duplicated_resource.sub_blocks:
		if sub_block != null:
			var duplicated_sub_block: BlockResource = deep_duplicate_block(sub_block)
			duplicated_sub_blocks.append(duplicated_sub_block)
	duplicated_resource.sub_blocks = duplicated_sub_blocks

	ESUtils.update_block_ids(duplicated_resource)

	return duplicated_resource

static func deep_duplicate_condition(resource: Resource):
	if resource == null:
		return null
	
	var duplicated_resource: Resource = resource.duplicate(true)
	duplicated_resource.id = UUID.v4()
	duplicated_resource.gd_script.duplicate(true)
	
	return duplicated_resource

static func update_block_ids(block: BlockResource):
	if block == null: return
	
	block.id = UUID.v4()
	for event in block.events:
		if event != null:
			event.id = UUID.v4()
	for action in block.actions:
		if action != null:
			action.id = UUID.v4()
	
	for sub_block in block.sub_blocks:
		if sub_block != null:
			update_block_ids(sub_block)

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


static func find_event_block(event_sheet_data: Array[BlockResource], event: EventResource):
	for _block in event_sheet_data:
		if _block.events.has(event):
			return _block
		
		# Рекурсивно проверяем суб-блоки
		var block = find_event_block(_block.sub_blocks, event)
		if block != null:
			return block
	
	return null

static func find_action_block(event_sheet_data: Array[BlockResource], action: ActionResource):
	for _block in event_sheet_data:
		if _block.actions.has(action):
			return _block
		
		# Рекурсивно проверяем суб-блоки
		var block = find_action_block(_block.sub_blocks, action)
		if block != null:
			return block
	
	return null

static func find_index_by_id(array: Array, target_id: String) -> int:
	for i in range(array.size()):
		var item = array[i]
		if "id" in item and item.id == target_id:
			return i
	return -1

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
static func find_empty_block(parent: Node, target_id: String, expected_type: String) -> Variant:
	if "id" in parent and parent.get_class() == expected_type and parent.id == target_id:
		return parent
	
	for child in parent.get_children():
		var result = find_empty_block(child, target_id, expected_type)
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



static func get_parent_block_resource(item: Node, parent: Node = null):
	var _item_resource = item.block_resource if "block_resource" in item else item.resource
	if _item_resource is EventResource or _item_resource is ActionResource:
		return item.empty_block.block_resource
	else:
		if parent:
			if "block_resource" in parent:
				return parent.block_resource
		else:
			if "block_resource" in item.get_parent():
				return item.get_parent().block_resource
	return null

static func find_index(item: Node, event_sheet_data: Array[BlockResource] = []) -> int:
	var _item_resource = item.block_resource if "block_resource" in item else item.resource
	
	var _parent_resource: BlockResource = get_parent_block_resource(item)
	
	if _parent_resource != null:
		if _item_resource is EventResource: return _parent_resource.events.find(_item_resource)
		if _item_resource is ActionResource: return _parent_resource.actions.find(_item_resource)
		if _item_resource is BlockResource: return _parent_resource.sub_blocks.find(_item_resource)
	else:
		if _item_resource is BlockResource: return event_sheet_data.find(_item_resource)
	
	return 0

static func remove_item(item: Node, event_sheet_data: Array[BlockResource] = []):
	var _item_resource = item.block_resource if "block_resource" in item else item.resource
	
	var _parent_resource: BlockResource = get_parent_block_resource(item)
	
	var _item_resource_index: int = -1
	if _parent_resource != null:
		if _item_resource is EventResource:
			_item_resource_index = _parent_resource.events.find(_item_resource)
			_parent_resource.events.erase(_item_resource)
		if _item_resource is ActionResource:
			_item_resource_index = _parent_resource.actions.find(_item_resource)
			_parent_resource.actions.erase(_item_resource)
		if _item_resource is BlockResource:
			_item_resource_index = _parent_resource.sub_blocks.find(_item_resource)
			_parent_resource.sub_blocks.erase(_item_resource)
	else:
		if _item_resource is BlockResource:
			_item_resource_index = event_sheet_data.find(_item_resource)
			event_sheet_data.erase(_item_resource)
	
	item.get_parent().remove_child(item)
	return _item_resource_index

static func add_item(item: Node, index: int, parent: Node, event_sheet_data: Array[BlockResource] = []):
	var _item_resource = item.block_resource if "block_resource" in item else item.resource
	var _item_index: int = index
	
	var _parent_resource: BlockResource = get_parent_block_resource(item, parent)
	
	if _parent_resource != null:
		if _item_resource is EventResource: _parent_resource.events.insert(index, _item_resource)
		if _item_resource is ActionResource: _parent_resource.actions.insert(index, _item_resource)
		if _item_resource is BlockResource: _parent_resource.sub_blocks.insert(index, _item_resource)
	else:
		if _item_resource is BlockResource: event_sheet_data.insert(index, _item_resource)
	
	parent.add_child(item)
	if "block_resource" in parent: parent.move_child(item, index + 1 if index != -1 else 0)
	else: parent.move_child(item, index if index != -1 else 0)




static func change_resource(block, index: int, new_data):
	if block is EventResource: block.events[index] = new_data
	elif block is ActionResource: block.actions[index] = new_data

static func spawn_block_item(event_sheet_class, parent_item: Node, item: Node, resource, spawn_resource: bool = true):
	if parent_item:
		if resource is BlockResource:
			if spawn_resource: parent_item.block_resource.sub_blocks.append(resource)
			parent_item.add_child(item)
		elif resource is EventResource:
			if spawn_resource: parent_item.block_resource.events.append(resource)
			parent_item.block_events.add_child(item)
		elif resource is ActionResource:
			if spawn_resource: parent_item.block_resource.actions.append(resource)
			parent_item.block_actions.add_child(item)
	else:
		if resource is BlockResource:
			if spawn_resource: event_sheet_class.event_sheet_data.append(resource)
			event_sheet_class.block_items.add_child(item)
	event_sheet_class.generate_code()

static func remove_block_item(event_sheet_class, parent_item: Node, item: Node, resource):
	if parent_item:
		if resource is BlockResource:
			var _index = parent_item.block_resource.sub_blocks.find(resource)
			parent_item.block_resource.sub_blocks.remove_at(_index)
			parent_item.remove_child(item)
		elif resource is EventResource:
			var _index = parent_item.block_resource.events.find(resource)
			parent_item.block_resource.events.remove_at(_index)
			parent_item.block_events.remove_child(item)
		elif resource is ActionResource:
			var _index = parent_item.block_resource.actions.find(resource)
			parent_item.block_resource.actions.remove_at(_index)
			parent_item.block_actions.remove_child(item)
	else:
		if resource is BlockResource:
			var _index = event_sheet_class.event_sheet_data.find(resource)
			event_sheet_class.event_sheet_data.remove_at(_index)
			event_sheet_class.block_items.remove_child(item)
	event_sheet_class.generate_code()

static func create_block(event_sheet_class, block_type: Types.BlockType, block_data, parent_item: Node = null, create_new_resource: bool = true, save_resources: bool = true, fill_conditions: bool = false) -> VBoxContainer:
	var _new_block = block_data
	
	if create_new_resource:
		_new_block = BlockResource.new()
		_new_block.id = UUID.v4()
		_new_block.block_type = block_type
		match block_type:
			Types.BlockType.GROUP:
				_new_block.group_name = block_data.group_name
				_new_block.group_description = block_data.group_description
			Types.BlockType.COMMENT:
				_new_block.comment_text = block_data.comment_text
			Types.BlockType.VARIABLE:
				_new_block.variable_is_global = block_data.variable_is_global
				_new_block.variable_name = block_data.variable_name
				_new_block.variable_type = block_data.variable_type
				_new_block.variable_value = block_data.variable_value
	
	var _block_item = event_sheet_class.empty_block.instantiate()
	_block_item.id = _new_block.id
	if save_resources:
		ESUtils.undo_redo.create_action("Add Blocks")
		ESUtils.undo_redo.add_do_method(ESUtils, "spawn_block_item", event_sheet_class, parent_item, _block_item, _new_block)
		ESUtils.undo_redo.add_undo_method(ESUtils, "remove_block_item", event_sheet_class, parent_item, _block_item, _new_block)
		ESUtils.undo_redo.commit_action()
	else:
		spawn_block_item(event_sheet_class, parent_item, _block_item, _new_block, false)
	_block_item.block_resource = _new_block
	
	_block_item.drop_data.connect(event_sheet_class._drop_data_block)
	_block_item.select.connect(event_sheet_class._on_select_content)
	_block_item.change.connect(event_sheet_class._on_change_content)
	#_block_item.context_menu.connect(_on_context_menu)
	_block_item.add_action.connect(event_sheet_class._on_add_action)
	
	if fill_conditions:
		for event in _new_block.events:
			create_event(event_sheet_class, _block_item, event, save_resources)
		for action in _new_block.actions:
			create_action(event_sheet_class, _block_item, action, save_resources)
	
	event_sheet_class.generate_code()
	return _block_item

static func create_event(event_sheet_class, block_item: Node, event_data, save_resources: bool = true) -> Button:
	var _event_resource: EventResource = event_data
	
	_event_resource.id = UUID.v4()
	
	var _event_item = event_sheet_class.event_instance.instantiate()
	_event_item.id = _event_resource.id
	
	if save_resources:
		ESUtils.undo_redo.create_action("Add Events")
		ESUtils.undo_redo.add_do_method(ESUtils, "spawn_block_item", event_sheet_class, block_item, _event_item, _event_resource)
		ESUtils.undo_redo.add_undo_method(ESUtils, "remove_block_item", event_sheet_class, block_item, _event_item, _event_resource)
		ESUtils.undo_redo.commit_action()
	else:
		spawn_block_item(event_sheet_class, block_item, _event_item, _event_resource, false)
	
	_event_item.resource = _event_resource
	_event_item.empty_block = block_item
	_event_item.drop_data.connect(event_sheet_class._drop_data_event)
	
	event_sheet_class.generate_code()
	return _event_item

static func create_action(event_sheet_class, block_item: Node, action_data, save_resources: bool = true) -> Button:
	var _action_resource: ActionResource = action_data
	
	_action_resource.id = UUID.v4()
	
	var _action_item = event_sheet_class.action_instance.instantiate()
	_action_item.id = _action_resource.id
	
	if save_resources:
		ESUtils.undo_redo.create_action("Add Actions")
		ESUtils.undo_redo.add_do_method(ESUtils, "spawn_block_item", event_sheet_class, block_item, _action_item, _action_resource)
		ESUtils.undo_redo.add_undo_method(ESUtils, "remove_block_item", event_sheet_class, block_item, _action_item, _action_resource)
		ESUtils.undo_redo.commit_action()
	else:
		spawn_block_item(event_sheet_class, block_item, _action_item, _action_resource, false)
	
	_action_item.resource = _action_resource
	_action_item.empty_block = block_item
	_action_item.drop_data.connect(event_sheet_class._drop_data_action)
	
	return _action_item

static func duplicate_block(event_sheet_class, block_resource: BlockResource, parent_block: Node = null) -> VBoxContainer:
	var _duplicated_item = create_block(event_sheet_class, block_resource.block_type, block_resource, parent_block, false, false)
	return _duplicated_item

static func update_block(event_sheet_class, block_item: Node, block_level: int = 0) -> VBoxContainer:
	if block_item == null:
		return null
	
	var _empty_block: VBoxContainer = block_item
	var _block_resource: BlockResource = _empty_block.block_resource
	
	_block_resource.level = block_level
	
	if _block_resource.block_type == Types.BlockType.GROUP:
		pass
	
	if _block_resource.block_type == Types.BlockType.COMMENT:
		pass
	
	if _block_resource.block_type == Types.BlockType.VARIABLE:
		_block_resource.variable_is_global = _block_resource.level == 0
	
	_empty_block.block_resource = _block_resource
	_empty_block.block_type = _block_resource.block_type
	_empty_block.block_expand = Types.SubBlocksState.NONE if _block_resource.sub_blocks.size() == 0 else _block_resource.block_expand
	
	if _block_resource.block_type == Types.BlockType.STANDART:
		for event in _block_resource.events:
			var _event_item: Button = find_empty_block(_empty_block.block_events, event.id, "Button")
			if _event_item != null: _event_item.resource = event
		
		for action in _block_resource.actions:
			var _action_item: Button = find_empty_block(_empty_block.block_actions, action.id, "Button")
			if _action_item != null: _action_item.resource = action
	
	event_sheet_class.block_items.update_lines()
	event_sheet_class.generate_code()
	return _empty_block
