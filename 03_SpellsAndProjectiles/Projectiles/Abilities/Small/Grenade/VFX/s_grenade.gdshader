shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

// Placeholder grenade : corps métallique sombre + liseré électrique clignotant.
uniform vec3 body_color : source_color = vec3(0.07, 0.11, 0.10);
uniform vec3 glow_color : source_color = vec3(0.25, 0.9, 1.0);
uniform float blink_speed = 7.0;
uniform float fresnel_power = 2.5;
uniform float glow_strength = 1.4;

void fragment() {
	ALBEDO = body_color;
	METALLIC = 0.6;
	ROUGHNESS = 0.35;

	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), fresnel_power);
	float blink = 0.5 + 0.5 * sin(TIME * blink_speed);
	EMISSION = glow_color * (fresnel * 0.8 + blink * 0.5) * glow_strength;
}
