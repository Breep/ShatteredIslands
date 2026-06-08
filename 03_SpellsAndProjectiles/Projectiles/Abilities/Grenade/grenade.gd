# Grenade — projectile d'abilité à trajectoire en cloche dont le comportement
# par défaut est une explosion AoE à l'impact : VFX d'explosion électrique +
# dégâts magiques + stacks de vulnérabilité (magique) à tous les ennemis dans
# un rayon autour du point d'impact.
#
# Variables par-level : _damage, _vulnerability_stacks, _hit_radius sont des
# Array @export indexées par level (résolu par ProjectileComponent +
# LevelResolver, repris depuis _stats.level dans Projectile.init()).
# L'attribution des actions (pour le pipeline damage / alterations) vient de
# _stats.source_id, mis par l'émetteur (typiquement card_name côté carte).
class_name Grenade
extends Projectile

const _EXPLOSION_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Projectiles/Abilities/Grenade/VFX/VFX_Explosion_Electric_B.tscn")
const _EXPLOSION_LIFETIME: float = 3.0

@export var _damage: Array[float] = []
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


func _aoe_explosion(cb_vars: Dictionary) -> void:
	var source: Entity = cb_vars.get(ProjectileStats.VarType.SOURCE)
	if not is_instance_valid(source): return
	var impact_pos: Vector3 = cb_vars.get(ProjectileStats.VarType.POSITION, global_position)

	var damage: float = value_at_level(_damage, level, 0.0)
	var vulnerability_stacks: float = value_at_level(_vulnerability_stacks, level, 0.0)
	var hit_radius: float = value_at_level(_hit_radius, level, 0.0)
	var source_id: StringName = _stats.source_id if _stats != null else &""

	_spawn_explosion_vfx(source, impact_pos)

	for enemy: Entity in source.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
		if enemy == null or not is_instance_valid(enemy): continue
		if enemy.global_position.distance_to(impact_pos) > hit_radius: continue
		source.damage.direct(enemy, damage, Utils.ActionType.DAMAGE_MAGICAL, source_id)
		if enemy.alterations != null:
			enemy.alterations.add_typed_stack(Alteration.Type.VULNERABILITY, Utils.ActionType.DAMAGE_MAGICAL, vulnerability_stacks)


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
