class_name Card
extends Resource

enum Rarity {
	COMMON,
	RARE,
	EPIC
}

@export var name : String
@export var picture : Texture2D
@export var families: Array[Family.FamilyType]
@export var rarity : Rarity
@export var player_upgrade: PlayerUpgrade

var lvl : int
