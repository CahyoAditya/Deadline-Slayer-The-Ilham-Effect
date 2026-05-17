extends Node

#--- State Enum
enum GameState { MENU, PLAYING, PAUSED, KERNEL_PANIC, GAME_OVER, WIN }

#--- Exported Resources (Scriptable Object pattern)
@export var progress_data: Resource
@export var sanity_data: Resource
@export var battery_data: Resource
@export var event_config: Resource

#--- Runtime State
var current_state: GameState = GameState.MENU
var deadline_timer: float = 1200.0 # Default 20:00 menit (1200 detik)
var is_specter_active: bool = false

func _ready() -> void:
	# Menghubungkan sinyal kekalahan dari EventBus agar GameManager tahu kapan harus Game Over
	if not EventBus.sanity_depleted.is_connected(_on_sanity_depleted):
		EventBus.sanity_depleted.connect(_on_sanity_depleted)
		
	if not EventBus.specter_caught_player.is_connected(_on_specter_caught_player):
		EventBus.specter_caught_player.connect(_on_specter_caught_player)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		_handle_deadline_timer(delta)
		# _check_lose_conditions() pasif dihapus karena kita sudah pakai sistem Sinyal (Event-Driven)

func start_game() -> void:
	# Reset state permainan
	current_state = GameState.PLAYING
	deadline_timer = 1200.0 
	is_specter_active = false
	
	if progress_data:
		progress_data.current_progress = 0.0
		
	print("Game Started: Menggila di kamar kost, bersiap ngampus...")

func set_state(new_state: GameState) -> void:
	var old_state = current_state
	current_state = new_state
	
	# Menembakkan sinyal ke EventBus berdasarkan perubahan state
	match current_state:
		GameState.PAUSED:
			EventBus.game_paused.emit()
		GameState.PLAYING:
			if old_state == GameState.PAUSED:
				EventBus.game_resumed.emit()
		GameState.KERNEL_PANIC:
			EventBus.kernel_panic_triggered.emit()

func _handle_deadline_timer(delta: float) -> void:
	# Timer terus berkurang setiap frame selama bermain
	deadline_timer = clamp(deadline_timer - delta, 0.0, deadline_timer)
	
	# Kondisi kalah jika waktu habis (Timeout)
	if deadline_timer <= 0.0:
		trigger_lose("timeout")

func trigger_win() -> void:
	set_state(GameState.WIN)
	print("UPLOAD COMPLETE! Tugas berhasil di-submit ke Class IPB.")

func trigger_lose(reason: String) -> void:
	set_state(GameState.GAME_OVER)
	print("GAME OVER! Alasan kalah: ", reason)
	# Mengarahkan pemain ke screen kekalahan berdasarkan alasannya

#--- Signal Callbacks untuk Kondisi Kalah ---
func _on_sanity_depleted() -> void:
	if current_state == GameState.PLAYING:
		trigger_lose("sanity_depleted")

func _on_specter_caught_player() -> void:
	if current_state == GameState.PLAYING:
		trigger_lose("caught_by_specter")
