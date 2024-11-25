
static func params() -> Dictionary:
	return { }

static func get_template(_params: Dictionary = params()) -> String:
	return """func _input() -> void:""".format({ })

static func get_info(_params: Dictionary = params()) -> String:
	return """Input""".format({ })
