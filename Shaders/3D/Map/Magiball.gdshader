shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded;

uniform sampler2D tex_frg_2 : source_color;
uniform sampler2D tex_frg_3 : source_color;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.1;
uniform float wave_frequency : hint_range(0.1, 10.0) = 2.0;
uniform float rotation_speed : hint_range(0.0, 2.0) = 0.5;
uniform float halo_size : hint_range(0.0, 1.0) = 0.3;
uniform float halo_intensity : hint_range(0.0, 5.0) = 1.5;

void fragment() {
    float timeFactor = TIME * time_speed;

    // Calcul de l'onde pour déformation UV (ajout de variation en X et Y)
    float waveX = sin(UV.y * wave_frequency + timeFactor) * wave_amplitude;
    float waveY = cos(UV.x * wave_frequency + timeFactor) * wave_amplitude;
    vec2 uv_wave = UV + vec2(waveX, waveY);

    // Rotation des UV
    float angle = rotation_speed * timeFactor;
    mat2 rotationMatrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
    vec2 uv_rotated = rotationMatrix * (uv_wave - vec2(0.5)) + vec2(0.5);

    // Chargement des textures avec UV modifiés
    vec4 tex1 = texture(tex_frg_2, uv_rotated);
    vec4 tex2 = texture(tex_frg_3, uv_rotated);

    // Mélange des textures
    vec4 mixedColor = tex1 * tex2;

    // Suppression des pixels noirs (en supposant qu'un canal alpha est présent)
    if (mixedColor.a < 0.1 || (mixedColor.r + mixedColor.g + mixedColor.b) < 0.1) {
        discard;
    }

    // Variation de couleur avec le temps
    vec3 colorVariation = vec3(0.5 + 0.5 * sin(timeFactor), 0.5 + 0.5 * cos(timeFactor), 1.0);
    vec3 finalColor = mixedColor.rgb * colorVariation;

    // Calcul du Fresnel
    float fresnelPower = 0.7;
    float fresnelEffect = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnelPower);
    float finalAlpha = fresnelEffect * opacity * mixedColor.a;

    // Ajout du halo lumineux
    float distanceToEdge = 1.0 - length(UV - vec2(0.5));
    float haloEffect = smoothstep(halo_size, halo_size * 0.5, distanceToEdge) * halo_intensity;
    finalColor += haloEffect;

    // Sortie
    ALBEDO = finalColor;
    ALPHA = finalAlpha + haloEffect * 0.5;

    // Désactivation de l'objet de base pour ne voir que le shader
    if (finalAlpha < 0.05) {
        discard;
    }
}