class_name TimedAlteration
extends Alteration

## Non-stackable binary alteration with a duration.
## Semantics: on/off state; applying a shorter duration while one is active is
## a no-op; duration == -1 means infinite.
##
## Timer management is delegated to the owning module (Resources cannot hold
## scene-tree Timer nodes directly). This class defines the contract and
## broadcast signal; the module is responsible for driving state transitions.
## Used for (post-rework): Stun, Silence, Taunt, Invulnerable, Untargetable.

signal status_changed(is_active: bool, duration: float, infinite: bool)
