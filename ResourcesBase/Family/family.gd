class_name Family
extends Resource

enum FamilyType {
	Attack,
	Defense,
	Fire,
	Storm,
	Serenity,
	Life,
	Poison,
	Shadow
}

const COLORS = {
	FamilyType.Attack: Color(0.774, 0.644, 0.085),  # Yellow
	FamilyType.Storm: Color(0, 0, 1),   # Blue
	FamilyType.Defense: Color(0.4, 0.26, 0.13),  # Brown
	FamilyType.Fire: Color(1, 0, 0),     # Red
	FamilyType.Shadow: Color(0, 0, 0),   # Black
	FamilyType.Poison: Color(0.069, 0.332, 0.106), # Green
	FamilyType.Serenity: Color(1, 1, 1), # White
	FamilyType.Life: Color(0.737, 0.379, 0.087), # Orange
}

@export var cards: Array[Card] # ALL cards in this game of this family type
@export var icon: Texture2D
@export var family_name: String
@export var family_type: FamilyType

var lvl: int # Current level of the family (number of cards in the player deck affiliated with this family)

func get_description() -> String: # Virtual
	return "Virtual family shouldn't be instanciated"
