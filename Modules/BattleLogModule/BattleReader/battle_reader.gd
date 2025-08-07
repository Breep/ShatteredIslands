class_name BattleReader
extends Node

# [CLIENT ONLY]

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _entity_manager: EntityManager
@export var _spawn_manager: SpawnManager

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary] = []

var _start_time: float
var _current_index: int = 0
var _is_playing: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server(): queue_free() # Only clients read battle logs
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)


func _process(_delta: float) -> void:
	if not _is_playing or _current_index >= _battle_logs.size(): return
	var elapsed_time: float = (Time.get_ticks_msec() as float) / 1000.0 - _start_time
	while _current_index < _battle_logs.size() and _battle_logs[_current_index][BattleLog.Main.TIME] <= elapsed_time:
		_apply_log(_battle_logs[_current_index])
		_current_index += 1

# ============================== Public function ==============================

func add_log(logs: Array[Dictionary]) -> void:
	_battle_logs += logs


func _on_global_fighting_manager_state_changed(state: GlobalFightingManager.FightingState) -> void:
	match state:
		GlobalFightingManager.FightingState.POSITIONING:
			_battle_logs.clear()
		GlobalFightingManager.FightingState.FIGHTING:
			_start_playback()
		GlobalFightingManager.FightingState.FINISHED:
			return

# ============================== Private function ==============================

func _start_playback() -> void:
	_start_time = (Time.get_ticks_msec() as float) / 1000.0
	_current_index = 0
	_is_playing = true


func _stop_playback() -> void:
	_is_playing = false


func _apply_log(battle_log: Dictionary) -> void:
	var type: BattleLog.Type = battle_log[BattleLog.Main.TYPE]
	match type:
		BattleLog.Type.AUTO_ATTACK:
			_apply_auto_attack(battle_log)
		BattleLog.Type.DAMAGE_TAKEN:
			_apply_damage_taken(battle_log)
		BattleLog.Type.SPELL_CASTED:
			_apply_spell_casted(battle_log)
		BattleLog.Type.STACK_TAKEN:
			_apply_stack_taken(battle_log)

# ============================== Logs applied ==============================

 #{"time":0.1, "type":"auto_attack", "source":1, "target":2, "modifier":{"critical":true, "poison":false, "ignite":false, "instability":true}}
func _apply_auto_attack(battle_log: Dictionary) -> void:
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var target_id: int = battle_log[BattleLog.Main.TARGET]
	#var modifier: Dictionary = battle_log[BattleLog.Main.MODIFIER]
	#print("[", multiplayer.get_unique_id(), "] BattleReader: Auto-attack: ", source_id, "->", target_id)
	if not _entity_manager.entities.has(source_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Auto-attack: Unknown source !")
		return
	if not _entity_manager.entities.has(target_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Auto-attack: Unknown target !")
		return
	var source: Entity = _entity_manager.entities[source_id]
	var target: Entity = _entity_manager.entities[target_id]
	var projectile_spawn: Node3D = source.get_auto_attack_spawn()
	_spawn_manager.spawn_projectile(source, target, Projectile.ProjectileType.AUTO_ATTACK, projectile_spawn, ProjectileStats.new())


#{"time":0.1, "type":"damage_taken", "source":1, "modifier":{"critical":true}}
func _apply_damage_taken(battle_log: Dictionary) -> void:
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var damage: int = battle_log [BattleLog.Main.DAMAGE]
	var damage_type: Utils.DamageType = battle_log[BattleLog.Main.DAMAGE_TYPE]
	var modifier: Dictionary = battle_log[BattleLog.Main.MODIFIER]
	#print("[", multiplayer.get_unique_id(), "] BattleReader: Damage taken: ", source_id, ":", damage)
	if not _entity_manager.entities.has(source_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Damage taken: Unknown source !")
		return
	var source: Entity = _entity_manager.entities[source_id]
	source.take_damage(damage, damage_type, modifier[BattleLog.Modifier.CRITICAL])


#{"time":0.1, "type":"spell_casted", "source":1, "target":2, "spell_type":<spell_type>}
func _apply_spell_casted(battle_log: Dictionary) -> void:
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var target_id: int = battle_log[BattleLog.Main.TARGET]
	var spell_type: Spell.Type = battle_log[BattleLog.Main.SPELL_TYPE]
	if not _entity_manager.entities.has(source_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Spell casted: Unknown source !")
		return
	if not _entity_manager.entities.has(target_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Spell casted: Unknown target !")
		return
	var source: Entity = _entity_manager.entities[source_id]
	var target: Entity = _entity_manager.entities[target_id]
	source.cast_spell(target, spell_type, {})


#{"time":0.1, "source":1, "stack_type":<stack_type>, "stack_number":42}
func _apply_stack_taken(battle_log: Dictionary) -> void:
	print("DEBUG - STACK TAKEN")
	var source_id: int = battle_log[BattleLog.Main.SOURCE]
	var stack_type: Utils.StackType = battle_log[BattleLog.Main.STACK_TYPE]
	var stack_number: int = battle_log[BattleLog.Main.STACK_NUMBER]
	if not _entity_manager.entities.has(source_id):
		printerr("[", multiplayer.get_unique_id(), "] BattleReader: Stack taken: Unknown source !")
		return
	var source: Entity = _entity_manager.entities[source_id]
	source.take_condition_stacks(stack_number, stack_type)
