shader_type spatial;

// On active la transparence (blend_mix + depth_draw_opaque désactivé)
// et on désactive le backface culling pour voir la cascade des deux côtés
render_mode blend_mix, depth_draw_opaque, cull_disabled;

// --- UNIFORMS (paramètres réglables dans l'inspecteur) ---

// La texture d'écume (PNG avec alpha)
uniform sampler2D foam_texture : source_color, filter_linear_mipmap, repeat_enable;

// Vitesse de défilement vertical (valeur négative = vers le bas)
uniform float scroll_speed : hint_range(-5.0, 5.0) = -0.8;

// Combien de fois la texture se répète (tiling)
uniform vec2 uv_scale = vec2(1.0, 2.0);

// Couleur de teinte appliquée à l'écume
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.9);

// Intensité globale de l'opacité
uniform float alpha_intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // On scale les UV pour contrôler le tiling
    vec2 scrolled_uv = UV * uv_scale;

    // On décale les UV sur l'axe Y avec le temps
    // TIME est une variable intégrée de Godot qui s'incrémente chaque frame
    scrolled_uv.y += TIME * scroll_speed;

    // On sample la texture d'écume aux UV décalés
    vec4 foam = texture(foam_texture, scrolled_uv);

    // On applique la couleur de teinte
    ALBEDO = foam.rgb * foam_color.rgb;

    // L'alpha final = alpha de la texture × alpha de la teinte × intensité
    ALPHA = foam.a * foam_color.a * alpha_intensity;

    // Optionnel : un peu de rugosité pour capter la lumière
    ROUGHNESS = 0.6;
    METALLIC = 0.0;
}
