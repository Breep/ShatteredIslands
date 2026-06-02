shader_type canvas_item;
render_mode unshaded;

// Cadre arrondi avec contour, pour le ColorRect "CadreLevel".
// Fond et contour ont couleur/alpha independants, plus un glow
// optionnel sur le contour (exterieur) et a l'interieur du cadre.

// --- 1. FORME ---
group_uniforms Shape;
// 1.0 = arrondi maximal (cercle/pill sur le cote le plus court).
uniform float CornerRadius : hint_range(0.0, 1.0) = 0.3;
// Marge interne (px) reservee pour laisser respirer le glow exterieur.
// Le glow exterieur est rogne par les bords du ColorRect : augmente cette
// marge (et la taille du rect) si tu veux voir le halo deborder.
uniform float MarginPx : hint_range(0.0, 32.0) = 4.0;
group_uniforms;

// --- 2. FOND ---
group_uniforms Fill;
uniform vec4 FillColor : source_color = vec4(0.16924527, 0.1692453, 0.16924521, 0.60784316);
group_uniforms;

// --- 3. CONTOUR ---
group_uniforms Outline;
uniform vec4 OutlineColor : source_color = vec4(0.9416784, 0.84232056, 0.0, 1.0);
uniform float OutlineThicknessPx : hint_range(0.0, 16.0) = 2.0;
group_uniforms;

// --- 4. GLOW ---
group_uniforms Glow;
uniform bool EnableOutlineGlow = true;
uniform vec4 OutlineGlowColor : source_color = vec4(0.9416784, 0.84232056, 0.0, 1.0);
uniform float OutlineGlowSizePx : hint_range(0.0, 32.0) = 6.0;
uniform float OutlineGlowIntensity : hint_range(0.0, 4.0) = 1.0;

uniform bool EnableInnerGlow = false;
uniform vec4 InnerGlowColor : source_color = vec4(0.9416784, 0.84232056, 0.0, 0.5);
uniform float InnerGlowSizePx : hint_range(0.0, 32.0) = 6.0;
uniform float InnerGlowIntensity : hint_range(0.0, 4.0) = 1.0;

uniform bool GlowPulse = false;
uniform float GlowPulseSpeed : hint_range(0.0, 10.0) = 2.0;
group_uniforms;

float rounded_box_sdf(vec2 center_pos, vec2 half_size, float radius) {
    vec2 q = abs(center_pos) - half_size + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

// Composite alpha "over" : couleur "above" par dessus "below".
vec4 over(vec4 below, vec4 above) {
    float out_a = above.a + below.a * (1.0 - above.a);
    vec3 out_rgb = (above.rgb * above.a + below.rgb * below.a * (1.0 - above.a)) / max(out_a, 0.0001);
    return vec4(out_rgb, out_a);
}

void fragment() {
    vec2 size_px = vec2(1.0 / fwidth(UV.x), 1.0 / fwidth(UV.y));
    vec2 pos_px = UV * size_px;
    vec2 half_size = size_px * 0.5 - MarginPx;
    float radius_px = clamp(CornerRadius * min(half_size.x, half_size.y), 0.0, min(half_size.x, half_size.y));

    float d = rounded_box_sdf(pos_px - size_px * 0.5, half_size, radius_px);
    float aa = 1.0;

    float pulse = GlowPulse ? mix(0.4, 1.0, 0.5 + 0.5 * sin(TIME * GlowPulseSpeed)) : 1.0;

    vec4 col = vec4(0.0);

    // A. GLOW EXTERIEUR (derriere tout le reste)
    if (EnableOutlineGlow && OutlineGlowSizePx > 0.0) {
        float g = 1.0 - smoothstep(0.0, OutlineGlowSizePx, max(d, 0.0));
        g *= OutlineGlowIntensity * pulse;
        vec4 gc = OutlineGlowColor;
        gc.a *= clamp(g, 0.0, 1.0);
        col = over(col, gc);
    }

    // B. FOND (a l'interieur du bord interne du contour)
    float fill_mask = 1.0 - smoothstep(-aa, aa, d + OutlineThicknessPx);
    vec4 fc = FillColor;
    fc.a *= fill_mask;
    col = over(col, fc);

    // C. GLOW INTERIEUR (vers le centre depuis le bord)
    if (EnableInnerGlow && InnerGlowSizePx > 0.0) {
        float ig = 1.0 - smoothstep(0.0, InnerGlowSizePx, max(-d, 0.0));
        ig *= step(d, 0.0) * InnerGlowIntensity * pulse;
        vec4 igc = InnerGlowColor;
        igc.a *= clamp(ig, 0.0, 1.0);
        col = over(col, igc);
    }

    // D. CONTOUR (par dessus)
    float outer_edge = 1.0 - smoothstep(-aa, aa, d);
    float inner_edge = 1.0 - smoothstep(-aa, aa, d + OutlineThicknessPx);
    float outline_mask = clamp(outer_edge - inner_edge, 0.0, 1.0);
    vec4 oc = OutlineColor;
    oc.a *= outline_mask;
    col = over(col, oc);

    COLOR = col;
}
