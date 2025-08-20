shader_type spatial; // Pour Godot 3.x, utilisez spatial. Pour Godot 4, utilisez "shader_type material;"

uniform float amplitude : hint_range(0.0, 2.0) = 0.3;
uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform float noise_scale : hint_range(0.1, 10.0) = 2.0;
uniform float pulse_frequency : hint_range(0.1, 10.0) = 2.0;
uniform float sharpness : hint_range(0.1, 5.0) = 2.0;

float rand(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smootherstep
    float n000 = rand(i + vec3(0.0, 0.0, 0.0));
    float n001 = rand(i + vec3(0.0, 0.0, 1.0));
    float n010 = rand(i + vec3(0.0, 1.0, 0.0));
    float n011 = rand(i + vec3(0.0, 1.0, 1.0));
    float n100 = rand(i + vec3(1.0, 0.0, 0.0));
    float n101 = rand(i + vec3(1.0, 0.0, 1.0));
    float n110 = rand(i + vec3(1.0, 1.0, 0.0));
    float n111 = rand(i + vec3(1.0, 1.0, 1.0));

    return mix(
        mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
        mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
        f.z
    );
}

void vertex() {
    float time = TIME * speed;

    float noise_val = noise(VERTEX * noise_scale + time);

    float pulse = abs(sin(time * pulse_frequency + noise_val * 10.0));
    pulse = pow(pulse, sharpness);

    float displacement = amplitude * noise_val * pulse;

    VERTEX += NORMAL * displacement;
}
