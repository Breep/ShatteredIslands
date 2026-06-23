# Meteor (projectile) — tombe du ciel sur la position figée de la cible (cf.
# PathTrajectory) et explose au contact du sol (Area3D du groupe GROUND). Sur
# son passage, inflige à chaque ennemi touché des dégâts magiques en % des PV
# max + des stacks d'ignite. Mêmes principes que Boulder pour le on_hit :
# callback par défaut + détection par signaux, pas d'auto-destruction au
# contact d'une unité (seul le sol le détruit).
class_name MeteorProjectile
extends Projectile

# === CONSTANTS ===
const _EXPLOSION_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Projectiles/Abilities/Big/Meteor/VFX/VFX_meteor_hit.tscn")

# === EXPORTS ===
## Dégâts magiques en % des PV max de la cible, par level.
@export var _damage_percents: Array[float] = []
## Stacks d'ignite infligés, par level.
@export var _ignite_stacks: Array[float] = []
## Délai (s) après impact avant destruction, le temps que le VFX d'explosion
## joue. Le visuel du projectile est caché pendant ce délai.
@export var _explosion_lifetime: float = 2.0

# === PRIVATE VARS ===
@onready var _visual: Node3D = $MeteorVisual

var _exploded: bool = false


# === Node base functions ===

func _ready() -> void:
	if _stats != null:
		_stats.on_hit_callbacks.append(_default_hit)
	if is_instance_valid(_source):
		scale = Vector3.ONE * _source.stats.aoe_size
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	AudioManager.play_3d("meteor_falling", global_position)
	super._ready()


# === Private functions ===

# Comportement par défaut, joué une fois par ennemi touché.
func _default_hit(cb_vars: Dictionary) -> void:
	var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
	if not is_instance_valid(target): return
	var damage: float = target.stats.health_max * value_at_level(_damage_percents, level, 0.0) / 100.0
	_source.damage.direct(target, damage, Utils.ActionType.DAMAGE_MAGICAL, &"meteor")
	_source.alterations.direct_stack(target,
			value_at_level(_ignite_stacks, level, 0.0), Alteration.Type.IGNITE, &"meteor")


func _explode() -> void:
	if _exploded: return
	_exploded = true
	AudioManager.play_3d("meteor_hit_ground", global_position)
	if is_instance_valid(_visual):
		_visual.hide()
	add_child(_EXPLOSION_VFX.instantiate())
	get_tree().create_timer(_explosion_lifetime).timeout.connect(queue_free)


# === Overrides ===
# Comme Boulder : le pipeline mono-cible / auto-destructeur de Projectile n'a
# pas de sens ici. Le météore traverse, déclenche ses callbacks par ennemi, et
# n'est détruit qu'au contact du sol (groupe GROUND).

func process_tick() -> void:
	if _exploded: return
	super.process_tick()


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
	if _exploded: return
	var entity := body as Entity
	if entity == null: return
	if entity in _hit_history: return
	if entity.team == _source.team: return
	_on_hit(entity)


func _on_area_entered(area: Area3D) -> void:
	if _exploded: return
	if area.is_in_group("GROUND"):
		_explode()
