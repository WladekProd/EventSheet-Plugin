
static func params() -> Dictionary:
	return { }

static func get_template(params: Dictionary = params()) -> String:
	return """func _input() -> void:""".format({ })

static func get_info(params: Dictionary = params()) -> String:
	return """Input""".format({ })
