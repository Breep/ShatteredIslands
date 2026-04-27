class_name BattleCallbackRegistry
extends RefCounted

## Registry for battle lifecycle callbacks (start/end).
## Cards register lambdas that get called when combat begins or ends.

var _battle_start_callbacks: Array[Dictionary] = [] # [{id: StringName, callback: Callable}]
var _battle_end_callbacks: Array[Dictionary] = [] # [{id: StringName, callback: Callable}]


func register_battle_start(id: StringName, callback: Callable) -> void:
	_battle_start_callbacks.append({&"id": id, &"callback": callback})


func register_battle_end(id: StringName, callback: Callable) -> void:
	_battle_end_callbacks.append({&"id": id, &"callback": callback})


func execute_battle_start() -> void:
	for entry: Dictionary in _battle_start_callbacks:
		var callback: Callable = entry[&"callback"]
		if callback.is_valid():
			callback.call()


func execute_battle_end() -> void:
	for entry: Dictionary in _battle_end_callbacks:
		var callback: Callable = entry[&"callback"]
		if callback.is_valid():
			callback.call()


func clear_all() -> void:
	_battle_start_callbacks.clear()
	_battle_end_callbacks.clear()
