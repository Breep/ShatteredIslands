shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec4 base_color : source_color = vec4(0.30, 0.40, 0.50, 1.0);
uniform float border_thickness : hint_range(0.0, 0.5) = 0.1;
uniform float center_falloff : hint_range(0.1, 5.0) = 2.0;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.02;
uniform bool use_hexagonal_shape = false;
uniform bool is_pointy_top = true;

float hex_distance(vec2 p) {
	p = abs(p);
	if (is_pointy_top) {
		return max(p.x, p.x * 0.5 + p.y * 0.866025);
	} else {
		return max(p.y, p.y * 0.5 + p.x * 0.866025);
	}
}

void fragment() {
	vec2 p = UV - vec2(0.5);
	float d;

	if (use_hexagonal_shape) {
		d = hex_distance(p) * 2.0;
	} else {
		d = length(p) * 2.0;
	}

	float border = smoothstep(1.0 - border_thickness - edge_softness, 1.0 - border_thickness, d);
	float gradient = pow(clamp(d, 0.0, 1.0), center_falloff);

	float final_alpha = max(border, gradient);

	ALBEDO = base_color.rgb;
	ALPHA = final_alpha * base_color.a;
}
