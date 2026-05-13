extends Node

@export var current_sanity: float = 100.0
@export var passive_drain_rate: float = 0.5
@export var specter_drain_rate: float = 3.0
@export var kopi_restore_amount: float = 25.0
@export var critical_threshold: float = 20.0

var _critical_emitted: bool = false
var _depleted_emitted: bool = false

func _ready() -> void:
	current_sanity = clamp(current_sanity, 0.0, 100.0)
	_event_bus().sanity_changed.emit(current_sanity)

func _process(delta: float) -> void:
	if _game_manager().is_playing():
		drain(max(passive_drain_rate, 0.0) * delta)

func drain(amount: float) -> void:
	if amount <= 0.0 or _depleted_emitted:
		return

	current_sanity = clamp(current_sanity - amount, 0.0, 100.0)
	_event_bus().sanity_changed.emit(current_sanity)

	if current_sanity <= critical_threshold and not _critical_emitted:
		_critical_emitted = true
		_event_bus().sanity_critical.emit()
		print("Sanity critical: ", current_sanity)

	if current_sanity <= 0.0 and not _depleted_emitted:
		_depleted_emitted = true
		_event_bus().sanity_depleted.emit()

func drain_from_specter(delta: float) -> void:
	drain(specter_drain_rate * delta)

func restore_from_kopi() -> void:
	restore(kopi_restore_amount)

func restore(amount: float) -> void:
	if amount <= 0.0:
		return

	current_sanity = clamp(current_sanity + amount, 0.0, 100.0)
	_depleted_emitted = current_sanity <= 0.0
	_critical_emitted = current_sanity <= critical_threshold
	_event_bus().sanity_changed.emit(current_sanity)

func reset() -> void:
	current_sanity = 100.0
	_critical_emitted = false
	_depleted_emitted = false
	_event_bus().sanity_changed.emit(current_sanity)

func _event_bus():
	return get_node("/root/EventBus")

func _game_manager():
	return get_node("/root/GameManager")
