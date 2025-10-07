// Godot 4.x
shader_type canvas_item;

/* Animate 0 → 1 */
uniform float progress : hint_range(0.0, 1.0) = 0.0;

/* Block size in texture pixels */
uniform vec2 block_px = vec2(16.0, 16.0);

/* Start corner: 0=TopLeft, 1=TopRight, 2=BottomRight, 3=BottomLeft */
uniform int corner : hint_enum("TopLeft,TopRight,BottomRight,BottomLeft") = 0;

/* Soft edge on the random threshold for the current diagonal */
uniform float softness : hint_range(0.0, 0.3) = 0.08;

/* Random seed */
uniform float seed = 1.234;

/* simple hash */
float hash21(vec2 p){
    p = fract(p * vec2(443.897, 441.423) + seed);
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

void fragment() {
    // Work in texture-pixel space
    vec2 tex_px      = UV / TEXTURE_PIXEL_SIZE;
    vec2 tex_size_px = 1.0 / TEXTURE_PIXEL_SIZE;

    // Grid size (# of blocks along each axis)
    vec2 grid = max(floor(tex_size_px / block_px), vec2(1.0));

    // Cell index of this fragment
    vec2 idx = clamp(floor(tex_px / block_px), vec2(0.0), grid - 1.0);

    // Re-index so (0,0) is the chosen corner
    vec2 ic = idx;
    if (corner == 1)      ic.x = (grid.x - 1.0) - ic.x;          // TopRight
    else if (corner == 2) ic = (grid - 1.0) - ic;                // BottomRight
    else if (corner == 3) ic.y = (grid.y - 1.0) - ic.y;          // BottomLeft

    // Diagonal index from the corner (0 .. diag_count-1)
    float diag = ic.x + ic.y;
    float diag_count = grid.x + grid.y - 1.0;

    // Progress across diagonals
    float p = clamp(progress, 0.0, 1.0);
    float diag_f = p * diag_count;
    float current_diag = floor(diag_f);
    float within = fract(diag_f); // 0..1 progress inside the current diagonal

    // Random order within the current diagonal
    float r = hash21(idx);

    float a = 0.0;
    if (diag < current_diag) {
        // fully revealed earlier diagonals
        a = 1.0;
    } else if (diag == current_diag) {
        // reveal a random subset as progress grows
        float th = within; // threshold
        // hard step: float a_step = step(r, th);
        // softened step:
        a = 1.0 - smoothstep(th - softness, th + softness, r);
    } // later diagonals remain hidden

    vec4 col = texture(TEXTURE, UV); // always sample sharp
    COLOR = vec4(col.rgb, col.a * a);
}
