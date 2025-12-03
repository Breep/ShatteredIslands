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
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)


func _process(_delta: float) -> void:
	if not _is_playing or _current_index >= _battle_logs.size(): return
	var elapsed_time: float = (Time.get_ticks_msec() as float) / 1000.0 - _start_time
	while _current_index < _battle_logs.size() and _battle_logs[_current_index][BattleLog.Main.TIME] <= elapsed_time:
		_apply_log(_battle_logs[_current_index])
		_current_index += 1

# ============================== Public function ==============================

func add_log(logs: Array[Dictionary]) -> void:
	_battle_logs += logs


func _on_game_manager_game_state_changed(state: Game.GameState) -> void:
	match state:
		Game.GameState.FIGHTING_POSITIONING:
			_battle_logs.clear()
		Game.GameState.FIGHTING_NORMAL:
			_start_playback()

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
		BattleLog.Type.AUTO_ATTACK:
			_apply_auto_attack(battle_log)
		BattleLog.Type.DAMAGE_TAKEN:
			_apply_damage_taken(battle_log)
		BattleLog.Type.SPELL_CASTED:
			_apply_spell_casted(battle_log)
		BattleLog.Type.STACK_TAKEN:
			_apply_stack_taken(battle_log)
		BattleLog.Type.ACTION_DONE:
			_apply_action_done(battle_log)
		_:
			Verbose.warn("Unknown battle_log type received | " + str(type), Verbose.Category.BATTLE_READER)

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
	source.projectile_attack(target, Projectile.ProjectileType.AUTO_ATTACK, projectile_spawn, ProjectileStats.new())


#{"time":0.1, "type":"damage_taken", "source":1, "modifier":{"critical":true}}
func _apply_damage_taken(battle_log: Dictionary) -> void:
	var source_id: int = battle_log.get(BattleLog.Main.SOURCE, -1)
	var damage: int = battle_log.get(BattleLog.Main.DAMAGE, -1)
	var damage_type: Utils.DamageType = battle_log.get(BattleLog.Main.DAMAGE_TYPE, Utils.DamageType.PHYSICAL)
	var modifier: Dictionary = battle_log.get(BattleLog.Main.MODIFIER, {})
	Verbose.trace("Damage taken: "  + str(source_id) + ":" + str(damage), Verbose.Category.BATTLE_READER)
	var source: Entity = _entity_manager.get_entity(source_id)
	if source == null: return
	source.take_damage(damage, damage_type, modifier.get(BattleLog.Modifier.CRITICAL, false), "TODO")


#{"time":0.1, "type":"spell_casted", "source":1, "target":2, "spell_type":<spell_type>}
func _apply_spell_casted(battle_log: Dictionary) -> void:
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var target_id: int = battle_log[BattleLog.Main.TARGET]
	var spell_type: Spell.Type = battle_log[BattleLog.Main.SPELL_TYPE]
	if not _entity_manager.entities.has(source_id):
		Verbose.error("BattleReader: Spell casted: Unknown source !", Verbose.Category.BATTLE_SYNC)
		return
	if not _entity_manager.entities.has(target_id):
		Verbose.error("BattleReader: Spell casted: Unknown target !", Verbose.Category.BATTLE_SYNC)
		return
	var source: Entity = _entity_manager.entities[source_id]
	var target: Entity = _entity_manager.entities[target_id]
	source.cast_spell(target, spell_type, {})


#{"time":0.1, "source":1, "stack_type":<stack_type>, "stack_number":42}
func _apply_stack_taken(battle_log: Dictionary) -> void:
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var stack_type: Utils.StackType = battle_log[BattleLog.Main.STACK_TYPE]
	var stack_number: int = battle_log[BattleLog.Main.STACK_NUMBER]
	if not _entity_manager.entities.has(source_id):
		Verbose.error("BattleReader: Stack taken: Unknown source !", Verbose.Category.BATTLE_SYNC)
		return
	var source: Entity = _entity_manager.entities[source_id]
	source.take_condition_stacks(stack_number, stack_type, false, "TODO")


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















 
