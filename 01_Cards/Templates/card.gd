# Donnée d'une carte : identité (id de design + uid d'instance), rareté, niveau
# et l'effet appliqué au héros (player_upgrade). Resource sérialisable, dupliquée
# par instance dans le pool du marchand.
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
	Rarity.RARE: 5,
	Rarity.EPIC: 3,
	Rarity.LEGENDARY: 3,
}

const RARITY_CARD_VALUE: Dictionary[Rarity, int] = {
	Rarity.COMMON: 1,
	Rarity.RARE: 2,
	Rarity.EPIC: 3,
	Rarity.LEGENDARY: 5,
}

## Identité de design stable (réseau, dédoublonnage main/coffre, leveling).
@export var id : StringName
@export var name : String
@export var picture : Texture2D
@export var families: Array[Family.Type]
@export var rarity : Rarity
@export var player_upgrade: CardEffect
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


# Identité de design effective. Retombe sur `name` tant que `id` n'est pas
# renseigné, pour rester compatible avec les .tres existants.
func design_id() -> StringName:
	return id if id != &"" else StringName(name)


var uid: int
