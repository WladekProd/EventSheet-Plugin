
static func params() -> Dictionary:
	return { }

static func get_template(params: Dictionary = params()) -> String:
	return """func __process(delta: float) -> void:""".format(params)
