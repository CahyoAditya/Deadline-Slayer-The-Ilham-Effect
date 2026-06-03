shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// How strong the fisheye distortion is. 
// Positive values bulge outwards (like a CRT), negative values pinch inwards.
uniform float distortion : hint_range(-3.0, 3.0) = 1.0;

// Whether to clip the edges to black when the texture is pulled inward
uniform bool clip_edges = true;

void fragment() {
	// Center the UVs at (0, 0)
	vec2 uv = SCREEN_UV - 0.5;
	
	// Calculate distance from center squared
	float r2 = dot(uv, uv);
	
	// Apply the fisheye distortion factor
	uv = uv * (1.0 + r2 * distortion);
	
	// Shift UVs back to (0,1) range
	vec2 final_uv = uv + 0.5;
	
	if (clip_edges) {
		// If the distorted UV goes out of bounds, render pitch black
		if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
			COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		} else {
			COLOR = texture(SCREEN_TEXTURE, final_uv);
		}
	} else {
		COLOR = texture(SCREEN_TEXTURE, final_uv);
	}
}