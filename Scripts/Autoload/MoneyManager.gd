extends Node

var current_money := 0.0

func _ready() -> void:
	pass

func add_money(amount: float) -> void:
	current_money += amount
	EventBus.emit_money_changed(current_money)

func spend_money(amount: float) -> bool:
	if current_money < amount:
		return false
	current_money -= amount
	EventBus.emit_money_changed(current_money)
	return true

func reset() -> void:
	current_money = 0.0
	EventBus.emit_money_changed(current_money)
