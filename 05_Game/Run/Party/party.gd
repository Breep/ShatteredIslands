# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs (état de run sauvegardable), un Roaster par slot
# (inventaire de chaque joueur : héros, acolytes, bâtiments), la formation
# côté joueur et le coffre partagé. État "vivant" injecté dans chaque Encounter.
#
# Resource : sérialisable en .tres pour la save inter-confrontation.
class_name Party
extends Resource

#region ============================== Export ==============================
@export var players: Array[PlayerState]
@export var formation: FightingFormation
@export var roasters: Dictionary[PlayerState.Slot, Roaster] = {}
## Coffre partagé par toute l'équipe : stockage de cartes hors-héros.
@export var chest: Deck = Deck.new()
#endregion


#region ============================== Public functions ==============================
# Roaster d'un slot. null si aucun roaster posé pour ce slot.
func get_roaster(slot: PlayerState.Slot) -> Roaster:
	return roasters.get(slot)


# Idem, mais crée le Roaster si absent. À utiliser quand on pose l'ownership
# (ajout d'un héros au lock, etc.).
func get_or_create_roaster(slot: PlayerState.Slot) -> Roaster:
	if not roasters.has(slot):
		roasters[slot] = Roaster.new()
	return roasters[slot]


# Slot du joueur propriétaire d'une entry. NONE si l'entry n'appartient à
# aucun roaster connu.
func find_slot_of(entry: RoasterEntry) -> PlayerState.Slot:
	for slot: PlayerState.Slot in roasters:
		if roasters[slot].has(entry):
			return slot
	return PlayerState.Slot.NONE


# Itération plate sur toutes les entries de tous les roasters confondus.
# Pratique pour les passes globales (attach scenes, init runtime data...).
func all_entries() -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for roaster: Roaster in roasters.values():
		result.append_array(roaster.entries)
	return result
#endregion
