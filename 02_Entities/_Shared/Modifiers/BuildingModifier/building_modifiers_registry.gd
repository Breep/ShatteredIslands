# Registry des modifiers appliqués aux buildings du héros propriétaire.
# Stocké sur chaque Entity qui peut "déployer" un building (héros principal).
# Au spawn d'un building, celui-ci remonte sa chaîne `summoner` et apply le
# contenu de chaque ancestor's registry sur lui-même (clone + register).
#
# /!\ DETTE STRUCTURELLE — TODO refacto /!\
# TODO: Modifier le CLAUDE.md en conséquence lors du refacto
# Cf. SummonModifiersRegistry pour le même problème : ce registry encapsule
# 5 sub-registries qui portent de la logique active (recompute stats, signaux
# globaux). Utilisé ici comme store de templates ; side-effects inoffensifs
# tant que personne ne tick / recompute dessus. À séparer "store" vs "registry
# actif" plus tard.
class_name BuildingModifiersRegistry
extends Resource


var stat_modifiers_registry: EntityStatModifiersRegistry
var action_modifiers_registry: ActionModifiersRegistry
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var death_modifiers_registry: DeathModifiersRegistry
var battle_callback_registry: BattleCallbackRegistry

# Bonus de level appliqué aux buildings à leur spawn — sommé le long de la
# chaîne summoner par Entity._apply_inherited_building_modifiers(), puis clampé
# à [1, Entity.MAX_LEVEL] côté Entity. Indexé par `id` (typiquement card_name)
# pour idempotence et unregister propre.
var _level_bonuses: Dictionary[StringName, int] = {}

# Alterations (stacks) accordées à chaque building au spawn. Indexé par `id`
# (typiquement card_name). Chaque grant : { "type": Alteration.Type, "flat": float,
# "pct": float } → stacks = flat + building.health_max * pct / 100.
var _alteration_grants: Dictionary[StringName, Dictionary] = {}


func _init() -> void:
	stat_modifiers_registry = EntityStatModifiersRegistry.new(EntityStats.new())
	# recompute_all() initialise les inner StatModifierDictionary via setup() :
	# sans ça, leur `_stat_type` reste à 0 (HEALTH_MAX) et register_modifier
	# rejette silencieusement tout modifier d'un autre stat_type (AD, AS, etc.).
	# Normalement appelé via update_base_stats côté Entity (ProgressionComponent),
	# mais ici on est un container sans base stats.
	stat_modifiers_registry.recompute_all()
	action_modifiers_registry = ActionModifiersRegistry.new()
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	death_modifiers_registry = DeathModifiersRegistry.new()
	battle_callback_registry = BattleCallbackRegistry.new()


# Clone et register sur les registries homologues du building cible.
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

	# Alterations (stacks) : le grant est émis par l'ancêtre source (le héros qui
	# porte la carte) vers le building → on passe par direct_stack pour traverser
	# le pipeline (résolution serveur + log + replay), jamais par apply_stack.
	if source_ancestor != null and source_ancestor.alterations != null:
		for grant_id: StringName in _alteration_grants:
			var grant: Dictionary = _alteration_grants[grant_id]
			var amount: float = grant["flat"] + target.stats.health_max * grant["pct"] / 100.0
			source_ancestor.alterations.direct_stack(target, amount, grant["type"], grant_id)

	# TODO BattleCallback : voir SummonModifiersRegistry, même limite.


static func _derive_id(original_id: StringName, ancestor: Entity) -> StringName:
	return StringName("%s@%d" % [original_id, ancestor.uid])


# ============================== Level bonus API ==============================

func register_level_bonus(id: StringName, bonus: int) -> void:
	_level_bonuses[id] = bonus


func unregister_level_bonus(id: StringName) -> void:
	_level_bonuses.erase(id)


func get_total_level_bonus() -> int:
	var total: int = 0
	for v: int in _level_bonuses.values():
		total += v
	return total


# ============================== Alteration grant API ==============================

# Accorde des stacks d'une alteration à chaque building au spawn :
# stacks = flat + building.health_max * hp_max_percent / 100.
func register_alteration_grant(id: StringName, type: Alteration.Type, flat: float, hp_max_percent: float = 0.0) -> void:
	_alteration_grants[id] = {"type": type, "flat": flat, "pct": hp_max_percent}


func unregister_alteration_grant(id: StringName) -> void:
	_alteration_grants.erase(id)
