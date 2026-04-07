shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D base_texture : source_color;
uniform vec3 fresnel_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float fresnel_power : hint_range(0.1, 10.0) = 2.5;
uniform float fresnel_intensity : hint_range(0.0, 3.0) = 1.5;

void fragment() {
	vec4 tex = texture(base_texture, UV);
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	ALBEDO = tex.rgb + fresnel_color * fresnel * fresnel_intensity;
	EMISSION = fresnel_color * fresnel * fresnel_intensity * 0.6;
}
