class_name PeriodicTimerRegistry
extends Node

# Structure interne pour stocker l'état de chaque effet
class TickEffect:
	var id: StringName
	var period_ticks: int
	var ticks_left: int
	var callback: Callable
	var is_running: bool = false

class OneShotEffect:
	var ticks_left: int
	var callback: Callable

const TICKS_PER_SECOND: int = 60

# Liste des effets (on préfère une Array pour un tri stable)
var _effects: Array[TickEffect] = []
# Oneshots : déclenchés une fois après un délai, puis auto-retirés
var _oneshots: Array[OneShotEffect] = []

# Conversion des secondes en ticks (basé sur 60 FPS physiques)
func _to_ticks(seconds: float) -> int:
	return int(round(seconds * TICKS_PER_SECOND))

func register(id: StringName, period: float, callback: Callable, autostart: bool = false) -> void:
	unregister(id) # Évite les doublons

	var new_effect = TickEffect.new()
	new_effect.id = id
	new_effect.period_ticks = _to_ticks(period)
	new_effect.ticks_left = new_effect.period_ticks
	new_effect.callback = callback
	new_effect.is_running = autostart

	_effects.append(new_effect)
	# On trie par ID pour garantir que l'ordre d'exécution est identique partout
	_effects.sort_custom(func(a, b): return a.id < b.id)

func unregister(id: StringName) -> void:
	for i in range(_effects.size() - 1, -1, -1):
		if _effects[i].id == id:
			_effects.remove_at(i)
			break


func register_oneshot(delay: float, callback: Callable) -> void:
	var effect := OneShotEffect.new()
	effect.ticks_left = _to_ticks(delay)
	effect.callback = callback
	_oneshots.append(effect)


func process_tick() -> void:
	for effect in _effects:
		if not effect.is_running:
			continue

		effect.ticks_left -= 1

		if effect.ticks_left <= 0:
			# L'effet se déclenche
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

# --- Méthodes de compatibilité avec ton ancien code ---

func start_all() -> void:
	for e in _effects: e.is_running = true

func stop_all() -> void:
	for e in _effects: e.is_running = false

func pause_all() -> void:
	stop_all() # Plus besoin de stocker time_left, ticks_left est déjà là

func resume_all() -> void:
	start_all()

func clear_all() -> void:
	_effects.clear()
	_oneshots.clear()
