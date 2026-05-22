class_name BattleCallbackRegistry
extends RefCounted

## Registry for everything an entity hooks into a battle: lifecycle events
## (start / end) and time-based effects (periodic / one-shot). Cards, families
## and mobs register lambdas here; the owning entity drives them via
## execute_battle_start/end and process_tick.

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
#endregion

#region ============================== Inner classes ==============================
class TickEffect:
	var id: StringName
	var period_ticks: int
	var ticks_left: int
	var callback: Callable
	var is_running: bool = false

class OneShotEffect:
	var ticks_left: int
	var callback: Callable
#endregion

#region ============================== Private variables ==============================
var _battle_start_callbacks: Array[Dictionary] = [] # [{id: StringName, callback: Callable}]
var _battle_end_callbacks: Array[Dictionary] = [] # [{id: StringName, callback: Callable}]
# On préfère une Array pour les effets périodiques afin de garantir un tri stable
var _periodic_effects: Array[TickEffect] = []
# Oneshots : déclenchés une fois après un délai, puis auto-retirés
var _oneshots: Array[OneShotEffect] = []
#endregion


# ============================== Public functions ==============================
#region ============================== Battle lifecycle ==============================
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
#endregion


#region ============================== Periodic timers ==============================
func register_periodic(id: StringName, period: float, callback: Callable, autostart: bool = false) -> void:
	unregister(id) # Évite les doublons

	var new_effect := TickEffect.new()
	new_effect.id = id
	new_effect.period_ticks = _to_ticks(period)
	new_effect.ticks_left = new_effect.period_ticks
	new_effect.callback = callback
	new_effect.is_running = autostart

	_periodic_effects.append(new_effect)
	# On trie par ID pour garantir que l'ordre d'exécution est identique partout
	_periodic_effects.sort_custom(func(a, b): return a.id < b.id)


func unregister(id: StringName) -> void:
	for i in range(_periodic_effects.size() - 1, -1, -1):
		if _periodic_effects[i].id == id:
			_periodic_effects.remove_at(i)
			break


func register_oneshot(delay: float, callback: Callable) -> void:
	var effect := OneShotEffect.new()
	effect.ticks_left = _to_ticks(delay)
	effect.callback = callback
	_oneshots.append(effect)


func process_tick() -> void:
	for effect in _periodic_effects:
		if not effect.is_running:
			continue

		effect.ticks_left -= 1

		if effect.ticks_left <= 0:
			effect.callback.call()
			# On réinitialise avec la période exacte (déterminisme parfait)
			effect.ticks_left = effect.period_ticks

	var fired: Array[OneShotEffect] = []
	for effect in _oneshots:
		effect.ticks_left -= 1
		if effect.ticks_left <= 0:
			fired.append(effect)
	for effect in fired:
		effect.callback.call()
		_oneshots.erase(effect)


func start_timers() -> void:
	for e in _periodic_effects: e.is_running = true


func stop_timers() -> void:
	for e in _periodic_effects: e.is_running = false


func pause_timers() -> void:
	stop_timers() # ticks_left est déjà conservé, rien à stocker en plus


func resume_timers() -> void:
	start_timers()
#endregion


#region ============================== Misc ==============================
func clear_all() -> void:
	_battle_start_callbacks.clear()
	_battle_end_callbacks.clear()
	_periodic_effects.clear()
	_oneshots.clear()
#endregion


# ============================== Private functions ==============================
#region ============================== Utils ==============================
# Conversion des secondes en ticks (basé sur 60 FPS physiques)
func _to_ticks(seconds: float) -> int:
	return int(round(seconds * TICKS_PER_SECOND))
#endregion
