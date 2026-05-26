extends Node

@export var max_sanity := 100.0
@export var current_sanity := 100.0
@export var passive_drain_rate := 1.0
@export var critical_threshold := 20.0
@export var kopi_restore_amount := 35.0

var _critical_emitted := false
var _depleted_emitted := false

func _ready() -> void:
	max_sanity = GameManager.sanity_data.max_sanity
	passive_drain_rate = GameManager.sanity_data.passive_drain_per_second
	kopi_restore_amount = GameManager.sanity_data.kopi_restore_amount
	current_sanity = clamp(current_sanity, 0.0, max_sanity)
	EventBus.emit_sanity_changed(current_sanity)

func _process(delta: float) -> void:
	if _game_manager_is_playing():
		drain(max(passive_drain_rate, 0.0) * delta)

func drain(amount: float) -> void:
	if amount <= 0.0 or _depleted_emitted:
		return

	current_sanity = clamp(current_sanity - amount, 0.0, max_sanity)
	EventBus.emit_sanity_changed(current_sanity)

	if current_sanity <= critical_threshold and not _critical_emitted:
		_critical_emitted = true
		EventBus.emit_sanity_critical()
		print("Sanity critical: ", current_sanity)

	if current_sanity <= 0.0 and not _depleted_emitted:
		_depleted_emitted = true
		EventBus.emit_sanity_depleted()
		print("Sanity depleted")

func drain_from_specter(amount: float) -> void:
	drain(amount)

func restore_from_kopi() -> void:
	restore(kopi_restore_amount)

func restore(amount: float) -> void:
	if amount <= 0.0:
		return

	current_sanity = clamp(current_sanity + amount, 0.0, max_sanity)
	_depleted_emitted = current_sanity <= 0.0
	_critical_emitted = current_sanity <= critical_threshold
	EventBus.emit_sanity_changed(current_sanity)

func _game_manager_is_playing() -> bool:
	if not is_instance_valid(get_tree().root):
		return false

	if not get_tree().root.has_node("GameManager"):
		return true

	var game_manager := get_tree().root.get_node("GameManager")
	if game_manager.has_method("is_playing"):
		return game_manager.is_playing()

	return true
