## Register mods

This pull request adds one file, `registry/<owner>.toml`, or adds a repository to it. It changes nothing else.

Before opening it:

- [ ] Each mod's `qm.toml` has a `[publish]` table whose `repository` is the repository it is in.
- [ ] Each mod folder has a `mod.json` with the mod's id, and no other listed mod uses that id.
- [ ] The latest release has the mod archive (`.zip` or `.qmpack`) attached, and the archive holds that `mod.json`.
- [ ] The archive holds no program files, and its Lua is readable source.

If a mod runs programs or loads native code, say here what for:

The review runs on its own and comments with the result. When every check passes, the pull request is merged automatically. The rules are at https://gamiseus.github.io/publish/.
