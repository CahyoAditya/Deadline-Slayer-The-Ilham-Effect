shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 motion_vector = vec2(0.0, 0.0);
uniform int blur_samples = 8;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);
    
    for (int i = 0; i < blur_samples; i++) {
        float offset = (float(i) / float(blur_samples - 1)) - 0.5;
        color += texture(SCREEN_TEXTURE, uv + (motion_vector * offset));
    }
    
    COLOR = color / float(blur_samples);
}
