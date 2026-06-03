shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Dead yellow / sepia tint color
uniform vec4 tint_color : source_color = vec4(0.85, 0.75, 0.45, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.35;

// Color saturation (0.0 is black and white, 1.0 is normal, 2.0 is highly saturated)
uniform float saturation : hint_range(0.0, 2.0) = 0.4;

void fragment() {
    vec4 raw = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Calculate Luma (grayscale brightness)
    float luma = dot(raw.rgb, vec3(0.299, 0.587, 0.114));
    
    // Apply Saturation (mix between grayscale and raw color)
    vec3 sat_color = mix(vec3(luma), raw.rgb, saturation);
    
    // Apply Tint (multiply the saturated color by the tint, mixed by tint_amount)
    vec3 final_color = mix(sat_color, sat_color * tint_color.rgb, tint_amount);
    
    // Increase contrast slightly to make it look 'dead'
    final_color = (final_color - 0.5) * 1.1 + 0.5;
    
    COLOR = vec4(final_color, raw.a);
}
