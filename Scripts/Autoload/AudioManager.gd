extends Node

## AudioManager — Full pool-based audio system for horror immersion.
## Provides: music crossfade, ambient layering, SFX pool (polyphonic),
## a dedicated stinger channel, and silence-before-jumpscare support.

# ─── Constants ────────────────────────────────────────────────────────────────
const SFX_POOL_SIZE := 8
const CROSSFADE_DURATION := 1.5
const SILENCE_FADE_DURATION := 0.6

# ─── SFX ID → File Path(s) Dictionary ─────────────────────────────────────────
# Arrays = random variant selection; single strings = always that file.
const SFX_MAP: Dictionary = {
	# ── Player ──
	"flashlight_on":        "res://Sound Effects/Character/Flashlight on.mp3",
	"flashlight_off":       "res://Sound Effects/Character/Flashlight off.mp3",
	"flashlight_click":     "res://Sound Effects/House & Office/Home or Office/Switch_clicking.mp3",
	"interact":             "res://Sound Effects/House & Office/Home or Office/Switch_3.mp3",
	"footstep_wood":        "res://Sound Effects/Character/Footsteps_walking_wood_loop.mp3",
	"footstep_run":         "res://Sound Effects/Character/Footsteps_ running.mp3",
	"gasp": [
		"res://Sound Effects/Character/Gasp.mp3",
		"res://Sound Effects/Character/Gasp_2.mp3",
		"res://Sound Effects/Character/Gasp_3.mp3",
	],
	"breathing_fast":       "res://Sound Effects/Character/Breathing_fast.mp3",
	"pickup_kopi":          "res://Sound Effects/Character/Can_opening.mp3",
	"pickup_battery":       "res://Sound Effects/Character/Soda can_opening.mp3",

	# ── Terminal ──
	"terminal_open":        "res://Sound Effects/House & Office/Home or Office/Typing.mp3",
	"terminal_close":       "res://Sound Effects/House & Office/Home or Office/Switch_3.mp3",
	"terminal_keypress": [
		"res://Sound Effects/House & Office/Home or Office/Typing_2.mp3",
		"res://Sound Effects/House & Office/Home or Office/Typing_3.mp3",
		"res://Sound Effects/House & Office/Home or Office/Typing_4.mp3",
		"res://Sound Effects/House & Office/Home or Office/Typing_5.mp3",
	],
	"terminal_correct":     "res://Sound Effects/Ambient/Task_successful_mystery.mp3",
	"terminal_wrong":       "res://Sound Effects/Stingers & Spooky Triggers/Scratch_high pitch.mp3",

	# ── Specter ──
	"specter_whisper":      "res://Sound Effects/Monsters & Ghosts/Ghost_moan.mp3",
	"specter_moan":         "res://Sound Effects/Monsters & Ghosts/Ghost_moan_2.mp3",
	"specter_growl": [
		"res://Sound Effects/Monsters & Ghosts/Ghost_growl.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_growl_1.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_growl_2.mp3",
	],
	"specter_moan_aggressive": "res://Sound Effects/Monsters & Ghosts/Ghost_moan_aggressive.mp3",
	"specter_hurt": [
		"res://Sound Effects/Monsters & Ghosts/Monster_hurt.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_hurt_2.mp3",
	],
	"specter_dismissed":    "res://Sound Effects/Monsters & Ghosts/Ghost_scream_moan.mp3",
	"specter_footstep": [
		"res://Sound Effects/Monsters & Ghosts/Monster_footstep.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_footstep_1.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_footstep_2.mp3",
		"res://Sound Effects/Monsters & Ghosts/Monster_footstep_3.mp3",
	],
	"specter_breath":       "res://Sound Effects/Monsters & Ghosts/Monster_breath.mp3",
	"specter_chatter":      "res://Sound Effects/Monsters & Ghosts/Ghost_chatter.mp3",

	# ── Jumpscares ──
	"jumpscare_01": [
		"res://Sound Effects/Monsters & Ghosts/Ghost_scream.mp3",
		"res://Sound Effects/Monsters & Ghosts/Ghost_scream_2.mp3",
		"res://Sound Effects/Monsters & Ghosts/Ghost_scream_3.mp3",
	],
	"jumpscare_02":         "res://Sound Effects/Monsters & Ghosts/Ghost_scream_4.mp3",
	"jumpscare_stinger":    "res://Sound Effects/Stingers & Spooky Triggers/Piano_stinger_dissonent.mp3",
	"jumpscare_stinger_echo": "res://Sound Effects/Stingers & Spooky Triggers/Piano_stinger_dissonent_echo.mp3",

	# ── Sanity hallucinations ──
	"hallucination_creak": [
		"res://Sound Effects/Ambient/Creepy_ambience.mp3",
		"res://Sound Effects/Ambient/Creepy_ambience_2.mp3",
		"res://Sound Effects/Ambient/Creepy_ambience_3.mp3",
		"res://Sound Effects/Ambient/Creepy_ambience_4.mp3",
		"res://Sound Effects/Ambient/Creepy_ambience_5.mp3",
	],
	"hallucination_crying": [
		"res://Sound Effects/Ambient/Crying_moaning_ambience.mp3",
		"res://Sound Effects/Ambient/Crying_moaning_ambience_2.mp3",
		"res://Sound Effects/Ambient/Crying_moaning_ambience_3.mp3",
	],
	"hallucination_child_laugh": [
		"res://Sound Effects/Monsters & Ghosts/Child laugh.mp3",
		"res://Sound Effects/Monsters & Ghosts/Child laugh_2.mp3",
		"res://Sound Effects/Monsters & Ghosts/Child laugh_3.mp3",
		"res://Sound Effects/Monsters & Ghosts/Child laugh_4.mp3",
	],
	"hallucination_baby": [
		"res://Sound Effects/Monsters & Ghosts/Baby_babbling.mp3",
		"res://Sound Effects/Monsters & Ghosts/Baby_coo.mp3",
	],
	"hallucination_whimper": "res://Sound Effects/Character/Whimpering.mp3",
	"hallucination_distant_yell": [
		"res://Sound Effects/Ambient/Distant Yell_Echo and Reverb.mp3",
		"res://Sound Effects/Ambient/Distant Yell_Echo and Reverb_2.mp3",
	],
	"hallucination_ghost_chatter": "res://Sound Effects/Monsters & Ghosts/Ghost_chatter.mp3",
	"hallucination_tone_moan":     "res://Sound Effects/Monsters & Ghosts/Tone_Moaning_Deep.mp3",

	# ── Environmental (one-shots triggered by HorrorAmbientManager) ──
	"env_creak": [
		"res://Sound Effects/House & Office/Home or Office/Creak.mp3",
		"res://Sound Effects/House & Office/Home or Office/Creak_Long.mp3",
		"res://Sound Effects/House & Office/Home or Office/Creak_Long_2.mp3",
	],
	"env_old_house": [
		"res://Sound Effects/Ambient/Old House_creeky metal and wood_ambiance.mp3",
		"res://Sound Effects/Ambient/Old House_creeky metal and wood_ambiance_2.mp3",
		"res://Sound Effects/Ambient/Old House_creeky metal and wood_ambiance_3.mp3",
	],
	"env_door_knock": [
		"res://Sound Effects/House & Office/Home or Office/Door_knocking_quiet.mp3",
		"res://Sound Effects/House & Office/Home or Office/Door_knocking.mp3",
		"res://Sound Effects/House & Office/Home or Office/Door_knocking_1.mp3",
	],
	"env_door_bang": [
		"res://Sound Effects/House & Office/Home or Office/Door_bang.mp3",
		"res://Sound Effects/House & Office/Home or Office/Door_bang_2.mp3",
	],
	"env_door_creak": [
		"res://Sound Effects/House & Office/Home or Office/Door_creak.mp3",
		"res://Sound Effects/House & Office/Home or Office/Door_closing_squeaky.mp3",
	],
	"env_glass_break": [
		"res://Sound Effects/Ambient/Glass Breaking_Large_Window.mp3",
		"res://Sound Effects/House & Office/Home or Office/Braking Glass.mp3",
	],
	"env_mechanical": [
		"res://Sound Effects/Ambient/Mechanical Randomness_Spooky.mp3",
		"res://Sound Effects/Ambient/Mechanical Randomness_Spooky_2.mp3",
		"res://Sound Effects/Ambient/Mechanical Randomness_Spooky_3.mp3",
	],
	"env_piano_stab": [
		"res://Sound Effects/Ambient/Piano_suspense_ambient_4.mp3",
		"res://Sound Effects/Ambient/Piano_suspense_ambient_5.mp3",
	],
	"env_metal_scrape": [
		"res://Sound Effects/Ambient/Screech_metalic_dragging.mp3",
		"res://Sound Effects/Ambient/Screech_metalic_dragging_2.mp3",
	],

	# ── Stingers ──
	"stinger_generic": [
		"res://Sound Effects/Stingers & Spooky Triggers/Stinger.mp3",
		"res://Sound Effects/Stingers & Spooky Triggers/Stinger_2.mp3",
		"res://Sound Effects/Stingers & Spooky Triggers/Stinger_3.mp3",
	],
	"stinger_slow":         "res://Sound Effects/Stingers & Spooky Triggers/Slow Stinger.mp3",
	"stinger_crescendo":    "res://Sound Effects/Stingers & Spooky Triggers/Suspenseful crescendo.mp3",
	"stinger_piano_diss":   "res://Sound Effects/Stingers & Spooky Triggers/Piano_stinger_dissonent_2.mp3",
	"stinger_piano_high":   "res://Sound Effects/Stingers & Spooky Triggers/Piano_stinger_highnote.mp3",

	# ── Progress events ──
	"event_specter_spawn":  "res://Sound Effects/Monsters & Ghosts/Ghost_moan_aggressive.mp3",
	"event_door_bang":      "res://Sound Effects/House & Office/Home or Office/Door_bang_2.mp3",
	"event_glass_shatter":  "res://Sound Effects/Ambient/Glass Breaking_Large_Window.mp3",
	"event_alarm":          "res://Sound Effects/House & Office/Home or Office/Alarm_fast.mp3",
	"event_alarm_slow":     "res://Sound Effects/House & Office/Home or Office/Alarm_slow.mp3",
	"event_static":         "res://Sound Effects/Ambient/Static_electrical.mp3",
	"event_win":            "res://Sound Effects/Ambient/Task_successful_mystery.mp3",
	"event_lose_timeout":   "res://Sound Effects/Stingers & Spooky Triggers/Slow Stinger.mp3",
	"event_lose_sanity":    "res://Sound Effects/Monsters & Ghosts/Ghost_scream_4.mp3",
	"event_lose_caught":    "res://Sound Effects/Monsters & Ghosts/Ghost_scream.mp3",

	# ── Ambient music layers (played on music/ambient channels) ──
	"music_calm_ambient":   "res://Sound Effects/Ambient/Artificial Rainstorm.mp3",
	"music_haunting":       "res://Sound Effects/Ambient/Ambience_haunting.mp3",
	"music_haunting_long":  "res://Sound Effects/Ambient/Ambience_haunting_2.mp3",
	"music_tension":        "res://Sound Effects/Ambient/Piano_suspense_ambient.mp3",
	"music_drone_horror":   "res://Sound Effects/Ambient/Drone Epic Horror.mp3",
	"music_specter_moan":   "res://Sound Effects/Monsters & Ghosts/Monster_suspense_moan_distant.mp3",
	"music_countdown":      "res://Sound Effects/Ambient/10 Second count down_beeps.mp3",
	"music_static_horror":  "res://Sound Effects/Ambient/Static_electrical.mp3",
	"music_alarm":          "res://Sound Effects/House & Office/Home or Office/Alarm_fast.mp3",
}

# ─── Music Layer Map ───────────────────────────────────────────────────────────
const MUSIC_LAYERS: Dictionary = {
	"calm": {
		"base":    "music_calm_ambient",
		"overlay": "", # Silence the haunting undertones until the specter appears
	},
	"tension": {
		"base":    "music_haunting_long",
		"overlay": "music_tension",
	},
	"horror_active": {
		"base":    "music_haunting_long",
		"overlay": "music_drone_horror",
	},
	"horror_ambient": {
		"base":    "music_haunting_long",
		"overlay": "music_specter_moan",
	},
	"tension_loop": {
		"base":    "music_haunting",
		"overlay": "music_tension",
	},
	"kernel_panic": {
		"base":    "music_alarm",
		"overlay": "music_static_horror",
	},
}

# ─── Nodes ────────────────────────────────────────────────────────────────────
var _music_base: AudioStreamPlayer
var _music_overlay: AudioStreamPlayer
var _ambient: AudioStreamPlayer
var _stinger: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
# Dedicated player for typing — clips the long recording to 150ms per keypress
var _typing_player: AudioStreamPlayer
const TYPING_CLIP_DURATION := 0.1  # seconds of the recording to play per key
var _typing_tween: Tween

var _current_music_state := ""
var _is_silenced := false
var _silence_tween: Tween

func _ready() -> void:
	# Music base layer
	_music_base = _make_player("MusicBase", -6.0)
	_music_base.autoplay = false

	# Music overlay layer (horror undertone on top of base)
	_music_overlay = _make_player("MusicOverlay", -14.0)
	_music_overlay.autoplay = false

	# Ambient layer (for active-horror ambience, separate from music)
	_ambient = _make_player("Ambient", -10.0)
	_ambient.autoplay = false

	# Stinger — loud, one-shot, high priority
	_stinger = _make_player("Stinger", 0.0)
	_stinger.autoplay = false

	# SFX pool — polyphonic
	for i in SFX_POOL_SIZE:
		var p := _make_player("SFX_%d" % i, 0.0)
		p.autoplay = false
		_sfx_pool.append(p)

	# Typing — dedicated player that clips long recordings to one keyclick
	_typing_player = _make_player("TypingKey", 0.0)
	_typing_player.autoplay = false


# ─── Public API ───────────────────────────────────────────────────────────────

## Play a single typing keyclick — stops the long recording after TYPING_CLIP_DURATION.
func play_typing_sfx(volume_db: float = -4.0) -> void:
	var path := _resolve_path("terminal_keypress")
	if path.is_empty():
		return
	var stream := _load_stream(path)
	if stream == null:
		return
	_typing_player.volume_db = volume_db
	_typing_player.stream = stream
	_typing_player.play()
	
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.kill()
		
	_typing_tween = create_tween()
	_typing_tween.tween_interval(TYPING_CLIP_DURATION)
	_typing_tween.tween_callback(func() -> void:
		if _typing_player.playing:
			_typing_player.stop()
	)

## Play a one-shot sound effect by ID (uses SFX pool).
func play_sfx(sfx_id: String, volume_db: float = 0.0) -> void:
	var path := _resolve_path(sfx_id)
	if path.is_empty():
		push_warning("AudioManager: Unknown SFX id '%s'" % sfx_id)
		return
	var stream := _load_stream(path)
	if stream == null:
		return
	var player := _next_sfx_player()
	player.volume_db = volume_db
	player.stream = stream
	player.play()

## Play a sound on the stinger channel (loud, interrupts previous stinger).
func play_stinger(sfx_id: String, volume_db: float = 2.0) -> void:
	var path := _resolve_path(sfx_id)
	if path.is_empty():
		return
	var stream := _load_stream(path)
	if stream == null:
		return
	_stinger.volume_db = volume_db
	_stinger.stream = stream
	_stinger.play()

## Transition to a named music state (crossfade).
func play_music(music_state: String) -> void:
	if music_state == _current_music_state:
		return
	_current_music_state = music_state

	if not MUSIC_LAYERS.has(music_state):
		push_warning("AudioManager: Unknown music state '%s'" % music_state)
		return

	var layer: Dictionary = MUSIC_LAYERS[music_state]
	_crossfade_to(_music_base, _resolve_path(layer.get("base", "")), CROSSFADE_DURATION)
	_crossfade_to(_music_overlay, _resolve_path(layer.get("overlay", "")), CROSSFADE_DURATION + 0.3)

## Stop all music with fade.
func stop_music(fade_duration: float = 1.0) -> void:
	_fade_out_player(_music_base, fade_duration)
	_fade_out_player(_music_overlay, fade_duration)
	_current_music_state = ""

## Perform the pre-jumpscare silence: fade EVERYTHING out, wait, then callback.
func silence_for_jumpscare(callback: Callable) -> void:
	if _is_silenced:
		callback.call()
		return
	_is_silenced = true

	if _silence_tween and _silence_tween.is_valid():
		_silence_tween.kill()

	_silence_tween = create_tween().set_parallel(true)
	_silence_tween.tween_property(_music_base,    "volume_db", -60.0, SILENCE_FADE_DURATION)
	_silence_tween.tween_property(_music_overlay, "volume_db", -60.0, SILENCE_FADE_DURATION)
	_silence_tween.tween_property(_ambient,       "volume_db", -60.0, SILENCE_FADE_DURATION)

	await _silence_tween.finished
	await get_tree().create_timer(0.15).timeout  # brief total silence moment

	callback.call()

## Restore audio after jumpscare (restore volume levels).
func restore_after_jumpscare(music_state: String = "tension") -> void:
	_is_silenced = false
	# Reset volumes
	_music_base.volume_db    = -6.0
	_music_overlay.volume_db = -14.0
	_ambient.volume_db       = -10.0
	play_music(music_state)

## Play a sound on the ambient channel (loops until replaced).
func play_ambient(sfx_id: String, volume_db: float = -10.0) -> void:
	var path := _resolve_path(sfx_id)
	if path.is_empty():
		return
	var stream := _load_stream(path)
	if stream == null:
		return
	_ambient.volume_db = volume_db
	_ambient.stream = stream
	_ambient.play()

## Stop ambient channel.
func stop_ambient() -> void:
	_fade_out_player(_ambient, 1.0)

# ─── Private Helpers ─────────────────────────────────────────────────────────

func _start_calm_music() -> void:
	play_music("calm")

func _make_player(node_name: String, vol_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	p.volume_db = vol_db
	add_child(p)
	return p

func _resolve_path(sfx_id: String) -> String:
	if not SFX_MAP.has(sfx_id):
		return ""
	var entry = SFX_MAP[sfx_id]
	if entry is Array:
		if entry.is_empty():
			return ""
		return entry[randi() % entry.size()]
	return entry as String

func _load_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: File not found '%s'" % path)
		return null
	return load(path) as AudioStream

func _next_sfx_player() -> AudioStreamPlayer:
	var player := _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE
	if player.playing:
		player.stop()
	return player

func _crossfade_to(player: AudioStreamPlayer, path: String, duration: float) -> void:
	if path.is_empty():
		_fade_out_player(player, duration)
		return
	var stream := _load_stream(path)
	if stream == null:
		return
	var original_vol := player.volume_db
	var t := create_tween()
	t.tween_property(player, "volume_db", -60.0, duration * 0.5)
	t.tween_callback(func() -> void:
		player.stream = stream
		player.play()
	)
	t.tween_property(player, "volume_db", original_vol, duration * 0.5)

func _fade_out_player(player: AudioStreamPlayer, duration: float) -> void:
	var t := create_tween()
	t.tween_property(player, "volume_db", -60.0, duration)
	t.tween_callback(func() -> void: player.stop())
