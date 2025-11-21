shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// --- GROUPES DE PARAMÈTRES ---

group_uniforms Textures;
// La texture de bruit qui définit la forme des fissures (Utilisez un Noise Cellular !)
uniform sampler2D crust_noise : filter_linear_mipmap, repeat_enable;
// Échelle de la texture de bruit
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;

group_uniforms Couleurs;
// Couleur de la roche froide (Croûte)
uniform vec3 rock_color : source_color = vec3(0.05, 0.02, 0.02);
// Couleur du magma (Fissures)
uniform vec3 magma_color : source_color = vec3(2.0, 0.5, 0.1); // Valeurs > 1.0 pour HDR
// Intensité de la lumière du magma
uniform float emission_energy : hint_range(0.0, 20.0) = 8.0;

group_uniforms Physique;
// Seuil entre la roche et le magma (contrôle la largeur des fissures)
uniform float crack_width : hint_range(0.0, 1.0) = 0.4;
// Douceur de la transition roche/magma
uniform float crack_softness : hint_range(0.001, 0.5) = 0.05;
// Hauteur du déplacement (le magma est plus bas que la roche)
uniform float displacement_height : hint_range(0.0, 0.5) = 0.1;

group_uniforms Animation;
// Vitesse d'écoulement du magma
uniform float flow_speed : hint_range(0.0, 2.0) = 0.1;
// Effet de pulsation de chaleur
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;

// Variable passée du Vertex au Fragment
varying float height_val;

void vertex() {
	// Animation du magma qui coule lentement
	float time = TIME * flow_speed;
	vec2 scroll = vec2(time * 0.5, time * 0.1);
	
	// On lit le bruit pour savoir où sont les creux (magma) et les bosses (roche)
	float noise = texture(crust_noise, UV * noise_scale + scroll).r;
	
	// On stocke la valeur pour l'utiliser dans le fragment shader
	height_val = noise;
	
	// Déplacement des vertex : La roche reste en haut, le magma creuse le mesh
	// On inverse le bruit pour que les fissures soient "en creux"
	float displacement = smoothstep(crack_width - crack_softness, crack_width + crack_softness, noise);
	
	// On pousse les sommets le long de la normale (la roche ressort)
	VERTEX += NORMAL * displacement * displacement_height;
}

void fragment() {
	// Récupération de la valeur de hauteur calculée dans le vertex
	// On recalcul ici une version plus précise pour la couleur si besoin, 
	// mais utiliser la varying assure la cohérence avec le relief.
	
	// Calcul du masque de mélange Roche vs Magma
	// 0.0 = Magma pur, 1.0 = Roche pure
	float mix_factor = smoothstep(crack_width - crack_softness, crack_width + crack_softness, height_val);
	
	// COULEUR (ALBEDO)
	// Mélange entre la roche sombre et le magma
	vec3 final_albedo = mix(magma_color, rock_color, mix_factor);
	ALBEDO = final_albedo;
	
	// RUGOSITÉ (ROUGHNESS)
	// La roche est très rugueuse (pas de reflets), le magma est liquide (lisse)
	ROUGHNESS = mix(0.1, 1.0, mix_factor);
	
	// ÉMISSION
	// Seul le magma émet de la lumière. La roche est noire.
	// On ajoute une pulsation pour rendre le météore instable
	float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8; // Variation subtile
	
	// On inverse le mix_factor car on veut l'émission là où il y a du magma (0.0)
	float magma_mask = 1.0 - mix_factor;
	
	// Effet Fresnel pour simuler la chaleur atmosphérique sur les bords de la roche
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 rim_heat = vec3(1.0, 0.3, 0.0) * fresnel * 2.0;
	
	// L'émission finale est le magma + la chaleur sur les bords
	EMISSION = (magma_color * emission_energy * magma_mask * pulse) + (rim_heat * mix_factor);
	
	// NORMALE (Détail visuel)
	// Optionnel : on peut ajouter du détail ici, mais le déplacement vertex fait le gros du travail
}