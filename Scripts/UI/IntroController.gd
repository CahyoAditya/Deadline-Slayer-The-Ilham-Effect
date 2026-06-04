extends Control

@onready var narrative_text: Label = %NarrativeText
@onready var skip_container: Control = %SkipContainer
@onready var skip_wheel: Control = %SkipWheel

var lines: Array[String] = [
	"Proyek Akhir Grafika Komputer dan Visualisasi.",
	"Tugasnya jelas: Membuat Game 3D atau Aplikasi AR.",
	"Batas waktu unggah di CLASS IPB: Malam ini, 23:59.",
	"Teman-teman sekelompokmu: Azka, Adit, dan Calvin...",
	"Tiba-tiba menghilang tanpa jejak semenjak maghrib tadi.",
	"Kamu, Ilham, adalah satu-satunya yang tersisa.",
	"Jika kamu gagal mem-build project Godot ini...",
	"Bukan hanya IPK kalian berempat yang akan hancur.",
	"Sesuatu di sudut kamar kosmu... sudah menunggumu."
]

var current_line := 0
var current_char := 0
var type_timer := 0.0
var char_delay := 0.05
var pause_timer := 0.0
var line_pause := 1.5

var is_typing := false
var is_fading := false

# Skip logic
var hold_time := 0.0
const HOLD_MAX := 1.0
var is_holding := false
var can_skip := false

func _ready() -> void:
	narrative_text.text = ""
	AudioManager.play_ambient("music_static_horror", -15.0)
	
	# Only allow skipping if we've seen it before
	can_skip = GameManager.has_seen_intro
	if can_skip:
		var fade_tween := create_tween()
		fade_tween.tween_property(skip_container, "modulate:a", 1.0, 3.0)
	else:
		skip_container.modulate.a = 0.0
	
	_start_next_line()

func _input(event: InputEvent) -> void:
	if not can_skip:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_holding = event.pressed
	elif event is InputEventScreenTouch:
		is_holding = event.pressed
	elif event.is_action("ui_accept") or event.is_action("ui_cancel") or event.is_action("interact"):
		is_holding = event.is_pressed()

func _skip() -> void:
	GameManager.has_seen_intro = true
	AudioManager.stop_ambient()
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
	GameManager.start_game()

func _start_next_line() -> void:
	if current_line >= lines.size():
		_skip()
		return
		
	narrative_text.text = ""
	current_char = 0
	is_typing = true
	type_timer = 0.0

func _process(delta: float) -> void:
	# Handle skipping
	if can_skip:
		if is_holding:
			hold_time += delta
			if hold_time >= HOLD_MAX:
				_skip()
				return
		else:
			hold_time = max(0.0, hold_time - delta * 2.0)
		skip_wheel.set("progress", hold_time / HOLD_MAX)

	# Handle typing
	if is_typing:
		type_timer += delta
		if type_timer >= char_delay:
			type_timer -= char_delay
			var line: String = lines[current_line]
			if current_char < line.length():
				narrative_text.text += line[current_char]
				current_char += 1
				
				# Play typing sound (with some cooldown to avoid ear bleed)
				if current_char % 2 == 1:
					AudioManager.play_typing_sfx(-8.0)
			else:
				is_typing = false
				pause_timer = line_pause
	elif not is_fading:
		pause_timer -= delta
		if pause_timer <= 0.0:
			is_fading = true
			var fade_tween := create_tween()
			fade_tween.tween_property(narrative_text, "modulate:a", 0.0, 0.5)
			fade_tween.tween_callback(func():
				current_line += 1
				narrative_text.modulate.a = 1.0
				is_fading = false
				_start_next_line()
			)
