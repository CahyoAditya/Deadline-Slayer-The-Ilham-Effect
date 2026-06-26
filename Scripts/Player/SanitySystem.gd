extends Node

@export var max_sanity := 100.0
@export var current_sanity := 100.0
@export var passive_drain_rate := 1.0
@export var critical_threshold := 20.0
@export var kopi_restore_amount := 35.0

var _critical_emitted := false
var _depleted_emitted := false

# ─── Sanity audio tiers ───────────────────────────────────────────────────────
# Each tier activates different hallucination audio on independent random timers.
var _tier_75_active := false  # Creepy ambience sounds
var _tier_50_active := false  # Crying / distant yells
var _tier_30_active := false  # Child laughs / baby / whimper (most disturbing)
var _tier_10_active := false  # Ghost chatter + deep moaning tone

# Track last gasp time to avoid rapid-fire
var _last_gasp_time := -999.0
const GASP_COOLDOWN := 12.0

func _ready() -> void:
	max_sanity = GameManager.sanity_data.max_sanity
	passive_drain_rate = GameManager.sanity_data.passive_drain_per_second
	kopi_restore_amount = GameManager.sanity_data.kopi_restore_amount
	current_sanity = clamp(current_sanity, 0.0, max_sanity)
	EventBus.emit_sanity_changed(current_sanity)

	# Connect to EventBus for dramatic one-shot sounds
	EventBus.sanity_critical.connect(_on_sanity_critical)
	EventBus.sanity_depleted.connect(_on_sanity_depleted)
	EventBus.upgrade_purchased.connect(func(type: String) -> void:
		if type == "sanity":
			max_sanity = GameManager.sanity_data.max_sanity
	)

func _process(delta: float) -> void:
	if _game_manager_is_playing():
		drain(max(passive_drain_rate, 0.0) * delta)

	# Periodic gasp at low sanity
	if current_sanity <= 30.0 and _game_manager_is_playing():
		_last_gasp_time += delta
		if _last_gasp_time >= GASP_COOLDOWN:
			_last_gasp_time = 0.0
			AudioManager.play_sfx("gasp", -6.0)

func drain(amount: float) -> void:
	if amount <= 0.0 or _depleted_emitted:
		return

	var old_sanity := current_sanity
	current_sanity = clamp(current_sanity - amount, 0.0, max_sanity)
	EventBus.emit_sanity_changed(current_sanity)

	# Activate audio tiers as sanity crosses thresholds
	_check_audio_tiers(old_sanity, current_sanity)

	if current_sanity <= critical_threshold and not _critical_emitted:
		_critical_emitted = true
		EventBus.emit_sanity_critical()

	if current_sanity <= 0.0 and not _depleted_emitted:
		_depleted_emitted = true
		EventBus.emit_sanity_depleted()

func drain_from_specter(amount: float) -> void:
	drain(amount)

func restore_from_kopi() -> void:
	restore(kopi_restore_amount)
	AudioManager.play_sfx("pickup_kopi", 0.0)

func restore(amount: float) -> void:
	if amount <= 0.0:
		return

	current_sanity = clamp(current_sanity + amount, 0.0, max_sanity)
	_depleted_emitted = current_sanity <= 0.0
	_critical_emitted = current_sanity <= critical_threshold
	EventBus.emit_sanity_changed(current_sanity)

	# Deactivate higher-tier hallucinations if sanity was restored significantly
	_check_tier_deactivations()

# ─── Sanity Audio Tiers ──────────────────────────────────────────────────────

func _check_audio_tiers(old_val: float, new_val: float) -> void:
	# Tier 4: <75% — subtle creepy ambience
	if new_val < 75.0 and old_val >= 75.0 and not _tier_75_active:
		_tier_75_active = true
		_start_tier_75_hallucinations()

	# Tier 3: <50% — crying and distant yells
	if new_val < 50.0 and old_val >= 50.0 and not _tier_50_active:
		_tier_50_active = true
		_start_tier_50_hallucinations()

	# Tier 2: <30% — child laughs, baby sounds, whimpering (most unsettling)
	if new_val < 30.0 and old_val >= 30.0 and not _tier_30_active:
		_tier_30_active = true
		_start_tier_30_hallucinations()

	# Tier 1: <10% — ghost chatter + deep tonal moaning
	if new_val < 10.0 and old_val >= 10.0 and not _tier_10_active:
		_tier_10_active = true
		_start_tier_10_hallucinations()

func _check_tier_deactivations() -> void:
	if current_sanity >= 75.0:
		_tier_75_active = false
		_tier_50_active = false
		_tier_30_active = false
		_tier_10_active = false
	elif current_sanity >= 50.0:
		_tier_50_active = false
		_tier_30_active = false
		_tier_10_active = false
	elif current_sanity >= 30.0:
		_tier_30_active = false
		_tier_10_active = false
	elif current_sanity >= 10.0:
		_tier_10_active = false

## Tier 4 (75–50%): Subtle creepy ambience, played every 20–40s
func _start_tier_75_hallucinations() -> void:
	while _tier_75_active and _game_manager_is_playing():
		await get_tree().create_timer(randf_range(20.0, 40.0)).timeout
		if not _tier_75_active:
			break
		AudioManager.play_sfx("hallucination_creak", -8.0)

## Tier 3 (50–30%): Crying + distant yell, every 15–30s
func _start_tier_50_hallucinations() -> void:
	while _tier_50_active and _game_manager_is_playing():
		await get_tree().create_timer(randf_range(15.0, 30.0)).timeout
		if not _tier_50_active:
			break
		# Alternate between crying and distant yelling
		if randf() > 0.5:
			AudioManager.play_sfx("hallucination_crying", -5.0)
		else:
			AudioManager.play_sfx("hallucination_distant_yell", -5.0)

## Tier 2 (30–10%): Child laughter, baby sounds, whimpering — every 8–20s
## This is the most psychologically disturbing tier.
func _start_tier_30_hallucinations() -> void:
	while _tier_30_active and _game_manager_is_playing():
		await get_tree().create_timer(randf_range(8.0, 20.0)).timeout
		if not _tier_30_active:
			break
		var roll := randf()
		if roll < 0.4:
			AudioManager.play_sfx("hallucination_child_laugh", -2.0)
		elif roll < 0.7:
			AudioManager.play_sfx("hallucination_baby", -4.0)
		else:
			AudioManager.play_sfx("hallucination_whimper", -3.0)

## Tier 1 (<10%): Ghost chatter + tonal moan — constant low-frequency dread
func _start_tier_10_hallucinations() -> void:
	# One-shot immediate trigger for maximum impact
	AudioManager.play_sfx("hallucination_ghost_chatter", 0.0)
	await get_tree().create_timer(2.0).timeout
	AudioManager.play_sfx("hallucination_tone_moan", -3.0)

	while _tier_10_active and _game_manager_is_playing():
		await get_tree().create_timer(randf_range(5.0, 12.0)).timeout
		if not _tier_10_active:
			break
		if randf() > 0.5:
			AudioManager.play_sfx("hallucination_ghost_chatter", -2.0)
		else:
			AudioManager.play_sfx("hallucination_tone_moan", -1.0)

# ─── EventBus Callbacks ───────────────────────────────────────────────────────

func _on_sanity_critical() -> void:
	# Dramatic entry sound into critical sanity zone
	AudioManager.play_sfx("specter_chatter", -3.0)

func _on_sanity_depleted() -> void:
	# Final scream before game over
	AudioManager.play_sfx("event_lose_sanity", 2.0)

# ─── Helper ──────────────────────────────────────────────────────────────────

func _game_manager_is_playing() -> bool:
	if not is_instance_valid(get_tree().root):
		return false

	if not get_tree().root.has_node("GameManager"):
		return true

	var game_manager := get_tree().root.get_node("GameManager")
	if game_manager.has_method("is_playing"):
		return game_manager.is_playing()

	return true
