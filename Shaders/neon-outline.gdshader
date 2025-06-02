shader_type canvas_item;
render_mode unshaded;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float glow_size = 5.0;
uniform float glow_strength = 1.5;
uniform sampler2D custom_texture;

void fragment() {
    vec2 uv = UV;
    vec2 tex_size = vec2(textureSize(custom_texture, 0));
    
    float alpha_center = texture(custom_texture, uv).a;
    vec4 base_color = texture(custom_texture, uv);

    float glow = 0.0;
    float samples = 0.0;

    for (float x = -glow_size; x <= glow_size; x++) {
        for (float y = -glow_size; y <= glow_size; y++) {
            vec2 offset = vec2(x, y) / tex_size;
            float sample_alpha = texture(custom_texture, uv + offset).a;
            glow += sample_alpha;
            samples += 1.0;
        }
    }

    glow /= samples;

    vec4 glow_effect = glow_color * glow * glow_strength;
    glow_effect.a *= glow;

    // Si el pixel es opaco, solo mostramos el color original.
    // Si el pixel es transparente, aplicamos el efecto glow.
    COLOR = mix(glow_effect, base_color, step(0.01, alpha_center));
}
