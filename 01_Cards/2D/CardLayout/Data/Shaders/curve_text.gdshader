shader_type canvas_item;

uniform float height = 20.0; // Force de la courbe
uniform float frequency = 0.01; // Largeur de la courbe
uniform float phase_shift = 0;

void vertex() {
	float offset = cos(VERTEX.x * frequency + phase_shift) * height;
	VERTEX.y += offset;
}
