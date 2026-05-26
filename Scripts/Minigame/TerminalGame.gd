extends Node

var easy_patterns: Array[String] = [
	"print(\"hello\")", "x = 5", "deadline = true", "return score", "var hp = 100",
	"if ready:", "queue_free()", "await timer", "func start():", "pass",
	"for i in range(3):", "player.move()", "sanity -= 1", "battery += 10", "emit_signal()",
	"load_level()", "save_game()", "open_laptop()", "close_terminal()", "compile()"
]

var medium_patterns: Array[String] = [
	"if sanity <= 0:", "func restore(amount):", "EventBus.sanity_changed.emit(value)",
	"for task in tasks:", "var progress = clamp(value, 0, 100)", "match threshold:",
	"Input.is_action_pressed(\"interact\")", "get_tree().reload_current_scene()",
	"var tween = create_tween()", "deadline_timer -= delta", "set_process(true)",
	"if battery_level <= 0:", "return input.strip_edges()", "AudioManager.play_sfx(id)",
	"GameManager.trigger_win()", "var pattern = patterns.pick_random()",
	"line_edit.grab_focus()", "panel.visible = true", "camera.rotate_x(angle)",
	"velocity = velocity.normalized()"
]

var hard_patterns: Array[String] = [
	"func _physics_process(delta: float) -> void:",
	"current_progress = clamp(current_progress + amount, 0.0, 100.0)",
	"EventBus.progress_threshold_reached.connect(_on_threshold_reached)",
	"var next_pos = navigation_agent.get_next_path_position()",
	"if current_state == GameState.KERNEL_PANIC:",
	"await get_tree().create_timer(2.0).timeout",
	"var accuracy = correct_chars / max(total_chars, 1)",
	"for threshold in GameManager.event_config.thresholds:",
	"message_panel.set_anchors_preset(Control.PRESET_CENTER)",
	"flashlight.visible = flashlight_on and battery_level > 0.0"
]

func _ready() -> void:
	_load_pattern_resources()

func get_pattern() -> String:
	var progress := ProgressSystem.get_progress()
	if progress < 34.0:
		return easy_patterns.pick_random()
	if progress < 67.0:
		return medium_patterns.pick_random()
	return hard_patterns.pick_random()

func _load_pattern_resources() -> void:
	var easy := _load_pattern_set("res://Resources/Patterns/easy_patterns.tres")
	var medium := _load_pattern_set("res://Resources/Patterns/medium_patterns.tres")
	var hard := _load_pattern_set("res://Resources/Patterns/hard_patterns.tres")

	if easy != null:
		easy_patterns = easy.patterns
	if medium != null:
		medium_patterns = medium.patterns
	if hard != null:
		hard_patterns = hard.patterns

func _load_pattern_set(path: String) -> PatternSet:
	if ResourceLoader.exists(path):
		return load(path) as PatternSet
	return null
