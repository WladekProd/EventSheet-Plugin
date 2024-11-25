@tool
extends CodeEdit

var highlighter = CodeHighlighter.new()
var variable_names = []
var functions = {
	"Built-In": ["_ready()", "_builtin()"],
	"Local": [],
	"Variable": ["set()", "get()", "subscribe(like: bool)"]
}
static var code_template: String = \
"""
extends Node

func __init() -> void:
	{init}

func __ready() -> void:
	{ready}

func __process(delta: float) -> void:
	{process}

func __input(event: InputEvent) -> void:
	{input}
"""

func _ready() -> void:
	highlighter.number_color = Color("#a1ffe0")
	highlighter.symbol_color = Color("#abc9ff")
	highlighter.function_color = Color("#57b3ff")
	highlighter.member_variable_color = Color("#bce0ff")
	
	for control_keyword in ["pass", "if", "elif", "switch", "case", "default", "break", "continue", "return", "for", "while", "foreach"]:
		highlighter.add_keyword_color(control_keyword, Color("#ff8ccc"))
	for keyword in ["var", "int", "bool", "float", "double", "char", "string", "True", "False", "true", "false", "function", "def", "func", "class", "private", "print", "method", "try", "catch", "finally", "throw", "and", "or", "not", "null", "undefined", "in", "final", "static", "let", "const", "export", "import", "internal", "echo", "extends", "super", "this", "void"]:
		highlighter.add_keyword_color(keyword, Color("#ff7085"))
	
	highlighter.add_color_region('"', '"', Color("#ffeda1"))
	highlighter.add_color_region("'", "'", Color("#ffeda1"))
	highlighter.add_color_region("<", ">", Color.GOLDENROD)
	highlighter.add_color_region("//", "", Color("#cdcfd280"))
	highlighter.add_color_region("/*", "*/", Color("#cdcfd280"), false)
	highlighter.add_color_region("#", "", Color("#cdcfd280"))
	
	syntax_highlighter = highlighter
	text = code_template

func extract_variable_name(line):
	var pattern = "var\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*(?::\\s*([a-zA-Z_][a-zA-Z0-9_]*))?\\s*=\\s*([a-zA-Z_][a-zA-Z0-9_]*\\(.*\\)|\\[\\]|\\[.*\\]|\".*\"|\\d+)"
	var regex = RegEx.new()
	regex.compile(pattern)
	var matches = regex.search_all(line)
	for match_var in matches:
		var variable_name = match_var.get_string(1)
		return variable_name

func _on_text_changed() -> void:
	functions["Local"].clear()
	variable_names.clear()
	
	var editor_content = text
	
	var lines = editor_content.split("\n")
	for line in lines:
		if (line.begins_with("func ") or line.begins_with("def ")) and line.find("(") != -1 and line.find(")") != -1:
			var function_code = ""
			if line.begins_with("func "):
				function_code = "func"
			if line.begins_with("def "):
				function_code = "def"
			var function_name: String = line.trim_prefix(function_code).trim_suffix(":").strip_edges()
			if !functions["Local"].has(function_name):
				if function_name.begins_with("def "):
					function_name = function_name.replace("def ", "")
				elif function_name.begins_with("func "):
					function_name = function_name.replace("func ", "")
				functions["Local"].append(function_name)
		
		if line.begins_with("var ") and line.find("=") != 1:
			var variable_name = extract_variable_name(line)
			if variable_name and !variable_names.has(variable_name):
				if variable_name.begins_with("var "):
					variable_name = variable_name.replace("var ", "")
				variable_names.append(variable_name)
		
		for each_f in functions["Local"] + functions["Built-In"]:
			add_code_completion_option(CodeEdit.KIND_FUNCTION, each_f, each_f)
		for each_v in variable_names:
			add_code_completion_option(CodeEdit.KIND_VARIABLE, each_v, each_v)
			
			for other_f in functions["Variable"]:
				var last_text = ""
				for each_text in other_f.replace(")", ""):
					last_text += each_text
					if editor_content.split("\n")[get_caret_line()].ends_with(each_v + "." + last_text):
						add_code_completion_option(CodeEdit.KIND_FUNCTION, other_f, other_f)
		
		for classes in ["var", "int", "bool", "float", "double", "char", "string", "True", "False", "true", "false", "function", "def", "func", "class", "private", "print", "method", "try", "catch", "finally", "throw", "and", "or", "not", "null", "undefined", "in", "final", "static", "let", "const", "export", "import", "internal", "echo", "extends", "super", "this", "void", "pass", "if", "elif", "switch", "case", "default", "break", "continue", "return", "for", "while", "foreach"]:
			add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, classes, classes)
		
		update_code_completion_options(true)
