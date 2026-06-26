extends Node

const MESSAGE_TEXT := "Timer is over."

var canvas_layer: CanvasLayer
var message_panel: PanelContainer
var message_label: Label

func _ready() -> void:
	_build_ui()
	EventBus.five_minutes_elapsed.connect(_on_five_minutes_elapsed)
	EventBus.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(state: int) -> void:
	if state == 1: # PLAYING
		if message_panel != null:
			message_panel.visible = false

func _build_ui() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 90
	add_child(canvas_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(root)

	message_panel = PanelContainer.new()
	message_panel.visible = false
	message_panel.custom_minimum_size = Vector2(360, 96)
	message_panel.set_anchors_preset(Control.PRESET_CENTER)
	message_panel.offset_left = -180
	message_panel.offset_top = -48
	message_panel.offset_right = 180
	message_panel.offset_bottom = 48
	root.add_child(message_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	message_panel.add_child(margin)

	message_label = Label.new()
	message_label.text = MESSAGE_TEXT
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	margin.add_child(message_label)

func _on_five_minutes_elapsed() -> void:
	message_label.text = MESSAGE_TEXT
	message_panel.visible = true
