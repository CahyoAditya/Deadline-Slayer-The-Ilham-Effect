class_name TypingEvaluator
extends RefCounted

var started_at_msec := 0

func start_pattern() -> void:
	started_at_msec = Time.get_ticks_msec()

func get_speed_multiplier(char_count: int) -> float:
	var elapsed_seconds := float(Time.get_ticks_msec() - started_at_msec) / 1000.0
	var fast_threshold := maxf(float(char_count) / 6.0, 1.5)  # 360 CPM
	var slow_threshold := maxf(float(char_count) / 2.5, 5.0)  # 150 CPM

	if elapsed_seconds < fast_threshold:
		return 1.5
	if elapsed_seconds > slow_threshold:
		return 0.8
	return 1.0

func score(base_progress: float) -> float:
	var elapsed_seconds := float(Time.get_ticks_msec() - started_at_msec) / 1000.0
	if elapsed_seconds < 3.0:
		return base_progress * 1.5
	if elapsed_seconds > 8.0:
		return base_progress * 0.8
	return base_progress
