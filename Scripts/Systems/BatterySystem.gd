extends Node

@export var flashlight_path: NodePath = NodePath("../Head/Camera3D/Flashlight")

var battery_level := 100.0
var flashlight_on := true
var _depleted_emitted := false
var _low_battery_emitted := false

@onready var flashlight: SpotLight3D = get_node_or_null(flashlight_path)

func _ready() -> void:
	battery_level = GameManager.battery_data.max_battery
	_apply_flashlight_state()
	EventBus.emit_battery_changed(battery_level)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		set_flashlight(not flashlight_on)

func _process(delta: float) -> void:
	if not flashlight_on or not GameManager.is_playing():
		return

	battery_level = clamp(battery_level - GameManager.battery_data.drain_per_second * delta, 0.0, GameManager.battery_data.max_battery)
	EventBus.emit_battery_changed(battery_level)

	# Low battery warning (< 20%)
	if battery_level < 20.0 and not _low_battery_emitted:
		_low_battery_emitted = true
		AudioManager.play_sfx("env_mechanical", -10.0)  # subtle warning hum

	if battery_level <= 0.0 and not _depleted_emitted:
		_depleted_emitted = true
		_play_battery_dead_sequence()
		set_flashlight(false)
		EventBus.emit_battery_depleted()

func set_flashlight(is_on: bool) -> void:
	var was_on := flashlight_on
	flashlight_on = is_on and battery_level > 0.0
	_apply_flashlight_state()
	EventBus.emit_flashlight_toggled(flashlight_on)

	# Play appropriate sound
	if flashlight_on and not was_on:
		AudioManager.play_sfx("flashlight_on", 0.0)
	elif not flashlight_on and was_on:
		AudioManager.play_sfx("flashlight_off", 0.0)

func restore(amount := -1.0) -> void:
	if amount < 0.0:
		amount = GameManager.battery_data.pickup_restore_amount

	battery_level = clamp(battery_level + amount, 0.0, GameManager.battery_data.max_battery)
	_depleted_emitted = battery_level <= 0.0
	_low_battery_emitted = battery_level < 20.0
	EventBus.emit_battery_changed(battery_level)
	if battery_level > 0.0 and flashlight_on:
		_apply_flashlight_state()

	# Play pickup sound
	AudioManager.play_sfx("pickup_battery", 0.0)

func _apply_flashlight_state() -> void:
	if flashlight != null:
		flashlight.visible = flashlight_on

## Play 3 rapid flashlight clicks then silence when battery dies.
func _play_battery_dead_sequence() -> void:
	for i in 3:
		AudioManager.play_sfx("flashlight_click", 0.0)
		await get_tree().create_timer(0.12).timeout
	# Final click and silence — the darkness is now your problem
	AudioManager.play_sfx("flashlight_off", -4.0)
