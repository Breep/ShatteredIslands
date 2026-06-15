# AuraComponent — distribue des Modifier à tous les alliés du porteur (buff d'équipe).
# Pendant "push" du SummonModifiersRegistry : clone + id dérivé par allié, propagation
# aux alliés présents ET aux futurs spawns, révocation à la mort du porteur.
class_name AuraComponent
extends EntityComponent

#region ============================== Export ==============================
# Quand true (défaut), la mort du porteur retire l'aura de tous les alliés. Passer
# à false pour une aura qui survit au porteur (effet de type bannière / last stand).
@export var _expires_on_death: bool = true
#endregion

#region ============================== Private variables ==============================
# Templates portés par cette aura, indexés par leur id d'origine. Source de vérité
# repropagée aux alliés (présents et futurs).
var _modifiers: Dictionary[StringName, Modifier] = {}

# Alliés déjà servis → { id_origine: clone réellement registered sur l'allié }. On
# garde le clone pour le retirer via le registry homologue (unregister hétérogène).
var _served: Dictionary[Entity, Dictionary] = {}

# Faux tant qu'aucun modifier n'a été ajouté : on ne s'abonne et ne snapshot les
# alliés qu'au premier add, et la mort coupe la propagation aux futurs spawns.
var _active: bool = false
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.aura != null and _owner.aura != self:
		Verbose.trace("Override: AuraComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.aura.queue_free()
	_owner.aura = self
#endregion

#region ============================== Public functions ==============================
# Ajoute un modifier à l'aura et le propage aux alliés (présents + futurs spawns).
func add_modifier(modifier: Modifier) -> void:
	_set_modifier(modifier)


# Met à jour un modifier déjà porté (même id) et repropage la nouvelle valeur. Le
# register homologue écrase l'ancien clone via l'unicité d'id.
func update_modifier(modifier: Modifier) -> void:
	_set_modifier(modifier)


# Retire un modifier de l'aura et de tous les alliés servis.
func remove_modifier(id: StringName) -> void:
	if not _modifiers.has(id):
		Verbose.warn("AuraComponent: remove_modifier() id inconnu [" + id + "]", Verbose.Category.ENTITY_MODULE)
	_modifiers.erase(id)
	for ally: Entity in _served.keys():
		if not is_instance_valid(ally): continue
		var served: Dictionary = _served[ally]
		if not served.has(id): continue
		_unregister_clone(ally, served[id])
		served.erase(id)


# Retire l'aura entière de tous les alliés et coupe la propagation aux futurs spawns.
func clear() -> void:
	for ally in _served.keys():
		if not is_instance_valid(ally): continue
		for clone: Modifier in _served[ally].values():
			if not is_instance_valid(clone): continue
			_unregister_clone(ally, clone)
	_served.clear()
	_active = false
#endregion

#region ============================== Private functions ==============================
func _set_modifier(modifier: Modifier) -> void:
	if modifier == null or modifier.id == StringName():
		Verbose.error("AuraComponent: modifier null ou sans id", Verbose.Category.ENTITY_MODULE)
		return
	_ensure_active()
	_modifiers[modifier.id] = modifier
	for ally: Entity in _served.keys():
		if not is_instance_valid(ally): continue
		_apply_one(ally, modifier)


# S'abonne aux détections d'alliés et à la mort du porteur, et snapshot les alliés
# déjà présents. Idempotent : le snapshot + l'abonnement couvrent la fenêtre avant
# que le TargetComponent ne soit démarré (ses seeds rejoueront new_entity_detected).
func _ensure_active() -> void:
	if _active: return
	_active = true
	if _owner.target != null and not _owner.target.new_entity_detected.is_connected(_on_ally_detected):
		_owner.target.new_entity_detected.connect(_on_ally_detected)
	if not _owner.died.is_connected(_on_owner_died):
		_owner.died.connect(_on_owner_died)
	for ally: Entity in _current_allies():
		if not _served.has(ally):
			_served[ally] = {}


func _current_allies() -> Array[Entity]:
	if _owner.target == null:
		return []
	return _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)


func _apply_one(ally: Entity, modifier: Modifier) -> void:
	var clone: Modifier = modifier.clone()
	if clone == null:
		Verbose.error("AuraComponent: clone() null pour [" + modifier.id + "]", Verbose.Category.ENTITY_MODULE)
		return
	clone.id = _derive_id(modifier.id)
	_register_clone(ally, clone)
	if not _served.has(ally):
		_served[ally] = {}
	_served[ally][modifier.id] = clone


# Préfixe l'id du porteur pour éviter qu'une aura de même id portée par un autre
# émetteur n'écrase la nôtre sur un allié partagé (cf. SummonModifiersRegistry).
func _derive_id(original_id: StringName) -> StringName:
	return StringName("%s@%d" % [original_id, _owner.uid])


func _register_clone(ally: Entity, clone: Modifier) -> void:
	if clone is StatModifier:
		ally.stat_modifiers_registry.register_modifier(clone as StatModifier)
	elif clone is ActionModifier:
		ally.action_modifiers_registry.register_modifier(clone as ActionModifier)
	elif clone is AutoAttackModifier:
		ally.auto_attack_modifier_registry.register_modifier(clone as AutoAttackModifier)
	elif clone is DeathModifier:
		ally.death_modifiers_registry.register_modifier(clone as DeathModifier)
	else:
		Verbose.warn("AuraComponent: type de modifier non supporté [" + clone.id + "]", Verbose.Category.ENTITY_MODULE)


func _unregister_clone(ally: Entity, clone: Modifier) -> void:
	if clone is StatModifier:
		ally.stat_modifiers_registry.unregister_modifier(clone as StatModifier)
	elif clone is ActionModifier:
		ally.action_modifiers_registry.unregister_modifier(clone as ActionModifier)
	elif clone is AutoAttackModifier:
		ally.auto_attack_modifier_registry.unregister_modifier((clone as AutoAttackModifier).id)
	elif clone is DeathModifier:
		ally.death_modifiers_registry.unregister_modifier(clone as DeathModifier)
#endregion

#region ============================== Callbacks ==============================
func _on_ally_detected(entity: Entity) -> void:
	if not _active: return
	if not is_instance_valid(entity): return
	if entity.team != _owner.team: return
	if _served.has(entity): return
	_served[entity] = {}
	for modifier: Modifier in _modifiers.values():
		_apply_one(entity, modifier)


func _on_owner_died() -> void:
	if not _expires_on_death: return
	clear()
#endregion
