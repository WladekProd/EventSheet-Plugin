
var params: Dictionary = {}

func get_template(params: Dictionary = params) -> String:
	return """func __ready() -> void:""".format(params)
