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

# Hero-specific runtime context — consommé par HeroSpec.spawn_into.
# display_mode : BUYING_PHASE en tavern, FIGHTING_PHASE en combat.
# runtime_owner_player : Player runtime qui contrôle ce héros (UI "c'est mon hero").
var display_mode: Hero.DisplayMode = Hero.DisplayMode.FIGHTING_PHASE
var runtime_owner_player: Player = null
