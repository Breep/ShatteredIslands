shader_type spatial;
render_mode world_vertex_coords;

uniform float pull_intensity : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform sampler2D albedo_texture; // Texture en paramètre
uniform float alpha_value : hint_range(0.0, 1.0) = 1.0; // Opacité réglable

void vertex() {
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 target = vec3(0.0, min(-2.0, NODE_POSITION_WORLD.y) , 0.0);
	vec3 diff = VERTEX - target;
	VERTEX -=  ( diff ) * pull_intensity * (1.0 - (VERTEX.y - NODE_POSITION_WORLD.y + 0.25));
}

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV); // Récupère la couleur de la texture
    ALBEDO = tex_color.rgb; // Applique la couleur de la texture
    ALPHA = tex_color.a * alpha_value; // Transparence basée sur la texture et le paramètre
}