
var params: Dictionary = {
	"variable_a": "",
	"comparison": "",
	"variable_b": ""
}

func get_template(params: Dictionary = params) -> String:
	return """if {variable_a} {comparison} {variable_b}:""".format(params)
