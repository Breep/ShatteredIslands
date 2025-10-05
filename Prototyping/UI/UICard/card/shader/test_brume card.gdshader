shader_type canvas_item;
render_mode blend_add; // Glow-like (additif)

uniform sampler2D noise_tex;
uniform float intensity : hint_range(0.0, 5.0) = 1.5;
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float distortion : hint_range(0.0, 1.0) = 0.3;
uniform float glow_strength : hint_range(0.0, 3.0) = 1.0; // Force du halo
uniform vec4 aura_color : source_color = vec4(0.6, 0.0, 0.8, 1.0); // Violet démoniaque

void fragment() {
    // Distorsion multi-couche pour turbulence
    vec2 d_uv1 = UV * 2.0 + vec2(TIME * 0.1, TIME * 0.15);
    vec2 d_vec1 = texture(noise_tex, d_uv1).rg - 0.5;

    vec2 d_uv2 = UV * 3.0 + vec2(-TIME * 0.2, TIME * 0.25);
    vec2 d_vec2 = texture(noise_tex, d_uv2).rg - 0.5;

    vec2 distortion_vec = (d_vec1 + d_vec2) * distortion;

    // UV final du bruit
    vec2 noise_uv = UV + distortion_vec + vec2(0.0, -TIME * speed);
    vec4 noise = texture(noise_tex, noise_uv);

    // Texture de base comme masque
    vec4 base_tex = texture(TEXTURE, UV);

    // Alpha animé
    float alpha = clamp(base_tex.r * noise.r * intensity, 0.0, 1.0);
    alpha = pow(alpha, 2.0);

    // Halo additif
    vec3 glow = aura_color.rgb * noise.r * glow_strength;

    // Sortie finale : aura + halo lumineux
    COLOR = vec4(glow, alpha * aura_color.a);
}
