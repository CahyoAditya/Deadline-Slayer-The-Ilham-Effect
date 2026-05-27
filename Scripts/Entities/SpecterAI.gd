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

@onready var detection_area = get_node_or_null("DetectionArea")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_INHERIT
	EventBus.specter_spawned.connect(_on_specter_spawned)
	player = get_tree().get_first_node_in_group("player") as Node3D

func _process(delta: float) -> void:
	if not is_active or player == null or not GameManager.is_playing() or is_jumpscaring:
		$MeshInstance3D.position = Vector3.ZERO
		return

	# Decrement jumpscare timer
	jumpscare_timer -= delta
	if jumpscare_timer <= 0.0:
		_trigger_jumpscare()
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

		if senter_time_accumulated >= senter_duration_to_dismiss:
			_dismiss_specter()
	else:
		$MeshInstance3D.position = Vector3.ZERO

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

	visible = true
	is_active = true
	is_jumpscaring = false
	jumpscare_timer = jumpscare_time_limit
	senter_time_accumulated = 0.0
	$MeshInstance3D.position = Vector3.ZERO

	# Play horror ambient music
	AudioManager.play_music("horror_ambient")
	EventBus.emit_message_requested("A chilling presence fills the room...")

func _dismiss_specter() -> void:
	visible = false
	is_active = false
	$MeshInstance3D.position = Vector3.ZERO
	# Return to tension/normal music
	AudioManager.play_music("tension_loop")
	EventBus.emit_message_requested("The presence has faded.")

func _trigger_jumpscare() -> void:
	is_jumpscaring = true
	AudioManager.play_sfx("jumpscare_01")
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

	is_active = false
	visible = false
	EventBus.emit_specter_caught_player()
