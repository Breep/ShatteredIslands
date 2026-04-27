class_name EntityContext
extends RefCounted
## Pure data structure (DTO) for transferring context between entities.
## This is a "messenger" structure with all public variables.
## Entity is responsible for constructing its own EntityContext via get_context().

# Public context data
var team: int = -1
var battle_id: int = -1
var spawn_manager: SpawnManager
var arena_zone_manager: ArenaZoneManager
var life_state: Entity.LifeState = Entity.LifeState.ALIVE  # Summons inherit ALIVE by default
var fighting_state: Entity.FightingState = Entity.FightingState.UNDEF
var entity_owner: Entity
