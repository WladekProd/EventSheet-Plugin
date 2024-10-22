
static func params() -> Dictionary:
	return { }

static func get_template(params: Dictionary = params()) -> String:
	return """func __ready() -> void:""".format(params)
