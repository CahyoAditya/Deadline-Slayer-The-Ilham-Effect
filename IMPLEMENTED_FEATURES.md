# Implemented Features

This file documents the current playable systems added from `SYSTEM ARCHITECTURE.md`.

## Core Autoloads

The project now registers these global systems in `project.godot`:

- `EventBus`: global signal bus for cross-system events.
- `AudioManager`: placeholder central audio API.
- `GameManager`: game state, deadline countdown, win/lose flow.
- `ProgressSystem`: coding progress from 0 to 100.
- `EventTrigger`: reacts to progress thresholds.
- `KernelPanicSystem`: handles the 99% kernel panic event.
- `GlobalTimer`: separate 5-minute test timer.
- `DebugUI`: toggleable debug panel.
- `TimerEndTestMessage`: test listener for the global timer event.

## Controls

- `WASD`: move
- `Mouse`: look
- `Space`: jump
- `E`: interact
- `F`: toggle flashlight
- `F3`: toggle debug UI
- `P`: pause/resume
- `Esc`: close terminal, or toggle mouse capture during normal play

## HUD

Scene: `res://Scenes/UI/HUD.tscn`

The HUD shows:

- Deadline timer
- Sanity bar
- Battery meter
- Coding progress bar
- Interaction hint
- Temporary center-screen messages
- Pause overlay
- Win/loss end screen

The HUD also changes colors for low sanity, low battery, and deadline danger.

The HUD updates through `EventBus` signals:

- `deadline_changed`
- `sanity_changed`
- `battery_changed`
- `progress_changed`
- `interact_hint_changed`
- `message_requested`

## Deadline And Game State

Script: `res://Scripts/Autoload/GameManager.gd`

`GameManager` starts the game automatically and counts down from `EventConfig.deadline_seconds`, currently `1200` seconds.

Lose conditions:

- Deadline reaches `0`
- Sanity reaches `0`
- Specter catches the player

Win condition:

- Progress reaches `100%`

Win/loss now shows an end screen with:

- Result title
- Reason text
- Progress reached
- Final sanity
- Final battery
- Time survived
- `Try Again` button
- `Quit` button

## Pause

Press `P` to pause or resume the game.

The pause overlay includes a `Resume` button. Movement, sanity drain, battery drain, terminal interaction, and enemy chase stop while paused.

## Terminal Mini-Game

Scene: `res://Scenes/Props/CodingTerminal.tscn`

How to use:

1. Walk to the terminal prop.
2. Press `E`.
3. Type the shown code pattern exactly.
4. Press `Enter`.
5. Correct input adds progress.
6. Press `Esc` to close the terminal.

The terminal now gives feedback:

- Correct input shows green progress feedback.
- Wrong input shows red error feedback.
- The target pattern is labeled with `TYPE EXACTLY`.

Patterns are loaded from:

- `res://Resources/Patterns/easy_patterns.tres`
- `res://Resources/Patterns/medium_patterns.tres`
- `res://Resources/Patterns/hard_patterns.tres`

Difficulty changes based on progress:

- `0-33%`: easy
- `34-66%`: medium
- `67-100%`: hard

## Progress Threshold Events

Script: `res://Scripts/Systems/EventTrigger.gd`

Thresholds:

- `25%`: activates Specter placeholder and shows a message.
- `50%`: fires doorway jumpscare event.
- `75%`: fires desk jumpscare event.
- `99%`: triggers kernel panic.
- `100%`: triggers win.

## Sanity System

Script: `res://Scripts/Player/SanitySystem.gd`

Sanity drains while the game is playing. When sanity reaches `0`, `GameManager` triggers a loss.

Kopi pickups restore sanity.

Scene:

- `res://Scenes/Props/KopiItem.tscn`

How to use:

1. Walk to a Kopi item.
2. Press `E`.
3. Sanity is restored.
4. The item disappears.

## Battery And Flashlight

Script: `res://Scripts/Systems/BatterySystem.gd`

The player has a `SpotLight3D` flashlight attached to the camera.

How to use:

- Press `F` to toggle flashlight.
- Battery drains while the flashlight is on.
- When battery reaches `0`, the flashlight turns off.
- Battery pickups restore battery.

Scene:

- `res://Scenes/Props/BatteryPickup.tscn`

## Specter Placeholder

Scene: `res://Scenes/Entities/Specter.tscn`

The Specter is currently a simple placeholder capsule. It starts hidden and becomes visible when the `25%` progress threshold fires.

If it gets close enough to the player, it emits `specter_caught_player`, which causes a loss.

## Kernel Panic

Script: `res://Scripts/Systems/KernelPanicSystem.gd`

At `99%` progress, the game enters `KERNEL_PANIC` state, shows a message, waits for `EventConfig.kernel_panic_auto_reboot_time`, then returns to `PLAYING`.

This is currently a functional stub, not a full animated UI screen.

## Debug UI

Script: `res://Scripts/Autoload/DebugUI.gd`

Press `F3` to open the debug panel.

Available buttons:

- `Start 5m`: start the global 5-minute timer.
- `Start 10s`: start a 10-second test timer.
- `Stop`: stop the timer.
- `Reset`: reset timer.
- `Finish Now`: immediately fire the timer-finished event.
- `Progress +10`: add 10% progress.
- `Lose Sanity`: drain 25 sanity.
- `Hide`: close debug UI.

## Global Timer Test

Script: `res://Scripts/Autoload/GlobalTimer.gd`

The timer emits through `EventBus.five_minutes_elapsed` when finished.

Example listener:

```gdscript
func _ready() -> void:
	EventBus.five_minutes_elapsed.connect(_on_five_minutes_elapsed)

func _on_five_minutes_elapsed() -> void:
	print("Timer ended")
```

`TimerEndTestMessage` currently listens to this event and shows `Timer is over.`

## Data Files

Editable resource files:

- `res://Resources/Data/progress_data.tres`
- `res://Resources/Data/sanity_data.tres`
- `res://Resources/Data/battery_data.tres`
- `res://Resources/Data/event_config.tres`

Use these to tweak progress gain, max sanity, passive sanity drain, battery drain, deadline length, event thresholds, and kernel panic duration.

## Known Stubbed Areas

These systems exist in functional placeholder form but are not full production implementations yet:

- Audio playback only prints requested SFX/music IDs.
- Specter AI is a basic chase placeholder.
- Kernel panic has no full-screen custom UI yet.
- Jumpscares emit events and messages but do not play custom visual sequences yet.
- Props use simple primitive meshes.
