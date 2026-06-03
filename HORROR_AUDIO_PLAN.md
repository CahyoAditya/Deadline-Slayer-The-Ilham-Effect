# 🎧 Horror Audio Implementation Plan
## Deadline Slayer: The Ilham Effect

---

## Overview

This plan transforms the game's soundscape from silence into a layered, psychologically oppressive horror experience. The core philosophy: **sound does more than cue events — it manipulates the player's nervous system**. We use silence as a weapon, distant sounds as anxiety generators, and sudden silence before jumpscares as the classic horror one-two punch.

---

## Horror Audio Psychology Techniques Used

| Technique | Description | Where Applied |
|---|---|---|
| **Pre-Jumpscare Silence** | Abruptly cut all ambient audio 0.5–1s before jumpscare fires | SpecterAI `_trigger_jumpscare()` |
| **Sonic Dread Buildup** | Layer increasingly disturbing sounds as threats approach | Specter active state |
| **Sanity Audio Degradation** | Hearing hallucinations (whispers, children laughing) as sanity drops | SanitySystem |
| **Environmental Storytelling** | Office ambience slowly corrupted by horror sounds | Passive ambient system |
| **Proximity Tension** | Monster sounds grow louder/more frequent when specter is active | SpecterAI |
| **Dynamic Silence** | Sudden music/ambient dropout creates dread | Pre-jumpscare hook |
| **False Positives** | Random spooky stingers play even when no threat exists | Random event system |
| **Reward Sounds** | Satisfying, contrasting sounds for pickups and progress | Kopi/Battery/Terminal |

---

## Audio System Architecture

### AudioManager (Rebuilt)

The stub `AudioManager.gd` will be rebuilt into a full audio manager with:

- **Multiple named `AudioStreamPlayer` channels** (music_layer, ambient_layer, sfx_pool[], horror_stinger_layer)
- **Bus routing** for volume control per category
- **Crossfade** support between music states
- **Tween-based volume ramping** for dramatic silence moments
- **SFX pool** (8 players) for polyphonic effect playback
- **Randomization wrappers** to pick from sound variant arrays

### Audio States (Music/Ambient layers)

| State | Files Used | Trigger |
|---|---|---|
| `calm` | `Air conditioning_Running.mp3` + `Suburban Neighborhood_2.mp3` | Game starts |
| `tension` | `Ambience_haunting.mp3` + `Piano_suspense_ambient.mp3` | Specter spawned |
| `horror_active` | `Ambience_haunting_2.mp3` + `Drone Epic Horror.mp3` | Specter closes in (timer < 4s) |
| `kernel_panic` | `Alarm_fast.mp3` + `Static_electrical.mp3` | Kernel panic triggered |
| `critical_deadline` | `10 Second count down_beeps.mp3` | Timer < 60s |
| `silence` | *(nothing)* | 0.7s before jumpscare |

---

## Sound Effect Mapping by Game Event

### Player Actions

| Event | Sound File | Notes |
|---|---|---|
| Footsteps (walking) | `Footsteps_walking_wood_loop.mp3` | Looped while moving |
| Flashlight on | `Flashlight on.mp3` | `BatterySystem.set_flashlight(true)` |
| Flashlight off | `Flashlight off.mp3` | `BatterySystem.set_flashlight(false)` |
| Battery depleted | `Switch_clicking.mp3` → silence | Flashlight clicking then dead |
| Interact (E press) | `Switch_3.mp3` | Generic interaction feedback |
| Terminal open | `Typing.mp3` (oneshot) | Terminal opened event |
| Terminal typing | `Typing_2.mp3` through `Typing_5.mp3` (random) | While in terminal minigame |
| Kopi pickup | `Can_opening.mp3` | Sanity restore |
| Battery pickup | `Soda can_opening.mp3` | Battery restore |
| Gasp (low sanity) | `Gasp.mp3`, `Gasp_2.mp3`, `Gasp_3.mp3` | Random, <30% sanity |

### Specter / Entity Events

| Event | Sound File | Notes |
|---|---|---|
| Specter spawned (25% threshold) | `Ghost_moan.mp3` → silence → `Mechanical Randomness_Spooky.mp3` | Creates dread before entity appears |
| Specter active (ambient while visible) | `Monster_suspense_moan_distant.mp3` (looped) | Replaces calm ambient |
| Specter being flashed | `Ghost_growl.mp3` | Each flash hit |
| Specter flinch (flashlight hurts it) | `Monster_hurt.mp3` | During flash dismissal |
| Specter dismissed | `Ghost_scream_moan.mp3` → transition to `tension_loop` | Victory over specter |
| **PRE-JUMPSCARE SILENCE** | Mute all layers for 0.7s | Just before jumpscare fires |
| **Jumpscare fires** | `Ghost_scream.mp3` + `Piano_stinger_dissonent.mp3` simultaneously | Maximum volume shock |
| Specter footsteps (heard nearby) | `Monster_footstep.mp3` / `Monster_footstep_1.mp3` (random) | Periodic while active |
| Specter approaching (< 3m from player) | `Monster_breath.mp3` (looped, spatialized) | Proximity audio |

### Sanity System Sounds

| Sanity Level | Sound Effect | Trigger |
|---|---|---|
| 100% to 75% | Normal ambience | Passive |
| 75% to 50% | `Creepy_ambience.mp3` overlaid randomly every 20–35s | Sanity drain |
| 50% to 30% | `Crying_moaning_ambience.mp3`, `Distant Yell_Echo and Reverb.mp3` | Sanity critical approaching |
| **sanity_critical** (<=20%) | `Child laugh.mp3` (random), `Baby_babbling.mp3`, `Whimpering.mp3` | `EventBus.sanity_critical` |
| <=10% sanity | `Ghost_chatter.mp3` + `Tone_Moaning_Deep.mp3` | Severe hallucinations |
| **sanity_depleted** | `Ghost_scream_4.mp3` + game over | `EventBus.sanity_depleted` |

### Progress Threshold Events

| Threshold | Sound Sequence | Files |
|---|---|---|
| **25%** | Silence 0.5s → `Ghost_moan_aggressive.mp3` → specter music | Specter first spawn |
| **50%** | `Door_bang.mp3` (false door bang) → `Stinger_2.mp3` | Doorway jumpscare event |
| **75%** | `Glass Breaking_Large_Window.mp3` + `Piano_stinger_dissonent_echo.mp3` | Desk jumpscare |
| **99%** | `Alarm_fast_2.mp3` + `Static_electrical.mp3` | Kernel panic |
| **100% (WIN)** | `Task_successful_mystery.mp3` | Victory |

### Battery / Flashlight Events

| Event | Sound |
|---|---|
| Flashlight toggle ON | `Flashlight on.mp3` |
| Flashlight toggle OFF | `Flashlight off.mp3` |
| Battery low (<20%) | `Mechanical Randomness_Spooky.mp3` (short, looped subtly) |
| Battery depleted | `Switch_clicking.mp3` x3 rapid clicks → silence |

### Environmental / Passive Ambience

| Layer | Sound File | Loop |
|---|---|---|
| Primary indoor ambient | `Air conditioning_Running.mp3` | Always |
| Secondary horror undertone | `Ambience_haunting_1.mp3` | Always (low volume) |
| Random house creak #1 | `Old House_creeky metal and wood_ambiance.mp3` | Every 15–45s random |
| Random house creak #2 | `Creak.mp3` / `Creak_Long.mp3` | Every 20–60s random |
| Random door knock | `Door_knocking_quiet.mp3` | Every 60–120s random |
| Random distant yell | `Distant Yell_Echo and Reverb.mp3` | Every 90–150s random |
| Piano stab (false scare) | `Piano_suspense_ambient_4.mp3` | Rare (every 2–4 min) |

### Terminal / Minigame

| Event | Sound |
|---|---|
| Terminal opened | `Typing.mp3` |
| Each keypress in minigame | `Typing_2.mp3` through `Typing_5.mp3` (random) |
| Correct pattern | `Task_successful_mystery.mp3` |
| Wrong pattern | `Scratch_high pitch.mp3` |
| Terminal closed | `Switch_3.mp3` |

### Kernel Panic

| Event | Sound |
|---|---|
| KP triggered | `Alarm_fast.mp3` + `Static_electrical.mp3` |
| KP rebooting (duration) | `Alarm_slow.mp3` loop |
| KP resolved | `Task_successful_mystery_1.mp3` |

### Win / Lose

| Event | Sound |
|---|---|
| Game won | `Task_successful_mystery.mp3` |
| Game lost (timeout) | `Slow Stinger.mp3` |
| Game lost (sanity) | `Ghost_scream_4.mp3` |
| Game lost (caught) | `Ghost_scream.mp3` + `Piano_stinger_dissonent.mp3` |

---

## Implementation: File Changes Required

1. **`Scripts/Autoload/AudioManager.gd`** — Full rewrite: pool-based polyphonic audio manager
2. **`Scripts/Autoload/HorrorAmbientManager.gd`** — New autoload for passive environmental sounds
3. **`Scripts/Entities/SpecterAI.gd`** — Pre-silence coroutine + proximity audio + footstep timer
4. **`Scripts/Player/SanitySystem.gd`** — Hallucination audio tiers per sanity threshold
5. **`Scripts/Systems/EventTrigger.gd`** — Sound sequences at each progress threshold
6. **`Scripts/Systems/BatterySystem.gd`** — Flashlight click/on/off sounds
7. **`Scripts/Systems/KernelPanicSystem.gd`** — Alarm + static sounds
8. **`Scripts/Props/KopiItem.gd`** — Pickup sound
9. **`Scripts/Props/BatteryPickup.gd`** — Pickup sound
10. **`Scripts/UI/TerminalUIController.gd`** — Typing sounds

---

## Key Horror Design Rules

> **Rule 1:** The ambient sound must ALWAYS be present. Silence is only used intentionally as a weapon.

> **Rule 2:** No jumpscare fires without at least 0.5s of pre-silence. The brain needs to register the quiet before the scream hits.

> **Rule 3:** Sound variants are randomized to prevent audio fatigue. No sound plays the same way twice in a row.

> **Rule 4:** Sanity audio hallucinations are the most disturbing layer — child laughter, crying, and whispering must feel random and unearned to be effective.

> **Rule 5:** The monster's presence should be HEARD before it is seen. Distant moans and footsteps prime fear before visual confirmation.
