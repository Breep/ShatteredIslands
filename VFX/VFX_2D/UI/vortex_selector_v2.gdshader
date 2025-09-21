// Shader pour Godot 4.x - Version finale "Sceau Démoniaque" + Zoom au centre
shader_type canvas_item;

// Paramètres de base de l'ondulation
uniform float speed = 0.2;
uniform vec2 wave_frequency = vec2(5.0, 3.0);
uniform float wave_amplitude = 0.05;
uniform sampler2D noise_texture;
uniform sampler2D color_gradient;

// Paramètres pour l'effet de souris
uniform vec2 mouse_pos;
uniform vec2 node_size;
uniform float effect_radius = 0.25;
uniform float repulsion_force = 0.2;
uniform float glow_intensity = 0.3;

// Paramètres spécifiques à la forme du sceau
uniform float seal_points = 5.0;
uniform float seal_sharpness = 0.15;

// NOUVEAU : Paramètre pour le zoom
uniform float max_zoom = 1.5; // Zoom de 150% au centre


void fragment() {
    vec2 normalized_mouse = mouse_pos / node_size;
    vec2 uv = UV;
    vec2 center = vec2(0.5); // Le centre de la texture

    // --- NOUVEAU : CALCUL DE L'EFFET DE ZOOM ---
    // On calcule la distance de la souris au centre du rectangle
    float dist_mouse_to_center = distance(normalized_mouse, center);

    // On calcule un niveau de zoom de 0.0 (souris au bord) à 1.0 (souris au centre)
    // 0.7 est une bonne approximation de la distance max (du centre à un coin)
    float zoom_level = 1.0 - smoothstep(0.0, 0.7, dist_mouse_to_center);

    // On convertit ce niveau en facteur de zoom réel (de 1.0 à max_zoom)
    float zoom_factor = 1.0 + (max_zoom - 1.0) * zoom_level;

    // On applique le zoom aux coordonnées UV. C'est l'effet "loupe".
    // Diviser par le facteur de zoom rapproche les coordonnées du centre.
    uv = (uv - center) / zoom_factor + center;


    // --- CALCUL DE L'EFFET DE LA SOURIS (SCEAU) ---
    // MODIFIÉ : On utilise les UV zoomés pour que l'effet de sceau soit aussi affecté
    vec2 direction = uv - normalized_mouse;
    float distance_to_mouse = length(direction);
    float angle = atan(direction.y, direction.x);
    float star_shape = sin(angle * seal_points) * seal_sharpness;
    float shaped_distance = distance_to_mouse - star_shape;
    float effect_strength = 1.0 - smoothstep(0.0, effect_radius, shaped_distance);


    // --- APPLICATION DES EFFETS ---
    // MODIFIÉ : On utilise les UV zoomés pour l'ondulation de base
    float wave = sin(uv.y * wave_frequency.y + TIME * speed) + cos(uv.x * wave_frequency.x + TIME * speed * 0.7);
    vec2 offset_uv = uv + wave * wave_amplitude;

    vec2 direction_from_mouse = normalize(direction);
    offset_uv += direction_from_mouse * effect_strength * repulsion_force;

    float noise_value = texture(noise_texture, offset_uv).r;

    noise_value = clamp(noise_value + effect_strength * glow_intensity, 0.0, 1.0);

    vec4 final_color = texture(color_gradient, vec2(noise_value, 0.5));

    COLOR = final_color;
}