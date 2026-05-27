extends CanvasLayer

@onready var post_process_rect: ColorRect = $PostProcessRect
@onready var distort_rect: ColorRect = $DistortRect

var post_process_mat: ShaderMaterial
var distort_mat: ShaderMaterial

func _ready() -> void:
	if post_process_rect:
		post_process_mat = post_process_rect.material as ShaderMaterial
	if distort_rect:
		distort_mat = distort_rect.material as ShaderMaterial
	
	EventBus.sanity_changed.connect(_on_sanity_changed)
	# Set initial sanity values
	_on_sanity_changed(100.0)

func _on_sanity_changed(sanity: float) -> void:
	# sanity_factor goes from 0.0 (100% sanity) to 1.0 (0% sanity)
	var sanity_factor = 1.0 - (sanity / 100.0)
	
	if post_process_mat:
		# Aberration: 0.1 (sane) to 28.0 (insane) - massive color separation!
		var ab_amount = lerpf(0.1, 28.0, sanity_factor)
		post_process_mat.set_shader_parameter("aberration_amount", ab_amount)
		
		# Vignette Opacity: 0.4 (sane) to 0.98 (insane) - almost black borders!
		var vig_opacity = lerpf(0.4, 0.98, sanity_factor)
		post_process_mat.set_shader_parameter("vignette_opacity", vig_opacity)
		
		# Vignette Intensity: 0.4 (sane) to 0.95 (insane) - closes in on the center of the screen!
		var vig_intensity = lerpf(0.4, 0.95, sanity_factor)
		post_process_mat.set_shader_parameter("vignette_intensity", vig_intensity)
		
		# Film Grain: 0.03 (sane) to 0.5 (insane) - extremely noisy and degraded feed!
		var grain_amt = lerpf(0.03, 0.5, sanity_factor)
		post_process_mat.set_shader_parameter("grain_amount", grain_amt)

	if distort_mat:
		if sanity < 30.0:
			# Map sanity 30..0 to distort_amount 0.0..0.14 - extreme wall-bending distortion!
			var distort_factor = 1.0 - (sanity / 30.0)
			var distort_amt = lerpf(0.0, 0.14, distort_factor)
			distort_mat.set_shader_parameter("distort_amount", distort_amt)
			# Speed up the distortion wave speed as sanity drops (3.0 to 8.0)
			var distort_spd = lerpf(3.0, 8.0, distort_factor)
			distort_mat.set_shader_parameter("distort_speed", distort_spd)
		else:
			distort_mat.set_shader_parameter("distort_amount", 0.0)
