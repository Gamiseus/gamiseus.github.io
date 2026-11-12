# QuarterMaster changelog

Versions are `Major.Minor.Patch`.

- **Major**: sweeping overhaul of the whole loader. Never bumped automatically. Next planned: 2.0, at the full launcher and site release.
- **Minor**: large update; things behave noticeably differently.
- **Patch**: ordinary work; fixes and small changes that keep behaviour, or corrections to the current minor or major version.

## 1.2.0

- launcher: Assets view on the Patches tab lists sounds, images and fonts that two sources replace
- launcher: pick the winner for a group of files or one file; stored as a fix, undo under Fixes
- launcher: pick the faction for a side when two factions replace it
- factions leave alone files a player gave to another mod or to the game
- faction images and sounds stay after the game reloads a file
- faction weapon pools keep weapons another mod added
- the game reports which mod's file each replaced asset ended up being
- mods page: "replaces a game file" marks use the game's full file list
- plans: `asset_choices`, `asset_exclusions`, `factions` (plan schema 4, written only when used)
- wiki: Assets view, faction pick, pool behaviour
- saves that load with mods are marked with the profile, the mods and the values each mod writes
- launcher: Saves screen shows values left by mods no profile on the slot loads
- launcher: Clean up removes such values on request, after a backup; values two mods wrote stay
- added `save_content` in `mod.json`: a mod's weapons become their base weapon while the mod is off
- a test launch without mods does not mark or change saves
- wiki: Saves and your mod
- QuarterMaster's wrappers (save check, faction functions) are put back when a mod replaces the function during loading
- a wrapper that was put back passes straight through, so its part runs once per call
- launcher: Diagnostics has "Trace globals..." for a diagnostic test run
- a diagnostic test run notes which mod sets each watched global, and counts who calls each watched function
- the trace is kept with the run in the profile's run log; normal launches are not traced
- wiki: diagnostic test run, wrappers QuarterMaster puts back
- images are shown at a size separate from their resolution: a replacement takes the original's size
- added `[sprites]` in `qm.toml`: `scale`, `like`, `size` per image
- added `QM.Sprites` (`setSize`, `setScale`, `matchSize`, `reset`, `rawSize`, `scaleOf`)
- added feature name `sprite_sizes`
- removed the "dimension mismatch" warning; a replacement of another shape is reported instead
- wiki: image resolution and size, `QM.Sprites`
- Steam not running: message box, then the game closes, instead of a silent crash
- wiki: Steam must be running
- tests: one integration test program per crate (`tests/suite/`), 62 test programs down to 23
- tests: legacy app tests moved to `ui/tests/` and run by `check.ps1`
- tests: shared helpers deduplicated; one `support::exclusive()` guard replaces four per-file environment locks
- tests: integration, launcher and legacy app tests kept local (`.gitignore`); unit tests stay in the repository
- tests: removed the unused patch benchmarks (and `criterion`), the legacy Python suite, and the 1024 px screenshot set
- added `TESTING.md`
- added `image` in `[publish]`: a picture for the mod's card in the mod list
- editor schema for `qm.toml` knows the `[publish]` table
- wiki: `image`, schema addresses

## 1.1.0

- added debug mode (`-debug`, `QM_DEBUG=1`, launcher switch)
- console window only in debug mode
- dump commands (`qm.dump_game_files`) only in debug mode
- added `qm.dump_patched()`
- added dump keys: Ctrl+Shift+D, Ctrl+Shift+Alt+D, Ctrl+Shift+P
- debug mode dumps every loaded file; otherwise only patched files
- added developer commands (`-dev`, `QM_DEV=1`, launcher switch): AI overlay (F1), dev blast (F5)
- added `qm.debug`, `qm.dev`
- launcher: Debug mode and Developer commands switches replace the console switch
- fixed `on_click` ignored on `config.toml` button options
- removed `disable_console` launch setting (use `--disable-console`)
- wiki: faction, anchor, compatibility and publishing guides folded in; standalone guides removed
- wiki: removed experiment-mod section

## 1.0.0

- baseline: patch engine, launcher, asset autoloader, menus, keybinds, faction mods, anchors, compatibility patches
