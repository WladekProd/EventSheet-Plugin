@tool
extends RefCounted

enum Type {
	STRING,
	NUMBER,
	BOOLEAN,
	VECTOR2,
	NODE_PATH,
	RESOURCE
}

class Parameter:
	var name: String
	var type: Type
	var value: Variant
	var required: bool = true
	
	func _init(p_name: String, p_type: Type, p_value: Variant = null, p_required: bool = true):
		name = p_name
		type = p_type
		value = p_value
		required = p_required
	
	func validate() -> bool:
		if required and (value == null or (value is String and value.is_empty())):
			return false
		
		match type:
			Type.STRING:
				return true  # Любое значение можно преобразовать в строку
			Type.NUMBER:
				if value is String:
					return value.is_valid_float() or value.is_valid_int()
				return value is float or value is int
			Type.BOOLEAN:
				if value is String:
					return value.to_lower() in ["true", "false", "1", "0"]
				return value is bool
			Type.VECTOR2:
				if value is String:
					return "," in value
				return value is Vector2
			Type.NODE_PATH:
				return value is NodePath or value is String
			Type.RESOURCE:
				return value is Resource or value is String
		
		return false
	
	func get_typed_value() -> Variant:
		match type:
			Type.STRING:
				return str(value)
			Type.NUMBER:
				return float(value)
			Type.BOOLEAN:
				return bool(value)
			Type.VECTOR2:
				if value is String:
					var parts = value.split(",")
					if parts.size() >= 2:
						return Vector2(float(parts[0]), float(parts[1]))
				return value if value is Vector2 else Vector2.ZERO
			Type.NODE_PATH:
				return NodePath(str(value))
			Type.RESOURCE:
				return value
		
		return value

class ParameterSet:
	var parameters: Dictionary = {}
	
	func add_parameter(param: Parameter):
		parameters[param.name] = param
	
	func get_parameter(name: String) -> Parameter:
		return parameters.get(name)
	
	func validate_all() -> bool:
		for param_name in parameters:
			var param: Parameter = parameters[param_name]
			if not param.validate():
				push_error("Parameter validation failed: %s" % param_name)
				return false
		return true
	
	func get_typed_dict() -> Dictionary:
		var result = {}
		for param_name in parameters:
			var param: Parameter = parameters[param_name]
			result[param_name] = param.get_typed_value()
		return result

static func create_from_dict(params_dict: Dictionary) -> ParameterSet:
	var param_set = ParameterSet.new()
	
	for key in params_dict:
		var param_data = params_dict[key]
		var type_name = param_data.get("type", {}).get("name", "string")
		var value = param_data.get("value", "")
		
		var param_type = _string_to_type(type_name)
		var parameter = Parameter.new(key, param_type, value)
		param_set.add_parameter(parameter)
	
	return param_set

static func _string_to_type(type_name: String) -> Type:
	match type_name:
		"string": return Type.STRING
		"number": return Type.NUMBER
		"boolean": return Type.BOOLEAN
		"vector2": return Type.VECTOR2
		"node_path": return Type.NODE_PATH
		"resource": return Type.RESOURCE
		_: return Type.STRING