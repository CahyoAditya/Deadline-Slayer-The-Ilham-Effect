extends CharacterBody3D

@export var jumpscare_time_limit := 7.0
@export var senter_duration_to_dismiss := 5.0
@export var spawn_points: Array[Vector3] = [
	Vector3(0.0, 0.9, -0.65),    # Behind the player
	Vector3(-1.8, 0.9, 1.2),     # To the right of the player
	Vector3(-1.8, 0.9, -2.5),    # To the left of the player
	Vector3(0.5, 0.9, 1.2)       # Far corner
]

var player: Node3D
var is_active := false
var jumpscare_timer := 0.0
var senter_time_accumulated := 0.0
var is_jumpscaring := false
var spawn_check_timer := 0.0

# Horror audio state
var _last_flash_sound_time := 0.0
var _footstep_timer := 0.0
var _footstep_interval := 3.5
var _breath_interval_timer := 0.0
var _horror_mode_triggered := false  # Extra scary mode when timer < 4s

@onready var detection_area = get_node_or_null("DetectionArea")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_INHERIT
	EventBus.specter_spawned.connect(_on_specter_spawned)
	player = get_tree().get_first_node_in_group("player") as Node3D

func _process(delta: float) -> void:
	if not is_active or player == null or not GameManager.is_playing() or is_jumpscaring:
		$MeshInstance3D.position = Vector3.ZERO
		if GameManager.is_playing() and not is_active and not is_jumpscaring:
			_tick_spawn_timer(delta)
		return

	# Check if player is shining flashlight at the Specter
	var is_flashing = _check_if_flashed()

	if is_flashing:
		senter_time_accumulated += delta
		
		# Visual feedback: vibrate the mesh to show it's taking damage
		var shake_strength = 0.05
		$MeshInstance3D.position = Vector3(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		# Play a hurt/growl sound periodically while being flashed
		_last_flash_sound_time += delta
		if _last_flash_sound_time >= 0.6:
			_last_flash_sound_time = 0.0
			AudioManager.play_sfx("specter_growl", -4.0)
			AudioManager.play_sfx("specter_hurt", -2.0)

		if senter_time_accumulated >= senter_duration_to_dismiss:
			_dismiss_specter()
	else:
		$MeshInstance3D.position = Vector3.ZERO
		_last_flash_sound_time = 0.0

		# Periodic phantom footsteps while active
		_footstep_timer += delta
		if _footstep_timer >= _footstep_interval:
			_footstep_timer = 0.0
			_footstep_interval = randf_range(2.5, 5.0)  # vary the rhythm
			AudioManager.play_sfx("specter_footstep", -6.0)

		# Periodic spectral breathing
		_breath_interval_timer += delta
		if _breath_interval_timer >= randf_range(4.0, 8.0):
			_breath_interval_timer = 0.0
			AudioManager.play_sfx("specter_breath", -8.0)

		# Decrement jumpscare timer only when NOT being flashed
		jumpscare_timer -= delta

		# HORROR MODE: when timer < 4s switch to most intense music + extra moans
		if jumpscare_timer <= 4.0 and not _horror_mode_triggered:
			_horror_mode_triggered = true
			AudioManager.play_music("horror_active")
			AudioManager.play_sfx("specter_moan_aggressive", -2.0)

		if jumpscare_timer <= 0.0:
			_initiate_jumpscare_sequence()
			return

func _tick_spawn_timer(delta: float) -> void:
	var progress := ProgressSystem.get_progress()
	if progress < 25.0:
		spawn_check_timer = 0.0
		return

	spawn_check_timer += delta

	var interval := 30.0
	var chance := 0.30

	if progress >= 80.0:
		interval = 10.0
		chance = 0.75
	elif progress >= 75.0:
		interval = 15.0
		chance = 0.60
	elif progress >= 50.0:
		interval = 20.0
		chance = 0.45

	if spawn_check_timer >= interval:
		spawn_check_timer = 0.0
		if randf() < chance:
			_on_specter_spawned()

func _check_if_flashed() -> bool:
	if player == null:
		return false

	var camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera == null:
		return false

	# 1. Flashlight must be turned on
	var flashlight = camera.get_node_or_null("Flashlight") as SpotLight3D
	if flashlight == null or not flashlight.visible:
		return false

	# 2. Specter must be in front of the camera (FOV check)
	var to_specter = (global_position - camera.global_position).normalized()
	var camera_forward = -camera.global_transform.basis.z.normalized()
	var dot = camera_forward.dot(to_specter)
	
	# dot > 0.96 corresponds to ~16 degrees cone, matching the flashlight's beam
	if dot < 0.96:
		return false

	# 3. Raycast check for line of sight (no obstacles/walls blocking the light)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, global_position)
	query.exclude = [player.get_rid(), get_rid()]
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		return false

	return true

func spawn_in_front_of_player() -> void:
	if player == null:
		return

	var camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera == null:
		return

	var forward_dir = -camera.global_transform.basis.z.normalized()
	
	# Position the ghost body so its head (0.7m above its origin) is directly in front of the camera
	# Adjusted distance to 0.9 meters for a closer look without camera near-plane clipping
	var target_ghost_pos = camera.global_position + forward_dir * 0.9
	target_ghost_pos.y -= 0.85 # Offset head height to align with camera eye level
	
	global_position = target_ghost_pos
	
	# Look at the player camera horizontally (keeping X and Z rotation at 0)
	var look_target = camera.global_position
	look_target.y = global_position.y
	look_at(look_target, Vector3.UP)

	# Disable collision shape so she doesn't physically push/collide with the player
	$CollisionShape3D.disabled = true

	visible = true
	is_active = true
	is_jumpscaring = false
	var progress := ProgressSystem.get_progress()
	var current_limit = 5.0 if progress >= 80.0 else jumpscare_time_limit
	jumpscare_timer = current_limit
	senter_time_accumulated = 0.0
	_horror_mode_triggered = false
	_footstep_timer = 0.0
	_breath_interval_timer = 0.0
	$MeshInstance3D.position = Vector3.ZERO

	# Play immediate intense sounds
	AudioManager.play_sfx("specter_moan_aggressive", 1.0)
	AudioManager.play_music("horror_active")
	EventBus.emit_message_requested("SHE IS RIGHT HERE.")

func _on_specter_spawned() -> void:
	if spawn_points.is_empty():
		return

	# Pick a random spawn point
	var idx = randi() % spawn_points.size()
	global_position = spawn_points[idx]
	
	# Make it face the player
	if player != null:
		var target_pos = player.global_position
		target_pos.y = global_position.y
		if global_position.distance_to(target_pos) > 0.1:
			look_at(target_pos, Vector3.UP)

	# Re-enable collision for normal spawn
	$CollisionShape3D.disabled = false

	visible = true
	is_active = true
	is_jumpscaring = false
	var progress := ProgressSystem.get_progress()
	var current_limit = 5.0 if progress >= 80.0 else jumpscare_time_limit
	jumpscare_timer = current_limit
	senter_time_accumulated = 0.0
	_horror_mode_triggered = false
	_footstep_timer = 0.0
	_breath_interval_timer = 0.0
	$MeshInstance3D.position = Vector3.ZERO

	# ── HORROR AUDIO SEQUENCE ON SPAWN ──────────────────────────────────────
	# 1. Play a moan immediately to announce presence
	AudioManager.play_sfx("specter_moan", -2.0)
	# 2. After 0.8s, switch to the tense horror ambient music
	await get_tree().create_timer(0.8).timeout
	if is_active:  # Guard in case dismissed while waiting
		AudioManager.play_music("horror_ambient")
	EventBus.emit_message_requested("A chilling presence fills the room...")

func _dismiss_specter() -> void:
	visible = false
	is_active = false
	_horror_mode_triggered = false
	$MeshInstance3D.position = Vector3.ZERO

	# Re-enable collision shape on reset
	$CollisionShape3D.disabled = false

	# Play a retreating scream, then switch back to tension music
	AudioManager.play_sfx("specter_dismissed", 0.0)
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_music("tension_loop")
	EventBus.emit_message_requested("The presence has faded.")
	EventBus.emit_specter_sight_broken()

## Step 1 of jumpscare: kill all sound (horror silence technique)
func _initiate_jumpscare_sequence() -> void:
	is_jumpscaring = true
	is_active = false

	# ── PRE-JUMPSCARE SILENCE ─────────────────────────────────────────────
	# The silence before the scream is what makes the scream terrifying.
	await AudioManager.silence_for_jumpscare(_do_jumpscare.bind())

func _do_jumpscare() -> void:
	# Position the ghost head right in front of the camera for an extreme close-up
	if player != null:
		var camera = player.get_node_or_null("Head/Camera3D") as Camera3D
		if camera != null and is_instance_valid(camera):
			var forward_dir = -camera.global_transform.basis.z.normalized()
			
			# Put the ghost head close (0.65 meters) to avoid camera clipping
			var target_ghost_pos = camera.global_position + forward_dir * 0.65
			target_ghost_pos.y -= 0.85 # Offset head height to align with camera eye level
			
			global_position = target_ghost_pos
			
			# Make it look at the camera horizontally (keeping X and Z rotation at 0)
			var look_target = camera.global_position
			look_target.y = global_position.y
			look_at(look_target, Vector3.UP)
			
	# Disable collision shape so she doesn't push the camera / player
	$CollisionShape3D.disabled = true
	visible = true

	# ── JUMPSCARE AUDIO BLAST ─────────────────────────────────────────────
	# Fire both the ghost scream AND the piano dissonance at max volume
	AudioManager.play_sfx("jumpscare_01", 3.0)
	AudioManager.play_stinger("jumpscare_stinger", 4.0)

	EventBus.emit_message_requested("TOO LATE.")
	
	# Camera shake effect
	var camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	if camera != null and is_instance_valid(camera):
		var shake_timer := 1.2
		while shake_timer > 0.0:
			if not is_instance_valid(camera) or not is_inside_tree():
				break
			await get_tree().process_frame
			shake_timer -= get_process_delta_time()
			camera.h_offset = randf_range(-0.15, 0.15)
			camera.v_offset = randf_range(-0.15, 0.15)
		if is_instance_valid(camera):
			camera.h_offset = 0.0
			camera.v_offset = 0.0

	visible = false
	EventBus.emit_specter_caught_player()
