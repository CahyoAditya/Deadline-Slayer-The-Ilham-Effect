extends CharacterBody3D

@export var move_speed := 1.4
@export var catch_distance := 1.25
@export var spawn_distance := 8.0
@export var grace_seconds := 4.0

var player: Node3D
var is_active := false
var grace_time_left := 0.0
var has_caught_player := false

@onready var detection_area: Area3D = $DetectionArea

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	EventBus.specter_spawned.connect(_on_specter_spawned)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	player = get_tree().get_first_node_in_group("player") as Node3D

func _physics_process(delta: float) -> void:
	if not is_active or player == null or not GameManager.is_playing():
		velocity = Vector3.ZERO
		return

	if grace_time_left > 0.0:
		grace_time_left -= delta
		velocity = Vector3.ZERO
		return

	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()

	_try_catch_player()

func _on_specter_spawned() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var behind_player := player.global_transform.basis.z.normalized()
		global_position = player.global_position + behind_player * spawn_distance
		global_position.y = player.global_position.y

	visible = true
	is_active = true
	has_caught_player = false
	grace_time_left = grace_seconds
	process_mode = Node.PROCESS_MODE_INHERIT
	EventBus.emit_message_requested("The Specter has entered the room.")

func _try_catch_player() -> void:
	if has_caught_player or player == null or grace_time_left > 0.0:
		return

	var specter_xz := Vector2(global_position.x, global_position.z)
	var player_xz := Vector2(player.global_position.x, player.global_position.z)
	var vertical_distance := absf(global_position.y - player.global_position.y)

	if specter_xz.distance_to(player_xz) <= catch_distance and vertical_distance <= 2.0:
		has_caught_player = true
		EventBus.emit_specter_caught_player()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_try_catch_player()
