shader_type canvas_item;
render_mode blend_add;

uniform sampler2D flare_texture : hint_default_white;
uniform vec4 flare_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float intensity : hint_range(0.0, 10.0) = 1.5;
uniform float scale : hint_range(0.1, 5.0) = 1.0;

void fragment() {
	// Recentre les UV et applique le scale depuis le centre
	vec2 uv = (UV - 0.5) / scale + 0.5;

	// Clip en dehors de [0,1]
	float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);

	vec4 tex = texture(flare_texture, uv);
	COLOR = vec4(flare_color.rgb * intensity, tex.a * inside * intensity);
}
