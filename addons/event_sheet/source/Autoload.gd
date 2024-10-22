@tool
extends Node
class_name ESUtils

static func cteate_object(scene, object_path: String, object_name: String, x: float, y: float) -> Node:
	var object: Node = load(object_path).instantiate()
	object.name = object_name
	object.position = Vector2(x, y)
	scene.add_child(object)
	return object

static func find_block_and_parent(target_id: int, event_sheet_data: Array[BlockResource]) -> Dictionary:
	var result: Dictionary = {"block": null, "parent": null}

	for block in event_sheet_data:
		result = find_block_and_parent_by_id(target_id, block)
		if result["block"] != null:
			break

	if result["block"] != null:
		print("Найден блок с ID:", result["block"].id)
		if result["parent"] != null:
			print("Родительский блок ID:", result["parent"].id)
		else:
			print("Родительский блок не найден (это верхний блок)")
	else:
		print("Блок с таким ID не найден")

	return result
static func find_block_and_parent_by_id(target_id: int, current_block: BlockResource, parent_block: BlockResource = null) -> Dictionary:
	# Если текущий блок имеет нужный ID, возвращаем текущий блок и его родителя
	if current_block.id == target_id:
		return {"block": current_block, "parent": parent_block}

	# Рекурсивный поиск в подблоках
	for sub_block in current_block.sub_blocks:
		var result = find_block_and_parent_by_id(target_id, sub_block, current_block)
		if result["block"] != null:
			return result
	
	# Если ничего не найдено, возвращаем null значения
	return {"block": null, "parent": null}

static func is_descendant_of(block: BlockResource, potential_ancestor: BlockResource) -> bool:
	if block == potential_ancestor:
		return true
	
	for sub_block in potential_ancestor.sub_blocks:
		if is_descendant_of(block, sub_block):
			return true
	
	return false
