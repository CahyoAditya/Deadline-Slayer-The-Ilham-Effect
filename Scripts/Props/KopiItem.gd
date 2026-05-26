extends "res://Scripts/Props/InteractableBase.gd"

func interact(player: Node3D) -> void:
	var sanity_system := player.get_node_or_null("SanitySystem")
	if sanity_system != null and sanity_system.has_method("restore_from_kopi"):
		sanity_system.restore_from_kopi()
	EventBus.emit_message_requested("SANITY +")
	queue_free()
