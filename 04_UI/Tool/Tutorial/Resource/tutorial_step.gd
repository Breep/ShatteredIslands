class_name TutorialStep
extends Resource

# A single tutorial beat: a Braise dialogue line, optionally pointing at a UI
# target, with a defined way to know when the player has acted on it.

#region ============================== Enums ==============================
enum ValidationEvent {
	NONE, ## Auto-advance after auto_advance_delay seconds.
	ENTITY_CLICKED,
	FURNITURE_CLICKED,
	UI_SKILL_PICKED,
	END_BUYING_PRESSED,
	GAME_STATE_FIGHTING,
	GAME_STATE_ENDING_ROUND,
}
#endregion


#region ============================== Export ==============================
@export var id: StringName

@export_multiline var text: String

## Unique-name-in-owner of the Control to point at (no `%` prefix). Empty = bubble centered, no arrow.
@export var target_unique_name: StringName

@export var validation_event: ValidationEvent = ValidationEvent.NONE

## Optional discriminator passed alongside the validation event (e.g. furniture id).
@export var validation_filter: StringName

## Delay in seconds before the bubble auto-advances. Used when validation_event is NONE,
## and as a safety fallback for other events (set to 0 to disable fallback).
@export var auto_advance_delay: float = 4.0
#endregion
