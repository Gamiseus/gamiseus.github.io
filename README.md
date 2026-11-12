# gamiseus.github.io

The source of the [QuarterMaster site](https://gamiseus.github.io/): the mod list, the modding wiki, and the mod index that QuarterMaster's Browse tab reads.

QuarterMaster is a mod manager for *Mud and Blood*. The site is where players find mods and where mod authors learn to make and publish them.

| | |
|---|---|
| [Mods](https://gamiseus.github.io/mods/) | Every listed mod, with its version, changes and readme. |
| [Modding wiki](https://gamiseus.github.io/wiki/) | How to make a mod, from replacing a sound to patching game code. |
| [Changelog](https://gamiseus.github.io/changelog/) | What changed in each version of QuarterMaster. |
| [Download](https://github.com/Gamiseus/QuarterMaster/releases) | QuarterMaster itself. |

## Listing your mod

A mod is listed when its repository can be found, its `qm.toml` has a `[publish]` table, and it has a release with the mod archive attached. The wiki has the steps: [Listing a mod](https://gamiseus.github.io/publish/).

To register a repository, open a pull request here that adds one file, `registry/<your-account>.toml`:

```toml
repository = "your-name/your-repo"
```

The pull request is reviewed automatically. It comments with the result, and when every check passes it is merged for you. [`registry/README.md`](registry/README.md) has the file's format, including how to list several repositories.

## How mods are checked

Every release of every listed mod is checked before it appears: that it comes from the repository that owns the mod's id, that its archive holds the mod, and that the archive passes a safety check. The wiki lists [what is checked](https://gamiseus.github.io/wiki/packaging-and-publishing/#what-the-site-checks).

QuarterMaster verifies each download against the hash recorded here, so players get the archive that was checked.

## Reporting a problem

Open an issue here for a mod that should not be listed, a mistake in the wiki, or a problem with the site.
