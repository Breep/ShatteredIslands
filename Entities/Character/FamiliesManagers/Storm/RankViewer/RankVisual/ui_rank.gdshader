shader_type canvas_item;

// --- TEXTURES ---
uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform sampler2D gradient_texture;

// --- ANIMATION ---
uniform float speed = 1.0;
uniform float brilliance = 1.2;

// --- SHADOW (FAKE 3D) ---
uniform vec2 shadow_offset = vec2(15.0, 15.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// --- OUTLINE ---
uniform bool enable_outline = true;
uniform float outline_width = 1.5;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// --- GRADIENT / VISIBILITY TUNING ---
uniform float min_brightness : hint_range(0.0, 2.0) = 0.6;
uniform float max_brightness : hint_range(0.0, 3.0) = 1.8;
uniform float saturation_boost : hint_range(0.0, 2.0) = 1.2;

// --- EMISSION / GLOW ---
uniform float emission_strength : hint_range(0.0, 3.0) = 0.6;


// ============================================================================
// === CONVERSION RGB <-> HSV  (Godot custom implementation)
// ============================================================================

vec3 rgb2hsv(vec3 c) {
    float maxc = max(c.r, max(c.g, c.b));
    float minc = min(c.r, min(c.g, c.b));
    float delta = maxc - minc;

    float h = 0.0;

    if (delta > 0.00001) {
        if (maxc == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (maxc == c.g) {
            h = ((c.b - c.r) / delta) + 2.0;
        } else {
            h = ((c.r - c.g) / delta) + 4.0;
        }
        h /= 6.0;
    }

    float s = (maxc == 0.0) ? 0.0 : (delta / maxc);
    float v = maxc;

    return vec3(h, s, v);
}

vec3 hsv2rgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;

    float i = floor(h);
    float f = h - i;

    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    vec3 outcolor;

    if (i == 0.0) outcolor = vec3(v, t, p);
    else if (i == 1.0) outcolor = vec3(q, v, p);
    else if (i == 2.0) outcolor = vec3(p, v, t);
    else if (i == 3.0) outcolor = vec3(p, q, v);
    else if (i == 4.0) outcolor = vec3(t, p, v);
    else outcolor = vec3(v, p, q);

    return outcolor;
}


// ============================================================================
// === FRAGMENT MAIN
// ============================================================================

void fragment() {
	// 1. Texture de base
	vec4 main_tex = texture(TEXTURE, UV);

	// 2. Bruit animé pour l’effet feu
	vec2 uv_move1 = UV + vec2(TIME * speed * 0.5, TIME * speed);
	vec2 uv_move2 = UV + vec2(-TIME * speed * 0.2, TIME * speed * 0.8);
	float noise = texture(noise_texture, uv_move1).r * texture(noise_texture, uv_move2).r;

	// 3. Dégradé vertical
	vec4 gradient_col = texture(gradient_texture, vec2(1.0 - UV.y, 0.0));

	// 4. Luminosité contrôlée
	vec3 face_color = mix(
		gradient_col.rgb * min_brightness,
		gradient_col.rgb * max_brightness,
		noise
	);

	// 5. Boost de saturation
	vec3 hsv = rgb2hsv(face_color);
	hsv.y = clamp(hsv.y * saturation_boost, 0.0, 1.0);
	face_color = hsv2rgb(hsv);

	// 6. Brillance + emission
	face_color *= brilliance;
	vec3 emission = gradient_col.rgb * noise * emission_strength;

	// 7. Ombre décalée (3D fake)
	vec2 offset_uv = UV - (shadow_offset * TEXTURE_PIXEL_SIZE);
	float shadow_alpha = 0.0;

	if (offset_uv.x >= 0.0 && offset_uv.x <= 1.0 && offset_uv.y >= 0.0 && offset_uv.y <= 1.0) {
		shadow_alpha = texture(TEXTURE, offset_uv).a;
	}

	// 8. Outline
	float outline = 0.0;

	if (enable_outline) {
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				if (x == 0 && y == 0) continue;

				vec2 sample_uv = UV + vec2(float(x), float(y)) * outline_width * TEXTURE_PIXEL_SIZE;

				if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 && sample_uv.y >= 0.0 && sample_uv.y <= 1.0) {
					outline = max(outline, texture(TEXTURE, sample_uv).a);
				}
			}
		}
		outline = clamp(outline - main_tex.a, 0.0, 1.0);
	}

	// 9. Composition finale
	vec3 final_rgb = vec3(0.0);
	float final_alpha = 0.0;

	if (main_tex.a > 0.1) {
		final_rgb = face_color + emission;
		final_alpha = main_tex.a;

	} else if (outline > 0.05) {
		final_rgb = outline_color.rgb;
		final_alpha = outline * outline_color.a;

	} else if (shadow_alpha > 0.1) {
		final_rgb = mix(shadow_color.rgb, gradient_col.rgb * 0.2, 0.2);
		final_alpha = shadow_alpha * shadow_color.a;
	}

	COLOR.rgb = final_rgb;
	COLOR.a = final_alpha;
}
