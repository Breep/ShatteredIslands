// Shader pour Godot 4.x
shader_type canvas_item;

// Paramètres qu'on pourra régler depuis l'Inspecteur
uniform float speed = 0.2;
uniform vec2 wave_frequency = vec2(5.0, 3.0);
uniform float wave_amplitude = 0.05;

// Les textures qu'on va fournir au shader
uniform sampler2D noise_texture;
uniform sampler2D color_gradient;


void fragment() {
    // UV sont les coordonnées du pixel actuel (de 0.0 à 1.0)
    vec2 uv = UV;

    // 1. Calcul de l'ondulation
    // On combine deux vagues (sin et cos) pour un mouvement moins répétitif
    // TIME est une variable intégrée qui représente le temps qui passe
    float wave = sin(uv.y * wave_frequency.y + TIME * speed) + cos(uv.x * wave_frequency.x + TIME * speed * 0.7);

    // 2. On applique l'ondulation comme un décalage (offset)
    // L'amplitude contrôle la "force" de la distorsion
    vec2 offset_uv = uv + wave * wave_amplitude;

    // 3. On lit la texture de bruit avec les coordonnées déformées
    // On ne prend que la valeur du canal rouge (.r) car le bruit est en niveaux de gris
    float noise_value = texture(noise_texture, offset_uv).r;

    // 4. On utilise cette valeur de bruit pour lire la couleur dans le dégradé
    // Un dégradé 1D est une ligne de couleurs. On utilise la valeur de bruit
    // pour se déplacer le long de cette ligne (coordonnée X).
    vec4 final_color = texture(color_gradient, vec2(noise_value, 0.5));

    // On applique la couleur finale au pixel
    COLOR = final_color;
}