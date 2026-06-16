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
	## Appended after the originals so existing .tres integer references stay valid.
	CARD_BOUGHT, ## Any card purchased from the shop (validation_filter unused here).
	SHOP_REFRESHED, ## The player rerolled the shop.
	OPEN_SHOP, ## The player opened the shop panel.
	HERO_SKILL_CHOSEN, ## The local hero picked a talent from the skill selection.
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

## Forces the bubble to a fixed screen position instead of anchoring next to the
## target (no arrow). AUTO = normal target-relative placement. Use when the target
## is awkward to point at or the bubble would overlap content (e.g. the talent
## cards, or the entity sheet at the bottom).
enum ScreenAnchor {
	AUTO = 0,
	RIGHT_CENTER = 1,
	CENTER = 2,
	BOTTOM_CENTER = 3,
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

## Extra Controls (by unique-name) to ALSO spotlight — each gets its own hole and
## border. The bubble still anchors to target_unique_name. Use when a step must
## highlight several elements at once (e.g. the two talent choices).
@export var extra_target_unique_names: Array[StringName] = []

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

## Hides the bubble's Skip button. Use on forced steps where the only way out is
## to perform the required action (e.g. buy the highlighted card). Pair with a
## reachable validation_event so the step is never a dead-end.
@export var hide_skip: bool = false

## UI state the step guarantees before pointing at things, via Events.
## ensure_shop_open: force the shop panel open (in case the player closed it).
## ensure_shop_closed: force it closed (to clear the view, e.g. to click an enemy).
## hide_hand: hide the player's hand while the step is active (auto-restored after).
@export var ensure_shop_open: bool = false
@export var ensure_shop_closed: bool = false
@export var hide_hand: bool = false

## Fades the spotlight dim out while the player is dragging an entity, so the
## field stays readable for placement; the dim returns when the drag ends.
@export var dim_off_while_dragging: bool = false

## Highlights the target but blocks input ON it too (no hole pass-through). Use for
## purely-informational steps that point at an interactive element the player must
## NOT use yet (e.g. showing a card's rarity before the dedicated buy step).
@export var block_interaction: bool = false

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

## Extra screen-space padding (in pixels) added around the target rect when
## drawing the highlight. Useful when the target's visual bounds feel too tight
## (e.g. small icons). 0 = pixel-perfect on the Control's transformed rect.
@export var highlight_padding: float = 0.0

## Forces the bubble to a specific side relative to the target. AUTO uses the
## first side with enough screen space. When set, the chosen side is honored
## IF there's room; otherwise it falls back to AUTO. Useful for elements where
## the auto pick lands awkwardly (e.g. gold display in a corner).
@export var preferred_arrow_side: PreferredArrowSide = PreferredArrowSide.AUTO

## Pins the bubble to a fixed screen spot (no arrow), overriding target-relative
## placement. AUTO keeps the normal behavior.
@export var screen_anchor: ScreenAnchor = ScreenAnchor.AUTO
#endregion
