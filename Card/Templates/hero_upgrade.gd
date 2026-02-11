class_name HeroUpgrade
extends Resource

## Base class for card effects. Each card's player_upgrade references a concrete subclass.
##
## Migration note: Override apply_card() for new-style cards that use CardContext registries.
## Legacy cards that override apply() will continue to work — the default apply_card()
## delegates to apply() for backward compatibility.


## New entry point — override this in migrated cards.
## Default implementation delegates to legacy apply() for backward compatibility.
func apply_card(ctx: CardContext, card_lvl: int) -> void:
	apply(ctx.hero.families_stats, card_lvl)


## Legacy entry point — kept for non-migrated cards.
## Override apply_card() instead for new cards.
func apply(_stats: FamiliesStats, _cardLvl: int) -> void:
	push_warning("[HeroUpgrade] call virtual apply()")
	pass


func get_description(_cardlvl: int) -> String:
	push_warning("[HeroUpgrade] call virtual get_description()")
	return ""
