shader_type canvas_item;

// ==== FILL CONTROLS ====
uniform bool  auto_animate = true;     // if false, drive fill_progress manually
uniform float fill_speed   = 0.35;     // units: fraction per second
uniform float fill_progress : hint_range(0.0, 1.0) = 0.0; // used when auto_animate = false
uniform bool  horizontal   = true;     // true: fill left->right, false: top->bottom
uniform float edge_softness : hint_range(0.0, 0.25) = 0.08; // soft edge thickness (in UV space)

// ==== GLOW AFTER FULL ====
uniform float glow_strength : hint_range(0.0, 4.0, 0.01) = 0.75; // additive brightness
uniform vec3  glow_color    = vec3(1.0, 0.95, 0.6);              // warm glow
uniform float glow_period   = 1.2;                               // seconds per pulse
uniform float glow_pause    = 0.0;                               // optional pause between pulses
uniform float start_time    = 0.0;                               // sync point (seconds since engine start)

// ==== OPTIONAL COLOR TINT WHILE FILLING ====
uniform bool  tint_while_filling = false;
uniform vec3  filling_tint = vec3(1.0, 0.95, 0.85);
uniform float filling_tint_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    // Base texture/color
    vec4 base = texture(TEXTURE, UV) * COLOR;

    // --- Compute progress 0..1 ---
    float p;
    if (auto_animate) {
        float t = max(0.0, TIME - start_time);
        p = clamp(t * fill_speed, 0.0, 1.0);
    } else {
        p = clamp(fill_progress, 0.0, 1.0);
    }

    // --- Position along fill axis ---
    float pos = horizontal ? UV.x : UV.y;

    // --- Soft edge fill mask (1 = filled, 0 = not yet) ---
    // We want 1.0 for pos <= p, with a feather near the boundary.
    float edge_a = p - edge_softness;
    float edge_b = p;
    float fill_mask = 1.0 - smoothstep(edge_a, edge_b, pos);
    fill_mask = clamp(fill_mask, 0.0, 1.0);

    // Optional warm tint while filling (only on the already-filled area)
    vec3 col = base.rgb;
    if (tint_while_filling && p < 1.0) {
        col = mix(col, filling_tint * col, filling_tint_strength * fill_mask);
    }

    // --- After full: periodic glow (additive) ---
    if (p >= 1.0) {
        // Simple pulse: sin; optional duty-cycle pause using a saw w/ clamp
        float cycle = glow_period + max(0.0, glow_pause);
        float tmod  = mod(max(0.0, TIME - start_time), cycle);
        float pulse;
        if (tmod <= glow_period) {
            // 0..glow_period: smooth sin pulse 0..1
            float ph = tmod / glow_period;                // 0..1
            pulse = 0.5 + 0.5 * sin(6.2831853 * ph);      // 0..1
        } else {
            // pause window: no glow
            pulse = 0.0;
        }

        // Only glow where the sprite has alpha
        float alpha_mask = base.a;
        col += glow_color * glow_strength * pulse * alpha_mask;
    }

    // Keep alpha only where filled (so the unfilled part stays transparent)
    float out_alpha = base.a * fill_mask;

    COLOR = vec4(col, out_alpha);
}
