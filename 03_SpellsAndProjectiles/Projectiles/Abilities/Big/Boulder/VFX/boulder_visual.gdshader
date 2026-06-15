shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0, 128);
uniform float roughness : hint_range(0, 1);
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16, 16);
uniform sampler2D texture_height : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float height_scale : hint_range(-10, 10);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	vec3 height_map = texture(texture_height, UV).rgb;
	// Convertir en échelle de gris pour obtenir la valeur de hauteur
	float h = (height_map.r + height_map.g + height_map.b) / 3.0;
	// Appliquer le déplacement le long des normales du mesh
	VERTEX += NORMAL * h * height_scale;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float roughness_tex = texture(texture_roughness, base_uv).r;
	ROUGHNESS = roughness_tex * roughness;
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}