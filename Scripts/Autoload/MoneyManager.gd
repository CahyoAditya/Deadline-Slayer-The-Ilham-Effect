extends Node

var current_money := 0.0

func _ready() -> void:
	EventBus.game_state_changed.connect(_on_game_state_changed)

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

func _on_game_state_changed(state: int) -> void:
	# Reference GameManager game state if needed, or simply reset when game starts
	# GameManager.GameState.PLAYING is state 1 usually (let's check GameManager.gd to verify state definition)
	if state == 1: # PLAYING
		reset()
