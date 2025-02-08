shader_type canvas_item;

varying vec2 vertex_pos;

void vertex() {
	vertex_pos = VERTEX;
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 real_uv = vertex_pos / tex_size;
	COLOR.a *= 1.0 - real_uv.x;
}