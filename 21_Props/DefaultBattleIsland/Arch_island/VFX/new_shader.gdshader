shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D water_texture : source_color, filter_linear_repeat;
uniform sampler2D normal_map : hint_normal, filter_linear_repeat;

uniform vec2 scroll_speed = vec2(0.02, 0.01);
uniform float wave_strength = 0.03;
uniform float wave_speed = 1.5;
uniform float transparency : hint_range(0.0, 1.0) = 0.85;
uniform vec4 tint_color : source_color = vec4(0.4, 0.8, 0.9, 1.0);

void fragment() {
    float time = TIME;
    
    // UV scrolling de base (donne l'impression de mouvement)
    vec2 uv = UV + scroll_speed * time;
    
    // Légère distorsion sinusoïdale des UV (ondulation)
    uv.x += sin(UV.y * 8.0 + time * wave_speed) * wave_strength;
    uv.y += cos(UV.x * 8.0 + time * wave_speed) * wave_strength;
    
    vec4 tex = texture(water_texture, uv);
    
    // Mélange avec la tint pour ajuster la couleur
    ALBEDO = mix(tex.rgb, tint_color.rgb, 0.2);
    
    // Normal map animée (2 couches qui scrollent dans des directions opposées)
    vec2 nUV1 = UV + time * vec2(0.03, 0.02);
    vec2 nUV2 = UV + time * vec2(-0.02, 0.03);
    vec3 n1 = texture(normal_map, nUV1).rgb;
    vec3 n2 = texture(normal_map, nUV2).rgb;
    NORMAL_MAP = normalize(n1 + n2) * 0.5 + 0.5;
    
    METALLIC = 0.1;
    ROUGHNESS = 0.15;   // Basse roughness = reflets brillants
    ALPHA = tex.a * transparency;
}