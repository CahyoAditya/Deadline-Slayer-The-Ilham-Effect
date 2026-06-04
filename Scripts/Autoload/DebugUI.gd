extends Node

const TOGGLE_KEY := KEY_F3

var canvas_layer: CanvasLayer
var panel: PanelContainer
var status_label: Label
var time_label: Label
var event_label: Label
var last_event_text := "Last event: none"
var previous_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _is_dragging := false

func _ready() -> void:
	_build_ui()
	EventBus.five_minutes_elapsed.connect(_on_five_minutes_elapsed)

func _input(event: InputEvent) -> void:
	if panel and panel.visible:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var title_rect = Rect2(panel.position, Vector2(panel.size.x, 40))
				if title_rect.has_point(event.position):
					_is_dragging = true
			else:
				_is_dragging = false
		elif event is InputEventMouseMotion and _is_dragging:
			panel.position += event.relative

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
	panel.custom_minimum_size = Vector2(320, 0)
	panel.size = Vector2(320, 600) # Give it a fixed height so it can scroll
	canvas_layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "Debug Test UI (F3) [Drag Me]"
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

	var preset_grid := GridContainer.new()
	preset_grid.columns = 2
	preset_grid.add_theme_constant_override("h_separation", 8)
	root.add_child(preset_grid)
	_add_button(preset_grid, "Save UI Preset", _save_preset)
	_add_button(preset_grid, "Load UI Preset", _load_preset)

	var shader_label := Label.new()
	shader_label.text = "Shader Toggles:"
	root.add_child(shader_label)
	
	var shader_grid := GridContainer.new()
	shader_grid.columns = 2
	root.add_child(shader_grid)

	_add_shader_toggle(shader_grid, "VHS", "VHSRect")
	_add_shader_toggle(shader_grid, "Glitch", "GlitchRect")
	_add_shader_toggle(shader_grid, "PS1 Post", "PS1Rect")
	_add_shader_toggle(shader_grid, "Distort", "DistortRect")
	_add_shader_toggle(shader_grid, "Fisheye Lens", "FisheyeRect")
	_add_shader_toggle(shader_grid, "Color Grade", "ColorGradeRect")

	var fps_cb := CheckBox.new()
	fps_cb.name = "FPSLimit"
	fps_cb.text = "Cinematic FPS Limit (24)"
	fps_cb.focus_mode = Control.FOCUS_NONE
	fps_cb.button_pressed = Engine.max_fps == 24
	fps_cb.toggled.connect(func(toggled_on: bool):
		Engine.max_fps = 24 if toggled_on else 0
	)
	root.add_child(fps_cb)

	var slider_label := Label.new()
	slider_label.text = "Shader Intensity:"
	root.add_child(slider_label)

	var slider_grid := GridContainer.new()
	slider_grid.columns = 2
	slider_grid.add_theme_constant_override("h_separation", 16)
	root.add_child(slider_grid)

	_add_shader_slider(slider_grid, "PSX Intensity", "PS1Rect", "intensity", 0.0, 1.0)
	_add_shader_slider(slider_grid, "VHS Curve", "VHSRect", "warp_amount", 0.0, 3.0)
	_add_shader_slider(slider_grid, "VHS Lines", "VHSRect", "scanlines_opacity", 0.0, 1.0)
	_add_shader_slider(slider_grid, "Glitch Shake", "GlitchRect", "shake_power", 0.0, 0.1)
	_add_shader_slider(slider_grid, "Fisheye Bend", "FisheyeRect", "distortion", -2.0, 2.0)
	_add_shader_slider(slider_grid, "Grade Saturate", "ColorGradeRect", "saturation", 0.0, 1.5)
	_add_shader_slider(slider_grid, "Grade Yellow", "ColorGradeRect", "tint_amount", 0.0, 1.0)

func _add_shader_slider(parent: Node, text: String, node_name: String, param: String, min_val: float, max_val: float) -> void:
	var label = Label.new()
	label.text = text
	parent.add_child(label)
	
	var slider = HSlider.new()
	slider.name = node_name + "_" + param
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = (max_val - min_val) / 100.0
	
	# Fetch current value dynamically
	var rect = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + node_name)
	if rect and rect.material is ShaderMaterial:
		var current_val = (rect.material as ShaderMaterial).get_shader_parameter(param)
		if current_val != null:
			slider.value = current_val
			
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 100
	slider.value_changed.connect(func(val: float):
		var r = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + node_name)
		if r and r.material is ShaderMaterial:
			(r.material as ShaderMaterial).set_shader_parameter(param, val)
	)
	parent.add_child(slider)

func _add_shader_toggle(parent: Node, text: String, node_name: String) -> void:
	var cb := CheckBox.new()
	cb.name = "Toggle_" + node_name
	cb.text = text
	
	var rect = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + node_name)
	if rect:
		cb.button_pressed = rect.visible
		
	cb.focus_mode = Control.FOCUS_NONE
	cb.toggled.connect(func(toggled_on: bool):
		var r = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + node_name)
		if r:
			r.visible = toggled_on
			last_event_text = "Last event: toggled " + node_name + " " + ("ON" if toggled_on else "OFF")
	)
	parent.add_child(cb)

func _save_preset() -> void:
	var config := ConfigFile.new()
	var rects = ["VHSRect", "GlitchRect", "PS1Rect", "DistortRect", "FisheyeRect", "ColorGradeRect"]
	for r_name in rects:
		var rect = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + r_name)
		if rect:
			config.set_value("Toggles", r_name, rect.visible)
			if rect.material is ShaderMaterial:
				var mat = rect.material as ShaderMaterial
				if r_name == "PS1Rect": config.set_value("Params", "PS1Rect_intensity", mat.get_shader_parameter("intensity"))
				if r_name == "VHSRect":
					config.set_value("Params", "VHSRect_warp_amount", mat.get_shader_parameter("warp_amount"))
					config.set_value("Params", "VHSRect_scanlines_opacity", mat.get_shader_parameter("scanlines_opacity"))
				if r_name == "GlitchRect": config.set_value("Params", "GlitchRect_shake_power", mat.get_shader_parameter("shake_power"))
				if r_name == "FisheyeRect": config.set_value("Params", "FisheyeRect_distortion", mat.get_shader_parameter("distortion"))
				if r_name == "ColorGradeRect":
					config.set_value("Params", "ColorGradeRect_saturation", mat.get_shader_parameter("saturation"))
					config.set_value("Params", "ColorGradeRect_tint_amount", mat.get_shader_parameter("tint_amount"))
	config.set_value("Toggles", "FPSLimit", Engine.max_fps == 24)
	config.save("user://shader_preset.cfg")
	last_event_text = "Last event: Saved preset to user://shader_preset.cfg"

func _load_preset() -> void:
	var config := ConfigFile.new()
	if config.load("user://shader_preset.cfg") != OK:
		last_event_text = "Last event: No preset found."
		return
		
	var rects = ["VHSRect", "GlitchRect", "PS1Rect", "DistortRect", "FisheyeRect", "ColorGradeRect"]
	for r_name in rects:
		var rect = get_tree().root.get_node_or_null("Main/PostProcessLayer/" + r_name)
		if rect:
			var vis = config.get_value("Toggles", r_name, rect.visible)
			rect.visible = vis
			
			# Also update the UI checkbox if it exists
			var cb = _find_child_by_name("Toggle_" + r_name)
			if cb and cb is CheckBox: cb.button_pressed = vis
			
			if rect.material is ShaderMaterial:
				var mat = rect.material as ShaderMaterial
				var p_key = r_name + "_"
				# Update material and sliders
				if r_name == "PS1Rect": _apply_param(mat, "intensity", config.get_value("Params", p_key + "intensity", 1.0), p_key + "intensity")
				if r_name == "VHSRect":
					_apply_param(mat, "warp_amount", config.get_value("Params", p_key + "warp_amount", 0.5), p_key + "warp_amount")
					_apply_param(mat, "scanlines_opacity", config.get_value("Params", p_key + "scanlines_opacity", 0.12), p_key + "scanlines_opacity")
				if r_name == "GlitchRect": _apply_param(mat, "shake_power", config.get_value("Params", p_key + "shake_power", 0.03), p_key + "shake_power")
				if r_name == "FisheyeRect": _apply_param(mat, "distortion", config.get_value("Params", p_key + "distortion", 0.8), p_key + "distortion")
				if r_name == "ColorGradeRect":
					_apply_param(mat, "saturation", config.get_value("Params", p_key + "saturation", 0.25), p_key + "saturation")
					_apply_param(mat, "tint_amount", config.get_value("Params", p_key + "tint_amount", 0.85), p_key + "tint_amount")
	
	var fps_limit = config.get_value("Toggles", "FPSLimit", false)
	Engine.max_fps = 24 if fps_limit else 0
	var fps_cb = _find_child_by_name("FPSLimit")
	if fps_cb and fps_cb is CheckBox: fps_cb.button_pressed = fps_limit
	
	last_event_text = "Last event: Loaded preset from user://shader_preset.cfg"

func _apply_param(mat: ShaderMaterial, param: String, val: float, slider_name: String) -> void:
	mat.set_shader_parameter(param, val)
	var slider = _find_child_by_name(slider_name)
	if slider and slider is HSlider:
		slider.value = val

func _find_child_by_name(n: String) -> Node:
	return panel.find_child(n, true, false)

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
	if GameManager.is_playing():
		GameManager.trigger_lose("debug_timeout")
	last_event_text = "Last event: forced game over (debug)"

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
