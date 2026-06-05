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
			if _entity.battle_callback_registry != null:
				_entity.battle_callback_registry.start_timers()
				_entity.battle_callback_registry.execute_battle_start()
		Entity.FightingState.CELEBRATING:
			stop_combat_modules()
			if _entity.battle_callback_registry != null:
				_entity.battle_callback_registry.execute_battle_end()
		Entity.FightingState.SPAWNING, Entity.FightingState.UNDEF:
			pass


func stop_combat_modules() -> void:
	if _entity.target != null: _entity.target.stop()
	if _entity.alterations != null: _entity.alterations.stop()
	if _entity.movement != null: _entity.movement.stop()
	# Auto-attack : on libère la cible standing pour stopper la boucle d'attaque.
	if _entity.auto_attack != null: _entity.auto_attack.clear_target()
	if _entity.battle_callback_registry != null: _entity.battle_callback_registry.stop_timers()
	if _entity.mana != null: _entity.mana.stop()


func start_combat_modules() -> void:
	if _entity.target != null: _entity.target.start()
	if _entity.alterations != null: _entity.alterations.start()
	if _entity.movement != null: _entity.movement.start()
	if _entity.battle_callback_registry != null: _entity.battle_callback_registry.start_timers()
	if _entity.mana != null: _entity.mana.start()
	# Auto-attack : pas de start ici, c'est le controller (IA/Player, Phase 2-3) qui set la cible.
#endregion
