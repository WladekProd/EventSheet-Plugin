
const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

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

static func get_template(_params: Dictionary = params()) -> String:
	return """
var object: Node = load("{object}").instantiate()
object.name = {name}
object.position = Vector2({x}, {y})
self.add_child(object)
""".format({
		"object": _params["object"]["value"],
		"name": _params["name"]["value"],
		"x": _params["x"]["value"],
		"y": _params["y"]["value"],
	})

static func get_info(_params: Dictionary = params()) -> String:
	return """Create object: [img=15]{object}[/img] {name} at ({x}, {y})""".format({
		"object": ESUtils.get_file_icon(_params["object"]["value"]),
		"name": _params["name"]["value"],
		"x": _params["x"]["value"],
		"y": _params["y"]["value"],
	})
