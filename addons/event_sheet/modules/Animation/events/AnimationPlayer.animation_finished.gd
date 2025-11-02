const Types = preload("res://addons/event_sheet/source/utils/event_sheet_types.gd")

static func params() -> Dictionary:
	return {
		"animation_name": {
			"order": 0,
			"name": "Animation Name",
			"type": {
				"name": "string",
				"data": []
			},
			"value": ""
		}
	}

static func get_condition_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "Animation finished",
		"category": Types.Category.ANIMATION,
		"icon": preload("res://addons/event_sheet/resources/icons/start.svg"),
		"change_icon_color": true,
		"description": "Triggered when animation finishes playing."
	}

static func get_object_metadata(object_path: String = "") -> Dictionary:
	return {
		"name": "AnimationPlayer",
		"icon": {}
	}

static func get_template(_params: Dictionary = params()) -> String:
	var anim_name = _params.get("animation_name", {}).get("value", "")
	if anim_name.is_empty():
		return "if animation_finished:"
	return "if animation_finished and current_animation == \"%s\":" % anim_name

static func get_info(_params: Dictionary = params()) -> String:
	var anim_name = _params.get("animation_name", {}).get("value", "")
	if anim_name.is_empty():
		return "Any animation finished"
	return "Animation finished: %s" % anim_name

static func execute(_params: Dictionary, context: Node = null) -> bool:
	if not context or not context is AnimationPlayer:
		return false
	var anim_name = _params.get("animation_name", {}).get("value", "")
	if anim_name.is_empty():
		return not context.is_playing()
	return not context.is_playing() and context.current_animation == anim_name

static func execute_typed(typed_params, context: Node = null) -> bool:
	if not context or not context is AnimationPlayer:
		return false
	var anim_param = typed_params.get_parameter("animation_name")
	if anim_param:
		var anim_name = anim_param.get_typed_value()
		if anim_name.is_empty():
			return not context.is_playing()
		return not context.is_playing() and context.current_animation == anim_name
	return not context.is_playing()