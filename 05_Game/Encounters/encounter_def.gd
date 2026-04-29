class_name EncounterDef
extends Resource

# Description statique d'un encounter pour la phase de buying.
# Authorée comme un .tres dans 05_Game/Encounters/Defs/.
#
# Les players (héros joueurs) viennent du game state au runtime — pas décrits ici.
# Seuls les NPCs (masters + slaves) sont définis dans cette resource.

@export var encounter_name: StringName
@export var masters: Array[EntityPlacement]
@export var slaves: Array[EntityPlacement]
