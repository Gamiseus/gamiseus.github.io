# QuarterMaster Modding Wiki

Everything a mod author can use in QuarterMaster (QM) for *Mud and Blood* v0.5.3b: swapping art and sound, building a faction, patching game code, adding settings, keybinds and menu pages, working alongside other mods, and publishing.

The guide runs from the simplest kind of mod to the hardest. Each part builds on the ones before it, and the examples reuse one made-up mod, **Example Mod** (`example_mod`), so you can follow a single project from start to finish.

## Where to start

| You want to... | You need | Read |
|---|---|---|
| Replace sounds, music, sprites or fonts | Files in a folder. No code. | [Part 1](#part-1-what-a-mod-is), [Part 2](#part-2-replacing-art-and-sound-assets) |
| Put a different army on one side | One data file plus art and sound. No code. | [Part 3](#part-3-faction-mods-factiontoml) |
| Change a number or a line in the game | A few lines of TOML. | [Part 4](#part-4-changing-game-code-qmtoml) |
| Add your own Lua code | TOML plus Lua. | [Part 5](#part-5-adding-your-own-lua-files) |
| Give players settings, keybinds or a menu page | A `config.toml`, plus Lua to act on it. | [Part 6](#part-6-settings-keybinds-and-menus-configtoml) |
| Make your mod work with another mod | Anchors and compatibility patches. | [Part 7](#part-7-working-with-other-mods) |
| Look up a game table or function | | [Part 8](#part-8-game-reference) |
| Test, debug, package, publish | | [Part 9](#part-9-tools), [Part 10](#part-10-testing-and-debugging), [Part 11](#part-11-packaging-and-publishing) |

This wiki describes the newest version of QuarterMaster, the one at the top of the [changelog](../Quartermaster/CHANGELOG.md).

---

# Part 1: What a mod is

## How QuarterMaster loads mods

QuarterMaster never changes the game's files on disk. A small library (`winmm.dll`) sits next to `mnb.exe` and loads with the game. Each time the game loads one of its own Lua files, QuarterMaster edits the text in memory first, using the patches from every enabled mod. Remove the mods and the game is vanilla again.

The launcher keeps your mods in a library and builds a `Mods` folder for the active profile. The game reads that folder. While you develop, you can also point the launcher at a workspace folder of mods (see [Part 10](#part-10-testing-and-debugging)).

## The files in a mod

A mod is a folder (or a `.zip` of one). Every file is optional except that the mod must contain something QuarterMaster can load.

```
ExampleMod/
  mod.json          who the mod is: id, name, version, what it needs
  qm.toml           changes to game code (patches)
  config.toml       settings, keybinds and menu entries
  faction.toml      a faction that replaces the Allies or the Germans
  assets/           sounds, music, sprites and fonts that replace the game's
  example.lua       your own Lua files, loaded through qm.toml
  README.md         shown on the mod's page when published
```

| File | Read by | Needed when |
|---|---|---|
| `mod.json` | Launcher and game | Always recommended. Without it the mod is named after its folder. |
| `qm.toml` | Game | You change or add game code. |
| `config.toml` | Game and launcher | You offer settings, keybinds or menu entries. |
| `faction.toml` | Game | You make a faction. |
| `assets/` | Game | You replace or add art and sound. |

Other layouts QuarterMaster accepts:

- **A version folder.** `ExampleMod/1.0.0/mod.json` and so on. When the top folder has no mod files, the newest version folder is used. The launcher's library stores mods this way.
- **A zip.** `ExampleMod.zip` in the Mods folder works like the folder. The launcher unpacks zips on import, so this matters only for zips placed by hand.
- **Several patch files.** Besides `qm.toml`, every `.toml` file under a `qm/` subfolder of the mod is loaded as a patch file, in file-name order. Use this to split a large mod.
- `quartermaster.toml` is accepted as another name for `qm.toml`.

To make QuarterMaster skip a mod folder without deleting it, put an empty file named `.qmignore` in it.

## mod.json

`mod.json` identifies the mod and says how it relates to other mods.

```json
{
  "$schema": "../../Quartermaster/schemas/mod.schema.json",
  "schema_version": 1,
  "id": "example_mod",
  "name": "Example Mod",
  "version": "1.0.0",
  "authors": ["Your Name"],
  "description": "A short sentence about what the mod does.",
  "category": "Gameplay",
  "tags": ["Example"],
  "load_priority": 50,
  "game_version": ">=0.5.3"
}
```

Only `id`, `name` and `version` are required. The `$schema` line gives you completion and error checking in editors that support JSON Schema; point it at wherever your copy of the schema is (`qm schema --out <folder>` writes one).

| Key | Meaning |
|---|---|
| `id` | The mod's permanent identifier: lowercase letters, digits, `_` and `-`. Other mods, saves and settings refer to it, so don't change it after release. |
| `name` | The name players see. |
| `version` | A version such as `1.0.0`. Raise it with every release. |
| `authors` | A list of names. A single `"author": "Your Name"` is also accepted. |
| `description` | A short summary. |
| `category` | One of `Core`, `UI`, `Gameplay`, `Content`, `Audio`, `Visuals`, `Tools`, `Dev`, `Modpack`, `Other`. |
| `tags` | Free-form labels for searching. |
| `load_priority` | When the mod's changes run compared with other mods. Lower numbers run first. Default 50. Mods that others build on use low numbers (5 or 10); tools that should run last use high ones (90). |
| `game_version` | The game versions the mod supports, as a range (`">=0.5.3"`). |
| `entry_patch` | The patch file name, if it isn't `qm.toml`. |
| `homepage`, `github`, `nexus` | Links shown on the mod's page. |
| `update_keys` | Where the launcher looks for updates: `"GitHub:owner/repo#ExampleMod.zip"` or `"Nexus:1234"`. |
| `relationships` | How the mod relates to other mods (below). |
| `min_qm`, `qm_features` | The QuarterMaster version or features the mod needs. See [Feature gates](#feature-gates-min_qm-and-qm_features). |
| `overrides` | Launcher code-check findings you have reviewed and want silenced. See [Code checks](#code-checks). |
| `save_content` | Weapons the mod adds, with the game weapon each becomes while the mod is off. See [Saves and your mod](#saves-and-your-mod). |

### Relationships

```json
{
  "relationships": {
    "requires": { "other_mod": ">=1.0.0" },
    "recommends": { "another_mod": "*" },
    "conflicts": { "old_mod": "<2.0.0" },
    "load_after": ["other_mod"],
    "load_before": [],
    "provides": []
  }
}
```

| Key | Meaning |
|---|---|
| `requires` | Mods this mod can't run without, each with a version range. If one is missing or fails to load, this mod is skipped too. |
| `recommends`, `suggests` | Mods that go well with this one. Shown to the player; nothing is enforced. |
| `conflicts` | Mods (and versions) that can't run together with this one. |
| `load_after`, `load_before` | Ordering only: load after or before these mods when they are present. No error if they are missing. |
| `provides` | Other ids this mod answers to. A mod that `provides` `"other_mod"` satisfies another mod's `requires` on `other_mod`. |

Version ranges use `>=`, `<=`, `>`, `<`, `=`, `^` and `~`, combined with spaces (`">=1.2 <2"`). `"*"` means any version.

`requires` and `load_after` do different jobs and you often want both: `requires` says the other mod must be there, `load_after` says your changes run after its changes.

### Saves and your mod

The game keeps a save in the `player` table and writes all of it. Anything your mod puts there stays in the save after the mod is turned off.

**Values.** A value your code sets as `player.<name> = ...`, which the game's own code never sets, is recorded as your mod's. When a save loads, QuarterMaster marks it with the profile, the enabled mods and the values each of them writes (`player._qm_meta`). Later, when no profile that uses the save slot loads your mod any more, the launcher's Saves screen says the save has values from it and offers **Clean up**. Clean up runs only when the player asks. It makes a backup first and removes only values that one mod alone wrote; a value two mods both write is listed and left in the save. Use a name of your own (`player.example_mod_points`, not `player.points`) so the value is yours alone.

**Weapons.** A saved soldier who carries a weapon your mod adds would break the save once the mod is off, because the game no longer knows the weapon. Declare your weapons in `mod.json` and name the game weapon each one becomes:

```json
{
  "save_content": {
    "weapons": {
      "example_rifle": "k98",
      "example_smg": "mp40"
    }
  }
}
```

The key is your weapon's tag; the value is the tag of one of the game's own weapons (the K98 is used when it is not one). While your mod is off, a saved weapon with one of these tags is rebuilt as its base weapon when the save loads, in squads, in class unlocks and in swapped weapons. While your mod is on, nothing changes. A test launch without mods leaves saves alone. Weapons from a `faction.toml` need no entry; factions handle theirs ([Players, profiles and saves](#players-profiles-and-saves)).

---

# Part 2: Replacing art and sound (`assets/`)

This is the simplest kind of mod: no code and no patch file. Put files in an `assets/` folder and QuarterMaster loads them over the game's own. A mod can be nothing but an `assets/` folder.

```
ExampleSounds/
  assets/
    sounds/
      garand1.wav
      garand2.wav
    sprites/
      allied_idle.png
```

A file replaces the game's file with the same name. The game's own files are packed inside `mnb.exe`. Start the game once in [debug mode](#debug-mode) and press Ctrl+Shift+Alt+D to extract all of them to `Mods/qm/game-dump-full/`, so you can see every name and use the originals as templates.

## Folders

| Put the file in | It is loaded as | File types |
|---|---|---|
| `assets/sounds/` | A sound effect | `.wav`, `.ogg`, `.mp3` |
| `assets/sounds/vo/` or `assets/vo/` | A voice line (streamed) | `.wav`, `.ogg`, `.mp3` |
| `assets/music/` | Music (streamed) | `.wav`, `.ogg`, `.mp3` |
| `assets/sprites/` | An image | `.png`, `.jpg`, `.jpeg`, `.bmp` |
| `assets/ui/`, `assets/cheevos/`, `assets/splash/` | An image from that game folder | same |
| `assets/fonts/` | A font | `.ttf`, `.otf` |
| `assets/text/` | A game text string | `.txt` |

Folder names are forgiving: `sfx` and `audio` work like `sounds`, `voice` and `voices` like `vo`, `bgm` like `music`, `gfx` and `images` like `sprites`, and `descriptions` like `text`. A file placed directly in `assets/` is sorted by its file type. Subfolders inside these folders are fine and are only for your own tidiness, except `ui`, `cheevos` and `splash`, which exist because the game has files with the same name in different folders.

## How a file finds what it replaces

For each file, QuarterMaster looks for a match in this order:

1. A game file with the same folder and name (`assets/sounds/garand1.wav` replaces the game's `sounds/garand1.wav`). The game sometimes stores a file under a differently named variable; this match handles that for you.
2. For audio, a game variable named after the file plus `Sound` or `Music`.
3. A game file with the same name in any folder.
4. A game variable with exactly the file's name.

A replacement sound keeps the original's volume, looping and streaming mode. If nothing matches, the file is loaded as a **new** asset under its own name, ready for a patch or a faction to use. A new image `top_example.png` becomes the game variable `top_example`.

## Numbered sound pools

Many sounds come in numbered sets (`garand1.wav` to `garand4.wav`) and the game picks one at random.

- Replace any of them by number.
- Add more than the game has (`garand5.wav`, `garand6.wav`) and the game picks from the whole larger set. No code needed.
- Where the game has a single sound, add numbered versions of it (`mg42Sound1.wav`, `mg42Sound2.wav`) and each play picks one at random.

## Text files

A `.txt` file in `assets/text/` sets the game text variable named after the file. `assets/text/weaponText_m1.txt` replaces the M1's description on the squad screen. The names are the variables in the game's `includes/localisation.lua`.

## Image resolution and size

The game draws an image at its pixel size: a 100x40 sprite covers 100x40 pixels of the game's 1280x720 screen. QuarterMaster separates the two, so your file can have any resolution.

**A replacement needs nothing.** When your image replaces one of the game's, it is shown at the size of the original. A 400x160 `top_m1.png` in place of the game's 100x40 one looks sharper and takes up exactly the same space. This also holds for images a faction replaces.

If your file has a different shape from the original (a different ratio of width to height), it is stretched to the original's box and the log says so. Give it a size rule to choose for yourself.

**A new image is shown at its pixel size**, because there is no original to copy. To show it at another size, or to overrule the automatic size of a replacement, add a `[sprites]` table to `qm.toml`. Each entry is named after the image's global name in the game, which for a file in `assets/` is normally the file name without its extension:

```toml
[sprites.example_badge]
scale = 0.25               # a quarter of its own pixels: a 400x400 file shows at 100x100

[sprites.top_example_smg]
like = "top_m3"            # the size another image is shown at

[sprites.side_example_smg]
size = [150, 100]          # an exact size, in the game's pixels
```

| Key | Meaning |
|---|---|
| `scale` | A fraction of the file's own pixel size. `0.5` for a file drawn at twice the game's resolution. |
| `like` | The name of another image global. Your image is shown at the size that one is shown at. |
| `size` | `[width, height]` in the game's pixels. |

Use exactly one key per entry. The rules are applied once the game has loaded, so they see every mod's images, and a later mod's rule for the same image wins. A rule for a name the game has no image under is reported in the log.

What "shown at" means in code: `image:getWidth()`, `getHeight()` and `getDimensions()` return the shown size, and `love.graphics.draw(image, x, y, r, sx, sy, ox, oy)` scales the image to it, with the origin `ox, oy` still given in shown pixels. Game code and other mods written for the original size therefore keep working. A draw that passes a Quad is left as it is, since a Quad addresses the file's real pixels.

If your mod relies on this, list `sprite_sizes` under `qm_features` in `mod.json`. From Lua the same controls are on `QM.Sprites` ([Part 9](#the-qm-lua-module)).

## When two mods replace the same file

The mod that loads later wins, so the mod with the higher `load_priority` number is the one players see. The launcher's mod page lists which files an asset mod replaces and which are new.

Players can overrule that. The launcher's Patches tab has an **Assets** view that lists every sound, image and font two sources replace (two mods, or a mod and a faction), grouped by folder or by numbered set. For each group, or for one file in it, the player picks the winner: one of the mods, the faction, or the game's own file. The files of the others are then not loaded. Where the picked mod has no file, the file stays with whoever had it. The choice is stored in the profile as a fix and can be undone.

Things worth knowing as an author:

- A mod that replaces only some of a numbered set (29 of the game's 30 lines) is listed as such, so a mixed set is visible to the player.
- An image whose size differs from the game's gets a note, because the game draws most images at fixed positions.
- A font file changes every size of that font, since the game makes all sizes from one file.
- Numbers above the game's count are additions; nothing is renumbered.

## Other ways to replace assets

| Way | Use it when |
|---|---|
| `assets/` folder | The swap should always apply while the mod is on. The usual choice. |
| `[sprites]`, `[sounds]`, `[voices]` in `faction.toml` | The swap belongs to a faction and should apply only while that faction is active. See [Part 3](#part-3-faction-mods-factiontoml). |
| A patch that sets the game variable yourself | You need logic: a random pick, a setting that turns it on, a seasonal swap. See [Part 4](#part-4-changing-game-code-qmtoml). |

---

# Part 3: Faction mods (`faction.toml`)

A faction mod puts a different army on one side of the game: one data file, `faction.toml`, plus art and sound. It needs no code. Faction support is built into QuarterMaster, so players need nothing else installed.

## The idea

The game marks every unit `allied` or `axis` and checks that in hundreds of places, so a faction **takes over** a side instead of adding a third one. Your soldiers are still "allied" to the game; what changes is what is attached to them: frames, weapons, classes, names, voices, text and vehicle skins. Three things follow:

- every rule in the game keeps working for your army;
- anything you leave out stays vanilla, so you can build a faction one piece at a time;
- turning the mod off returns the vanilla game, saves included.

## Starting one

```bash
qm new example_army "Example Army" --template faction_mod
```

This writes a `faction.toml` with every section (most commented out), a copy of the editor schema (`faction.schema.json`), and empty folders for your files. Check your work at any time:

```bash
qm faction check ExampleArmy
```

The check reports errors (the faction won't load until they are fixed), warnings, and which frames still show vanilla art. `qm lint ExampleArmy` runs the same checks along with the rest.

When the mod is enabled and the game starts, the log has a line like `[QM][Faction] Example Army replaces the Allies: 64 frames, 3 weapons, 2 classes`.

## The smallest faction

```toml
schema = 1
id = "example_army"          # lowercase letters, digits, underscores; stored in saves
name = "Example Army"
replaces = "allied"          # or "axis"
side_name = "Example"        # optional: the word the game uses for the side
```

That is a complete, valid faction that changes nothing. Each section you add changes one thing. All paths are relative to the mod folder.

## Names: `[names]`

The simplest section: a list of surnames.

```toml
[names]
last = ["Smith", "Jones", "Brown"]
```

Everything it can hold:

```toml
[names]
last_file = "names/last.txt"       # one name per line; # starts a comment
first_file = "names/first.txt"
format = "full"                    # "Alex Smith"; the default "initial" gives "A. Smith"
vehicles = ["Old Faithful", "Lucky Seven"]     # vehicle call signs
french = { last = ["Martin", "Bernard"] }      # names for the french unit
```

Use `first` and `last` for short inline lists and `first_file` and `last_file` for long ones. On the Axis side the soldier names are used for the German commander, because vanilla German soldiers have no names.

## Text: `[text]`

Any game string can be replaced by its name. The names are in the game's `includes/localisation.lua`.

```toml
[text]
mouseOverRifleSpec = "Rifleman, the backbone of the Example Army"
```

## Unit art: `[units.<unit>]`

Each unit is a folder with one image per animation frame, named after the frame (`idle.png`, `aim.png`, `reload1.png` ...).

| Side | Units |
|---|---|
| Allied | `base` (rifleman), `sarge`, `para`, `french` |
| Axis | `base` (soldier), `officer`, `volks` |

```toml
[units.base]
folder = "units/base"

[units.sarge]
folder = "units/sarge"
copy_from = "base"                                # frames the sergeant lacks use your base frames
frames = { idle = "units/shared/idle_cap.png" }   # point single frames anywhere
```

Files that don't match a frame name are reported and skipped. Frames can have any resolution: each is shown at the size of the vanilla frame it replaces ([Part 2](#image-resolution-and-size)). Keep the vanilla frame's proportions, or the frame is stretched to fit.

### Frame names

All units have: `idle`, `aim`, `fire`, `parry`, `pinned`, `pinCover`, `call`, `observe`, `dead`, `proneAim`, `proneFire`, `unjam1`-`unjam2`, `attack1`-`attack4`, `fragThrow1`-`fragThrow3`, `faustToss`, `reload1`-`reload10`, `buringMan1`-`buringMan4` (the game's own spelling).

| Unit | Also has |
|---|---|
| Allied `base`, `para`, `french` | `deadBBQ`, `analyze`, `brief`, `bazooka`, `bazooka1`-`bazooka3`, `bazookaFired`, `faustFired`, `flare1`-`flare7`, `mortar1`-`mortar4` |
| Allied `sarge` | `analyze`, `brief`, `bazooka`, `bazooka1`-`bazooka3`, `bazookaFired`, `faustFired`, `smoking1`-`smoking2` |
| Axis `base` | `deadBBQ`, `bazooka1`-`bazooka3`, `flare1`-`flare7`, `mortar1`-`mortar4` |
| Axis `officer`, `volks` | The same as Axis `base`, plus `jagerMove` |

## Weapons: `[[weapons]]`

There are two ways to give your army a weapon.

A **reskin** changes a vanilla weapon in place. Its tag stays the same, so everything in the game that looks for that weapon still works. Use this for most of your weapons.

```toml
[[weapons]]
reskin = "m1"                      # the Garand becomes...
description = "Example Rifle. Reliable and accurate."
top_sprite = "weapons/example_rifle_top.png"
side_sprite = "weapons/example_rifle_side.png"
sound = "springfieldSound"
stats = { action = "bolt", ammo = 5, maxAmmo = 5, range = 480, damage = 110 }
```

A **new** weapon has its own tag and starts as a copy of a vanilla weapon's stats:

```toml
[[weapons]]
tag = "example_smg"
based_on = "m3"
name = "Example SMG"
top_sprite = "weapons/example_smg_top.png"
side_sprite = "weapons/example_smg_side.png"
sound = "weapons/example_smg"
stats = { maxAmmo = 35 }           # ammo follows maxAmmo unless you set it
loot_side = "allied"               # also drops as Allied loot
pools = ["smg", "grunt"]           # and joins these random pools
```

| Key | Meaning |
|---|---|
| `reskin` | The vanilla weapon tag to change in place. Use this or `tag`, not both. |
| `tag`, `based_on` | A new weapon's own tag, and the vanilla weapon it copies its stats from. |
| `name` | The weapon's name. |
| `description` | The squad screen text. With only a `name`, the name is used. |
| `top_sprite`, `side_sprite` | The weapon seen from above (in a soldier's hands) and from the side (in menus). |
| `mag_sprite` | The magazine image: a game sprite name or an image file. |
| `sound` | The firing sound. Three forms, below. |
| `stats` | Any of the stats listed below. Ones you leave out keep the base weapon's value. |
| `loot_side` | `"allied"` or `"axis"`: a new weapon also drops as that side's loot. |
| `pools` | Random pools a new weapon joins. |

**Sound** can be written three ways:

- A bare game sound name with no slash or dot (`"springfieldSound"`) reuses a sound the game already has. Handy as a placeholder.
- A single file (`"weapons/example_rifle.wav"`).
- A path without a number or extension (`"weapons/example_smg"`) picks up `example_smg1.wav`, `example_smg2.wav` and so on, and the game varies between them.

**Stats:** `action` (`"semi"`, `"bolt"`, `"auto"`), `class` (`""`, `"smg"`, `"lmg"`, `"atRifle"`), `ammo`, `maxAmmo`, `range`, `damage`, `recoil`, `bulk`, `rof`, `rofTime`, `jam`, `rgCapable` (0 or 1: can fire rifle grenades).

### Random pools: `[pools.<pool>]`

Loot and reinforcement weapons are drawn from these pools: `allied`, `allied_sniper`, `grunt`, `para`, `resistance`, `smg`, `axis`, `axis_crew`. Add and remove weapons by tag:

```toml
[pools.grunt]
add = ["example_smg"]
remove = ["springfield"]
```

An added weapon comes up as often as any other weapon in the pool. If another mod changed the same pool function, its weapons stay in the pool too: the faction asks that function for the rest of the draw and only redraws a weapon it removed.

### Swapping a weapon everywhere: `[spawn_swap]`

The game hands out weapons by name in about 300 places. `spawn_swap` replaces one with another wherever your side receives it:

```toml
[spawn_swap]
tommy = "example_smg"
```

Unlike a reskin, the weapon's tag really changes, so the game's own checks for the old tag stop matching for those soldiers. `qm faction check` tells you how many such checks each swap affects (`k98` has 14, `shotgun` 9, `m1` 3; most have none). Prefer a reskin when it does the job.

## Classes: `[classes.<slot>]` (Allied side)

The game has 12 class slots: `rifle`, `light`, `gunner`, `medic`, `comms`, `officer`, `engy`, `scout`, `sniper`, `commando`, `sapper`, `intel`. You can rename and rebalance them. You can't add new ones.

```toml
[classes.rifle]
name = "Rifleman"
description = "Medium to long range with the Example Rifle."
start_weapon = "m1"                        # given on promotion to this class
unlocks = ["m1", "example_smg", "bar"]     # weapon upgrade tiers 1 to 3
bonus = { speed = 0, skill = 5 }           # replaces the vanilla bonus for this class
skills = ["Smoke, ...", "Frag, ...", "Charge, ..."]   # names and text only
icon = "icons/rifle.png"                   # class badge
```

- `bonus` keys: `speed`, `skill`, `max_health` (also heals by the same amount) and `hth_damage` are added to the soldier; `detect_range` and `mine_detect_range` are multiplied.
- `skills` changes what the three skills are called and described as. What a skill does stays vanilla.
- With only a `name`, the vanilla description is kept, and the other way round.

The vanilla values, for balancing against:

| Slot | Vanilla name | Start weapon | Vanilla bonus | Unlocks |
|---|---|---|---|---|
| `rifle` | Heavy Infantry | `m1` | none | `matchGarand`, `m1941`, `t20` |
| `light` | Light Infantry | `m1Carbine` | speed +10 | `m1CarbinePara`, `m2Carbine`, `m2CarbineA1` |
| `gunner` | Gunner | `bar` | speed -10, detect range +200 | `bren`, `m1919`, `vicker` |
| `medic` | Medic | keeps weapon | skill -15 | `sten`, `m3`, `m1` |
| `comms` | Signaller | keeps weapon | speed -10 | `sten`, `m3`, `tommy` |
| `officer` | Officer | keeps weapon | none | `m1Carbine`, `tommy`, `m1` |
| `engy` | Engineer | `shotgun` | mine detect x3 | `m3`, `m1Carbine`, `m1` |
| `scout` | Scout | `shotgun` | detect range x2 | `sten`, `m3`, `tommy` |
| `sniper` | Sniper | `1917` | skill +15 | `scopedGarand`, `scopedSpringfield`, `scopedEnfield` |
| `commando` | Commando | `sten` | hand-to-hand +25, health +20 | `m3`, `tommy`, `stenMKVI` |
| `sapper` | Sapper | `shotgun` | mine detect x3 | `sten`, `m3`, `tommy` |
| `intel` | Intel | `sten` | none | `m3`, `mp40`, `stg44` |

## Voices: `[voices]`

Name your files like the game's voice lines (`contact1.wav`, `pinned3.wav`, `alliedHurt1.wav`). The originals are in the game's `sounds/vo/allied/` and `sounds/vo/axis/`.

```toml
[voices]
folder = "voices"                   # replaces lines in sounds/vo/allied (or vo/axis)
map = { hurt = "alliedHurt" }       # lets you ship hurt1.wav instead of alliedHurt1.wav
dirs = { frenchies = "voices_fr" }  # the french unit's own folder
fill_missing = true                 # the default
```

You don't need as many recordings as the game has. With `fill_missing`, if the game has 35 `contact` lines and you supply 5, your 5 are reused across all 35, so none of the original lines slip through.

## Other images and sounds: `[sprites]`, `[sounds]`

Any other image or sound can be replaced by its global name while the faction is active:

```toml
[sprites]
parachuteAllied = "misc/parachute.png"

[sounds]
airStrike1 = "misc/plane.wav"
```

The difference from an `assets/` folder (Part 2) is that these apply only while the faction is active for its side, and are checked by `qm faction check`.

## Vehicles: `[[vehicles]]`

Reskin and rename a vehicle of your side. New vehicle types and vehicle stats aren't supported, because the game's vehicle behaviour is written separately for each vehicle.

```toml
[[vehicles]]
reskin = "sherman"
name = "Example Tank"                # shown in the vehicle tooltip
body = "vehicles/tank/body.png"
turret = "vehicles/tank/turret.png"
husk = "vehicles/tank/husk.png"      # the wreck
debris = "vehicles/tank/debris"      # debris1.png, debris2.png, ... spread over the vanilla debris
call_signs = ["Old Faithful", "Lucky Seven"]
parts = { SecondTurret1 = "vehicles/tank/second.png" }   # any other <tag><part> sprite
```

`driver`, `gunner` and `icon` take images as well.

| Side | Vehicles and guns |
|---|---|
| Allied | `sherman`, `stuart`, `churchill`, `m10`, `m20`, `m5`, `greyHound`, `jeep`, `deuce`, `weasel`, `weaselBoxed`, `halfTrack`, `ambulance`, `howitzer`, `landMattress`, `bofor`, `m2hb`, `clownCar` |
| Axis | `panzer4`, `panther`, `tiger`, `stug`, `flakPanzer`, `wespe`, `puma`, `sdkfz`, `sdkfz2`, `sdkfz2Boxed`, `sdkfz222`, `opel`, `kubel`, `benz`, `bike`, `horseCart`, `goliath`, `r35`, `nebel`, `flak30`, `flak38`, `germHowitzer`, `pak36`, `pak38`, `pak88`, `zb60`, `armoredCannon`, `brestCannon` |

## Code: `[hooks]`

For anything the data can't express, point at a Lua file:

```toml
[hooks]
lua = "hooks.lua"
```

```lua
-- hooks.lua returns a table with any of these three functions.
local H = {}

function H.on_enable(faction)                    -- once, after the faction is applied
  print(faction.name .. " is active")
end

function H.on_soldier_created(dude, unit, side)  -- unit is "base", "sarge", ...
  if unit == "base" then dude.speed = dude.speed + 5 end
end

function H.on_weapon_created(weapon, tag)        -- after every weapon is built
end

return H
```

A faction mod can also carry an ordinary `qm.toml` beside its `faction.toml` for behaviour changes that go beyond these hooks (Part 4).

## Reading the active faction from another mod

When a faction is active, the global `QMFactions` describes it:

```lua
local army = QMFactions and QMFactions.get("allied")
if army then
  print(army.name)           -- "Example Army"; also army.id, army.side_name, army.replaces, army.mod_id
end

local w = QMFactions and QMFactions.weapon("example_smg")   -- { tag, mode, based_on, faction } or nil
local n = QMFactions and QMFactions.vehicle_name("sherman") -- "Example Tank" or nil
```

`QMFactions` exists only while at least one faction is active, so test for it first.

## Players, profiles and saves

- **One faction per side.** If a profile enables two factions for the same side, the launcher's Assets view lets the player pick which one runs. Without a pick the one with the higher `load_priority` is used and the log names the one left out. A pick stays put when the load order changes. One Allied and one Axis faction together is fine.
- **A player can give a file back.** In the Assets view a player can choose another mod's file, or the game's own, over a faction's image, sound or voice line. The faction then leaves that one alone and everything else of it still applies.
- **Faction art survives a reload.** A faction's images and sounds are registered with the asset loader, so when the game loads the same file again later it still gets the faction's version.
- **Saves stay loadable.** A save remembers which faction it ran with. When it is loaded without that faction, QuarterMaster puts the vanilla class unlocks back and turns weapons the game doesn't know into their base weapon (a weapon `based_on = "m3"` becomes an M3). A weapon that another loaded mod adds is left alone.
- The launcher's mod list shows a faction mod as "Replaces the Allies" or "Replaces the Germans".

## What a faction can't do

A third side, new class slots, new vehicle types or vehicle stats, changing what a skill does, and the German side's spawn roles. These may come in later schema versions; `schema = 1` files will keep working.

---

# Part 4: Changing game code (`qm.toml`)

A patch is an instruction: find this line in a game file, then put this code before it, after it, or in its place. Patches go in `qm.toml`.

To see the code you are patching, start the game once in [debug mode](#debug-mode) and press Ctrl+Shift+D: every Lua file of the game is written to `Mods/qm/game-dump/`. Without debug mode, that folder still holds the files your mods patch, saved as the game loaded them.

## Your first patch

```toml
[manifest]
version = "1.0.0"

[[patches]]
[patches.pattern]
id = "example_mod:hello"
target = "main.lua"
pattern = 'require "includes/directives"'
position = "after"
payload = '''
print("[Example Mod] loaded")
'''
```

- `[manifest]` with a `version` is required at the top of every patch file.
- Each patch starts with `[[patches]]`, then a table that names its type. This one is a **pattern** patch.
- `target` is the game file. `pattern` is the line to find. `position` says where the `payload` goes.

Launch the game and the line appears in the log (`Mods/qm/log/latest.log`).

## Pattern patches

A pattern patch matches whole lines of the game file.

| Key | Meaning |
|---|---|
| `target` | The game file, such as `"main.lua"` or `"includes/urb_engine.lua"`. A list patches several files: `["includes/ai.lua", "includes/urb_engine.lua"]`. |
| `pattern` | The line to find. Leading and trailing spaces are ignored on both sides. `*` matches any run of characters and `?` any single character. Several lines match those lines in a row. |
| `position` | `"before"` or `"after"` inserts the payload next to the match. `"at"` replaces the matched lines with the payload. |
| `payload` | The code to insert. |
| `match_indent` | `true` indents the payload like the line it matched. Cosmetic, but it keeps the patched file readable in dumps. |
| `times` | How many matches to patch. Without it, every match is patched. A different number of matches than `times` gives a warning; extra matches are left alone. `expect` is another name for the same key. |

Quote patterns and payloads with TOML's literal strings so backslashes and quotes need no escaping: `'single quotes'` for one line, `'''triple quotes'''` for several.

### The three positions

Insert after a line:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:after_load"
target = "main.lua"
pattern = 'print("loading Save")'
position = "after"
payload = 'print("[Example Mod] a save was found")'
match_indent = true
```

Replace a line (`at`). The payload stands in for the matched line, so repeat anything you want to keep:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:replace_log"
target = "main.lua"
pattern = 'print("loading Save")'
position = "at"
payload = 'print("loading Save (Example Mod is active)")'
match_indent = true
```

Match several lines in a row, to pin down a line that appears in more than one place:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:new_profile_note"
target = "main.lua"
pattern = '''
player = {}
newProfile(player)
'''
position = "after"
payload = 'print("[Example Mod] started a new profile")'
match_indent = true
```

### Choosing a good line

- Pick a line that appears once in the file, or use several lines, or set `times = 1` to take only the first match.
- Prefer `before` and `after` to `at`. Inserted code stacks with other mods' code on the same line; a replaced line is gone for every mod that wanted to find it.
- If you must use `at` and your payload keeps some of the original lines, add `apply_as = "edits"` so those lines stay in place for other mods. See [Part 7](#keeping-lines-other-mods-need-apply_as).

## Regex patches

A regex patch matches inside a line with a regular expression, and can change just part of the line. Use it to change a number.

```toml
[[patches]]
[patches.regex]
id = "example_mod:frag_cooldown"
target = "includes/urb_engine.lua"
pattern = 'player\.deployedTroops\[foo\]\.skill2Timer = (?P<seconds>120)'
root_capture = "seconds"
position = "at"
payload = "60"
times = 1
```

The pattern finds the line that sets the light infantry frag cooldown; `root_capture` narrows the change to the group named `seconds`; `position = "at"` replaces that group with `60`.

| Key | Meaning |
|---|---|
| `pattern` | A regular expression (Rust `regex` syntax). `^` and `$` match at line starts and ends. |
| `root_capture` | The capture group the position applies to, by name or number. Without it, the whole match. |
| `position` | `"at"` replaces the match or group; `"before"` and `"after"` insert next to it, inside the line. |
| `payload` | The text to insert. `$1`, `$name` or `${name}` insert what a group matched. |
| `line_prepend` | Text put at the start of each payload line, typically a captured indent: `line_prepend = "$indent"`. |
| `verbose` | `true` ignores spaces and line breaks in the pattern, so a long one can be laid out over several lines. |
| `times` | As for pattern patches. |

Reusing part of the match in the payload:

```toml
[[patches]]
[patches.regex]
id = "example_mod:log_wave"
target = "includes/mnb2.lua"
pattern = '(?P<indent>[ \t]*)function spawnMNB2Wave\(\)'
position = "after"
payload = '''

print("[Example Mod] a wave is spawning")'''
line_prepend = "$indent  "
times = 1
```

### Pattern or regex?

| Use a pattern patch when | Use a regex patch when |
|---|---|
| You insert whole lines next to a line. | You change part of a line: a number, a name, one argument. |
| The line is plain text you can copy from the game file. | The line varies and you need alternatives or groups. |
| You want the simplest thing that works. | The same change applies to many similar lines. |

## Keys every patch type shares

These go in the same table as the keys above.

| Key | Meaning |
|---|---|
| `id` | The patch's name. Give every patch one, written `mod_id:something`. Other mods, the launcher's fixes and crash reports refer to patches by id, and an id you choose stays the same when you add patches above it. |
| `name`, `description` | Shown in the launcher's Patches tab. |
| `priority` | Overrides the mod's priority for this one patch. Lower runs first. |
| `before`, `after` | Run before or after other patches: a list of ids, `mod_id:patch_id`, or `mod_id:*` for every patch of a mod. |
| `requires` | Patches this one needs. If a needed patch in the same file didn't apply, this one is skipped. See [Part 7](#a-patch-that-needs-another-patch). |
| `on_failure` | What to do when the patch finds no match: `"warn"` (the default: log it and carry on), `"skip_patch"`, `"skip_mod"` (skip the rest of this mod's patches in that file), or `"abort"` (stop the game with an error). |

## Order

Patches on the same file run in priority order, lowest number first. A mod's priority comes from, in order: the player's profile, `load_priority` in `mod.json`, then `priority` under `[manifest]` in `qm.toml`. A patch's own `priority` key overrides it for that patch.

Order matters when one patch changes a line another patch looks for. When two mods only insert code at the same line, both apply; [Part 7](#part-7-working-with-other-mods) covers who goes on top.

## Variables: `[vars]`

A `[vars]` table defines text that is substituted into payloads wherever `{{qm:name}}` appears. Use it to keep a tunable number in one place.

```toml
[vars]
example_mod_cooldown = "60"

[[patches]]
[patches.regex]
id = "example_mod:frag_cooldown"
target = "includes/urb_engine.lua"
pattern = 'player\.deployedTroops\[foo\]\.skill2Timer = (?P<seconds>120)'
root_capture = "seconds"
position = "at"
payload = "{{qm:example_mod_cooldown}}"
times = 1
```

All mods share one set of variables, and a later mod's value replaces an earlier one's, so prefix names with your mod id. Values are text. `{{quartermaster:name}}` is another spelling of `{{qm:name}}`.

One built-in substitution works anywhere in a patch file: `{{qm_hack:patch_dir}}` becomes the full path of your mod's folder, for code that reads the mod's own files.

---

# Part 5: Adding your own Lua files

Past a few lines, keep your code in a Lua file and have patches call into it.

## Module patches

A module patch registers one of your files under a name the game can `require`.

`example.lua`:

```lua
local ExampleMod = {}
_G.ExampleMod = ExampleMod      -- make it reachable from patches, keybinds and other mods

function ExampleMod.update(dt)
  -- runs every frame once hooked up below
end

return ExampleMod
```

`qm.toml`:

```toml
[manifest]
version = "1.0.0"

# 1. Register the file.
[[patches]]
[patches.module]
id = "example_mod:module"
source = "example.lua"
name = "includes/example"
before = "main.lua"

# 2. Load it once the game's own files are loaded.
[[patches]]
[patches.pattern]
id = "example_mod:require"
target = "main.lua"
pattern = 'require "includes/directives"'
position = "after"
payload = 'ExampleMod = require "includes/example"'

# 3. Call it every frame.
[[patches]]
[patches.pattern]
id = "example_mod:update"
target = "main.lua"
pattern = 'function love.update(dt)'
position = "after"
payload = '''
if ExampleMod and ExampleMod.update then ExampleMod.update(dt) end
'''
match_indent = true
```

| Key | Meaning |
|---|---|
| `source` | Your file, relative to the mod folder. |
| `name` | The name to `require`. Any name works; the game's own files are named `includes/<file>`. |
| `before` | The game file the module must be ready before. Use `"main.lua"`. |
| `load_now` | `true` runs the module immediately, just before the `before` file loads, instead of waiting for a `require`. |

`require "includes/directives"` is the last of the game's own files loaded at the top of `main.lua`, which makes "after it" the usual place to load a module: every game function exists by then, but `love.load` has not run yet. The `player` table and the game's images and sounds only exist once `love.load` has run, so code that needs them belongs in a function you call later, not at the top of your file.

### Ways to run your code

| Way | When it runs | Use it for |
|---|---|---|
| Payload of a pattern patch | Wherever you put it | A line or two. |
| Module + `require` patch | When the `require` line runs | Most mods. Your code is in a real file with real line numbers in error messages. |
| Module with `load_now = true` | Before `main.lua` starts; no game functions exist yet | Setting up something the game's own top-level code will read. |
| Copy patch (below) | As part of the game file | Appending a block of functions to a game file. |

## Replacing a whole game file

Give a module the same `name` as a game file and the game loads yours instead:

```toml
[[patches]]
[patches.module]
id = "example_mod:particles"
source = "particlesSystem.lua"
name = "includes/particlesSystem"
before = "main.lua"
```

This is the bluntest tool there is. Patches other mods wrote for the original file no longer apply to it, and your copy won't pick up a game update. Use it only when you are rewriting most of the file, and start from the game's own version of it.

## Copy patches

A copy patch adds text to the start or end of a game file, from files in your mod or from an inline payload.

```toml
[[patches]]
[patches.copy]
id = "example_mod:extra_functions"
target = "includes/urb_engine.lua"
position = "append"            # or "prepend"
sources = ["extra_functions.lua"]
```

| Key | Meaning |
|---|---|
| `position` | `"append"` (end of file) or `"prepend"` (start). |
| `sources` | A list of your files to copy in, in order. |
| `payload` | Text to copy in, instead of or as well as `sources`. |

Copied code becomes part of the game file, so pattern and regex patches on that file can match it. Appended code can't follow a top-level `return` at the end of the file.

## Wrapping a game function

Often the cleanest way to change what a game function does is to wrap it from your module instead of patching its lines. Keep the original and call it:

```lua
function ExampleMod.install()
  local original = floatyText            -- a game function: floatyText(dude, text)
  function floatyText(dude, text)
    print("[Example Mod] " .. tostring(text))
    return original(dude, text)          -- always call the original
  end
end
```

Call `ExampleMod.install()` from your `require` patch (`ExampleMod = require "includes/example"; ExampleMod.install()`).

| Patch the lines when | Wrap the function when |
|---|---|
| The change is inside a long function. | You act before or after the whole function, or change its arguments or result. |
| You need the function's local variables. | You only need its arguments and globals. |

Always call the original. A wrapper that doesn't call it silently turns off every other mod that wrapped the same function, and the launcher flags it ([Code checks](#code-checks)).

QuarterMaster wraps a few game functions itself: `updateProfile` (the save check), and for an active faction `weaponCreator`, `specClick`, `newProfile`, the weapon pool functions, the name functions and the soldier and vehicle spawners. If your mod replaces one of these, QuarterMaster puts its own part back around your version when `love.load` ends, so the save check and the faction keep working whether or not you call the original. Its part runs once per call even when your function calls the wrapper it found.

---

# Part 6: Settings, keybinds and menus (`config.toml`)

QuarterMaster builds three screens into the game's main menu and fills them from every mod's `config.toml`:

- **Mod Settings**: one tab per mod with its options.
- **Keybinds**: every mod's keybinds plus the game's own controls, all rebindable.
- **Mod Operations**: cards that open a mod's page or start a mod's game mode.

The screens appear when at least one enabled mod has a config. In Lua they are `QM.Menu` and `QM.Input`; because they may be absent, test before use (`if QM and QM.Menu then`).

`config.toml` starts with the mod's name as it should appear on its tab:

```toml
name = "Example Mod"
```

Settings and keybinds are stored under the mod's `id` from `mod.json`.

## Options

```toml
name = "Example Mod"

[[options]]
id = "double_xp"
label = "Double XP"
type = "checkbox"
default = false
description = "Soldiers earn experience twice as fast."

[[options]]
id = "squad_size"
label = "Squad Size"
type = "cycle"
options = [6, 8, 12]
labels = ["Small (6)", "Medium (8)", "Large (12)"]
default = 6
description = "How many soldiers you can field."
```

| Key | Meaning |
|---|---|
| `id` | The option's name in code. |
| `label` | The text on its row. |
| `type` | `"checkbox"` (on/off), `"cycle"` (step through a list), or `"button"` (run an action). |
| `default` | The starting value. |
| `description` | The tooltip. |
| `options` | For `cycle`: the values, as numbers or text. |
| `labels` | For `cycle`: the text shown for each value. Without it the values themselves are shown. |
| `button_text` | For `button`: the text on the button. |
| `on_click` | For `button`: the global function to call, by name ([below](#acting-when-an-option-changes)). |
| `show_if` | Show the option only when another option has a certain value (below). |
| `aliases` | Extra names the value is also stored under (below). |

The launcher's mod page has an Options tab that edits the same options outside the game.

### Showing an option only when it applies

```toml
[[options]]
id = "difficulty"
label = "Difficulty"
type = "cycle"
options = ["Normal", "Hard", "Custom"]
default = "Normal"

[[options]]
id = "custom_enemy_count"
label = "Extra Enemies"
type = "cycle"
options = [1, 2, 3]
default = 1
show_if = { id = "difficulty", value = "Custom" }
```

`show_if` names another option of the same mod. Use `value` for one value or `values = ["Hard", "Custom"]` for several.

### Reading an option in Lua

The current value is in three places. Pick one and stay with it.

| Where | Example | Value of a checkbox | Notes |
|---|---|---|---|
| `QM.settings.<mod_id>.<option_id>` | `QM.settings.example_mod.double_xp` | `true` / `false` | The clearest. Separate per mod, so names can't clash. |
| `modSettings.<name>` | `modSettings.double_xp` | `1` / `0` | One table shared by all mods. |
| `player.option_<name>` | `player.option_double_xp` | `1` / `0` | On the save table, like the game's own options. |

```lua
if QM and QM.settings.example_mod and QM.settings.example_mod.double_xp then
  xpGain = xpGain * 2
end
```

In `modSettings` and `player`, a checkbox is stored as the number 1 or 0, as the game's own options are. Lua treats 0 as true, so compare with `== 1`; `if modSettings.double_xp then` is always true.

In those two tables each option is stored under several names at once: its `id`, the camelCase form of the id (`doubleXp`), both with `Enabled` added (`doubleXpEnabled`), and anything in `aliases`. Aliases exist so that older code reading a particular name keeps working.

Settings are saved in `saveModSettings.lua` in the game's save folder and are loaded before your module's code at `love.load` runs.

### Acting when an option changes

Options declared in `config.toml` are read when you need them. To run code at the moment the player changes one, register the option from Lua instead and give it a `set` function:

```lua
if QM and QM.Menu then
  QM.Menu.registerOption("example_mod", "Example Mod", {
    id = "double_xp",
    label = "Double XP",
    type = "checkbox",
    default = false,
    description = "Soldiers earn experience twice as fast.",
    set = function(value) print("double_xp is now", value) end,
  })
end
```

A `button` option runs a function when clicked. In `config.toml`, name a global function with `on_click`; a dotted name reaches one level into a global table:

```toml
[[options]]
id = "reset_stats"
label = "Reset Statistics"
type = "button"
button_text = "RESET"
on_click = "ExampleMod.resetStats"
```

Registered from Lua, `on_click` can be the function itself:

```lua
QM.Menu.registerOption("example_mod", "Example Mod", {
  id = "reset_stats",
  label = "Reset Statistics",
  type = "button",
  button_text = "RESET",
  on_click = function() ExampleMod.resetStats() end,   -- or a name: "ExampleMod.resetStats"
})
```

Register options at startup, in your module's setup code after the `require`.

### Other places to declare a config

| Where | Notes |
|---|---|
| `config.toml` | The usual place. |
| A `[config]` table inside `qm.toml` | The same keys, nested: `[[config.options]]`, `[[config.keybinds]]`. Keeps a small mod to one file. |
| `config.lua` | The older format (`return { name = ..., options = { ... } }`), still read. It is read as text, not run, so keep it to plain tables. |
| `QM.Menu.registerOption` / `QM.Input.registerAction` in Lua | When an option needs a callback or is built at run time. |

QuarterMaster uses the first of `config.toml`, the `[config]` table, and `config.lua` that it finds.

## Keybinds

```toml
[[keybinds]]
id = "example_mod_ping"
name = "Ping Location"
category = "Orders"
tab = "Example Mod"
default = "t"
modifiers = ["ctrl"]
description = "Marks the spot under the cursor."
on_trigger = "ExampleMod.onPing"
```

```lua
function ExampleMod.onPing()
  local x = love.mouse.getX() + player.screenx    -- screen position to map position
  local y = love.mouse.getY() + player.screeny
  print("[Example Mod] ping at", x, y)
end
```

| Key | Meaning |
|---|---|
| `id` | The action's name. Keybind ids are shared by all mods, so start yours with your mod id. |
| `name` | The text in the Keybinds list. |
| `category` | A heading inside the tab. |
| `tab` | The tab the keybind appears under. Without it: "Uncategorized". |
| `default` | The key: a LÖVE key name such as `"t"`, `"f6"`, `"space"`, `"kp1"`, or a mouse button `"mouse1"` to `"mouse8"`. |
| `modifiers` | Keys held with it: any of `"ctrl"`, `"shift"`, `"alt"`. A combination can also be written into `default` directly: `"ctrl+shift+t"`. |
| `secondary` | A second key for the same action. |
| `description` | The tooltip. |
| `on_trigger` | The function to call, as a name reachable from the global table: `"ExampleMod.onPing"`. |

Players rebind keys on the Keybinds screen; bindings are saved in `saveKeybinds.lua`. A pressed key that triggers a mod action is not passed on to the game.

### Other ways to use a keybind

**Attach the function in Lua** instead of naming it in the config, for a local function or a closure:

```lua
if QM and QM.Input then
  QM.Input.onTrigger("example_mod_ping", function() ExampleMod.onPing() end)
end
```

**Test whether a key is held**, for something that happens every frame while the key is down:

```lua
function ExampleMod.update(dt)
  if QM and QM.Input and QM.Input.isDown("example_mod_ping") then
    -- held this frame
  end
end
```

**Register the whole action in Lua**, for keybinds created at run time. It takes the same keys as the config, and `on_trigger` may be a function:

```lua
QM.Input.registerAction({
  id = "example_mod_mark",
  name = "Mark Target",
  category = "Orders",
  tab = "Example Mod",
  default = "m",
  on_trigger = function() print("marked") end,
})
```

### The game's own controls

The game's controls are listed on the "Vanilla Controls" tab and can be rebound too. Their ids, for `QM.Input.isDown`: `camera_left`, `camera_right`, `squad_halt`, `grouping`, `alt_move`, `selection_mod`, `deselect`, `pause`, `toggle_faces`, `fade_roofs`, `tactical_view`, `windowed`, `fullscreen`, and `group_0` to `group_9`.

### QM.Input functions

| Function | Does |
|---|---|
| `isDown(actionId)` | True while the action's key or combination is held. |
| `onTrigger(actionId, fn)` | Sets the function an action calls. Works before or after the action is registered. |
| `trigger(actionId)` | Runs the action's function as if its key were pressed. |
| `registerAction(def)` | Adds an action, or updates one with the same id. |
| `isBindingDown("ctrl+t")` | True while that combination is held, without an action. |
| `setBindingSlot(actionId, slot, combo)` | Sets the primary (`1`) or secondary (`2`) binding. |
| `clearBinding(actionId)`, `clearBindingSlot(actionId, slot)` | Unbinds. |
| `resetAction(actionId)`, `resetTab(tab)` | Restores defaults. |
| `findConflict(actionId, combo, slot)` | The id of another action already using that combination, if any. |
| `formatKey("ctrl+t")` | The display form, `"CTRL+T"`. |
| `saveCurrentKeybinds()`, `loadSavedKeybinds()` | Writes and reads `saveKeybinds.lua`. |

## Mod Operations: cards and pages

A **mode** is a card on the Mod Operations screen. A **page** is a simple screen with a title, text and one action button.

```toml
[[modes]]
id = "example_briefing"
title = "Example Operation"
subtitle = "A sample mission"
description = "Opens the briefing for the example operation."
priority = 50
on_click = "page:briefing"

[[pages]]
id = "briefing"
title = "Example Operation"
content = "Hold the line for ten minutes. Reinforcements arrive at dawn."
action_label = "Begin"
action_on_click = "exampleStartOperation"
```

```lua
function exampleStartOperation()        -- a plain global function
  print("[Example Mod] operation started")
end
```

| Mode key | Meaning |
|---|---|
| `id`, `title` | Required. |
| `subtitle`, `description` | Text on the card and its tooltip. |
| `icon` | An image shown on the card, as a path the game can open, such as `Mods/ExampleMod/card.png`. |
| `priority` | Cards with higher numbers come first. Default 50. |
| `on_click` | `"page:<page id>"` opens one of your pages; any other text is the name of a global function to call. |

Function names in `on_click` and `action_on_click` here must be plain globals (`exampleStartOperation`), not a dotted path into a table. Keybinds and option buttons accept dotted names; modes and pages don't.

| Page key | Meaning |
|---|---|
| `id`, `title` | Required. |
| `content` | The text. |
| `action_label` | The text of the action button. Without it there is no button. |
| `action_on_click` | The name of a plain global function the button calls. |

From Lua the same things are `QM.Menu.registerMenuButton(def)` and `QM.Menu.registerPage(def)`, where `on_click` and `action_on_click` may be functions.

## A fully custom screen

For a screen you draw yourself, ask for a page number and supply two functions: one that draws, one that creates the buttons.

```lua
local function draw()
  love.graphics.printf("Example Mod statistics", 50, 200, 800, "left")
end

local function registerButtons()
  -- Button.new(x, y, width, height, label, status, hoverable, tooltip)
  buttons[#buttons + 1] = Button.new(32, 686, 60, 30, "example_back", "active", true, "Back")
end

function example_backButton()      -- clicking a button calls the global <label>Button
  menuPage = 1                     -- 1 is the main menu
end

local pageNumber = QM.Menu.allocatePage("example_mod", "stats", draw, registerButtons)
-- Open it from anywhere with: menuPage = pageNumber
```

The game shows whichever screen `menuPage` holds. `allocatePage` hands out numbers from 100 up so mods never collide; asking again with the same mod id and page id returns the same number. `QM.Menu.getPage("example_mod", "stats")` looks a number up.

A button's click handler is always the global function named after its label plus `Button`. Since that name is shared by every mod, start your labels with your mod id.

### QM.Menu functions

| Function | Does |
|---|---|
| `registerOption(modId, modName, def)` | Adds or replaces an option. |
| `getOptionValue(modId, def)`, `setOptionValue(modId, def, value)` | Reads or sets an option by its definition table (`{ id = "double_xp" }` is enough). Setting saves at once. |
| `getVisibleOptions(modId)` | The mod's options whose `show_if` currently passes. |
| `registerMenuButton(def)`, `registerPage(def)` | Adds a Mod Operations card or a simple page. |
| `allocatePage(modId, pageId, drawFn, buttonsFn)`, `getPage(modId, pageId)` | Custom screens. |
| `saveCurrentSettings()`, `loadSavedSettings()` | Writes and reads `saveModSettings.lua`. |
| `PAGE_MOD_MODES`, `PAGE_MOD_OPTIONS` | The screen numbers 85 and 86. `QM.Input.PAGE_CONTROLS` is 87. |

---

# Part 7: Working with other mods

Two mods often patch near the same line. Most of the time both simply apply: each inserts its code and QuarterMaster stacks the blocks. Trouble starts when one mod rewrites the very line another mod hooks, so the second mod's code lands in the wrong place or is lost. This part covers the tools for that, from the lightest to the heaviest.

The game and the launcher's preview run the same patch code, so what the launcher's Patches tab shows is what the game gets.

A few words used throughout this part:

- **A** is the patch being placed or changed: yours, or the one a compatibility patch changes.
- **B** is the other patch that A is placed on.
- A **site** is one place where A's own `pattern` matches the unchanged game file. A patch with `times = 3` can have three sites.
- A **block** is the code one patch inserted at a line.

The examples use three made-up mods: `example_mod` (yours), `other_mod` and `third_mod`.

## Name your patches and declare what you need

Two habits prevent most trouble:

- Give every patch an `id`. Everything in this part refers to patches by name, written `mod_id:patch_id`, where the mod id comes from `mod.json` and not from the folder name. A patch whose `id` already starts with its mod id (`example_mod:require`) is named by that id as it is. Without an `id`, QuarterMaster makes one up from the patch's position in the file, and that changes as soon as you add a patch above it.
- If your mod builds on another, list it in `mod.json` under `requires` (it must be present) and `load_after` (your changes come after its changes).

A mod delivered as a `.zip` in the Mods folder has its id, version and relationships read from the `mod.json` inside the zip, so everything in this part works for it as well. If that `mod.json` can't be read, the zip loads with its file name as its id and a warning.

## Where your block goes at a shared line

When several mods insert at the same line, their blocks stack. In a profile set to dependency order (the default for new profiles), a mod that `requires` or loads after another has its block placed below that mod's blocks. Mods with no relationship keep the older load order, and so does a profile still set to the older order. If "below the other mod's block" is all you need, `load_after` is enough.

To ask for the top or the bottom of the stack, add `stack` to a pattern or regex patch:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:require"
target = "main.lua"
pattern = 'require "includes/directives"'
position = "after"
payload = 'ExampleMod = require "includes/example"'
stack = "last"               # or "first"
```

- `"first"` puts the block on top of the code at that line, so it runs first. `"last"` puts it at the bottom.
- It works in every stacking mode, the older order included.
- In dependency order, a mod you need still stays above your block and a mod that needs yours stays below it. A `"first"` block therefore goes right below the last mod it needs.
- The hint stays with the block: code another mod adds later at that line never goes above a `"first"` block or below a `"last"` block, unless dependency order or a stack rule (see [Compatibility patches](#compatibility-patches)) says otherwise.
- Two blocks from the same mod keep their usual order between them.
- Any other value is ignored with a warning and the patch applies as usual.

## A patch that needs another patch

A pattern or regex patch can list the patches it depends on:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:use_helper"
requires = ["example_mod:add_helper", "other_mod:load_module"]
target = "main.lua"
pattern = 'tensionLoop:setLooping(true)'
position = "before"
payload = 'ExampleMod.useHelper()'
```

- Each entry is a patch name, or `mod_id:*` for all of a mod's patches, as in `before` and `after`.
- A needed patch in the same file runs first. If it did not apply there (it found no line, or it is turned off), this patch is skipped too, with the warning `needs_patch`. A patch that needs the skipped one is skipped in turn.
- A needed patch in a different file is only checked for being loaded and turned on. The game patches each file when it loads it, so it cannot wait for another file.
- A name that matches no loaded patch gives a warning and the patch still runs.
- When two patches need each other, the one that runs first is not checked and gets a warning.

This `requires` on a patch is separate from `requires` in `mod.json`, which is about whole mods.

## Anchors: placing your code on another mod's code

An anchor says "put my code next to the code that patch added", with your own `pattern` as the fallback when that patch isn't there. Add `[[patches.pattern.anchors]]` tables under the patch:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:after_other"
target = "main.lua"
pattern = 'require "includes/directives"'    # the fallback, used when other_mod is off
position = "after"
payload = 'ExampleMod = require "includes/example"'

[[patches.pattern.anchors]]
within = "other_mod:load_module"
edge = "end"                                 # after the last line of that patch's block
```

With `other_mod` enabled, your line goes directly after the last line of its block instead of somewhere among the blocks at that line. With `other_mod` off, your line goes after `require "includes/directives"` as it would without the anchor.

An anchor on another mod's patch is only used if your `mod.json` lists that mod under `requires`. Anchors on your own mod's patches need nothing.

### The three kinds of anchor

**The other patch's first or last line.** `within` plus `edge = "start"` (before B's first line) or `edge = "end"` (after B's last line), as above. An edge anchor is only used when B's lines at that place close every block they open; an edge on a patch that ends inside an open `if` is never used.

**A line inside the other patch's code.** `within` plus `pattern`:

```toml
[[patches.pattern.anchors]]
within = "other_mod:halt_fix"
pattern = "OtherMod.clearPath(soldier)"
exact = true
```

The text must be found in the lines B wrote or kept at that place; lines a third mod added in between don't count. Without `exact`, `*` and `?` work as in a normal `pattern`. With `exact = true` the line must match exactly once its spaces are trimmed. The match must be unique unless you set `nth`.

**A line anywhere in the file.** `pattern` without `within` searches the whole file as it is at that point, other mods' changes included. Use it to move a patch to a line that another mod added.

### Anchor keys

| Key | Meaning |
|---|---|
| `within` | The other patch (B), as `mod_id:patch_id`. One patch only; `mod_id:*` is not allowed. |
| `edge` | `"start"` or `"end"`. Needs `within`; can't be combined with `pattern`. |
| `pattern` | The text to find: inside B's code with `within`, otherwise in the whole file. |
| `exact` | `true`: whole-line match, no wildcards. Default `false`. |
| `nth` | Which match to use (1 is the first) when the text is found more than once. |
| `position` | `"before"` or `"after"` the anchor line. Default: the patch's own `position`. |
| `b_site` | Which of B's places to use (0 is the first), when B matches in several places and A is at none of them. |
| `check` | A hash of B's boundary line that the launcher writes for edge anchors. Leave it out when writing by hand. |

### How an anchor is chosen

A patch can list several anchors. For each of A's sites, QuarterMaster tries them in order and uses the first that works; A's own `pattern` is always the last resort. An anchor on B works at a site only where B is at that same place: B inserts on the same line, rewrites it, or keeps it while rewriting the lines around it. A is never inserted more times than it has sites.

An anchor also makes B run before A, so that B's code is there to be found. This is a hard rule: a priority or a `before`/`after` that says otherwise is dropped and reported.

An anchor is not used when:

- B is off, its mod is off, or B patches a different file;
- the text is not found in B's lines, or is found more than once without `nth`;
- B has changed since a launcher-made edge anchor was created;
- using it would create a loop of ordering rules with other anchors.

The patch then uses its own `pattern` at that site, and the patch report says why.

### Limiting anchors to some sites

When A matches in several places and only some should move, add a `sites` list next to `anchors` (`[[patches.pattern.sites]]`). Each entry is `{ context = "<32 hex>", ordinal = 1 }`: a hash of the lines around the site in the unchanged game file, and which match it is when several have the same surrounding lines. Sites left out keep A's own line. The hashes are not practical to write by hand; the launcher's anchor picker and **Save as compatibility patch...** write them. Without `sites`, the anchors are tried at every site.

### What can take anchors

Anchors work on `pattern` patches with `position = "before"` or `"after"`, and on `regex` patches. An anchor on a `copy` or `module` patch, or with `position = "at"`, is skipped and reported, and B can never be a module patch.

An `at` pattern patch can take anchors only when it runs as separate edits (see [the next section](#keeping-lines-other-mods-need-apply_as)) and only keeps lines and adds new ones. Its anchors then say where to find its own lines:

- `within` alone: its lines are looked for inside B's code at that place. With more than one match, `nth` picks one.
- `within` with `pattern`, or `pattern` alone: the anchor finds a line, and the patch's own lines must contain it exactly once.
- `edge` and a `position` on the anchor are skipped and reported.

### Anchors on regex patches

A regex patch takes `anchors` and `sites` like a pattern patch. Its sites are its matches in the unchanged game file. The anchor says where to search; the regex then changes or inserts at its match as usual.

- `within` alone: the regex searches only B's lines at that place. With more than one match, `nth` picks one.
- `within` with `pattern`, or `pattern` alone: the anchor finds a line, and the regex must match exactly once on it.
- `edge`: the payload goes in as whole lines before B's first line or after B's last. This only works for a regex that inserts (not `"at"`) and whose `payload` and `line_prepend` use no capture group; otherwise the anchor is skipped with the reason `needs_capture`.
- Leave `position` off the anchor; the regex places its code by its own `position`.

## Keeping lines other mods need: `apply_as`

An `at` patch removes the lines it matched and writes its payload in their place. If the payload repeats some of those lines, any code another mod attached to them is lost, and a later patch no longer finds its line.

`apply_as = "edits"` on an `at` pattern patch runs it as separate edits instead:

```toml
[[patches]]
[patches.pattern]
id = "example_mod:new_profile_extra"
target = "main.lua"
pattern = '''
player = {}
newProfile(player)
'''
position = "at"
payload = '''
player = {}
newProfile(player)
ExampleMod.onNewProfile(player)
'''
apply_as = "edits"
```

QuarterMaster compares the pattern lines with the payload lines, ignoring indentation:

- A line both have is **kept**. It stays in the file exactly as the game wrote it, and other mods can still attach code to it.
- Payload lines between kept lines are **inserted** next to the kept line above them (or below, at the top), and stack there like a `before` or `after` patch.
- Other lines are changed or removed in place.

In the example both original lines are kept and only the third is added. (This simple case could be an `after` patch; `apply_as` earns its place when new lines sit between kept ones.)

Details worth knowing:

- A pattern line containing `*` or `?` is never kept; it counts as changed.
- The patch still needs all of its pattern lines to match, in order.
- New lines another mod inserted between your pattern lines are skipped over: they stay where they are. Lines another mod changed are never skipped.
- A place where one of your changed or removed lines has another mod's lines in the middle is skipped with the warning `edits_refused:split_change`, so no mod's code is removed.
- On a `before` or `after` patch with a multi-line pattern, `apply_as = "edits"` only does the skipping-over: the patch finds its lines again when another mod's new lines sit between them.

The patch falls back to running as one replacement, with the warning `edits_refused:<reason>`, when:

| Reason | Cause |
|---|---|
| `ambiguous` | The lines can be paired in more than one way, often because of repeated `end` lines. |
| `scope` | A new line next to a kept line opens or closes a block, as when the payload wraps a kept `function` line in a new function. |
| `long_string` | A kept or new line is inside a long string or long comment. |
| `too_large` | The pattern and payload are too long to compare. |

### Two mods changing the same line

When two mods' `at` patches change the same game line, only the first change can stay: the second patch no longer finds the line and misses. The launcher reports this as "both change line N" and offers to keep one mod's change or the other's. The patch whose change is dropped skips that one edit and runs as separate edits, so its other edits still apply. Its record carries the warning `hunk_skipped:<n>`. A compatibility patch can make the same choice with `skip_hunks` (below).

QuarterMaster does not merge two mods' changes to one line into a single line.

## Order and failures within one file

- `on_failure = "skip_mod"` on a patch that fails skips the rest of that mod's patches **in that file only**. The mod's patches in other files still run, because the game patches each file when it loads it.
- `on_failure = "abort"` on a patch that fails stops the game with a Lua error when it loads that file. The launcher reports it before launch as an error.
- Copy patches run before the pattern and regex patches of the same file, so those can patch the copied code. A copy that names a pattern or regex patch of the same file in its `after` runs right after that patch instead. A `mod_id:*` rule never moves a copy.
- In `main.lua`, QuarterMaster adds a block of its own at the top (the Steam safety code) and one at the end. A `prepend` copy goes below the top block and an `append` above the end block. An append whose code ends in a top-level `return` stays at the very end, with the warning `copy_after_footer:return`.
- No patch can match the lines QuarterMaster adds to `main.lua`. The lines it changes in place (the save folder line in `conf.lua`, the score upload in `includes/external.lua`) can be used as a `before` or `after` line, but a patch that would remove or rewrite one is not applied there, with the warning `matched_qm_startup_code: skipped`.

## Compatibility patches

A compatibility patch is a small mod that changes *another* mod's patches, so two mods work together without editing either. It is an ordinary mod: a `mod.json`, and a `qm.toml` with `[[overrides]]` entries. It may also have patches of its own.

```json
{
  "id": "compat_example_other",
  "name": "Example Mod + Other Mod",
  "version": "1.0.0",
  "relationships": {
    "requires": { "example_mod": ">=1.0.0", "other_mod": ">=1.0.0" },
    "load_after": ["example_mod", "other_mod"]
  },
  "qm_features": ["overrides", "anchors"]
}
```

```toml
[manifest]
version = "1.0.0"

# Turn off a patch that the other mod makes unnecessary.
[[overrides]]
patch = "other_mod:old_halt"
disable = true

# Run one patch after another.
[[overrides]]
patch = "example_mod:require"
after = ["other_mod:load_module"]

# Keep Example Mod's halt code next to Other Mod's copy of the line it hooks.
[[overrides]]
patch = "example_mod:halt_extra"
[[overrides.anchors]]
within = "other_mod:halt_fix"
pattern = "OtherMod.clearPath(soldier)"
exact = true
```

### Override keys

| Key | Meaning |
|---|---|
| `patch` | The patch to change, as `mod_id:patch_id`. Required. |
| `disable` | `true` turns the patch off. |
| `priority` | Gives the patch a new priority. |
| `before`, `after` | Patch names: run this patch before or after them. |
| `anchors` | Anchors, as described above. They are tried before the patch author's own. |
| `replace_anchors` | `true` drops the author's anchors and uses only yours. |
| `sites` | Which of the patch's sites the anchors apply to. |
| `apply_as` | `"edits"` or `"literal"`: how an `at` patch runs. |
| `skip_hunks` | Edits of an `at` patch that should not run, so another patch's change to the same line stays. |
| `stack_below`, `stack_above` | At a shared line, put the patch's block below or above another patch's block. |
| `stack_site`, `stack_side` | The line and side a stack rule is for. Optional. |
| `fingerprint` | The patch's content when the entry was written. Optional but recommended. |

An entry needs at least one change. A key QuarterMaster doesn't recognise (a typo such as `disabled`) makes the whole entry invalid, so a half-read entry is never applied. A mod with a bad entry still loads; only that entry is skipped.

### Permission

An override only applies when the compatibility mod `requires` every mod the entry refers to: the mod of `patch`, of every `within`, of every name in `before` and `after`, and of `stack_below` and `stack_above`. Mods are matched by id, ignoring case, and through `provides`. `load_after`, `recommends` and `suggests` don't count.

An entry that names a mod you don't require is ignored and reported. The reason for the rule: an override changes when another mod's patch runs, and a mod should only change mods it was built for.

### Fingerprints

```toml
[[overrides]]
patch = "other_mod:old_halt"
fingerprint = { anchor = "<32 hex>", payload = "<32 hex>" }
disable = true
```

`anchor` is a hash of where the patch goes (target, pattern, position) and `payload` a hash of its code. Ids, names, priorities and `before`/`after` are not part of them. When the other mod later changes that patch, the entry is switched off instead of being applied to code it wasn't written for. If the patch only got a new id, the entry finds it again by its content.

Hashes are not practical to write by hand. Make the change as a fix in the launcher and use **Save as compatibility patch...**, which writes them for you. Without a fingerprint, the entry applies to whatever patch has that name.

### Stack rules

A stack rule puts one patch's block directly below or above another patch's block at a shared line. It is stronger than a `stack` hint and works in every stacking mode.

```toml
[[overrides]]
patch = "example_mod:require"
stack_below = "other_mod:load_module"
stack_side = "after"
```

- `stack_below` or `stack_above` names the other patch.
- `stack_site` (`{ context = "<32 hex>", ordinal = 1 }`) limits the rule to one game line, as the launcher's stack view writes it. Without it, the rule acts at every line where both blocks meet.
- `stack_side` is `"before"` or `"after"` the line. Without it, both sides.
- The rule does nothing at a line where the other block is absent, for example when that patch is off.

Order of strength: the player's own rule, then a compatibility patch's rule, then dependency order, then the author's `stack` hint.

### Skipping one edit of an `at` patch

`skip_hunks` records the choice described under [Two mods changing the same line](#two-mods-changing-the-same-line):

```toml
[[overrides]]
patch = "example_mod:armor_change"
fingerprint = { anchor = "<32 hex>", payload = "<32 hex>" }

[[overrides.skip_hunks]]
fp = { anchor = "<32 hex>", payload = "<32 hex>" }
vanilla = "u.armor = 2"
ordinal = 0
keep = "other_mod:armor_change"
```

`ordinal` counts the patch's edits from 0 (kept lines don't count), `vanilla` is that edit's pattern lines, trimmed, and `fp` is the patch's content. `keep` names the patch whose change stays; its mod must be in `requires` too. If the patch changed or the edit is gone, nothing is skipped and the entry is reported. Like fingerprints, these are meant to be written by the launcher.

### Who wins

1. The player's own fixes in the profile.
2. Compatibility patches. When two of them change the same thing on one patch, the later one in load order wins.
3. The patch author's own keys.

A compatibility patch's `disable` always applies; the player has no fix that turns a patch back on.

### What the player sees

Every entry gets a status, written to the game log, to `patch-report.json` and shown in the launcher's Patches tab:

| Status | Meaning |
|---|---|
| `applied` | The change is in effect. |
| `rejected_not_required` | It refers to a mod this mod doesn't require. Ignored. |
| `waiting` | The target mod is off. Nothing happens until it is turned on. |
| `target_missing` | The target mod has no such patch. |
| `suspended_drift` | The patch changed since the entry was made, or several patches could be the one meant. Off. |
| `superseded` | A later compatibility patch changes the same thing. |
| `superseded_by_profile` | The player's own fix on that patch wins. |
| `invalid` | The entry could not be read (unknown key, bad name, no change). Skipped. |

### Making one from fixes in the launcher

This is the easy way, and the only practical way to get fingerprints and site hashes. Fix the conflict in the launcher first: turn a patch off, order two patches, move a patch next to another mod's code, run an `at` patch as separate edits, keep one of two changes to a line, or order two blocks at a shared line. Then, in **Mods > Patches > Fixes**, choose **Save as compatibility patch...** on the fix.

- The mod's id is `compat_<mod>_<mod>`; you choose the name.
- `requires` and `load_after` list every mod the fixes touch, at the version you have or newer.
- `qm_features` lists exactly the features its `qm.toml` uses.
- Each fix becomes one `[[overrides]]` entry with its fingerprint, and a `README.txt` says what it does in plain words.
- Before saving, the launcher runs the profile with the new mod in place of the fixes and compares every file. It saves only when the game code comes out the same.
- Saving installs the mod, turns it on in the profile and removes the fixes it replaces. **Undo** reverses all of that.

Load order changes and adjusted copies (next section) can't be saved this way. A paused fix, or a fix on a mod that is off, has to be resumed or turned on first.

The saved mod is an ordinary folder. Share it like any other mod.

## Adjusted copies

A player can also replace one of your patches with an adjusted copy: the launcher copies the patch, the player edits the lines it looks for, and the profile runs the copy instead of the original. Copies live in the player's profile, not in any mod, so there is no key for them in `qm.toml`. As an author you only need to know how they behave:

- A copy runs as the mod it was copied from, at the original patch's place in the order. That mod's `on_failure = "skip_mod"` covers it, `mod_id:*` ordering rules match it, and a crash in it names the mod, the copy and its fix.
- A copy's lines match only their exact text: `*` and `?` in them are not wildcards.
- A copy keeps the original's number of places, and a copy of a regex patch stays a regex. A regex that uses capture groups or `root_capture` is not offered as a copy.
- A copy does not run while its mod is off, failed to load or is missing.
- A compatibility patch cannot change a copy.

## Feature gates: `min_qm` and `qm_features`

If your mod uses newer QuarterMaster features, say so in `mod.json`. A QuarterMaster that lacks them skips the mod, and every mod that requires it, and tells the player why ("needs QuarterMaster 1.2.0 or newer (this is 1.0.0)") instead of loading it half-working.

```json
{
  "min_qm": "1.2.0",
  "qm_features": ["anchors", "apply_as"]
}
```

`min_qm` is a version (`"1.2.0"` means that version or newer) or a range (`">=1.2 <2"`). A value that is not a version also skips the mod. `qm_features` lists features by name:

| Feature name | List it when you use |
|---|---|
| `overrides` | `[[overrides]]` entries |
| `anchors` | `anchors`, `within`, `sites`, `replace_anchors` |
| `regex_anchors` | Anchors on regex patches |
| `stack_hint` | The `stack` key |
| `stack_rules` | `stack_below` / `stack_above` in an override |
| `apply_as` | `apply_as = "edits"` |
| `skip_hunks` | `skip_hunks` in an override |
| `run_as` | Adjusted copies that run as their base mod (written by the launcher) |
| `min_qm` | The `min_qm` key itself |
| `sprite_sizes` | `[sprites]` rules, or images that rely on being shown at the original's size |

List the features the mod uses, and only those. The gates cover a whole mod; there is no way to gate a single patch or override entry. Patch-level `requires` has no feature name; if your mod depends on it being checked, set `min_qm`.

## Code checks

The launcher also reads what the patched code means, in the order the game runs it, and warns about combinations that probably don't do what their authors meant. These are warnings and notes; none of them blocks a launch.

| Check | Raised when |
|---|---|
| `redefined_global` | Two mods define the same global function and the one that runs last doesn't call the other. The other never runs. |
| `double_hook` | Two mods wrap the same global function and the wrapper installed later drops the earlier one: it copied the function too early, or never calls its copy. |
| `capture_before_define` | A patch copies a global (`local orig = someFunction`) before another mod's patch defines it. The copy holds the old value, or nil. |
| `table_literal_reset` | A patch sets a shared global table to a new table (`modSettings = { ... }`) after another mod added fields to it. Write `modSettings = modSettings or {}` instead. |
| `shared_file_writer` | Two mods write the same file and one doesn't read it first in the same function, so it drops what the other saved. When both read first, it is only a note. |
| `key_collision` | Two mods act on the same key with the same modifier keys in their own key handlers. Keybinds declared in `config.toml` are handled by the Controls screen instead and are not flagged. |
| `name_collision` | Two mods add a button with the same label (a click calls one shared global, `<label>Button`), or use the same `menuPage` number. |
| `shared_field` | Two mods set the same field on a soldier, the player or another game table, and the game itself never sets it. A note: both are storing their own data in one field. |
| `dead_code` | A patch adds code inside a branch that never runs (`if false then`, `if(1 == 0) then`). |
| `early_return_shadow` | A patch adds code after another patch's unconditional `return` in the same function. A `return` inside an `if` is not counted. |
| `bypassed_hook` | A mod's `at` patches removed a call or test from every game line that had it, and another mod's code still calls or tests it the old way, going around the first mod's change. |
| `block_balance` | One mod's patches on a file open more blocks than they close, or the reverse. Patches that open and close one block as a pair leave the file broken when one of them is off or didn't apply. |
| `moved_scope` | Shown only when previewing a fix: the fix moves a patch's code into a different function, so it runs at another time and sees other locals. |
| `free_name_changed` | Shown only when previewing a fix: a name the moved code uses means something else at the new place. |

The checks read tokens and blocks rather than fully parsing Lua, so they can be wrong on unusual code, and they only see literal names: a file name or key built at run time is not seen.

If you have looked at a finding and it is fine, silence it in `mod.json`. Each entry is `<check>:<name>`, or `<check>:*` for every name:

```json
{ "overrides": ["redefined_global:loadModSettings", "key_collision:ctrl+f9", "early_return_shadow:*"] }
```

| Check | What `<name>` is |
|---|---|
| `redefined_global`, `double_hook`, `capture_before_define` | The global's name. |
| `table_literal_reset` | The table's name. |
| `shared_file_writer` | The file name as written in the code (`shared_file_writer:example_settings.lua`). |
| `key_collision` | The modifiers and the key, modifiers in the order alt, ctrl, gui, shift (`key_collision:ctrl+f9`). |
| `dead_code`, `early_return_shadow` | The function the code is in, or the file name for code outside functions. |
| `bypassed_hook` | The function name or the test as shown (`bypassed_hook:calcDamage`). |
| `shared_field` | The field (`shared_field:pathQueue`). |
| `name_collision` | `<label>Button` or `menuPage=<n>` (`name_collision:menuPage=101`). |
| `block_balance` | The file (`block_balance:main.lua`). |

A finding is silenced when either of the two mods it names lists it. This `overrides` list in `mod.json` is unrelated to the `[[overrides]]` tables in `qm.toml`.

### Checking in the running game: a diagnostic test run

The code checks read the code; they don't run it. To see what really happens, open **Diagnostics** in the launcher and choose **Trace globals...**. It starts the game once with tracing on:

- **Globals to watch.** While the game loads (up to the end of its first frame), every time one of these names gets a new value the game notes the file and line that set it. The result lists the changes in order, each with the mod and patch that owns the line, or "the game's own code". Two mods setting the same name is the usual cause of one mod's function disappearing.
- **Functions whose callers to count.** After the game has loaded, each of these functions (`name`, or `Table.name`) counts the places that call it, for as long as the run lasts. The result shows each place with its number of calls, which tells you whether your hook runs once or several times per event.

The fields start with the names the code checks flagged (`redefined_global`, `capture_before_define`, `double_hook` and `name_collision` findings whose name is a plain global). You can change them before starting.

A diagnostic run leaves nothing out of the profile. The save is backed up first, the game loads more slowly while it is traced, and the result stays in the profile's run log. Normal launches are never traced.

## What isn't supported

- Anchors on copy and module patches, and on `at` pattern patches that run as one replacement.
- Stacking for an `at` patch that runs as one replacement: it removes its lines and writes them again, so it has no block to stack. Run it as separate edits and its new lines stack. Likewise a regex that replaces text or inserts inside a line keeps its place; only a regex that inserts whole lines stacks.
- Merging two mods' changes to one line into a single line.
- `on_failure = "skip_mod"` across files.
- Moving an appended copy above a `return` at the end of a file. The launcher's compile check stops a launch with such a file and names the patch.
- Gating a single entry on a QuarterMaster version.

---

# Part 8: Game reference

The game is about 130,000 lines of Lua. This part lists what mods use most. Everything here was checked against the v0.5.3b sources; for anything else, extract the files (Ctrl+Shift+D in [debug mode](#debug-mode)) and search them.

## Files

| File | Holds |
|---|---|
| `conf.lua` | Window and engine settings. |
| `main.lua` | Start-up, asset loading (`love.load`), and input handling. |
| `includes/urb_engine.lua` | Most of the game: soldiers, weapons, classes, vehicles, menus, saving. |
| `includes/ai.lua` | Enemy and friendly AI, and enemy spawning. |
| `includes/drawFiles.lua` | Drawing: the map, units, HUD and menus. |
| `includes/mnb2.lua` | Classic (wave) mode. |
| `includes/trench.lua` | Trench mode. |
| `includes/bcChecks.lua` | Battle conditions. |
| `includes/directives.lua` | Directive cards. |
| `includes/vehicleEngine.lua` | Vehicle damage. |
| `includes/mapBuild.lua`, `includes/mapGeneration.lua` | Map building. |
| `includes/particlesSystem.lua` | Particles, fire, destruction, loot drops. |
| `includes/localisation.lua` | Every text string, as plain global variables. |
| `includes/ser.lua` | The save serializer. |

`main.lua` loads the others with `require` lines at its top; `require "includes/directives"` is the last of them.

## When things run

| Function in `main.lua` | Runs |
|---|---|
| `love.load()` | Once at start. Loads every image and sound, then the save, then calls `setOptionVolume()`. Asset mods load just before that call; factions and mod configs just after. |
| `love.update(dt)` | Every frame, before drawing. |
| `love.draw()` | Every frame. |
| `love.keypressed(key)`, `love.keyreleased(key)` | On key presses. |
| `love.mousepressed(x, y, button)`, `love.mousereleased(x, y, button)` | On mouse clicks. |
| `love.quit()` | On exit. |

To run code in one of these, add a pattern patch `after` its `function` line, as in [Part 5](#module-patches).

## The `player` table

`player` is one global table holding the whole game state. It is also what gets saved, so anything you add to it is written to the save file.

| Field | Holds |
|---|---|
| `player.deployedTroops` | Every soldier on the map, both sides. |
| `player.deployedVehicles` | Every vehicle and gun on the map. |
| `player.screenx`, `player.screeny` | The camera offset. Map position = mouse position + this. |
| `player.tp`, `player.command` | Tactical points and command points. |
| `player.gameType` | `0` campaign, `1` classic. |
| `player.gameState` | `0` in battle, `1` in menus. |
| `player.diff` | Difficulty level. |
| `player.unlock` | The weapon upgrade tiers for each class: `player.unlock.rifle[1]` and so on. |
| `player.buildings`, `player.placeables`, `player.deco` | Buildings, placed objects (wire, sandbags), and decals. |
| `player.groundType`, `player.forest`, `player.fire` | Terrain patches, trees, and active fires. |
| `player.lootables` | Items lying on the ground. |
| `player.particles` | Active particles. |

## A soldier

Each entry of `player.deployedTroops` is a table. Game code usually calls it `dude` or `soldier`.

| Field | Holds |
|---|---|
| `id` | A unique number. `convertedId(id)` turns it into the soldier's index in `player.deployedTroops`, or -1. |
| `faction` | `"allied"` or `"axis"`. |
| `tag` | Which unit art to draw: `"allied"`, `"sarge"`, `"para"`, `"french"`, `"axis"`, `"officer"`, `"volks"`. |
| `playerControlled` | `1` for the player's soldiers, `0` for AI. |
| `name` | Display name. |
| `x`, `y`, `rotation` | Position and facing. |
| `targetx`, `targety` | Where the soldier is walking to. |
| `health`, `maxHealth` | Health. A soldier with 10 or less is out of action. |
| `dead` | `0` alive, `1` dead. |
| `state` | The animation frame, such as `"idle"`, `"aim"`, `"fire"`. Drawn as the image `<tag>_<state>`. |
| `spec` | Class: `""` for a recruit, or `"rifle"`, `"light"`, `"gunner"`, `"medic"`, `"comms"`, `"officer"`, `"engy"`, `"scout"`, `"sniper"`, `"commando"`, `"sapper"`, `"intel"`. |
| `weapon` | The weapon table (below). |
| `skill`, `speed`, `detectRange`, `mineDetectRange`, `hthDamage`, `armor` | Combat stats. |
| `rank`, `xp`, `kills`, `patrols` | Progress. |
| `morale`, `pinned`, `stress` | Morale state. |
| `selected` | Whether the player has the soldier selected. |
| `flagged` | Seconds the soldier stays revealed to the enemy. |
| `save`, `maxSave` | Veterancy saves left and earned. |
| `skill1Timer`, `skill2Timer`, `skill3Timer` | Cooldowns of the three class skills, in seconds. |

Loop over soldiers like this:

```lua
for i = 1, #player.deployedTroops do
  local dude = player.deployedTroops[i]
  if dude.faction == "allied" and dude.health > 10 then
    -- an Allied soldier who is still fighting
  end
end
```

## A weapon

`dude.weapon` is filled in by `weaponCreator(weapon, tag)`.

| Field | Holds |
|---|---|
| `tag` | The weapon's name, such as `"m1"`. Its images are `top_<tag>` and `side_<tag>` and its text is `weaponText_<tag>`. |
| `action` | `"semi"`, `"bolt"` or `"auto"`. |
| `class` | `""`, `"smg"`, `"lmg"` or `"atRifle"`. |
| `ammo`, `maxAmmo` | Rounds in the magazine and its size. |
| `range`, `damage`, `recoil`, `bulk` | Stats. |
| `rof`, `rofTime` | Rate of fire as shown, and the real delay between automatic shots. |
| `jam`, `jammed` | Jam chance per thousand, and whether it is jammed now. |
| `sound`, `magSprite` | The names of the fire sound and magazine image. |
| `rgCapable` | `1` if it can fire rifle grenades. |

To add a weapon without a faction, wrap `weaponCreator` ([Part 5](#wrapping-a-game-function)): build your weapon when your tag is asked for, and call the original for every other tag. The game falls back to a `k98` for tags it doesn't know.

## A vehicle

Entries of `player.deployedVehicles` have `tag` (`"sherman"`, `"tiger"` ...), `faction`, `callSign`, `x`, `y`, `rotation`, `health`, and `operationalTimer` (seconds before it leaves). A vehicle's images are named `<tag>Body`, `<tag>Turret`, `<tag>_husk` and `<tag>_debris1` onward.

## Menus and buttons

| | |
|---|---|
| `menuPage` | The screen shown. `1` is the main menu; the game uses 0 to 20, QuarterMaster 85 to 87, and mods 100 and up. |
| `buttons` | The list of buttons on the current screen, rebuilt each time the screen changes. |
| `Button.new(x, y, width, height, label, status, hoverable, tooltip)` | Creates a button. `status` is `"active"` to accept clicks. |
| `<label>Button()` | The global function a click calls. |
| `uiFade` | The menu's current opacity (0 to 255), for fading your drawing with it. |
| `bigFont`, `cardFont` | The menu fonts. |

## Useful functions

| Function | Does |
|---|---|
| `randNbr(max)` | A random whole number from 1 to `max`. |
| `distanceCheck(x1, y1, x2, y2)` | The distance between two points. |
| `distanceCheck2(a, b)` | The distance between two units. |
| `los(x1, x2, y1, y2)`, `los2(shooter, target)` | Line of sight between points or units. Note the argument order of `los`. |
| `underCover(dude)` | Whether a soldier is in cover. |
| `floatyText(dude, text)` | Shows text floating above a soldier. |
| `anounceStuff(text)` | Shows an announcement. |
| `createGrunt(x, y, spec)` | Spawns an Allied soldier. |
| `spawnAxisTroops(x, y, spec)` | Spawns a German soldier. |
| `createAlliedSoldier(dude)` | Fills an empty table with a new Allied soldier's fields. |
| `weaponCreator(weapon, tag)` | Fills a weapon table for a tag. |
| `death(dude)` | Kills a soldier. |
| `moraleHit(dude, amount)` | Applies a morale hit. |
| `buffer(dude, buffType)`, `hasBuffByTag(tag, dude)` | Gives a timed buff, and tests for one. |
| `giveAward(dude, award, icon)`, `hasAward(dude, name)` | Medals. |
| `revealAllEnemies()` | Reveals every enemy for a while. |
| `spawnMNB2Wave()` | Spawns a classic-mode wave. |
| `offerDirective(amount)` | Offers the player a choice of directives. |
| `createFire(x, y, size)` | Starts a fire. |
| `createExplosion(tag, x, y, dad)` | Sets off an explosion. `tag` picks the kind: `"mortarExplosion"`, `"mineExplosion"` and others listed in the function. `dad` is the soldier responsible, or nil. |
| `p38Strike(x, y, shots)` | Calls an air strike on a point. |
| `destruction(x, y, radius, foo)` | Destroys cover and decals in an area. |
| `createLootByName(name, x, y)` | Drops an item. |
| `addParticle(particle, type, x, y, rotation)` | Fills a particle table; then `table.insert(player.particles, particle)`. |
| `newProfile()`, `updateProfile(player)` | Creates a fresh save, and upgrades a loaded one. |
| `setOptionVolume()` | Applies the volume options. |

Text shown in the game lives in global variables in `includes/localisation.lua`: `weaponText_<tag>`, `<spec>_skillText_1` to `_3`, `mouseOver<Class>Spec`, `conditionTitle_<n>` and `conditionText_<n>`, `lootText_<item>`, and so on. Changing text is a one-line assignment in a patch, a `.txt` file in `assets/text/`, or a `[text]` entry in a faction.

---

# Part 9: Tools

## The `qm` command line

`qm.exe` ships with QuarterMaster. The commands a mod author uses:

| Command | Does |
|---|---|
| `qm new <id> "<name>" --template <t>` | Creates a new mod folder from a template (below). |
| `qm lint <mod_dir>` | Checks `mod.json`, runs every patch against the game's files to find patterns that don't match, checks a `faction.toml`, and reports risky code. Run this before every release. |
| `qm validate [--mod-dir <dir>] [--json]` | Runs all enabled mods together offline and reports conflicts between them. |
| `qm test-patches [--target <file.lua>] [--mod-dir <dir>]` | Shows the patched game file with each line marked by the patch that wrote it. |
| `qm faction check <mod_dir> [--json]` | Checks a faction and lists what it changes. |
| `qm watch [--relaunch]` | Watches your workspace folder and re-checks mods as you save. With `--relaunch`, restarts the game. |
| `qm pack <mod_dir> [--out <dir>]` | Builds the release `.zip` and prints its checksum entry. |
| `qm schema [--out <dir>]` | Writes the editor schemas: `mod.schema.json`, `qm.schema.json`, `faction.schema.json`. |
| `qm sync-workspace [<dir>]` | Imports every mod in a workspace folder into the launcher's library. |
| `qm import <path>` | Imports one mod (folder or zip). |
| `qm launch [--profile <id>] [--vanilla]` | Starts the game with a profile, or without mods. |
| `qm status` | Shows the game path, version, library and profiles. |

`qm profile ...` and `qm save ...` manage profiles and save slots; run `qm --help` for the full list.

### Templates

`qm new` takes any of these with `--template`:

| Template | Starts you with |
|---|---|
| `empty` | `mod.json` and a `qm.toml` with one patch. |
| `single_anchor_patch` | One commented pattern patch. |
| `multi_file_engine_hook` | A module plus patches that call it from the game loop. |
| `asset_file_injection` | A module that adds new files to the game. |
| `faction_mod` | A commented `faction.toml` with every section, and its folders. |
| `sprite_replacer`, `sound_replacer`, `custom_battle_music`, `custom_particle_fx` | Art and audio starters. |
| `custom_weapon`, `custom_soldier_class`, `custom_battle_condition`, `custom_reinforcement_card`, `custom_map_structure` | Gameplay starters. |
| `custom_hud_overlay`, `gmenu_settings` | UI starters. |

Some of the older templates were written before the built-in menu and asset loading existed and do by hand what `config.toml` and `assets/` now do for you. Prefer the approaches in this wiki where they overlap.

## Editor schemas

The three schema files give completion and error checking as you type:

- `mod.json`: add `"$schema": "<path>/mod.schema.json"`.
- `qm.toml` and `faction.toml`: make the first line `#:schema <path>/qm.schema.json` (or `faction.schema.json`). This works in editors with a TOML extension that understands schemas, such as Even Better TOML for VS Code.

`<path>` is either a folder holding your own copy (`qm schema --out <folder>` writes one) or the QuarterMaster site, which always has the current ones:

```
https://gamiseus.github.io/schemas/mod.schema.json
https://gamiseus.github.io/schemas/qm.schema.json
https://gamiseus.github.io/schemas/faction.schema.json
```

## The `qm` Lua module

Inside the game, `require "qm"` (or `require "quartermaster"`) returns a table of information and helpers.

```lua
local qm = require "qm"
print(qm.name, qm.version)       -- "QuarterMaster", "1.1.0"
print(qm.mod_dir)                -- the Mods folder
```

| Member | Is |
|---|---|
| `name`, `short_name`, `version` | `"QuarterMaster"`, `"QM"`, and the version. |
| `mod_dir` | The path of the Mods folder. |
| `log_path` | The path of the current log file. |
| `debug`, `dev` | `true` when the game was started in [debug mode](#debug-mode) or with [developer commands](#developer-commands). |
| `dump_game_files(target, filter)` | Debug mode only. Extracts the game's original files, loaded yet or not. `target` is a folder (relative to the Mods folder, default `qm/game-dump`); `filter` is `"lua"` (default) for scripts or `"*"` for everything. Returns `true, count, path` or `false, message`. `dump_vanilla` is the same function. |
| `dump_patched()` | Debug mode only. Writes every game Lua file with all patches applied to `Mods/qm/dump/`, including files the game hasn't loaded yet. Returns `true, count, path` or `false, message`. |
| `get_var(name)`, `set_var(name, value)`, `remove_var(name)` | Reads and changes the `[vars]` values from [Part 4](#variables-vars). Values are text. |
| `reload_patches()` | Re-reads every mod's patch files from disk. Game files already loaded stay as they were patched. |
| `set_dump_all(on)`, `is_dump_all()` | Whether every file the game loads is saved to the dump folders, not only the ones your mods patch. Off by default, on in debug mode. |

### `QM.Sprites`

The global `QM.Sprites` controls the size an image is shown at ([Part 2](#image-resolution-and-size)). It exists in every modded game.

```lua
local badge = love.graphics.newImage("example_badge.png")   -- a 400x400 file
QM.Sprites.setScale(badge, 0.25)
print(badge:getWidth())                                      -- 100
```

| Function | Does |
|---|---|
| `setSize(image, w, h)` | Shows the image at an exact size. |
| `setScale(image, k)` | Shows it at `k` times its own pixel size. `1` is its pixel size. |
| `matchSize(image, other)` | Shows it at the size `other` is shown at. |
| `reset(image)` | Back to its pixel size. |
| `rawSize(image)` | The file's real width and height. |
| `scaleOf(image)` | Shown size over pixel size, as two numbers (width, height). `1, 1` when it is shown at its pixel size. |

## The launcher

What the launcher shows for a mod, on its page:

| Tab | Shows |
|---|---|
| Overview | The description, authors, links, README, and for an asset mod the files it replaces. |
| Options | The mod's `config.toml` options, editable outside the game. |
| Patches | Every patch and whether it applied, conflicts with other mods, and the fixes for them. |
| Load Order | Where the mod sits and what it depends on. |
| Security | What the code scan found (below). |

The Diagnostics screen has the crash list, the live log, and a health report.

Two switches under **Settings > Launch** matter to mod authors. Both apply to every profile:

| Switch | Does |
|---|---|
| Debug mode | Starts the game in [debug mode](#debug-mode): console window, full dumps, dump keys. |
| Developer commands | Unlocks the game's own [developer commands](#developer-commands). |

## The security scan

QuarterMaster reads every mod's Lua and lists what it is able to do, so players can decide what to trust. Nothing is blocked. A mod that does none of these is reported as plain sandboxed Lua.

| Capability | Found by | Rated |
|---|---|---|
| Running programs | `os.execute`, `io.popen`, `os.remove`, `os.rename` | High |
| Native code | `require "ffi"`, `ffi.load`, `ffi.cdef`, `package.loadlib` | High |
| Network access | `require "socket"`, `socket.http`, `ssl.https`, `enet` | Medium |
| Reading or writing any file | `io.open` and its relatives | Low |
| Loading code at run time | `loadstring`, `loadfile`, `dofile` | Low |

Use `love.filesystem` for files where you can: it is confined to the game's save folder and isn't flagged. `qm lint` shows the same findings before you publish.

---

# Part 10: Testing and debugging

## A working loop

1. Keep your mods in one workspace folder and point the launcher at it (Settings), or run `qm sync-workspace <folder>`.
2. Run `qm lint <mod>` after each change. It catches a pattern that no longer matches without starting the game.
3. Launch from the launcher or with `qm launch`.
4. Read the log, or turn on [debug mode](#debug-mode) to watch it in a console window as the game runs.

`qm watch` automates steps 2 and 3.

## Debug mode

Players never see a console window or a folder full of dumped files: QuarterMaster writes its log quietly and saves only the files your mods patch. Debug mode turns on the extra tools a mod author wants. There are three ways to start it, and any one is enough:

| How | Where |
|---|---|
| The **Debug mode** switch | Launcher, Settings > Launch. |
| `-debug` (or `--debug`) | On the game's command line, for example in a shortcut to `mnb.exe` or in Steam's launch options. |
| `QM_DEBUG=1` | As an environment variable. |

In debug mode:

- A console window opens next to the game and shows the log as it is written, including everything the game and your mods `print`.
- Every Lua file the game loads is saved to the dump folders (below), not only the files a mod patches.
- The dump commands work, from code (`qm.dump_game_files`, `qm.dump_patched`; see [the `qm` Lua module](#the-qm-lua-module)) and from these keys:

| Key | Writes | To |
|---|---|---|
| Ctrl+Shift+D | Every original Lua file of the game | `Mods/qm/game-dump/` |
| Ctrl+Shift+Alt+D | Every game file: scripts, images, audio, fonts | `Mods/qm/game-dump-full/` |
| Ctrl+Shift+P | Every Lua file with all patches applied | `Mods/qm/dump/` |

The dump keys cover the whole game, including files it has not loaded yet. When at least one enabled mod has a `config.toml`, they are listed on the Controls screen under a **QuarterMaster** tab and can be rebound there.

In your own code, `require("qm").debug` tells you whether debug mode is on, so you can keep noisy logging out of players' games:

```lua
local qm = require "qm"
if qm.debug then
  print("[ExampleMod] squad size is " .. tostring(#player.deployedTroops))
end
```

## Developer commands

The game has a few developer tools of its own that are switched off in the released version. QuarterMaster can unlock them. They are meant for testing; a player would call them cheats.

Turn them on with the **Developer commands** switch (launcher, Settings > Launch), with `-dev` on the game's command line, or with `QM_DEV=1`.

| Key | Does |
|---|---|
| F1 | Shows or hides the AI overlay: what each soldier is doing and why. |
| F5 | Turns the dev blast on or off. While it is on, a right-click on the battlefield calls an air strike on that spot. |

Like the dump keys, these appear under the **QuarterMaster** tab of the Controls screen when that screen exists. `require("qm").dev` is `true` while they are unlocked. Debug mode and developer commands are independent: either can be on without the other.

## Files QuarterMaster writes

All under the game's `Mods/qm/` folder:

| Path | Holds |
|---|---|
| `log/latest.log` | This run's log: every mod loaded, every patch applied or missed, and everything the game `print`s. `prev.log` is the run before. |
| `log/err.log` | Only the errors. |
| `log/crashes/` | One report per crash, naming the mod and patch whose code was running. |
| `patch-report.json` | The outcome of every patch, override and anchor, as data. |
| `game-dump/` | Game files as the game loaded them, before patching. Normally only the files your mods patch; in debug mode every file the game loads, and all of them after Ctrl+Shift+D. |
| `dump/` | The same files after patching. When something misbehaves, read your patch in place here. Each patched file has a `.json` beside it listing which patch wrote which lines. |
| `game-dump-full/` | Everything in the game's archive, after Ctrl+Shift+Alt+D in debug mode. |
| `load-order.json` | The active profile's mods, order and fixes, written by the launcher. |
| `blacklist.txt` | Mod folder names to skip, one per line. |

## Common problems

| What you see | Likely cause | Fix |
|---|---|---|
| "resulted in no matches" in the log or lint | The `pattern` isn't in the target file, or another mod changed the line first. | Copy the line again from `game-dump/`. Check `target`. Look at `dump/` to see what the line is by the time your patch runs. |
| "resulted in N matches, wanted 1" | The line appears more than once. | Match several lines, or accept the first with `times = 1`. |
| The game stops with a syntax error naming a game file | A payload left the file unbalanced: a missing `end`, or an `at` patch that removed one. | Open the file in `dump/` at the line given. |
| "attempt to call a nil value" for your function | The code ran before your module was required, or the function isn't global. | Check the order of your patches; assign the module to a global (`_G.ExampleMod = ExampleMod`). |
| "attempt to index global 'player'" | Your code ran at the top of a file, before `love.load` created `player`. | Move it into a function called later. |
| A setting is always on | Testing `modSettings.x` or `player.option_x` for truth. | Compare with `== 1`, or use `QM.settings`. |
| A keybind does nothing | `on_trigger` names something that isn't reachable from the global table. | Make the module global, and check the spelling. |
| The mod doesn't load at all | A missing `requires`, a failed feature gate, or an unreadable `mod.json`. | The log and the launcher say which. |
| A replacement image looks stretched | Its shape (width to height) differs from the original's, and it is fitted to the original's box. | Keep the original's proportions, or set its size under `[sprites]`. |
| A new image is far too large | It has no original to take a size from, so it is shown at its pixel size. | Add a `[sprites]` rule: `scale`, `like` or `size`. |

## Crashes

When Lua code crashes, QuarterMaster works out which mod's patch wrote the line that failed and saves a report. The launcher's crash list shows it and offers to turn that mod off. Reports are most useful when your patches have ids and your code is in modules, where error messages carry your own file name and line number.

---

# Part 11: Packaging and publishing

## Saves, Steam and safety

Things QuarterMaster does for every modded game, which you don't need to handle yourself:

- **Steam stats.** Leaderboard uploads, achievements and stats are switched off while mods are loaded. Don't try to turn them back on.
- **Steam must be running.** The game needs Steam to start. Without it, QuarterMaster shows a message box ("Steam is not running, or this Steam account does not own the game") and closes the game when the box is dismissed. The log has a `[QM] Steam did not start` line. Before this, the game closed with no message.
- **Save slots.** Each profile has its own save slot, so a modded game never touches a vanilla save. A slot used with mods is marked as modded for good. A slot locked as vanilla can't be launched with mods.
- **Damaged saves.** A save file that fails to load does not stop the game. The damaged file is kept as `<name>.damaged` and the game gets the newest copy that loads: `backUp.lua` (for `saveMNB3.lua`), then `<name>.prev`, then a fresh profile. The log says which, in lines starting `[QM] Save guard:`.
- **Previous copies.** Before the game overwrites `saveMNB3.lua`, `saveMNB2.lua` or `saveMNBclassic.lua`, the copy on disk becomes `<name>.prev`, so one lost write costs one save point and not the save. The `.prev` files belong to the save slot and move with it.
- **Faction saves.** A save made with a faction loads without it; see [Part 3](#part-3-faction-mods-factiontoml).

What you should do: fields you add to `player` are saved with the game, so name them after your mod (`player.example_mod_kills`) and cope with them being absent in a save made before your mod was installed.

## Building a release

```bash
qm lint ExampleMod
qm pack ExampleMod --out dist
```

`qm pack` writes `ExampleMod.zip` and prints its entry for a release index, including the SHA-256 checksum. Players install the zip from the launcher; it can also be dropped into the Mods folder as is.

Before you pack:

- Raise `version` in `mod.json`.
- Include a `README.md`. It becomes the mod's page.
- List what you need under `relationships`, and `min_qm` / `qm_features` if you use newer features.

## Updates

`update_keys` in `mod.json` tells the launcher where newer versions appear:

```json
{ "update_keys": ["GitHub:your-name/your-repo#ExampleMod.zip"] }
```

The part after `#` is the file name attached to your GitHub release. `"Nexus:1234"` points at a Nexus Mods page id.

## Listing a mod in the launcher's Browse tab

Published mods appear on the QuarterMaster site and in the launcher's **Mods > Browse** tab, where players install them with one click and get updates automatically. The site checks for new releases every 15 minutes; GitHub sometimes delays a check, so allow up to an hour or two. A mod needs three things to be listed.

### 1. Make the repository findable

Choose one:

- **A topic.** Add the topic `quartermaster-mod` to your GitHub repository (the gear next to "About" on its page). Mods found this way are marked **Discovered**.
- **A registration.** Open a pull request on [gamiseus.github.io](https://github.com/Gamiseus/gamiseus.github.io) that adds one file, `registry/<owner>.toml`, named after your GitHub account:

  ```toml
  repository = "your-name/your-repo"
  ```

  The pull request is reviewed automatically (see [What the site checks](#what-the-site-checks)). When everything passes it is merged for you and the mod is listed. Mods listed this way are marked **Registered**.

  With mods in several repositories, list them all in the one file, up to ten. To add a repository later, open a pull request that adds it to your file.

  ```toml
  repositories = ["your-name/your-repo", "your-name/another-repo"]
  contact = "optional: how to reach you"
  ```

### 2. Add a `[publish]` table

In the mod's `qm.toml`, next to its `mod.json`. The game ignores this table, so it is safe to ship.

```toml
[manifest]
version = "1.0.0"

[publish]
repository = "your-name/your-repo"
asset = "ExampleMod.zip"
summary = "One line shown in the mod list."
image = "preview.png"
```

| Key | Meaning |
|---|---|
| `repository` | Your repository's exact `owner/name` (letter case doesn't matter). Required. It stops forks and copies from being listed by accident: a fork is listed only once its own `[publish]` table names the fork. |
| `asset` | The release file to install. Without it, the first `.zip` or `.qmpack` in the release is used. |
| `summary` | One line of at most 140 characters for the list. Without it, the first line of the mod's description is used. |
| `image` | A picture for the mod's card in the site's mod list: a `.png`, `.jpg`, `.webp` or `.gif` file in the mod's folder (a subfolder is fine: `"art/preview.png"`), at most 1 MB. It is cropped to 16:9 on the card. Without it, the card shows the first letter of the mod's name. |
| `channel` | Only `"stable"` for now. |

The index looks for `qm.toml` files up to three folders deep, so these layouts all work:

```
qm.toml                          one mod at the repository's root
mods/<id>/qm.toml
<Mod name>/<version>/qm.toml
```

The mod's id comes from the `mod.json` in the same folder.

### 3. Publish a release

Create a GitHub release and attach the mod archive: a `.zip` holding the mod folder with its `mod.json` (what `qm pack` builds), or a `.qmpack` exported from the launcher, which can hold several mods.

Only the **latest** release is listed. The index checks that the archive holds a `mod.json` with the same id as the folder that published it, and records the archive's SHA-256. The launcher refuses a download whose hash doesn't match, so never replace a release's files after publishing. Make a new release instead.

### What the site checks

Every release of every listed mod is checked, whether the mod was registered or found by its topic. A registration pull request gets the same checks, and a comment that says which it failed.

**The pull request.** It changes exactly one file, `registry/<owner>.toml` (or `registry/<owner>-<name>.toml`), which lists only repositories of that owner. It may add the file or add repositories to it. The repositories must be public, not archived, and not registered already.

**The mod's id.** An id belongs to the first repository that lists it and stays there, so nobody else can publish a mod under your id. Choose an id nobody uses.

**The archive.** It is read, never run. These are refused, and the pull request says where each was found:

| Refused | Why |
|---|---|
| Program files and native libraries (`.exe`, `.dll`, `.so` and the like, whatever they are named) | Their contents can't be checked. |
| Compiled Lua | It can't be read. Ship the source. |
| Paths that leave the mod's folder, links, zip bombs | Nothing honest needs them. |
| Code that is downloaded and then run | |
| Code hidden by encoding it: long lists of character codes, escaped text, decoded text passed to `loadstring` | |
| Windows command-line tools, and places where passwords, keys or browser data are kept | |

These are held for the site's owner, who decides whether the mod may be listed with them:

| Held | |
|---|---|
| Running programs, native code | The two capabilities QuarterMaster rates High ([the security scan](#the-security-scan)). Say in the pull request what the mod uses them for. |
| System functions reached indirectly (`getfenv`, `os[...]`, `debug.sethook`) | The capability scan can't follow them. |
| Reading where the user's files are (`os.getenv("APPDATA")` and the like) | |
| Network use and run-time code loading in the same file | Code could arrive over the network. |
| Packed code (a line over 4,000 characters, long encoded blocks), scripts the game doesn't use (`.bat`, `.py`), archives inside the archive | |
| A pull request from an account under a week old, or from someone other than the repositories' owner | A public member of the owning organization counts as the owner. |

Network access, raw file access and run-time code loading on their own are not held. They are shown on the mod's page under "Can do".

**Later releases.** A release that is refused or held is not listed. The version listed before it stays until the new one is cleared, and its page says a newer release is being checked.

`qm lint` shows the capability findings before you publish.

### Several mods in one repository

Give each mod its own folder with a `mod.json` and a `qm.toml` containing `[publish]`. They can share one archive (a `.qmpack`, or a `.zip` with each mod in its own folder) or have one file each, chosen with `asset`.

### The mod's page

Each listed mod gets a card in the site's mod list and a page showing its picture (the `image` above, when it has one), its README (`README.md` in the mod's folder, or else the repository's root `README.md`), the latest release's notes as its changelog, and the `requires` and `conflicts` from its `mod.json`. Scripts, frames, styles and plain `http` links are removed from the README. Relative links and images point at your repository's files.

### Removal

A mod that breaks the rules or harms players is removed by adding its repository to the site's denylist. To take your own mod off the list, remove its `[publish]` table or the topic; for a registered repository, open a pull request that removes it from your file. Copies already installed stay on players' machines.

---

# Quick reference

## Patch keys

| Key | Pattern | Regex | Copy | Module |
|---|---|---|---|---|
| `id` | yes | yes | yes | yes |
| `name`, `description` | yes | yes | `name` | |
| `target` | yes | yes | yes | |
| `pattern`, `payload`, `position` | yes | yes | `payload`, `position` | |
| `times` / `expect` | yes | yes | | |
| `match_indent` | yes | | | |
| `root_capture`, `line_prepend`, `verbose` | | yes | | |
| `sources` | | | yes | |
| `source`, `name` (to require), `before` (file), `load_now` | | | | yes |
| `priority`, `on_failure` | yes | yes | yes | yes |
| `before`, `after` (patch order) | yes | yes | yes | |
| `requires`, `anchors`, `sites`, `stack` | yes | yes | | |
| `apply_as` | yes | | | |

## Positions

| Patch type | Values |
|---|---|
| Pattern, regex | `"before"`, `"after"`, `"at"` |
| Copy | `"prepend"`, `"append"` |

## config.toml tables

| Table | Required keys | Optional keys |
|---|---|---|
| top level | | `name` |
| `[[options]]` | `id`, `label` | `type`, `default`, `description`, `options`, `labels`, `button_text`, `on_click`, `show_if`, `aliases` |
| `[[keybinds]]` | `id`, `name`, `default` | `category`, `tab`, `modifiers`, `secondary`, `description`, `on_trigger` |
| `[[modes]]` | `id`, `title` | `subtitle`, `description`, `icon`, `priority`, `on_click` |
| `[[pages]]` | `id`, `title` | `content`, `action_label`, `action_on_click` |

## Where things are stored

| What | Where |
|---|---|
| Mod settings | `saveModSettings.lua` in the game's save folder; in Lua, `QM.settings.<mod_id>.<option_id>` |
| Keybinds | `saveKeybinds.lua` in the game's save folder |
| The game save | `saveMNB3.lua` (with `backUp.lua`), loaded into `player` |
| Logs, dumps, crash reports | `Mods/qm/` |

## Ids to keep unique

These names are shared by every mod, so start each with your mod id:

- patch ids (`example_mod:name`)
- keybind ids (`example_mod_ping`)
- `[vars]` names
- button labels, and so their `<label>Button` functions
- global variables and fields you add to `player` or to soldiers
- files you write with `love.filesystem`
