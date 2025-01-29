class_name Family
extends Resource

enum FamilyType {
	Attack,
	Rock,
	Fire,
	Storm,
	Serinity,
	Life,
	Poison,
	Shadow
}

@export var cards: Array[Card] # ALL cards in this game of this family type
@export var icon: Texture2D
@export var family_name: String
@export var family_type: FamilyType

var lvl: int # Current level of the family (number of cards in the player deck affiliated with this family)

func get_description() -> String: # Virtual
	return "Virtual family shouldn't be instanciated"
