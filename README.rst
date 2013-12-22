======================
Nimrod argument parser
======================

`Nimrod <http://nimrod-lang.org>`_ provides the `parseopt module
<http://nimrod-lang.org/parseopt.html>`_ to parse options from the command
line. I found this module lacking, used to python modules like `optparse
<http://docs.python.org/2/library/optparse.html>`_ or `argparse
<http://docs.python.org/3/library/argparse.html>`_.  This module tries to
provide similar functionality to prevent you from writing command line parsing
and let you concentrate on providing the best possible experience for your
users.

An alternative to this module is the `commandeer
<https://github.com/fenekku/commandeer>`_ module.


License
=======

`MIT license <LICENSE.rst>`_.


Installation
============

Stable version
--------------

Install the `Nimrod <http://nimrod-lang.org>`_ compiler.  Use `Nimrod's babel
package manager <https://github.com/nimrod-code/babel>`_ to install the
module::

    $ babel update
    $ babel install argument_parser

Development version
-------------------

Install the `Nimrod <http://nimrod-lang.org>`_ compiler.  Use `Nimrod's babel
package manager <https://github.com/nimrod-code/babel>`_ to install locally the
github checkout::

    $ git clone https://github.com/gradha/argument_parser.git
    $ cd argument_parser
    $ git checkout develop
    $ babel install


Documentation
=============

Once you have installed ``argument_parser`` you can just ``import
argument_parser`` in your programs and use its API.  The ``argument_parser``
module comes with embedded docstrings. You can run ``nake doc`` to generate the
HTML along with other documents, which are referenced from the `docindex file
<docindex.rst>`_. Here is an example on how to build the HTML on Unix::

    $ cd `babel path argument_parser`
    $ nake doc
    $ open docindex.html

The generated documentation for all public versions can also be found at
`http://gradha.github.io/argument_parser/
<http://gradha.github.io/argument_parser/>`_.  No guarantees on its freshness,
though, do check the generation date at the bottom.

In the distant future, when most features are complete, a tutorial will be
provided to explain how to use the module. In the meantime you should read the
examples provided in the `examples subdirectory <examples>`_. These examples
try to show how to implement common usage patterns for different types of
command line parsing. The examples are also converted to HTML and referenced
from the `docindex file <docindex.rst>`_ for convenience.


Changes
=======

This is version is 0.2.0. For a list of changes see the `docs/changes.rst
<docs/changes.rst>`_ file.


Git branches
============

This project uses the `git-flow branching model
<https://github.com/nvie/gitflow>`_. Which means the ``master`` default branch
doesn't *see* much movement, development happens in another branch like
``develop``. Most people will be fine using the ``master`` branch, but if you
want to contribute something please check out first the ``develop`` branch and
do pull requests against that.


Feedback
========

You can send me feedback through `github's issue tracker
<http://github.com/gradha/argument_parser/issues>`_. I also take a look from
time to time to `Nimrod's forums <http://forum.nimrod-lang.org>`_ where you can
talk to other nimrod programmers.
