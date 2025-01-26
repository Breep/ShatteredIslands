shader_type canvas_item;

uniform int lightning_number = 5;
uniform vec2 amplitude = vec2(2.0, 1.0);
uniform float offset = 0.45;
uniform float thickness = 0.02;
uniform float speed = 3.0;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_thickness = 0.08;
uniform vec4 glow_color : source_color = vec4(0.2, 0.0, 0.8, 0.0);
uniform float alpha : hint_range(0, 1) = 1.0;

// Personnalisations ajoutées
uniform float noise_frequency = 1.0; // Fréquence du bruit
uniform float noise_intensity = 1.0; // Intensité du bruit
uniform bool use_random_colors = false; // Activer les couleurs aléatoires
uniform vec2 color_variation_range = vec2(0.8, 1.2); // Variation de couleur
uniform bool modulate_alpha_over_time = false; // Moduler la transparence dans le temps

// Y de départ et d'arrivée pour les arcs électriques
uniform float y_start : hint_range(0.0, 1.0) = 0.2; // Coordonnée Y de départ
uniform float y_end : hint_range(0.0, 1.0) = 0.8;   // Coordonnée Y d'arrivée

// Fonction pour générer un nombre pseudo-aléatoire
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Fonction pour tracer une ligne
float plot(vec2 st, float pct, float half_width) {
    return smoothstep(pct - half_width, pct, st.y) -
           smoothstep(pct, pct + half_width, st.y);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1, 311.7)),
              dot(uv, vec2(269.5, 183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    uv *= noise_frequency; // Appliquer la fréquence du bruit
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0, 0.0)), fuv - vec2(0.0, 0.0)),
                   dot(hash22(iuv + vec2(1.0, 0.0)), fuv - vec2(1.0, 0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0, 1.0)), fuv - vec2(0.0, 1.0)),
                   dot(hash22(iuv + vec2(1.0, 1.0)), fuv - vec2(1.0, 1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total * noise_intensity; // Appliquer l'intensité du bruit
}

vec4 randomize_color(vec4 color, vec2 variation_range, vec2 uv) {
    float r = clamp(color.r * mix(variation_range.x, variation_range.y, rand(uv + vec2(0.1, 0.2))), 0.0, 1.0);
    float g = clamp(color.g * mix(variation_range.x, variation_range.y, rand(uv + vec2(0.3, 0.4))), 0.0, 1.0);
    float b = clamp(color.b * mix(variation_range.x, variation_range.y, rand(uv + vec2(0.5, 0.6))), 0.0, 1.0);
    return vec4(r, g, b, color.a);
}

void fragment() {
    vec2 uv = UV;
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    vec2 t;
    float y;
    float pct;
    float buffer;
    float time_mod = modulate_alpha_over_time ? sin(TIME) * 0.5 + 0.5 : 1.0; // Modulation alpha

    for (int i = 0; i < lightning_number; i++) {
        // Calculer le décalage et la courbe
        t = uv * amplitude + vec2(float(i), -float(i)) - TIME * speed;

        // Interpolation entre y_start et y_end
        y = mix(y_start, y_end, uv.x) + fbm(t) * offset;

        pct = plot(uv, y, thickness);
        buffer = plot(uv, y, glow_thickness);

        vec4 line_color = base_color;
        vec4 halo_color = glow_color;

        if (use_random_colors) {
            line_color = randomize_color(base_color, color_variation_range, uv + vec2(float(i)));
            halo_color = randomize_color(glow_color, color_variation_range, uv + vec2(float(i)));
        }

        color += pct * line_color;
        color += buffer * halo_color;
    }

    color.a *= alpha * time_mod;
    COLOR = color;
}
