extends Node

@export var flashlight_path: NodePath = NodePath("../Head/Camera3D/Flashlight")

var battery_level := 100.0
var flashlight_on := true
var _depleted_emitted := false
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

	if battery_level <= 0.0 and not _depleted_emitted:
		_depleted_emitted = true
		set_flashlight(false)
		EventBus.emit_battery_depleted()

func set_flashlight(is_on: bool) -> void:
	flashlight_on = is_on and battery_level > 0.0
	_apply_flashlight_state()
	EventBus.emit_flashlight_toggled(flashlight_on)

func restore(amount := -1.0) -> void:
	if amount < 0.0:
		amount = GameManager.battery_data.pickup_restore_amount

	battery_level = clamp(battery_level + amount, 0.0, GameManager.battery_data.max_battery)
	_depleted_emitted = battery_level <= 0.0
	EventBus.emit_battery_changed(battery_level)
	if battery_level > 0.0 and flashlight_on:
		_apply_flashlight_state()

func _apply_flashlight_state() -> void:
	if flashlight != null:
		flashlight.visible = flashlight_on
