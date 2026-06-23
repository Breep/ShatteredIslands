class_name FightingEventRegistry
extends Node

# ============================== Export ==============================
@export var _fighting_area: FightingArea

# ============================== Private variables ==============================
var _fighting_events: Dictionary[StringName, FightingEvent] = {}

# ============================== Node base functions ==============================
func _ready() -> void:
	if _fighting_area == null:
		printerr("FightingEventRegistry: Missing reference to FightingArea [", get_path(), "]")
		return
	
	# Connect to area events once
	_fighting_area.entity_died.connect(_on_entity_died)

# ============================== Public functions ==============================
func register_event(fe: FightingEvent) -> void:
	if fe == null: return
	if _fighting_events.has(fe.id):
		printerr("FightingEventRegistry: register_handler() - already known fighting event \"", fe.id, "\" [", get_path(), "]")
		return
	_fighting_events[fe.id] = fe


func update_event(fe: FightingEvent) -> void:
	if fe == null: return
	if !_fighting_events.has(fe.id):
		printerr("FightingEventRegistry: update_handler() - fighting event not found \"", fe.id, "\" [", get_path(), "]")
		return
	_fighting_events[fe.id] = fe


func unregister_event(fe_id: StringName) -> void:
	_fighting_events.erase(fe_id)


func clear() -> void:
	_fighting_events.clear()

# ============================== Private callbacks ==============================
func _on_entity_died(victim: Entity) -> void:
	for fighting_event in _fighting_events.values():
		if !fighting_event.enabled:
			continue
		if fighting_event.on_entity_died_callback.is_valid():
			var cb_vars := {
				FightingEvent.VarType.FIGHTING_AREA: _fighting_area,
				FightingEvent.VarType.ENTITIES: _fighting_area.entity_signal_relay.entities.values(),
				FightingEvent.VarType.VICTIM: victim,
				FightingEvent.VarType.EVENT_OWNER: fighting_event.owner
			}
			fighting_event.on_entity_died_callback.call(cb_vars)
		if fighting_event.is_one_time_effect:
			unregister_event(fighting_event.id)
