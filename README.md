Nimrod argument parser
======================

[Nimrod](http://nimrod-code.org) provides the [parseopt
module](http://nimrod-code.org/parseopt.html) to parse options from
the commandline. I found this module lacking, used to python modules
like [optparse](http://docs.python.org/2/library/optparse.html) or
[argparse](http://docs.python.org/3/library/argparse.html).  This
module tries to provide similar functionality to prevent you from
writing commandline parsing and let you concentrate on providing
the best possible experience for your users.


License
=======

[MIT license](LICENSE.md).


Installation and usage
======================

To get the source code you can likely use [Nimrod's babel package
manager](https://github.com/nimrod-code/babel) and type:

    babel install argument_parser

If you don't have babel you can simply download the argument_parser.nim
file and add it to your program. All other files in this repository
are accessory and can be ignored for normal usage. Once you have
the source you can just ``import argument_parser`` and use its
contents. Use [nimrod's configuration
files](http://nimrod-code.org/nimrodc.html#configuration-files)
feature to specify a path to where you install this module so you
don't have to copy it around.


Documentation
=============

The argument_parser module comes with embedded docstrings. You can
run ``nimrod doc2 argument_parser.nim`` and obtain a reference html
file with instructions on the exported symbols.  If you installed
through babel, you can find this in a path similar to
``~/.babel/libs/argument_parser-version``.

In the distant future, when most features are complete, a tutorial
will be provided to explain how to use the module. In the meantime
you should read the examples provided in the [examples
subdirectory](examples). These examples try to show how to implement
common usage patterns for different types of commandline parsing.


Roadmap
=======

The last stable version is 0.1.0. Note that the default *master*
branch from the github repo is for development, though I try not
to break too much stuff. I don't have much of a roadmap myself, but
I use [github's issue
tracker](http://github.com/gradha/argument_parser/issues) to keep
reminders of what has to be done. Feel free to add your comments
to existing issues or create new ones.


Feedback
========

You can send me feedback through [github's issue
tracker](http://github.com/gradha/argument_parser/issues). I also
take a look from time to time to [Nimrod's
forums](http://forum.nimrod-code.org) where you can talk to other
nimrod programmers.
