class_name BattleWriter
extends Node

# [CLIENT ONLY]

# ============================== External nodes ==============================

@export_group("External nodes")
@export var _fighting_area: FightingArea

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary]
var _last_log_index_sent: int = 0
var _start_time: float
var _normal_fight_duration: float
var _accelerated_fight_start_time: float
var _is_accelerated_fight: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if not multiplayer.is_server(): queue_free() # Only the server writes battle logs
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	_fighting_area.projectile_spawned.connect(_on_fighting_area_projectile_spawned)
	_fighting_area.spell_casted.connect(_on_fighting_area_spell_casted)
	_fighting_area.action_done.connect(_on_fighting_area_action_done)
	_fighting_area.interaction_received.connect(_on_fighting_area_interaction_received)

# ============================== Public functions ==============================

# Should return the new logs (current logs - last logs (how to do so ?))
func get_current_logs() -> Array[Dictionary]:
	var new_logs: Array[Dictionary] = _battle_logs.slice(_last_log_index_sent)
	_last_log_index_sent = _battle_logs.size()
	return new_logs

# ============================== Private functions ==============================

#region logs
#{"time":0.1, "type":"auto_attack", "source":1, "target":2, "modifier":{"critical":true, "poison":false, "ignite":false, "instability":true}}
func _log_attack(source: Entity, target: Entity,
				critical: bool = false, poison: bool = false, ignite: bool = false, instability: bool = false) -> void:
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.AUTO_ATTACK,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.TARGET: target.id,
		BattleLog.Main.MODIFIER: {
			BattleLog.Modifier.CRITICAL: critical,
			BattleLog.Modifier.POISON: poison,
			BattleLog.Modifier.IGNITE: ignite,
			BattleLog.Modifier.INSTABILITY: instability
		}
	}
	_battle_logs.append(data)


func _log_spell_casted(source: Entity, target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary) -> void:
	if source == null or target == null: return
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.SPELL_CASTED,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.TARGET: target.id,
		BattleLog.Main.SPELL_TYPE: spell_type,
		BattleLog.Main.SPELL_MODIFIER: spell_modifier
	}
	_battle_logs.append(data)


func _log_action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	if not is_instance_valid(source):
		Verbose.warn("_log_action_done() -> source invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	if not is_instance_valid(target):
		Verbose.warn("_log_action_done() -> target invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.ACTION_DONE,
		BattleLog.Main.ACTION_TYPE: action_type,
		BattleLog.Main.ACTION_ID: action_id,
		BattleLog.Main.VALUE: value,
		BattleLog.Main.CRITICAL: is_critical,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.TARGET: target.id
	}
	
	_battle_logs.append(data)


func _log_interaction_received(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	Verbose.trace("_log_interaction_received() | " + str(receiver) + " | " + str(source), Verbose.Category.BATTLE_WRITER)
	
	if not is_instance_valid(receiver):
		Verbose.warn("_log_action_done() -> receiver invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.INTERACTION_RECEIVED,
		BattleLog.Main.ACTION_TYPE: action_type,
		BattleLog.Main.ACTION_ID: action_id,
		BattleLog.Main.VALUE: value,
		BattleLog.Main.CRITICAL: is_critical,
		BattleLog.Main.RECEIVER: receiver.id,
		BattleLog.Main.SOURCE: source.id if source != null else -1,
	}
	
	_battle_logs.append(data)
#endregion

func _get_time() -> float:
	if _is_accelerated_fight:
		return _normal_fight_duration + ((Time.get_ticks_msec() as float) / 1000.0 - _accelerated_fight_start_time)# / GlobalFightingManager.ACCELERATED_FIGHT_TIME_SCALE
	else:
		return ((Time.get_ticks_msec() as float) / 1000.0 - _start_time)

# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(state: Game.GameState) -> void:
	match state:
		Game.GameState.FIGHTING_POSITIONING:
			_battle_logs.clear()
		Game.GameState.FIGHTING_NORMAL:
			_start_time = (Time.get_ticks_msec() as float) / 1000.0
			_is_accelerated_fight = false
		Game.GameState.FIGHTING_ACCELERATED:
			_normal_fight_duration = _get_time()
			_accelerated_fight_start_time = (Time.get_ticks_msec() as float) / 1000.0
			_is_accelerated_fight = true


func _on_fighting_area_projectile_spawned(source: Entity, target: Entity, projectile_type: Projectile.ProjectileType, projectile_modifiers: Array[Projectile.ProjectileEffect]) -> void:
	if projectile_type == Projectile.ProjectileType.AUTO_ATTACK:
		_log_attack(source, target,
					projectile_modifiers.has(Projectile.ProjectileEffect.CRITIC),
					projectile_modifiers.has(Projectile.ProjectileEffect.POISON),
					projectile_modifiers.has(Projectile.ProjectileEffect.IGNITE),
					projectile_modifiers.has(Projectile.ProjectileEffect.INSTABILITY))


func _on_fighting_area_spell_casted(source: Entity, target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary) -> void:
	_log_spell_casted(source, target, spell_type, spell_modifier)


func _on_fighting_area_interaction_received(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	_log_interaction_received(receiver, source, action_type, action_id, value, is_critical)


func _on_fighting_area_action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	_log_action_done(source, target, action_type, action_id, value, is_critical)
