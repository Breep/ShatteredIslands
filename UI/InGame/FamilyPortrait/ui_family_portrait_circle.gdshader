shader_type canvas_item;

// Texture personnalisée (modifiable dans l'inspecteur)
uniform sampler2D custom_texture : source_color;

// Couleur modifiable
uniform vec4 modulate_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Rayon du cercle (option bonus)
uniform float radius = 0.5;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);

    if (dist > radius) {
        discard;
    }

    vec4 tex_color = texture(custom_texture, UV);
    COLOR = tex_color * modulate_color;
}