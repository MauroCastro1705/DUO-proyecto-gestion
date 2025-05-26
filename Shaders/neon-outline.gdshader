shader_type canvas_item;
render_mode unshaded;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); 
uniform float glow_size = 5.0;
uniform float glow_strength = 1.5;
uniform sampler2D custom_texture; // sin : source_color

void fragment() {
    vec2 uv = UV;
    float alpha = texture(custom_texture, uv).a;

    float glow = 0.0;
    for (float x = -glow_size; x <= glow_size; x++) {
        for (float y = -glow_size; y <= glow_size; y++) {
            vec2 offset = vec2(x, y) / vec2(textureSize(custom_texture, 0));
            glow += texture(custom_texture, uv + offset).a;
        }
    }

    glow /= pow((glow_size * 2.0 + 1.0), 2.0);

    vec4 base_color = texture(custom_texture, uv);
    vec4 neon = glow_color * glow * glow_strength;
    COLOR = mix(neon, base_color, alpha);
}
