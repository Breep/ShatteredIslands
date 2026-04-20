class_name AlterationsModule
extends Module

## Common base for modules that manage Alterations on an entity.
## During the rework transition this serves as a unifying type shared by
## ConditionsModule (stackable alterations) and StatusModule (timed alterations).
## Phase 3b will absorb both into a single concrete subclass.
