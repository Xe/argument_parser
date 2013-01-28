import os, strutils

# - Types

type
  Tparameter_specification* = object
    ## Holds the expectations of a parameter.
    single_letter: char
    single_word: string
    double_word: string
    consumes: bool

  Tcommandline_results* = object
    ## Contains the results of the parsing.
    files: seq[string]


# - Tparameter_specification procs

proc init*(param: var Tparameter_specification, single_letter = ' ',
    single_word = "", double_word = "", consumes = false) =
  # Initialization helper.
  param.single_letter = single_letter
  param.single_word = single_word
  param.double_word = double_word
  param.consumes = consumes

proc new_parameter_specification*(single_letter = ' ', single_word = "",
    double_word = "", consumes = false): Tparameter_specification =
  # Initialization helper for let variables.
  result.init(single_letter, single_word, double_word, consumes)

# - Tcommandline_results procs

proc init*(param: var Tcommandline_results; files: seq[string] = @[]) =
  # Initialization helper.
  param.files = files

proc new_commandline_results*(files: seq[string]): Tcommandline_results =
  # Initialization helper for let variables.
  result.init(files)

proc `$`*(data: Tcommandline_results): string =
  # Stringifies a Tcommandline_results structure for debug output
  return "Tcommandline_result{files:$1}" % [join(
    map(data.files) do (x: string) -> string: x.escape(), ", ")]

proc parse*(expected: seq[Tparameter_specification],
    args: seq[TaintedString] = nil): Tcommandline_results =
  result.init()
  var args = args
  if args == nil:
    let total_params = ParamCount()
    echo "Got no explicit args, retrieving from OS. Count: ", total_params
    newSeq(args, total_params)
    for i in 0..total_params - 1:
      echo ($i)
      args[i] = paramStr(i + 1)

  for index, arg in args:
    echo "Arg ", $index, " value '", arg, "'"
    if arg.len > 0:
      if arg[0] == '-':
        if arg.len > 1:
          if arg[1] == '-':
            if arg.len > 3:
              echo "\tDouble dash word parameter"
            else:
              echo "\tDouble dash letter parameter? broken"
          else:
            if arg.len > 2:
              echo "\tSingle dash word parameter"
            else:
              echo "\tSingle dash letter parameter"
        else:
          echo "Single dash parameter, stdin/stdout?"
      else:
        echo "Normal parameter"
    else:
      echo "\tEmpty file parameter?"

when isMainModule:
  echo "Welcome to argument_parser!"
  parse()
