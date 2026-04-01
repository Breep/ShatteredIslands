## RuneGlow — Controller for rune illumination shader (runtime only)
##
## Attach this script to the TextureRect node that holds the runes texture.
## The shader material (rune_glow.gdshader) must be assigned to this node.
##
## Usage from parent CardNode:
##   $Runes.set_rarity(RuneGlow.Rarity.LEGENDARY)
##   $Runes.set_glow_mode(RuneGlow.GlowMode.RANDOM)
##   $Runes.set_hover(true)
##
class_name RuneGlow
extends TextureRect

# ── Enums ──────────────────────────────────────────────────────

enum GlowMode {
	MYSTIC_PULSE = 0,  ## All runes breathe together
	RANDOM = 1,        ## Zones illuminate independently
}

enum Rarity {
	COMMON = 0,
	RARE = 1,
	EPIC = 2,
	LEGENDARY = 3,
}

# ── Rarity Configuration ──────────────────────────────────────
# All rarities share the same base settings, only color changes.

const RARITY_CONFIG: Dictionary = {
	Rarity.COMMON: {
		"color": Color(0.878, 0.894, 0.918, 1.0),   # Gris argent doux
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 10,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 14,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Rarity.RARE: {
		"color": Color(0.235, 0.471, 0.933, 1.0),    # Bleu vif
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 10,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 14,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Rarity.EPIC: {
		"color": Color(0.553, 0.282, 0.957, 1.0),    # Violet profond
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 10,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 14,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Rarity.LEGENDARY: {
		"color": Color(1.0, 0.647, 0.0, 1.0),        # Orange doré
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 10,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 14,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
}

# ── Exported properties ───────────────────────────────────────

@export var current_rarity: Rarity = Rarity.COMMON
@export var current_mode: GlowMode = GlowMode.MYSTIC_PULSE
@export var hover_transition_duration: float = 0.3
@export var speed_override: float = 0.0

# ── State ─────────────────────────────────────────────────────

var _is_hovered: bool = false
var _hover_tween: Tween = null
var _shader_mat: ShaderMaterial = null

# ── Lifecycle ─────────────────────────────────────────────────

func _ready() -> void:
	if material is ShaderMaterial:
		_shader_mat = material as ShaderMaterial
	else:
		push_warning("RuneGlow: Node '%s' needs a ShaderMaterial with rune_glow.gdshader" % name)
		return

	_apply_rarity_config()
	_shader_mat.set_shader_parameter("glow_mode", int(current_mode))
	_shader_mat.set_shader_parameter("hover_blend", 0.0)

# ── Public API ────────────────────────────────────────────────

## Set the rarity and apply all associated glow parameters
func set_rarity(rarity: Rarity) -> void:
	current_rarity = rarity
	_apply_rarity_config()

## Switch glow animation mode
func set_glow_mode(mode: GlowMode) -> void:
	current_mode = mode
	if _shader_mat:
		_shader_mat.set_shader_parameter("glow_mode", int(mode))

## Trigger hover state (smooth transition)
func set_hover(hovered: bool) -> void:
	if _is_hovered == hovered or _shader_mat == null:
		return
	_is_hovered = hovered
	_animate_hover(1.0 if hovered else 0.0)

## Instant intensity flash then return to normal
func flash(intensity: float, duration: float = 0.5) -> void:
	if _shader_mat == null:
		return
	var config: Dictionary = RARITY_CONFIG.get(current_rarity, RARITY_CONFIG[Rarity.COMMON])
	var original: float = config["intensity_multiplier"]
	_shader_mat.set_shader_parameter("intensity_multiplier", intensity)
	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: _shader_mat.set_shader_parameter("intensity_multiplier", v),
		intensity, original, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

## Fade glow in from zero
func fade_in(duration: float = 0.6) -> void:
	if _shader_mat == null:
		return
	var config: Dictionary = RARITY_CONFIG.get(current_rarity, RARITY_CONFIG[Rarity.COMMON])
	var target: float = config["intensity_multiplier"]
	_shader_mat.set_shader_parameter("intensity_multiplier", 0.0)
	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: _shader_mat.set_shader_parameter("intensity_multiplier", v),
		0.0, target, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

## Fade glow out to zero
func fade_out(duration: float = 0.4) -> void:
	if _shader_mat == null:
		return
	var current: float = _shader_mat.get_shader_parameter("intensity_multiplier")
	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: _shader_mat.set_shader_parameter("intensity_multiplier", v),
		current, 0.0, duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

# ── Internal ──────────────────────────────────────────────────

func _apply_rarity_config() -> void:
	if _shader_mat == null:
		return
	var config: Dictionary = RARITY_CONFIG.get(current_rarity, RARITY_CONFIG[Rarity.COMMON])
	_shader_mat.set_shader_parameter("glow_color", config["color"])
	_shader_mat.set_shader_parameter("intensity_multiplier", config["intensity_multiplier"])
	_shader_mat.set_shader_parameter("idle_intensity", config["idle_intensity"])
	_shader_mat.set_shader_parameter("hover_intensity", config["hover_intensity"])
	var spd: float = speed_override if speed_override > 0.0 else config["speed"]
	_shader_mat.set_shader_parameter("animation_speed", spd)
	_shader_mat.set_shader_parameter("inner_radius", config["inner_radius"])
	_shader_mat.set_shader_parameter("inner_samples", config["inner_samples"])
	_shader_mat.set_shader_parameter("inner_falloff", config["inner_falloff"])
	_shader_mat.set_shader_parameter("inner_brightness", config["inner_brightness"])
	_shader_mat.set_shader_parameter("outer_radius", config["outer_radius"])
	_shader_mat.set_shader_parameter("outer_samples", config["outer_samples"])
	_shader_mat.set_shader_parameter("outer_falloff", config["outer_falloff"])
	_shader_mat.set_shader_parameter("outer_brightness", config["outer_brightness"])
	_shader_mat.set_shader_parameter("core_hotspot", config["core_hotspot"])
	_shader_mat.set_shader_parameter("min_tint", config["min_tint"])
	_shader_mat.set_shader_parameter("random_zones", config["random_zones"])
	_shader_mat.set_shader_parameter("zone_softness", config["zone_softness"])

func _animate_hover(target: float) -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	var current: float = _shader_mat.get_shader_parameter("hover_blend")
	_hover_tween = create_tween()
	_hover_tween.tween_method(
		func(v: float) -> void: _shader_mat.set_shader_parameter("hover_blend", v),
		current, target, hover_transition_duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
