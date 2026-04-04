## RuneGlow — Controller for rune illumination shader
##
## Attach this script to the TextureRect node that holds the runes texture.
## The shader material (rune_glow.gdshader) must be assigned to this node.
##
## Usage from parent CardNode:
##   $Runes.set_rarity(Card.Rarity.LEGENDARY)
##   $Runes.set_glow_mode(RuneGlow.GlowMode.RANDOM)
##   $Runes.set_hover(true)
##
class_name RuneGlowTools
extends TextureRect

# ── Enums ──────────────────────────────────────────────────────

enum GlowMode {
	MYSTIC_PULSE = 0,  ## All runes breathe together
	RANDOM = 1,        ## Zones illuminate independently
}

const RARITY_CONFIG: Dictionary = {
	Card.Rarity.COMMON: {
		"color": Color(0.276, 0.274, 0.336, 1.0),   # Gris argent doux — #E0E4EA
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 6,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 8,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Card.Rarity.RARE: {
		"color": Color(0.235, 0.471, 0.933, 1.0),    # Bleu vif — #3C78EE
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 6,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 8,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Card.Rarity.EPIC: {
		"color": Color(0.553, 0.282, 0.957, 1.0),    # Violet profond — #8D48F4
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 6,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 8,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
	Card.Rarity.LEGENDARY: {
		"color": Color(1.0, 0.647, 0.0, 1.0),        # Orange doré — #FFA500
		"intensity_multiplier": 3.0,
		"idle_intensity": 0.73,
		"hover_intensity": 1.2,
		"speed": 1.0,
		"inner_radius": 0.006,
		"inner_samples": 6,
		"inner_falloff": 0.5,
		"inner_brightness": 1.5,
		"outer_radius": 0.035,
		"outer_samples": 8,
		"outer_falloff": 0.8,
		"outer_brightness": 0.6,
		"core_hotspot": 0.5,
		"min_tint": 0.0,
		"random_zones": 13,
		"zone_softness": 0.5,
	},
}

# ── Exported properties ───────────────────────────────────────

@export var current_rarity: Card.Rarity = Card.Rarity.COMMON :
	set(value):
		current_rarity = value
		_apply_rarity_config()

@export var current_mode: GlowMode = GlowMode.MYSTIC_PULSE :
	set(value):
		current_mode = value
		_set_shader_param("glow_mode", int(value))

## Duration of the hover transition (seconds)
@export var hover_transition_duration: float = 0.3

## Override animation speed (0 = use rarity default)
@export var speed_override: float = 0.0 :
	set(value):
		speed_override = value
		var config: Dictionary = RARITY_CONFIG.get(current_rarity, RARITY_CONFIG[Card.Rarity.COMMON])
		var spd: float = value if value > 0.0 else config["speed"]
		_set_shader_param("animation_speed", spd)

## Override intensity multiplier (useful for special effects, e.g., card played)
@export var intensity_override: float = 1.0 :
	set(value):
		intensity_override = value
		_set_shader_param("intensity_multiplier", value)

# ── State ─────────────────────────────────────────────────────

var _is_hovered: bool = false
var _hover_tween: Tween = null
var _shader_mat: ShaderMaterial = null

# ── Lifecycle ─────────────────────────────────────────────────

## Lazily grab the ShaderMaterial — works both in editor and at runtime
func _ensure_shader_mat() -> bool:
	if _shader_mat != null:
		return true
	if material is ShaderMaterial:
		_shader_mat = material as ShaderMaterial
		return true
	return false

func _ready() -> void:
	if not _ensure_shader_mat():
		push_warning("RuneGlow: Node '%s' needs a ShaderMaterial with rune_glow.gdshader" % name)
		return

	_apply_rarity_config()
	_set_shader_param("glow_mode", int(current_mode))
	_set_shader_param("intensity_multiplier", intensity_override)
	_set_shader_param("hover_blend", 0.0)
	_set_shader_param("time_seed", randf() * 100.0)

# ── Public API ────────────────────────────────────────────────

## Call after duplicating the material externally to refresh the internal reference
func refresh_material() -> void:
	_shader_mat = null
	if _ensure_shader_mat():
		_apply_rarity_config()
		_set_shader_param("glow_mode", int(current_mode))
		_set_shader_param("intensity_multiplier", intensity_override)
		_set_shader_param("time_seed", randf() * 100.0)


## Set the rarity and apply all associated glow parameters
func set_rarity(rarity: Card.Rarity) -> void:
	current_rarity = rarity

## Switch glow animation mode
func set_glow_mode(mode: GlowMode) -> void:
	current_mode = mode

## Trigger hover state (smooth transition)
func set_hover(hovered: bool) -> void:
	if _is_hovered == hovered:
		return
	_is_hovered = hovered
	_animate_hover(1.0 if hovered else 0.0)

## Instant intensity change (no transition), useful for card spawn effects
func flash(intensity: float, target: float = -1.0, duration: float = 0.5) -> void:
	if _shader_mat == null:
		return
	var end_value := target if target >= 0.0 else intensity_override
	intensity_override = intensity
	var tween := create_tween()
	tween.tween_property(self, "intensity_override", end_value, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

## Flash residual: instant constant glow that fades back to 0
func flash_residual(intensity: float = 2.0, duration: float = 0.5) -> void:
	if _shader_mat == null:
		return
	_set_shader_param("residual_flash", intensity)
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: _set_shader_param("residual_flash", v),
		intensity, 0.0, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## Smoothly turn glow on/off (e.g., card entering/leaving scene)
func fade_in(duration: float = 0.6) -> void:
	if _shader_mat == null:
		return
	_set_shader_param("intensity_multiplier", 0.0)
	var tween := create_tween()
	tween.tween_method(_set_intensity, 0.0, intensity_override, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func fade_out(duration: float = 0.4) -> void:
	if _shader_mat == null:
		return
	var tween := create_tween()
	tween.tween_method(_set_intensity, intensity_override, 0.0, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

# ── Internal ──────────────────────────────────────────────────

func _apply_rarity_config() -> void:
	if not _ensure_shader_mat():
		return
	var config: Dictionary = RARITY_CONFIG.get(current_rarity, RARITY_CONFIG[Card.Rarity.COMMON])
	# Color
	_set_shader_param("glow_color", config["color"])
	# Intensity & animation
	_set_shader_param("intensity_multiplier", config["intensity_multiplier"])
	_set_shader_param("idle_intensity", config["idle_intensity"])
	_set_shader_param("hover_intensity", config["hover_intensity"])
	var spd: float = speed_override if speed_override > 0.0 else config["speed"]
	_set_shader_param("animation_speed", spd)
	# Inner glow
	_set_shader_param("inner_radius", config["inner_radius"])
	_set_shader_param("inner_samples", config["inner_samples"])
	_set_shader_param("inner_falloff", config["inner_falloff"])
	_set_shader_param("inner_brightness", config["inner_brightness"])
	# Outer halo
	_set_shader_param("outer_radius", config["outer_radius"])
	_set_shader_param("outer_samples", config["outer_samples"])
	_set_shader_param("outer_falloff", config["outer_falloff"])
	_set_shader_param("outer_brightness", config["outer_brightness"])
	# Core
	_set_shader_param("core_hotspot", config["core_hotspot"])
	_set_shader_param("min_tint", config["min_tint"])
	# Random mode
	_set_shader_param("random_zones", config["random_zones"])
	_set_shader_param("zone_softness", config["zone_softness"])

func _animate_hover(target: float) -> void:
	if not _ensure_shader_mat():
		return
	# Kill previous hover tween if running
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_method(_set_hover_blend, _get_shader_param("hover_blend"), target, hover_transition_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _set_hover_blend(value: float) -> void:
	_set_shader_param("hover_blend", value)

func _set_intensity(value: float) -> void:
	_set_shader_param("intensity_multiplier", value)

func _set_shader_param(param: StringName, value: Variant) -> void:
	if _shader_mat == null:
		_ensure_shader_mat()
	if _shader_mat:
		_shader_mat.set_shader_parameter(param, value)

func _get_shader_param(param: StringName) -> Variant:
	if _shader_mat == null:
		_ensure_shader_mat()
	if _shader_mat:
		return _shader_mat.get_shader_parameter(param)
	return 0.0
