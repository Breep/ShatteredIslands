shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Paramètres de rotation
uniform float x_rot : hint_range(-80.0, 80.0) = 0.0;
uniform float y_rot : hint_range(-80.0, 80.0) = 0.0;
uniform float fov : hint_range(1, 179) = 90;

// Infos envoyées par le script (Calibration automatique)
uniform vec2 card_center_screen; // Centre global de la carte en pixels
uniform vec2 card_size_screen;   // Taille réelle de la carte à l'écran (pixels)

void fragment() {
	// 1. Calcul du ratio d'aspect interne pour que X et Y réagissent pareil
	float aspect = card_size_screen.y / card_size_screen.x;
	
	// 2. Conversion du pixel écran actuel en coordonnée locale de carte [-0.5, 0.5]
	vec2 screen_pixel_pos = SCREEN_UV / SCREEN_PIXEL_SIZE;
	vec2 uv = (screen_pixel_pos - card_center_screen) / card_size_screen;
	uv.y *= aspect; // Correction de l'étirement vertical

	// 3. Matrice de rotation 3D inverse (Logique Hei)
	float sin_y = sin(radians(y_rot));
	float cos_y = cos(radians(y_rot));
	float sin_x = sin(radians(x_rot));
	float cos_x = cos(radians(x_rot));

	mat3 inv_rot_mat;
	inv_rot_mat[0] = vec3(cos_y, 0.0, -sin_y);
	inv_rot_mat[1] = vec3(sin_y * sin_x, cos_x, cos_y * sin_x);
	inv_rot_mat[2] = vec3(sin_y * cos_x, -sin_x, cos_y * cos_x);

	float t = tan(radians(fov) / 2.0);
	vec3 p = inv_rot_mat * vec3(uv, 0.5 / t);
	
	// Projection perspective
	float v = (0.5 / t) + 0.5;
	float z_factor = inv_rot_mat[2].z;
	vec2 projected_uv = (p.xy / p.z) * v * z_factor;
	vec2 offset_origin = v * inv_rot_mat[2].xy;
	
	// 4. Clipping : On ne dessine que la forme de la carte
	vec2 final_uv = projected_uv - offset_origin;
	if (abs(final_uv.x) > 0.5 || abs(final_uv.y / aspect) > 0.5) {
		discard;
	}

	// 5. Retransformation vers SCREEN_UV pour lire le backbuffer
	vec2 target_pixel = (final_uv.x * card_size_screen.x + card_center_screen.x) * vec2(1.0, 0.0) +
	                    (final_uv.y / aspect * card_size_screen.y + card_center_screen.y) * vec2(0.0, 1.0);
	
	vec4 c = textureLod(screen_texture, target_pixel * SCREEN_PIXEL_SIZE, 0.0);

	// 6. Correction Alpha Cruciale (CanvasGroup prémultiplié) 
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR = c * COLOR;
}