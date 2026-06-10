# Nuit Noire — projectile signature du Dark Knight. Comportement par défaut à
# l'impact : dégâts magiques sur la cible touchée + 1 stack d'un debuff tiré au
# hasard (Weakness OU Vulnerability). Le tirage est refait pour chaque projectile
# (chaque instance reroll son propre debuff dans son on_hit).
#
# Variables par-level : _damage et _debuff_stacks sont des Array @export indexées
# par level (résolu par ProjectileComponent + LevelResolver). L'attribution des
# actions vient de _stats.source_id, posé par l'émetteur.
class_name NuitNoire
extends Projectile

@export var _damage: Array[float] = []
@export var _debuff_stacks: Array[float] = []


func _ready() -> void:
	if _stats != null:
		_stats.on_hit_callbacks.append(_on_impact)
	super._ready()


func _on_impact(cb_vars: Dictionary) -> void:
	var source: Entity = cb_vars.get(ProjectileStats.VarType.SOURCE)
	var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
	if not is_instance_valid(source) or not is_instance_valid(target):
		return

	var damage: float = value_at_level(_damage, level, 0.0)
	var stacks: float = value_at_level(_debuff_stacks, level, 1.0)
	var source_id: StringName = _stats.source_id if _stats != null else &""

	source.damage.direct(target, damage, Utils.ActionType.DAMAGE_MAGICAL, source_id)

	var debuff: Alteration.Type = Utils.pick_random(
		[Alteration.Type.WEAKNESS, Alteration.Type.VULNERABILITY], source.battle_id, "NuitNoire")
	source.alterations.inflict_condition_stacks(target, stacks, debuff, source_id)
