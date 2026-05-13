extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var walk_anim_name: String = ""

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray = $Head/Camera3D/InteractRay
@onready var anim_player: AnimationPlayer = $Head/Camera3D/AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Auto-detect the walking animation name from the library
	if anim_player.has_animation_library("walking"):
		var walk_lib = anim_player.get_animation_library("walking")
		var anim_list = walk_lib.get_animation_list()
		if anim_list.size() > 0:
			walk_anim_name = "walking/" + anim_list[0]
			
			# Fix the rotation issue programmatically!
			# The animation is read-only, so we duplicate it, disable the bad track, and save it back.
			var fixed_anim = anim_player.get_animation(walk_anim_name).duplicate()
			for i in range(fixed_anim.get_track_count()):
				var path = str(fixed_anim.track_get_path(i))
				# The root track (path ".") is what forces the character to lie down
				if path == "." or path == "Armature" or path.begins_with("Armature:"):
					fixed_anim.track_set_enabled(i, false)
			
			# Add the fixed animation back to the player
			var new_lib = AnimationLibrary.new()
			new_lib.add_animation(anim_list[0], fixed_anim)
			anim_player.remove_animation_library("walking")
			anim_player.add_animation_library("walking", new_lib)
			
			print("Walking animation loaded and rotation fixed: ", walk_anim_name)
		else:
			print("Walking animation library found but it contains no animations!")
	else:
		print("ERROR: Walking animation library not found on AnimationPlayer!")

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		# Search for an Interactable component or directly call interact
		if collider.has_method("interact"):
			collider.interact(self)
		else:
			for child in collider.get_children():
				if child.has_method("interact"):
					child.interact(self)
					break

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Play walking animation when moving
		if walk_anim_name != "" and anim_player.current_animation != walk_anim_name:
			anim_player.play(walk_anim_name)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		# Stop walking animation when idle
		if walk_anim_name != "" and anim_player.current_animation == walk_anim_name:
			anim_player.stop()

	move_and_slide()
