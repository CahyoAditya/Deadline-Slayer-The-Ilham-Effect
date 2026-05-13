extends Node

# --- State Enum ---
enum GameState { MENU, PLAYING, PAUSED, KERNEL_PANIC, GAME_OVER, WIN }

# --- Exported Resources (Scriptable Object pattern) ---
@export var progress_data: ProgressData
@export var sanity_data: SanityData
@export var battery_data: BatteryData
@export var event_config: EventConfig

# --- Runtime State ---
var current_state: GameState = GameState.MENU
var deadline_timer: float = 0.0                # Countdown in seconds
var is_specter_active: bool = false

func start_game():
	# resets all resources, loads KostRoom.tscn
	deadline_timer = 900.0 # Example 15 mins
	is_specter_active = false
	set_state(GameState.PLAYING)

func set_state(new_state: GameState):
	current_state = new_state
	match current_state:
		GameState.PAUSED:
			EventBus.game_paused.emit()
		GameState.PLAYING:
			EventBus.game_resumed.emit()
		GameState.KERNEL_PANIC:
			EventBus.kernel_panic_triggered.emit()

func check_lose_conditions():
	# called every frame during PLAYING
	pass

func trigger_win():
	# plays upload animation, transitions to WIN
	set_state(GameState.WIN)

func trigger_lose(reason: String):
	# transitions to GAME_OVER
	print("Game Over: ", reason)
	set_state(GameState.GAME_OVER)
