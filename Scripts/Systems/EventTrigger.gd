extends Node

func _ready() -> void:
	EventBus.progress_threshold_reached.connect(_on_threshold_reached)

func _on_threshold_reached(threshold: int) -> void:
	print("Progress threshold reached: ", threshold)
	match threshold:
		25:
			_fire_event_25()
		50:
			_fire_event_50()
		75:
			_fire_event_75()
		80:
			_fire_event_80()
		99:
			_fire_kernel_panic()
		100:
			GameManager.trigger_win()

## 25% — First specter spawn: brief silence then moan, then specter appears
func _fire_event_25() -> void:
	# Silence the room briefly before the moan (tension build)
	AudioManager.stop_music(0.4)
	await get_tree().create_timer(0.5).timeout

	# Haunting moan to announce the specter
	AudioManager.play_sfx("event_specter_spawn", 0.0)
	await get_tree().create_timer(1.2).timeout

	# Now activate the specter (audio handled by SpecterAI._on_specter_spawned)
	AudioManager.play_sfx("specter_whisper", -3.0)
	GameManager.is_specter_active = true
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("Something started moving in the room.")

## 50% — Doorway jumpscare: a sudden door bang + stinger
func _fire_event_50() -> void:
	# Classic jump: unexpected loud bang
	AudioManager.play_sfx("event_door_bang", 3.0)
	await get_tree().create_timer(0.1).timeout
	AudioManager.play_stinger("stinger_generic", 2.0)

	await get_tree().create_timer(0.6).timeout
	EventBus.emit_jumpscare_fired("doorway_jumpscare")
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("The doorway is not empty.")

## 75% — Desk jumpscare: glass shattering + dissonant piano echo
func _fire_event_75() -> void:
	# Glass shatter + dissonant piano scream
	AudioManager.play_sfx("event_glass_shatter", 2.0)
	await get_tree().create_timer(0.05).timeout
	AudioManager.play_stinger("jumpscare_stinger_echo", 3.0)
	AudioManager.play_sfx("jumpscare_02", 1.0)

	await get_tree().create_timer(0.4).timeout
	EventBus.emit_jumpscare_fired("desk_jumpscare")
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("The lights hate you now.")

## 80% — Face-to-face specter spawn: ghost appears directly in front of player's face
func _fire_event_80() -> void:
	AudioManager.play_sfx("event_glass_shatter", 1.5)
	AudioManager.play_stinger("jumpscare_stinger", 3.0)
	
	var specter = get_tree().root.get_node_or_null("Main/Specter")
	if specter and specter.has_method("spawn_in_front_of_player"):
		GameManager.is_specter_active = true
		specter.spawn_in_front_of_player()
		EventBus.emit_jumpscare_fired("face_to_face")

## 99% — Kernel panic: alarm + electrical static
func _fire_kernel_panic() -> void:
	# Alarm and static blast to signal system failure
	AudioManager.play_sfx("event_alarm", 2.0)
	await get_tree().create_timer(0.1).timeout
	AudioManager.play_sfx("event_static", -2.0)
	AudioManager.play_music("kernel_panic")

	GameManager.set_state(GameManager.GameState.KERNEL_PANIC)
	EventBus.emit_kernel_panic_triggered()
