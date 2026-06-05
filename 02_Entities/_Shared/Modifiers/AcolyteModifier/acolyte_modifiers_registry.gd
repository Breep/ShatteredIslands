# Registry des modifiers appliqués aux acolytes du héros propriétaire.
# Stocké sur chaque Entity qui peut "déployer" un acolyte (héros principal).
# Au spawn d'un acolyte, celui-ci remonte sa chaîne `summoner` et apply le
# contenu de chaque ancestor's registry sur lui-même (clone + register).
#
# /!\ DETTE STRUCTURELLE — TODO refacto /!\
# Cf. SummonModifiersRegistry pour le même problème : ce registry encapsule
# 5 sub-registries qui portent de la logique active (recompute stats, signaux
# globaux). Utilisé ici comme store de templates ; side-effects inoffensifs
# tant que personne ne tick / recompute dessus. À séparer "store" vs "registry
# actif" plus tard.
class_name AcolyteModifiersRegistry
extends Resource


var stat_modifiers_registry: EntityStatModifiersRegistry
var action_modifiers_registry: ActionModifiersRegistry
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var death_modifiers_registry: DeathModifiersRegistry
var battle_callback_registry: BattleCallbackRegistry


func _init() -> void:
	stat_modifiers_registry = EntityStatModifiersRegistry.new(EntityStats.new())
	action_modifiers_registry = ActionModifiersRegistry.new()
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	death_modifiers_registry = DeathModifiersRegistry.new()
	battle_callback_registry = BattleCallbackRegistry.new()


# Clone et register sur les registries homologues de l'acolyte cible.
func apply_to(target: Entity, source_ancestor: Entity) -> void:
	for original: StatModifier in stat_modifiers_registry.get_all_modifiers():
		var clone: StatModifier = original.clone() as StatModifier
		clone.id = _derive_id(original.id, source_ancestor)
		target.stat_modifiers_registry.register_modifier(clone)

	for category: Utils.ActionCategory in [
		Utils.ActionCategory.DAMAGE, Utils.ActionCategory.STACK,
		Utils.ActionCategory.HEAL, Utils.ActionCategory.DODGE,
		Utils.ActionCategory.SUMMON, Utils.ActionCategory.SPELL,
	]:
		for original: ActionModifier in action_modifiers_registry.get_all_modifiers(category):
			var clone: ActionModifier = original.clone() as ActionModifier
			clone.id = _derive_id(original.id, source_ancestor)
			target.action_modifiers_registry.register_modifier(clone)

	for original: AutoAttackModifier in auto_attack_modifier_registry.get_all_modifiers():
		var clone: AutoAttackModifier = original.clone() as AutoAttackModifier
		clone.id = _derive_id(original.id, source_ancestor)
		target.auto_attack_modifier_registry.register_modifier(clone)

	for original: DeathModifier in death_modifiers_registry.get_all_modifiers():
		var clone: DeathModifier = original.clone() as DeathModifier
		clone.id = _derive_id(original.id, source_ancestor)
		target.death_modifiers_registry.register_modifier(clone)

	# TODO BattleCallback : voir SummonModifiersRegistry, même limite.


static func _derive_id(original_id: StringName, ancestor: Entity) -> StringName:
	return StringName("%s@%d" % [original_id, ancestor.uid])
