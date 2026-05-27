shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float distort_amount : hint_range(0.0, 0.1) = 0.0;
uniform float distort_speed = 3.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	if (distort_amount > 0.0) {
		// Apply sinusoidal wave distortion
		uv.x += sin(uv.y * 20.0 + TIME * distort_speed) * distort_amount;
		uv.y += cos(uv.x * 20.0 + TIME * distort_speed) * distort_amount;
	}
	COLOR = texture(screen_texture, uv);
}
