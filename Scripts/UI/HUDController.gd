extends CanvasLayer

@onready var deadline_timer: Label = %DeadlineTimer
@onready var sanity_bar: ProgressBar = %SanityBar
@onready var battery_meter: ProgressBar = %BatteryMeter
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var interact_hint: Label = %InteractHint
@onready var message_label: Label = %MessageLabel
@onready var pause_overlay: PanelContainer = %PauseOverlay
@onready var end_screen: PanelContainer = %EndScreen
@onready var end_title: Label = %EndTitle
@onready var end_reason: Label = %EndReason
@onready var end_stats: Label = %EndStats
@onready var resume_button: Button = %ResumeButton
@onready var pause_restart_button: Button = %PauseRestartButton
@onready var pause_main_menu_button: Button = %PauseMainMenuButton
@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton
@onready var crosshair: ColorRect = %Crosshair
@onready var mobile_controls: Control = %MobileControls
@onready var mobile_interact_btn: Button = %MobileInteractButton
@onready var mobile_flashlight_btn: Button = %MobileFlashlightButton

var _is_terminal_open := false
var last_sanity := 100.0
var last_battery := 100.0
var last_progress := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.deadline_changed.connect(_on_deadline_changed)
	EventBus.sanity_changed.connect(_on_sanity_changed)
	EventBus.battery_changed.connect(_on_battery_changed)
	EventBus.progress_changed.connect(_on_progress_changed)
	EventBus.interact_hint_changed.connect(_on_interact_hint_changed)
	EventBus.message_requested.connect(_on_message_requested)
	EventBus.game_lost.connect(_on_game_lost)
	EventBus.game_won.connect(_on_game_won)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	EventBus.terminal_opened.connect(func() -> void: 
		crosshair.visible = false
		if mobile_controls.visible:
			mobile_controls.hide()
		_is_terminal_open = true
	)
	EventBus.terminal_closed.connect(func() -> void: 
		crosshair.visible = true
		if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
			mobile_controls.show()
		_is_terminal_open = false
	)
	resume_button.pressed.connect(GameManager.resume_game)
	pause_restart_button.pressed.connect(func() -> void:
		GameManager.resume_game()
		GameManager.restart_game()
	)
	pause_main_menu_button.pressed.connect(func() -> void:
		GameManager.resume_game()
		GameManager.return_to_main_menu()
	)
	retry_button.pressed.connect(GameManager.restart_game)
	quit_button.pressed.connect(func() -> void: get_tree().quit())

	mobile_controls.visible = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	mobile_interact_btn.pressed.connect(func() -> void:
		var ev := InputEventAction.new()
		ev.action = "interact"
		ev.pressed = true
		Input.parse_input_event(ev)
	)
	mobile_flashlight_btn.pressed.connect(func() -> void:
		var ev := InputEventAction.new()
		ev.action = "flashlight"
		ev.pressed = true
		Input.parse_input_event(ev)
	)

	_on_deadline_changed(GameManager.deadline_timer)
	_on_sanity_changed(100.0)
	_on_battery_changed(100.0)
	_on_progress_changed(0.0)
	pause_overlay.visible = false
	end_screen.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _is_terminal_open:
		GameManager.toggle_pause()
		get_viewport().set_input_as_handled()

func _on_deadline_changed(time_left_seconds: float) -> void:
	var total_seconds := int(ceil(time_left_seconds))
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	deadline_timer.text = "DEADLINE: %02d:%02d" % [minutes, seconds]
	deadline_timer.add_theme_color_override("font_color", Color.RED if time_left_seconds <= 300.0 else Color.WHITE)

func _on_sanity_changed(value: float) -> void:
	last_sanity = value
	sanity_bar.value = value
	if value <= 20.0:
		sanity_bar.modulate = Color(1.0, 0.2, 0.2)
	elif value <= 50.0:
		sanity_bar.modulate = Color(1.0, 0.85, 0.2)
	else:
		sanity_bar.modulate = Color(0.3, 1.0, 0.35)

func _on_battery_changed(value: float) -> void:
	last_battery = value
	battery_meter.value = value
	battery_meter.modulate = Color(1.0, 0.25, 0.25) if value <= 15.0 else Color.WHITE

func _on_progress_changed(value: float) -> void:
	last_progress = value
	progress_bar.value = value

func _on_interact_hint_changed(text: String) -> void:
	interact_hint.text = text
	interact_hint.visible = text != ""

func _on_message_requested(text: String) -> void:
	message_label.text = text
	message_label.visible = text != ""
	if text != "":
		var timer := get_tree().create_timer(3.0)
		timer.timeout.connect(func() -> void:
			if message_label.text == text:
				message_label.visible = false
		)

func _on_game_lost(reason: String) -> void:
	var text := "Waktu habis. Portal SIPEMAS sudah ditutup Pak MAA."
	if reason == "sanity_depleted":
		text = "Kamu kena mental breakdown duluan. Gagal submit."
	elif reason == "caught_by_specter":
		text = "Kamu diculik Weeping Angel. Tugas GKV melayang."
	_show_end_screen("DEADLINE MISSED", text)

func _on_game_won() -> void:
	_show_end_screen("SUBMITTED", "Tugas GKV berhasil di-upload! Pak MAA bangga.")

func _on_game_paused() -> void:
	pause_overlay.visible = true
	crosshair.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_game_resumed() -> void:
	pause_overlay.visible = false
	crosshair.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _show_end_screen(title: String, reason: String) -> void:
	end_title.text = title
	end_reason.text = reason
	crosshair.visible = false
	end_stats.text = "Progress: %.1f%%\nSanity: %.1f%%\nBattery: %.1f%%\nTime survived: %s" % [
		last_progress,
		last_sanity,
		last_battery,
		_format_time(GameManager.time_survived)
	]
	end_screen.visible = true
	pause_overlay.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _format_time(seconds_value: float) -> String:
	var total_seconds := int(floor(seconds_value))
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
