
var params: Dictionary = {
	"text": ""
}

func get_template(params: Dictionary = params) -> String:
	return """print({text})""".format(params)
