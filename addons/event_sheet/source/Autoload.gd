@tool
extends Node
class_name ESUtils

static func cteate_object(scene, object_path: String, object_name: String, x: float, y: float) -> Node:
	var object: Node = load(object_path).instantiate()
	object.name = object_name
	object.position = Vector2(x, y)
	scene.add_child(object)
	return object
