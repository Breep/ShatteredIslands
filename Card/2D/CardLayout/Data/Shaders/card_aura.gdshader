shader_type canvas_item;
render_mode blend_add;

uniform sampler2D aura_texture : hint_default_white;
uniform vec4 aura_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float intensity : hint_range(0.0, 10.0) = 1.5;
// 1.0 = texture remplit le rect, 0.5 = texture 2x plus petite (plus de marge)
uniform float base_scale : hint_range(0.1, 2.0) = 0.6;

// Animation de pulsation
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.2;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.08;

// Rotation lente de la texture
uniform float rotation_speed : hint_range(0.0, 3.0) = 0.3;

// Deuxième layer pour épaissir l'aura
uniform float layer2_scale_offset : hint_range(0.0, 0.5) = 0.1;
uniform float layer2_rotation_offset : hint_range(0.0, 6.28) = 2.1;

// Fondu sur les bords du rect
uniform float edge_fade : hint_range(0.0, 0.5) = 0.15;

vec2 rotate_uv(vec2 uv, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

float sample_layer(sampler2D tex, vec2 base_uv, float scale, float angle) {
	// scale < 1.0 = texture plus petite, scale > 1.0 = texture plus grande
	vec2 uv = rotate_uv(base_uv, angle) * (1.0 / scale) + 0.5;

	float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
	vec4 t = texture(tex, uv);
	float mask = dot(t.rgb, vec3(0.299, 0.587, 0.114)) * t.a * inside;
	return mask;
}

void fragment() {
	vec2 centered = UV - 0.5;

	float pulse = sin(TIME * pulse_speed) * pulse_amount;
	float scale1 = base_scale + pulse;
	float scale2 = base_scale + layer2_scale_offset - pulse;

	float angle1 = TIME * rotation_speed;
	float angle2 = TIME * rotation_speed * -0.7 + layer2_rotation_offset;

	float mask1 = sample_layer(aura_texture, centered, scale1, angle1);
	float mask2 = sample_layer(aura_texture, centered, scale2, angle2);

	float mask = max(mask1, mask2);

	// Fondu doux sur les bords du rect
	float fade = smoothstep(0.0, edge_fade, UV.x)
	           * smoothstep(0.0, edge_fade, 1.0 - UV.x)
	           * smoothstep(0.0, edge_fade, UV.y)
	           * smoothstep(0.0, edge_fade, 1.0 - UV.y);

	mask *= fade;

	COLOR = vec4(aura_color.rgb * mask * intensity, mask * intensity);
}
