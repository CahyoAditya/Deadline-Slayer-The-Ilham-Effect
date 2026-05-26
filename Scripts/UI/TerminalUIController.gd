extends PanelContainer

@onready var current_pattern_label: Label = %CurrentPattern
@onready var output_log: RichTextLabel = %OutputLog
@onready var input_field: LineEdit = %InputField
@onready var status_bar: Label = %StatusBar
@onready var feedback_label: Label = %TerminalFeedback
@onready var terminal_game: Node = $TerminalGame

var evaluator := TypingEvaluator.new()
var current_pattern := ""
var flavor_lines: Array[String] = [
	"> gcc -o main main.c",
	"> Compiling module 3/12...",
	"> [OK] SanityCheck.dll loaded",
	"> ERROR: NullPointerException at deadline.cpp:99",
	"> Retrying...",
	"> Uploading to SIPEMAS IPB...",
	"> Linker warning: sleep debt unresolved",
	"> Coffee driver mounted",
	"> Deadline daemon still alive",
	"> Build cache corrupted. Continuing anyway."
]

func _ready() -> void:
	visible = false
	EventBus.terminal_requested.connect(open)
	EventBus.progress_changed.connect(_on_progress_changed)
	EventBus.game_paused.connect(close)
	EventBus.game_lost.connect(func(_reason: String) -> void: close())
	EventBus.game_won.connect(close)
	input_field.text_submitted.connect(_on_text_submitted)
	input_field.keep_editing_on_text_submit = true

func open() -> void:
	if not GameManager.is_playing():
		return

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	EventBus.emit_terminal_opened()
	_next_pattern()
	_refocus_input()

func close() -> void:
	if not visible:
		return

	visible = false
	EventBus.emit_terminal_closed()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	elif visible and event is InputEventMouseButton and event.pressed:
		call_deferred("_focus_input")

func _on_text_submitted(text: String) -> void:
	if PatternMatcher.check(text, current_pattern):
		var gained := evaluator.score(GameManager.progress_data.progress_per_correct_input)
		ProgressSystem.add_progress(gained)
		_append_output("[color=green]> OK +%.1f%%[/color]" % gained)
		_show_feedback("OK +%.1f%%" % gained, Color(0.25, 1.0, 0.35))
		_next_pattern()
	else:
		_append_output("[color=red]> ERROR: pattern mismatch[/color]")
		_show_feedback("ERROR: type it exactly", Color(1.0, 0.2, 0.2))
	input_field.clear()
	_refocus_input()

func _process(_delta: float) -> void:
	if visible and input_field != null and not input_field.has_focus():
		input_field.grab_focus()

func _next_pattern() -> void:
	current_pattern = terminal_game.get_pattern()
	current_pattern_label.text = "TYPE EXACTLY:\n" + current_pattern
	evaluator.start_pattern()

func _on_progress_changed(value: float) -> void:
	status_bar.text = "UPLOAD %.1f%%" % value
	if flavor_lines.size() > 0:
		_append_output(flavor_lines.pick_random())

func _append_output(line: String) -> void:
	output_log.append_text(line + "\n")
	output_log.scroll_to_line(output_log.get_line_count())

func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)

func _focus_input() -> void:
	if not visible:
		return

	input_field.grab_focus()
	input_field.caret_column = input_field.text.length()

func _refocus_input() -> void:
	_focus_input()
	call_deferred("_focus_input")
