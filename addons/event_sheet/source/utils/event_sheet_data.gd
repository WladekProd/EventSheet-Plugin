
# =-=-=-= // Event Sheet
static func create_event_sheet(name: String) -> Dictionary:
	return {
		"uuid": ESUtils.UUID.v4(),
		"name": name,
		"blocks": []
	}

# =-=-=-= // Block
static func create_block(type: String, level: int = 0, parameters: Dictionary = {}) -> Dictionary:
	match type:
		"variable":
			return {
				"uuid": ESUtils.UUID.v4(),
				"class": "block",
				"type": "variable",
				"level": level,
				"parameters": {
					"variable_is_global": parameters.variable_is_global,
					"variable_name": parameters.variable_name,
					"variable_type": parameters.variable_type,
					"variable_value": parameters.variable_value
				}
			}
		"comment":
			return {
				"uuid": ESUtils.UUID.v4(),
				"class": "block",
				"type": "comment",
				"level": level,
				"parameters": {
					"comment_text": parameters.comment_text
				}
			}
		"group":
			return {
				"uuid": ESUtils.UUID.v4(),
				"class": "block",
				"type": "group",
				"expand": true,
				"level": level,
				"parameters": {
					"group_name": parameters.group_name,
					"group_description": parameters.group_description
				},
				"childrens": []
			}
		_:
			return {
				"uuid": ESUtils.UUID.v4(),
				"class": "block",
				"type": "standart",
				"expand": true,
				"level": level,
				"events": [],
				"actions": [],
				"childrens": []
			}

# =-=-=-= // Event
static func create_event(name: String, type: String, script_path: String, object, params) -> Dictionary:
	match type:
		_:
			return {
				"uuid": ESUtils.UUID.v4(),
				"name": name,
				"type": "standart",
				"class": "event",
				"script": script_path,
				"object": object,
				"parameters": params
			}

# =-=-=-= // Action
static func create_action(name: String, type: String, script_path: String, object, params) -> Dictionary:
	match type:
		_:
			return {
				"uuid": ESUtils.UUID.v4(),
				"name": name,
				"type": "standart",
				"class": "action",
				"script": script_path,
				"object": object,
				"parameters": params
			}
