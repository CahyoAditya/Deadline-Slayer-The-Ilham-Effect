class_name PatternSet
extends Resource

@export var difficulty := "easy"
@export var patterns: Array[String] = []

func get_random_pattern() -> String:
	if patterns.is_empty():
		return "print(\"deadline\")"
	return patterns.pick_random()
