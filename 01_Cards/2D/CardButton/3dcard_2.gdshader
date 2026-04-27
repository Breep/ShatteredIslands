shader_type canvas_item;
render_mode unshaded;

// Texture du CanvasGroup (les enfants pré-rendus)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Paramètres passés par le script
uniform vec2 card_size;
uniform vec2 card_center_screen; // Position RÉELLE à l'écran

// Contrôles
uniform float x_rot : hint_range(-60.0, 60.0) = 0.0;
uniform float y_rot : hint_range(-60.0, 60.0) = 0.0;
uniform float fov : hint_range(0.1, 10.0) = 2.0;

void fragment() {
    // 1. Conversion SCREEN_UV -> Coordonnées locales [-0.5, 0.5]
    vec2 pixel_pos = SCREEN_UV / SCREEN_PIXEL_SIZE;
    vec2 uv = (pixel_pos - card_center_screen) / card_size;
    
    // 2. Calcul des angles
    float rad_x = radians(x_rot);
    float rad_y = radians(y_rot);
    
    // 3. Projection Perspective Inverse
    // On calcule où ce pixel "écran" se trouverait sur la carte 3D
    float cos_x = cos(rad_x);
    float sin_x = sin(rad_x);
    float cos_y = cos(rad_y);
    float sin_y = sin(rad_y);
    
    // Facteur de profondeur Z basé sur l'inclinaison combinée
    float z = fov - (uv.x * sin_y - uv.y * sin_x * cos_y);
    
    // Transformation des coordonnées pour simuler la rotation et la perspective
    // On inclut le cosinus pour le raccourcissement réel de la carte
    vec2 projected_uv;
    projected_uv.x = (uv.x * cos_y) * fov / z;
    projected_uv.y = (uv.y * cos_x + uv.x * sin_x * sin_y) * fov / z;
    
    // 4. Clipping (on ne dessine que la carte)
    if (abs(projected_uv.x) > 0.5 || abs(projected_uv.y) > 0.5) {
        discard;
    }
    
    // 5. Retransformation vers le backbuffer
    vec2 target_pixel = (projected_uv * card_size) + card_center_screen;
    vec2 target_screen_uv = target_pixel * SCREEN_PIXEL_SIZE;
    
    // 6. Échantillonnage et correction Alpha 
    vec4 c = textureLod(screen_texture, target_screen_uv, 0.0);
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }
    
    COLOR = c;
    // On multiplie par COLOR pour garder le self_modulate du CanvasGroup
    COLOR *= COLOR; 
}