shader_type canvas_item;

uniform sampler2D vertical_gradient;
uniform sampler2D color_gradient;
uniform float size_effect: hint_range(-5.0, 5.0, 0.05) = 0.1;
uniform float speed = 1.0;
uniform float highlight_strength: hint_range(-4.0, 4.0, 0.05) = 0.5;
uniform bool  color_mode_toggle = false;
uniform bool  is_horizontal = false;
uniform float pause_duration = 0.5;
uniform bool  effect_enabled = true;
uniform float start_time = 0.0; // seconds since engine start

void fragment() {
    vec4 old_color = COLOR;

    if (!effect_enabled) {
        COLOR = old_color;
    } else {
        // TIME is seconds since engine start; align with start_time
        float local_time = max(0.0, TIME - start_time) * abs(speed);
        float effect_cycle_duration = 1.0 + pause_duration;
        float mod_time = mod(local_time, effect_cycle_duration);

        float progress = mod_time / 1.0; // active phase only
        if (mod_time > 1.0) progress = 1.0; // hold during pause
        if (speed < 0.0)    progress = 1.0 - progress; // reverse

        float current_time = mix(0.0 - size_effect, 1.0 + size_effect, progress);
        float effect_lower_bound = current_time - size_effect;
        float effect_upper_bound = current_time + size_effect;
        float position_value = (is_horizontal) ? UV.x : UV.y;

        float effect_distance = smoothstep(effect_lower_bound, current_time, position_value)
                              - smoothstep(current_time, effect_upper_bound, position_value);

        float inner_effect_position = smoothstep(effect_lower_bound, effect_upper_bound, position_value);
        vec2 color_position = (color_mode_toggle) ? vec2(UV.x, inner_effect_position) : vec2(progress);

        vec4 new_color = texture(color_gradient, color_position);
        new_color = mix(old_color, new_color, texture(vertical_gradient, vec2(progress)));

        COLOR.rgb = mix(old_color.rgb, new_color.rgb, vec3(effect_distance * highlight_strength));
    }
}
