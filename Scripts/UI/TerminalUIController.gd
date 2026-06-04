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
var _glitch_timer := 0.0

var flavor_lines: Array[String] = [
	"> Menghubungkan ke CLASS IPB...",
	"> [NOTIF] Kamu di-ping di grup WA kelompok...",
	"> Warning: Ditagih tugas kelompok Strukdat padahal GKV belum kelar",
	"> ERROR: Lupa ngasih salam ke dosen di email, auto E",
	"> Fatal Error: Ketiduran di kelas jam 7 pagi",
	"> [SIAK] Kamu alfa 4 kali, fix dilarang ikut UAS",
	"> ALERT: Lupa bayar parkir, kamu jadi buronan tukang parkir rektorat",
	"> Calvin: 'Bagian lu mana woi? Udah mau deadline nih!'",
	"> Pak MAA: 'Jangan lupa tugas GKV dikumpulkan di CLASS IPB'",
	"> Mengunggah ke CLASS IPB... (Timeout)",
	"> Compile Godot engine... (Tolong cepetan dong, mau nangis)",
	"> ERROR: Transformasi 3D mleyot. Matrix error.",
	"> Menyeduh kopi sachet ke-5 malam ini...",
	"> git commit -m 'Tugas GKV Bismillah A amin amin'",
	"> Azka: 'Kok kode gw merah semua?'",
	"> [CLASS IPB] Sesi akan habis dalam 00:07:32",
	"> ERROR: undefined reference to 'waktu_tidur'",
	"> Aditya: 'Eh ini pake Canvas API kan?'",
	"> AAS, SNN, EPG mereview tugas kamu... (deg-degan)",
	"> 'Aduh ini kenapa Weeping Angelnya ngedeketin gw?'",
	"> Mengirim tugas ke dosen... GAGAL (Koneksi Kosan Mati)",
	"> Baterai laptop sisa 4%... Charger mana charger!!!",
	"> [WARNING] Kopi sudah habis, nyawa tersisa 1%",
	"> 'Kok render Canvas API nya cuma nge-blank putih doang!?'",
	"> Tugas Pekan 9 belum kelar... malah main game",
	"> ERROR: NullPointerException pada mental_breakdown.gd",
	"> Mengekstrak file tugas_akhir_gkv_final_bgt_fix_banget_fix.zip",
	"> OAK: Memory Segmentation Fault (Persis kayak otakmu sekarang)",
	"> RPL: Use case diagram dicoret dosen, suruh ulang",
	"> Strukdat: AVL Tree tidak seimbang, IPK lu juga",
	"> DPP: Tugas lu dicopy temen terus lu yang disalahin",
	"> [WIFI KOSAN] Koneksi terputus. Nasib jadi anak kos.",
	"> Mata udah 5 watt, butuh asupan Indomie rebus pake telor ganda",
	"> AAS: 'Kenapa milih warna UI nya gini?' (Mental Damage +50)",
	"> SNN: 'Coba tolong jelaskan baris 42 ini' (Panik luar biasa)",
	"> EPG: 'Ini kurang interaktif ya' (Padahal udah ngoding 3 hari)",
	"> Julius: 'Guys, gkv gw error di node modules nih'",
	"> WARNING: Asam lambung naik akibat telat makan 12 jam",
	"> Pak MAA: 'Silakan yang mau share screen' (Hening cipta)",
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
		
	if visible:
		_glitch_timer -= delta
		if _glitch_timer <= 0.0:
			_update_glitched_text()
			_glitch_timer = 0.1

func _update_glitched_text() -> void:
	if current_pattern == "":
		return
		
	var sanity := 100.0
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		var san_sys := player_node.get_node_or_null("SanitySystem")
		if san_sys and san_sys.get("current_sanity") != null:
			sanity = san_sys.current_sanity
	
	if sanity > 50.0:
		current_pattern_label.text = "KETIK PERSIS SEPERTI INI:\n" + current_pattern
		return
		
	var severity := 1.0 - (sanity / 50.0) # 0.0 to 1.0
	var glitched := ""
	for c in current_pattern:
		# Max 50% chance per character to glitch at 0 sanity
		if randf() < severity * 0.5:
			# Random readable ASCII character
			glitched += String.chr(randi_range(33, 126))
		else:
			glitched += c
			
	current_pattern_label.text = "KETIK PERSIS SEPERTI INI:\n" + glitched

func _next_pattern() -> void:
	current_pattern = terminal_game.get_pattern()
	_update_glitched_text()
	evaluator.start_pattern()



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
