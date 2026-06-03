extends Node

## HorrorAmbientManager — Autoload that manages passive environmental horror audio.
## Runs randomized creaks, knocks, distant sounds, and false-scare stingers
## on independent timers to keep the player in a constant state of unease.
## Must be added to Project Settings > Autoload as "HorrorAmbientManager".

# ─── Timer Ranges (seconds) ───────────────────────────────────────────────────
const CREAK_MIN        := 12.0
const CREAK_MAX        := 40.0
const KNOCK_MIN        := 55.0
const KNOCK_MAX        := 120.0
const DISTANT_YELL_MIN := 80.0
const DISTANT_YELL_MAX := 160.0
const PIANO_STAB_MIN   := 90.0
const PIANO_STAB_MAX   := 210.0
const FOOTSTEP_MIN     := 25.0
const FOOTSTEP_MAX     := 70.0
const METAL_MIN        := 20.0
const METAL_MAX        := 55.0
const DOOR_CREAK_MIN   := 35.0
const DOOR_CREAK_MAX   := 90.0

var _specter_active := false
var _game_playing  := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect to EventBus signals
	EventBus.specter_spawned.connect(_on_specter_spawned)
	EventBus.specter_sight_broken.connect(_on_specter_dismissed)
	EventBus.game_state_changed.connect(_on_game_state_changed)

	# Defer timer start so AudioManager is ready
	call_deferred("_start_ambient_timers")

func _on_game_state_changed(new_state: int) -> void:
	_game_playing = (new_state == GameManager.GameState.PLAYING)

func _on_specter_spawned() -> void:
	_specter_active = true

func _on_specter_dismissed() -> void:
	_specter_active = false

# ─── Timer Starters ───────────────────────────────────────────────────────────

func _start_ambient_timers() -> void:
	_game_playing = GameManager.is_playing()
	_schedule_creak()
	_schedule_knock()
	_schedule_distant_yell()
	_schedule_piano_stab()
	_schedule_footstep()
	_schedule_metal()
	_schedule_door_creak()

func _schedule_creak() -> void:
	var delay := randf_range(CREAK_MIN, CREAK_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_creak()
	_schedule_creak()

func _schedule_knock() -> void:
	var delay := randf_range(KNOCK_MIN, KNOCK_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_knock()
	_schedule_knock()

func _schedule_distant_yell() -> void:
	var delay := randf_range(DISTANT_YELL_MIN, DISTANT_YELL_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_distant_yell()
	_schedule_distant_yell()

func _schedule_piano_stab() -> void:
	var delay := randf_range(PIANO_STAB_MIN, PIANO_STAB_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_piano_stab()
	_schedule_piano_stab()

func _schedule_footstep() -> void:
	# Only play phantom footsteps during active specter state
	var delay := randf_range(FOOTSTEP_MIN, FOOTSTEP_MAX)
	await get_tree().create_timer(delay).timeout
	if _specter_active and _game_playing:
		AudioManager.play_sfx("specter_footstep", -8.0)
	_schedule_footstep()

func _schedule_metal() -> void:
	var delay := randf_range(METAL_MIN, METAL_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_metal()
	_schedule_metal()

func _schedule_door_creak() -> void:
	var delay := randf_range(DOOR_CREAK_MIN, DOOR_CREAK_MAX)
	await get_tree().create_timer(delay).timeout
	_play_env_door_creak()
	_schedule_door_creak()

# ─── Playback ─────────────────────────────────────────────────────────────────

func _play_env_creak() -> void:
	if not _game_playing:
		return
	# Old house creaks are more intense when specter is active
	if _specter_active:
		AudioManager.play_sfx("env_old_house", -4.0)
	else:
		AudioManager.play_sfx("env_creak", -8.0)

func _play_env_knock() -> void:
	if not _game_playing:
		return
	# 40% chance of a loud knock, 60% quiet during calm, loud when specter active
	if _specter_active:
		AudioManager.play_sfx("env_door_bang", -2.0)
	else:
		AudioManager.play_sfx("env_door_knock", -10.0)

func _play_env_distant_yell() -> void:
	if not _game_playing:
		return
	AudioManager.play_sfx("hallucination_distant_yell", -12.0 if not _specter_active else -6.0)

func _play_env_piano_stab() -> void:
	if not _game_playing:
		return
	# Piano stabs are false-scare stingers — only play when specter is NOT active
	# so they feel unearned and mysterious
	if not _specter_active:
		AudioManager.play_sfx("env_piano_stab", -10.0)
	else:
		# Replace with a creepier stinger during specter time
		AudioManager.play_sfx("stinger_piano_diss", -4.0)

func _play_env_metal() -> void:
	if not _game_playing:
		return
	if _specter_active:
		AudioManager.play_sfx("env_mechanical", -3.0)
	else:
		AudioManager.play_sfx("env_mechanical", -12.0)

func _play_env_door_creak() -> void:
	if not _game_playing:
		return
	AudioManager.play_sfx("env_door_creak", -6.0 if not _specter_active else -1.0)
