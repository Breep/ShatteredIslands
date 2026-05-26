extends TextureRect
class_name SimpleLogoAppear

@export var play_on_ready := true

@export var start_scale := Vector2(0.8, 0.8)
@export var final_scale := Vector2.ONE

@export var fade_duration := 0.4
@export var scale_duration := 0.45

@export var start_delay := 0.0

var tween: Tween
var base_modulate: Color


func _ready() -> void:
	base_modulate = modulate
	pivot_offset = size / 2.0

	if play_on_ready:
		appear.call_deferred()


func appear() -> void:
	if tween and tween.is_running():
		tween.kill()

	visible = true
	pivot_offset = size / 2.0

	scale = start_scale
	modulate.a = 0.0

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"modulate:a",
		base_modulate.a,
		fade_duration
	).set_delay(start_delay)

	tween.tween_property(
		self,
		"scale",
		final_scale,
		scale_duration
	).set_delay(start_delay)\
	 .set_trans(Tween.TRANS_QUINT)\
	 .set_ease(Tween.EASE_OUT)
