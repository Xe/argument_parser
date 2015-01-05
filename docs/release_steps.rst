=============================
Argument parser release steps
=============================

These are the steps to be performed for new stable releases of `argument_parser
<https://github.com/gradha/argument_parser>`_. See the `README
<../README.rst>`_.

* Run ``nake test`` to verify at least basic stuff works.
* Create new milestone with version number (``vXXX``) at
  https://github.com/gradha/argument_parser/milestones.
* Create new dummy issue `Release versionname` and assign to that milestone.
* ``git flow release start versionname`` (``versionname`` without ``v``).
* Update version numbers:

  * Modify `../README.rst <../README.rst>`_.
  * Modify `../argument_parser.nim <../argument_parser.nim>`_.
  * Modify `../argument_parser.nimble <../argument_parser.nimble>`_.
  * Modify `changes.rst <changes.rst>`_ with list of changes and
    version/number.

* ``git commit -av`` into the release branch the version number changes.
* ``git flow release finish versionname`` (the ``tagname`` is ``versionname``
  without ``v``). When specifying the tag message, copy and paste a text
  version of the changes log into the message. Add ``*`` item markers.
* Move closed issues without milestone to the release milestone.
* Build doc binary with ``nake dist_doc``.
* ``git push origin master stable --tags``.
* Attach the binaries to the appropriate release at
  `https://github.com/gradha/argument_parser/releases
  <https://github.com/gradha/argument_parser/releases>`_.

  * Use ``nake md5`` task to generate md5 values, add them to the release.
  * Follow the tag link of the release and create a hyper link to its changes
    log on (e.g.
    `https://github.com/gradha/argument_parser/blob/v0.2.0/docs/changes.rst
    <https://github.com/gradha/argument_parser/blob/v0.2.0/docs/changes.rst>`_).

* Store binaries in local archive.
* Increase version numbers, ``master`` branch gets +0.0.1:

  * Modify `../README.rst <../README.rst>`_.
  * Modify `../argument_parser.nim <../argument_parser.nim>`_.
  * Modify `../argument_parser.nimble <../argument_parser.nimble>`_.
  * Add to `changes.rst <changes.rst>`_ development version with unknown date.

* ``git commit -av`` into ``master`` with `Bumps version numbers for
  development. Refs #release issue`.
* Regenerate static website.

  * Make sure git doesn't show changes, then run ``nake web`` and review.
  * ``git add . && git commit``. Tag with `Regenerates website. Refs
    #release_issue`.
  * ``./nakefile postweb`` to return to the previous branch. This also updates
    submodules, so it is easier.

* ``git push origin master stable gh-pages --tags``.
* Close the dummy release issue.
* Close the milestone on github.
* Announce at `http://forum.nim-lang.org/t/135
  <http://forum.nim-lang.org/t/135>`_.
