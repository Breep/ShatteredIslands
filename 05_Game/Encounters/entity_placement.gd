class_name EntityPlacement
extends Resource

# Décrit une entité (master ou slave) à placer dans un encounter.
#
# scene          : la scène à instancier au runtime
# fixed_slot_id  : si non vide, l'entité sera pinnée à ce slot précis
#                  (cf TavernSlots). Sinon, auto-placement dans son rôle.

@export var scene: PackedScene
@export var fixed_slot_id: StringName
