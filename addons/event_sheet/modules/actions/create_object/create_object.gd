
var params: Dictionary = {
	"object": "",
	"name": "",
	"x": "",
	"y": ""
}

func get_template(params: Dictionary = params) -> String:
	return """ESUtils.cteate_object(get_meta("cur_scene"), "{object}", "{name}", {x}, {y})""".format(params)
