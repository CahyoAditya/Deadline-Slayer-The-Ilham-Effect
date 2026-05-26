extends Node

var is_active := false

func _ready() -> void:
	EventBus.kernel_panic_triggered.connect(_on_kernel_panic_triggered)

func _on_kernel_panic_triggered() -> void:
	if is_active:
		return

	is_active = true
	EventBus.emit_message_requested("KERNEL PANIC. Rebooting...")
	await get_tree().create_timer(GameManager.event_config.kernel_panic_auto_reboot_time).timeout
	resolve()

func resolve() -> void:
	if not is_active:
		return

	is_active = false
	EventBus.emit_kernel_panic_resolved()
	GameManager.set_state(GameManager.GameState.PLAYING)
