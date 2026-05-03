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

enum PopupMode {
	PASSIVE, ## Input passes through, no dim. Default — non-intrusive tip.
	BLOCKING, ## Blocks input outside target rect, no dim. Forces interaction with the highlighted target.
	MODAL_DIMMED, ## Same blocking + dimmed background. For high-importance steps.
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

## Controls input blocking and background dim around the bubble.
## Note: with BLOCKING/MODAL_DIMMED + no target + no validation_event + auto_advance_delay = 0,
## the only way out is the Skip button. Set auto_advance_delay > 0 or use a target to avoid dead-ends.
@export var popup_mode: PopupMode = PopupMode.PASSIVE

## Optional portrait shown on the left of the bubble. Leave null to fall back
## to the default portrait baked in the bubble scene.
@export var portrait_texture: Texture2D

## Optional speaker name shown above the dialogue. Leave empty to fall back
## to the default name baked in the bubble scene.
@export var speaker_name: String = ""
#endregion
