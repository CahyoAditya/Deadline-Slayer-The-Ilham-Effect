extends PanelContainer

@onready var current_pattern_label: Label = %CurrentPattern
@onready var output_log: RichTextLabel = %OutputLog
@onready var input_field: LineEdit = %InputField
@onready var status_bar: Label = %StatusBar
@onready var feedback_label: Label = %TerminalFeedback
@onready var terminal_game: Node = $TerminalGame
@onready var close_btn: Button = %TerminalCloseButton
@onready var submit_btn: Button = %TerminalSubmitButton

@onready var toko_btn: Button = %TokoAzkaButton
@onready var shop_vbox: VBoxContainer = %ShopVBox
@onready var terminal_vbox: VBoxContainer = $TerminalMargin/TerminalVBox
@onready var shop_close_btn: Button = %ShopCloseButton
@onready var shop_intro: RichTextLabel = %ShopIntro
@onready var buy_coffee_btn: Button = %BuyCoffeeButton
@onready var buy_battery_btn: Button = %BuyBatteryButton
@onready var buy_battery_upgrade_btn: Button = %BuyBatteryUpgradeButton
@onready var buy_sanity_upgrade_btn: Button = %BuySanityUpgradeButton
@onready var money_label: Label = %MoneyLabel
@onready var shop_money_label: Label = %ShopMoneyLabel
@onready var shop_log: RichTextLabel = %ShopLog

var has_seen_shop_intro := false
var coffee_consumed := 0

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
	"> [Chat Terakhir Calvin]: 'Ham, gw ke bawah bentar nyari angin...'",
	"> [Chat Terakhir Azka]: 'Ham, layar gw kok ada yang aneh ya?'",
	"> [Chat Terakhir Adit]: 'Tolong...'",
	"> Mengunggah ke CLASS IPB... (Timeout)",
	"> Compile Godot engine... (Tolong cepetan dong, gw sendirian nih)",
	"> ERROR: Transformasi 3D mleyot. Titik koordinat hilang, seperti teman-temanmu.",
	"> Menyeduh kopi sachet ke-5 malam ini...",
	"> git commit -m 'Tugas GKV Bismillah A amin amin (Sendirian)'",
	"> [LOG] User 'Azka' disconnected unexpectedly.",
	"> [CLASS IPB] Sesi akan habis dalam 00:07:32",
	"> ERROR: undefined reference to 'kewarasan_ilham'",
	"> [LOG] User 'Aditya' disconnected unexpectedly.",
	"> AAS, SNN, EPG mereview tugas kamu... (deg-degan)",
	"> 'Aduh ini kenapa Weeping Angelnya ngedeketin gw?'",
	"> Mengirim tugas ke dosen... GAGAL (Koneksi Kosan Mati)",
	"> Baterai laptop sisa 4%... Charger mana charger!!!",
	"> [WARNING] Kopi sudah habis, nyawa tersisa 1%",
	"> [LOG] User 'Calvin' disconnected unexpectedly.",
	"> Tugas Pekan 9 belum kelar... malah main game horor",
	"> ERROR: NullPointerException pada mental_breakdown.gd",
	"> Mengekstrak file tugas_akhir_gkv_final_bgt_fix_banget_fix.zip",
	"> OAK: Memory Segmentation Fault (Persis kayak otakmu sekarang)",
	"> RPL: Use case diagram dicoret dosen, suruh ulang",
	"> Strukdat: AVL Tree tidak seimbang, IPK lu juga",
	"> DPP: Tugas lu dicopy temen terus lu yang disalahin",
	"> [WIFI KOSAN] Koneksi terputus. Nasib jadi anak kos yang ditinggal.",
	"> Mata udah 5 watt, butuh asupan Indomie rebus pake telor ganda",
	"> AAS: 'Kenapa cuma nama Ilham di laporan kelompok?' (Mental Damage +50)",
	"> SNN: 'Coba tolong jelaskan baris 42 ini' (Panik luar biasa)",
	"> EPG: 'Ini kurang interaktif ya' (Gimana mau interaktif, ngerjain sendiri!)",
	"> [Pesan Sistem]: 3 perangkat grup offline. Mulai mode Solo.",
	"> WARNING: Asam lambung naik akibat telat makan 12 jam",
	"> Pak MAA: 'Silakan kelompok 5 share screen' (Hening cipta, Ilham sendirian)",
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
	
	toko_btn.pressed.connect(_open_shop)
	shop_close_btn.pressed.connect(_close_shop)
	buy_coffee_btn.pressed.connect(func(): _order_item("coffee"))
	buy_battery_btn.pressed.connect(func(): _order_item("battery"))
	buy_battery_upgrade_btn.pressed.connect(func(): _buy_upgrade("battery"))
	buy_sanity_upgrade_btn.pressed.connect(func(): _buy_upgrade("sanity"))
	EventBus.money_changed.connect(_on_money_changed)

func open() -> void:
	if not GameManager.is_playing():
		return

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	EventBus.emit_terminal_opened()
	AudioManager.play_sfx("terminal_open", 0.0)
	_next_pattern()
	_refocus_input()
	_on_money_changed(MoneyManager.current_money)
	input_field.text_changed.connect(_on_text_changed)

func close() -> void:
	if not visible:
		return

	visible = false
	_close_shop() # Reset view
	AudioManager.play_sfx("terminal_close", 0.0)
	if input_field.text_changed.is_connected(_on_text_changed):
		input_field.text_changed.disconnect(_on_text_changed)
	EventBus.emit_terminal_closed()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _on_text_changed(_new_text: String) -> void:
	# Cooldown prevents flooding the pool on rapid keypresses
	if _keypress_sound_timer > 0.0:
		return
	_keypress_sound_timer = KEYPRESS_SOUND_COOLDOWN
	AudioManager.play_typing_sfx(-4.0)

func _on_text_submitted(text: String) -> void:
	if PatternMatcher.check(text, current_pattern):
		var char_count := current_pattern.length()
		var multiplier := evaluator.get_speed_multiplier(char_count)
		
		# Hitung progress
		var base_progress := float(char_count) * GameManager.progress_data.progress_per_char
		var gained := base_progress * multiplier
		ProgressSystem.add_progress(gained)
		
		# Hitung uang
		var base_money := float(char_count) * GameManager.money_data.money_per_char
		var earned_money := base_money * multiplier
		MoneyManager.add_money(earned_money)

		_append_output("[color=green]> OKE +%.1f%% (+Rp%d)[/color]" % [gained, int(earned_money)])
		_show_feedback("MANTAP +%.1f%% | +Rp%d" % [gained, int(earned_money)], Color(0.25, 1.0, 0.35))
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
	# Keep input focused while terminal is open and terminal view is active
	if visible and terminal_vbox.visible and input_field != null and not input_field.has_focus():
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
	if not visible or not terminal_vbox.visible:
		return

	input_field.grab_focus()
	input_field.caret_column = input_field.text.length()

func _refocus_input() -> void:
	_focus_input()
	call_deferred("_focus_input")

# --- TOKO AZKA MECHANICS ---

func _open_shop() -> void:
	terminal_vbox.visible = false
	shop_vbox.visible = true
	_on_money_changed(MoneyManager.current_money)
	if not has_seen_shop_intro:
		has_seen_shop_intro = true
		shop_intro.text = "SELAMAT DATANG DI TOKO AZKA JAYA ABADI"
		shop_intro.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(shop_intro, "visible_characters", shop_intro.text.length(), 2.0)
	else:
		shop_intro.visible_characters = -1
		shop_intro.text = "SELAMAT DATANG DI TOKO AZKA JAYA ABADI"

func _close_shop() -> void:
	shop_vbox.visible = false
	terminal_vbox.visible = true
	if visible:
		_refocus_input()

func _order_item(item_type: String) -> void:
	var cfg := GameManager.money_data
	var price := cfg.kopi_price if item_type == "coffee" else cfg.battery_price
	if not MoneyManager.spend_money(price):
		_append_shop_log("[color=red]Uang tidak cukup! (Rp %d)[/color]" % int(price))
		return
	
	_deliver_item(item_type)

func _deliver_item(item_type: String) -> void:
	AudioManager.play_sfx("terminal_correct", 0.0)
	
	var player = get_tree().get_first_node_in_group("player")
	if not player: 
		_append_shop_log("[color=red]Error: Player tidak ditemukan![/color]")
		return
	
	if item_type == "coffee":
		coffee_consumed += 1
		var san_sys = player.get_node_or_null("SanitySystem")
		if san_sys:
			if coffee_consumed >= 3 and randf() < 0.30:
				_append_shop_log("[color=red]FATAL: KAMU OVERDOSIS KAFEIN![/color]")
				_append_shop_log("[color=red]JANTUNGMU BERDETAK TERLALU KENCANG, KEWARASAN MENURUN DRASTIS![/color]")
				# Sisakan minimal 5% sanity agar tidak langsung mati tanpa sempat membaca log/warning
				var target_drain := 45.0
				var current_san := float(san_sys.get("current_sanity"))
				if current_san - target_drain < 5.0:
					target_drain = maxf(current_san - 5.0, 0.0)
				san_sys.drain(target_drain)
				
				AudioManager.play_sfx("gasp", 2.0)
				EventBus.emit_message_requested("OVERDOSIS KAFEIN! KAMU MERASA INGIN MATI.")
			else:
				_append_shop_log("[color=green]> Meminum Calvin Coffee. Kewarasan bertambah.[/color]")
				san_sys.restore(GameManager.sanity_data.kopi_restore_amount)
	elif item_type == "battery":
		var bat_sys = player.get_node_or_null("BatterySystem")
		if bat_sys:
			_append_shop_log("[color=green]> Mengganti baterai senter.[/color]")
			bat_sys.restore(50.0)

func _buy_upgrade(type: String) -> void:
	var cfg := GameManager.money_data
	var price := cfg.upgrade_battery_price if type == "battery" else cfg.upgrade_sanity_price
	if not MoneyManager.spend_money(price):
		_append_shop_log("[color=red]Uang tidak cukup untuk upgrade! (Rp %d)[/color]" % int(price))
		return
	
	AudioManager.play_sfx("terminal_correct", 0.0)
	
	if type == "battery":
		GameManager.battery_data.max_battery += cfg.upgrade_battery_amount
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var bat_sys = player.get_node_or_null("BatterySystem")
			if bat_sys:
				bat_sys.restore(cfg.upgrade_battery_amount)
		_append_shop_log("[color=green]Max Batre naik! (+%d) Total: %d[/color]" % [int(cfg.upgrade_battery_amount), int(GameManager.battery_data.max_battery)])
	else:
		GameManager.sanity_data.max_sanity += cfg.upgrade_sanity_amount
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var san_sys = player.get_node_or_null("SanitySystem")
			if san_sys:
				san_sys.restore(15.0) # Berikan pemulihan kecil saja (15.0) agar tidak terlalu OP
		_append_shop_log("[color=green]Max Sanity naik! (+%d) Total: %d[/color]" % [int(cfg.upgrade_sanity_amount), int(GameManager.sanity_data.max_sanity)])
	
	EventBus.emit_upgrade_purchased(type)

func _on_money_changed(new_value: float) -> void:
	if money_label != null:
		money_label.text = "💰 Rp %d" % int(new_value)
	if shop_money_label != null:
		shop_money_label.text = "💰 Rp %d" % int(new_value)
		
	var cfg := GameManager.money_data
	if buy_coffee_btn != null:
		buy_coffee_btn.disabled = new_value < cfg.kopi_price
	if buy_battery_btn != null:
		buy_battery_btn.disabled = new_value < cfg.battery_price
	if buy_battery_upgrade_btn != null:
		buy_battery_upgrade_btn.disabled = new_value < cfg.upgrade_battery_price
	if buy_sanity_upgrade_btn != null:
		buy_sanity_upgrade_btn.disabled = new_value < cfg.upgrade_sanity_price

func _append_shop_log(text: String) -> void:
	shop_log.append_text(text + "\n")
	shop_log.scroll_to_line(shop_log.get_line_count())
