
const Types = preload("res://addons/event_sheet/source/types.gd")

static func params() -> Dictionary:
	return {
		"object": {
			"order": 0,
			"name": "Object",
			"type": Types.STANDART_TYPES.OPEN_FILE,
			"value": ""
		},
		"name": {
			"order": 1,
			"name": "Name",
			"type": Types.STANDART_TYPES.STRING,
			"value": ""
		},
		"x": {
			"order": 2,
			"name": "X Position",
			"type": Types.STANDART_TYPES.NUMBER,
			"value": ""
		},
		"y": {
			"order": 3,
			"name": "Y Position",
			"type": Types.STANDART_TYPES.NUMBER,
			"value": ""
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """
var object: Node = load("{object}").instantiate()
object.name = {name}
object.position = Vector2({x}, {y})
scene.add_child(object)
""".format({
		"object": params["object"]["value"],
		"name": params["name"]["value"],
		"x": params["x"]["value"],
		"y": params["y"]["value"],
	})

static func get_info(params: Dictionary = params()) -> String:
	return """Create object: {name} at ({x}, {y})""".format({
		"name": params["name"]["value"],
		"x": params["x"]["value"],
		"y": params["y"]["value"],
	})
