class_name PlayerState
extends Resource

# Pure data slice of a Player: everything that must persist across a run
# save/load. Lives in RunContext.party.players. Behaviour, signals and clamps
# stay on Player (which proxies its public API to this state).

@export var gold: int = 0
@export var xp: int = 0
@export var lvl: int = 1
@export var health: int = 0
@export var max_health: int = 0
@export var damage: int = 0

@export var win_streak: int = 0
@export var total_win_number: int = 0
@export var total_lose_number: int = 0
@export var current_damage_win_lose_diff: int = 0

@export var round_of_death: int = -1
@export var is_dead: bool = false

@export var hero_desc_id: int = 0
@export var deck: PlayerDeck
@export var data_memory: NestedRegistry


func _init() -> void:
	if data_memory == null:
		data_memory = NestedRegistry.new()
