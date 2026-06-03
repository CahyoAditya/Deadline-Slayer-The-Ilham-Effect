extends "res://Scripts/Props/InteractableBase.gd"

@onready var camera_marker: Marker3D = $CameraMarker

var _player_camera: Camera3D
var _original_cam_transform: Transform3D
var _is_active := false

@onready var screen_mesh: MeshInstance3D = $ScreenMesh
@onready var terminal_viewport: SubViewport = $TerminalViewport

func _ready() -> void:
	EventBus.terminal_closed.connect(_on_terminal_closed)
	
	# 1. Fix Checkerboard Texture
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = terminal_viewport.get_texture()
	screen_mesh.material_override = mat

	# 2. Fix Mangled Orientation (Align to world space facing player)
	# The player is at X=-1.58, looking at X=-2.6 (so player looks -X).
	# Thus, the screen must face +X. 
	# Godot QuadMesh faces +Z. So we point its +Z towards world +X.
	var correct_basis = Basis(Vector3(0, 0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0))
	
	# Position screen mesh 0.5 units above the center of the terminal prop
	screen_mesh.global_position = global_position + Vector3(0.0, 0.5, 0.0)
	screen_mesh.global_basis = correct_basis
	
	# Position camera marker 0.6 units in front of the screen (+X direction)
	camera_marker.global_position = screen_mesh.global_position + Vector3(0.7, 0.0, 0.0)
	# Look at the screen mesh
	camera_marker.global_basis = correct_basis # This means the camera looks -Z, which is world -X (towards the screen)

func interact(player: Node3D) -> void:
	if _is_active:
		return
	_is_active = true
	
	# Find player camera
	_player_camera = get_viewport().get_camera_3d()
	if _player_camera:
		_original_cam_transform = _player_camera.global_transform
		
		# Tween camera to the marker
		var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(_player_camera, "global_transform", camera_marker.global_transform, 0.4)
		
		# Enable depth of field blur using Practical attributes
		if _player_camera.attributes == null:
			_player_camera.attributes = CameraAttributesPractical.new()
		var attrs = _player_camera.attributes as CameraAttributesPractical
		if attrs:
			attrs.dof_blur_far_enabled = true
			attrs.dof_blur_far_distance = 0.5
			attrs.dof_blur_far_transition = 0.5
			attrs.dof_blur_near_enabled = true
			attrs.dof_blur_near_distance = 1.0
	
	EventBus.emit_terminal_requested()

func _on_terminal_closed() -> void:
	if not _is_active:
		return
	_is_active = false
	
	if _player_camera:
		var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(_player_camera, "global_transform", _original_cam_transform, 0.4)
		
		# Restore DOF
		if _player_camera.attributes is CameraAttributesPractical:
			var attrs = _player_camera.attributes as CameraAttributesPractical
			attrs.dof_blur_far_enabled = false
			attrs.dof_blur_near_enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if _is_active:
		$TerminalViewport.push_input(event)
