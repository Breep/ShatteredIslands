class_name Card
extends Resource

enum Rarity {
	COMMON,
	RARE,
	EPIC
}

@export var name : String
@export var picture : Texture2D
@export var family: Family.FamilyType
@export var rarity : Rarity
@export var player_upgrade: CharacterUpgrade
@export var lvl : int = 1
