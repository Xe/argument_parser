====================================
What to do for a new public release?
====================================

* Create new milestone with version number.
* Create new dummy issue `Release versionname` and assign to that milestone.
* git flow release start versionname (versionname without v).
* Update version numbers:

  * Modify `../README.rst <../README.rst>`_.
  * Modify `../argument_parser.nim <../argument_parser.nim>`_.
  * Modify `../argument_parser.babel <../argument_parser.babel>`_.
  * Update `changes.rst <changes.rst>`_ with list of changes and
    version/number.

* ``git commit -av`` into the release branch the version number changes.
* git flow release finish versionname (the tagname is versionname without v).
* Move closed issues without milestone to the release milestone.
* Push all to git: ``git push origin master develop --tags``.
* Run ``nake dist_doc`` to generate zip package and attach to
  `https://github.com/gradha/argument_parser/releases
  <https://github.com/gradha/argument_parser/releases>`_.
* Increase version numbers, at least maintenance (stable version + 0.1.1):

  * Modify `../README.rst <../README.rst>`_.
  * Modify `../argument_parser.nim <../argument_parser.nim>`_.
  * Modify `../argument_parser.babel <../argument_parser.babel>`_.
  * Add to `changes.rst <changes.rst>`_ development version with unknown date.

* ``git commit -av`` into develop with `Bumps version numbers for develop
  branch. Refs #release issue`.
* Close the dummy release issue.
* Check out gh-pages branch and run update script.
* Add to the index.html the link of the new version along with files.
* Push docs branch.
* Announce at `http://forum.nimrod-code.org/t/135
  <http://forum.nimrod-code.org/t/135>`_.
