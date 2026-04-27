extends Node3D

const HIT_VFX = preload("res://21_Props/DefaultBattleIsland/Arch_island/VFX/Scenes/VFX_meteor_hit.tscn")

@onready var _meteor_3d: Node3D = %VFX_FireBall
@onready var _path_3d: Path3D = %Path3D
@onready var _path_follow_3d: PathFollow3D = %PathFollow3D

var spells_node: Node3D

var _deploy_time: float = 1.2
var _elapsed: float = 0.0
var _is_falling: bool = false

func _ready() -> void:
	_path_3d.rotate_y(randf_range(0, 360))
	_is_falling = true


func _process(delta: float) -> void:
	if not _is_falling: return
	_elapsed += delta
	var linear_t := clampf(_elapsed / _deploy_time, 0.0, 1.0)
	var eased_t := linear_t * linear_t #* linear_t * linear_t
	_path_follow_3d.progress_ratio = eased_t
	if linear_t >= 1.0:
		_is_falling = false
		_on_impact()


func _on_impact() -> void:
	_meteor_3d.hide()
	var hit: Node3D = HIT_VFX.instantiate()
	if spells_node != null:
		spells_node.add_child(hit)
		hit.global_position = global_position
	else:
		add_child(hit)
	get_tree().create_timer(2.0).timeout.connect(hit.queue_free)
