extends StaticBody3D

@export var interact_message := "Interact"

func interact(_player: Node3D) -> void:
	print(interact_message)
