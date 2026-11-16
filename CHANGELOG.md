# Site changelog

What changed on the QuarterMaster site.

## 1.2.2

- the safety check reads a mod's text files as code whatever their extension, not only `.lua` and `.toml`
- patches written in the short form (`[[pattern]]`, `[[module]]`, ...) are read like the long form

## 1.2.1

- a mod whose id is not plain lowercase letters, digits, `_` or `-` is not listed

## 1.2.0

- a mod id stays with the repository that listed it first, so nobody else can publish under it
- every release of every listed mod goes through a safety check before it appears
- a release that does not pass is not listed; the version before it stays, with a note on its page
- one registration file can list several repositories
- registration pull requests are reviewed automatically, and merged when every check passes
- mod pages show what the mod can do

## 1.1.0

- the modding wiki: a page per part, a sidebar, coloured code, and the whole wiki on one page
- search over the wiki and the mods
- QuarterMaster's changelog
- the editor schemas, at fixed addresses
- the mod list is cards; a card shows the picture the mod's author chose
- wider pages
- the download button goes to QuarterMaster's releases
- the site checks for new mod releases every 15 minutes
- the updates page is gone; the feed (`updates.xml`) stays

## 1.0.0

- the mod list, a page per mod, and the mod index QuarterMaster's Browse tab reads
- registration by pull request; discovery by the `quartermaster-mod` topic