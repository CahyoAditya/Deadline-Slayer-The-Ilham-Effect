extends Node

enum GameState { MENU, PLAYING, PAUSED, KERNEL_PANIC, GAME_OVER, WIN }

@export var progress_data: ProgressData = ProgressData.new()
@export var sanity_data: SanityData = SanityData.new()
@export var battery_data: BatteryData = BatteryData.new()
@export var event_config: EventConfig = EventConfig.new()
@export var money_data: MoneyData = MoneyData.new()

var current_state: GameState = GameState.MENU
var deadline_timer := 0.0
var is_specter_active := false
var lose_reason := ""
var time_survived := 0.0
var has_seen_intro := false

var tooltips: Array[String] = [
	"Tip: Tekan F untuk menyalakan Senter jika ruangan terlalu gelap.",
	"Tip: Jangan lupa cek TOKO AZKA di pojok kanan atas Terminal!",
	"Tip: Panik? Tekan Q untuk segera menutup Terminal.",
	"Tip: Jangan hiraukan suara aneh. Tetaplah mengetik.",
	"Tip: Kafein memulihkan kewarasan, awas jangan sampai overdosis.",
	"Tip: Baterai senter perlahan habis. Segera beli di Toko Azka.",
	"Tip: Jangan pernah menoleh ke belakang."
]
var tooltip_timer := 0.0
const TOOLTIP_INTERVAL := 45.0

func _ready() -> void:
	_load_resources()
	EventBus.sanity_depleted.connect(func() -> void: trigger_lose("sanity_depleted"))
	EventBus.specter_caught_player.connect(func() -> void: trigger_lose("caught_by_specter"))
	call_deferred("_check_auto_start")

func _check_auto_start() -> void:
	if get_tree().current_scene and get_tree().current_scene.name == "Main":
		start_game()

func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return

	time_survived += delta
	deadline_timer = maxf(deadline_timer - delta, 0.0)
	EventBus.emit_deadline_changed(deadline_timer)
	
	tooltip_timer += delta
	if tooltip_timer >= TOOLTIP_INTERVAL:
		tooltip_timer = 0.0
		if not is_specter_active:
			EventBus.emit_message_requested(tooltips.pick_random())

	if deadline_timer <= 0.0:
		trigger_lose("timeout")

func start_game() -> void:
	progress_data.reset()
	if is_instance_valid(ProgressSystem):
		ProgressSystem.reset()
	if is_instance_valid(MoneyManager):
		MoneyManager.reset()
	deadline_timer = event_config.deadline_seconds
	is_specter_active = false
	lose_reason = ""
	time_survived = 0.0
	EventBus.emit_deadline_changed(deadline_timer)
	
	if is_instance_valid(GlobalTimer):
		GlobalTimer.start_timer(event_config.deadline_seconds)

	set_state(GameState.PLAYING)
	# Start calm background music (deferred so AudioManager is fully ready)
	call_deferred("_start_calm_music")

func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	var old_state := current_state
	current_state = new_state
	EventBus.emit_game_state_changed(current_state)

	if new_state == GameState.PAUSED:
		EventBus.emit_game_paused()
	elif old_state == GameState.PAUSED and new_state == GameState.PLAYING:
		EventBus.emit_game_resumed()

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		set_state(GameState.PAUSED)
		
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		set_state(GameState.PLAYING)
		EventBus.emit_message_requested("")

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		pause_game()
	elif current_state == GameState.PAUSED:
		resume_game()

func restart_game() -> void:
	current_state = GameState.MENU
	get_tree().reload_current_scene()
	await get_tree().process_frame
	start_game()

func return_to_main_menu() -> void:
	current_state = GameState.MENU
	AudioManager.stop_music(0.5)
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func trigger_win() -> void:
	if current_state == GameState.WIN:
		return

	set_state(GameState.WIN)
	AudioManager.stop_music(0.5)
	await get_tree().create_timer(0.3).timeout
	AudioManager.play_sfx("event_win", 2.0)
	EventBus.emit_game_won()
	EventBus.emit_message_requested("TUGAS BERHASIL DISUBMIT KE CLASS IPB!")

func trigger_lose(reason: String) -> void:
	if current_state == GameState.GAME_OVER or current_state == GameState.WIN:
		return

	lose_reason = reason
	set_state(GameState.GAME_OVER)
	EventBus.emit_game_lost(reason)

	# Stop all music first
	AudioManager.stop_music(0.3)
	# Play reason-specific lose sound
	if reason == "sanity_depleted":
		AudioManager.play_sfx("event_lose_sanity", 2.0)
	elif reason == "caught_by_specter":
		AudioManager.play_sfx("event_lose_caught", 2.0)
	else:
		AudioManager.play_stinger("event_lose_timeout", 1.0)

	var message := "Waktu habis. Portal CLASS IPB sudah ditutup Pak MAA."
	if reason == "sanity_depleted":
		message = "Kamu kena mental breakdown duluan. Gagal submit."
	elif reason == "caught_by_specter":
		message = "Kamu diculik Weeping Angel. Tugas GKV melayang."
	elif reason == "debug_timeout":
		message = "[Debug] Timer is over."
	EventBus.emit_message_requested(message)

func _load_resources() -> void:
	if ResourceLoader.exists("res://Resources/Data/progress_data.tres"):
		var loaded_progress := load("res://Resources/Data/progress_data.tres")
		if loaded_progress is ProgressData:
			progress_data = loaded_progress

	if ResourceLoader.exists("res://Resources/Data/sanity_data.tres"):
		var loaded_sanity := load("res://Resources/Data/sanity_data.tres")
		if loaded_sanity is SanityData:
			sanity_data = loaded_sanity

	if ResourceLoader.exists("res://Resources/Data/battery_data.tres"):
		var loaded_battery := load("res://Resources/Data/battery_data.tres")
		if loaded_battery is BatteryData:
			battery_data = loaded_battery

	if ResourceLoader.exists("res://Resources/Data/event_config.tres"):
		var loaded_config := load("res://Resources/Data/event_config.tres")
		if loaded_config is EventConfig:
			event_config = loaded_config

	if ResourceLoader.exists("res://Resources/Data/money_data.tres"):
		var loaded_money := load("res://Resources/Data/money_data.tres")
		if loaded_money is MoneyData:
			money_data = loaded_money

func _start_calm_music() -> void:
	AudioManager.play_music("calm")
