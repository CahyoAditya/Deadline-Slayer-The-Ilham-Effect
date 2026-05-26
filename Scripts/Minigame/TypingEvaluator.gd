class_name TypingEvaluator
extends RefCounted

var started_at_msec := 0

func start_pattern() -> void:
	started_at_msec = Time.get_ticks_msec()

func score(base_progress: float) -> float:
	var elapsed_seconds := float(Time.get_ticks_msec() - started_at_msec) / 1000.0
	if elapsed_seconds < 3.0:
		return base_progress * 1.5
	if elapsed_seconds > 8.0:
		return base_progress * 0.8
	return base_progress
