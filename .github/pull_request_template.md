## Register a repository

- Repository: `owner/name`
- File added: `registry/<owner>-<name>.toml`

Before opening this pull request:

- [ ] Each mod's `qm.toml` has a `[publish]` table whose `repository` is this repository.
- [ ] Each mod folder has a `mod.json` with the mod's id.
- [ ] The latest release has the mod archive (`.zip` or `.qmpack`) attached, and the archive holds that `mod.json`.

The check on this pull request says whether the repository can be listed and what to fix if not. The rules are at https://gamiseus.github.io/publish/.
