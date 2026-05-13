shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size = 1.0;

uniform float aberration_amount = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// --- Chromatic Aberration ---
	// Calculate distance from center for radial aberration
	vec2 center_dist = uv - vec2(0.5);
	float dist_sq = dot(center_dist, center_dist);
	
	vec2 shift = center_dist * aberration_amount * 0.01 * dist_sq;
	
	float r = texture(screen_texture, uv - shift).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv + shift).b;
	vec3 color = vec3(r, g, b);
	
	// --- Film Grain ---
	float noise = (random(uv * grain_size + TIME) - 0.5) * grain_amount;
	color += noise;
	
	// --- Vignette ---
	float d = distance(uv, vec2(0.5, 0.5));
	float vignette = smoothstep(0.8, vignette_intensity * 0.799, d * (vignette_intensity + vignette_opacity));
	color = mix(vignette_color.rgb, color, vignette);
	
	COLOR = vec4(color, 1.0);
}
