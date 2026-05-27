extends Node

const TOGGLE_KEY := KEY_F3

var canvas_layer: CanvasLayer
var panel: PanelContainer
var status_label: Label
var time_label: Label
var event_label: Label
var last_event_text := "Last event: none"
var previous_mouse_mode := Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	_build_ui()
	EventBus.five_minutes_elapsed.connect(_on_five_minutes_elapsed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == TOGGLE_KEY:
		toggle()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not panel.visible:
		return

	var state := "running" if GlobalTimer.is_running else "stopped"
	if GlobalTimer.has_finished:
		state = "finished"

	status_label.text = "Timer: %s" % state
	time_label.text = "Time left: %s (%.1fs)" % [
		GlobalTimer.get_time_left_text(),
		GlobalTimer.get_time_left()
	]
	event_label.text = last_event_text

func toggle() -> void:
	if panel.visible:
		hide_ui()
	else:
		show_ui()

func show_ui() -> void:
	previous_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	panel.visible = true

func hide_ui() -> void:
	panel.visible = false
	Input.set_mouse_mode(previous_mouse_mode)

func _build_ui() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)

	panel = PanelContainer.new()
	panel.visible = false
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(280, 0)
	canvas_layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Debug Test UI (F3)"
	title.add_theme_font_size_override("font_size", 18)
	root.add_child(title)

	status_label = Label.new()
	root.add_child(status_label)

	time_label = Label.new()
	root.add_child(time_label)

	event_label = Label.new()
	root.add_child(event_label)

	var button_grid := GridContainer.new()
	button_grid.columns = 2
	button_grid.add_theme_constant_override("h_separation", 8)
	button_grid.add_theme_constant_override("v_separation", 8)
	root.add_child(button_grid)

	_add_button(button_grid, "Start 5m", _on_start_5m_pressed)
	_add_button(button_grid, "Start 10s", _on_start_10s_pressed)
	_add_button(button_grid, "Stop", _on_stop_pressed)
	_add_button(button_grid, "Reset", _on_reset_pressed)
	_add_button(button_grid, "Finish Now", _on_finish_now_pressed)
	_add_button(button_grid, "Hide", hide_ui)
	_add_button(button_grid, "Progress +10", _on_progress_pressed)
	_add_button(button_grid, "Lose Sanity", _on_lose_sanity_pressed)
	_add_button(button_grid, "Set 99%", _on_set_99_pressed)

func _add_button(parent: Node, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	parent.add_child(button)

func _on_start_5m_pressed() -> void:
	GlobalTimer.start_timer(300.0)
	last_event_text = "Last event: started 5 minute timer"

func _on_start_10s_pressed() -> void:
	GlobalTimer.start_timer(10.0)
	last_event_text = "Last event: started 10 second test timer"

func _on_stop_pressed() -> void:
	GlobalTimer.stop_timer()
	last_event_text = "Last event: timer stopped"

func _on_reset_pressed() -> void:
	GlobalTimer.reset_timer()
	last_event_text = "Last event: timer reset"

func _on_finish_now_pressed() -> void:
	GlobalTimer.finish_now()

func _on_five_minutes_elapsed() -> void:
	last_event_text = "Last event: five_minutes_elapsed fired"

func _on_progress_pressed() -> void:
	ProgressSystem.add_progress(10.0)
	last_event_text = "Last event: progress +10"

func _on_lose_sanity_pressed() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_node("SanitySystem"):
		player.get_node("SanitySystem").drain(25.0)
	last_event_text = "Last event: sanity -25"

func _on_set_99_pressed() -> void:
	if not GameManager.is_playing():
		return
	var needed = 99.0 - ProgressSystem.get_progress()
	if needed > 0.0:
		ProgressSystem.add_progress(needed)
	elif needed < 0.0:
		ProgressSystem.current_progress = 99.0
		GameManager.progress_data.current_progress = 99.0
		EventBus.emit_progress_changed(99.0)
	last_event_text = "Last event: progress set to 99%"
