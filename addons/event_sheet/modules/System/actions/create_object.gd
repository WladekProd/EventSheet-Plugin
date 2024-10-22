
static func params() -> Dictionary:
	return {
		"object": {
			"name": "Object",
			"value": ""
		},
		"name": {
			"name": "Name",
			"value": ""
		},
		"x": {
			"name": "X Position",
			"value": ""
		},
		"y": {
			"name": "Y Position",
			"value": ""
		}
	}

static func get_template(params: Dictionary = params()) -> String:
	return """ESUtils.cteate_object(get_meta("cur_scene"), "{object.value}", "{name.value}", {x.value}, {y.value})""".format(params)
