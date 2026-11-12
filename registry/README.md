# Registry

Each `.toml` file here lists one owner's repositories whose mods appear on the site and in QuarterMaster's Browse tab.

```toml
# One repository:
repository = "owner/name"

# or several (up to ten):
repositories = ["owner/name", "owner/another"]

contact = "optional: how to reach you"
```

Name the file after the repositories' owner: `<owner>.toml` (or `<owner>-<name>.toml`). One file lists one owner's repositories only.

## Registering

Open a pull request that adds your file, or adds a repository to it. It must change that one file and nothing else. It is reviewed automatically:

- **Accepted:** it is merged for you and the mods are listed within the hour.
- **Waiting:** something needs the site owner's decision. There is nothing for you to do unless the comment says so.
- **Cannot be accepted yet:** the comment lists what to fix. Push to the same pull request and it is reviewed again.

Each repository still needs a `qm.toml` with a `[publish]` table naming it, and a release with the mod archive attached. Every release goes through the safety check. The steps and the checks are in the wiki: https://gamiseus.github.io/publish/.

A registration file holds only `repository` or `repositories`, and `contact`.
