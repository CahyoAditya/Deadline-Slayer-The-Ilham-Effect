# Polish Plan

This plan turns the current playable prototype into a cleaner horror game loop.

## 1. Stabilize The Core Loop

- Verify project opens cleanly in Godot with no script parse errors.
- Test full loop from game start to win:
  - Open terminal.
  - Type patterns.
  - Reach `25%`, `50%`, `75%`, `99%`, and `100%`.
  - Confirm threshold events fire once.
  - Confirm `100%` triggers win.
- Test full loop from game start to loss:
  - Sanity reaches `0`.
  - Deadline reaches `0`.
  - Specter catches player.
- Add restart button or input after win/loss.
- Stop gameplay systems after win/loss so sanity, battery, and enemy do not keep updating.

## 2. Player Feel

- Tune movement speed, acceleration, jump height, and mouse sensitivity.
- Add head bob or subtle camera sway while walking.
- Add footstep audio based on movement.
- Add a proper pause menu.
- Make terminal opening and closing feel smoother:
  - Fade terminal in.
  - Lock movement reliably.
  - Restore mouse capture reliably.

## 3. Enemy Polish

- Replace capsule Specter with a proper ghost model or stylized mesh.
- Add spawn animation or sound cue at `25%`.
- Add clear warning before chase begins.
- Add patrol behavior before full chase.
- Add line-of-sight behavior:
  - Specter slows or stops when looked at.
  - Specter speeds up when not watched.
- Add increasing aggression at progress thresholds:
  - `25%`: appears and patrols.
  - `50%`: starts short chases.
  - `75%`: faster movement and more pressure.
  - `99%`: final chase.
- Tune catch distance and grace period through exported values.

## 4. Horror Events

- Implement `50%` doorway jumpscare visually.
- Implement `75%` desk jumpscare visually.
- Add light flicker event at `25%`.
- Add room blackout event at `75%`.
- Add screen distortion when sanity is low.
- Add random ambient events:
  - Knock sound.
  - Whisper.
  - Object movement.
  - Sudden laptop glitch.
- Make events non-repeating unless intentionally designed to repeat.

## 5. Terminal Mini-Game Polish

- Improve terminal layout and styling.
- Add typing sound on successful input.
- Add error beep and red flash on wrong input.
- Add output log flavor lines tied to progress.
- Add combo/bonus feedback for fast typing.
- Add difficulty tuning:
  - Easy patterns should be short.
  - Medium patterns should include function calls and conditionals.
  - Hard patterns should be longer and more precise.
- Add stats:
  - Patterns typed.
  - Accuracy.
  - Average typing time.
  - Progress gained.

## 6. HUD Polish

- Replace plain progress bars with themed UI.
- Add color changes:
  - Sanity green/yellow/red.
  - Battery white/dim.
  - Deadline red below 5 minutes.
- Add low sanity warning animation.
- Add low battery warning animation.
- Add interaction prompt styling.
- Add win/loss screen instead of temporary center text.
- Add readable font and consistent spacing.

## 7. Audio

- Replace `AudioManager` print stubs with real playback.
- Add audio buses:
  - Master
  - Music
  - SFX
  - Ambience
  - UI
- Add looping ambience:
  - Room hum.
  - Rain.
  - Clock.
- Add tension music that changes by progress or sanity.
- Add Specter sounds:
  - Whisper.
  - Footsteps.
  - Chase cue.
  - Catch sting.
- Add UI sounds:
  - Terminal key.
  - Error beep.
  - Confirm.
  - Pause.

## 8. Visual Polish

- Replace primitive terminal, kopi, battery, and Specter placeholders.
- Add simple materials for placeholder objects while final assets are missing.
- Improve room lighting:
  - Desk lamp focus.
  - Dark corners.
  - Flashlight usefulness.
- Add post-processing changes based on sanity:
  - Vignette stronger at low sanity.
  - Chromatic aberration stronger at low sanity.
  - Grain stronger during horror events.
- Add Specter material:
  - Transparent ghost look.
  - Emission or outline.
  - Flicker during jumpscares.

## 9. Game State And UX

- Add main menu.
- Add pause menu.
- Add settings menu:
  - Mouse sensitivity.
  - Audio volume.
  - Fullscreen toggle.
- Add win screen:
  - Submitted message.
  - Time remaining.
  - Final sanity.
  - Patterns typed.
- Add loss screen:
  - Loss reason.
  - Progress reached.
  - Time survived.
  - Retry button.
- Add save-free restart flow by reloading the main scene.

## 10. Balancing

- Tune deadline length.
- Tune progress per correct terminal entry.
- Tune sanity drain rate.
- Tune kopi restore amount.
- Tune battery drain rate.
- Tune battery pickup restore amount.
- Tune Specter speed by threshold.
- Tune terminal pattern difficulty.
- Test whether the player can win while under pressure.

## 11. Code Cleanup

- Split current `Player.gd` responsibilities:
  - `PlayerController.gd`
  - `PlayerInteraction.gd`
- Move temporary timer test systems out of production path when no longer needed.
- Replace debug-only messages with proper UI feedback.
- Add comments only where behavior is not obvious.
- Keep all cross-system communication through `EventBus`.
- Keep exported tuning values in `.tres` resources where possible.

## 12. Testing Checklist

- Start game: HUD appears and timer counts down.
- Walk, jump, look around.
- Flashlight toggles with `F`.
- Battery drains only while flashlight is on.
- Terminal opens with `E`.
- Terminal closes with `Esc`.
- Correct terminal input increases progress.
- Wrong terminal input does not increase progress.
- Progress thresholds fire once each.
- Specter appears at `25%`.
- Specter does not instantly kill on spawn.
- Specter kills when touching player after grace period.
- Sanity drains during play.
- Kopi restores sanity and disappears.
- Battery pickup restores battery and disappears.
- `99%` kernel panic triggers and resolves.
- `100%` win triggers.
- Timeout loss triggers.
- Sanity loss triggers.
- Specter catch loss triggers.
- Restart works from win/loss screen once implemented.

## 13. Suggested Implementation Order

1. Fix any Godot parse/runtime errors.
2. Build proper win/loss screens and restart flow.
3. Polish Specter behavior.
4. Polish terminal UI and feedback.
5. Add real audio through `AudioManager`.
6. Improve HUD styling.
7. Add horror event visuals.
8. Replace placeholder meshes.
9. Balance values from repeated playtests.
10. Remove or hide debug tools for release builds.
