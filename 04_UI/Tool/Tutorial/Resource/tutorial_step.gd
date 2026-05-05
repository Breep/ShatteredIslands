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
	MODAL_DIMMED, ## Alias for BLOCKING + highlight_target = true (kept for back-compat).
}

## Preferred bubble side. AUTO = first side that fits (right, left, top, bottom).
## Values match UIBraiseBubble.ArrowSide so the int can be passed through directly.
## Naming follows the arrow's position on the bubble:
## - LEFT  → arrow on left of bubble  → bubble appears on the RIGHT of the target
## - RIGHT → arrow on right of bubble → bubble appears on the LEFT of the target
## - TOP   → arrow on top of bubble   → bubble appears BELOW the target
## - BOTTOM→ arrow on bottom of bubble→ bubble appears ABOVE the target
enum PreferredArrowSide {
	AUTO = 0,
	LEFT = 1,
	RIGHT = 2,
	TOP = 3,
	BOTTOM = 4,
}
#endregion


#region ============================== Export ==============================
@export var id: StringName

@export_multiline var text: String

## Unique-name-in-owner of the Control to point at (no `%` prefix). Empty = bubble centered, no arrow.
@export var target_unique_name: StringName

## Optional descendant name used to drill into the target's subtree (e.g. into an
## instanced sub-scene whose unique-names aren't reachable from the root). When
## set, the resolver descends from `target_unique_name` via find_child(owned=false)
## and returns the first match. Empty = stay on the parent target.
@export var target_sub_name: StringName

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

## When true, the rest of the screen darkens around the target (4-strip spotlight)
## while this step is active. Independent from popup_mode — you can have a
## passive (non-blocking) tip that still highlights its target. Setting
## popup_mode = MODAL_DIMMED implies highlight_target = true.
@export var highlight_target: bool = false

## Forces the bubble to a specific side relative to the target. AUTO uses the
## first side with enough screen space. When set, the chosen side is honored
## IF there's room; otherwise it falls back to AUTO. Useful for elements where
## the auto pick lands awkwardly (e.g. gold display in a corner).
@export var preferred_arrow_side: PreferredArrowSide = PreferredArrowSide.AUTO
#endregion
