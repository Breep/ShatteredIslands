extends Resource
class_name CardPile

var rng: RandomNumberGenerator = RandomNumberGenerator.new()  # Générateur de nombres aléatoires
var deck_pile: Array[Card] = []  # Initialise un tableau vide pour les cartes

# Ajouter une carte au deck
func add_card(card_to_add: Card) -> void:
	deck_pile.append(card_to_add)

# Retirer une carte spécifique du deck
func remove_card(card_to_remove: Card) -> void:
	if card_to_remove in deck_pile:
		deck_pile.erase(card_to_remove)

# Retirer une carte par son index
func remove_card_int(index: int) -> void:
	if index >= 0 and index < deck_pile.size():
		deck_pile.remove_at(index)
	else:
		print("Index invalide :", index)

# Piocher une carte par son index
func draw_card(index: int) -> Card:
	if deck_pile.is_empty():
		print("Le deck est vide.")
		return null
	
	if index >= 0 and index < deck_pile.size():
		var drawn_card: Card = deck_pile[index]
		remove_card_int(index)
		return drawn_card
	else:
		print("Index invalide :", index)
		return null

# Piocher une carte aléatoire
func draw_random_card() -> Card:
	if deck_pile.is_empty():
		print("Le deck est vide.")
		return null
	
	var random_index = rng.randi_range(0, deck_pile.size() - 1)  # Index aléatoire valide
	return draw_card(random_index)

func draw_n_random_card(number :int) -> Array[Card]:
	var random_card_array : Array[Card]
	for i in number:
		random_card_array.append(draw_random_card())
	return random_card_array

# Mélanger le deck
func shuffle() -> void:
	if deck_pile.is_empty():
		print("Le deck est vide, rien à mélanger.")
		return
	
	for i in range(deck_pile.size()):
			var random_index = rng.randi_range(0, deck_pile.size() - 1)
			# Échange des éléments avec une variable temporaire
			var temp = deck_pile[i]
			deck_pile[i] = deck_pile[random_index]
			deck_pile[random_index] = temp
		
	print("Deck mélangé avec succès.")
	for card in deck_pile:
		print("Carte ajoutée :", card.name)
	
	
# Construire et afficher le deck
func construct_pile_deck(families: Array[Family], gamerules: CardRules) -> void:
	deck_pile.clear()
	
	# Parcourt chaque famille
	for family in families:
		for card in family.cards:
			match card.rarity:
				Card.Rarity.COMMON:
					for i in gamerules.common_number:
						add_card(card)
				Card.Rarity.RARE:
					for i in gamerules.rare_number:
						add_card(card)
				Card.Rarity.EPIC:
					for i in gamerules.epic_number:
						add_card(card)

	
	# Affiche les cartes ajoutées pour vérification
	for card in deck_pile:
		print("Carte ajoutée :", card.name)
