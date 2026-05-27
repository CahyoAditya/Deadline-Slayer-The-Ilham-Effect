extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_locked := false

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray = $Head/Camera3D/InteractRay

func _ready():
	add_to_group("player")
	EventBus.terminal_opened.connect(_on_terminal_opened)
	EventBus.terminal_closed.connect(_on_terminal_closed)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if input_locked or not GameManager.is_playing():
		return

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
		var target := _find_interactable(collider)
		if target != null:
			target.interact(self)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()

func _process(_delta: float) -> void:
	if input_locked or not GameManager.is_playing():
		EventBus.emit_interact_hint_changed("")
		return

	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		var target := _find_interactable(collider)
		if target != null:
			var hint := "Press E"
			var message = target.get("interact_message")
			if message != null and str(message) != "":
				hint = "Press E - " + str(message)
			EventBus.emit_interact_hint_changed(hint)
			return

	EventBus.emit_interact_hint_changed("")

func _find_interactable(collider: Variant) -> Node:
	if collider == null or not collider is Node:
		return null

	var collider_node := collider as Node
	if collider_node.has_method("interact"):
		return collider_node

	for child in collider_node.get_children():
		if child.has_method("interact"):
			return child

	return null

func _on_terminal_opened() -> void:
	input_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_terminal_closed() -> void:
	input_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
