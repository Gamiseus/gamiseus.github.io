# Registry

Each `.toml` file here lists one repository whose mods appear on the site and in QuarterMaster's Browse tab, even without the `quartermaster-mod` topic.

```toml
repository = "owner/name"
contact = "optional: how to reach you"
```

Name the file `<owner>-<name>.toml`. A pull request that adds or changes a file here runs a check that says whether the repository can be listed and, if not, what to fix.

Registration does not skip the rules: the repository still needs a `qm.toml` with a `[publish]` table naming it, and a release with the mod archive attached. See https://gamiseus.github.io/publish/.

`denylist.txt` holds repositories that are never listed.
