class_name BattleWriter
extends Node

var _battle_logs: Array[Dictionary]

var _entities: Array[Entity]

func _ready() -> void:
	var data = {"time":0.1, "type":"auto_attack", "source":1, "target":2, "modifier":{"critical":true, "poison":false, "ignite":false, "instability":true}}
	print(data)


 #{"time":0.1, "type":"auto_attack", "source":1, "target":2, "modifier":{"critical":true, "poison":false, "ignite":false, "instability":true}}
func log_attack(time: float, source: Entity, target: Entity,
				critical: bool = false, poison: bool = false, ignite: bool = false, instability: bool = false) -> void:
	var data: Dictionary = {
		BattleLog.TIME: time,
		BattleLog.TYPE: BattleLog.Type.AUTO_ATTACK,
		BattleLog.SOURCE: source.id,
		BattleLog.TARGET: target.id,
		BattleLog.MODIFIER: {
			BattleLog.Modifier.CRITICAL: critical,
			BattleLog.Modifier.POISON: poison,
			BattleLog.Modifier.IGNITE: ignite,
			BattleLog.Modifier.INSTABILITY: instability
		}
	}
	_battle_logs.append(data)
