shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.75, 0.78, 0.82, 1.0);
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.25, 0.28, 0.32, 1.0);

uniform float metallic_strength : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.4;
uniform float shine_strength : hint_range(0.0, 3.0) = 1.2;
uniform float shine_width : hint_range(0.01, 0.5) = 0.12;
uniform float shine_speed : hint_range(-5.0, 5.0) = 0.8;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.15;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float vertical_gradient = UV.y;
	float metal_band = sin((UV.y * 18.0) + (UV.x * 4.0)) * 0.5 + 0.5;
	metal_band = pow(metal_band, contrast);

	float noise = random(UV * 120.0) * noise_strength;

	vec3 metal = mix(shadow_color.rgb, base_color.rgb, vertical_gradient);
	metal = mix(metal, highlight_color.rgb, metal_band * metallic_strength);
	metal += noise;

	float shine_pos = fract(TIME * shine_speed);
	float shine = smoothstep(shine_pos - shine_width, shine_pos, UV.x + UV.y * 0.35);
	shine *= 1.0 - smoothstep(shine_pos, shine_pos + shine_width, UV.x + UV.y * 0.35);

	metal += highlight_color.rgb * shine * shine_strength;

	COLOR = vec4(metal, tex.a * base_color.a);
}