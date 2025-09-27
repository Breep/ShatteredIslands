@tool

extends Container
class_name HexGridContainer

@export var columns: int = 5:
	set(value):
		columns = max(1, value)
		queue_sort()

@export var pointy_top := true: # true = rows offset (odd-r / even-r)
	set(value):
		pointy_top = value
		queue_sort()

@export var odd_offset := true: # odd-r / odd-q (true) or even-r / even-q (false)
	set(value):
		odd_offset = value
		queue_sort()

@export var cell_size := Vector2(128, 128): # size each child will get
	set(value):
		cell_size = value
		queue_sort()

@export var gap := Vector2(8, 8): # extra spacing between logical cells
	set(value):
		gap = value
		queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_layout_children()

func _layout_children():
	# Theme-like separations (optional)
	var hsep := gap.x
	var vsep := gap.y

	var kids: Array[Control] = []
	for c in get_children():
		if c is Control and c.visible:
			kids.append(c)

	if kids.is_empty():
		return

	# Effective pitch and offsets
	var W := cell_size.x
	var H := cell_size.y

	var pitch_x: float
	var pitch_y: float
	var offset_half: float

	if pointy_top:
		# Pointy-top: rows are staggered. Horizontal pitch = full width, vertical pitch = 3/4 height.
		pitch_x = W + hsep
		pitch_y = H * 0.75 + vsep
		offset_half = W * 0.5
	else:
		# Flat-top: columns are staggered. Horizontal pitch = 3/4 width, vertical pitch = full height.
		pitch_x = W * 0.75 + hsep
		pitch_y = H + vsep
		offset_half = H * 0.5

	var content_min := Vector2(INF, INF)
	var content_max := Vector2(-INF, -INF)

	for i in kids.size():
		var row := i / columns
		var col := i % columns

		var pos := Vector2.ZERO
		if pointy_top:
			# Offset every other ROW by half the width
			var odd_row := (row % 2) == 1
			var apply_offset := odd_row if odd_offset else !odd_row
			pos.x = col * pitch_x + (offset_half if apply_offset else 0.0)
			pos.y = row * pitch_y
		else:
			# Offset every other COLUMN by half the height
			var odd_col := (col % 2) == 1
			var apply_offset := odd_col if odd_offset else !odd_col
			pos.x = col * pitch_x
			pos.y = row * pitch_y + (offset_half if apply_offset else 0.0)

		# Fit child
		var rect := Rect2(pos, cell_size)
		fit_child_in_rect(kids[i], rect)

		content_min = content_min.min(rect.position)
		content_max = content_max.max(rect.position + rect.size)

	# Optional: center content inside this container
	var content_size := content_max - content_min
	var origin := (size - content_size) * 0.5 - content_min
	for c in kids:
		c.position += origin

func _get_minimum_size() -> Vector2:
	# Rough minimum based on current child count & settings
	var count := 0
	for c in get_children():
		if c is Control and c.visible:
			count += 1
	if count == 0:
		return Vector2.ZERO

	var rows := int(ceil(float(count) / float(columns)))
	var W := cell_size.x
	var H := cell_size.y

	if pointy_top:
		var width := (columns - 1) * (W + gap.x) + W + (W * 0.5) # account for offset
		var height := (rows - 1) * (H * 0.75 + gap.y) + H
		return Vector2(width, height)
	else:
		var width := (columns - 1) * (W * 0.75 + gap.x) + W
		var height := (rows - 1) * (H + gap.y) + H + (H * 0.5) # account for offset
		return Vector2(width, height)
