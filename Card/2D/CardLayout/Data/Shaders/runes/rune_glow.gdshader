shader_type canvas_item;

// ============================================================
// RUNE GLOW SHADER v2 — Backlight Energy Projection
// ============================================================
// Apply to the TextureRect containing the runes layer.
// Runes texture: white/bright on TRANSPARENT background.
//
// Effect layers (back to front):
//   1. OUTER HALO  — wide, soft energy field bleeding far from runes
//   2. INNER GLOW  — tight bright halo hugging the rune edges
//   3. RUNE CORE   — the rune itself, colored + hot center
//
// This simulates light projected from BEHIND the card through the runes.
// ============================================================

group_uniforms rarity;
uniform vec4 glow_color : source_color = vec4(0.149, 0.388, 0.933, 1.0);
uniform float intensity_multiplier : hint_range(0.0, 3.0, 0.01) = 1.0;

group_uniforms animation;
uniform int glow_mode : hint_range(0, 1, 1) = 0;
uniform float animation_speed : hint_range(0.1, 5.0, 0.01) = 1.0;
uniform float time_seed : hint_range(0.0, 100.0, 0.001) = 0.0;

group_uniforms hover;
uniform float hover_blend : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float idle_intensity : hint_range(0.0, 2.0, 0.01) = 0.4;
uniform float hover_intensity : hint_range(0.0, 3.0, 0.01) = 1.2;
uniform float residual_intensity : hint_range(0.0, 2.0, 0.01) = 0.5;
uniform float residual_flash : hint_range(0.0, 10.0, 0.01) = 0.0;

group_uniforms inner_glow;
/// Radius of the tight glow hugging the runes
uniform float inner_radius : hint_range(0.001, 0.02, 0.001) = 0.006;
/// Samples for inner glow blur
uniform int inner_samples : hint_range(4, 24, 1) = 10;
/// Falloff sharpness for inner glow (higher = tighter)
uniform float inner_falloff : hint_range(0.5, 3.0, 0.1) = 1.2;
/// Brightness of the inner glow
uniform float inner_brightness : hint_range(0.5, 3.0, 0.1) = 1.5;

group_uniforms outer_halo;
/// Radius of the wide energy field around runes
uniform float outer_radius : hint_range(0.01, 0.08, 0.001) = 0.035;
/// Samples for outer halo (higher = smoother, costs more)
uniform int outer_samples : hint_range(6, 32, 1) = 14;
/// Falloff for outer halo (higher = tighter to rune, lower = wider diffuse)
uniform float outer_falloff : hint_range(0.3, 3.0, 0.1) = 0.8;
/// Brightness of the outer energy projection
uniform float outer_brightness : hint_range(0.1, 2.0, 0.1) = 0.6;

group_uniforms core;
/// How much the rune center goes toward white (simulates overexposure / energy burn)
uniform float core_hotspot : hint_range(0.0, 1.0, 0.01) = 0.5;
/// Minimum tint on runes even at lowest glow
uniform float min_tint : hint_range(0.0, 0.5, 0.01) = 0.25;

group_uniforms random_mode;
uniform int random_zones : hint_range(4, 24, 1) = 10;
uniform float zone_softness : hint_range(0.5, 3.0, 0.1) = 1.5;


// ── Utilities ────────────────────────────────────────────────

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

// ── Mystic Pulse ─────────────────────────────────────────────

float mystic_pulse(float time) {
	float base = sin(time * 1.0) * 0.5 + 0.5;
	float secondary = sin(time * 2.3 + 0.8) * 0.15;
	float tertiary = sin(time * 0.4 - 1.2) * 0.2 + 0.2;
	float flicker = sin(time * 7.1) * 0.03;
	float combined = clamp(base + secondary + tertiary + flicker, 0.0, 1.0);
	return pow(combined, 1.4);
}

// ── Random Zone Illumination ─────────────────────────────────

float random_zone_value(vec2 uv, float time) {
	vec2 centered = uv - vec2(0.5);
	float angle = atan(centered.y, centered.x);
	float normalized_angle = (angle + 3.14159) / (2.0 * 3.14159);

	float total = 0.0;
	float weight_sum = 0.0;

	for (int i = 0; i < random_zones; i++) {
		float zone_center = (float(i) + 0.5) / float(random_zones);
		float dist = abs(normalized_angle - zone_center);
		dist = min(dist, 1.0 - dist);

		float zone_width = 1.0 / float(random_zones);
		float w = exp(-pow(dist / (zone_width * zone_softness), 2.0));

		float phase = hash(float(i) * 17.31) * 6.2831;
		float speed_var = 0.7 + hash(float(i) * 31.71) * 0.6;
		float zone_val = sin(time * speed_var + phase) * 0.5 + 0.5;
		zone_val = pow(zone_val, 1.8);

		total += zone_val * w;
		weight_sum += w;
	}

	return (weight_sum > 0.0) ? total / weight_sum : 0.0;
}

// ── Blur sampling (reused for both inner and outer passes) ───

float blur_sample(sampler2D tex, vec2 uv, float radius, int samples, float falloff) {
	if (radius <= 0.001) {
		return texture(tex, uv).a;
	}

	float total = 0.0;
	float weight_sum = 0.0;
	float angle_step = 6.2831 / float(samples);

	// Multi-ring sampling: 2 rings for smoother coverage
	for (int ring = 1; ring <= 2; ring++) {
		float ring_radius = radius * (float(ring) / 2.0);
		for (int i = 0; i < samples; i++) {
			float a = float(i) * angle_step + float(ring) * 0.5; // offset rings
			vec2 offset = vec2(cos(a), sin(a)) * ring_radius;
			float s = texture(tex, uv + offset).a;
			float ring_weight = 1.0 / float(ring);
			total += s * ring_weight;
			weight_sum += ring_weight;
		}
	}

	// Center sample (strongest weight)
	total += texture(tex, uv).a * 3.0;
	weight_sum += 3.0;

	float raw = total / weight_sum;
	return pow(raw, falloff);
}


// ── Fragment ─────────────────────────────────────────────────

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float rune_mask = original.a;

	// Effective intensity (idle <-> hover)
	float effective_intensity = mix(idle_intensity, hover_intensity, hover_blend);
	effective_intensity *= intensity_multiplier;

	float t = (TIME + time_seed) * animation_speed;

	// Animation factor
	float anim_factor = 0.0;
	if (glow_mode == 0) {
		anim_factor = mystic_pulse(t);
	} else {
		anim_factor = random_zone_value(UV, t);
	}

	float glow_strength = anim_factor * effective_intensity + residual_intensity * hover_blend + residual_flash;

	// ── Layer 1: OUTER HALO (wide energy projection) ─────────
	// The "backlight" — energy bleeding far around the runes
	// as if a powerful source behind the card pushes light through
	float outer_mask = blur_sample(TEXTURE, UV, outer_radius, outer_samples, outer_falloff);
	// Subtract rune area so outer doesn't double-stack on the rune itself
	float outer_only = max(outer_mask - rune_mask, 0.0);
	vec3 outer_color = glow_color.rgb * outer_only * glow_strength * outer_brightness;
	float outer_alpha = outer_only * glow_strength * outer_brightness * 0.5;

	// ── Layer 2: INNER GLOW (tight bright rim) ───────────────
	// Bright edge hugging the rune contours — the concentrated
	// light right where it passes through the rune cutout
	float inner_mask = blur_sample(TEXTURE, UV, inner_radius, inner_samples, inner_falloff);
	// Keep some overlap with rune for a smooth transition
	float inner_only = max(inner_mask - rune_mask * 0.5, 0.0);
	vec3 inner_color = glow_color.rgb * inner_only * glow_strength * inner_brightness;
	float inner_alpha = inner_only * glow_strength * inner_brightness * 0.7;

	// ── Layer 3: RUNE CORE (overexposed center) ──────────────
	// The rune itself is colored by rarity. At peak intensity,
	// the center burns toward white — like staring into a light source.
	float tint_factor = min_tint + (1.0 - min_tint) * glow_strength;
	vec3 rune_base = glow_color.rgb * tint_factor;

	// Hot center: blend toward white at peak intensity
	float hotspot = glow_strength * core_hotspot;
	vec3 rune_hot = mix(rune_base, vec3(1.0), hotspot);

	vec3 rune_color = rune_hot * rune_mask;
	float rune_alpha = rune_mask * tint_factor;

	// ── Composite all layers (back to front) ─────────────────
	vec3 final_color = outer_color + inner_color + rune_color;

	// Alpha: all layers fade from transparent to opaque with glow strength
	float final_alpha = max(rune_alpha, max(outer_alpha, inner_alpha));
	final_alpha = min(final_alpha, 1.0);

	COLOR = vec4(final_color, final_alpha);
}
