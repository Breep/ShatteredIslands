class_name BattleReader
extends Node

# [CLIENT ONLY]

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _entity_manager: EntityManager

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary] = []

var _start_time: float
var _current_index: int = 0
var _is_playing: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server(): queue_free() # Only clients read battle logs
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	GlobalFightingManager.all_fights_are_over.connect(_on_gfm_all_fights_are_over)


func _process(_delta: float) -> void:
	if not _is_playing or _current_index >= _battle_logs.size(): return
	var elapsed_time: float = (Time.get_ticks_msec() as float) / 1000.0 - _start_time
	while _current_index < _battle_logs.size() and _battle_logs[_current_index][BattleLog.Main.TIME] <= elapsed_time:
		_apply_log(_battle_logs[_current_index])
		_current_index += 1

# ============================== Public function ==============================

func add_log(logs: Array[Dictionary]) -> void:
	_battle_logs += logs


func _on_gfm_fighting_phase_state_changed(state: GlobalFightingManager.FightingPhaseState) -> void:
	match state:
		GlobalFightingManager.FightingPhaseState.NORMAL:
			_start_playback()
		GlobalFightingManager.FightingPhaseState.FINISHED:
			_stop_playback()


func _on_gfm_all_fights_are_over() -> void:
	_battle_logs.clear()
	_current_index = 0

# ============================== Private function ==============================

func _start_playback() -> void:
	_start_time = (Time.get_ticks_msec() as float) / 1000.0
	_current_index = 0
	_is_playing = true


func _stop_playback() -> void:
	_is_playing = false


func _apply_log(battle_log: Dictionary) -> void:
	var type: BattleLog.Type = battle_log.get(BattleLog.Main.TYPE, -1)
	match type:
		BattleLog.Type.AUTO_ATTACK:          _apply_auto_attack(battle_log)
		BattleLog.Type.SPELL_CASTED:         _apply_spell_casted(battle_log)
		BattleLog.Type.ACTION_DONE:          _apply_action_done(battle_log)
		BattleLog.Type.INTERACTION_RECEIVED: _apply_interaction_received(battle_log)
		_: Verbose.warn("Unknown battle_log type received | " + str(type), Verbose.Category.BATTLE_READER)

# ============================== Logs applied ==============================

#{"time":0.1, "type":"auto_attack", "source":1, "target":2, "modifier":{"critical":true, "poison":false, "ignite":false, "instability":true}}
func _apply_auto_attack(battle_log: Dictionary) -> void:
	var source_id: int = battle_log.get(BattleLog.Main.SOURCE, -1)
	var target_id: int = battle_log.get(BattleLog.Main.TARGET, -1)
	Verbose.trace("Auto-attack: " + str(source_id) + "->" + str(target_id), Verbose.Category.BATTLE_READER)
	var source: Entity = _entity_manager.get_entity(source_id)
	var target: Entity = _entity_manager.get_entity(target_id)
	if source == null or target == null: return
	var projectile_spawn: Node3D = source.get_auto_attack_spawn()
	#source.projectile_attack(target, Projectile.ProjectileType.AUTO_ATTACK, projectile_spawn, ProjectileStats.new()) # TODO use auto attack api


#{"time":0.1, "type":"spell_casted", "source":1, "target":2, "spell_type":<spell_type>}
func _apply_spell_casted(battle_log: Dictionary) -> void:
	var source_id: int = battle_log.get(BattleLog.Main.SOURCE, -1)
	var source: Entity = _entity_manager.get_entity(source_id)
	if source == null: return
	
	var target_id: int = battle_log.get(BattleLog.Main.TARGET, -1)
	var target: Entity = _entity_manager.get_entity(target_id) if target_id != -1 else null
	
	var spell_type: Spell.Type = battle_log.get(BattleLog.Main.SPELL_TYPE, -1)
	var spell_modifier: Dictionary = battle_log.get(BattleLog.Main.SPELL_MODIFIER, {})
	
	source.cast_spell(target, spell_type, spell_modifier)


#region ACTION/INTERACTION
#var data: Dictionary = {
	#BattleLog.Main.TIME: _get_time(),
	#BattleLog.Main.TYPE: BattleLog.Type.ACTION_DONE,
	#BattleLog.Main.ACTION_TYPE: action_type,
	#BattleLog.Main.ACTION_ID: action_id,
	#BattleLog.Main.VALUE: value,
	#BattleLog.Main.CRITICAL: is_critical,
	#BattleLog.Main.SOURCE: source.id,
	#BattleLog.Main.TARGET: target.id
#}
func _apply_action_done(battle_log: Dictionary) -> void:
	var source_id: int = battle_log.get(BattleLog.Main.SOURCE, -1)
	var source: Entity = _entity_manager.get_entity(source_id)
	if source == null:
		Verbose.error("_apply_action_done() -> Unknown source")
		return
	
	var target_id: int = battle_log.get(BattleLog.Main.TARGET, -1)
	var target: Entity = _entity_manager.get_entity(target_id)
	if target == null:
		Verbose.error("_apply_action_done() -> Unknown target")
		return
	
	var action_type: Utils.ActionType = battle_log.get(BattleLog.Main.ACTION_TYPE, -1)
	var action_id: StringName = battle_log.get(BattleLog.Main.ACTION_ID, "Unknown action")
	var value: float = battle_log.get(BattleLog.Main.VALUE, -1)
	var is_critical: bool = battle_log.get(BattleLog.Main.CRITICAL, false)
	
	source.signal_action_done(target, action_type, action_id, value, is_critical)


#var data: Dictionary = {
	#BattleLog.Main.TIME: _get_time(),
	#BattleLog.Main.TYPE: BattleLog.Type.ACTION_DONE,
	#BattleLog.Main.ACTION_TYPE: action_type,
	#BattleLog.Main.ACTION_ID: action_id,
	#BattleLog.Main.VALUE: value,
	#BattleLog.Main.CRITICAL: is_critical,
	#BattleLog.Main.RECEIVER: receiver.id,
	#BattleLog.Main.SOURCE: source.id if source != null else -1,
#}
func _apply_interaction_received(battle_log: Dictionary) -> void:
	var receiver_id: int = battle_log.get(BattleLog.Main.RECEIVER, -1)
	var receiver: Entity = _entity_manager.get_entity(receiver_id)
	if receiver == null:
		Verbose.error("_apply_interaction_received() -> Unknown receiver")
		return
	
	var source_id: int = battle_log.get(BattleLog.Main.TARGET, -1)
	var source: Entity = _entity_manager.get_entity(source_id) if source_id != -1 else null
	
	var action_type: Utils.ActionType = battle_log.get(BattleLog.Main.ACTION_TYPE, -1)
	var action_id: StringName = battle_log.get(BattleLog.Main.ACTION_ID, "Unknown action")
	var value: float = battle_log.get(BattleLog.Main.VALUE, -1)
	var is_critical: bool = battle_log.get(BattleLog.Main.CRITICAL, false)
	
	_map_interaction(receiver, source, action_type, action_id, value, is_critical)
#endregion


# ============================== Action/Interaction Mapping ==============================

func _map_interaction(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	match action_type:
		Utils.ActionType.DAMAGE_PHYSICAL: receiver.take_damage(value, Utils.DamageType.PHYSICAL, is_critical, action_id, source)
		Utils.ActionType.DAMAGE_MAGICAL: receiver.take_damage(value, Utils.DamageType.MAGICAL, is_critical, action_id, source)
		Utils.ActionType.DAMAGE_POISON: receiver.take_damage(value, Utils.DamageType.POISON, is_critical, action_id, source)
		Utils.ActionType.UTILITY_HEAL: receiver.take_heal(value, is_critical, action_id, source)
		Utils.ActionType.UTILITY_STUN: Verbose.warn("Stun not implemented", Verbose.Category.BATTLE_READER)
		Utils.ActionType.UTILITY_CLEANSE: receiver.take_cleanse(value, is_critical, action_id, source)
		Utils.ActionType.UTILITY_DISPELL: receiver.take_dispell(value, is_critical, action_id, source)
		Utils.ActionType.STACK_SHIELD: receiver.take_condition_stacks(value, Utils.StackType.SHIELD, is_critical, action_id, source)
		Utils.ActionType.STACK_IGNITE: receiver.take_condition_stacks(value, Utils.StackType.IGNITE, is_critical, action_id, source)
		Utils.ActionType.STACK_POISON: receiver.take_condition_stacks(value, Utils.StackType.POISON, is_critical, action_id, source)
		Utils.ActionType.STACK_REGEN: receiver.take_condition_stacks(value, Utils.StackType.REGEN, is_critical, action_id, source)
		Utils.ActionType.STACK_NECROSIS: receiver.take_condition_stacks(value, Utils.StackType.NECROSIS, is_critical, action_id, source)





 
