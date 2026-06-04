class_name Family
extends Resource

# ============================== Enum ==============================

enum Type {
	UNDEF = 0,
	WARRIOR = 1,
	ENGINEER = 2,
	ARDENT_CELESTIAL = 3,
	STORM_CALLER = 4,
	LIGHT = 5,
	COLOSSUS = 6,
	POISON = 7,
	CHICKEN_LORD = 8,
	NECROSIS = 9,
}

# ============================== Constant ==============================

const COLORS = {
	Type.WARRIOR: Color(0.473, 0.482, 0.464, 1.0),  # Gray
	Type.STORM_CALLER: Color(0, 0, 1),   # Blue
	Type.ENGINEER: Color(0.4, 0.26, 0.13),  # Brown
	Type.ARDENT_CELESTIAL: Color(1, 0, 0),     # Red
	Type.POISON: Color(0.069, 0.332, 0.106), # Green
	Type.LIGHT: Color(1, 1, 1), # White
	Type.COLOSSUS: Color(0.737, 0.379, 0.087), # Orange
	Type.CHICKEN_LORD: Color(0.673, 0.504, 0.032, 1.0), # Yellow
	Type.NECROSIS: Color(0.518, 0.148, 0.681, 1.0), # Purple
}

# ============================== Exports ==============================

@export var cards: Array[Card] # ALL cards in this game of this family type
@export var icon: Texture2D
@export var family_name: String
@export var family_type: Type
@export var color: Color
@export_multiline() var description: String = "<Family Description>"

# ============================== Public variables ==============================

var lvl: int # Current level of the family (number of cards in the player hand affiliated with this family)

# ============================== Public functions ==============================

func get_description() -> String: # Virtual
	return "Virtual family shouldn't be instanciated"
