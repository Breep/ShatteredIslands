class_name Alteration
extends Resource

## Abstract base class for all alterations (buffs, debuffs, and timed binary effects).
## Polarity distinguishes positive effects (dispellable) from negative ones (cleanseable).
## Concrete alterations inherit from either StackableAlteration or TimedAlteration.

enum Polarity {
	BUFF,
	DEBUFF,
}

## Keys for the `mod` dictionary passed to add_stack() etc.
## Shared across all stackable subclasses so callers can reuse them.
enum ModifierType {
	DURATION,
}

@export var id: StringName
@export var polarity: Polarity = Polarity.BUFF
