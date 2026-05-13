extends Node

@export var interact_message: String = "Interacted!"

func interact(player: Node3D):
	print("Player interacted with: ", get_parent().name, " - ", interact_message)
	# For Week 1, we just print. Later we can add specific logic here or emit signals.
