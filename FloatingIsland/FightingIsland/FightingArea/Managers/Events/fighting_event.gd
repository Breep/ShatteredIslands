class_name FightingEvent
extends Resource

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

var id: StringName
var owner: Entity
var tags: Array[TagType] = []
var enabled: bool = true
var is_one_time_effect: bool = false

enum VarType { # Variable types of the callbacks dictionary
	FIGHTING_AREA,
	ENTITIES,
	VICTIM,
	EVENT_OWNER
}

var on_entity_died_callback := Callable() # var: Dictionary

# Optional: return a uniqueness key to avoid duplicates (e.g., “card:poison_aura:team=2”)
func unique_key() -> StringName:
	return id
