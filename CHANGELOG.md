# Site changelog

Changes to the site and to `qm-site-builder`, which builds it. Not published on the site. Versions are the builder's.

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
