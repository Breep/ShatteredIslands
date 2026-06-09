shader_type spatial;

// Rendu transparent, non affecté par la lumière (unshaded) pour des couleurs pures
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

// --- Paramètres ---
uniform vec4 dash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.0); // Transparent par défaut
uniform float speed : hint_range(-10.0, 10.0, 0.1) = 2.0;
uniform float thickness : hint_range(0.001, 0.25, 0.001) = 0.05;
uniform float dash_frequency : hint_range(1.0, 50.0, 1.0) = 15.0;

// Nouveau paramètre : Rayon des coins (0.0 = carré, 0.5 = cercle)
uniform float corner_radius : hint_range(0.0, 0.5, 0.01) = 0.1;

// --- Fonction SDF (Signed Distance Field) ---
// Calcule la distance exacte entre le pixel actuel et le bord d'un rectangle arrondi.
float sd_rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    // Centrer les UV (-0.5 à 0.5)
    vec2 p = UV - vec2(0.5);

    // --- 1. Masque de la forme et de l'épaisseur ---
    // Calcul de la distance par rapport au bord (taille de la boîte = 0.5)
    float dist = sd_rounded_box(p, vec2(0.5), corner_radius);
    
    // On est sur la bordure si on est à l'intérieur de la forme (dist <= 0.0)
    // ET qu'on ne dépasse pas l'épaisseur voulue (dist > -thickness)
    // Utilisation de smoothstep au lieu de step pour un léger anti-aliasing
    float outer_edge = 1.0 - smoothstep(-0.005, 0.005, dist);
    float inner_edge = smoothstep(-thickness - 0.005, -thickness + 0.005, dist);
    float is_border = outer_edge * inner_edge;

    // --- 2. Calcul des pointillés animés ---
    // On utilise l'angle polaire pour projeter les pointillés tout autour du centre
    float angle = atan(p.y, p.x);
    // Normalisation de l'angle entre 0.0 et 1.0
    float perimeter_coord = (angle + PI) / (2.0 * PI);

    // Application de la fréquence et du temps pour l'animation
    float current_dash_pos = perimeter_coord * dash_frequency + TIME * speed;
    float is_dash = step(0.5, fract(current_dash_pos));

    // --- 3. Combinaison et Affichage ---
    // Le pixel est coloré si on est sur la bordure ET sur un tiret
    float final_mask = is_border * is_dash;

    if (final_mask > 0.5) {
        ALBEDO = dash_color.rgb;
        ALPHA = dash_color.a;
    } else {
        ALBEDO = bg_color.rgb;
        ALPHA = bg_color.a;
    }
}