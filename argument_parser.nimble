[Package]
name          = "argument_parser"
version       = "0.4.3"
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

https://github.com/Xe/badger_bits.git >= 0.2.2
nake >= 1.4
nim >= 0.10.2

"""
