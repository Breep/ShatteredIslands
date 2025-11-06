class_name Card
extends Resource

enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

const RARITY_COLORS: Dictionary[Rarity, Color] = {
	Rarity.COMMON: Color.WEB_GRAY,
	Rarity.RARE: Color.DARK_BLUE,
	Rarity.EPIC: Color.REBECCA_PURPLE,
	Rarity.LEGENDARY: Color.DARK_ORANGE,
}

@export var name : String
@export var picture : Texture2D
@export var family: Family.FamilyType
@export var rarity : Rarity
@export var player_upgrade: CharacterUpgrade
@export var lvl : int = 1

var uid: int
