shader_type canvas_item;

uniform float time_scale = 1.0;
uniform float intensity = 0.15;

//void fragment() {
    //vec2 uv = UV;
//
    //// texture de base (ta barre)
    //vec4 base = texture(TEXTURE, uv);
//
    //// effet vague (liquide)
    //float wave = sin((uv.y * 10.0) + TIME * 4.0 * time_scale) * 0.02;
//
    //// bruit simple
    //float noise = sin((uv.x + TIME) * 10.0) * 0.01;
//
    //float liquid = wave + noise;
//
    //// masque : seulement sur la partie visible (alpha)
    //float mask = base.a;
//
    //// couleur liquide (légèrement différente)
    //vec3 liquid_color = base.rgb + vec3(0.1, 0.2, 0.1) * liquid;
//
    //// mix sans casser la forme
    //vec3 final_color = mix(base.rgb, liquid_color, intensity * mask);
//
    //COLOR = vec4(final_color, base.a);
//}