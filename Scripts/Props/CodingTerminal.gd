extends "res://Scripts/Props/InteractableBase.gd"

@onready var camera_marker: Marker3D = $CameraMarker

var _player_camera: Camera3D
var _original_cam_transform: Transform3D
var _is_active := false

@onready var screen_mesh: MeshInstance3D = $ScreenMesh
@onready var terminal_viewport: SubViewport = $TerminalViewport

func _ready() -> void:
	EventBus.terminal_closed.connect(_on_terminal_closed)
	
	# 1. Fix Checkerboard Texture in runtime
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = terminal_viewport.get_texture()
	
	screen_mesh.material_override = mat
	
	# The screen mesh and camera marker positions are now left alone 
	# so you can position them manually in the editor!

func interact(player: Node3D) -> void:
	if _is_active:
		return
	_is_active = true
	
	# Find player camera
	_player_camera = get_viewport().get_camera_3d()
	if _player_camera:
		_original_cam_transform = _player_camera.transform
		
		# Calculate exactly where the camera should look (at the center of the screen)
		var forward = (screen_mesh.global_position - camera_marker.global_position).normalized()
		
		# Build a Transform3D safely using Godot's built-in method
		var target_transform = Transform3D(Basis(), camera_marker.global_position)
		target_transform = target_transform.looking_at(screen_mesh.global_position, Vector3.UP)
		
		# Tween camera to the marker, facing the screen
		var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(_player_camera, "global_transform", target_transform, 0.4)
		
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
		# Tween the LOCAL transform back so we don't fight the player's head movement!
		t.tween_property(_player_camera, "transform", _original_cam_transform, 0.4)
		
		# Restore DOF
		if _player_camera.attributes is CameraAttributesPractical:
			var attrs = _player_camera.attributes as CameraAttributesPractical
			attrs.dof_blur_far_enabled = false
			attrs.dof_blur_near_enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
		
	if event is InputEventMouse:
		var camera := get_viewport().get_camera_3d()
		if camera:
			var mouse_pos: Vector2 = event.position
			var ray_origin := camera.project_ray_origin(mouse_pos)
			var ray_dir := camera.project_ray_normal(mouse_pos)
			
			var screen_normal := screen_mesh.global_transform.basis.z.normalized()
			var plane := Plane(screen_normal, screen_mesh.global_position)
			var intersect_pos = plane.intersects_ray(ray_origin, ray_dir)
			
			if intersect_pos != null:
				var local_pos = screen_mesh.global_transform.affine_inverse() * intersect_pos
				
				# QuadMesh size from tscn
				var quad_size := Vector2(1.0, 0.75)
				if screen_mesh.mesh and screen_mesh.mesh is QuadMesh:
					quad_size = screen_mesh.mesh.size
					
				var uv := Vector2(
					(local_pos.x / quad_size.x) + 0.5,
					0.5 - (local_pos.y / quad_size.y)
				)
				
				if uv.x >= 0.0 and uv.x <= 1.0 and uv.y >= 0.0 and uv.y <= 1.0:
					var vp_size := Vector2($TerminalViewport.size)
					var event_copy = event.duplicate()
					event_copy.position = Vector2(uv.x * vp_size.x, uv.y * vp_size.y)
					
					if event_copy is InputEventMouseMotion:
						event_copy.relative = event.relative * (vp_size / get_viewport().get_visible_rect().size)
						
					$TerminalViewport.push_input(event_copy)
					get_viewport().set_input_as_handled()
					return
		
		# Consume unhandled mouse events so we don't click through
		get_viewport().set_input_as_handled()
	else:
		# Keyboard events
		$TerminalViewport.push_input(event)
		get_viewport().set_input_as_handled()
