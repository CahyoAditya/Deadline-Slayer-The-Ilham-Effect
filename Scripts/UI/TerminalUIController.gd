extends PanelContainer

@onready var current_pattern_label: Label = %CurrentPattern
@onready var output_log: RichTextLabel = %OutputLog
@onready var input_field: LineEdit = %InputField
@onready var status_bar: Label = %StatusBar
@onready var feedback_label: Label = %TerminalFeedback
@onready var terminal_game: Node = $TerminalGame
@onready var close_btn: Button = %TerminalCloseButton
@onready var submit_btn: Button = %TerminalSubmitButton

var evaluator := TypingEvaluator.new()
var current_pattern := ""

# Typing sound cooldown — prevents flooding the pool on rapid input
const KEYPRESS_SOUND_COOLDOWN := 0.10  # seconds
var _keypress_sound_timer := 0.0
var flavor_lines: Array[String] = [
	"> Menghubungkan ke SIPEMAS IPB...",
	"> [WARNING] Module Canvas API belum di-import",
	"> ERROR: Plotly is not defined di baris 42",
	"> Pak MAA: 'Jangan lupa tugas GKV dikumpulkan di SIPEMAS'",
	"> Mengunggah ke SIPEMAS... (Timeout)",
	"> Compile Godot engine... (Tolong cepetan dong)",
	"> ERROR: Transformasi 3D gagal. Matrix error.",
	"> Menyeduh kopi... [Kopi driver mounted]",
	"> git commit -m 'Tugas GKV Bismillah A'",
	"> Warning: Kurang tidur terdeteksi. Silakan istirahat.",
	"> [SIPEMAS] Sesi akan habis dalam 00:07:32",
	"> ERROR: undefined reference to 'kewarasan_mahasiswa'",
	"> TODO: Bikin tutorial VR Unity besok",
	"> AAS, SNN, EPG mereview kode kamu...",
	"> Menghitung verteks objek geometri... 100% CPU",
	"> 'Aduh ini error apaan lagi dah?'",
	"> Mengirim tugas ke pak.dosen@ipb.ac.id... GAGAL",
	"> Baterai laptop sisa 4%... Gawat",
	"> [WARNING] Kopi sudah habis",
	"> Memuat scene Godot... Memori penuh",
	"> 'Kok render Canvas API nya nge-blank putih doang?'",
	"> Tugas Pekan 9 belum selesai... Deadline sudah dekat",
	"> ERROR: NullPointerException pada mental_breakdown.gd",
	"> Memuat materi: Transformasi Objek 3D... [FAILED]",
	"> Mengekstrak file tugas_akhir_gkv_final_bgt_fix.zip",
]

func _ready() -> void:
	visible = false
	EventBus.terminal_requested.connect(open)
	EventBus.progress_changed.connect(_on_progress_changed)
	EventBus.game_paused.connect(close)
	EventBus.game_lost.connect(func(_reason: String) -> void: close())
	EventBus.game_won.connect(close)
	input_field.text_submitted.connect(_on_text_submitted)
	input_field.keep_editing_on_text_submit = true
	
	close_btn.pressed.connect(close)
	submit_btn.pressed.connect(func(): _on_text_submitted(input_field.text))

func open() -> void:
	if not GameManager.is_playing():
		return

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	EventBus.emit_terminal_opened()
	AudioManager.play_sfx("terminal_open", 0.0)
	_next_pattern()
	_refocus_input()
	input_field.text_changed.connect(_on_text_changed)

func close() -> void:
	if not visible:
		return

	visible = false
	AudioManager.play_sfx("terminal_close", 0.0)
	if input_field.text_changed.is_connected(_on_text_changed):
		input_field.text_changed.disconnect(_on_text_changed)
	EventBus.emit_terminal_closed()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	elif visible and event is InputEventMouseButton and event.pressed:
		call_deferred("_focus_input")

func _on_text_changed(_new_text: String) -> void:
	# Cooldown prevents flooding the pool on rapid keypresses
	if _keypress_sound_timer > 0.0:
		return
	_keypress_sound_timer = KEYPRESS_SOUND_COOLDOWN
	AudioManager.play_typing_sfx(-4.0)

func _on_text_submitted(text: String) -> void:
	if PatternMatcher.check(text, current_pattern):
		var gained := evaluator.score(GameManager.progress_data.progress_per_correct_input)
		ProgressSystem.add_progress(gained)
		_append_output("[color=green]> OKE +%.1f%%[/color]" % gained)
		_show_feedback("MANTAP +%.1f%%" % gained, Color(0.25, 1.0, 0.35))
		AudioManager.play_sfx("terminal_correct", 0.0)
		_next_pattern()
	else:
		_append_output("[color=red]> ERROR: salah ketik cuy[/color]")
		_show_feedback("ERROR: ketik yang bener!", Color(1.0, 0.2, 0.2))
		AudioManager.play_sfx("terminal_wrong", 0.0)
		# While the Specter is active, mistakes cost sanity — panic makes you clumsy
		if GameManager.is_specter_active:
			var sanity_sys := get_tree().get_first_node_in_group("player")
			if sanity_sys:
				var sys := sanity_sys.get_node_or_null("SanitySystem")
				if sys and sys.has_method("drain"):
					sys.drain(5.0)
	input_field.clear()
	_refocus_input()

func _process(delta: float) -> void:
	# Tick down the typing sound cooldown
	if _keypress_sound_timer > 0.0:
		_keypress_sound_timer -= delta
	# Keep input focused while terminal is open
	if visible and input_field != null and not input_field.has_focus():
		input_field.grab_focus()

func _next_pattern() -> void:
	current_pattern = terminal_game.get_pattern()
	var display_pattern := current_pattern
	# At low sanity, swap one character with a lookalike to disorient the player
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		var san_sys := player_node.get_node_or_null("SanitySystem")
		if san_sys and san_sys.get("current_sanity") != null:
			if san_sys.current_sanity < 30.0 and randf() < 0.5:
				display_pattern = _distort_pattern(current_pattern)
	current_pattern_label.text = "KETIK PERSIS SEPERTI INI:\n" + display_pattern
	evaluator.start_pattern()

## Swap one character with a visually similar lookalike to confuse at low sanity.
func _distort_pattern(pattern: String) -> String:
	const LOOKALIKES := {
		"0": "O", "O": "0", "l": "1", "1": "l",
		"I": "l", "S": "5", "5": "S", "B": "8",
		"G": "6", "6": "G", "Z": "2", "2": "Z",
	}
	var chars := pattern.split("", false)
	# Collect swappable indices
	var swappable: Array[int] = []
	for i in chars.size():
		if LOOKALIKES.has(chars[i]):
			swappable.append(i)
	if swappable.is_empty():
		return pattern
	var idx: int = swappable[randi() % swappable.size()]
	chars[idx] = LOOKALIKES[chars[idx]]
	return "".join(chars)

func _on_progress_changed(value: float) -> void:
	status_bar.text = "UPLOAD %.1f%%" % value
	if flavor_lines.size() > 0:
		_append_output(flavor_lines.pick_random())

func _append_output(line: String) -> void:
	output_log.append_text(line + "\n")
	output_log.scroll_to_line(output_log.get_line_count())

func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)

func _focus_input() -> void:
	if not visible:
		return

	input_field.grab_focus()
	input_field.caret_column = input_field.text.length()

func _refocus_input() -> void:
	_focus_input()
	call_deferred("_focus_input")
