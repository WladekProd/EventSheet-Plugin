@tool
extends Container

@export_range(1,3) var columns : int = 1 :
	set(new_columns):
		if columns == new_columns:
			return
		columns = new_columns
		queue_sort()
		update_minimum_size()

@export_group("Theme Override Constants","theme_")
@export_range(0,1024) var theme_h_separation = 5
@export_range(0,1024) var theme_v_separation = 5
@export_group("")

var padding: int = 0
var is_dragging: bool = false
var drag_offset: int = -1
var column_sizes: Array = [-1,-1]

func _ready() -> void:
	add_to_group("splits")

func _input(event):
	if columns == 2:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() and ESUtils.is_split_hovered:
				is_dragging = event.pressed
				drag_offset = event.position.x - column_sizes[0]
				if ESUtils.is_split_hovered: ESUtils.is_split_pressed = true
			elif !event.is_pressed():
				is_dragging = false
				if ESUtils.is_split_pressed: ESUtils.is_split_pressed = false
		elif event is InputEventMouseMotion and is_dragging and ESUtils.is_split_pressed:
			if is_dragging:
				column_sizes[0] = clamp(event.position.x - drag_offset, 0, get_size().x)
				column_sizes[1] = get_size().x - column_sizes[0] - padding
				queue_sort()
				queue_redraw()

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_handle_sort_children()

func _occupied(occupied, index, col_span, row_span) -> bool:
	for col_count in range(col_span):
		for row_count in range(row_span):
			if occupied.has(index + col_count + row_count*columns):
				return true
	return false

func _calculate_layout( col_minw : Dictionary, row_minh : Dictionary,  col_expanded : Dictionary, row_expanded : Dictionary, child_array : Array, layout : Dictionary ):
	var occupied : Dictionary

	var valid_controls_index = 0
	for child in get_children():
		var control_child = child as Control
		if control_child == null:
			continue
		
		if not control_child.is_visible_in_tree() || control_child.is_set_as_top_level():
			continue
		
		var col_span : int = 1
		var row_span : int = 1
		
		while _occupied(occupied,valid_controls_index, col_span, row_span):
			valid_controls_index += 1
		
		var row : int = valid_controls_index / columns
		var col : int = valid_controls_index % columns
		
		
		child_array.append({"child": child, "row": row, "col": col, "col_span": col_span, "row_span": row_span})
		
		occupied[col + row*columns] = control_child
		valid_controls_index += 1
		
		var ms : Vector2 = control_child.get_combined_minimum_size()
		
		for cn in col_span:
			if col+cn <= columns:
				if col_minw.has(col+cn):
					col_minw[col+cn] = maxi(col_minw[col+cn], ceili(ms.x/col_span))
				else:
					col_minw[col+cn] = ceili(ms.x/col_span)
				
				if control_child.get_h_size_flags() & SIZE_EXPAND:
					col_expanded[col+cn] = true
		
		for rn in row_span:
			if row_minh.has(row+rn):
				row_minh[row+rn] = maxi(row_minh[row+rn], ceili(ms.y/row_span))
			else:
				row_minh[row+rn] = ceili(ms.y/row_span)
			
			if control_child.get_v_size_flags() & SIZE_EXPAND:
				row_expanded[row+rn] = true
	
	while valid_controls_index < columns:
		col_expanded[valid_controls_index] = true
		col_minw[valid_controls_index] = 0
		valid_controls_index += 1
	
	if row_minh.size() == 0:
		row_minh[0] = 0
	
	layout["max_col"] = mini(valid_controls_index, columns)
	layout["max_row"] = row_minh.size()

func _handle_sort_children():
	var col_minw : Dictionary
	var row_minh : Dictionary
	var col_expanded : Dictionary
	var row_expanded : Dictionary
	var layout : Dictionary
	var child_array : Array

	_calculate_layout(col_minw, row_minh, col_expanded, row_expanded, child_array, layout)
	var max_col : int = layout.max_col
	var max_row : int = layout.max_row

	var remaining_space : Vector2i = get_size();
	for key in col_minw:
		var value = col_minw[key]
		if !col_expanded.has(key):
			remaining_space.x -= value;
		
	for key in row_minh:
		var value = row_minh[key]
		if !row_expanded.has(key):
			remaining_space.y -= value;
	
	remaining_space.y -= theme_v_separation * maxi(max_row - 1, 0)
	remaining_space.x -= theme_h_separation * maxi(max_col - 1, 0)
	
	var can_fit : bool = false
	while !can_fit && col_expanded.size() > 0:
		can_fit = true
		var max_index : int = col_expanded.keys().front()
		for E in col_expanded:
			if col_minw[E] > col_minw[max_index]:
				max_index = E
			if can_fit && (remaining_space.x / col_expanded.size()) < col_minw[E]:
				can_fit = false
		
		if !can_fit:
			col_expanded.erase(max_index);
			remaining_space.x -= col_minw[max_index];
	
	can_fit = false
	while !can_fit && row_expanded.size() > 0:
		can_fit = true
		var max_index : int = row_expanded.keys().front()
		for E in row_expanded:
			if row_minh[E] > row_minh[max_index]:
				max_index = E
			if can_fit && (remaining_space.y / row_expanded.size()) < row_minh[E]:
				can_fit = false
		
		if !can_fit:
			row_expanded.erase(max_index)
			remaining_space.y -= row_minh[max_index]
	
	var col_remaining_pixel :int = 0
	var col_expand : int = 0
	if col_expanded.size() > 0:
		col_expand = remaining_space.x / col_expanded.size()
		col_remaining_pixel = remaining_space.x - col_expanded.size() * col_expand
	
	var row_remaining_pixel : int = 0
	var row_expand : int = 0
	if row_expanded.size() > 0:
		row_expand = remaining_space.y / row_expanded.size()
		row_remaining_pixel = remaining_space.y - row_expanded.size() * row_expand
	
	var rtl : bool = is_layout_rtl()
	var col_width : Array[int]
	col_width.resize(max_col)
	var col_pos : Array[int]
	col_pos.resize(max_col)
	var curr_col_pos : int = 0
	if rtl:
		curr_col_pos = get_size().x
	for col in range (max_col):
		col_pos[col] = curr_col_pos
		if col_expanded.has(col):
			col_width[col] = col_expand
			if col_remaining_pixel > 0:
				col_remaining_pixel -= 1
				col_width[col] += 1
		else:
			col_width[col] = col_minw[col]
		if rtl:
			curr_col_pos -= col_width[col]
			col_pos[col] -= col_width[col] - theme_h_separation
		else:
			curr_col_pos += col_width[col] + theme_h_separation
	
	var row_height : Array[int]
	row_height.resize(max_row)
	var row_pos : Array[int]
	row_pos.resize(max_row)
	var curr_row_pos : int = 0
	for row in range (max_row):
		row_pos[row] = curr_row_pos
		if row_expanded.has(row):
			row_height[row] = row_expand
			if col_remaining_pixel > 0:
				row_remaining_pixel -= 1
				row_height[row] += 1
		else:
			row_height[row] = row_minh[row]
		curr_row_pos += row_height[row] + theme_v_separation

	for child_entry in child_array:
		var row = child_entry.row
		var col = child_entry.col
		var col_span = child_entry.col_span
		var row_span = child_entry.row_span

		var p = Vector2i(col_pos[col], row_pos[row])
		var cw = 0
		var rh = 0

		# Рассчитываем ширину и высоту на основе span
		for n in range(col_span):
			if col + n < columns:
				cw += col_width[col + n]
		for n in range(row_span):
			rh += row_height[row + n]

		# Применяем отступы и разделители
		var size = Vector2i(cw + theme_v_separation * (col_span - 1), rh + theme_h_separation * (row_span - 1))
		fit_child_in_rect(child_entry.child, Rect2(p, size))

	# Логика для двух столбцов
	if columns == 2 and child_array.size() >= 2:
		
		if column_sizes[0] == -1:
			column_sizes[0] = child_array[0].child.get_size().x + padding
		
		var cw_left = (col_width[0] - padding if column_sizes[0] == -1 else column_sizes[0])
		var cw_right = (col_width[1] + padding if column_sizes[1] == -1 else column_sizes[1])
		var rh_top = row_height[child_array[0].row]
		var rh_bottom = row_height[child_array[1].row]

		# Устанавливаем позиции и размеры для первого и второго столбца
		fit_child_in_rect(child_array[0].child, Rect2(Vector2i(col_pos[0], row_pos[child_array[0].row]), Vector2i(cw_left - padding, rh_top)))
		fit_child_in_rect(child_array[1].child, Rect2(Vector2i(col_pos[0] + cw_left - padding, row_pos[child_array[1].row]), Vector2i(cw_right, rh_bottom)))

func _get_minimum_size() -> Vector2:
	var col_minw : Dictionary
	var row_minh : Dictionary
	var col_expanded : Dictionary
	var row_expanded : Dictionary
	var layout : Dictionary
	var child_array : Array
	
	_calculate_layout(col_minw, row_minh, col_expanded, row_expanded, child_array, layout)
	var max_col : int = layout.max_col
	var max_row : int = layout.max_row
	
	var min_size : Vector2 = Vector2(theme_h_separation*(max_col-1),theme_v_separation*(max_row-1))
	for w in col_minw.values():
		min_size.x += w
	for h in row_minh.values():
		min_size.y += h
	
	return min_size
