shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

group_uniforms Perspective_Controls;
uniform float x_rot : hint_range(-80.0, 80.0) = 0.0;
uniform float y_rot : hint_range(-80.0, 80.0) = 0.0;
uniform float fov : hint_range(1, 179) = 90;

group_uniforms Calibration;
// IMPORTANT : Ajustez 'rect_scale' jusqu'à ce que la carte ne "glisse" plus.
// C'est le ratio (Taille de la carte / Taille du Viewport).
uniform vec2 rect_scale = vec2(0.3, 0.3);
uniform vec2 size_ratio = vec2(1.0, 1.4); // Ratio largeur/hauteur de la carte

void fragment() {
	// 1. On recrée l'espace local de la carte (-0.5 à 0.5)
	// On applique le size_ratio pour que la rotation X et Y soit symétrique
	vec2 uv = (UV - 0.5) * size_ratio;

	// 2. Logique "Hei" : Matrice de rotation 3D inverse
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
	vec2 projected_uv = (p.xy / p.z) * v * inv_rot_mat[2].z;
	vec2 offset_origin = v * inv_rot_mat[2].xy;

	// 3. Clipping (on ne dessine que la forme de la carte)
	vec2 card_uv = projected_uv - offset_origin + 0.5;
	if (card_uv.x < 0.0 || card_uv.x > 1.0 || card_uv.y < 0.0 || card_uv.y > 1.0) {
		discard;
	}

	// 4. Calcul du décalage Écran
	// C'est ici qu'on corrige l'étirement : on multiplie le delta local par 'rect_scale'
	// pour qu'il corresponde à des pixels écran réels.
	vec2 uv_delta = (projected_uv - offset_origin - (UV - 0.5) * size_ratio) * rect_scale;

	vec4 c = textureLod(screen_texture, SCREEN_UV + uv_delta, 0.0);

	// 5. Correction Alpha et assombrissement
	// Le CanvasGroup est en alpha prémultiplié. On divise par l'alpha pour
	// retrouver les couleurs originales avant de ré-appliquer le modulate.
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR = c * COLOR;
}
