// Magical pulse effect for the intro cinematic crystal: brightness + tint
// breathe on a sine wave, with bright pixels glowing more strongly.
shader_type canvas_item;

uniform float pulse_speed : hint_range(0.05, 3.0) = 0.55;
uniform vec4 magic_color : source_color = vec4(0.55, 0.8, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.65;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.4;
uniform float min_brightness : hint_range(0.5, 1.5) = 0.85;
uniform float max_brightness : hint_range(0.5, 2.5) = 1.35;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float t = 0.5 + 0.5 * sin(TIME * pulse_speed * TAU);

	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 glow = magic_color.rgb * lum * t * glow_strength;

	vec3 tinted = mix(tex.rgb, tex.rgb * magic_color.rgb, t * tint_strength);
	float brightness = mix(min_brightness, max_brightness, t);

	COLOR = vec4(tinted * brightness + glow, tex.a);
}
