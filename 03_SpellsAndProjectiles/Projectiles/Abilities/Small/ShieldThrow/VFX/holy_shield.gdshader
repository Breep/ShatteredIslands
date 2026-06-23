shader_type spatial;
render_mode cull_disabled, blend_mix;

uniform sampler2D base_texture : source_color, filter_linear_mipmap;
uniform vec3 holy_color : source_color = vec3(1.0, 0.85, 0.3);
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5;
uniform float fresnel_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.5;
uniform float base_brightness : hint_range(0.0, 2.0) = 0.3;

#include "res://22_VFX/VFX_3D/Import/Shared/fresnel.gdshaderinc"

void fragment() {
	vec4 tex = texture(base_texture, UV);

	// Fresnel rim glow
	float f = fresnel(fresnel_power, NORMAL, VIEW);

	// Pulsating effect
	float pulse = 1.0 + pulse_intensity * sin(TIME * pulse_speed);

	// Mix base texture with holy golden tint
	vec3 tinted_base = mix(tex.rgb, tex.rgb * holy_color, base_brightness);

	// Holy rim glow
	vec3 rim_glow = holy_color * f * fresnel_intensity * pulse;

	ALBEDO = tinted_base + rim_glow * 0.3;
	EMISSION = rim_glow * emission_strength;
	ALPHA = tex.a;
}
