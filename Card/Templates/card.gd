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
@export var families: Array[Family.Type]
@export var rarity : Rarity
@export var player_upgrade: HeroUpgrade
@export var points: Dictionary[Family.Type, int]

var _lvl: int = 1 # Current lvl
@export_range(1, 5) var lvl: int:
	get: return _lvl
	set(value):
		value = clampi(value, 1, RARITY_MAX_LEVEL[rarity])
		if value == _lvl: return
		_lvl = value


func is_max_level() -> bool:
	return _lvl == RARITY_MAX_LEVEL[rarity]

var uid: int
