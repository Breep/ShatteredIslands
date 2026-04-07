shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, shadows_disabled, fog_disabled;

uniform float Intensity : hint_range(0.0, 5.0) = 1.2;
uniform bool Enable_Distortion = true;
uniform float Dist_Zoom_Strenght = 1.0;
uniform float Diost_repeat_strenght = 2.0;
uniform vec2 Distortion_Speed_XY = vec2(0.5, 0.0);
uniform sampler2D Distortion_Texture : source_color;
uniform float Distortion_Attenuation = 5.0;
uniform sampler2D Texture_Add : source_color, hint_default_black;
uniform float Zoom_Strenght = 1.0;
uniform float repeat = 1.0;
uniform vec2 Offset_XY = vec2(-0.625, 0.0);
uniform sampler2D Texture_Main : source_color, filter_linear, repeat_disable;
uniform float Power = 1.3;
uniform sampler2D Texture_Substract : source_color, hint_default_black, filter_linear;
uniform sampler2D Color_1D_Gradient : source_color, repeat_disable;
uniform float Transparency : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// --- Distortion pass (polar UV + noise) ---
	vec2 dist_polar;
	{
		vec2 dir = UV - vec2(0.5);
		float radius = length(dir) * 2.0;
		float angle = atan(dir.y, dir.x) / (PI * 2.0);
		dist_polar = vec2(radius * Dist_Zoom_Strenght, angle * Diost_repeat_strenght);
	}

	vec2 dist_uv = Distortion_Speed_XY * TIME + dist_polar;
	float dist_sample = texture(Distortion_Texture, dist_uv).r;
	float dist_offset = dist_sample / Distortion_Attenuation;

	vec2 uv_distorted = mix(UV, UV + vec2(dist_offset), float(Enable_Distortion));

	// --- Texture Add (radial mask) ---
	float tex_add = texture(Texture_Add, uv_distorted).r;

	// --- Main texture (polar panning) ---
	vec2 main_polar;
	{
		vec2 dir = uv_distorted - vec2(0.5);
		float radius = length(dir) * 2.0;
		float angle = atan(dir.y, dir.x) / (PI * 2.0);
		main_polar = vec2(radius * Zoom_Strenght, angle * repeat);
	}

	vec2 main_uv = Offset_XY + main_polar;
	float tex_main = pow(texture(Texture_Main, main_uv).r, Power);

	// --- Combine & subtract ---
	float tex_sub = texture(Texture_Substract, UV).r;
	float combined = clamp(tex_add + tex_main - tex_sub, 0.0, 1.0);

	// --- Color gradient lookup ---
	vec4 color = texture(Color_1D_Gradient, vec2(combined));

	ALBEDO = color.rgb * Intensity;
	ALPHA = color.a * Transparency;
}
