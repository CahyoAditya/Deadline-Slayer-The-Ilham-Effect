# **SYSTEM\_ARCHITECTURE.md**

# **Deadline Slayer: The Ilham Effect**

A 3D First-Person Survival Horror Game built in Godot 4 Course: KOM1304 \- Grafika Komputer dan Visualisasi | Institut Pertanian Bogor | 2026

---

## **Table of Contents**

1. [Project Overview](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#1-project-overview)  
2. [Engine & Technology Stack](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#2-engine--technology-stack)  
3. [Directory Structure](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#3-directory-structure)  
4. [Core Systems Architecture](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#4-core-systems-architecture)  
5. [Scene Graph](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#5-scene-graph)  
6. [Scripts Reference](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#6-scripts-reference)  
7. [Shader Pipeline](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#7-shader-pipeline)  
8. [AI System: The Specter of Failure](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#8-ai-system-the-specter-of-failure)  
9. [Audio Architecture](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#9-audio-architecture)  
10. [UI / HUD Architecture](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#10-ui--hud-architecture)  
11. [Resource & Asset List](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#11-resource--asset-list)  
12. [Signal Bus (Event System)](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#12-signal-bus-event-system)  
13. [Data Flow Diagram](https://claude.ai/chat/83f83d9a-a450-44f3-891a-c8cdfc8486e5#13-data-flow-diagram)

---

## **1\. Project Overview**

**Game Title:** Deadline Slayer: The Ilham Effect **Genre:** First-Person Survival Horror (Meta-Game / Surrealist Horror) **Engine:** Godot 4.x **Rendering:** Forward+ (required for post-processing effects) **Target Platform:** PC (Windows/Linux)

### **Concept Summary**

The player is a computer science student locked in a small kost (boarding house) room. They must complete a coding assignment (a mini-game terminal) before the deadline while being hunted by a ghost entity called **"The Specter of Failure"** — a manifestation of academic anxiety. Resources (battery, sanity, kopi) are limited. The game ends when either the assignment is submitted (win) or sanity reaches zero / the specter catches the player (lose).

### **Core Gameplay Loop**

\[Player enters room\] → \[HUD initializes: Deadline Timer, Sanity Bar, Battery Meter\]  
        ↓  
\[Player interacts with Coding Terminal\] → \[Mini-game: Pattern Matching / Typing\]  
        ↓  
\[Progress increases (0% → 100%)\] → \[Specter AI becomes more aggressive\]  
        ↓  
\[At 25%, 50%, 75%: Event triggers fire\] → \[Jumpscare / Atmosphere shift\]  
        ↓  
\[At 99%: Kernel Panic event\] → \[Manual Reboot required\]  
        ↓  
\[At 100%: Final Boss Phase — 15-second brutal upload sequence\]  
        ↓  
\[WIN: Upload complete\] OR \[LOSE: Sanity \= 0 / Caught by Specter\]

---

## **2\. Engine & Technology Stack**

| Component | Technology |
| ----- | ----- |
| Game Engine | Godot 4.x |
| Scripting Language | GDScript (primary) |
| Rendering Backend | Forward+ |
| Shader Language | Godot Shading Language (GLSL-like) |
| Audio Engine | Godot AudioStreamPlayer3D |
| Version Control | Git |
| Asset Format (3D) | .glb / .gltf (Low-poly) |
| Asset Format (Textures) | .png / .webp |
| Asset Format (Audio) | .ogg (music/ambient), .wav (SFX) |

---

## **3\. Directory Structure**

res://  
├── project.godot  
├── scenes/  
│   ├── main/  
│   │   ├── Main.tscn                  \# Root scene, loads GameManager  
│   │   ├── MainMenu.tscn              \# Title screen  
│   │   └── GameOver.tscn             \# Lose/Win screen  
│   ├── world/  
│   │   ├── KostRoom.tscn             \# Main gameplay environment  
│   │   └── props/  
│   │       ├── Desk.tscn  
│   │       ├── CodingTerminal.tscn   \# Interactable mini-game node  
│   │       ├── Lamp.tscn  
│   │       ├── Trash.tscn  
│   │       ├── NasiPadangWrapper.tscn  
│   │       ├── ChicknTeaBox.tscn  
│   │       └── BatteryItem.tscn  
│   ├── player/  
│   │   ├── Player.tscn               \# First-person controller  
│   │   └── Camera.tscn               \# Camera with post-processing  
│   ├── entities/  
│   │   └── Specter.tscn              \# The Specter of Failure ghost AI  
│   └── ui/  
│       ├── HUD.tscn                  \# In-game HUD overlay  
│       ├── TerminalUI.tscn           \# Coding mini-game interface  
│       ├── PauseMenu.tscn  
│       └── KernelPanicScreen.tscn   \# 99% special event  
│  
├── scripts/  
│   ├── autoload/  
│   │   ├── GameManager.gd            \# AUTOLOAD: global game state  
│   │   ├── EventBus.gd               \# AUTOLOAD: global signal bus  
│   │   └── AudioManager.gd          \# AUTOLOAD: audio playback control  
│   ├── player/  
│   │   ├── PlayerController.gd      \# FPS movement & input  
│   │   ├── PlayerInteraction.gd     \# Raycast-based interaction  
│   │   └── SanitySystem.gd          \# Sanity resource logic  
│   ├── entities/  
│   │   └── SpecterAI.gd             \# Ghost AI state machine  
│   ├── systems/  
│   │   ├── ProgressSystem.gd        \# Tracks coding progress %  
│   │   ├── BatterySystem.gd         \# Flashlight battery drain  
│   │   ├── EventTrigger.gd          \# Fires events at 25/50/75/99/100%  
│   │   └── KernelPanicSystem.gd     \# 99% reboot mechanic  
│   ├── minigame/  
│   │   ├── TerminalGame.gd          \# Mini-game controller  
│   │   ├── PatternMatcher.gd        \# Regex/pattern matching logic  
│   │   └── TypingEvaluator.gd       \# Typing speed/accuracy scorer  
│   ├── ui/  
│   │   ├── HUDController.gd  
│   │   ├── TerminalUIController.gd  
│   │   └── KernelPanicUI.gd  
│   └── props/  
│       ├── InteractableBase.gd      \# Base class for all interactables  
│       ├── KopiItem.gd              \# Sanity recovery item  
│       └── BatteryPickup.gd        \# Battery restore item  
│  
├── shaders/  
│   ├── ToonShader.gdshader          \# Cel-shading for world/props  
│   ├── SpecterShader.gdshader       \# Translucent ghost material  
│   ├── PostProcess.gdshader         \# Vignette \+ Grain \+ Chromatic Aberration  
│   └── SanityDistort.gdshader      \# Distortion effect at low sanity  
│  
├── resources/  
│   ├── ProgressData.tres            \# Custom Resource: progress state  
│   ├── SanityData.tres              \# Custom Resource: sanity state  
│   ├── BatteryData.tres             \# Custom Resource: battery state  
│   ├── EventConfig.tres             \# Custom Resource: event thresholds  
│   └── patterns/  
│       ├── easy\_patterns.tres       \# Pattern bank for mini-game (easy)  
│       ├── medium\_patterns.tres  
│       └── hard\_patterns.tres  
│  
├── assets/  
│   ├── models/  
│   │   ├── kost\_room.glb  
│   │   ├── desk.glb  
│   │   ├── chair.glb  
│   │   ├── laptop.glb  
│   │   ├── specter.glb  
│   │   └── props/ (nasi\_padang.glb, chickntea.glb, trash\_pile.glb, etc.)  
│   ├── textures/  
│   │   ├── room\_diffuse.png  
│   │   ├── specter\_texture.png  
│   │   └── ui/ (terminal\_bg.png, hud\_frame.png, etc.)  
│   └── audio/  
│       ├── ambient/  
│       │   ├── room\_hum.ogg  
│       │   ├── clock\_tick.ogg  
│       │   └── rain\_outside.ogg  
│       ├── sfx/  
│       │   ├── jumpscare\_01.wav  
│       │   ├── jumpscare\_02.wav  
│       │   ├── specter\_whisper.wav  
│       │   ├── specter\_footstep.wav  
│       │   ├── keyboard\_type.wav  
│       │   ├── error\_beep.wav  
│       │   ├── kernel\_panic.wav  
│       │   └── upload\_complete.wav  
│       └── music/  
│           ├── menu\_theme.ogg  
│           └── tension\_loop.ogg  
│  
└── theme/  
    └── anime\_hud\_theme.tres         \# Godot Theme resource for UI styling

---

## **4\. Core Systems Architecture**

### **4.1 GameManager (Autoload Singleton)**

**File:** `res://scripts/autoload/GameManager.gd`

The central state machine for the entire game session. All other systems read from or write to GameManager.

\# GameManager.gd — Responsibilities  
extends Node

\# \--- State Enum \---  
enum GameState { MENU, PLAYING, PAUSED, KERNEL\_PANIC, GAME\_OVER, WIN }

\# \--- Exported Resources (Scriptable Object pattern) \---  
@export var progress\_data: ProgressData        \# .tres resource  
@export var sanity\_data: SanityData            \# .tres resource  
@export var battery\_data: BatteryData          \# .tres resource  
@export var event\_config: EventConfig          \# .tres resource

\# \--- Runtime State \---  
var current\_state: GameState \= GameState.MENU  
var deadline\_timer: float \= 0.0                \# Countdown in seconds  
var is\_specter\_active: bool \= false

\# \--- Key Methods \---  
\# func start\_game() → resets all resources, loads KostRoom.tscn  
\# func set\_state(new\_state: GameState) → transitions \+ fires EventBus signals  
\# func check\_lose\_conditions() → called every frame during PLAYING  
\# func trigger\_win() → plays upload animation, transitions to WIN  
\# func trigger\_lose(reason: String) → transitions to GAME\_OVER

### **4.2 EventBus (Autoload Signal Bus)**

**File:** `res://scripts/autoload/EventBus.gd`

Global decoupled signal relay. All systems communicate through this instead of direct node references.

\# EventBus.gd  
extends Node

\# Progress events  
signal progress\_changed(new\_percent: float)  
signal progress\_threshold\_reached(threshold: int)  \# 25, 50, 75, 99, 100

\# Sanity events  
signal sanity\_changed(new\_value: float)  
signal sanity\_critical()          \# \< 20%  
signal sanity\_depleted()          \# \= 0 → lose condition

\# Battery events  
signal battery\_changed(new\_value: float)  
signal battery\_depleted()         \# Flashlight off

\# Specter events  
signal specter\_spawned()  
signal specter\_sight\_broken()     \# Player looks away  
signal specter\_sight\_maintained() \# Player maintains eye contact  
signal specter\_caught\_player()    \# Lose condition

\# Game state events  
signal game\_paused()  
signal game\_resumed()  
signal kernel\_panic\_triggered()  
signal kernel\_panic\_resolved()  
signal jumpscare\_fired(jumpscare\_id: String)

### **4.3 ProgressSystem**

**File:** `res://scripts/systems/ProgressSystem.gd`

Manages the coding completion percentage. Linked to the TerminalGame mini-game output.

\# ProgressSystem.gd  
extends Node

var current\_progress: float \= 0.0   \# 0.0 to 100.0  
var thresholds\_fired: Array\[int\] \= \[\]

const THRESHOLDS \= \[25, 50, 75, 99, 100\]

func add\_progress(amount: float) \-\> void:  
    current\_progress \= clamp(current\_progress \+ amount, 0.0, 100.0)  
    EventBus.progress\_changed.emit(current\_progress)  
    \_check\_thresholds()

func \_check\_thresholds() \-\> void:  
    for t in THRESHOLDS:  
        if current\_progress \>= t and t not in thresholds\_fired:  
            thresholds\_fired.append(t)  
            EventBus.progress\_threshold\_reached.emit(t)

### **4.4 SanitySystem**

**File:** `res://scripts/player/SanitySystem.gd`

Manages the player's sanity. Drains passively and from Specter proximity. Recoverable via Kopi item.

\# SanitySystem.gd  
extends Node

var current\_sanity: float \= 100.0  
const PASSIVE\_DRAIN\_RATE: float \= 0.5      \# per second while playing  
const SPECTER\_DRAIN\_RATE: float \= 3.0      \# per second when specter is nearby  
const KOPI\_RESTORE\_AMOUNT: float \= 25.0

func \_process(delta: float) \-\> void:  
    if GameManager.current\_state \== GameManager.GameState.PLAYING:  
        \_drain(PASSIVE\_DRAIN\_RATE \* delta)  
        \# Additional drain injected by SpecterAI via EventBus

func \_drain(amount: float) \-\> void:  
    current\_sanity \= clamp(current\_sanity \- amount, 0.0, 100.0)  
    EventBus.sanity\_changed.emit(current\_sanity)  
    if current\_sanity \<= 20.0:  
        EventBus.sanity\_critical.emit()  
    if current\_sanity \<= 0.0:  
        EventBus.sanity\_depleted.emit()

func restore\_from\_kopi() \-\> void:  
    current\_sanity \= clamp(current\_sanity \+ KOPI\_RESTORE\_AMOUNT, 0.0, 100.0)  
    EventBus.sanity\_changed.emit(current\_sanity)

### **4.5 BatterySystem**

**File:** `res://scripts/systems/BatterySystem.gd`

Controls flashlight battery. Drains over time when flashlight is on. Refillable by pickup items.

\# BatterySystem.gd  
extends Node

var battery\_level: float \= 100.0  
var flashlight\_on: bool \= true  
const DRAIN\_RATE: float \= 1.0   \# % per second when on

func \_process(delta: float) \-\> void:  
    if flashlight\_on and GameManager.current\_state \== GameManager.GameState.PLAYING:  
        battery\_level \= clamp(battery\_level \- DRAIN\_RATE \* delta, 0.0, 100.0)  
        EventBus.battery\_changed.emit(battery\_level)  
        if battery\_level \<= 0.0:  
            flashlight\_on \= false  
            EventBus.battery\_depleted.emit()

### **4.6 EventTrigger**

**File:** `res://scripts/systems/EventTrigger.gd`

Listens to `EventBus.progress_threshold_reached` and fires the appropriate scripted event.

\# EventTrigger.gd — listens to EventBus  
func \_on\_threshold\_reached(threshold: int) \-\> void:  
    match threshold:  
        25:  \_fire\_event\_25()  
        50:  \_fire\_event\_50()  
        75:  \_fire\_event\_75()  
        99:  \_fire\_kernel\_panic()  
        100: GameManager.trigger\_win()

func \_fire\_event\_25() \-\> void:  
    \# Atmosphere: lights flicker, distant footsteps  
    \# Specter: begins patrolling  
    AudioManager.play\_sfx("specter\_whisper")  
    GameManager.is\_specter\_active \= true  
    EventBus.specter\_spawned.emit()

func \_fire\_event\_50() \-\> void:  
    \# Jumpscare: specter appears briefly in doorway  
    EventBus.jumpscare\_fired.emit("doorway\_jumpscare")  
    \# HP drain rate increases

func \_fire\_event\_75() \-\> void:  
    \# Room goes dark briefly  
    \# Specter movement speed increases  
    EventBus.jumpscare\_fired.emit("desk\_jumpscare")  
    AudioManager.play\_sfx("jumpscare\_02")

func \_fire\_kernel\_panic() \-\> void:  
    GameManager.set\_state(GameManager.GameState.KERNEL\_PANIC)  
    EventBus.kernel\_panic\_triggered.emit()

---

## **5\. Scene Graph**

Main.tscn  
└── Node (GameManager autoload reference)  
└── KostRoom.tscn \[World\]  
    ├── Environment  
    │   ├── DirectionalLight3D (main lamp)  
    │   ├── OmniLight3D (desk lamp)  
    │   └── WorldEnvironment (ambient \+ fog)  
    ├── RoomMesh (MeshInstance3D — kost\_room.glb)  
    ├── Props/  
    │   ├── Desk (StaticBody3D)  
    │   ├── CodingTerminal (Area3D \+ InteractableBase)  
    │   ├── NasiPadangWrapper (StaticBody3D)  
    │   ├── ChicknTeaBox (StaticBody3D)  
    │   ├── TrashPile (StaticBody3D)  
    │   ├── KopiItem (Area3D \+ KopiItem.gd)        ← consumable  
    │   └── BatteryPickup (Area3D \+ BatteryPickup.gd)  
    ├── Player.tscn  
    │   ├── CharacterBody3D (PlayerController.gd)  
    │   ├── Head (Node3D)  
    │   │   ├── Camera3D (Camera.tscn)  
    │   │   │   ├── SubViewport (PostProcess canvas)  
    │   │   │   └── SpotLight3D (Flashlight)  
    │   │   └── RayCast3D (PlayerInteraction.gd)  
    │   └── SanitySystem (Node — SanitySystem.gd)  
    ├── Specter.tscn (spawned at runtime)  
    │   ├── CharacterBody3D (SpecterAI.gd)  
    │   ├── MeshInstance3D (specter.glb \+ SpecterShader)  
    │   └── AudioStreamPlayer3D (spatial footsteps)  
    └── HUD.tscn (CanvasLayer)  
        ├── DeadlineTimer (Label)  
        ├── SanityBar (TextureProgressBar)  
        ├── BatteryMeter (TextureProgressBar)  
        ├── ProgressBar (TextureProgressBar)  
        └── TerminalUI.tscn (hidden until interaction)

---

## **6\. Scripts Reference**

### **Player Scripts**

| Script | Extends | Purpose |
| ----- | ----- | ----- |
| `PlayerController.gd` | CharacterBody3D | WASD movement, mouse look, crouch |
| `PlayerInteraction.gd` | Node | RayCast3D → detects interactables, calls `interact()` |
| `SanitySystem.gd` | Node | Sanity state, drain, recovery |

### **System Scripts**

| Script | Extends | Purpose |
| ----- | ----- | ----- |
| `ProgressSystem.gd` | Node | Tracks 0–100% coding progress |
| `BatterySystem.gd` | Node | Flashlight battery drain/restore |
| `EventTrigger.gd` | Node | Fires scripted events at progress thresholds |
| `KernelPanicSystem.gd` | Node | Handles 99% reboot sequence |

### **Entity Scripts**

| Script | Extends | Purpose |
| ----- | ----- | ----- |
| `SpecterAI.gd` | CharacterBody3D | Ghost AI: patrol, chase, weeping-angel freeze |

### **Mini-game Scripts**

| Script | Extends | Purpose |
| ----- | ----- | ----- |
| `TerminalGame.gd` | Control | Manages terminal mini-game session state |
| `PatternMatcher.gd` | RefCounted | Validates player input vs target pattern |
| `TypingEvaluator.gd` | RefCounted | Scores accuracy/speed, returns progress increment |

### **UI Scripts**

| Script | Extends | Purpose |
| ----- | ----- | ----- |
| `HUDController.gd` | CanvasLayer | Binds HUD elements to EventBus signals |
| `TerminalUIController.gd` | Control | Shows/hides terminal, relays input to TerminalGame |
| `KernelPanicUI.gd` | CanvasLayer | Animates BSOD-style screen, countdown reboot |

### **Autoload Scripts**

| Script | Role |
| ----- | ----- |
| `GameManager.gd` | Global game state, win/lose conditions |
| `EventBus.gd` | Decoupled signal relay for all systems |
| `AudioManager.gd` | Centralized SFX/music playback |

---

## **7\. Shader Pipeline**

### **7.1 ToonShader (`res://shaders/ToonShader.gdshader`)**

Applied to: all world props, room mesh, desk, items.

* Cel-shading with 3–4 discrete light bands  
* Hard outline rendering via inverted-hull method (separate pass)  
* Supports albedo texture \+ tint color parameter

// ToonShader.gdshader — key logic outline  
shader\_type spatial;  
uniform sampler2D albedo\_texture : source\_color;  
uniform int shade\_steps : hint\_range(2, 6\) \= 3;  
uniform float outline\_thickness \= 0.03;  
uniform vec4 outline\_color : source\_color \= vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {  
    float NdotL \= dot(NORMAL, LIGHT);  
    float stepped \= floor(NdotL \* float(shade\_steps)) / float(shade\_steps);  
    ALBEDO \= texture(albedo\_texture, UV).rgb \* stepped;  
}

### **7.2 SpecterShader (`res://shaders/SpecterShader.gdshader`)**

Applied to: Specter mesh.

* Additive transparency with time-based vertex distortion  
* Edge glow effect (fresnel)  
* Flicker at low sanity / close proximity

### **7.3 PostProcess Shader (`res://shaders/PostProcess.gdshader`)**

Applied via SubViewport \+ CanvasItem shader on Camera.

* **Vignette:** radial darkening from edges  
* **Film Grain:** animated noise overlay  
* **Chromatic Aberration:** RGB channel offset, intensity scales with low sanity

// PostProcess.gdshader — parameters  
uniform float vignette\_strength : hint\_range(0.0, 2.0) \= 0.6;  
uniform float grain\_amount : hint\_range(0.0, 1.0) \= 0.08;  
uniform float chroma\_offset : hint\_range(0.0, 0.02) \= 0.003;  
// chroma\_offset is driven by SanitySystem at runtime via ShaderMaterial.set\_shader\_parameter()

### **7.4 SanityDistort Shader (`res://shaders/SanityDistort.gdshader`)**

Applied as a full-screen overlay when sanity \< 30%.

* Screen-space UV warping (sinusoidal)  
* Intensity inversely proportional to sanity value  
* Disabled above 30% sanity

---

## **8\. AI System: The Specter of Failure**

**File:** `res://scripts/entities/SpecterAI.gd` **Scene:** `res://scenes/entities/Specter.tscn`

### **State Machine**

States:  
  INACTIVE    → waiting to be activated (before 25% progress)  
  PATROL      → wandering room on NavMesh path  
  CHASE       → actively moving toward player  
  FROZEN      → player is looking at specter (Weeping Angel mechanic)  
  JUMPSCARE   → scripted close-encounter

### **Weeping Angel Mechanic**

The Specter only moves when the player is **not** looking at it.

\# SpecterAI.gd  
func \_is\_player\_looking() \-\> bool:  
    var to\_specter \= (global\_position \- player.global\_position).normalized()  
    var player\_forward \= \-player.get\_node("Head/Camera3D").global\_transform.basis.z  
    var dot \= player\_forward.dot(to\_specter)  
    return dot \> 0.6   \# Within \~53° FOV cone

func \_process(delta: float) \-\> void:  
    match current\_state:  
        State.PATROL:  
            if \_is\_player\_looking():  
                current\_state \= State.FROZEN  
                EventBus.specter\_sight\_maintained.emit()  
            else:  
                \_move\_on\_path(delta)  
        State.FROZEN:  
            if not \_is\_player\_looking():  
                current\_state \= State.CHASE  
                EventBus.specter\_sight\_broken.emit()  
        State.CHASE:  
            if \_is\_player\_looking():  
                current\_state \= State.FROZEN  
            else:  
                \_chase\_player(delta)  
                \_drain\_player\_sanity(delta)

### **Speed Scaling by Progress**

\# Specter gets faster as coding progress increases  
func \_get\_current\_speed() \-\> float:  
    var p \= GameManager.progress\_data.current\_progress  
    return lerp(2.0, 6.5, p / 100.0)  \# min 2.0, max 6.5 units/sec

### **Lose Condition**

When the Specter reaches the player (overlap detection):

func \_on\_body\_entered(body: Node3D) \-\> void:  
    if body.is\_in\_group("player"):  
        EventBus.specter\_caught\_player.emit()  
        GameManager.trigger\_lose("caught\_by\_specter")

---

## **9\. Audio Architecture**

**File:** `res://scripts/autoload/AudioManager.gd`

### **Audio Buses**

Master  
├── Music     (volume: \-6 dB, effects: none)  
├── SFX       (volume: 0 dB, effects: none)  
└── Ambient   (volume: \-3 dB, effects: Reverb Room)

### **3D Spatial Audio Nodes**

All Specter sounds use `AudioStreamPlayer3D` attached to the Specter node for automatic panning and attenuation.

| Audio File | Bus | Trigger |
| ----- | ----- | ----- |
| `room_hum.ogg` | Ambient | Game start, loops |
| `clock_tick.ogg` | Ambient | Game start, loops |
| `rain_outside.ogg` | Ambient | Game start, loops |
| `specter_whisper.wav` | SFX | 25% threshold |
| `specter_footstep.wav` | SFX | Specter CHASE state |
| `jumpscare_01.wav` | SFX | 50% threshold |
| `jumpscare_02.wav` | SFX | 75% threshold |
| `keyboard_type.wav` | SFX | Each correct keystroke in mini-game |
| `error_beep.wav` | SFX | Wrong input in mini-game |
| `kernel_panic.wav` | SFX | 99% threshold |
| `upload_complete.wav` | SFX | Win condition |
| `tension_loop.ogg` | Music | Plays during PLAYING state |

### **Sanity-Driven Audio Effects**

\# AudioManager.gd — sanity listener  
func \_on\_sanity\_changed(value: float) \-\> void:  
    \# Pitch shift tension music downward as sanity drops  
    var pitch \= remap(value, 0.0, 100.0, 0.75, 1.0)  
    $Music/TensionLoop.pitch\_scale \= pitch  
    \# Increase reverb on SFX bus  
    var reverb: AudioEffectReverb \= AudioServer.get\_bus\_effect(sfx\_bus\_idx, 0\)  
    reverb.room\_size \= remap(value, 0.0, 100.0, 0.9, 0.3)

---

## **10\. UI / HUD Architecture**

### **10.1 HUD Layout (`res://scenes/ui/HUD.tscn`)**

Styled with anime aesthetic via `res://theme/anime_hud_theme.tres`.

HUD (CanvasLayer)  
├── TopBar (HBoxContainer)  
│   ├── DeadlineTimerLabel     — "DEADLINE: 14:32" (red countdown)  
│   └── ProgressLabel          — "COMPILE: 47%"  
├── BottomLeft (VBoxContainer)  
│   ├── SanityLabel            — "SANITY"  
│   ├── SanityBar (TextureProgressBar)  
│   ├── BatteryLabel           — "BATTERY"  
│   └── BatteryMeter (TextureProgressBar)  
├── ProgressBar (bottom center, TextureProgressBar)  
└── InteractHint (Label, center-bottom) — "\[E\] Interact"

### **10.2 Terminal UI (`res://scenes/ui/TerminalUI.tscn`)**

Shown when player interacts with the CodingTerminal prop.

TerminalUI (Control, full-screen overlay)  
├── Background (ColorRect — dark translucent)  
├── TerminalWindow (PanelContainer — anime OS style)  
│   ├── TitleBar ("deadline\_slayer\_v0.99 — bash")  
│   ├── OutputLog (RichTextLabel — scrollable, shows code output)  
│   ├── CurrentPattern (Label — shows pattern to type)  
│   ├── InputField (LineEdit — player types here)  
│   └── StatusBar (Label — "LINES COMPILED: 234/500")  
└── CloseHint (Label — "\[ESC\] Return to room")

### **10.3 Kernel Panic Screen (`res://scenes/ui/KernelPanicScreen.tscn`)**

Full-screen, blocks gameplay. Player must press `CTRL+ALT+DEL` equivalent (custom key combo).

KernelPanicScreen (CanvasLayer, z\_index: 100\)  
├── Background (ColorRect — deep blue, \#0000AA)  
├── ErrorText (RichTextLabel — ASCII art kernel panic message)  
├── CountdownLabel — "Auto-reboot in: 5..."  
└── ManualRebootHint — "Press \[R\] to manually reboot now"

---

## **11\. Resource & Asset List**

### **Custom Resources (Scriptable Objects Pattern)**

**`ProgressData.tres`**

class\_name ProgressData extends Resource  
@export var current\_progress: float \= 0.0  
@export var max\_progress: float \= 100.0  
@export var progress\_per\_correct\_input: float \= 2.0

**`SanityData.tres`**

class\_name SanityData extends Resource  
@export var max\_sanity: float \= 100.0  
@export var passive\_drain\_per\_second: float \= 0.5  
@export var specter\_drain\_per\_second: float \= 3.0  
@export var kopi\_restore\_amount: float \= 25.0

**`BatteryData.tres`**

class\_name BatteryData extends Resource  
@export var max\_battery: float \= 100.0  
@export var drain\_per\_second: float \= 1.0  
@export var pickup\_restore\_amount: float \= 50.0

**`EventConfig.tres`**

class\_name EventConfig extends Resource  
@export var thresholds: Array\[int\] \= \[25, 50, 75, 99, 100\]  
@export var jumpscare\_duration: float \= 1.5  
@export var kernel\_panic\_auto\_reboot\_time: float \= 10.0

**`PatternSet.tres` (easy / medium / hard)**

class\_name PatternSet extends Resource  
@export var difficulty: String \= "easy"  
@export var patterns: Array\[String\] \= \[\]  
\# Example patterns (easy): \["print('Hello')", "x \= 5", "if True:"\]  
\# Example patterns (hard): \["for i in range(len(arr)):", "def \_\_init\_\_(self):"\]

### **3D Model Assets**

| File | Poly Count | Notes |
| ----- | ----- | ----- |
| `kost_room.glb` | \~2000 | Single-room environment, low-poly |
| `desk.glb` | \~300 | Main interaction point |
| `laptop.glb` | \~400 | On desk, becomes terminal |
| `specter.glb` | \~800 | Humanoid ghost, rigged for animation |
| `nasi_padang.glb` | \~100 | Prop, no collision needed |
| `chickntea.glb` | \~100 | Prop |
| `trash_pile.glb` | \~200 | Atmosphere prop |

---

## **12\. Signal Bus (Event System)**

All systems are **decoupled**. They emit and receive signals only through `EventBus.gd`. No direct node references between unrelated systems.

ProgressSystem ──emit──► EventBus.progress\_threshold\_reached  
                                        │  
                          ┌─────────────┼──────────────┐  
                          ▼             ▼              ▼  
                    EventTrigger   HUDController   SpecterAI  
                    (fires events) (updates HUD)  (speeds up)

SanitySystem ──emit──► EventBus.sanity\_changed  
                                │  
                    ┌───────────┼──────────────┐  
                    ▼           ▼              ▼  
              HUDController  AudioManager  PostProcess shader  
              (updates bar)  (pitch shift) (chroma aberration)

SpecterAI ──emit──► EventBus.specter\_caught\_player  
                                │  
                                ▼  
                          GameManager.trigger\_lose()

---

## **13\. Data Flow Diagram**

INPUT (Keyboard/Mouse)  
        │  
        ▼  
PlayerController.gd ──────────► PlayerInteraction.gd  
(movement, camera look)          (raycast → detects CodingTerminal)  
        │                                  │  
        │                                  ▼  
        │                        TerminalGame.gd (mini-game)  
        │                                  │  
        │                     PatternMatcher \+ TypingEvaluator  
        │                                  │  
        │                        ProgressSystem.add\_progress()  
        │                                  │  
        │                         EventBus.progress\_changed  
        │                                  │  
        │              ┌───────────────────┼────────────────────┐  
        │              ▼                   ▼                    ▼  
        │        HUDController      EventTrigger          SpecterAI  
        │        (progress bar)     (threshold checks)    (speed scale)  
        │  
        ▼  
SanitySystem.\_process()  
        │  
        ▼  
EventBus.sanity\_changed  
        │  
  ┌─────┴──────────────────┐  
  ▼                         ▼  
HUDController          AudioManager  
(sanity bar update)    (pitch / reverb)  
                            │  
                            ▼  
                     PostProcess shader  
                     (chromatic aberration scale)

# 

# **Deadline Slayer: The Ilham Effect — Development Plan**

## **AI AGENT INSTRUCTIONS**

**Read this section first before executing any task.**

This document is the authoritative implementation plan for the Godot 4 game **"Deadline Slayer: The Ilham Effect"**. It is designed to be consumed by an AI coding agent (e.g. Claude, Copilot, or similar) to implement the game step by step.

### **Rules for AI Execution**

1. **Always reference `SYSTEM_ARCHITECTURE.md`** for file paths, class names, signal names, and resource structures before writing any code.  
2. **Use GDScript** for all scripts. Do not use C\#.  
3. **Engine version:** Godot 4.x (not Godot 3). APIs differ significantly. Use `CharacterBody3D`, not `KinematicBody`. Use `@export`, not `export`. Use `super()` not `.()`.  
4. **Scriptable Object pattern:** Game balance values (sanity drain rate, battery drain, progress per keypress) must live in `.tres` Resource files, not hardcoded. See `resources/` section in SYSTEM\_ARCHITECTURE.md.  
5. **All inter-system communication** goes through `EventBus.gd` signals. Do not create direct node references between unrelated scenes.  
6. **Do not break the build.** Each week's output must be a playable/runnable Godot project, even if features are incomplete.  
7. **Commit message format:** `[WeekN] Short description of what was implemented`  
8. When implementing shaders, always target the **Forward+** renderer.  
9. When uncertain about a Godot 4 API, prefer the official Godot 4 documentation over assumptions.

---

## **Project Timeline: 4 Weeks**

| Week | Theme | Deliverable |
| ----- | ----- | ----- |
| 1 | Fondasi & Asset Building | Playable empty room \+ player movement \+ shaders |
| 2 | Gameplay & Logic | Working terminal mini-game \+ all resource systems |
| 3 | Horror AI & Audio | Specter AI \+ jumpscare events \+ spatial audio |
| 4 | Final Phase & Polish | Kernel panic \+ final boss upload \+ bug fixing |

**Total estimated scope:** \~4 weeks × \~20 hours \= \~80 development hours across 4 members.

**Member roles:**

* **Azka:** Project lead, shaders, post-processing, environment  
* **Aditya:** Gameplay systems, mini-game logic, UI/UX  
* **Calvin:** Specter AI, audio integration, event system  
* **Ilham:** World/prop modeling, props, testing, balancing

---

## **Week 1: Fondasi & Asset Building ("The Shell")**

### **Goals**

Stand up the Godot project, implement core player controls, build the room environment, and get shaders running.

### **Tasks**

#### **1.1 — Project Setup**

* \[ \] Create new Godot 4 project named `DeadlineSlayer`  
* \[ \] Set renderer to **Forward+** (required for post-processing)  
* \[ \] Configure `project.godot`:  
  * Application name: `Deadline Slayer: The Ilham Effect`  
  * Main scene: `res://scenes/main/Main.tscn`  
  * Resolution: 1920×1080, stretch mode: `canvas_items`  
* \[ \] Create full directory structure as defined in `SYSTEM_ARCHITECTURE.md § 3`  
* \[ \] Create `EventBus.gd` and `GameManager.gd` as Autoloads (Project → Project Settings → Autoload)  
* \[ \] Create `AudioManager.gd` as Autoload

**Acceptance Criteria:** Project opens in Godot editor without errors. All directories exist.

---

#### **1.2 — Environment Design: Kost Room**

* \[ \] Import or block out `KostRoom.tscn`:  
  * Room dimensions: \~6m × 5m × 3m (small kost room scale)  
  * **Walls:** 4 walls \+ floor \+ ceiling using `MeshInstance3D` \+ `StaticBody3D` \+ `CollisionShape3D`  
  * **Door:** closed, non-openable (decorative). Placed on one wall.  
  * **Window:** on the wall opposite the door, small, with curtains  
* \[ \] Place props as `StaticBody3D` nodes:  
  * Desk (center-left area) — main gameplay anchor  
  * Chair (behind desk)  
  * Bookshelf (back wall, optional)  
  * Trash pile (corner near door)  
  * Nasi Padang wrapper (on desk)  
  * Chick n Tea box (on desk or floor)  
* \[ \] Set up lighting:  
  * `DirectionalLight3D` simulating night (low intensity, cool blue tint)  
  * `OmniLight3D` at desk lamp position (warm yellow, range 3m)  
  * `WorldEnvironment`: ambient light very low, enable fog (near: 5m, density: 0.05)

**Asset fallback:** If .glb models are not yet available, use colored `BoxMesh` / `CylinderMesh` placeholders with correct dimensions. Label them with name labels.

**Acceptance Criteria:** Room is visible and walkable. Props are placed. Lighting looks moody.

---

#### **1.3 — First-Person Character Controller**

* \[ \] Create `Player.tscn`:

  * Root: `CharacterBody3D` (script: `PlayerController.gd`)  
  * Child: `CollisionShape3D` (CapsuleShape, height 1.8m, radius 0.3m)  
  * Child: `Head` (Node3D, position Y=0.8m)  
    * Child: `Camera3D` (fov: 75\)  
    * Child: `SpotLight3D` (flashlight: range 8m, angle 25°, enabled by default)  
    * Child: `RayCast3D` (length 2.5m, InteractionLayer only)

\[ \] Implement `PlayerController.gd`:

 Movement: WASD, speed 4.0 m/s  
Sprint: Shift key, speed 6.5 m/s (drains sanity slightly faster)  
Mouse look: sensitivity 0.002 rad/pixel  
Vertical clamp: \-80° to \+80°  
Gravity: use Godot default (9.8 m/s²)  
Flashlight toggle: F key → toggles SpotLight3D.visible

*   
* \[ \] Implement `PlayerInteraction.gd`:

  * On `_input(event)`: if `E` key pressed, check RayCast3D collision  
  * If hit body has method `interact()`, call `body.interact(self)`  
  * Show/hide `InteractHint` label in HUD based on raycast hit

**Acceptance Criteria:** Player can walk around room, look freely, toggle flashlight, and `[E]` hint appears near interactables.

---

#### **1.4 — Shader Setup**

##### **ToonShader (`res://shaders/ToonShader.gdshader`)**

* \[ \] Implement cel-shading with 3 shade steps  
* \[ \] Implement outline via inverted-hull pass (or `CULL_FRONT` trick)  
* \[ \] Parameters exposed: `shade_steps` (int), `albedo_texture`, `outline_thickness` (float), `outline_color` (vec4)  
* \[ \] Apply to: room walls, floor, ceiling, all props

##### **PostProcess Shader (`res://shaders/PostProcess.gdshader`)**

* \[ \] Implement as a CanvasItem shader on a full-screen `ColorRect` inside the Camera's SubViewport  
* \[ \] Features:  
  * **Vignette:** `vignette_strength` uniform, darkens edges  
  * **Film Grain:** `grain_amount` \+ `TIME` for animated noise  
  * **Chromatic Aberration:** `chroma_offset` uniform, separates R/G/B channels by UV offset  
* \[ \] Wire `chroma_offset` to SanitySystem: as sanity decreases, offset increases  
  * Sanity 100% → `chroma_offset = 0.001`  
  * Sanity 0% → `chroma_offset = 0.015`

**Acceptance Criteria:** Room has cel-shaded look with visible outlines. Vignette and grain are visible. Chromatic aberration increases when sanity variable is manually set low in the editor.

---

#### **Week 1 Deliverable Summary**

✅ Godot project created with directory structure  
✅ KostRoom.tscn with props and lighting  
✅ Player FPS controller with flashlight  
✅ ToonShader applied to world  
✅ PostProcess shader pipeline working  
✅ EventBus and GameManager autoloads registered

---

## **Week 2: Gameplay & Logic ("The Brain")**

### **Goals**

Implement all resource systems (sanity, battery, progress) and the core coding terminal mini-game with full UI.

### **Tasks**

#### **2.1 — Custom Resources (Scriptable Objects)**

* \[ \] Create `res://scripts/systems/ProgressData.gd` (class\_name ProgressData)  
* \[ \] Create `res://scripts/systems/SanityData.gd` (class\_name SanityData)  
* \[ \] Create `res://scripts/systems/BatteryData.gd` (class\_name BatteryData)  
* \[ \] Create `res://scripts/systems/EventConfig.gd` (class\_name EventConfig)  
* \[ \] Create `res://scripts/minigame/PatternSet.gd` (class\_name PatternSet)  
* \[ \] Instantiate `.tres` files for each in `res://resources/`  
* \[ \] Reference all `.tres` files from `GameManager.gd` via `@export` variables  
* \[ \] Populate `patterns/easy_patterns.tres`, `medium_patterns.tres`, `hard_patterns.tres` with 20 patterns each:  
  * Easy: single statements (`x = 5`, `print("hello")`)  
  * Medium: function calls, conditionals  
  * Hard: loops, comprehensions, class methods

**Acceptance Criteria:** Resources load without errors. All values can be tweaked in the Godot Inspector without changing code.

---

#### **2.2 — Sanity System**

* \[ \] Implement `SanitySystem.gd` (attached to Player node):  
  * Passive drain: `SanityData.passive_drain_per_second` × delta every frame while GameState \== PLAYING  
  * Emit `EventBus.sanity_changed(value)` every frame  
  * Emit `EventBus.sanity_critical()` when below 20%  
  * Emit `EventBus.sanity_depleted()` when 0 → triggers `GameManager.trigger_lose("sanity_depleted")`  
* \[ \] Implement `KopiItem.gd`:  
  * On `interact()`: call `SanitySystem.restore_from_kopi()`  
  * Show "SANITY \+" floating text (Label3D)  
  * Despawn item after use  
  * Place 2 Kopi items in room at game start

**Acceptance Criteria:** Sanity bar visible in HUD, drains over time, Kopi item restores it.

---

#### **2.3 — Battery System**

* \[ \] Implement `BatterySystem.gd` (as child of Player or GameManager):  
  * Drains `BatteryData.drain_per_second` per second while flashlight is on  
  * On depletion: disable SpotLight3D, emit `EventBus.battery_depleted()`  
  * Manual flashlight toggle (F key) calls `BatterySystem.set_flashlight(bool)`  
* \[ \] Implement `BatteryPickup.gd`:  
  * On `interact()`: restore `BatteryData.pickup_restore_amount` to battery  
  * Despawn after use  
  * Place 1 battery item in room

**Acceptance Criteria:** Battery drains, flashlight goes off when depleted, pickup restores it.

---

#### **2.4 — Progress System**

* \[ \] Implement `ProgressSystem.gd`:  
  * As defined in `SYSTEM_ARCHITECTURE.md § 4.3`  
  * Listen for results from `TerminalGame.gd`  
  * Emit `EventBus.progress_changed(percent)` and threshold signals  
* \[ \] Connect to `EventTrigger.gd` (stub — full implementation in Week 3\)

**Acceptance Criteria:** Progress value increases when mini-game is played. Console logs threshold events at 25/50/75%.

---

#### **2.5 — Coding Terminal Mini-Game**

* \[ \] Create `CodingTerminal.tscn` prop (Area3D on desk):  
  * On player `interact()`: show `TerminalUI.tscn`  
  * Captures keyboard input while open (disable player movement input)  
  * ESC closes terminal, returns control to player  
* \[ \] Implement `TerminalGame.gd`:  
  * On open: load a pattern from the current difficulty `PatternSet`  
  * Display pattern in `CurrentPattern` label  
  * Player types in `InputField (LineEdit)`  
  * On `text_submitted`: call `PatternMatcher.check(input, pattern)`  
  * If correct: add progress, show next pattern, play `keyboard_type.wav`  
  * If incorrect: flash red, play `error_beep.wav`, no penalty (just retry)  
  * Difficulty escalates: easy patterns for 0–33%, medium for 34–66%, hard for 67–100%  
* \[ \] Implement `PatternMatcher.gd`:  
  * `func check(input: String, pattern: String) -> bool`  
  * Strip leading/trailing whitespace before comparison  
  * Case-sensitive  
* \[ \] Implement `TypingEvaluator.gd`:  
  * Track time per pattern  
  * If typed in \< 3 seconds: `progress_bonus = 1.5×`  
  * If typed in \> 8 seconds: `progress_bonus = 0.8×`  
* \[ \] Implement `TerminalUIController.gd`:  
  * Binds `InputField` to `TerminalGame`  
  * Scrolls `OutputLog` with fake compiler output text (flavor text)  
  * Updates `StatusBar` with progress label

**Terminal flavor output examples (add \~30 lines to OutputLog as progress increases):**

\> gcc \-o main main.c  
main.c:47: warning: implicit declaration of 'printff'  
\> Compiling module 3/12...  
\> \[OK\] SanityCheck.dll loaded  
\> ERROR: NullPointerException at deadline.cpp:99  
\> Retrying... 

**Acceptance Criteria:** Player can open terminal, type patterns, see progress bar fill, close terminal and resume walking.

---

#### **2.6 — HUD Implementation**

* \[ \] Implement `HUD.tscn` and `HUDController.gd`:  
  * **DeadlineTimer:** counts down from 20:00 (configurable in EventConfig), turns red below 5:00  
  * **SanityBar:** `TextureProgressBar`, green → yellow → red as sanity drops  
  * **BatteryMeter:** `TextureProgressBar`, white bar  
  * **ProgressBar:** bottom-center, shows 0–100% compile progress  
  * **InteractHint:** appears when raycast hits interactable  
* \[ \] Apply `anime_hud_theme.tres`:  
  * Custom panel style with thin borders  
  * Font: use a monospace font (e.g. JetBrains Mono .ttf added to project)  
  * Color scheme: dark background (\#0D0D0D), green accent (\#39FF14 neon), red for danger

**Acceptance Criteria:** All HUD elements visible, update in real time from EventBus signals.

---

#### **Week 2 Deliverable Summary**

✅ All .tres resource files created and wired to GameManager  
✅ SanitySystem drains and is restorable  
✅ BatterySystem drains flashlight  
✅ ProgressSystem tracks and emits thresholds  
✅ Terminal mini-game fully playable  
✅ HUD fully functional and styled

---

## **Week 3: Horror AI & Audio ("The Soul")**

### **Goals**

Implement the Specter AI with Weeping Angel mechanic, jumpscare event system, and all spatial audio.

### **Tasks**

#### **3.1 — Specter Scene & Shader**

* \[ \] Create `Specter.tscn`:  
  * Root: `CharacterBody3D` (script: `SpecterAI.gd`)  
  * Child: `CollisionShape3D` (CapsuleShape, 1.8m tall)  
  * Child: `MeshInstance3D` (specter.glb or placeholder `CapsuleMesh`)  
    * Material: `SpecterShader.gdshader`  
  * Child: `NavigationAgent3D` (for NavMesh pathfinding)  
  * Child: `AudioStreamPlayer3D` (footstep sounds, bus: SFX)  
  * Child: `Area3D` \+ `CollisionShape3D` (catch radius: 0.8m)  
* \[ \] Implement `SpecterShader.gdshader`:  
  * `render_mode blend_add` (additive, ghost-like)  
  * Fresnel glow on edges  
  * `TIME`\-based vertex displacement (subtle floating motion)  
  * `flicker_intensity` uniform: set to 0 normally, 1.0 during jumpscare

---

#### **3.2 — Specter AI State Machine**

* \[ \] Implement `SpecterAI.gd` as described in `SYSTEM_ARCHITECTURE.md § 8`  
* \[ \] States: INACTIVE → PATROL → CHASE → FROZEN → JUMPSCARE  
* \[ \] NavMesh: bake `NavigationRegion3D` in KostRoom.tscn to cover walkable floor  
* \[ \] Patrol path: 4 waypoints around the room edges (Vector3 array defined in Inspector)  
* \[ \] Weeping Angel check: FOV dot product \> 0.6 \= player is looking  
* \[ \] Speed scaling: linear lerp from 2.0 to 6.5 based on progress %  
* \[ \] On INACTIVE → PATROL trigger: `EventBus.specter_spawned` (fired at 25% progress)  
* \[ \] On CATCH: `EventBus.specter_caught_player` → `GameManager.trigger_lose("caught")`  
* \[ \] Sanity drain while specter is in CHASE and within 4m of player: `SanityData.specter_drain_per_second`

---

#### **3.3 — Event Trigger System**

* \[ \] Implement `EventTrigger.gd` fully:

   **25% Threshold:**

  * Spawn Specter at predefined spawn point (behind bookshelf / outside door gap)  
  * Flicker `OmniLight3D` at desk (3 flickers over 1 second)  
  * Play `specter_whisper.wav`  
  * Log to OutputLog: `> WARNING: Unknown process consuming memory...`  
* **50% Threshold:**

  * Scripted jumpscare: Specter teleports to doorway, faces player for 0.5s, disappears  
  * Play `jumpscare_01.wav`  
  * `chroma_offset` spikes to 0.02 for 1 second then normalizes  
  * Log to OutputLog: `> ERROR: Segmentation fault (core dumped)`  
* **75% Threshold:**

  * Room lights OFF for 3 seconds (only flashlight available)  
  * Specter appears directly behind the player, visible for 0.3s if player turns  
  * Play `jumpscare_02.wav`  
  * Specter speed permanently increases by 1.5×  
  * Log to OutputLog: `> CRITICAL: Stack overflow at 0x00000000`  
* **99% Threshold:**

  * Fire `EventBus.kernel_panic_triggered()`  
  * `GameManager.set_state(KERNEL_PANIC)`  
  * Show `KernelPanicScreen.tscn`  
  * Specter is frozen during kernel panic  
  * Player must press `R` within `EventConfig.kernel_panic_auto_reboot_time` seconds to reboot  
  * If player reboots: `GameManager.set_state(PLAYING)`, progress stays at 99%, Specter resumes  
  * If timer runs out: auto-reboot (same result)  
* **100% Threshold:**

  * **Final Boss Phase:** 15-second upload sequence  
  * During upload: Specter enters permanent CHASE, max speed  
  * HUD shows upload progress bar (0→100% over 15 sec)  
  * Player must survive 15 seconds without being caught  
  * If survived: `GameManager.trigger_win()`

---

#### **3.4 — Audio Setup**

* \[ \] Configure 3 audio buses in Godot AudioServer: `Music`, `SFX`, `Ambient`  
* \[ \] Add `AudioEffectReverb` to `Ambient` bus  
* \[ \] Implement `AudioManager.gd`:  
  * `func play_sfx(name: String)` → looks up stream by name, plays on SFX bus  
  * `func play_music(name: String)` → crossfades to new music track  
  * `func play_ambient(name: String)` → starts ambient loop  
  * `func _on_sanity_changed(value)` → adjusts pitch and reverb as documented in `SYSTEM_ARCHITECTURE.md § 9`  
* \[ \] Hook AudioManager to `EventBus.sanity_changed` signal  
* \[ \] Add all audio files to `assets/audio/` directories  
* \[ \] `AudioStreamPlayer3D` on Specter: plays `specter_footstep.wav` when in CHASE state, 3D attenuation model: `Logarithmic`, max distance: 8m

---

#### **3.5 — SanityDistort Shader**

* \[ \] Implement `SanityDistort.gdshader`:  
  * Full-screen CanvasItem shader overlay (separate ColorRect, z\_index above world)  
  * UV sine-wave distortion: `UV += sin(UV.y * 20.0 + TIME * 3.0) * distort_amount`  
  * `distort_amount` uniform: 0 at sanity \> 30%, scales to 0.03 at sanity \= 0%  
* \[ \] Wire to `EventBus.sanity_changed` → update `ShaderMaterial.set_shader_parameter("distort_amount", ...)`

---

#### **Week 3 Deliverable Summary**

✅ Specter spawns at 25% and patrols room  
✅ Weeping Angel mechanic functional  
✅ All three jumpscare events fire at thresholds  
✅ Kernel Panic screen at 99%  
✅ Spatial audio working for Specter  
✅ Sanity affects audio pitch and screen distortion

---

## **Week 4: Final Phase & Polish ("The Deadline")**

### **Goals**

Implement the final win/lose conditions, polish all systems, fix bugs, balance difficulty.

### **Tasks**

#### **4.1 — Win Condition: Upload to Class IPB**

* \[ \] Implement the **Final Boss Phase** (100% progress trigger):

  * Show a new HUD overlay: `UploadBar (TextureProgressBar)` — fills over 15 seconds  
  * Specter enters max-speed permanent CHASE  
  * Background music switches to final tension track

OutputLog rapidly scrolls upload progress text:  
 \> Uploading to SIPEMAS IPB...\> 34%... 67%... 89%...\> Connection timeout. Retrying...\> 100% — UPLOAD COMPLETE

*   
  * If player survives 15 seconds: trigger win  
  * Timer node: `SceneTree.create_timer(15.0)` → on timeout: `GameManager.trigger_win()`  
* \[ \] Win screen (`GameOver.tscn` with win variant):

  * "SUBMITTED." in large green text  
  * Shows: time remaining, patterns typed, sanity at end  
  * Play `upload_complete.wav`  
  * Button: "Play Again" → reload scene

---

#### **4.2 — Lose Conditions**

* \[ \] Implement `GameManager.trigger_lose(reason: String)`:

  * Fade to black (Tween on CanvasLayer ColorRect)  
  * Show lose message based on reason:  
    * `"sanity_depleted"` → *"Your mind collapsed before the deadline."*  
    * `"caught_by_specter"` → *"The Specter claimed you. Deadline missed."*  
    * `"timeout"` → *"Time's up. The professor has logged out."*  
  * Show stats: progress reached, time survived  
  * Button: "Try Again"  
* \[ \] Implement deadline timeout:

  * `GameManager.deadline_timer` counts down each frame  
  * On reaching 0: `GameManager.trigger_lose("timeout")`

---

#### **4.3 — Kernel Panic System (Polish)**

* \[ \] `KernelPanicScreen.tscn` — polish the BSOD aesthetic:  
  * ASCII art header: `:( The Specter is in your system.`  
  * Display fake memory dump hex lines (procedurally generated)  
  * Countdown: auto-reboot in 10 seconds (configurable in EventConfig)  
  * `R` key triggers immediate reboot  
  * Reboot animation: screen goes black → flickers → game resumes  
* \[ \] While kernel panic is active: Specter is frozen in place (set `current_state = FROZEN` without player-look condition)

---

#### **4.4 — Bug Fixing & Balancing Checklist**

**Balancing Targets:**

| Parameter | Target Feel | Tuning Lever |
| ----- | ----- | ----- |
| Sanity drain rate | Should reach critical (\~20%) around 70% progress with no Kopi | `SanityData.passive_drain_per_second` |
| Specter speed at 100% | Fast enough to be stressful, catchable only if player is stationary | `SpecterAI._get_current_speed()` max value |
| Battery life | Should last \~5 minutes continuous (full game is \~15 min) | `BatteryData.drain_per_second` |
| Mini-game difficulty | Player should reach 100% in \~10–12 minutes with focus | `ProgressData.progress_per_correct_input` |
| Kernel panic timer | Long enough to read screen but urgent | `EventConfig.kernel_panic_auto_reboot_time` |

**Bug Checklist:**

* \[ \] Specter does not clip through walls (NavMesh baked correctly)  
* \[ \] Player cannot walk through props (all have StaticBody3D \+ CollisionShape)  
* \[ \] Terminal input does not register while terminal is closed  
* \[ \] Flashlight does not drain when off  
* \[ \] Kopi and Battery items cannot be picked up twice  
* \[ \] Kernel Panic cannot be triggered if already in KERNEL\_PANIC state (guard condition)  
* \[ \] Win cannot trigger if player was just caught (race condition guard)  
* \[ \] HUD updates correctly after game restart (all resources reset)  
* \[ \] Audio does not stack on repeated jumpscare calls (check `is_playing()` before calling play)

---

#### **4.5 — Final Polish**

**Visual Polish:**

* \[ \] Add `AnimationPlayer` to desk lamp: subtle flicker animation (loop)  
* \[ \] Add particle system (`GPUParticles3D`) to Specter: floating dust/pixels  
* \[ \] Post-processing intensity scales gradually: at game start effects are subtle, by 75% they are intense  
* \[ \] Add `Label3D` "floating text" feedback: "+PROGRESS", "+SANITY", "WRONG" above terminal

**Audio Polish:**

* \[ \] Add subtle heartbeat sound that increases tempo as sanity drops below 30%  
* \[ \] Add clock tick ambient that speeds up as deadline timer reaches final 3 minutes  
* \[ \] Add typing clatter ambiance that plays on loop while terminal is open

**UX Polish:**

* \[ \] Add brief introductory cutscene / title card when game starts (5 seconds, skippable)  
* \[ \] Add in-game "lore" sticky notes on walls (Label3D or Decal) with funny/ominous messages:  
  * *"Do not look at it."*  
  * *"The wifi disconnected. There is no internet. There is only the terminal."*  
  * *"Ilham said we'd get an A. Ilham lied."*  
* \[ \] Main menu: animated background (rotating kost room camera), title, Start / Quit buttons

---

#### **Week 4 Deliverable Summary**

✅ Win condition: 15-second upload final phase  
✅ All three lose conditions functional  
✅ Kernel Panic screen fully polished  
✅ Balanced difficulty values in .tres resources  
✅ Bug checklist cleared  
✅ Visual and audio polish applied  
✅ Main menu functional  
✅ Game is completable end-to-end

---

## **Appendix A: Godot 4 Quick Reference**

\# Correct Godot 4 syntax reminders:

\# Signal connection (not .connect("signal", self, "method"))  
EventBus.sanity\_changed.connect(\_on\_sanity\_changed)

\# Exports  
@export var my\_resource: SanityData

\# Tween (not Tween.interpolate\_property)  
var tween \= create\_tween()  
tween.tween\_property(node, "modulate:a", 0.0, 1.0)

\# Timer  
await get\_tree().create\_timer(2.0).timeout

\# Input  
if Input.is\_action\_just\_pressed("ui\_accept"):

\# Navigation  
$NavigationAgent3D.target\_position \= player.global\_position  
var next\_pos \= $NavigationAgent3D.get\_next\_path\_position()

\# ShaderMaterial parameter update  
material.set\_shader\_parameter("chroma\_offset", value)

\# Group check  
if body.is\_in\_group("player"):

---

## **Appendix B: GDScript Patterns Used in This Project**

### **InteractableBase (base class for all interactables)**

\# res://scripts/props/InteractableBase.gd  
class\_name InteractableBase  
extends Area3D

func interact(player: Node) \-\> void:  
    pass  \# Override in subclass

### **Pattern for .tres-driven systems**

\# Read from resource, never hardcode game values  
var drain \= GameManager.sanity\_data.passive\_drain\_per\_second

### **EventBus subscription pattern**

func \_ready() \-\> void:  
    EventBus.sanity\_changed.connect(\_on\_sanity\_changed)

func \_on\_sanity\_changed(value: float) \-\> void:  
    sanity\_bar.value \= value

---

## **Appendix C: Known Limitations & Out of Scope**

* **Mobile/controller support:** Not in scope for this submission.  
* **Save/load system:** Not in scope. Game is designed as a single \~15-minute session.  
* **Multiple rooms:** Only one kost room. The Specter does not leave the room.  
* **Multiplayer:** Not in scope.  
* **Localization:** All text in Bahasa Indonesia / informal bilingual (as appropriate to theme).

---

*Document generated for: Deadline Slayer: The Ilham Effect* *Kelompok 5, KOM1304 — Institut Pertanian Bogor, 2026*

