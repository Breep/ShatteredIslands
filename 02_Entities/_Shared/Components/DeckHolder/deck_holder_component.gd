# Encapsule la création du CardContext et l'application des upgrades de cartes du
# deck. Le state externe (hand, _custom_hand, data_memory, _custom_data_memory)
# vit sur Hero (timing hero_spec.spawn_into qui set les valeurs AVANT add_child).
# Le module agit, Hero conserve les fields.
class_name DeckHolderComponent
extends EntityComponent

#region ============================== Public variables ==============================
var hand: Hand
#endregion


#region ============================== Private variables ==============================
var _card_context: CardContext
#endregion

#region ============================== Node base variables ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.deck_holder != null and _owner.deck_holder != self:
		Verbose.trace("Override: DeckHolderComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.deck_holder.queue_free()
	_owner.deck_holder = self


func _ready() -> void:
	setup()
	# Chemin proto : la main posée en éditeur via override_custom_hand est bindée
	# ici. Au runtime, c'est le spawn qui appelle bind_hand() avec la main du
	# joueur — on ne touche pas override_custom_hand hors prototypage.
	if _owner.override_custom_hand != null:
		Verbose.debug("Binding proto hand on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		bind_hand(_owner.override_custom_hand)


#region ============================== Public functions ==============================
# Lie une main au porteur et applique immédiatement les upgrades de ses cartes.
# Canal d'injection runtime du deck (appelé au spawn avec la main du joueur) ;
# le proto retombe sur ce même chemin via override_custom_hand dans _ready.
func bind_hand(new_hand: Hand) -> void:
	hand = new_hand
	hand.card_added.connect(_on_hand_card_added)
	hand.card_removed.connect(_on_hand_card_removed)
	hand.card_upgraded.connect(_on_hand_card_upgraded)
	if _card_context == null:
		setup()
	apply_all_cards_upgrades()


# Crée le CardContext (indépendant de la main — peut être appelé sans main dispo).
func setup() -> void:
	_card_context = CardContext.create(
		_owner,
	)


# Applique les upgrades de toutes les cartes de la main via leur card_effect.
func apply_all_cards_upgrades() -> void:
	if _card_context == null:
		Verbose.error("DeckHolder: card_context not set, call setup() first", Verbose.Category.HERO)
		return
	if hand == null:
		Verbose.debug("DeckHolder: can't apply cards upgrades, hand is null", Verbose.Category.HERO)
		return

	Verbose.debug("Applying all cards upgrades", Verbose.Category.HERO)
	for card: Card in hand.get_cards_raw():
		apply_card(card)


# Applique une carte (achat / pose). Positionne le card_id du contexte pour que
# la carte puisse retirer ses ajouts keyés au revert.
func apply_card(card: Card) -> void:
	if _card_context == null:
		Verbose.error("DeckHolder: card_context not set, call setup() first", Verbose.Category.HERO)
		return
	if card == null or not card.has_effect():
		return
	card.apply_effect(_card_context)


# Retire une carte (vente / retrait) : défait ce que apply a posé.
func revert_card(card: Card) -> void:
	if _card_context == null:
		Verbose.error("DeckHolder: card_context not set, call setup() first", Verbose.Category.HERO)
		return
	if card == null or not card.has_effect():
		return
	card.revert_effect(_card_context)


func get_card_context() -> CardContext:
	return _card_context


func _on_hand_card_added(card: Card) -> void:
	card.apply_effect(_card_context)

func _on_hand_card_removed(card: Card) -> void:
	card.revert_effect(_card_context)

func _on_hand_card_upgraded(card: Card) -> void:
	card.revert_effect(_card_context)
	card.apply_effect(_card_context)
#endregion
