# 🎨 Horror Shader Implementation Plan
## Deadline Slayer: The Ilham Effect

---

## Visual Philosophy: PS1 Horror Aesthetic

The game should look like a **cursed PS1 game from 1998 that someone recorded onto VHS, then found in a dumpster 20 years later**. Think *Silent Hill*, *Clocktower*, *Koudelka* — low color depth, wobbly vertices, scanlines, pitch-black corridors lit only by a flashlight, and a sense that the screen itself is breaking.

The visual horror stack works in **layers**, driven by the same game events that trigger audio. Sanity affects one set. The Specter active state affects another. Jumpscares blow them all up at once.

---

## Shader Inventory & Roles

| Shader | Type | Horror Role |
|---|---|---|
| `PS1_SHADER.gdshader` | `spatial` (3D material) | Core PS1 look — vertex jitter + affine texture warping on all geometry |
| `PS1_PSX_POSTPROCESSING.gdshader` | `canvas_item` | Color depth reduction + dithering as screen-wide post-process |
| `VHS_CRT.gdshader` | `canvas_item` | Scanlines, roll lines, static noise, CRT warp — used for screen corruption |
| `PostProcess.gdshader` | `canvas_item` | **Already active** — vignette, chromatic aberration, film grain (driven by SanitySystem) |
| `SanityDistort.gdshader` | `canvas_item` | **Already active** — sinusoidal wave distortion at low sanity |
| `GLITCH_EFFECT.gdshader` | `canvas_item` | Horizontal block glitches + color channel split — jumpscare/kernel panic |
| `SQUIGGLE_VISION.gdshader` | `canvas_item` | Wobbling/squiggly outline on objects — hallucination effect at low sanity |
| `GOD_RAYS.gdshader` | `canvas_item` | Volumetric light shafts — from the flashlight or through a doorway |
| `DITHER_GRADIENT.gdshader` | `canvas_item` | Banded dithering between palette colors — PS1 color banding effect |
| `3D_PIXEL_ART_OUTLINE.gdshader` | `spatial` (fullscreen quad) | Edge-detection outlines on 3D geometry — PS1 polygon edge look |
| `ITEM_HIGHLIGHTER.gdshader` | `spatial` | Highlight interactable items — keep usable, swap color based on sanity |
| `PIXEL_PERFECT_OUTLINE_SHADER.gdshader` | `canvas_item` | UI/2D pixel outlines |

---

## The PS1 Layer Stack (Bottom → Top)

```
[ 3D World rendered with PS1_SHADER on all materials ]
         ↓
[ 3D_PIXEL_ART_OUTLINE on a fullscreen quad (edge detection) ]
         ↓
[ PostProcess.gdshader  — vignette + grain + aberration  (sanity-driven, LIVE) ]
         ↓
[ SanityDistort.gdshader — wave warp (sanity < 30%, LIVE) ]
         ↓
[ PS1_PSX_POSTPROCESSING — color depth + dithering (always on, subtle) ]
         ↓
[ VHS_CRT.gdshader — scanlines + roll (intensity driven by game state) ]
         ↓
[ GLITCH_EFFECT.gdshader — block glitches (jumpscare / kernel panic only) ]
```

> `SQUIGGLE_VISION` and `GOD_RAYS` are applied to specific scene nodes, not fullscreen.

---

## Game State → Shader Mapping

### 🟢 CALM state (0–25% progress, sanity > 75%)
- `PS1_SHADER`: **jitter = 0.3**, affine mapping ON → subtle wobbly vertices, classic PS1
- `PS1_PSX_POSTPROCESSING`: **colors = 14**, dithering ON → slightly washed-out palette
- `VHS_CRT`: **scanlines_opacity = 0.15**, roll = OFF, noise = 0.02 → barely there, just enough CRT texture
- `PostProcess`: vignette = 0.4, grain = 0.03, aberration = 0.1 → baseline dark atmosphere
- `3D_PIXEL_ART_OUTLINE`: shadow_strength = 0.3 → gives geometry hard shadow edges

### 🟡 TENSION state (Specter spawned)
- `PS1_SHADER`: **jitter increases to 0.55** → vertices start wobbling more noticeably
- `PS1_PSX_POSTPROCESSING`: **colors drops to 10** → palette degrades, colors look more wrong
- `VHS_CRT`: **roll turns ON**, roll_speed = 4, noise = 0.15 → VHS tape tracking interference
- `PostProcess`: aberration increases to 0.8 → colors begin to separate at edges
- `GLITCH_EFFECT`: **enabled but low** — shake_rate = 0.05, barely visible random flicker

### 🔴 HORROR ACTIVE state (Specter timer < 4s)
- `PS1_SHADER`: **jitter = 0.8** → geometry becoming extremely unstable
- `PS1_PSX_POSTPROCESSING`: **colors = 6**, dither_size = 2 → brutal color reduction, very PS1
- `VHS_CRT`: roll_speed = 12, noise = 0.35, static_noise = 0.12 → signal is dying
- `PostProcess`: aberration = 18.0, vignette nearly closes screen (driven by sanity anyway)
- `GLITCH_EFFECT`: shake_rate = 0.2, shake_power = 0.04 → regular glitch bursts

### ⚡ JUMPSCARE (0.0s timer → BANG)
- All shaders are ramped to MAX for 1.2 seconds (camera shake duration):
  - `GLITCH_EFFECT`: shake_rate = 0.8, shake_power = 0.08, shake_speed = 12 → screen tearing
  - `VHS_CRT`: roll_speed = 30, distort_intensity = 0.15 → tape completely breaking
  - `PS1_PSX_POSTPROCESSING`: colors = 2 → near-monochrome flash
  - `PostProcess`: aberration = 28.0 → extreme color split
- Then snap back to TENSION values after camera shake ends

### 🖥️ KERNEL PANIC state
- `GLITCH_EFFECT`: shake_rate = 0.4, shake_power = 0.06, shake_block_size = 15 → digital corruption
- `VHS_CRT`: roll ON at max speed, static_noise = 0.2
- `PS1_PSX_POSTPROCESSING`: colors = 4 → looks like BSOD era graphics
- `PostProcess`: grain = 0.4 → heavy static

### 🧠 SANITY Degradation (already partially driven by PostProcess)
**Additionally add:**
- At sanity < 50%: `SQUIGGLE_VISION` activates on the Specter mesh — it appears to warp/breathe
- At sanity < 30%: `PS1_SHADER` jitter bumps +0.15 passively (independent of specter state)
- At sanity < 15%: `VHS_CRT` adds subtle roll even in calm state — reality is breaking

---

## New Node/Script Required

### `Scripts/UI/ShaderController.gd` — New Script (on PostProcessController or a sibling node)

This script manages all `ShaderMaterial` parameter updates in one place, driven by EventBus signals:

```gdscript
# Connects to:
# EventBus.sanity_changed         → already handled by PostProcessController
# EventBus.specter_spawned        → switch to TENSION preset
# EventBus.specter_sight_broken   → fade back to CALM
# EventBus.jumpscare_fired        → JUMPSCARE blast + timed restore
# EventBus.kernel_panic_triggered → KERNEL_PANIC preset
# EventBus.kernel_panic_resolved  → fade back to TENSION
# EventBus.game_won               → snap to CALM (all clean)
# EventBus.game_lost              → freeze on current degraded state

# Key methods:
# set_shader_preset(preset_name, tween_duration)
# _jumpscare_blast()          → instant max, timed restore
# _tick_sanity_shader(value)  → extend PostProcessController with PS1 jitter
```

**Parameters controlled:**
| Shader | Parameters |
|---|---|
| `PS1_SHADER` (material param) | `jitter` |
| `PS1_PSX_POSTPROCESSING` | `colors`, `dither_size`, `enabled` |
| `VHS_CRT` | `scanlines_opacity`, `roll`, `roll_speed`, `noise_opacity`, `static_noise_intensity` |
| `GLITCH_EFFECT` | `shake_rate`, `shake_power`, `shake_speed` |

---

## PS1_SHADER Application Strategy

**Apply to:** All 3D MeshInstance3D materials in the scene (room geometry, furniture, the Specter).

The shader's key parameters:
- `jitter = 0.5` — the classic wobbly PS1 polygon look. Lower = tighter. Higher = Silent Hill.
- `affine_texture_mapping = true` — textures warp toward camera edges, the iconic PS1 look.
- `jitter_depth_independent = true` — jitter scales correctly regardless of distance.

For the **Specter entity specifically**, set jitter higher (0.7+) even at baseline so it always looks slightly wrong and unstable.

---

## SQUIGGLE_VISION Usage (Hallucination Layer)

Applied to: **Specter MeshInstance3D material** as a 2D canvas overlay, or as a `CanvasLayer` child.

- At sanity > 50%: **disabled**
- At sanity 50–30%: strength = 0.3, fps = 4 (slow, nauseating wobble)
- At sanity < 30%: strength = 0.8, fps = 8 (fast, reality-dissolving)

The effect makes the specter look like it's **made of melting rubber**, amplifying the uncanny horror of its design.

---

## GOD_RAYS Usage

Applied to: **A CanvasLayer node positioned above the scene**, triggered by EventBus.

- Default: **OFF** — the environment should be dark and oppressive
- When flashlight is ON: subtle upward god rays from the flashlight position (pale white/blue tint)
- During kernel panic: sickly green god rays to indicate digital corruption

---

## VHS_CRT Horror Settings Reference

The key parameters for horror escalation:

| State | scanlines | roll | noise | static | warp |
|---|---|---|---|---|---|
| Calm | 0.15 | OFF | 0.02 | 0.01 | 0.5 |
| Tension | 0.25 | ON/4 | 0.15 | 0.04 | 1.0 |
| Horror Active | 0.35 | ON/12 | 0.30 | 0.10 | 2.0 |
| Jumpscare | 0.50 | ON/30 | 0.50 | 0.20 | 4.0 |
| Kernel Panic | 0.40 | ON/20 | 0.40 | 0.20 | 1.5 |

---

## Implementation Order

1. **Apply PS1_SHADER to all 3D materials** in the scene — instant PS1 look
2. **Set up shader ColorRect stack** in the scene tree (one ColorRect per post-process shader, in order)
3. **Write `ShaderController.gd`** and connect to EventBus
4. **Extend `PostProcessController.gd`** to also drive `PS1_SHADER` jitter via exported NodePath to the material
5. **Add SQUIGGLE_VISION** to the Specter node as a material overlay
6. **Add GOD_RAYS** to a CanvasLayer, connect to flashlight_toggled signal
7. **Tune values in-editor** using the exported uniforms — the presets above are starting points

---

## Quick Horror Wins (Highest Impact First)

| Priority | Change | Impact |
|---|---|---|
| ⭐⭐⭐ | Apply `PS1_SHADER` to all geometry | Transforms entire look immediately |
| ⭐⭐⭐ | Activate `VHS_CRT` at low opacity baseline | Adds CRT texture instantly |
| ⭐⭐⭐ | Drive `GLITCH_EFFECT` from jumpscare event | Dramatic visual punch on scares |
| ⭐⭐ | `PS1_PSX_POSTPROCESSING` with colors=12 | Subtle color banding always active |
| ⭐⭐ | `SQUIGGLE_VISION` on Specter at low sanity | Makes monster feel wrong/alive |
| ⭐ | `GOD_RAYS` from flashlight | Atmospheric volumetric lighting |
| ⭐ | `3D_PIXEL_ART_OUTLINE` on scene quad | Hard polygon edges, retro look |
