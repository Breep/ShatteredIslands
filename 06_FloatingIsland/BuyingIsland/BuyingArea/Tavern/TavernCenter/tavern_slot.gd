class_name TavernSlot
extends Node3D

# Slot ciblable depuis un script d'encounter via son slot_id (cf TavernSlots).
# L'ID reste stable même si on renomme/déplace le Node dans la scène.

@export var slot_id: StringName
