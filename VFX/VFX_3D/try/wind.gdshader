shader_type spatial;

uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
uniform float wind_strength = 1.0;
uniform float time_scale = 1.0;
uniform float random_offset = 0.0;
uniform vec3 albedo_color : source_color = vec3(0.8, 0.8, 0.8);

void vertex() {
    float wave = sin(TIME * time_scale + VERTEX.y * 0.5 + random_offset) * wind_strength;
    VERTEX.xyz += wind_direction * wave * 0.05;
}

void fragment() {
    ALBEDO = albedo_color; // applique une couleur basique qui prend la lumière
}
