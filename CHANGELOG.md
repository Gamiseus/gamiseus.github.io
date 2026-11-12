# Site changelog

Changes to the site and to `qm-site-builder`, which builds it. Not published on the site. Versions are the builder's.

## 1.2.0

- a mod id stays with the repository that listed it first (`api/v1/owners.json`); before, the first repository by name took it
- `registry/ids.toml` assigns an id by hand
- safety scan of every archive, on every build: program files, bytecode, obfuscation and the like are rejected; High-rated capabilities and suspicious code are held
- a held release leaves the version before it listed; an issue is opened for each held release
- `allow` in a registry file accepts findings for a repository
- a registry file can list several repositories (`repositories = [...]`), one file per owner
- registration pull requests are reviewed automatically: merged, held for the owner, or rejected with what to fix
- limits: 10 repositories per file, 3 open registrations per author, 20 automatic merges a day
- mod pages show what the mod can do
- builder: `review-registration`, `scan`, `--owners`, `--previous-index`, `--report`
- `Gamiseus/MnB-Mods` is allowed `native_ffi` (PerfKit's timer)

## 1.1.0

- the modding wiki is published as `wiki/`: a page per part, a sidebar, coloured code, a one-page view
- `search/` searches the wiki and the mods
- `changelog/` shows QuarterMaster's changelog, versions only
- `schemas/` holds the editor schemas
- the mod list is cards; a card shows the picture named by `image` in the mod's `[publish]` table
- an empty mod list says "Nothing here yet."
- `publish/` forwards to the wiki's publishing part; the separate author guide is gone
- the updates page is gone; `updates.xml` stays
- wider pages
- the download button goes to the QuarterMaster repository's releases
- added `404.html`, `sitemap.xml` and a root `robots.txt`
- the stylesheet, script, font and logo are built into the builder; `static/` only overrides them
- builder: `--wiki`, `--changelog`, `--schemas`; a wiki link that goes nowhere stops the build
- the builder is named `qm-site-builder` (was `qm-index-builder`); its release moves to `Gamiseus/QuarterMaster`
- registered `Gamiseus/MnB-Mods`
- the build is scheduled every 15 minutes instead of hourly: GitHub ran the hourly one about once in twelve hours
- a scheduled build that changes nothing is not deployed (`build-hash.txt`, `.github/site-hash.ps1`)
- workflows use the current GitHub actions (Node 24)

## 1.0.0

- the mod index (`api/v1/index.json`), mod list, mod pages, updates page and feed
- registration by pull request, with a check; discovery by the `quartermaster-mod` topic
