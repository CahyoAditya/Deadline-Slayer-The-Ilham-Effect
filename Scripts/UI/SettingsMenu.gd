extends Control

signal closed

@onready var master_slider = $Panel/VBoxContainer/AudioSettings/MasterSlider
@onready var bgm_slider = $Panel/VBoxContainer/AudioSettings/BGMSlider
@onready var sfx_slider = $Panel/VBoxContainer/AudioSettings/SFXSlider

@onready var fullscreen_check = $Panel/VBoxContainer/VideoSettings/FullscreenCheck
@onready var resolution_option = $Panel/VBoxContainer/VideoSettings/ResolutionContainer/ResolutionOption
@onready var resolution_container = $Panel/VBoxContainer/VideoSettings/ResolutionContainer

func _ready():
	_update_ui_from_settings()
	
	# Hide resolution options on web since canvas size controls it
	if OS.has_feature("web"):
		resolution_container.hide()
	else:
		# Populate resolution dropdown
		resolution_option.clear()
		for i in range(SettingsManager.available_resolutions.size()):
			var res = SettingsManager.available_resolutions[i]
			resolution_option.add_item(str(res.x) + "x" + str(res.y), i)
		resolution_option.select(SettingsManager.resolution_index)
	
	# Connect signals
	master_slider.value_changed.connect(_on_master_changed)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)
	
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _update_ui_from_settings():
	master_slider.value = SettingsManager.master_volume
	bgm_slider.value = SettingsManager.bgm_volume
	sfx_slider.value = SettingsManager.sfx_volume
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen

func _on_master_changed(value: float):
	SettingsManager.master_volume = value
	SettingsManager.apply_settings()

func _on_bgm_changed(value: float):
	SettingsManager.bgm_volume = value
	SettingsManager.apply_settings()

func _on_sfx_changed(value: float):
	SettingsManager.sfx_volume = value
	SettingsManager.apply_settings()

func _on_fullscreen_toggled(toggled_on: bool):
	SettingsManager.is_fullscreen = toggled_on
	SettingsManager.apply_settings()

func _on_resolution_selected(index: int):
	SettingsManager.resolution_index = index
	SettingsManager.apply_settings()

func _on_back_pressed():
	SettingsManager.save_settings()
	emit_signal("closed")
	hide()

func open():
	_update_ui_from_settings()
	show()
