# Donnée d'une carte : identité (id de design + uid d'instance), rareté, niveau
# et l'effet appliqué au héros (card_effect). Resource sérialisable, dupliquée
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
@export var name : StringName
@export var picture : Texture2D
@export var families: Array[Family.Type]
@export var rarity : Rarity
@export var _card_effect: CardEffect
@export var points: Dictionary[Family.Type, int]
var uid: int

@export_range(1, 5) var _lvl: int = 1 # Current lvl
var lvl: int:
	get: return clampi(_lvl, 1, RARITY_MAX_LEVEL[rarity])
	set(value):
		value = clampi(value, 1, RARITY_MAX_LEVEL[rarity])
		if value == _lvl: return
		_lvl = value


func is_max_level() -> bool:
	return _lvl == RARITY_MAX_LEVEL[rarity]


func has_effect() -> bool:
	return _card_effect != null


# Accès en lecture à l'effet (introspection des valeurs par les panneaux de
# description, etc.). L'application/retrait passe par apply_effect/revert_effect.
func get_card_effect() -> CardEffect:
	return _card_effect


func apply_effect(ctx: CardContext) -> void:
	if _card_effect == null:
		Verbose.error("Can't apply effect on [" + name, Verbose.Category.CARD)
		return
	_card_effect.apply(ctx, name, lvl)


func revert_effect(ctx: CardContext) -> void:
	if _card_effect == null:
		Verbose.error("Can't revert effect on [" + name, Verbose.Category.CARD)
		return
	_card_effect.revert(ctx, name, lvl)


# One-shot à l'entrée dans la main (achat, sortie de coffre). Déclenche les
# mutations persistantes (ex. ajout au roaster). N'est PAS rejoué au respawn
# du héros — c'est la différence avec apply_effect.
func on_hand_enter_effect(ctx: CardContext) -> void:
	if _card_effect == null:
		Verbose.error("Can't on_hand_enter effect on [" + name, Verbose.Category.CARD)
		return
	_card_effect.on_hand_enter(ctx, name, lvl)


# Level-up : on délègue à la carte le soin de gérer la transition prev → new
# (delta pour les effets persistants, revert+apply pour les modifiers). À ce
# stade lvl est déjà = new_lvl ; prev_lvl est passé par le caller (Deck).
func on_upgrade_effect(ctx: CardContext, prev_lvl: int) -> void:
	if _card_effect == null:
		Verbose.error("Can't on_upgrade effect on [" + name, Verbose.Category.CARD)
		return
	_card_effect.on_upgrade(ctx, name, prev_lvl, lvl)


func get_description() -> String:
	if _card_effect == null:
		Verbose.error("Can't get description on [" + name, Verbose.Category.CARD)
		return ""
	return _card_effect.get_description(lvl)
