======================
Nimrod argument parser
======================

`Nimrod <http://nimrod-code.org>`_ provides the `parseopt module
<http://nimrod-code.org/parseopt.html>`_ to parse options from the command
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


Installation and usage
======================

To get the source code you can likely use `Nimrod's babel package manager
<https://github.com/nimrod-code/babel>`_ and type::

    babel install argument_parser

If you don't have babel you can simply download the argument_parser.nim file
and add it to your program. All other files in this repository are accessory
and can be ignored for normal usage. Once you have the source you can just
``import argument_parser`` and use its contents. Use `nimrod's configuration
files <http://nimrod-code.org/nimrodc.html#configuration-files>`_ feature to
specify a path to where you install this module so you don't have to copy it
around.


Documentation
=============

The argument_parser module comes with embedded docstrings. You can run ``nimrod
doc2 argument_parser.nim`` and obtain a reference html file with instructions
on the exported symbols.  If you installed through babel, you can find this in
a path similar to ``~/.babel/libs/argument_parser-version``.

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

The last version is 0.3.0. For a list of changes see the `docs/changes.rst
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
time to time to `Nimrod's forums <http://forum.nimrod-code.org>`_ where you can
talk to other nimrod programmers.
