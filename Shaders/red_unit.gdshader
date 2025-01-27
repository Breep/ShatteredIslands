shader_type canvas_item;

uniform vec4 outline_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform bool out_of_bounds = false;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (out_of_bounds) {
		COLOR.rgb = mix(COLOR.rgb, outline_color.rgb, 0.5);
	}
}
