shader_type canvas_item;

uniform float height = 20.0; // Force de la courbe
uniform float frequency = 0.01; // Largeur de la courbe
uniform float phase_shift = 0;

void vertex() {
	// Calcule l'offset vertical en fonction de la position horizontale
	// On centre l'effet pour que le milieu du texte soit le point le plus haut
	float offset = cos(VERTEX.x * frequency + phase_shift) * height;
	VERTEX.y += offset;
}
