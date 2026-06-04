extends Node

const SETTINGS_FILE_PATH = "user://settings.cfg"

var config = ConfigFile.new()

# Default Settings
var master_volume: float = 1.0
var bgm_volume: float = 1.0
var sfx_volume: float = 1.0
var is_fullscreen: bool = false
var resolution_index: int = 2 # e.g. 0=720p, 1=900p, 2=1080p

var available_resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

signal settings_changed

func _ready():
	load_settings()

func save_settings():
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "bgm", bgm_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("video", "fullscreen", is_fullscreen)
	config.set_value("video", "resolution", resolution_index)
	config.save(SETTINGS_FILE_PATH)
	apply_settings()

func load_settings():
	if config.load(SETTINGS_FILE_PATH) == OK:
		master_volume = config.get_value("audio", "master", 1.0)
		bgm_volume = config.get_value("audio", "bgm", 1.0)
		sfx_volume = config.get_value("audio", "sfx", 1.0)
		is_fullscreen = config.get_value("video", "fullscreen", false)
		resolution_index = config.get_value("video", "resolution", 2)
	apply_settings()

func apply_settings():
	# Apply Audio
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("BGM", bgm_volume)
	_set_bus_volume("SFX", sfx_volume)
	
	# Apply Video
	if OS.has_feature("web"):
		# Web handles resolution automatically via CSS/canvas, only apply fullscreen
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			if resolution_index >= 0 and resolution_index < available_resolutions.size():
				DisplayServer.window_set_size(available_resolutions[resolution_index])
				
	emit_signal("settings_changed")

func _set_bus_volume(bus_name: String, linear_volume: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		# Convert linear volume (0.0 to 1.0) to decibels (-80 to 0)
		var db = linear_to_db(max(linear_volume, 0.0001))
		AudioServer.set_bus_volume_db(bus_idx, db)
		AudioServer.set_bus_mute(bus_idx, linear_volume <= 0.001)
