# Encapsule la création du CardContext et l'application des upgrades de cartes du
# deck. Le state externe (deck, _custom_deck, data_memory, _custom_data_memory)
# vit sur Hero (timing hero_spec.spawn_into qui set les valeurs AVANT add_child).
# Le module agit, Hero conserve les fields.
class_name DeckHolder
extends EntityComponent


#region ============================== Private variables ==============================
var _card_context: CardContext
#endregion


#region ============================== Public functions ==============================
# Crée le CardContext (indépendant du deck — peut être appelé sans deck dispo).
func setup() -> void:
	_card_context = CardContext.create(
		_owner,
		_owner.stat_modifiers_registry,
		_owner.action_modifiers_registry,
		_owner.auto_attack_modifier_registry,
		_owner.periodic_timer_registry,
		_owner.battle_callback_registry
	)


# Applique les upgrades de toutes les cartes du deck via leur player_upgrade.
func apply_all_cards_upgrades(deck: PlayerDeck) -> void:
	if _card_context == null:
		Verbose.error("DeckHolder: card_context not set, call setup() first", Verbose.Category.HERO)
		return
	if deck == null:
		Verbose.error("DeckHolder: can't apply cards upgrades, deck is null", Verbose.Category.HERO)
		return

	Verbose.debug("Applying all cards upgrades", Verbose.Category.HERO)
	for card: Card in deck.get_active_deck():
		card.player_upgrade.apply_card(_card_context, card.lvl)


func get_card_context() -> CardContext:
	return _card_context
#endregion
