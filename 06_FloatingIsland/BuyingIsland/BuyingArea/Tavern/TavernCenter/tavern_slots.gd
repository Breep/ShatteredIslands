class_name TavernSlots

# Source de vérité pour tous les IDs logiques de slots.
# Pour qu'un slot soit ciblable depuis un encounter, il doit :
#   1. avoir le script TavernSlot attaché dans la scène
#   2. avoir son slot_id rempli avec une de ces constantes
#
# Les Node3D non-taggés restent utilisables pour l'auto-placement uniquement.

# Slave : juste derrière le master (centré, dans son dos)
const SLAVE_BEHIND_MASTER: StringName = &"slave_behind_master"

# Slave : tout au fond de la taverne, dans le coin gauche
const SLAVE_BACK_CORNER_LEFT: StringName = &"slave_back_corner_left"

# Slave : tout au fond de la taverne, dans le coin droit
const SLAVE_BACK_CORNER_RIGHT: StringName = &"slave_back_corner_right"
