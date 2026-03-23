shader_type canvas_item;
render_mode unshaded;

// --- 1. DONNÉES DE VIE ---
group_uniforms Health_Data;
uniform float HealthAmount : hint_range(0,1) = 0.6;
uniform float MaxHealth = 2500.0;
group_uniforms;

// --- 2. COULEURS ---
group_uniforms Colors;
uniform vec4 HealthColor : source_color = vec4(0.11, 0.64, 0.08, 1.0);
uniform vec4 BackgroundColor : source_color = vec4(0.15, 0.15, 0.15, 0.8);
group_uniforms;

// --- 3. EFFET SHIMMER ---
group_uniforms Shimmer_Effect;
uniform bool EnableShimmer = true;
uniform float ShimmerSpeed : hint_range(0.0, 5.0) = 1.5;
uniform float ShimmerStrength : hint_range(0.0, 1.0) = 0.3;
uniform float VolumeStrength : hint_range(0.0, 1.0) = 0.4;
group_uniforms;

// --- 4. LIGNES GRILLE (PARAMÉTRABLES & DÉSACTIVABLES) ---
group_uniforms Lines_Grid;
uniform bool ShowGrid = true; // <--- L'INTERRUPTEUR EST ICI
uniform vec4 LineColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Palier X (Petit palier)
uniform float Step_X_Value = 250.0;
uniform float Step_X_Height : hint_range(0.0, 1.0) = 0.25;
uniform float Step_X_Thickness : hint_range(0.1, 10.0) = 1.0;

// Palier Y (Grand palier)
uniform float Step_Y_Value = 1000.0;
uniform float Step_Y_Height : hint_range(0.0, 1.0) = 0.50;
uniform float Step_Y_Thickness : hint_range(0.1, 10.0) = 2.5;
group_uniforms;

// --- 5. BORDURE ---
group_uniforms Border;
uniform vec4 BorderColor : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform float BorderThicknessPx : hint_range(0.0, 10.0) = 2.0;
group_uniforms;

// --- 6. COINS ARRONDIS ---
group_uniforms Corners;
uniform float CornerRadius : hint_range(0.0, 0.5) = 0.05;
group_uniforms;

float rounded_box_sdf(vec2 center_pos, vec2 size, float radius) {
    return length(max(abs(center_pos) - size + radius, 0.0)) - radius;
}

void fragment() {
    vec2 pixel_size_uv = vec2(fwidth(UV.x), fwidth(UV.y));
    float aa_width = pixel_size_uv.x;

    // A. REMPLISSAGE
    float fill_mask = 1.0 - smoothstep(HealthAmount - aa_width, HealthAmount + aa_width, UV.x);
    float internal_gradient = 1.0 - abs(UV.y - 0.5) * VolumeStrength * 2.0;
    vec3 health_rgb = HealthColor.rgb * internal_gradient;

    // B. SHIMMER
    if (EnableShimmer) {
        float shimmer_pos = fract((TIME * ShimmerSpeed) - UV.x * 0.5 - UV.y * 0.2);
        float shimmer_mask = smoothstep(0.45, 0.5, shimmer_pos) * (1.0 - smoothstep(0.5, 0.55, shimmer_pos));
        health_rgb += vec3(1.0) * shimmer_mask * ShimmerStrength;
    }

    vec4 final_health_color = vec4(health_rgb, HealthColor.a);
    vec4 final_color = mix(BackgroundColor, final_health_color, fill_mask);

    // C. LIGNES GRILLE (Conditionnelle)
    if (ShowGrid) {
        float hp_at_pixel = UV.x * MaxHealth;
        float aa_hp = pixel_size_uv.x * MaxHealth;

        // Calcul Palier Y
        float half_line_Y = (Step_Y_Thickness * pixel_size_uv.x * MaxHealth) * 0.5;
        float dist_Y = abs(mod(hp_at_pixel, Step_Y_Value));
        dist_Y = min(dist_Y, Step_Y_Value - dist_Y);
        float mask_Y = smoothstep(half_line_Y + aa_hp, half_line_Y, dist_Y);

        // Calcul Palier X
        float half_line_X = (Step_X_Thickness * pixel_size_uv.x * MaxHealth) * 0.5;
        float dist_X = abs(mod(hp_at_pixel, Step_X_Value));
        dist_X = min(dist_X, Step_X_Value - dist_X);
        float mask_X = smoothstep(half_line_X + aa_hp, half_line_X, dist_X);

        float line_alpha = 0.0;
        if (mask_Y > 0.01 && UV.y < Step_Y_Height) {
            line_alpha = mask_Y;
        } 
        else if (mask_X > 0.01 && UV.y < Step_X_Height) {
            line_alpha = mask_X;
        }
        
        if (UV.x < aa_width * 2.0) line_alpha = 0.0;
        final_color = mix(final_color, LineColor, line_alpha);
    }

    // D. BORDURE
    vec2 border_width_uv = BorderThicknessPx * pixel_size_uv;
    float border_mask_x = step(UV.x, border_width_uv.x) + step(1.0 - border_width_uv.x, UV.x);
    float border_mask_y = step(UV.y, border_width_uv.y) + step(1.0 - border_width_uv.y, UV.y);
    float final_border_mask = clamp(border_mask_x + border_mask_y, 0.0, 1.0);
    final_color = mix(final_color, BorderColor, final_border_mask);

    // E. COINS ARRONDIS
    vec2 centered_uv = UV - 0.5;
    float dist_to_rounded_edge = rounded_box_sdf(centered_uv, vec2(0.5 - pixel_size_uv.x), CornerRadius);
    float avg_aa = (pixel_size_uv.x + pixel_size_uv.y) * 0.5;
    float rounded_mask = 1.0 - smoothstep(0.0, avg_aa * 1.5, dist_to_rounded_edge);

    final_color.a *= rounded_mask;
    COLOR = final_color;
}