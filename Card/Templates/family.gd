class_name Family
extends Resource

# ============================== Enum ==============================

enum FamilyType {
	UNDEF,
	WARRIOR,
	ENGINEER,
	ARDENT_CELESTIAL,
	STORM_CALLER,
	LIGHT,
	COLOSSUS,
	POISON,
	CHICKEN_LORD,
	NECROSIS,
}

# ============================== Constant ==============================

const COLORS = {
	FamilyType.WARRIOR: Color(0.473, 0.482, 0.464, 1.0),  # Gray
	FamilyType.STORM_CALLER: Color(0, 0, 1),   # Blue
	FamilyType.ENGINEER: Color(0.4, 0.26, 0.13),  # Brown
	FamilyType.ARDENT_CELESTIAL: Color(1, 0, 0),     # Red
	FamilyType.POISON: Color(0.069, 0.332, 0.106), # Green
	FamilyType.LIGHT: Color(1, 1, 1), # White
	FamilyType.COLOSSUS: Color(0.737, 0.379, 0.087), # Orange
	FamilyType.CHICKEN_LORD: Color(0.673, 0.504, 0.032, 1.0), # Yellow
	FamilyType.NECROSIS: Color(0.518, 0.148, 0.681, 1.0), # Orange
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
