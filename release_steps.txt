What to do for a new public release?
====================================

* Check if the future const verison number of the module matches public number,
  if it doesn't update the module const version number to new release.
* Create new milestone with version number.
* Create new dummy issue "Release versionname" and assign to that milestone.
* Move closed issues from "future milestone" to the release milestone.
* Update CHANGES.md with list of changes and version/number.
* Update README.md to indicate latest version.
* Tag source tree with the versionname.
* Push all.
* Close the dummy release issue.
* Increase version const number in main module, at least maintenance.
* Bump version number in babel for next release.
* Check out gh-pages branch and run update script.
* Add to the index.html the link of the new version along with files.
* Push docs.
* Announce at http://forum.nimrod-code.org/t/135.
