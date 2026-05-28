# Pool global de cartes du marchand : des instances de cartes regroupées par
# rareté. On y pioche en fournissant un % de chance par rareté (fourni par
# l'appelant) — aucune notion de pool par joueur ni de familles. Indépendant des
# singletons : les règles de construction sont passées en argument.
class_name ShopDeck
extends Resource

#region ============================== Private variables ==============================
# Instances disponibles, regroupées par rareté.
var _pools: Dictionary[Card.Rarity, Array] # Array[Card]
# Index uid -> Card pour la résolution réseau (RPC d'achat / refresh).
var _by_uid: Dictionary[int, Card]
#endregion


#region ============================== Public functions ==============================
# Construit le pool : pour chaque carte de chaque famille, crée le nombre
# d'instances dicté par `rarity_card_numbers`, avec un uid unique.
func construct(families: Array[Family], rarity_card_numbers: Dictionary[Card.Rarity, int]) -> void:
	_pools.clear()
	_by_uid.clear()
	var uid: int = 0
	for family: Family in families:
		for card: Card in family.cards:
			var copies: int = rarity_card_numbers.get(card.rarity, 0)
			for _i in copies:
				var instance: Card = card.duplicate()
				instance.uid = uid
				instance.lvl = 1
				uid += 1
				_add(instance)
	Verbose.debug("ShopDeck constructed | total cards = " + str(_by_uid.size()), Verbose.Category.SHOP_DECK)


func get_card(uid: int) -> Card:
	return _by_uid.get(uid)


func size() -> int:
	return _by_uid.size()


func add_card(card: Card) -> void:
	if card == null:
		Verbose.error("ShopDeck: can't add a null card", Verbose.Category.SHOP_DECK)
		return
	_add(card)


func remove_card(card: Card) -> void:
	if card == null:
		return
	if _pools.has(card.rarity):
		_pools[card.rarity].erase(card)
	_by_uid.erase(card.uid)


# Pioche `count` cartes en respectant les % de chance par rareté. Pas de doublon
# de design dans une même pioche. Les cartes piochées sont retirées du pool.
func draw(count: int, rarity_chances: Dictionary[Card.Rarity, float]) -> Array[Card]:
	var drawn: Array[Card] = []
	var drawn_ids: Array[StringName] = []
	for _i in count:
		var rarity: Card.Rarity = _roll_rarity(rarity_chances)
		var card: Card = _pick_available(rarity, drawn_ids)
		if card == null:
			card = _pick_fallback(rarity, drawn_ids)
		if card == null:
			Verbose.warn("ShopDeck: no more cards available to draw", Verbose.Category.SHOP_DECK)
			break
		drawn.append(card)
		drawn_ids.append(card.design_id())
	for card in drawn:
		remove_card(card)
	return drawn
#endregion


#region ============================== Private functions ==============================
func _add(card: Card) -> void:
	if not _pools.has(card.rarity):
		_pools[card.rarity] = [] as Array[Card]
	_pools[card.rarity].append(card)
	_by_uid[card.uid] = card


func _pick_available(rarity: Card.Rarity, exclude_ids: Array[StringName]) -> Card:
	if not _pools.has(rarity):
		return null
	var candidates: Array[Card] = []
	for card: Card in _pools[rarity]:
		if not card.design_id() in exclude_ids:
			candidates.append(card)
	if candidates.is_empty():
		return null
	return candidates[Utils.get_randi_range(0, candidates.size() - 1)]


# Cherche une rareté de repli (de la plus haute vers la plus basse) si la rareté
# tirée est épuisée.
func _pick_fallback(rarity: Card.Rarity, exclude_ids: Array[StringName]) -> Card:
	var order: Array[Card.Rarity] = [
		Card.Rarity.LEGENDARY,
		Card.Rarity.EPIC,
		Card.Rarity.RARE,
		Card.Rarity.COMMON,
	]
	var start: int = order.find(rarity)
	for i in range(start + 1, order.size()):
		var card: Card = _pick_available(order[i], exclude_ids)
		if card != null:
			return card
	return null


func _roll_rarity(rarity_chances: Dictionary[Card.Rarity, float]) -> Card.Rarity:
	var roll: float = Utils.get_randf_range(0.0, 100.0)
	var cumulative: float = 0.0
	for rarity: Card.Rarity in [Card.Rarity.COMMON, Card.Rarity.RARE, Card.Rarity.EPIC, Card.Rarity.LEGENDARY]:
		cumulative += rarity_chances.get(rarity, 0.0)
		if roll < cumulative:
			return rarity
	return Card.Rarity.COMMON
#endregion
