extends Node

var is_active := false

func _ready() -> void:
	EventBus.kernel_panic_triggered.connect(_on_kernel_panic_triggered)

func _on_kernel_panic_triggered() -> void:
	if is_active:
		return

	is_active = true

func resolve() -> void:
	if not is_active:
		return

	is_active = false
	EventBus.emit_kernel_panic_resolved()
	GameManager.set_state(GameManager.GameState.PLAYING)
