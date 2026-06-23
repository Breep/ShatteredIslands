# Grenade — projectile d'abilité à trajectoire en cloche dont le comportement
# par défaut est une explosion AoE à l'impact : VFX d'explosion électrique +
# dégâts magiques (part flat + ratio de l'AP du lanceur) + stacks de vulnérabilité
# (magique) à tous les ennemis dans un rayon autour du point d'impact.
#
# Variables par-level : _damage, _damage_ratio, _vulnerability_stacks, _hit_radius
# sont des Array @export indexées par level (résolu par ProjectileComponent +
# LevelResolver, repris depuis _stats.level dans Projectile.init()).
# L'attribution des actions (pour le pipeline damage / alterations) vient de
# _stats.source_id, mis par l'émetteur (typiquement card_name côté carte).
class_name Grenade
extends Projectile

const _EXPLOSION_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/Grenade/VFX/VFX_Explosion_Electric_B.tscn")
const _EXPLOSION_LIFETIME: float = 3.0

## Dégâts magiques flat infligés à l'impact, par level.
@export var _damage: Array[float] = []
## Ratio de l'AP du lanceur ajouté aux dégâts magiques, par level.
@export var _damage_ratio: Array[float] = []
@export var _vulnerability_stacks: Array[float] = []
## Rayon (unités monde) de la zone d'explosion par level.
@export var _hit_radius: Array[float] = []


func _ready() -> void:
	# Auto-register le comportement par défaut AVANT que super._ready() ne fasse
	# tourner les on_spawn callbacks de la carte. Au moment où le 1er hit
	# arrive, _aoe_explosion est déjà dans la liste.
	if _stats != null:
		_stats.on_hit_callbacks.append(_aoe_explosion)
	super._ready()


## Impact-sol sans avoir touché d'ennemi en vol : on explose quand même au point
## de chute. Si la grenade a déjà touché un ennemi, comportement par défaut
## (destruction) — l'explosion a déjà eu lieu via le hit.
func on_reached_ground() -> void:
	if not _hit_history.is_empty():
		super.on_reached_ground()
		return
	_aoe_explosion({
		ProjectileStats.VarType.SOURCE: _source,
		ProjectileStats.VarType.POSITION: global_position,
	})
	queue_free()


func _aoe_explosion(cb_vars: Dictionary) -> void:
	var source: Entity = cb_vars.get(ProjectileStats.VarType.SOURCE)
	if not is_instance_valid(source): return
	var impact_pos: Vector3 = cb_vars.get(ProjectileStats.VarType.POSITION, global_position)

	var damage: float = value_at_level(_damage, level, 0.0) \
		+ value_at_level(_damage_ratio, level, 0.0) * source.stats.get_stat(EntityStats.StatType.AP)
	var vulnerability_stacks: float = value_at_level(_vulnerability_stacks, level, 0.0)
	var hit_radius: float = value_at_level(_hit_radius, level, 0.0) * _source.stats.aoe_size
	var source_id: StringName = _stats.source_id if _stats != null else &""

	_spawn_explosion_vfx(source, impact_pos)

	for enemy: Entity in source.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
		if enemy == null or not is_instance_valid(enemy): continue
		if enemy.global_position.distance_to(impact_pos) > hit_radius: continue
		source.damage.direct(enemy, damage, Utils.ActionType.DAMAGE_MAGICAL, source_id)
		_source.alterations.direct_stack(enemy, vulnerability_stacks, Alteration.Type.VULNERABILITY, &"grenade")


func _spawn_explosion_vfx(source: Entity, pos: Vector3) -> void:
	if not is_instance_valid(source): return
	var vfx := _EXPLOSION_VFX.instantiate() as Node3D
	source.get_tree().current_scene.add_child(vfx)
	vfx.global_position = pos
	AudioManager.play_3d("grenade_explosion", pos)
	# Particules one-shot via AnimationPlayer autoplay "Init" → libération après coup.
	source.get_tree().create_timer(_EXPLOSION_LIFETIME).timeout.connect(func() -> void:
		if is_instance_valid(vfx):
			vfx.queue_free()
	)
