class_name ArdentCelestialManager
extends FamilyManager

var _ardent_celestial_stats: FamilyArdentCelestialStats

func _ready() -> void:
	_ardent_celestial_stats = _owner.families_stats.ardent_celestial


func start() -> void:
	Verbose.debug("ArdentCelestialManager start", Verbose.Category.FAMILY_MANAGER)
	_add_stack_modifiers()
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0

func stop() -> void:
	Verbose.debug("ArdentCelestialManager stop", Verbose.Category.FAMILY_MANAGER)
	_ardent_celestial_stats.titans_protection_accumulated_hp = 0.0


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
	for i in stack_value:
		if Utils.is_randomize_modifier_active(_ardent_celestial_stats.meteor_chance[level], _owner.battle_id):
			_owner.cast_spell(target, Spell.Type.METEOR, {
					Spell.MeteorModifier.DAMAGE_PERCENT: _ardent_celestial_stats.meteor_damage_percent[level],
					Spell.MeteorModifier.RADIUS: _ardent_celestial_stats.meteor_radius,
					Spell.MeteorModifier.ON_HIT_CALLBACKS: _ardent_celestial_stats.meteor_modifiers
					})
#endregion
