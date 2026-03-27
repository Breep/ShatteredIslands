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
	_add_stack_modifiers()
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0

func stop() -> void:
	Verbose.debug("ArdentCelestialManager stop", Verbose.Category.FAMILY_MANAGER)
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0
	_meteor_queues.clear()
	_meteor_scheduled.clear()


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
	var stack_type: Stack.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var stack_value: Stack.Type = cb_vars.get(ActionModifier.VarType.STACK_VALUE, 0)
	var target: Entity = cb_vars.get(ActionModifier.VarType.TARGET, null)
	if target == null: return
	if stack_type != Stack.Type.IGNITE: return
	var count: int = 0
	for i in stack_value:
		if Utils.is_randomize_modifier_active(_ardent_celestial_stats.meteor_chance[level], _owner.battle_id):
			for cb in _ardent_celestial_stats.meteor_on_cast_callbacks:
				if cb.is_valid():
					cb.call({})
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


func _dequeue_meteor(target: Entity) -> void:
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
	# Vérifier que la cible est encore valide, sinon retarget
	var final_target: Entity = target
	if not is_instance_valid(target):
		final_target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if final_target == null:
		# Plus de cible dispo : on réinjecte le restant nulle part, on drop
		_meteor_queues.erase(target)
		return
	_owner.cast_spell(target, Spell.Type.METEOR, {
				Spell.MeteorModifier.DAMAGE_PERCENT: _ardent_celestial_stats.meteor_damage_percent[level],
				Spell.MeteorModifier.RADIUS: _ardent_celestial_stats.meteor_radius,
				Spell.MeteorModifier.ON_HIT_CALLBACKS: _ardent_celestial_stats.meteor_on_hit_callbacks
				})
	# S'il reste des météores pour cette cible, programmer le prochain
	if _meteor_queues.has(target):
		_schedule_dequeue_for(target)
#endregion
