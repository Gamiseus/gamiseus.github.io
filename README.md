# gamiseus.github.io

The QuarterMaster site: the mod list, the modding wiki and the mod index that QuarterMaster's Browse tab reads (`https://gamiseus.github.io/api/v1/index.json`).

Nothing here is a web page. The pages are built by a workflow and deployed straight to GitHub Pages, so generated files are never committed.

## What is in this repository

| Path | What it is |
|---|---|
| `registry/*.toml` | Registered mod repositories, one per file: `repository = "owner/name"`. |
| `registry/denylist.txt` | Repositories that are never listed. |
| `content/wiki.md` | The modding wiki. A copy: edit `docs/QUARTERMASTER_MODDING_WIKI.md` in the QuarterMaster workspace instead. |
| `content/changelog.md` | QuarterMaster's changelog. A copy of `Quartermaster/CHANGELOG.md`. |
| `content/schemas/` | The editor schemas. Copies of `Quartermaster/schemas/`. |
| `static/` | Optional. A file here replaces the builder's own file of the same name (`site.css`, `site.js`, `logo.png`, `stencil.woff2`). |
| `.github/workflows/` | The build, the registration check, and a reminder that keeps the hourly build alive. |
| `CHANGELOG.md` | Changes to the site itself. Not published. |

## What the site holds

| Address | Content |
|---|---|
| `/` | What QuarterMaster is, the download link, the latest mod releases. |
| `/mods/`, `/mods/<id>/` | A card per mod, and a page per mod with its README, version and release notes. |
| `/wiki/`, `/wiki/<part>/`, `/wiki/all/` | The modding wiki: a page per part, and all of it on one page. |
| `/search/` | Search over the wiki and the mods. |
| `/changelog/` | QuarterMaster's changelog. |
| `/schemas/` | The editor schemas, at fixed addresses. |
| `/publish/` | Forwards to the wiki's steps for listing a mod. |
| `/api/v1/index.json` | The index the launcher reads. |
| `/updates.xml` | An Atom feed of mod releases. |

## How it is built

`.github/workflows/build.yml` runs every hour, on every push to `main`, and by hand. It runs a pinned release of `qm-site-builder` (source: `tools/qm-site-builder` in the QuarterMaster repository), which:

1. finds candidate repositories: those with the `quartermaster-mod` topic, and those in `registry/`;
2. skips any in `registry/denylist.txt`;
3. keeps each mod whose `qm.toml` has a `[publish]` table naming the repository exactly, so forks and mirrors are not listed by accident;
4. downloads the latest release's archive, checks that it holds that mod's `mod.json`, and records its SHA-256 and size (QuarterMaster checks the hash before installing);
5. copies the mod's card picture, when its `[publish]` table names one;
6. renders each mod's README (sanitized: no scripts, frames or styles) and the wiki, and writes every page.

A wiki link that goes nowhere stops the build, so a broken wiki is never published.

## Updating the wiki, the changelog or the schemas

In the QuarterMaster workspace:

```powershell
Quartermaster\tools\sync-site.ps1
```

It copies whatever changed into `content/`. Commit and push this repository to publish it. `Quartermaster\check.ps1` fails while the copies are out of date.

## Accepting a mod

A registration is a pull request adding `registry/<owner>-<name>.toml`. The "Check registration" workflow writes a pass or fail summary with what to fix. Merge it once it passes; the next build lists the mod.

A repository with the topic needs no pull request. It appears as "Discovered" rather than "Registered".

## Removing a mod

Add `owner/name` to `registry/denylist.txt` with a comment saying why, and delete its registry file if it has one. The next build drops it. QuarterMaster keeps installed copies; it only stops offering the mod.

## Updating the builder

The pages' layout, styles and script are inside the builder, so a change to them needs a new builder.

1. In the QuarterMaster workspace: `cargo build --release -p qm-site-builder`.
2. Publish `target\release\qm-site-builder.exe` in a release of `Gamiseus/QuarterMaster` tagged like `qm-site-builder-v1.1.0`. Mark it as a pre-release, so it never becomes the repository's latest release.
3. Get its hash: `(Get-FileHash target\release\qm-site-builder.exe -Algorithm SHA256).Hash.ToLower()`.
4. Set `BUILDER_TAG` and `BUILDER_SHA256` in `build.yml` and `check-registration.yml`, in one commit.

For a quick style change without a new builder, put a changed copy of `site.css` in `static/`.

## Previewing locally

In the QuarterMaster workspace, with a folder of recorded fixtures instead of GitHub:

```powershell
cargo run -p qm-site-builder -- build --fixtures <fixture folder> --registry <site>\registry --wiki ..\docs\QUARTERMASTER_MODDING_WIKI.md --changelog CHANGELOG.md --schemas schemas --out target\site-preview
```

Then serve `target\site-preview` with any static file server (the search page needs one; the other pages also open from disk). Without `--fixtures` the builder reads GitHub, using `GITHUB_TOKEN` if set.

## One-time setup

1. The repository must be named exactly `gamiseus.github.io`.
2. Settings, Pages: set the source to "GitHub Actions".
3. Publish the builder release and fill in `BUILDER_SHA256` (see "Updating the builder").
4. Run the "Build site" workflow once and open `https://gamiseus.github.io/api/v1/index.json`.
