# 🎮 Immersion Design Plan
## Deadline Slayer: The Ilham Effect
### Based on Indie Horror Psychological Technique Analysis

---

## Overview

This game already has the core skeleton of a deeply immersive horror experience. The setting — a student racing against a deadline while something haunts them — is **inherently relatable and mundane**, which is the single strongest asset. This plan maps five proven indie horror psychology techniques directly onto what already exists, what gaps need filling, and exactly how to fill them.

---

## Principle 1: The Low-Fidelity Imagination Trap
*"When a monster is a mess of pixelated, jagged shadows hidden behind a tracking filter, your brain has to fill in the blanks."*

### What This Game Already Has
- `PS1_SHADER.gdshader` — vertex jitter, affine texture mapping
- `PS1_PSX_POSTPROCESSING.gdshader` — color depth reduction + dithering
- `VHS_CRT.gdshader` — scanlines, roll, static noise
- `PostProcess.gdshader` — vignette, grain, chromatic aberration (sanity-driven)

### The Psychological Goal
The Specter must **never be fully seen**. Players should always doubt whether what they glimpsed was real. High-fidelity = demystified. Lo-fidelity = terrifying.

### What's Missing / Needs Implementation

#### A. Apply PS1_SHADER to all 3D materials
- The shader exists but is not applied to scene geometry
- **Action:** In the Godot editor, assign `PS1_SHADER.gdshader` as the material shader for every MeshInstance3D — room walls, floor, furniture, props
- Start values: `jitter = 0.4`, `affine_texture_mapping = true`, `jitter_depth_independent = true`

#### B. Give the Specter a higher base jitter (separate material)
- The Specter should always look *more wrong* than the environment
- **Action:** Create a separate ShaderMaterial instance for the Specter with `jitter = 0.7` baseline
- This makes it feel like it doesn't fully belong to physical reality, even when sanity is fine

#### C. Activate VHS_CRT as a baseline screen overlay
- Even at full sanity, the screen should feel like it's being watched through a degraded medium
- **Action:** Add a CanvasLayer with a ColorRect using `VHS_CRT` at low initial values:
  - `scanlines_opacity = 0.12`, `roll = false`, `noise_opacity = 0.02`, `static_noise_intensity = 0.01`
- This creates the "cursed recording" baseline without overwhelming the player

#### D. ShaderController.gd — drive all shaders from game state
- **Action:** Create `Scripts/UI/ShaderController.gd` (see `HORROR_SHADER_PLAN.md` for full spec)
- Connect to `EventBus.specter_spawned`, `jumpscare_fired`, `kernel_panic_triggered`
- Tween shader params between presets: CALM → TENSION → HORROR_ACTIVE → JUMPSCARE

#### E. Limit the flashlight cone deliberately
- A narrow, imperfect circle of light that doesn't show everything is scarier than a wide beam
- **Action:** In the scene, reduce `SpotLight3D` angle and add slight edge falloff
- The player should always see *just enough* to move, never enough to feel safe

---

## Principle 2: Weaponizing the Player's Own Hardware
*"Knowing the monster is actively listening to your actual microphone means you physically have to hold your breath in real life."*

### What This Game Already Has
- First-person perspective that creates physical identification with the character
- Flashlight mechanic that requires active management (F key)
- Battery drain creating real resource anxiety

### The Psychological Goal
Make the player feel **physically present** in the room. The fear response should leak into their body, not stay on screen.

### What's Missing / Needs Implementation

#### A. Microphone-Reactive Specter (Stretch Goal — High Impact)
- The Specter's jumpscare timer accelerates if the player makes noise (mic input above threshold)
- **Action:** Use Godot's `AudioEffectCapture` on a bus to sample mic volume in real time
- If `mic_volume > threshold` while Specter is active: `jumpscare_timer -= delta * 2.0`
- Show a subtle UI indicator (pulsing icon) that the mic is being listened to
- This converts the entire room into a game mechanic — players physically hold their breath

#### B. Headphone Warning at Game Start
- **Action:** Add a startup screen message: *"This game is best experienced with headphones in the dark."*
- Positions the player for maximum hardware immersion before the first frame

#### C. Real-Time Clock Integration
- The game already has a deadline timer. Showing the **player's actual system time** alongside the in-game countdown makes the deadline feel personally real
- **Action:** In `HUDController.gd`, add a label using `Time.get_time_string_from_system()`
- Label text: `"[REAL TIME: 21:04]"` in a small dim font under the deadline timer
- When the in-game deadline is at <5 minutes, the real clock label turns red

#### D. Window Title Changes by Game State
- **Action:** Use `DisplayServer.window_set_title()` to change the OS window title dynamically
- Normal: `"Deadline Slayer"` | Specter active: `"it knows you're here"` | Kernel panic: `"KERNEL PANIC — 21:04:31"`
- The window title changing surprises players who glance at their taskbar

---

## Principle 3: Mundane, Hyper-Relatable Settings
*"By grounding the universe in the mundane and everyday, the horror feels uncomfortably close to home."*

### What This Game Already Has ✅ (Strongest asset)
- Student doing a programming assignment at deadline — **universally relatable in the target audience**
- Terminal minigame with real coding flavor text (gcc, NullPointerException, SIPEMAS IPB)
- Kopi (coffee) as a sanity mechanic — deeply culturally grounded
- The Specter haunts a **bedroom/study**, not a castle or asylum

### The Psychological Goal
Every detail should feel like it could be *your room, your deadline, your panic.* Horror hits hardest when players think "this could happen to me."

### What's Missing / Needs Implementation

#### A. Environmental Storytelling Props
- The room should tell a story without cutscenes. Players should piece it together while staying vulnerable.
- **Action:** Add readable notes/sticky-notes around the room:
  - A sticky note on the monitor: *"Due 23:59 — DO NOT FORGET"*
  - An empty Kopi cup on the desk (visual only, spent)
  - A crumpled failed printout in the bin
  - A WhatsApp notification sound playing on loop from a "phone" prop
- These cost zero code — just placed MeshInstance3Ds with Label3D or Decal nodes

#### B. The Terminal Flavor Lines Are Already Gold — Expand Them
- Current lines: gcc, NullPointer, SIPEMAS IPB, "Coffee driver mounted"
- **Action:** Add 10 more hyper-specific lines in `TerminalUIController.gd`'s `flavor_lines` array:
  ```
  "> git commit -m 'please work'"
  "> Warning: sleep_debt exceeds threshold"
  "> [SIPEMAS] Session expires in 00:07:32"
  "> Segmentation fault (core dumped)"
  "> TODO: fix this tomorrow [2 years ago]"
  "> npm install... (this may take a while)"
  "> ERROR: undefined reference to 'motivation'"
  "> Connection to professor server: TIMEOUT"
  "> Low battery on phone... 4%"
  "> 3 unread emails from: pak.dosen@ipb.ac.id"
  ```
- Each line is a tiny horror beat — the situation is recognizable before the Specter even appears

#### C. Sound Design for the Mundane → Wrong Transition
- (Already partially implemented in `HorrorAmbientManager`)
- **Action:** The AC hum, fridge buzz, and keyboard clicking should be present and normal at game start
- As sanity drops, these sounds should subtly distort — the AC hum develops a low moan underneath it, the fridge sound becomes a breathing rhythm
- This is the "things feel slightly off" technique — the horror is recognizing familiar sounds becoming wrong

#### D. The Deadline Is Personal
- **Action:** At game start, show: *"Your assignment is due in 20 minutes. You haven't started."*
- Not a tutorial popup — a message on the terminal screen before the game begins, like the player just opened their laptop
- This grounds the stakes immediately before anything supernatural happens

---

## Principle 4: Deliberately Clunky Interfaces
*"Forcing you to look down at a keyboard and correctly type `route ship` induces genuine panic. The interface fights you."*

### What This Game Already Has ✅
- Terminal requires manual typing of exact code patterns — already tactile
- `E` to interact, not auto-interact — requires deliberate action
- Battery management creates resource anxiety during crises

### The Psychological Goal
Every interface friction point should amplify the player's vulnerability when the Specter is active. The terminal should feel **twice as hard to type on** when you're scared.

### What's Missing / Needs Implementation

#### A. Pattern Difficulty Spikes When Specter Is Active
- **Action:** When `GameManager.is_specter_active == true`, `TerminalGame.gd` should switch to hard patterns only, regardless of current progress percentage
- Add a subtle red border/glow to the terminal window when the Specter is nearby
- This makes every typing session during Specter presence feel like typing under gunfire

#### B. Mistakes Have Consequences Beyond Red Text
- Currently, a wrong pattern just shows an error. It should cost something.
- **Action:** Wrong terminal input while the Specter is active: `SanitySystem.drain(5.0)` — typing the wrong thing while panicking makes you more panicked
- Add a brief `GLITCH_EFFECT` flash on wrong input during Specter presence

#### C. Terminal Input Distorts at Low Sanity
- **Action:** At sanity < 30%, randomly inject a fake character into the displayed pattern once per pattern load
- The pattern shown is *slightly* different from what the player needs to type
- Players must read more carefully — deliberate interface friction at the worst moment
- Implementation: in `_next_pattern()`, if `SanitySystem.current_sanity < 30`, occasionally replace one char in `current_pattern_label.text` with a visually similar wrong character (e.g., `0` → `O`, `l` → `1`)

#### D. Flashlight Toggle Is Already Clunky — Lean Into It
- The `F` key turns off the flashlight. When the Specter is close, the player will be fumbling for F while also trying to type.
- **Action:** Add a subtle UI reminder: when battery < 15%, flash a `[F] FLASHLIGHT LOW` warning
- This creates divided attention — exactly the kind of real-world stress the article describes

---

## Principle 5: The Unbroken First-Person Perspective
*"Because you never get a cinematic break, the tension never resets."*

### What This Game Already Has ✅
- Fully first-person, no cutscenes
- All lore delivered through messages and environmental text
- Player remains vulnerable during all narrative moments

### The Psychological Goal
The player must **never feel safe**. Tension resets when the brain detects a "safe" mode. Even the pause menu should feel slightly wrong.

### What's Missing / Needs Implementation

#### A. Jumpscares Have No Visual Yet
- Currently `EventBus.emit_jumpscare_fired()` emits but nothing visual happens beyond camera shake
- **Action:** For the 50% and 75% jumpscares, use a `CanvasLayer` to flash a single disturbing image (a face, a hand, distorted text) for 2–3 frames, then immediately remove it
- 2–3 frames is too fast to consciously process but the brain registers it — subliminal impact
- This is the same technique used in *The Ring* and many Puppet Combo games

#### B. The Pause Menu Should Feel Unsafe
- **Action:** While paused, keep `VHS_CRT` roll running and `GLITCH_EFFECT` at low intensity
- The pause overlay text should use a slightly degraded font or flicker effect
- Player should feel like even pausing doesn't fully remove them from the space

#### C. End Screen Is a Story Beat, Not a UI Screen
- Currently the end screen shows stats as a clean panel
- **Action:** For the "caught by Specter" loss, replace with a distorted, glitched screen:
  - `GLITCH_EFFECT` at maximum for the entire end screen
  - Text scrambles in like corrupted data
  - The "Try Again" button text should say something off: *"Wake up"* or *"Try again (y/n):"*

#### D. Environmental Lore Delivery (No Cutscenes Required)
- **Action:** Add `Label3D` or `Decal` nodes on in-world surfaces:
  - Sticky notes with handwritten text (use a handwriting font)
  - Browser tabs visible on the in-game monitor showing a student forum
  - A WhatsApp chat log visible on a prop phone (photo texture)
  - A calendar on the wall with today's date circled in red
- Players discover these while remaining fully vulnerable — the story is told in the room, not through a safe cutscene bubble

---

## Implementation Priority Matrix

| Task | Principle | Effort | Horror Impact |
|---|---|---|---|
| Apply PS1_SHADER to geometry | 1 | Low | ⭐⭐⭐ |
| Add VHS_CRT baseline overlay | 1 | Low | ⭐⭐⭐ |
| Expand terminal flavor lines | 3 | Very Low | ⭐⭐⭐ |
| Add environmental props/notes | 3 | Low | ⭐⭐⭐ |
| Jumpscare visual flash (2-3 frames) | 5 | Medium | ⭐⭐⭐ |
| Terminal harder when Specter active | 4 | Low | ⭐⭐⭐ |
| Wrong input costs sanity | 4 | Very Low | ⭐⭐ |
| Real system clock in HUD | 2 | Very Low | ⭐⭐ |
| Window title changes with state | 2 | Very Low | ⭐⭐ |
| ShaderController.gd | 1 | Medium | ⭐⭐⭐ |
| Sanity distorts terminal display | 4 | Medium | ⭐⭐⭐ |
| Pause menu feels unsafe (shaders) | 5 | Low | ⭐⭐ |
| Glitched loss end screen | 5 | Medium | ⭐⭐ |
| Microphone-reactive Specter | 2 | High | ⭐⭐⭐ |
| Headphone warning screen | 2 | Very Low | ⭐ |

---

## The Core Loop Redesigned Through This Lens

```
[Game opens]
Player sees: Their room. A laptop. A deadline in 20 minutes.
Player hears: AC hum. Keyboard ticks. A distant notification.
Player reads: "Your assignment is due. You haven't started."
             — No cutscene. Just the room. You're already there.

[25% progress]
The flavor lines get darker. The VHS roll kicks in faintly.
Something moans from the hallway. The terminal becomes slightly harder.
The window title changes.

[50% progress — Specter spawned]
Typing under gunfire. Every mistake costs sanity.
The Specter's footsteps compete with your own. The flashlight flickers.
You are trying to concentrate on code while something hunts you.
This is the most relatable fear in the game — being distracted from something important by something terrifying.

[75% progress]
Glass shatters. The room distorts. The AC hum has become a breath.
The terminal shows patterns with subtle wrong characters.
The player cannot trust their own eyes anymore.

[99% — Kernel Panic]
The screen breaks. The window title: "KERNEL PANIC — 21:58:02"
An alarm sounds. Everything is wrong.
The player's real clock reads 21:58. The deadline was real.

[100% — Win]
A single quiet chime. Upload complete.
The room goes silent for the first time.
The horror doesn't end so much as... stop.
```

---

> **Design Rule:** Every system should answer the question: *"Does this make the player feel like they are actually there?"*
> If it doesn't, cut it or redesign it.
