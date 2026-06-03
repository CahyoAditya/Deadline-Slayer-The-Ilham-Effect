extends Node

var is_active := false

func _ready() -> void:
	EventBus.kernel_panic_triggered.connect(_on_kernel_panic_triggered)
	EventBus.kernel_panic_resolved.connect(_on_kernel_panic_resolved)

func _on_kernel_panic_triggered() -> void:
	if is_active:
		return

	is_active = true

	# KERNEL PANIC AUDIO — alarm + static blast
	AudioManager.play_sfx("event_alarm", 3.0)
	AudioManager.play_sfx("event_static", 0.0)
	AudioManager.play_music("kernel_panic")

	EventBus.emit_message_requested("KERNEL PANIC. Rebooting...")
	await get_tree().create_timer(GameManager.event_config.kernel_panic_auto_reboot_time).timeout
	resolve()

func _on_kernel_panic_resolved() -> void:
	pass  # Audio already handled in resolve()

func resolve() -> void:
	if not is_active:
		return

	is_active = false

	# Resolution audio — brief success chime then back to tension
	AudioManager.play_sfx("terminal_correct", 0.0)
	await get_tree().create_timer(0.4).timeout
	AudioManager.play_music("tension")

	EventBus.emit_kernel_panic_resolved()
	GameManager.set_state(GameManager.GameState.PLAYING)
