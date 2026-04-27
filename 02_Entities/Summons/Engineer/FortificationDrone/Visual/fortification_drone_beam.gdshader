shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

// Couleurs du beam
uniform vec3 core_color : source_color = vec3(0.3, 0.8, 1.0);
uniform vec3 edge_color : source_color = vec3(0.1, 0.5, 1.0);

// Intensité
uniform float core_intensity : hint_range(0.0, 5.0, 0.1) = 2.0;
uniform float edge_intensity : hint_range(0.0, 5.0, 0.1) = 1.5;

// Forme du beam le long de sa longueur (UV.y = 0 et 1 = extrémités)
uniform float extremity_intensity : hint_range(1.0, 10.0, 0.1) = 3.0;
uniform float center_intensity : hint_range(0.0, 1.0, 0.01) = 0.3;

// Flux d'énergie subtil
uniform float flow_speed : hint_range(0.0, 2.0, 0.01) = 0.4;
uniform float flow_scale : hint_range(1.0, 20.0, 0.1) = 6.0;
uniform float flow_amount : hint_range(0.0, 1.0, 0.01) = 0.15;

// Pulsation douce
uniform float pulse_speed : hint_range(0.0, 3.0, 0.01) = 0.8;
uniform float pulse_amount : hint_range(0.0, 0.5, 0.01) = 0.1;

// Opacité globale
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.8;

// Bruit simple sans texture
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	// UV.x = autour du cylindre (0-1), UV.y = le long du beam (0=drone, 1=cible)
	float along = UV.y;
	float around = UV.x;

	// --- Profil d'intensité le long du beam ---
	// Courbe en U : forte aux extrémités, douce au centre
	float dist_from_center = abs(along - 0.5) * 2.0; // 0 au centre, 1 aux bords
	float length_profile = mix(center_intensity, 1.0, pow(dist_from_center, 1.5));
	// Boost aux extrémités
	float extremity_boost = pow(dist_from_center, 3.0) * extremity_intensity;
	length_profile += extremity_boost;

	// --- Fresnel pour le volume du cylindre ---
	float fresnel = 1.0 - abs(dot(normalize(NORMAL), normalize(VIEW)));
	float edge_mask = pow(fresnel, 1.5);
	float core_mask = 1.0 - edge_mask;

	// --- Flux d'énergie subtil ---
	float flow = noise(vec2(around * flow_scale, along * flow_scale - TIME * flow_speed));
	float flow_factor = 1.0 + (flow * 2.0 - 1.0) * flow_amount;

	// --- Pulsation douce ---
	float pulse = 1.0 + sin(TIME * pulse_speed * PI * 2.0) * pulse_amount;

	// --- Composition finale ---
	vec3 core = core_color * core_intensity * core_mask;
	vec3 edge = edge_color * edge_intensity * edge_mask;
	vec3 beam = (core + edge) * length_profile * flow_factor * pulse;

	ALBEDO = beam;
	ALPHA = alpha * length_profile * clamp(core_mask * 0.7 + edge_mask * 1.0, 0.0, 1.0);
}
