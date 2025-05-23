shader_type canvas_item;
render_mode blend_add;

uniform vec2 rect_size = vec2(0.1, 0.1);
uniform vec4 neon_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cian
uniform float glow_strength = 3.0;
uniform float fall_off = 4.0;
uniform float brightness = 1.0;
uniform float flicker_speed = 5.0; // Velocidad del parpadeo
uniform float flicker_intensity = 0.3; // Cuánto varía

void fragment() {
    vec2 uv = UV - vec2(0.5);

    // Punto más cercano dentro del rectángulo
    vec2 closest_point;
    closest_point.x = clamp(uv.x, -rect_size.x, rect_size.x);
    closest_point.y = clamp(uv.y, -rect_size.y, rect_size.y);

    float dist = length(uv - closest_point);

    // Flicker usando una función seno para parpadeo suave
    float flicker = 1.0 + sin(TIME * flicker_speed + uv.x * 10.0) * flicker_intensity;

    float alpha = exp(-dist * fall_off) * glow_strength * brightness * flicker;
    alpha = clamp(alpha, 0.0, 1.0);

    COLOR = neon_color;
    COLOR.a *= alpha;
}
