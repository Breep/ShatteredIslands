class_name EntityStateMachine
extends RefCounted

# Coordinates entity lifecycle transitions across combat-related modules.
# Receives a back-reference to its owner Entity and delegates start/stop
# calls to its modules according to the current FightingState.

#region ============================== Private variables ==============================
var _entity: Entity
#endregion

#region ============================== Init ==============================
func _init(entity: Entity) -> void:
	_entity = entity
#endregion

#region ============================== Public functions ==============================
func transition_to(new_state: Entity.FightingState) -> void:
	Verbose.debug("Entity [" + _entity.entity_name + "] state machine transition to [" + str(Entity.FightingState.keys()[new_state]) + "]", Verbose.Category.ENTITY)
	match new_state:
		Entity.FightingState.IDLE:
			stop_combat_modules()
			if _entity.battle_callback_registry != null:
				_entity.battle_callback_registry.execute_battle_end()
		Entity.FightingState.FIGHTING:
			start_combat_modules()
			if _entity.periodic_timer_registry != null:
				_entity.periodic_timer_registry.start_all()
			if _entity.battle_callback_registry != null:
				_entity.battle_callback_registry.execute_battle_start()
		Entity.FightingState.CELEBRATING:
			stop_combat_modules()
			if _entity.battle_callback_registry != null:
				_entity.battle_callback_registry.execute_battle_end()
		Entity.FightingState.SPAWNING, Entity.FightingState.UNDEF:
			pass


# Stops modules and periodic timers; does NOT trigger battle_callback end.
# Asymmetric with start_combat_modules: preserves the exact behavior previously
# inlined in Entity._on_died (timers stop on death) and Entity._on_fighting_state_changed
# IDLE/CELEBRATING (timers stop on combat end).
func stop_combat_modules() -> void:
	if _entity.target != null: _entity.target.stop()
	if _entity.alterations != null: _entity.alterations.stop()
	if _entity.movement != null: _entity.movement.stop()
	if _entity._auto_attack_periodic_module != null and _entity.auto_attack_enabled:
		_entity._auto_attack_periodic_module.stop()
	if _entity.periodic_timer_registry != null:
		_entity.periodic_timer_registry.stop_all()


# Starts modules only; does NOT restart periodic timers nor trigger battle_callback start.
# Asymmetric with stop_combat_modules: preserves the exact behavior previously
# inlined in Entity.resurrect (timers stay where they are on resurrect).
func start_combat_modules() -> void:
	if _entity.target != null: _entity.target.start()
	if _entity.alterations != null: _entity.alterations.start()
	if _entity.movement != null: _entity.movement.start()
	if _entity._auto_attack_periodic_module != null and _entity.auto_attack_enabled:
		_entity._auto_attack_periodic_module.start()
#endregion
