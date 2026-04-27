shader_type canvas_item;

group_uniforms Aspect;
// La couleur principale du bouclier (Bleu cyan par défaut pour le style Diablo)
uniform vec4 shield_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
// Transparence globale de l'effet
uniform float alpha_intensity : hint_range(0.0, 1.0) = 0.5;
// Intensité de la lumière (Glow)
uniform float brightness : hint_range(0.5, 3.0) = 1.2;

group_uniforms Progression;
// Le pourcentage de remplissage du bouclier (0.0 = vide, 1.0 = plein)
uniform float fill_amount : hint_range(0.0, 1.0) = 1.0;
// Douceur du bord de la barre de progression (pour éviter un bord trop net)
uniform float fill_smoothness : hint_range(0.0, 0.1) = 0.02;

group_uniforms Pattern_Energie;
// Texture de bruit pour l'effet de fluide/énergie (NoiseTexture2D Seamless recommandée)
uniform sampler2D energy_noise : repeat_enable, filter_linear_mipmap;
// Échelle du bruit (Zoom)
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;
// Vitesse de défilement de l'énergie
uniform vec2 energy_speed = vec2(0.2, 0.5);

group_uniforms Hologramme;
// Nombre de lignes de balayage horizontales (Scanlines)
uniform float scanline_count : hint_range(0.0, 200.0) = 50.0;
// Vitesse de défilement des scanlines
uniform float scanline_speed : hint_range(-5.0, 5.0) = -2.0;
// Opacité des lignes
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.3;

group_uniforms Pulsation;
// Vitesse de la pulsation globale
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
// Intensité du flash périodique
uniform float pulse_intensity : hint_range(0.0, 0.5) = 0.1;


void fragment() {
	// 1. EFFET D'ÉNERGIE (NOISE)
	vec2 uv_energy = UV * noise_scale;
	vec2 scroll1 = TIME * energy_speed;
	vec2 scroll2 = TIME * energy_speed * vec2(-0.5, 0.8);

	float noise1 = texture(energy_noise, uv_energy + scroll1).r;
	float noise2 = texture(energy_noise, uv_energy + scroll2).r;
	float energy = mix(noise1, noise2, 0.5);

	// 2. EFFET SCANLINES (Hologramme)
	float scanline = sin((UV.y * scanline_count) + (TIME * scanline_speed));
	scanline = smoothstep(0.4, 0.6, scanline);

	// 3. MASQUE DE PROGRESSION (Barre de vie)
	// On calcule si le pixel actuel (UV.x) doit être visible ou non selon fill_amount.
	// smoothstep permet d'avoir un bord légèrement fondu au lieu d'une coupure nette pixelisée.
	float progression_mask = smoothstep(fill_amount, fill_amount - fill_smoothness, UV.x);

	// 4. BORDURE DU REMPLISSAGE (Optionnel : petit liseré brillant au bout de la jauge)
	// On crée une ligne brillante juste à l'endroit où la barre s'arrête
	float edge_glow = 1.0 - abs(UV.x - fill_amount);
	edge_glow = pow(edge_glow, 50.0) * progression_mask; // Puissance élevée pour affiner la ligne

	// 5. EFFET DE BORDURE (Vignette interne à la zone remplie)
	// On veut que l'effet de bord (rim) respecte aussi la progression
	// On calcule la distance par rapport au centre de la BARRE VISIBLE, pas du rectangle total, c'est dur à faire parfaitement en shader pur simple.
	// On va garder une vignette simple mais masquée par la progression.
	float dist_center = distance(UV, vec2(0.5));
	float rim = smoothstep(0.2, 0.8, dist_center);

	// 6. PULSATION
	float pulse = sin(TIME * pulse_speed) * pulse_intensity;

	// --- COMPOSITION FINALE ---

	vec3 base_color = shield_color.rgb * brightness;

	// Ajout du liseré brillant au bout de la barre
	base_color += vec3(1.0) * edge_glow * 2.0;

	// Scanlines
	base_color += shield_color.rgb * scanline * scanline_opacity;

	// Calcul Alpha
	float final_alpha = shield_color.a * alpha_intensity;
	final_alpha *= (energy + 0.3);
	final_alpha += rim * 0.3;
	final_alpha += pulse;

	// APPLICATION DU MASQUE DE PROGRESSION
	// C'est l'étape cruciale : si progression_mask est 0 (partie vide), l'alpha devient 0.
	final_alpha *= progression_mask;

	COLOR = vec4(base_color, clamp(final_alpha, 0.0, 1.0));
}