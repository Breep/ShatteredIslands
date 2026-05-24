extends VBoxContainer
class_name ContainerTween

enum ANIM_WHEN {
	READY,
	MANUAL
}

enum ANIM_TYPE {
	SCALE,
	SLIDE_IN_LEFT,
	SLIDE_IN_RIGHT,
	SLIDE_IN_TOP,
	SLIDE_IN_BOTTOM
}

enum ORDER_TYPE {
	START_TOP,
	START_BOTTOM,
	RANDOM
}

enum SCALE_FROM {
	CENTER,
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

@export var anim_when: ANIM_WHEN = ANIM_WHEN.READY
@export var anim_type: ANIM_TYPE = ANIM_TYPE.SCALE
@export var order_type: ORDER_TYPE = ORDER_TYPE.START_TOP
@export var scale_from: SCALE_FROM = SCALE_FROM.CENTER

@export var duration: float = 0.2
@export var delay_appear: float = 0.2
@export var delay_between_elements: float = 0.05
@export var change_visible: bool = true
@export var slide_distance: float = 120.0

var tween: Tween


func _ready() -> void:
	_prepare_children()

	if anim_when == ANIM_WHEN.READY:
		appear.call_deferred()


func appear() -> void:
	if tween and tween.is_running():
		tween.kill()

	if change_visible:
		visible = true

	var children := _get_ordered_children()

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	var delay := delay_appear

	for child in children:
		_prepare_child_start(child)

		match anim_type:
			ANIM_TYPE.SCALE:
				tween.parallel().tween_property(child, "scale", Vector2.ONE, duration).set_delay(delay)
				tween.parallel().tween_property(child, "modulate:a", 1.0, duration).set_delay(delay)

			ANIM_TYPE.SLIDE_IN_LEFT, ANIM_TYPE.SLIDE_IN_RIGHT, ANIM_TYPE.SLIDE_IN_TOP, ANIM_TYPE.SLIDE_IN_BOTTOM:
				tween.parallel().tween_property(child, "position", _get_final_position(child), duration).set_delay(delay)
				tween.parallel().tween_property(child, "modulate:a", 1.0, duration).set_delay(delay)

		delay += delay_between_elements


func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()

	var children := _get_ordered_children()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)

	var delay := 0.0

	for child in children:
		match anim_type:
			ANIM_TYPE.SCALE:
				tween.parallel().tween_property(child, "scale", Vector2.ZERO, duration).set_delay(delay)
				tween.parallel().tween_property(child, "modulate:a", 0.0, duration).set_delay(delay)

			ANIM_TYPE.SLIDE_IN_LEFT, ANIM_TYPE.SLIDE_IN_RIGHT, ANIM_TYPE.SLIDE_IN_TOP, ANIM_TYPE.SLIDE_IN_BOTTOM:
				tween.parallel().tween_property(child, "position", _get_slide_start_position(child), duration).set_delay(delay)
				tween.parallel().tween_property(child, "modulate:a", 0.0, duration).set_delay(delay)

		delay += delay_between_elements

	if change_visible:
		tween.finished.connect(func():
			visible = false
		)


func _prepare_children() -> void:
	for child in get_children():
		if child is Control:
			var control := child as Control
			_save_final_position(control)
			_set_pivot(control)


func _prepare_child_start(control: Control) -> void:
	_set_pivot(control)

	match anim_type:
		ANIM_TYPE.SCALE:
			control.scale = Vector2.ZERO
			control.modulate.a = 0.0

		ANIM_TYPE.SLIDE_IN_LEFT, ANIM_TYPE.SLIDE_IN_RIGHT, ANIM_TYPE.SLIDE_IN_TOP, ANIM_TYPE.SLIDE_IN_BOTTOM:
			_save_final_position(control)
			control.position = _get_slide_start_position(control)
			control.modulate.a = 0.0


func _get_ordered_children() -> Array[Control]:
	var result: Array[Control] = []

	for child in get_children():
		if child is Control:
			result.append(child)

	match order_type:
		ORDER_TYPE.START_TOP:
			pass
		ORDER_TYPE.START_BOTTOM:
			result.reverse()
		ORDER_TYPE.RANDOM:
			result.shuffle()

	return result


func _save_final_position(control: Control) -> void:
	control.set_meta("final_position", control.position)


func _get_final_position(control: Control) -> Vector2:
	return control.get_meta("final_position", control.position)


func _get_slide_start_position(control: Control) -> Vector2:
	var final_pos := _get_final_position(control)

	match anim_type:
		ANIM_TYPE.SLIDE_IN_LEFT:
			return final_pos + Vector2(-slide_distance, 0)
		ANIM_TYPE.SLIDE_IN_RIGHT:
			return final_pos + Vector2(slide_distance, 0)
		ANIM_TYPE.SLIDE_IN_TOP:
			return final_pos + Vector2(0, -slide_distance)
		ANIM_TYPE.SLIDE_IN_BOTTOM:
			return final_pos + Vector2(0, slide_distance)

	return final_pos


func _set_pivot(control: Control) -> void:
	match scale_from:
		SCALE_FROM.CENTER:
			control.pivot_offset = control.size / 2.0
		SCALE_FROM.TOP_LEFT:
			control.pivot_offset = Vector2.ZERO
		SCALE_FROM.TOP_CENTER:
			control.pivot_offset = Vector2(control.size.x / 2.0, 0.0)
		SCALE_FROM.TOP_RIGHT:
			control.pivot_offset = Vector2(control.size.x, 0.0)
		SCALE_FROM.BOTTOM_LEFT:
			control.pivot_offset = Vector2(0.0, control.size.y)
		SCALE_FROM.BOTTOM_CENTER:
			control.pivot_offset = Vector2(control.size.x / 2.0, control.size.y)
		SCALE_FROM.BOTTOM_RIGHT:
			control.pivot_offset = control.size
