# Donnée transportée pendant un drag-and-drop de carte entre conteneurs (main,
# shop, coffre…). Porte la carte agrégée (pour l'affichage) ET les cartes source
# réelles avec leurs UID : une carte niveau N = N cartes empilées. La cible
# décide quoi faire du payload (encaisser, vendre…) ; l'origine sait le reprendre
# ou le retirer définitivement après transfert.
class_name CardPayload
extends RefCounted

#region ============================== Public vars ==============================
var merged_card: Card
var source_cards: Array[Card]
# Le conteneur d'où part le drag (duck-typed : implémente le contrat container
# attendu par DragCoordinator). Sert au retour si le drop échoue.
var origin: Object
#endregion


#region ============================== Public functions ==============================
func _init(p_merged: Card = null, p_sources: Array[Card] = [], p_origin: Object = null) -> void:
	merged_card = p_merged
	source_cards = p_sources
	origin = p_origin


# Nombre de cartes réelles empilées = niveau de la carte agrégée.
func level() -> int:
	return source_cards.size()
#endregion
