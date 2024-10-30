@tool
extends VBoxContainer

func _ready() -> void:
	pass

func fix_items_size():
	var max_x_size: float = 0
	for item in get_children():
		for label in item.get_children():
			if label is Label:
				label.custom_minimum_size.x = 0
	for item in get_children():
		for label in item.get_children():
			if label is Label:
				if label.size.x > max_x_size:
					max_x_size = label.size.x
	for item in get_children():
		for label in item.get_children():
			if label is Label:
				label.custom_minimum_size.x = max_x_size
