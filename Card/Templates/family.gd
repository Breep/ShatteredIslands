class_name Family
extends Resource

# ============================== Enum ==============================

enum FamilyType {
	UNDEF,
	ATTACK,
	DEFENSE,
	FIRE,
	STORM,
	SERENITY,
	LIFE,
	POISON,
	MANA,
	CHICKEN,
	LIGHTNING,
	NECROSIS,
	SHADOW
}

# ============================== Constant ==============================

const COLORS = {
	FamilyType.ATTACK: Color(0.774, 0.644, 0.085),  # Yellow
	FamilyType.STORM: Color(0, 0, 1),   # Blue
	FamilyType.DEFENSE: Color(0.4, 0.26, 0.13),  # Brown
	FamilyType.FIRE: Color(1, 0, 0),     # Red
	FamilyType.POISON: Color(0.069, 0.332, 0.106), # Green
	FamilyType.SERENITY: Color(1, 1, 1), # White
	FamilyType.LIFE: Color(0.737, 0.379, 0.087), # Orange
}

# ============================== Exports ==============================

@export var cards: Array[Card] # ALL cards in this game of this family type
@export var icon: Texture2D
@export var family_name: String
@export var family_type: FamilyType
@export var color: Color
@export var description: String = "<Family Description>"

# ============================== Public variables ==============================

var lvl: int # Current level of the family (number of cards in the player deck affiliated with this family)

# ============================== Public functions ==============================

func get_description() -> String: # Virtual
	return "Virtual family shouldn't be instanciated"
