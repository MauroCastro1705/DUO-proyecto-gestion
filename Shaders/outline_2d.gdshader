shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // color del borde
uniform float outline_thickness = 1.0; // en píxeles
uniform bool show_outline = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;

    // Si el pixel actual es transparente, no dibujar nada
    if (alpha == 0.0) {
        discard;
    }

    // Buscar si hay píxeles transparentes alrededor → indica borde
    bool is_outline = false;

    vec2 texel_size = 1.0 / vec2(textureSize(TEXTURE, 0));

    for (float x = -outline_thickness; x <= outline_thickness; x++) {
        for (float y = -outline_thickness; y <= outline_thickness; y++) {
            if (x == 0.0 && y == 0.0) continue;
            vec2 offset = vec2(x, y) * texel_size;
            float sample_alpha = texture(TEXTURE, UV + offset).a;

            if (sample_alpha < 0.1) {
                is_outline = true;
            }
        }
    }

    if (show_outline && is_outline) {
        // Dibuja el contorno encima del sprite
        COLOR = outline_color;
    } else {
        // Dibuja el sprite normal
        COLOR = tex_color;
    }
}
