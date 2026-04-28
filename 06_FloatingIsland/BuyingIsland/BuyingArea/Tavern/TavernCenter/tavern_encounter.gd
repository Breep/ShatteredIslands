class_name TavernEncounter
extends RefCounted

# Décrit ce qui doit être affiché dans le TavernCenter pour un round de coop/mono.
# - players : héros joueurs, assis à la table
# - masters : entités ennemies principales, assises face aux joueurs
# - slaves  : entités secondaires, debout derrière les masters

var players: Array[Hero]
var masters: Array[Entity]
var slaves: Array[Entity]
