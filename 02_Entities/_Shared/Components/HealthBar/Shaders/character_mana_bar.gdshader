shader_type canvas_item;
render_mode unshaded;

// --- 1. DONNÉES DE VIE ---
group_uniforms Health_Data;
uniform float HealthAmount : hint_range(0,1) = 0.6;
uniform float MaxHealth = 2500.0;
group_uniforms;

// --- 2. COULEURS ---
group_uniforms Colors;
uniform vec4 HealthColor : source_color = vec4(0.11, 0.64, 0.08, 1.0);
uniform vec4 BackgroundColor : source_color = vec4(0.15, 0.15, 0.15, 0.8); // Alpha baissé par défaut
group_uniforms;

// --- 3. EFFET SHIMMER ---
group_uniforms Shimmer_Effect;
uniform bool EnableShimmer = true;
uniform float ShimmerSpeed : hint_range(0.0, 5.0) = 1.5;
uniform float ShimmerStrength : hint_range(0.0, 1.0) = 0.3;
uniform float VolumeStrength : hint_range(0.0, 1.0) = 0.4;
group_uniforms;

// --- 4. LIGNES GRILLE (NETTES) ---
group_uniforms Lines_Grid;
uniform vec4 LineColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float LineThickness : hint_range(0.1, 5.0) = 1.0; // Épaisseur en pixels
uniform float Height100 : hint_range(0.0, 1.0) = 0.25;
uniform float Height500 : hint_range(0.0, 1.0) = 0.50;
group_uniforms;

// --- 5. BORDURE (NETTE) ---
group_uniforms Border;
uniform vec4 BorderColor : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform float BorderThicknessPx : hint_range(0.0, 10.0) = 2.0; // Épaisseur en pixels
group_uniforms;

// --- 6. COINS ARRONDIS (NOUVEAU !) ---
group_uniforms Corners;
// Le rayon de l'arrondi. Attention, c'est en espace UV (0.0 à 0.5 max).
// Des valeurs très petites (ex: 0.05) suffisent souvent.
uniform float CornerRadius : hint_range(0.0, 0.5) = 0.05;
group_uniforms;

// Fonction utilitaire pour calculer une boîte arrondie
float rounded_box_sdf(vec2 center_pos, vec2 size, float radius) {
    return length(max(abs(center_pos) - size + radius, 0.0)) - radius;
}

void fragment() {
    // Calcul de la largeur d'un pixel en UV pour la netteté
    vec2 pixel_size_uv = vec2(fwidth(UV.x), fwidth(UV.y));
    float aa_width = pixel_size_uv.x;

    // ===============================
    // A. REMPLISSAGE & VOLUME
    // ===============================
    // Remplissage net
    float fill_mask = 1.0 - smoothstep(HealthAmount - aa_width, HealthAmount + aa_width, UV.x);

    // Gradient de volume
    float internal_gradient = 1.0 - abs(UV.y - 0.5) * VolumeStrength * 2.0;
    vec3 health_rgb = HealthColor.rgb * internal_gradient;

    // ===============================
    // B. SHIMMER
    // ===============================
    if (EnableShimmer) {
        float shimmer_pos = fract((TIME * ShimmerSpeed) - UV.x * 0.5 - UV.y * 0.2);
        float shimmer_mask = smoothstep(0.45, 0.5, shimmer_pos) * (1.0 - smoothstep(0.5, 0.55, shimmer_pos));
        health_rgb += vec3(1.0) * shimmer_mask * ShimmerStrength;
    }

    vec4 final_health_color = vec4(health_rgb, HealthColor.a);
    vec4 final_color = mix(BackgroundColor, final_health_color, fill_mask);

    // ===============================
    // C. LIGNES GRILLE (CORRIGÉES POUR ÊTRE NETTES)
    // ===============================
    float hp_at_pixel = UV.x * MaxHealth;
    // On calcule la demi-largeur voulue en PV
    float half_line_width_hp = (LineThickness * pixel_size_uv.x * MaxHealth) * 0.5;
    // Zone d'anti-aliasing (1 pixel de large en PV)
    float aa_hp = pixel_size_uv.x * MaxHealth;

    // Calcul 500
    float dist_500 = abs(mod(hp_at_pixel, 500.0));
    dist_500 = min(dist_500, 500.0 - dist_500);
    // Coupure nette avec anti-aliasing sur le bord seulement
    float mask_500 = smoothstep(half_line_width_hp + aa_hp, half_line_width_hp, dist_500);

    // Calcul 100
    float dist_100 = abs(mod(hp_at_pixel, 100.0));
    dist_100 = min(dist_100, 100.0 - dist_100);
    float mask_100 = smoothstep(half_line_width_hp + aa_hp, half_line_width_hp, dist_100);

    float line_alpha = 0.0;
    if (mask_500 > 0.01 && UV.y < Height500) line_alpha = mask_500;
    else if (mask_100 > 0.01 && UV.y < Height100) line_alpha = mask_100;
    if (UV.x < aa_width * 2.0) line_alpha = 0.0;

    final_color = mix(final_color, LineColor, line_alpha);

    // ===============================
    // D. BORDURE (CORRIGÉE POUR ÊTRE NETTE)
    // ===============================
    // On convertit l'épaisseur en pixels vers l'espace UV
    vec2 border_width_uv = BorderThicknessPx * pixel_size_uv;

    // Utilisation de step() pour une coupure parfaitement nette (pixelisée)
    // Si vous voulez un léger lissage, remplacez step(a,b) par smoothstep(a, a+pixel_size_uv.x, b)
    float border_mask_x = step(UV.x, border_width_uv.x) + step(1.0 - border_width_uv.x, UV.x);
    float border_mask_y = step(UV.y, border_width_uv.y) + step(1.0 - border_width_uv.y, UV.y);
    float final_border_mask = clamp(border_mask_x + border_mask_y, 0.0, 1.0);

    final_color = mix(final_color, BorderColor, final_border_mask);

    // ===============================
    // E. COINS ARRONDIS (DÉCOUPE FINALE)
    // ===============================
    // On centre les UVs de -0.5 à 0.5
    vec2 centered_uv = UV - 0.5;
    // On calcule la distance par rapport à une boîte arrondie théorique
    // On réduit légèrement la taille (0.5 - aa) pour que l'anti-aliasing ne touche pas le bord du ColorRect
    float dist_to_rounded_edge = rounded_box_sdf(centered_uv, vec2(0.5 - pixel_size_uv.x), CornerRadius);

    // Création du masque : 1 à l'intérieur, 0 à l'extérieur, avec un bord lisse
    // On utilise une largeur d'anti-aliasing moyenne entre X et Y
    float avg_aa = (pixel_size_uv.x + pixel_size_uv.y) * 0.5;
    float rounded_mask = 1.0 - smoothstep(0.0, avg_aa * 1.5, dist_to_rounded_edge);

    // On multiplie l'alpha final par ce masque pour découper les coins
    final_color.a *= rounded_mask;

    // SORTIE FINALE
    COLOR = final_color;
}