@tool
extends Node
class_name ESUtils

const Data = preload("res://addons/event_sheet/source/utils/event_sheet_data.gd")
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
		var _node = ESUtils.current_scene.get_node_or_null(node_path)
		if !_node: return ""
		
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
		
		return _full_save_path if FileAccess.file_exists(_full_save_path) else "res://addons/event_sheet/resources/icons/event_sheet_big.svg"
	else:
		return "res://addons/event_sheet/resources/icons/event_sheet_big.svg"

static func get_node_icon_texture(node: NodePath) -> Texture2D:
	if ESUtils.current_scene.has_node(node):
		var _node = ESUtils.current_scene.get_node_or_null(node)
		if !_node: return load("res://addons/event_sheet/resources/icons/event_sheet_big.svg")
		
		if _node is Sprite2D:
			if _node.texture:
				return _node.texture
		
		return EditorInterface.get_editor_theme().get_icon(_node.get_class(), "EditorIcons")
	else:
		return load("res://addons/event_sheet/resources/icons/event_sheet_big.svg")

static func get_node_name(node_path: NodePath) -> String:
	if ESUtils.current_scene.has_node(node_path):
		var _node = ESUtils.current_scene.get_node_or_null(node_path)
		if !_node: return ""
		return _node.name
	else:
		return ""

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

static func selection_is_equal_to_type(data) -> bool:
	if ESUtils.selected_items:
		var _data = ESUtils.selected_items[ESUtils.selected_items.size() - 1].object.data
		if data.class != _data.class:
			return true
	return false

static func sort_selected_items_by_block_number() -> Array:
	ESUtils.selected_items.sort_custom(func (a, b):
		if a["number"] < b["number"]:
			return true
		return false
	)
	return ESUtils.selected_items

static func unselect_item(uuid: String):
	for i in range(ESUtils.selected_items.size() - 1, -1, -1):
		var _uuid = ESUtils.selected_items[i].object.uuid
		if _uuid == uuid:
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

static func find_gd_files_in_paths(resource_paths: Array, object_path_or_type) -> Dictionary:
	var gd_files: Dictionary = { "actions": [], "events": [] }
	
	for base_path in resource_paths:
		var dir = DirAccess.open(base_path)
		if not dir:
			continue
		
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			if folder_name != "." and folder_name != "..":
				var sub_dir_path = "{0}/{1}".format([base_path, folder_name])
				
				# Проверяем, это папка или файл
				if dir.current_is_dir():
					# Проверяем, это ли директория "actions" или "events"
					if folder_name in ["actions", "events"]:
						var sub_dir = DirAccess.open(sub_dir_path)
						if sub_dir:
							sub_dir.list_dir_begin()
							var file_name = sub_dir.get_next()
							
							while file_name != "":
								if file_name != "." and file_name != "..":
									if file_name.ends_with(".gd"):
										# Получаем имя класса из имени файла
										var _split_name: PackedStringArray = file_name.split(".")
										if object_path_or_type is NodePath:
											if current_scene.get_node(object_path_or_type).is_class(_split_name[0]):
												gd_files[folder_name].append("{0}/{1}".format([sub_dir_path, file_name]))
										else:
											if object_path_or_type == _split_name[0]:
												gd_files[folder_name].append("{0}/{1}".format([sub_dir_path, file_name]))
								file_name = sub_dir.get_next()
							sub_dir.list_dir_end()
					else:
						# Рекурсивно обрабатываем вложенные папки
						var sub_files = find_gd_files_in_paths([sub_dir_path], object_path_or_type)
						gd_files["actions"].append_array(sub_files["actions"])
						gd_files["events"].append_array(sub_files["events"])
			folder_name = dir.get_next()
		
		dir.list_dir_end()
	
	return gd_files

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

# Найти визуальное тело блока
static func find_empty_block(parent: Node, target_id: String, expected_type: String) -> Variant:
	if "id" in parent and parent.get_class() == expected_type and parent.id == target_id:
		return parent
	
	for child in parent.get_children():
		var result = find_empty_block(child, target_id, expected_type)
		if result != null:
			return result
	
	return null





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


















static func save_event_sheet_data():
	if current_scene:
		var _file_path = current_scene.event_sheet_file.resource_path
		var _data_string = JSON.stringify(current_scene.event_sheet_file.data, "\t")
		var _file = FileAccess.open(_file_path, FileAccess.WRITE)
		if _file:
			_file.store_line(_data_string)
			_file.close()
			EditorInterface.get_resource_filesystem().update_file(_file_path)
			EditorInterface.get_resource_filesystem().scan()
			EditorInterface.get_resource_filesystem().scan_sources()
		else:
			print("file open failed")

# Проверить перемещён ли текущий блок в свои-же дочерние блоки
static func is_descendant_of(block: Dictionary, potential_ancestor: Dictionary) -> bool:
	if block == potential_ancestor:
		return true
	if not potential_ancestor.has("childrens"):
		return false
	for children in potential_ancestor["childrens"]:
		if is_descendant_of(block, children):
			return true
	return false

static func get_root_block(child_uuid: String, event_sheet_data: Array) -> String:
	for block in event_sheet_data:
		if block.has("uuid"):
			if block["uuid"] == child_uuid:
				return block["uuid"]
			if block.has("childrens"):
				for child in block["childrens"]:
					if get_root_block(child_uuid, [child]) != "":
						return block["uuid"]
	return ""

static func find_data(uuid: String, data: Dictionary) -> Dictionary:
	if data.has("uuid") and data.uuid == uuid:
		return { "dir": "", "item": data }
	if data.has("actions") and data.actions is Array:
		for action in data.actions:
			if action.has("uuid") and action.uuid == uuid:
				return { "dir": "actions", "item": action }
	if data.has("events") and data.events is Array:
		for event in data.events:
			if event.has("uuid") and event.uuid == uuid:
				return { "dir": "events", "item": event }
	if data.has("childrens") and data.childrens is Array:
		for child in data.childrens:
			var result = find_data(uuid, child)
			if result != null:
				return { "dir": "childrens", "item": result }
	return {}

static func get_parent_block(uuid: String, event_sheet_data: Array) -> String:
	for block in event_sheet_data:
		if block.has("childrens"):
			for child in block["childrens"]:
				if child.has("uuid") and child["uuid"] == uuid:
					return block["uuid"]
			var result = get_parent_block(uuid, block["childrens"])
			if result:
				return result
	return ""

static func get_block_body(uuid: String, parent) -> VBoxContainer:
	if parent.get_class() == "VBoxContainer" and "uuid" in parent and parent.uuid == uuid:
		return parent
	for child in parent.get_children():
		var result = get_block_body(uuid, child)
		if result != null:
			return result
	return null

static func create_blocks(event_sheet_class, data: Dictionary, parent_block: Dictionary = {}) -> VBoxContainer:
	if data.is_empty(): return
	var root_block_body = create_block(event_sheet_class, data, parent_block)
	if data.has("childrens"):
		for children in data.childrens:
			create_blocks(event_sheet_class, children, data)
	return root_block_body

static func unique_block(data: Dictionary, level: int = 0):
	if data.is_empty(): return
	
	if data.has("uuid"):
		data.uuid = UUID.v4()
	if data.has("level"):
		data.level = level
	if data.has("events"):
		for event in data.events: unique_condition(event)
	if data.has("actions"):
		for action in data.actions: unique_condition(action)
	
	if data.has("childrens"):
		for children in data.childrens:
			unique_block(children, level + 1)

static func unique_condition(data: Dictionary):
	if data.is_empty(): return
	if data.has("uuid"):
		data.uuid = UUID.v4()

static func create_block(event_sheet_class, block: Dictionary, parent_block: Dictionary = {}) -> VBoxContainer:
	var _block_body: VBoxContainer = event_sheet_class.block_body.instantiate()
	_block_body.add_action.connect(event_sheet_class._on_add_action)
	_block_body.change.connect(event_sheet_class._on_change_content)
	_block_body.select.connect(event_sheet_class._on_select_content)
	_block_body.drop_data.connect(event_sheet_class._drop_data_block)
	if parent_block.is_empty():
		event_sheet_class.block_items.add_child(_block_body)
	else:
		var _parent_block_body: VBoxContainer = get_block_body(parent_block.uuid, event_sheet_class.block_items)
		if _parent_block_body != null:
			_parent_block_body.add_child(_block_body)
			if !_parent_block_body.expand:
				_block_body.visible = false
			print(parent_block.uuid)
		else:
			print("Ошибка: Родительский блок не найден.")
	_block_body.data = block
	if block.has("events"):
		for event in block.events:
			create_condition(event_sheet_class, _block_body, "event", event)
	if block.has("actions"):
		for action in block.actions:
			create_condition(event_sheet_class, _block_body, "action", action)
	return _block_body

static func create_condition(event_sheet_class, block_body: VBoxContainer, condition_class: String, condition: Dictionary) -> Button:
	if condition_class == "event":
		var event_type: String = condition.type
		match event_type:
			"standart":
				var event_body: Button = event_sheet_class.event_body.instantiate()
				event_body.drop_data.connect(event_sheet_class._drop_data_block)
				block_body.block_events.add_child(event_body)
				event_body.data = condition
				event_body.block_body = block_body
				return event_body
	elif condition_class == "action":
		var event_type: String = condition.type
		match event_type:
			"standart":
				var action_body: Button = event_sheet_class.action_body.instantiate()
				action_body.drop_data.connect(event_sheet_class._drop_data_block)
				block_body.block_actions.add_child(action_body)
				action_body.data = condition
				action_body.block_body = block_body
				return action_body
	return null

static func _paste_items(event_sheet_class, clipboard_object: Object):
	var _to_block: Dictionary = clipboard_object.get_meta("to_block", {})
	var _clipboard_array:  Array = clipboard_object.get_meta("clipboard_array", [])
	var _objects_data: Array
	if _clipboard_array is Array:
		for _data in _clipboard_array:
			if _data.has("class"):
				var _duplicated_data = _data.duplicate(true)
				match _duplicated_data.class:
					"block":
						if !_to_block.is_empty():
							unique_block(_duplicated_data, _to_block.level + 1)
							_to_block.childrens.append(_duplicated_data)
							var root_block = create_blocks(event_sheet_class, _duplicated_data, _to_block)
							event_sheet_class.block_items.update_events(root_block)
							event_sheet_class.block_items.update_lines()
							_objects_data.append(root_block)
						else:
							unique_block(_duplicated_data)
							event_sheet_class.event_sheet_data.blocks.append(_duplicated_data)
							var root_block = create_blocks(event_sheet_class, _duplicated_data)
							_objects_data.append(root_block)
					"event":
						if !_to_block.is_empty():
							unique_condition(_duplicated_data)
							_to_block.events.append(_duplicated_data)
							var block_body = get_block_body(_to_block.uuid, event_sheet_class.block_items)
							var condition_body = create_condition(event_sheet_class, block_body, _duplicated_data.class, _duplicated_data)
							_objects_data.append(condition_body)
					"action":
						if !_to_block.is_empty():
							unique_condition(_duplicated_data)
							_to_block.actions.append(_duplicated_data)
							var block_body = get_block_body(_to_block.uuid, event_sheet_class.block_items)
							var condition_body = create_condition(event_sheet_class, block_body, _duplicated_data.class, _duplicated_data)
							_objects_data.append(condition_body)
	clipboard_object.set_meta("objects_data", _objects_data)

static func _remove_items(event_sheet_class, clipboard_object: Object):
	var _selected_item = ESUtils.selected_items[0] if ESUtils.selected_items.size() > 0 else null
	var _objects_data:  Array = clipboard_object.get_meta("objects_data", [])
	if _objects_data is Array:
		for _item in _objects_data:
			_remove_item(event_sheet_class, _item.get_parent(), _item)

static func _add_item(event_sheet_class, item_parent, item):
	match item.data.class:
		"block":
			if item_parent is String and !item_parent.is_empty():
				item_parent = get_block_body(item_parent, event_sheet_class.block_items)
			
			if "data" in item_parent: item_parent.data.childrens.append(item.data)
			else: event_sheet_class.event_sheet_data.blocks.append(item.data)
			item_parent.add_child(item)
		"event":
			item.block_body.data.events.append(item.data)
			item.block_body.block_events.add_child(item)
		"action":
			item.block_body.data.actions.append(item.data)
			item.block_body.block_actions.add_child(item)
	save_event_sheet_data()

static func _remove_item(event_sheet_class, item_parent, item):
	match item.data.class:
		"block":
			if item_parent is String and !item_parent.is_empty():
				item_parent = get_block_body(item_parent, event_sheet_class.block_items)
			
			if "data" in item_parent: item_parent.data.childrens.erase(item.data)
			else: event_sheet_class.event_sheet_data.blocks.erase(item.data)
			item_parent.remove_child(item)
			if "data" in item_parent: item_parent.data = item_parent.data
		"event":
			item.block_body.data.events.erase(item.data)
			item.block_body.block_events.remove_child(item)
		"action":
			item.block_body.data.actions.erase(item.data)
			item.block_body.block_actions.remove_child(item)
	save_event_sheet_data()
