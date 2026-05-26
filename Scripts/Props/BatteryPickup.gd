extends "res://Scripts/Props/InteractableBase.gd"

func interact(player: Node3D) -> void:
	var battery_system := player.get_node_or_null("BatterySystem")
	if battery_system != null and battery_system.has_method("restore"):
		battery_system.restore()
	EventBus.emit_message_requested("BATTERY +")
	queue_free()
