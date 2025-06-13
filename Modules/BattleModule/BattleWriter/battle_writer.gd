class_name BattleWriter
extends Node

# ============================== External nodes ==============================

@export var _fighting_area: FightingArea

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary]
var _entities: Array[Entity]
var _start_time: float

# ============================== Node base functions ==============================

func _ready() -> void:
	if not multiplayer.is_server(): queue_free() # Only the server writes a BattleLog
	_fighting_area.projectile_spawned.connect(_on_events_projectile_spawned)
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)

# ============================== Public functions ==============================



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


func _get_time() -> float:
	return ((Time.get_ticks_msec() as float) / 1000.0 - _start_time) * GlobalFightingManager.SERVER_TIME_SCALE

# ============================== Callbacks ==============================

func _on_global_fighting_manager_state_changed(state: GlobalFightingManager.FightingState) -> void:
	match state:
		GlobalFightingManager.FightingState.POSITIONING:
			_battle_logs.clear()
		GlobalFightingManager.FightingState.FIGHT:
			_start_time = (Time.get_ticks_msec() as float) / 1000.0
		GlobalFightingManager.FightingState.FINISHED:
			print("BattleLog size = ", _battle_logs.size())


func _on_events_projectile_spawned(source: Entity, target: Entity, projectile_type: Projectile.ProjectileType, projectile_modifiers: Array[Projectile.ProjectileEffect]) -> void:
	if projectile_type == Projectile.ProjectileType.AUTO_ATTACK:
		_log_attack(source, target,
					projectile_modifiers.has(Projectile.ProjectileEffect.CRITIC),
					projectile_modifiers.has(Projectile.ProjectileEffect.POISON),
					projectile_modifiers.has(Projectile.ProjectileEffect.IGNITE),
					projectile_modifiers.has(Projectile.ProjectileEffect.INSTABILITY))
