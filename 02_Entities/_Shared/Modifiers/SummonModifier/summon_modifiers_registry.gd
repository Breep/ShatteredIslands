# Registry des modifiers transmis aux summons en chaîne d'invocation.
# Stocké sur chaque Entity invocatrice (héros, acolyte, building, summon).
# Au spawn d'un summon, celui-ci remonte sa chaîne `summoner` et apply le
# contenu de chaque ancestor's registry sur lui-même (clone + register).
#
# /!\ DETTE STRUCTURELLE — TODO refacto /!\
# TODO: Modifier le CLAUDE.md en conséquence lors du refacto
# Ce registry encapsule les 5 mêmes registries qu'Entity
# (Stat / Action / AutoAttack / Death / BattleCallback). Ces registries
# ne sont PAS des data containers purs : ils portent de la logique active
# (recompute des stats côté StatModifier, tick des callbacks côté
# BattleCallback). On les utilise ici comme stores de templates ; leurs
# side-effects sont pour l'instant inoffensifs tant que personne ne déclenche
# process_tick / recompute dessus. À séparer en "modifier store" passif vs
# "modifier registry actif" quand l'API summon sera stabilisée.
class_name SummonModifiersRegistry
extends Resource


var stat_modifiers_registry: EntityStatModifiersRegistry
var action_modifiers_registry: ActionModifiersRegistry
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var death_modifiers_registry: DeathModifiersRegistry
var battle_callback_registry: BattleCallbackRegistry

# Bonus de level appliqué aux summons à leur spawn — sommé le long de la
# chaîne summoner par Entity._apply_inherited_summon_modifiers(), puis clampé
# à [1, Entity.MAX_LEVEL] côté Entity. Indexé par `id` (typiquement card_name)
# pour idempotence et unregister propre.
var _level_bonuses: Dictionary[StringName, int] = {}


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


# Clone le contenu de ce registry et register chaque clone sur les registries
# homologues du summon. Préfixe l'id du clone avec l'uid de l'ancêtre source
# pour garantir l'unicité quand plusieurs ancêtres contribuent à un même
# summon.
func apply_to(summon: Entity, source_ancestor: Entity) -> void:
	for original: StatModifier in stat_modifiers_registry.get_all_modifiers():
		var clone: StatModifier = original.clone() as StatModifier
		clone.id = _derive_id(original.id, source_ancestor)
		summon.stat_modifiers_registry.register_modifier(clone)

	for category: Utils.ActionCategory in [
		Utils.ActionCategory.DAMAGE, Utils.ActionCategory.STACK,
		Utils.ActionCategory.HEAL, Utils.ActionCategory.DODGE,
		Utils.ActionCategory.SUMMON, Utils.ActionCategory.SPELL,
	]:
		for original: ActionModifier in action_modifiers_registry.get_all_modifiers(category):
			var clone: ActionModifier = original.clone() as ActionModifier
			clone.id = _derive_id(original.id, source_ancestor)
			summon.action_modifiers_registry.register_modifier(clone)

	for original: AutoAttackModifier in auto_attack_modifier_registry.get_all_modifiers():
		var clone: AutoAttackModifier = original.clone() as AutoAttackModifier
		clone.id = _derive_id(original.id, source_ancestor)
		summon.auto_attack_modifier_registry.register_modifier(clone)

	for original: DeathModifier in death_modifiers_registry.get_all_modifiers():
		var clone: DeathModifier = original.clone() as DeathModifier
		clone.id = _derive_id(original.id, source_ancestor)
		summon.death_modifiers_registry.register_modifier(clone)

	# TODO BattleCallback : structure interne plus complexe (start/end +
	# periodic/oneshot avec Callables), apply non trivial. À traiter quand
	# une carte le demandera.


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
