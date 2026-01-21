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

const RARITY_MAX_LEVEL: Dictionary[Rarity, int] = {
	Rarity.COMMON: 5,
	Rarity.RARE: 3,
	Rarity.EPIC: 2,
	Rarity.LEGENDARY: 1,
}

const RARITY_CARD_VALUE: Dictionary[Rarity, int] = {
	Rarity.COMMON: 1,
	Rarity.RARE: 2,
	Rarity.EPIC: 3,
	Rarity.LEGENDARY: 5,
}

@export var name : String
@export var picture : Texture2D
@export var families: Array[Family.FamilyType]
@export var rarity : Rarity
@export var player_upgrade: HeroUpgrade
@export var lvl : int = 1

func is_max_level() -> bool:
	return lvl == RARITY_MAX_LEVEL[rarity]

var uid: int
