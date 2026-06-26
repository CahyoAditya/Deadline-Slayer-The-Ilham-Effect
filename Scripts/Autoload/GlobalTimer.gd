extends Node

const DEFAULT_DURATION_SECONDS := 300.0

signal timer_started(duration_seconds: float)
signal timer_tick(time_left_seconds: float)
signal timer_finished()

@export var duration_seconds := DEFAULT_DURATION_SECONDS
@export var auto_start := true

var time_left_seconds := 0.0
var is_running := false
var has_finished := false

func _ready() -> void:
	if auto_start:
		start_timer(duration_seconds)

func _process(delta: float) -> void:
	if not is_running or not GameManager.is_playing():
		return

	time_left_seconds = maxf(time_left_seconds - delta, 0.0)
	timer_tick.emit(time_left_seconds)
	EventBus.emit_global_timer_tick(time_left_seconds)

	if time_left_seconds <= 0.0:
		_finish_timer()

func start_timer(seconds: float = DEFAULT_DURATION_SECONDS) -> void:
	duration_seconds = seconds
	time_left_seconds = seconds
	is_running = true
	has_finished = false
	timer_started.emit(duration_seconds)
	EventBus.emit_global_timer_started(duration_seconds)

func stop_timer() -> void:
	is_running = false

func reset_timer(seconds := -1.0) -> void:
	if seconds < 0.0:
		seconds = duration_seconds
	start_timer(seconds)

func finish_now() -> void:
	time_left_seconds = 0.0
	_finish_timer()

func get_time_left() -> float:
	return time_left_seconds

func get_time_left_text() -> String:
	var total_seconds := int(ceil(time_left_seconds))
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _finish_timer() -> void:
	if has_finished:
		return

	is_running = false
	has_finished = true
	timer_finished.emit()
	EventBus.emit_five_minutes_elapsed()
