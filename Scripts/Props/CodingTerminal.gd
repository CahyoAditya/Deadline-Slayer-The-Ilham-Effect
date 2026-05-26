extends "res://Scripts/Props/InteractableBase.gd"

func interact(_player: Node3D) -> void:
	EventBus.emit_terminal_requested()
