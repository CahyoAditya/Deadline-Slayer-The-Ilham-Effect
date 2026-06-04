extends Control

@onready var narrative_text: Label = %NarrativeText
@onready var skip_hint: Label = %SkipHint

var lines: Array[String] = [
	"Proyek Akhir Grafika Komputer dan Visualisasi.",
	"Sistem Koordinat, Transformasi 3D, Canvas API, Plotly...",
	"Batas waktu unggah di CLASS IPB: Malam ini, 23:59.",
	"Teman sekelompokmu, Calvin, tidak kunjung membalas chat WA.",
	"Matamu sudah berat. Baterai laptop menipis.",
	"Jika kamu gagal mem-build project Godot ini...",
	"Bukan hanya IPK-mu yang akan hancur.",
	"Sesuatu di sudut kamar kosmu... sudah menunggu kelengahanmu."
]

var current_line := 0
var current_char := 0
var type_timer := 0.0
var char_delay := 0.05
var pause_timer := 0.0
var line_pause := 1.5

var is_typing := false
var is_fading := false

func _ready() -> void:
	narrative_text.text = ""
	AudioManager.play_ambient("music_static_horror", -15.0)
	
	var fade_tween := create_tween()
	fade_tween.tween_property(skip_hint, "modulate:a", 1.0, 3.0)
	
	_start_next_line()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_skip()
	elif event is InputEventScreenTouch and event.pressed:
		_skip()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		_skip()

func _skip() -> void:
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
