class_name ThornVolleySpell
extends Spell

## Visuel pur de l'ultimate "Salve épineuse" du Treant : affiche une onde de choc
## au sol autour du lanceur le temps de l'impact, puis se libère. Aucune logique
## de gameplay ici (dégâts + stun gérés par SE_ThornVolley) — calqué sur FireGround
## pour pouvoir re-skinner le VFX ensuite.

var _spawn_pos: Vector3
var _radius: float
var _duration: float

@onready var _visual: Node3D = %ThornVisual


func init(spawn_pos: Vector3, radius: float, duration: float) -> void:
	_spawn_pos = spawn_pos
	_radius = radius
	_duration = duration


func _ready() -> void:
	global_position = _spawn_pos

	if _visual != null:
		_visual.scale = Vector3(_radius, 1.0, _radius)

	var life := Timer.new()
	life.wait_time = _duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(queue_free)
	add_child(life)
