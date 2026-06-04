extends Node

@onready var new_game_btn: Button = %NewGameButton
@onready var continue_btn: Button = %ContinueButton
@onready var credits_btn: Button = %CreditsButton
@onready var quit_btn: Button = %QuitButton
@onready var dark_overlay: ColorRect = %DarkOverlay
@onready var menu_camera: Camera3D = %MenuCamera3D

var _camera_origin: Transform3D
var _time := 0.0
const DOLLY_SPEED := 0.08
const DOLLY_AMPLITUDE := 0.15

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	continue_btn.disabled = true
	
	new_game_btn.pressed.connect(_on_new_game)
	credits_btn.pressed.connect(_on_credits)
	quit_btn.pressed.connect(_on_quit)
	
	_setup_button_hovers()
	
	_camera_origin = menu_camera.transform
	
	AudioManager.play_ambient("music_calm_ambient", -12.0)
	
	dark_overlay.modulate.a = 1.0
	var fade_tween := create_tween()
	fade_tween.tween_property(dark_overlay, "modulate:a", 0.3, 2.0)

func _setup_button_hovers() -> void:
	for btn: Button in [%NewGameButton, %ContinueButton, %CreditsButton, %QuitButton]:
		if btn.disabled:
			continue
		
		# We use call_deferred so layout sizes/positions are fully calculated
		btn.mouse_entered.connect(func() -> void:
			AudioManager.play_sfx("flashlight_click", -15.0)
			var t := create_tween()
			t.tween_property(btn, "position:x", 8.0, 0.1).as_relative()
		)
		btn.mouse_exited.connect(func() -> void:
			var t := create_tween()
			t.tween_property(btn, "position:x", -8.0, 0.2).as_relative()
		)

func _process(delta: float) -> void:
	_time += delta
	var offset := Vector3(
		sin(_time * DOLLY_SPEED) * DOLLY_AMPLITUDE,
		sin(_time * DOLLY_SPEED * 0.7) * DOLLY_AMPLITUDE * 0.3,
		cos(_time * DOLLY_SPEED * 0.5) * DOLLY_AMPLITUDE * 0.5
	)
	menu_camera.transform.origin = _camera_origin.origin + offset

func _on_new_game() -> void:
	AudioManager.stop_ambient()
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(dark_overlay, "modulate:a", 1.0, 1.2)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_credits() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
