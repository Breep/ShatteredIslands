shader_type canvas_item;

// Paramètres uniformes pour contrôler les valeurs du shader
uniform float time_speed_1 : hint_range(0.0, 100.0) = 80.0; // Vitesse de l'oscillation en X
uniform float time_speed_2 : hint_range(0.0, 100.0) = 50.0; // Vitesse de l'oscillation en Y
uniform float uv_offset_1 : hint_range(-1.0, 1.0) = 0.1; // Amplitude du décalage de l'UV en X
uniform float uv_offset_2 : hint_range(-1.0, 1.0) = 0.02; // Amplitude du décalage de l'UV en Y

// Paramètre pour la couleur (valeurs entre 0.0 et 1.0)
uniform vec4 custom_color = vec4(1.0, 1.0, 1.0, 1.0); // Couleur personnalisée, par défaut blanche

void fragment() {
    // Calcul des coordonnées UV avec les oscillations temporelles
    vec2 uv = vec2(UV.x - sin(TIME * time_speed_1) * uv_offset_1,
                   UV.y - sin(TIME * time_speed_2) * uv_offset_2);

    // Applique la couleur personnalisée, en utilisant la texture comme influence
    COLOR = texture(TEXTURE, uv) * custom_color;
}
