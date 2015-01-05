[Package]
name          = "argument_parser"
version       = "0.4.0"
author        = "Grzegorz Adam Hankiewicz"
description   = """Provides a complex commandline parser."""
license       = "MIT"

installDirs = """

docs
examples

"""

InstallFiles = """

LICENSE.rst
README.rst
argument_parser.nim
nakefile.nim
nakefile.nimrod.cfg

"""

[Deps]
Requires: """

nake >= 1.4
https://github.com/gradha/badger_bits.git >= 0.2.2

"""
