shader_type spatial;

render_mode blend_mix, cull_back, depth_draw_opaque, unshaded;

uniform vec3 ice_color = vec3(0.6, 0.8, 1.0); // couleur de base de la glace
uniform float glow_intensity = 2.0; // force de l’émission
uniform sampler2D noise_texture; // bruit optionnel pour surface irrégulière
uniform float time_speed = 1.0; // vitesse de l’effet animé

void fragment() {
    // Effet de bruit animé sur la glace
    vec2 uv = UV + vec2(TIME * time_speed * 0.1, TIME * time_speed * 0.05);
    float noise = texture(noise_texture, uv).r;

    // Couleur de la glace avec variation
    vec3 base = mix(ice_color * 0.7, ice_color * 1.2, noise);

    ALBEDO = base;
    EMISSION = ice_color * glow_intensity * noise;

    // effet de transparence glacée si besoin
    // ALPHA = 0.8; // décommente si tu veux un effet semi-transparent
}
