# Boulder — projectile d'abilité en ligne droite libre, perçant. Ne s'arrête
# sur aucune unité : il déclenche ses callbacks on_hit sur chaque ennemi
# traversé, et n'est détruit qu'au contact d'un mur (groupe WALL) ou en fin
# de vie. Sa taille — donc sa hitbox — est liée à aoe_size de la source.
# Les dégâts physiques infligés sont une part flat + un ratio de l'AD du lanceur.
class_name Boulder
extends Projectile

# === CONSTANTS ===
## Hauteur et durée du petit saut joué quand le boulder percute un mur.
const _JUMP_HEIGHT: float = 0.6
const _JUMP_DURATION: float = 0.12

# === EXPORTS ===
@export var _stun_durations: Array[float] = []
## Dégâts physiques flat infligés par ennemi traversé, par level.
@export var _damages: Array[float] = []
## Ratio de l'AD du lanceur ajouté aux dégâts physiques, par level.
@export var _damage_ratios: Array[float] = []
## Rayon de roulement (unités monde) servant à convertir la vitesse linéaire
## en vitesse angulaire du visuel. Mis à l'échelle par aoe_size au runtime.
@export var _roll_radius: float = 0.5

# === PRIVATE VARS ===
@onready var _visual: BoulderVisual = %BoulderVisual

var _dying: bool = false


# === Node base functions ===

func _ready() -> void:
	if _stats != null:
		_stats.on_hit_callbacks.append(_default_hit)
	if is_instance_valid(_source):
		scale = Vector3.ONE * _source.stats.aoe_size
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	AudioManager.play_3d("large_boulder_rolling", global_position)
	global_position = Vector3(_source.global_position.x, 0.0, _source.global_position.z)
	super._ready()


# === Private functions ===

# Comportement par défaut, joué une fois par ennemi traversé.
func _default_hit(cb_vars: Dictionary) -> void:
	var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
	if not is_instance_valid(target): return
	_source.alterations.direct_status(target, Alteration.Type.STUN,
			value_at_level(_stun_durations, level, 0.0), &"boulder")
	var damage: float = value_at_level(_damages, level, 0.0) \
			+ value_at_level(_damage_ratios, level, 0.0) * _source.stats.get_stat(EntityStats.StatType.AD)
	_source.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"boulder")


func _destroy() -> void:
	if _dying: return
	_dying = true
	AudioManager.play_3d("large_boulder_hit_wall", global_position)
	if is_instance_valid(_visual):
		_visual.play_impact()
	var base_y: float = position.y
	var tween := create_tween()
	tween.tween_property(self, "position:y", base_y + _JUMP_HEIGHT, _JUMP_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", base_y, _JUMP_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)


# Fait rouler le visuel autour de son axe X local. La boule est orientée par
# look_at (avant = -Z), donc un roulement vers l'avant tourne dans le sens -X.
func _roll(delta: float) -> void:
	if not is_instance_valid(_visual) or trajectory == null: return
	var aoe: float = _source.stats.aoe_size if is_instance_valid(_source) else 1.0
	var radius: float = _roll_radius * aoe
	if radius <= 0.0: return
	var angle: float = (trajectory.speed * delta) / radius
	_visual.roll(angle)


# === Overrides ===
# Le pipeline mono-cible / auto-destructeur de Projectile n'a pas de sens ici :
# Boulder perce et délègue toute sa détection aux signaux de l'Area3D.

func process_tick() -> void:
	if _dying: return
	super.process_tick()
	_roll(1.0 / TICKS_PER_SECOND)


func _check_hit(_from: Vector3, _to: Vector3) -> void:
	pass


func _on_hit(hit_target: Entity) -> void:
	_hit_history.append(hit_target)
	target_hit.emit(hit_target, global_position)
	for cb: Callable in _stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				ProjectileStats.VarType.SOURCE: _source,
				ProjectileStats.VarType.TARGET: hit_target,
				ProjectileStats.VarType.PROJECTILE: self,
				ProjectileStats.VarType.POSITION: global_position,
			})


func _on_target_died() -> void:
	pass


# === Callbacks ===

func _on_body_entered(body: Node3D) -> void:
	if _dying: return
	var entity := body as Entity
	if entity == null: return
	if entity in _hit_history: return
	if entity.team == _source.team: return
	_on_hit(entity)


func _on_area_entered(area: Area3D) -> void:
	if _dying: return
	if area.is_in_group("WALL"):
		_destroy()
