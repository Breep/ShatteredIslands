class_name ArdentCelestialManager
extends FamilyManager

const METEOR_DEFAULT_PERIOD: float = 0.2
const METEOR_NOISE_PERIOD: float = 0.05

var _ardent_celestial_stats: FamilyArdentCelestialStats
# Clé = Entity cible, Valeur = nombre de météores en attente pour cette cible
var _meteor_queues: Dictionary[Entity, int] = {}
# Ensemble des Entity pour lesquelles un oneshot est déjà programmé
var _meteor_scheduled: Dictionary[Entity, bool] = {}

func _ready() -> void:
	_ardent_celestial_stats = _owner.families_stats.ardent_celestial


func start() -> void:
	Verbose.debug("ArdentCelestialManager start", Verbose.Category.FAMILY_MANAGER)
	_register_meteor_spell_modifier()
	_add_stack_modifiers()
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0

func stop() -> void:
	Verbose.debug("ArdentCelestialManager stop", Verbose.Category.FAMILY_MANAGER)
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0
	_meteor_queues.clear()
	_meteor_scheduled.clear()


#region ========== MODIFIER: Meteor Spell Modifier ==========
## Registers a persistent SPELL ActionModifier that intercepts ALL METEOR casts.
## Automatically injects damage_percent, radius, on_hit_callbacks, on_cast_callbacks
## from ardent_celestial_stats. Any caller only needs cast_spell(target, METEOR, {}).
func _register_meteor_spell_modifier() -> void:
	var modifier := ActionModifier.new()
	modifier.id = &"ArdentCelestial Meteor"
	modifier.action_type = Utils.ActionCategory.SPELL
	modifier.is_one_time_effect = false
	modifier.auto_cleanup = true
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.SPELL_TYPE) != Spell.Type.METEOR:
			return
		var sm: Dictionary = cb_vars[ActionModifier.VarType.SPELL_MODIFIER]
		if not sm.has(Meteor.Modifier.DAMAGE_PERCENT):
			sm[Meteor.Modifier.DAMAGE_PERCENT] = _ardent_celestial_stats.meteor_damage_percent[level]
		if not sm.has(Meteor.Modifier.DAMAGE_FLAT):
			sm[Meteor.Modifier.DAMAGE_FLAT] = _ardent_celestial_stats.meteor_damage_flat[level]
		if not sm.has(Meteor.Modifier.RADIUS):
			sm[Meteor.Modifier.RADIUS] = _ardent_celestial_stats.meteor_radius
		# On_hit et on_cast : on merge les callbacks de la famille avec ceux déjà présents
		var existing_on_hit: Array = sm.get(Meteor.Modifier.ON_HIT_CALLBACKS, [])
		sm[Meteor.Modifier.ON_HIT_CALLBACKS] = existing_on_hit + _ardent_celestial_stats.meteor_on_hit_callbacks
		var existing_on_cast: Array = sm.get(Meteor.Modifier.ON_CAST_CALLBACKS, [])
		sm[Meteor.Modifier.ON_CAST_CALLBACKS] = existing_on_cast + _ardent_celestial_stats.meteor_on_cast_callbacks
	_owner.action_modifiers_registry.register_modifier(modifier)
#endregion


#region ========== PASSIVE: Celestial Passive ==========
func _add_stack_modifiers() -> void:
	if level < 1: return
	var stack_modifier := ActionModifier.new()
	stack_modifier.action_type = Utils.ActionCategory.STACK
	stack_modifier.id = &"Celestial Passive"
	stack_modifier.tags = [ActionModifier.TagType.CARD]
	stack_modifier.after_action_logic_callback = _on_inflict_condition_ignite
	stack_modifier.is_one_time_effect = false
	_owner.action_modifiers_registry.register_modifier(stack_modifier)


func _on_inflict_condition_ignite(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	var stack_type: Alteration.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var stack_value: Alteration.Type = cb_vars.get(ActionModifier.VarType.STACK_VALUE, 0)
	var target: Entity = cb_vars.get(ActionModifier.VarType.TARGET, null)
	if target == null: return
	if stack_type != Alteration.Type.IGNITE: return
	var count: int = 0
	var apocalypse_chance: float = _ardent_celestial_stats.apocalypse_bonus_meteor_chance
	var end_of_the_world_chance: float = _ardent_celestial_stats.end_of_the_world_bonus_meteor_chance 
	var chance: float = _ardent_celestial_stats.meteor_chance[level] + end_of_the_world_chance + apocalypse_chance
	
	# Si chance > 100 alors +1 meteor et chance-100 d'une deuxième meteor
	if chance > 100:
		var meteor_bonus = int(chance/100)
		count += meteor_bonus
		chance = chance - int(chance/100)*100
		
	for i in stack_value:
		if Utils.is_randomize_modifier_active(_ardent_celestial_stats.meteor_chance[level], _owner.battle_id):
			count += 1
	if count == 0: return
	_meteor_queues[target] = _meteor_queues.get(target, 0) + count
	if not _meteor_scheduled.get(target, false):
		_schedule_dequeue_for(target)


func _schedule_dequeue_for(target: Entity) -> void:
	var noise: float = Utils.get_randf_range(-METEOR_NOISE_PERIOD, METEOR_NOISE_PERIOD, _owner.battle_id, "meteor_queue_noise")
	var delay: float = METEOR_DEFAULT_PERIOD + noise
	_owner.periodic_timer_registry.register_oneshot(delay, _dequeue_meteor.bind(target))
	_meteor_scheduled[target] = true


func _dequeue_meteor(target: Variant) -> void:
	if not is_instance_valid(target):
		# La cible a été freed avant le déclenchement du oneshot — on drop la queue
		return
	_meteor_scheduled.erase(target)
	var remaining: int = _meteor_queues.get(target, 0)
	if remaining <= 0:
		_meteor_queues.erase(target)
		return
	# Décrémenter le compteur
	remaining -= 1
	if remaining <= 0:
		_meteor_queues.erase(target)
	else:
		_meteor_queues[target] = remaining
	# Retarget si nécessaire
	var final_target: Entity = target
	if final_target == null:
		final_target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if final_target == null:
		_meteor_queues.erase(target)
		return
	_owner.cast_spell(final_target, Spell.Type.METEOR)
	# S'il reste des météores pour cette cible, programmer le prochain
	if _meteor_queues.has(target):
		_schedule_dequeue_for(target)
#endregion
