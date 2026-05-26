class_name ProgressData
extends Resource

@export var current_progress := 0.0
@export var max_progress := 100.0
@export var progress_per_correct_input := 2.0

func reset() -> void:
	current_progress = 0.0
