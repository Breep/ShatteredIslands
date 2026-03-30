shader_type spatial;
render_mode unshaded;

// Paramètres modifiables dans l'inspecteur
uniform vec3 color : source_color = vec3(0.0, 0.8, 1.0);
uniform float thickness : hint_range(0.01, 0.2) = 0.05;
uniform float radius : hint_range(0.1, 0.5) = 0.4;
uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float glow : hint_range(1.0, 10.0) = 2.0;
uniform float glow_min : hint_range(1.0, 10.0) = 2.0;
uniform float glow_max : hint_range(1.0, 10.0) = 2.0;
uniform float fill : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // On centre les UV (de 0:1 à -0.5:0.5)
    vec2 uv = UV - 0.5;
    float dist = length(uv);

    // Glow dynamique (sinus entre glow_min et glow_max)
    float dynamic_glow;
    if (glow_min < glow_max) {
        dynamic_glow = mix(glow_min, glow_max, (sin(TIME * speed) * 0.5 + 0.5));
    } else {
        dynamic_glow = glow;
    }

    // Création de la pulsation avec le temps
    float pulse = sin(TIME * speed) * 0.05;
    float dynamic_radius = radius + pulse;

    // Dessin de l'anneau avec smoothstep pour l'anti-aliasing
    float ring = smoothstep(dynamic_radius, dynamic_radius - thickness, dist) -
                 smoothstep(dynamic_radius - thickness, dynamic_radius - (thickness * 2.0), dist);

    // Disque plein (pour l'état clicked)
    float disc = smoothstep(dynamic_radius, dynamic_radius - thickness, dist);

    // Mélange entre anneau et disque plein selon fill
    float shape = mix(ring, disc, fill);

    // Application de la couleur et de l'opacité
    ALBEDO = color * dynamic_glow;
    ALPHA = shape;
}