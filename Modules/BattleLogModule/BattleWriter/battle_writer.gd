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
	_fighting_area.damage_taken.connect(_on_fighting_area_damage_taken)
	_fighting_area.spell_casted.connect(_on_fighting_area_spell_casted)
	_fighting_area.stack_taken.connect(_on_fighting_area_stack_taken)

# ============================== Public functions ==============================

# Should return the new logs (current logs - last logs (how to do so ?))
func get_current_logs() -> Array[Dictionary]:
	var new_logs: Array[Dictionary] = _battle_logs.slice(_last_log_index_sent)
	_last_log_index_sent = _battle_logs.size()
	return new_logs

# ============================== Private functions ==============================

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


func _log_damage_taken(source: Entity, damage: float, damage_type: Utils.DamageType, critical: bool) -> void:
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.DAMAGE_TAKEN,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.DAMAGE: damage,
		BattleLog.Main.DAMAGE_TYPE: damage_type,
		BattleLog.Main.MODIFIER: {
			BattleLog.Modifier.CRITICAL: critical,
		}
	}
	_battle_logs.append(data)


func _log_spell_casted(source: Entity, target: Entity, spell_type: Spell.Type) -> void:
	if source == null or target == null: return
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.SPELL_CASTED,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.TARGET: target.id,
		BattleLog.Main.SPELL_TYPE: spell_type,
	}
	_battle_logs.append(data)


func _log_stack_taken(source: Entity, stack_type: Utils.StackType, stack_number: float, is_critical: bool) -> void:
	var data: Dictionary = {
		BattleLog.Main.TIME: _get_time(),
		BattleLog.Main.TYPE: BattleLog.Type.STACK_TAKEN,
		BattleLog.Main.STACK_TYPE: stack_type,
		BattleLog.Main.STACK_NUMBER: stack_number,
		BattleLog.Main.SOURCE: source.id,
		BattleLog.Main.MODIFIER: {
			BattleLog.Modifier.CRITICAL: is_critical
		}
	}
	_battle_logs.append(data)


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


func _on_fighting_area_damage_taken(source: Entity, damage: float, damage_type: Utils.DamageType, is_critical: bool, _blocked_by_armor: bool) -> void:
	_log_damage_taken(source, damage, damage_type, is_critical)


func _on_fighting_area_spell_casted(source: Entity, target: Entity, spell_type: Spell.Type) -> void:
	_log_spell_casted(source, target, spell_type)


func _on_fighting_area_stack_taken(source: Entity, stack_type: Utils.StackType, stack_number: float, is_critical: bool) -> void:
	_log_stack_taken(source, stack_type, stack_number, is_critical)
