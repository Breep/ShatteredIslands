shader_type canvas_item;

// --- Original controls ---
uniform float frequency : hint_range(0.0, 10.0) = 2.0;       // Legacy/inner glow baseline
uniform float dimLevel : hint_range(0.0, 1.0) = 0.0;         // Alpha outside mask
uniform float brightnessRange : hint_range(0.0, 1.0) = 0.05; // Blink amplitude
uniform float brightnessOffset : hint_range(-0.1, 0.1) = -0.05;
uniform vec3  tintColor : source_color = vec3(1.0);
uniform float tintBrightness : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D maskImage : filter_linear;

// --- New: blink frequency ---
uniform bool  enable_blink = true;
uniform float blink_frequency : hint_range(0.0, 10.0) = 2.0; // Hz (0 = static)
uniform float blink_intensity : hint_range(0.0, 1.0) = 0.25; // Extra pulse

// --- Shine band (sweeping metal ray) ---
uniform bool  enable_shine = true;
uniform float shine_speed = 0.5;                             // Sweeps per second across UV (same as before)
uniform float shine_width : hint_range(0.01, 0.5) = 0.15;
uniform float shine_sharpness : hint_range(1.0, 12.0) = 4.0;
uniform float shine_angle_deg : hint_range(0.0, 180.0) = 35.0;
uniform float shine_intensity : hint_range(0.0, 2.0) = 0.6;
uniform vec2  shine_offset = vec2(0.0, 0.0);

// --- New: pause between two shine passes (in seconds) ---
uniform float shine_pause_between : hint_range(0.0, 5.0) = 0.5;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    COLOR = base;

    // --- Mask ---
    vec4 mask_col = texture(maskImage, UV);
    float mask_brightness = (mask_col.r + mask_col.g + mask_col.b) * (1.0 / 3.0);
    COLOR.a = min(dimLevel + mask_brightness, 1.0);

    // --- Blink (uses new blink_frequency) ---
    float blink = 0.0;
    if (enable_blink) {
        // Legacy inner glow baseline
        float base_wave = brightnessRange * sin(frequency * TIME) + brightnessOffset;
        // Extra pulse driven by blink_frequency
        float f = blink_frequency;
        float pulse = (f > 0.0) ? (0.5 + 0.5 * sin(2.0 * 3.14159265 * f * TIME)) : 0.0;
        blink = base_wave + pulse * blink_intensity;
    }

    // --- Shine band with pause between passes ---
    float shine = 0.0;
    if (enable_shine) {
        float ang = radians(shine_angle_deg);
        vec2 dir = normalize(vec2(cos(ang), sin(ang)));

        // Project UVs and wrap to [0,1]
        float proj = dot(UV + shine_offset, dir) / 1.41421356;
        float u = fract(proj);

        // Base period for one full sweep (seconds per pass)
        float base_period = (abs(shine_speed) > 0.0001) ? (1.0 / abs(shine_speed)) : 1e6;

        // Add a pause after each sweep
        float cycle = base_period + max(shine_pause_between, 0.0);
        float phase = mod(TIME, cycle);
        float gate = (phase < base_period) ? 1.0 : 0.0; // 1 during sweep, 0 during pause

        // When sweeping, center moves uniformly 0..1
        float progress = clamp(phase / base_period, 0.0, 1.0);
        float center = (shine_speed >= 0.0) ? progress : (1.0 - progress);

        // Circular distance on [0,1] so the band stays continuous at wrap
        float diff = abs(u - center);
        float cd = min(diff, 1.0 - diff);

        float edge_in  = shine_width * 0.5;
        float edge_out = edge_in * 1.8;
        float band = 1.0 - smoothstep(edge_in, edge_out, cd);
        shine = pow(max(band, 0.0), shine_sharpness) * shine_intensity * gate;
    }

    float highlight_total = (enable_blink ? blink : 0.0) + (enable_shine ? shine : 0.0);
    vec3 highlight_color = tintColor * tintBrightness;

    COLOR.rgb += mask_brightness * highlight_total * highlight_color;
}
