extends Node

func _ready() -> void:
	# Menghubungkan ke EventBus agar mendengarkan sinyal milestone progress
	if not EventBus.progress_threshold_reached.is_connected(_on_threshold_reached):
		EventBus.progress_threshold_reached.connect(_on_threshold_reached)

func _on_threshold_reached(threshold: int) -> void:
	match threshold:
		25: _fire_event_25()
		50: _fire_event_50()
		75: _fire_event_75()
		99: _fire_event_kernel_panic()
		100: GameManager.trigger_win()

func _fire_event_25() -> void:
	# Atmosphere: lights flicker, distant footsteps
	# Specter: begins patrolling
	
	# Proteksi aman agar game tidak crash jika AudioManager belum dibuat oleh rekan tim
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("specter_whisper")
	else:
		print("[EventTrigger] AudioManager belum ada di Globals. SFX 'specter_whisper' dilewati.")
		
	GameManager.is_specter_active = true
	EventBus.specter_spawned.emit()

func _fire_event_50() -> void:
	# Jumpscare: specter appears briefly in doorway
	# HP drain rate increases
	EventBus.jumpscare_fired.emit("doorway_jumpscare")

func _fire_event_75() -> void:
	# Room goes dark briefly
	# Specter movement speed increases
	EventBus.jumpscare_fired.emit("desk_jumpscare")
	
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("jumpscare_02")
	else:
		print("[EventTrigger] AudioManager belum ada di Globals. SFX 'jumpscare_02' dilewati.")

func _fire_event_kernel_panic() -> void:
	GameManager.set_state(GameManager.GameState.KERNEL_PANIC)
	EventBus.kernel_panic_triggered.emit()