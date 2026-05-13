extends Node

enum GameState { MENU, PLAYING, PAUSED, KERNEL_PANIC, GAME_OVER, WIN }

var current_state: GameState = GameState.PLAYING
var deadline_timer: float = 0.0
var is_specter_active: bool = false

func _ready() -> void:
	var event_bus = get_node("/root/EventBus")
	event_bus.sanity_depleted.connect(_on_sanity_depleted)

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	var event_bus = get_node("/root/EventBus")
	match current_state:
		GameState.PAUSED:
			event_bus.game_paused.emit()
		GameState.PLAYING:
			event_bus.game_resumed.emit()

func trigger_win() -> void:
	set_state(GameState.WIN)
	print("WIN: Upload complete.")

func trigger_lose(reason: String) -> void:
	if current_state == GameState.GAME_OVER or current_state == GameState.WIN:
		return

	set_state(GameState.GAME_OVER)
	print("GAME OVER: ", reason)

func _on_sanity_depleted() -> void:
	trigger_lose("sanity_depleted")
