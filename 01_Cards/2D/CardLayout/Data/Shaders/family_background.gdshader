shader_type canvas_item;

// Family card background: a soft circle filled with a user-made color gradient,
// driven by a noise texture for organic variation. Kept intentionally simple.

// Circle shape (UV space, centered)
uniform float circle_radius : hint_range(0.0, 1.0) = 0.5;
uniform float circle_softness : hint_range(0.0, 0.5) = 0.03;

// Noise texture chosen in the inspector
uniform sampler2D noise_texture : repeat_enable;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;
uniform float noise_strength : hint_range(0.0, 1.0) = 1.0;
uniform float noise_speed : hint_range(0.0, 2.0) = 0.0;

// Custom gradient (make a GradientTexture1D / GradientTexture2D in the inspector)
uniform sampler2D gradient_texture : source_color;

void fragment() {
	// Distance from center → soft circle mask
	float dist = length(UV - vec2(0.5));
	float circle = 1.0 - smoothstep(circle_radius - circle_softness, circle_radius, dist);

	// Sample the noise (optionally scrolling) and remap to [0..1]
	vec2 noise_uv = UV * noise_scale + TIME * noise_speed * vec2(0.3, 0.7);
	float n = texture(noise_texture, noise_uv).r;
	n = mix(0.5, n, noise_strength);

	// Use the noise value as the lookup into the user gradient
	vec4 col = texture(gradient_texture, vec2(n, 0.5));

	col.a *= circle;
	COLOR = col;
}
