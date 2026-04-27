shader_type canvas_item;

// Base family color — always required
uniform vec4 base_color : source_color = vec4(1.0, 0.2, 0.1, 1.0);

// Auto-generated variation from base_color
uniform float brightness_variation : hint_range(0.0, 0.5) = 0.2;
uniform float saturation_variation : hint_range(0.0, 0.5) = 0.15;
uniform float hue_variation : hint_range(0.0, 0.2) = 0.05;

// Optional override colors (for multi-family cards)
// color_count = 1: only base_color + auto variations (3 shades generated)
// color_count = 2: base_color + override_color2
// color_count = 3: base_color + override_color2 + override_color3
uniform int color_count : hint_range(1, 3) = 1;
uniform vec4 override_color2 : source_color = vec4(0.1, 0.4, 1.0, 1.0);
uniform vec4 override_color3 : source_color = vec4(0.1, 0.9, 0.3, 1.0);

// Animation speed
uniform float speed : hint_range(0.0, 2.0) = 0.35;

// Blob scale — lower = bigger blobs
uniform float blob_scale : hint_range(1.0, 12.0) = 3.5;

// Domain warp distortion for organic feel
uniform float distortion : hint_range(0.0, 2.0) = 0.6;

// Color blending at cell borders (0 = sharp, 1 = very soft)
uniform float blend_amount : hint_range(0.0, 1.0) = 0.15;

// Liquid overlay distortion
uniform sampler2D liquid_texture : repeat_enable;
uniform float liquid_strength : hint_range(0.0, 1.0) = 0.08;
uniform float liquid_speed : hint_range(0.0, 2.0) = 0.3;
uniform float liquid_scale : hint_range(0.1, 5.0) = 1.0;

// Mask
uniform sampler2D mask_texture : hint_default_white;

// ======================== Color helpers ========================

vec3 rgb_to_hsv(vec3 c) {
	float cmax = max(c.r, max(c.g, c.b));
	float cmin = min(c.r, min(c.g, c.b));
	float delta = cmax - cmin;

	float h = 0.0;
	if (delta > 0.0001) {
		if (cmax == c.r)      h = mod((c.g - c.b) / delta, 6.0);
		else if (cmax == c.g) h = (c.b - c.r) / delta + 2.0;
		else                  h = (c.r - c.g) / delta + 4.0;
		h /= 6.0;
		if (h < 0.0) h += 1.0;
	}
	float s = (cmax > 0.0001) ? delta / cmax : 0.0;
	return vec3(h, s, cmax);
}

vec3 hsv_to_rgb(vec3 hsv) {
	float h = hsv.x * 6.0;
	float s = hsv.y;
	float v = hsv.z;
	float c = v * s;
	float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
	float m = v - c;
	vec3 rgb;
	if      (h < 1.0) rgb = vec3(c, x, 0.0);
	else if (h < 2.0) rgb = vec3(x, c, 0.0);
	else if (h < 3.0) rgb = vec3(0.0, c, x);
	else if (h < 4.0) rgb = vec3(0.0, x, c);
	else if (h < 5.0) rgb = vec3(x, 0.0, c);
	else              rgb = vec3(c, 0.0, x);
	return rgb + m;
}

// Generate a variation of the base color
vec3 vary_color(vec3 base_hsv, float seed) {
	float h_off = (fract(sin(seed * 73.156) * 43758.5453) - 0.5) * 2.0 * hue_variation;
	float s_off = (fract(sin(seed * 91.237) * 23421.6312) - 0.5) * 2.0 * saturation_variation;
	float v_off = (fract(sin(seed * 47.891) * 67823.1234) - 0.5) * 2.0 * brightness_variation;
	vec3 hsv = base_hsv;
	hsv.x = fract(hsv.x + h_off);
	hsv.y = clamp(hsv.y + s_off, 0.0, 1.0);
	hsv.z = clamp(hsv.z + v_off, 0.0, 1.0);
	return hsv_to_rgb(hsv);
}

// ======================== Noise helpers ========================

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)),
			  dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453123);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = dot(hash2(i), vec2(1.0));
	float b = dot(hash2(i + vec2(1.0, 0.0)), vec2(1.0));
	float c = dot(hash2(i + vec2(0.0, 1.0)), vec2(1.0));
	float d = dot(hash2(i + vec2(1.0, 1.0)), vec2(1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Voronoi returning: (dist1, dist2, cell_id_closest, cell_id_second)
vec4 voronoi(vec2 uv, float t) {
	vec2 i_uv = floor(uv);
	vec2 f_uv = fract(uv);

	float min_d1 = 1e10;
	float min_d2 = 1e10;
	float cell_id1 = 0.0;
	float cell_id2 = 0.0;

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = hash2(i_uv + neighbor);
			point = 0.5 + 0.5 * sin(t + 6.2831853 * point);
			vec2 diff = neighbor + point - f_uv;
			float d = dot(diff, diff);

			if (d < min_d1) {
				min_d2 = min_d1;
				cell_id2 = cell_id1;
				min_d1 = d;
				cell_id1 = dot(i_uv + neighbor, vec2(7.0, 113.0));
			} else if (d < min_d2) {
				min_d2 = d;
				cell_id2 = dot(i_uv + neighbor, vec2(7.0, 113.0));
			}
		}
	}
	return vec4(sqrt(min_d1), sqrt(min_d2), cell_id1, cell_id2);
}

// ======================== Color mapping ========================

vec4 id_to_color(float cell_id, vec3 base_hsv) {
	float seed = fract(sin(cell_id) * 43758.5453);

	if (color_count == 1) {
		// Single family: 3 auto-generated shades from base color
		float slot = seed * 3.0;
		// Each cell gets a unique seed → unique variation
		vec3 rgb = vary_color(base_hsv, seed * 100.0 + 1.0);
		return vec4(rgb, 1.0);
	} else if (color_count == 2) {
		return seed < 0.5 ? base_color : override_color2;
	} else {
		if (seed < 0.333) return base_color;
		else if (seed < 0.666) return override_color2;
		else return override_color3;
	}
}

// ======================== Fragment ========================

void fragment() {
	float t = TIME * speed;

	// Liquid distortion: two scrolling samples combined
	vec2 liquid_uv1 = UV * liquid_scale + TIME * liquid_speed * vec2(0.3, 0.7);
	vec2 liquid_uv2 = UV * liquid_scale * 0.8 - TIME * liquid_speed * vec2(0.5, 0.2);
	vec2 liq1 = texture(liquid_texture, liquid_uv1).rg;
	vec2 liq2 = texture(liquid_texture, liquid_uv2).rg;
	vec2 liquid_offset = ((liq1 + liq2) - 1.0) * liquid_strength;

	vec2 base_uv = UV + liquid_offset;

	// Scale to blob space
	vec2 uv = base_uv * blob_scale;

	// Domain warping for organic feel
	vec2 warp = vec2(
		value_noise(uv * 1.2 + t * 0.7),
		value_noise(uv * 1.2 + t * 0.7 + 50.0)
	);
	uv += (warp - 0.5) * distortion;

	// Voronoi
	vec4 vor = voronoi(uv, t);
	vec3 base_hsv = rgb_to_hsv(base_color.rgb);

	vec4 col1 = id_to_color(vor.z, base_hsv);
	vec4 col2 = id_to_color(vor.w, base_hsv);

	// Blend between the two closest cells at the border
	float edge = vor.y - vor.x;
	float blend_zone = max(blend_amount * 0.5, 0.001);
	float t_blend = smoothstep(0.0, blend_zone, edge);
	vec4 col = mix(col2, col1, t_blend);

	// Apply mask: use alpha if available, otherwise fall back to red channel
	vec4 mask_sample = texture(mask_texture, UV);
	float mask_val = min(mask_sample.r, mask_sample.a);
	col.a = mask_val;

	COLOR = col;
}
