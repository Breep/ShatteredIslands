class_name UIRankViewer
extends MarginContainer


@export_group("Rank Colors")
@export var rank_color_D: Color = Color("444444")
@export var rank_color_C: Color = Color("6b8c42")
@export var rank_color_B: Color = Color("42688c")
@export var rank_color_A: Color = Color("c53838")
@export var rank_color_S: Color = Color("ffd700")

@export_group("Gradient Settings")
@export_range(0.0, 1.0) var gradient_darken_factor: float = 0.5
@export_range(0.0, 1.0) var gradient_lighten_factor: float = 0.5

const RANK_ASSETS = {
	StormCallerManager.Rank.D: {
		"tex": preload("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/RankViewer/RankVisual/D.png")
	},
	StormCallerManager.Rank.C: {
		"tex": preload("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/RankViewer/RankVisual/C.png")
	},
	StormCallerManager.Rank.B: {
		"tex": preload("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/RankViewer/RankVisual/B.png")
	},
	StormCallerManager.Rank.A: {
		"tex": preload("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/RankViewer/RankVisual/A.png")
	},
	StormCallerManager.Rank.S: {
		"tex": preload("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/RankViewer/RankVisual/S.png")
	}
}

var _owner_hero: Hero
var _pulse_tween: Tween
var _rank_gradients: Dictionary = {}

@onready var _rank_icon: TextureRect = %RankIcon
@onready var _shader_mat: ShaderMaterial = _rank_icon.material as ShaderMaterial

func _ready() -> void:
	if _rank_icon.material:
		_rank_icon.material = _rank_icon.material.duplicate()
		_shader_mat = _rank_icon.material as ShaderMaterial
	_generate_gradients()
	_apply_rank_visual(StormCallerManager.Rank.D)
	_rank_icon.pivot_offset = _rank_icon.size / 2

func connect_entity(entity: Entity) -> void:
	if entity == null or not (entity is Hero):
		hide()
		return
	
	var new_hero: Hero = entity as Hero
	if _owner_hero != null and _owner_hero.get_rank_changed_signal().is_connected(_on_rank_changed):
		_owner_hero.get_rank_changed_signal().disconnect(_on_rank_changed)
	
	_owner_hero = new_hero
	#_owner_hero.get_rank_changed_signal().connect(_on_rank_changed) # TODO

func _on_rank_changed(new_rank: StormCallerManager.Rank) -> void:
	show()
	_stop_pulsing()
	
	_apply_rank_visual(new_rank)
	_play_scale_bump()
	
	if new_rank == StormCallerManager.Rank.S:
		_start_pulsing_s_rank()
		if _shader_mat: _shader_mat.set_shader_parameter("speed", 0.3)
	else:
		if _shader_mat:
			_shader_mat.set_shader_parameter("speed", 0.3)
			_shader_mat.set_shader_parameter("brilliance", 1.2)

#region ===== GESTION VISUELLE =====

func _generate_gradients() -> void:
	for rank_enum in RANK_ASSETS:
		var base_col: Color = _get_rank_color(rank_enum)
		var grad := Gradient.new()
		grad.set_color(0, base_col.darkened(gradient_darken_factor))
		grad.set_color(1, base_col.lightened(gradient_lighten_factor))
		
		var grad_tex := GradientTexture1D.new()
		grad_tex.gradient = grad
		_rank_gradients[rank_enum] = grad_tex

func _play_scale_bump() -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_ELASTIC)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(_rank_icon, "scale", Vector2(2, 2), 0.15)
	t.tween_property(_rank_icon, "scale", Vector2.ONE, 0.25)

func _start_pulsing_s_rank() -> void:
	if _pulse_tween != null and _pulse_tween.is_running():
		return

	# Reset initial
	if _shader_mat:
		_shader_mat.set_shader_parameter("min_brightness", 1.0)
	_rank_icon.scale = Vector2.ONE

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()

	# PHASE 1 : min_brightness 1.0 → 1.15  +  scale 1.0 → 1.08
	var up_tween := _pulse_tween.tween_method(
		func(val): if _shader_mat: _shader_mat.set_shader_parameter("min_brightness", val),
		1.0, 1.15, 0.25
	)
	up_tween.set_trans(Tween.TRANS_SINE)
	up_tween.set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.parallel().tween_property(
		_rank_icon,
		"scale",
		Vector2(1.08, 1.08),
		0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# PHASE 2 : min_brightness 1.15 → 1.0  +  scale 1.08 → 1.0
	var down_tween := _pulse_tween.tween_method(
		func(val): if _shader_mat: _shader_mat.set_shader_parameter("min_brightness", val),
		1.15, 1.0, 0.25
	)
	down_tween.set_trans(Tween.TRANS_SINE)
	down_tween.set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.parallel().tween_property(
		_rank_icon,
		"scale",
		Vector2.ONE,
		0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_pulsing() -> void:
	if _pulse_tween: _pulse_tween.kill()
	_pulse_tween = null
	
	_rank_icon.scale = Vector2.ONE
	if _shader_mat:
		_shader_mat.set_shader_parameter("min_brightness", 2.0)

func _get_rank_color(rank_enum: StormCallerManager.Rank) -> Color:
	match rank_enum:
		StormCallerManager.Rank.D: return rank_color_D
		StormCallerManager.Rank.C: return rank_color_C
		StormCallerManager.Rank.B: return rank_color_B
		StormCallerManager.Rank.A: return rank_color_A
		StormCallerManager.Rank.S: return rank_color_S
		_: return Color.WHITE

func _apply_rank_visual(rank_enum: StormCallerManager.Rank) -> void:
	if not RANK_ASSETS.has(rank_enum):
		return
	
	var data: Dictionary = RANK_ASSETS[rank_enum]
	
	_rank_icon.texture = data["tex"]
	_rank_icon.pivot_offset = _rank_icon.size / 2
	
	if _shader_mat and _rank_gradients.has(rank_enum):
		_shader_mat.set_shader_parameter("gradient_texture", _rank_gradients[rank_enum])

#endregion
