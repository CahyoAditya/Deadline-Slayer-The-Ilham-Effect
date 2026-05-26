class_name EventConfig
extends Resource

@export var deadline_seconds := 1200.0
@export var thresholds: Array[int] = [25, 50, 75, 99, 100]
@export var jumpscare_duration := 1.5
@export var kernel_panic_auto_reboot_time := 10.0
