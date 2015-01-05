======================
Argument parser readme
======================

The `Nim programming language <http://nim-lang.org>`_ provides the `parseopt
module <http://nim-lang.org/parseopt.html>`_ to parse options from the command
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

Install the `Nim <http://nim-lang.org>`_ compiler.  Use `Nim's Nimble package
manager <https://github.com/nim-lang/nimble>`_ to install the module::

    $ nimble update
    $ nimble install argument_parser


Development version
-------------------

Install the `Nim <http://nim-lang.org>`_ compiler.  Use `Nim's Nimble package
manager <https://github.com/nim-lang/nimble>`_ to install locally the github
checkout::

    $ git clone https://github.com/gradha/argument_parser.git
    $ cd argument_parser
    $ nimble install -y

If you don't mind downloading the git repository every time, you can also tell
Nimble to install the latest development version directly from git::

    $ nimble update
    $ nimble install -y argument_parser@#head


Documentation
=============

Once you have installed ``argument_parser`` you can just ``import
argument_parser`` in your programs and use its API.  The ``argument_parser``
module comes with embedded docstrings. You can run ``nake doc`` to generate the
HTML along with other documents, which are referenced from the `generated
theindex.html <theindex.html>`_ file.  Here is an example on how to build the
HTML on Unix::

    $ cd `nimble path argument_parser`
    $ nake doc
    $ open theindex.html

The generated documentation for all public versions can also be found at
`http://gradha.github.io/argument_parser/
<http://gradha.github.io/argument_parser/>`_.  No guarantees on its freshness,
though, do check the generation date at the bottom.

In the distant future, when most features are complete, a tutorial will be
provided to explain how to use the module. In the meantime you should read the
examples provided in the `examples subdirectory <examples>`_. These examples
try to show how to implement common usage patterns for different types of
command line parsing.


Changes
=======

This is stable version 0.4.0. For a list of changes see the `docs/changes.rst
<docs/changes.rst>`_ file.


Git branches
============

This project uses the `git-flow branching model
<https://github.com/nvie/gitflow>`_ with reversed defaults. Stable releases are
tracked in the `stable branch
<https://github.com/gradha/argument_parser/tree/stable>`_. Development happens
in the default `master branch
<https://github.com/gradha/argument_parser/tree/stable>`_.


Feedback
========

You can send me feedback through `github's issue tracker
<http://github.com/gradha/argument_parser/issues>`_. I also take a look from
time to time to `Nim's forums <http://forum.nim-lang.org>`_ where you can talk
to other Nim programmers.
