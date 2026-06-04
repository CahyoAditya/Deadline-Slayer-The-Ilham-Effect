extends Node

## ShaderController — Drives all post-process shader parameters from game state.
## This is a CHILD Node of PostProcessLayer (which already has PostProcessController).
## Sits on the PostProcessLayer CanvasLayer alongside PostProcessController.
## Controls: VHS_CRT, GLITCH_EFFECT, PS1_PSX_POSTPROCESSING.

# ─── Shader Material References ───────────────────────────────────────────────
var _vhs_mat: ShaderMaterial
var _glitch_mat: ShaderMaterial
var _ps1_post_mat: ShaderMaterial

var _vhs_rect: ColorRect
var _glitch_rect: ColorRect
var _ps1_rect: ColorRect

var _motion_blur_mat: ShaderMaterial
var _target_motion := Vector2.ZERO
var _current_motion := Vector2.ZERO

# ─── State ────────────────────────────────────────────────────────────────────
var _current_preset := "calm"
var _jumpscare_active := false
var _sanity := 100.0

# Presets: [scanlines_opacity, roll, roll_speed, noise_opacity, static_noise, warp_amount,
#           glitch_rate, glitch_power, glitch_speed, ps1_colors, ps1_dither_size]
const PRESETS := {
	"calm": {
		"scanlines_opacity": 0.12, "roll": false, "roll_speed": 4.0,
		"noise_opacity": 0.02, "static_noise": 0.01, "warp_amount": 0.5,
		"grille_opacity": 0.0,
		"glitch_rate": 0.0, "glitch_power": 0.01, "glitch_speed": 3.0,
		"ps1_colors": 14, "ps1_dither_size": 1,
	},
	"tension": {
		"scanlines_opacity": 0.22, "roll": true, "roll_speed": 5.0,
		"noise_opacity": 0.15, "static_noise": 0.04, "warp_amount": 1.0,
		"grille_opacity": 0.08,
		"glitch_rate": 0.05, "glitch_power": 0.02, "glitch_speed": 4.0,
		"ps1_colors": 10, "ps1_dither_size": 1,
	},
	"horror_active": {
		"scanlines_opacity": 0.32, "roll": true, "roll_speed": 12.0,
		"noise_opacity": 0.30, "static_noise": 0.10, "warp_amount": 2.0,
		"grille_opacity": 0.15,
		"glitch_rate": 0.18, "glitch_power": 0.04, "glitch_speed": 7.0,
		"ps1_colors": 6, "ps1_dither_size": 2,
	},
	"jumpscare": {
		"scanlines_opacity": 0.50, "roll": true, "roll_speed": 30.0,
		"noise_opacity": 0.50, "static_noise": 0.20, "warp_amount": 4.0,
		"grille_opacity": 0.25,
		"glitch_rate": 0.85, "glitch_power": 0.09, "glitch_speed": 14.0,
		"ps1_colors": 2, "ps1_dither_size": 3,
	},
	"kernel_panic": {
		"scanlines_opacity": 0.40, "roll": true, "roll_speed": 20.0,
		"noise_opacity": 0.40, "static_noise": 0.20, "warp_amount": 1.5,
		"grille_opacity": 0.20,
		"glitch_rate": 0.45, "glitch_power": 0.06, "glitch_speed": 10.0,
		"ps1_colors": 4, "ps1_dither_size": 2,
	},
	"win": {
		"scanlines_opacity": 0.08, "roll": false, "roll_speed": 4.0,
		"noise_opacity": 0.01, "static_noise": 0.0, "warp_amount": 0.3,
		"grille_opacity": 0.0,
		"glitch_rate": 0.0, "glitch_power": 0.0, "glitch_speed": 2.0,
		"ps1_colors": 16, "ps1_dither_size": 1,
	},
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Grab shader materials from sibling ColorRect nodes
	call_deferred("_init_materials")

	# Connect EventBus signals
	EventBus.specter_spawned.connect(_on_specter_spawned)
	EventBus.specter_sight_broken.connect(_on_specter_dismissed)
	EventBus.jumpscare_fired.connect(_on_jumpscare_fired)
	EventBus.kernel_panic_triggered.connect(_on_kernel_panic)
	EventBus.kernel_panic_resolved.connect(_on_kernel_panic_resolved)
	EventBus.game_won.connect(_on_game_won)
	EventBus.game_lost.connect(_on_game_lost)
	EventBus.sanity_changed.connect(_on_sanity_changed)
	EventBus.camera_moved.connect(_on_camera_moved)

func _init_materials() -> void:
	# Siblings on the parent PostProcessLayer
	var parent := get_parent()
	_vhs_rect = parent.get_node_or_null("VHSRect") as ColorRect
	_glitch_rect = parent.get_node_or_null("GlitchRect") as ColorRect
	_ps1_rect = parent.get_node_or_null("PS1Rect") as ColorRect

	if _vhs_rect:
		_vhs_mat = _vhs_rect.material as ShaderMaterial
	if _glitch_rect:
		_glitch_mat = _glitch_rect.material as ShaderMaterial
	if _ps1_rect:
		_ps1_post_mat = _ps1_rect.material as ShaderMaterial

	# Dynamic Motion Blur Injection
	var bbc = BackBufferCopy.new()
	bbc.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	parent.add_child(bbc)
	
	var mb_rect = ColorRect.new()
	mb_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mb_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_motion_blur_mat = ShaderMaterial.new()
	_motion_blur_mat.shader = load("res://Shaders/MOTION_BLUR.gdshader")
	mb_rect.material = _motion_blur_mat
	parent.add_child(mb_rect)

	_apply_preset("calm", 0.0)

func _on_camera_moved(velocity: Vector2) -> void:
	# Convert pixel velocity to UV velocity (scaling it down significantly)
	_target_motion = velocity * 0.0003

func _process(delta: float) -> void:
	if not _motion_blur_mat:
		return
		
	# Smoothly interpolate current motion to target motion
	_current_motion = _current_motion.lerp(_target_motion, 15.0 * delta)
	
	# Apply to shader
	_motion_blur_mat.set_shader_parameter("motion_vector", _current_motion)
	
	# Decay target motion back to zero rapidly so it only blurs while moving
	_target_motion = _target_motion.lerp(Vector2.ZERO, 30.0 * delta)

# ─── EventBus Handlers ───────────────────────────────────────────────────────

func _on_specter_spawned() -> void:
	_apply_preset("jumpscare", 0.0)
	var t := get_tree().create_timer(0.2)
	t.timeout.connect(func(): _transition_preset("tension", 1.5))
	# Update window title
	DisplayServer.window_set_title("deadline slayer — it knows you're here")

func _on_specter_dismissed() -> void:
	_apply_preset("kernel_panic", 0.0)
	var t := get_tree().create_timer(0.15)
	t.timeout.connect(func(): _transition_preset("tension", 2.0))
	DisplayServer.window_set_title("Deadline Slayer : The Ilham Effect")

func _on_jumpscare_fired(_id: String) -> void:
	if _jumpscare_active:
		return
	_jumpscare_active = true
	_apply_preset("jumpscare", 0.0)
	# Restore after 1.5 seconds (matches camera shake duration)
	await get_tree().create_timer(1.5).timeout
	_jumpscare_active = false
	_transition_preset("tension", 1.0)

func _on_kernel_panic() -> void:
	_transition_preset("kernel_panic", 0.3)
	DisplayServer.window_set_title("KERNEL PANIC — " + Time.get_time_string_from_system())

func _on_kernel_panic_resolved() -> void:
	_transition_preset("tension", 1.5)
	DisplayServer.window_set_title("Deadline Slayer : The Ilham Effect")

func _on_game_won() -> void:
	_transition_preset("win", 2.0)
	DisplayServer.window_set_title("Deadline Slayer — SUBMITTED ✓")

func _on_game_lost(reason: String) -> void:
	match reason:
		"caught_by_specter":
			_apply_preset("jumpscare", 0.0)
			DisplayServer.window_set_title("deadline slayer — you were caught")
		"sanity_depleted":
			DisplayServer.window_set_title("deadline slayer — your mind broke")
		_:
			DisplayServer.window_set_title("deadline slayer — time's up")

func _on_sanity_changed(sanity: float) -> void:
	_sanity = sanity
	# At very low sanity, boost VHS even in calm state
	if _current_preset == "calm" and sanity < 15.0:
		if _vhs_mat:
			_vhs_mat.set_shader_parameter("roll", true)
			_vhs_mat.set_shader_parameter("roll_speed", 3.0)
			_vhs_mat.set_shader_parameter("noise_opacity", 0.08)

# ─── Preset System ────────────────────────────────────────────────────────────

func _transition_preset(preset_name: String, duration: float) -> void:
	_current_preset = preset_name
	if duration <= 0.0:
		_apply_preset(preset_name, 0.0)
		return

	if not PRESETS.has(preset_name):
		return

	var target: Dictionary = PRESETS[preset_name]
	var t := create_tween().set_parallel(true)

	if _vhs_mat:
		t.tween_method(
			func(v: float) -> void: _vhs_mat.set_shader_parameter("scanlines_opacity", v),
			_vhs_mat.get_shader_parameter("scanlines_opacity") if _vhs_mat.get_shader_parameter("scanlines_opacity") != null else 0.12,
			target["scanlines_opacity"], duration
		)
		t.tween_method(
			func(v: float) -> void: _vhs_mat.set_shader_parameter("noise_opacity", v),
			_vhs_mat.get_shader_parameter("noise_opacity") if _vhs_mat.get_shader_parameter("noise_opacity") != null else 0.02,
			target["noise_opacity"], duration
		)
		t.tween_method(
			func(v: float) -> void: _vhs_mat.set_shader_parameter("static_noise_intensity", v),
			_vhs_mat.get_shader_parameter("static_noise_intensity") if _vhs_mat.get_shader_parameter("static_noise_intensity") != null else 0.01,
			target["static_noise"], duration
		)
		t.tween_method(
			func(v: float) -> void: _vhs_mat.set_shader_parameter("warp_amount", v),
			_vhs_mat.get_shader_parameter("warp_amount") if _vhs_mat.get_shader_parameter("warp_amount") != null else 0.5,
			target["warp_amount"], duration * 0.5
		)
		# Non-tweenable: set immediately
		_vhs_mat.set_shader_parameter("roll", target["roll"])
		_vhs_mat.set_shader_parameter("roll_speed", target["roll_speed"])
		_vhs_mat.set_shader_parameter("grille_opacity", target["grille_opacity"])

	if _glitch_mat:
		t.tween_method(
			func(v: float) -> void: _glitch_mat.set_shader_parameter("shake_rate", v),
			_glitch_mat.get_shader_parameter("shake_rate") if _glitch_mat.get_shader_parameter("shake_rate") != null else 0.0,
			target["glitch_rate"], duration
		)
		t.tween_method(
			func(v: float) -> void: _glitch_mat.set_shader_parameter("shake_power", v),
			_glitch_mat.get_shader_parameter("shake_power") if _glitch_mat.get_shader_parameter("shake_power") != null else 0.01,
			target["glitch_power"], duration
		)
		_glitch_mat.set_shader_parameter("shake_speed", target["glitch_speed"])

	if _ps1_post_mat:
		_ps1_post_mat.set_shader_parameter("colors", target["ps1_colors"])
		_ps1_post_mat.set_shader_parameter("dither_size", target["ps1_dither_size"])

func _apply_preset(preset_name: String, _duration: float) -> void:
	_current_preset = preset_name
	if not PRESETS.has(preset_name):
		return
	var p: Dictionary = PRESETS[preset_name]

	if _vhs_mat:
		_vhs_mat.set_shader_parameter("scanlines_opacity", p["scanlines_opacity"])
		_vhs_mat.set_shader_parameter("roll", p["roll"])
		_vhs_mat.set_shader_parameter("roll_speed", p["roll_speed"])
		_vhs_mat.set_shader_parameter("noise_opacity", p["noise_opacity"])
		_vhs_mat.set_shader_parameter("static_noise_intensity", p["static_noise"])
		_vhs_mat.set_shader_parameter("warp_amount", p["warp_amount"])
		_vhs_mat.set_shader_parameter("grille_opacity", p["grille_opacity"])

	if _glitch_mat:
		_glitch_mat.set_shader_parameter("shake_rate", p["glitch_rate"])
		_glitch_mat.set_shader_parameter("shake_power", p["glitch_power"])
		_glitch_mat.set_shader_parameter("shake_speed", p["glitch_speed"])

	if _ps1_post_mat:
		_ps1_post_mat.set_shader_parameter("colors", p["ps1_colors"])
		_ps1_post_mat.set_shader_parameter("dither_size", p["ps1_dither_size"])
