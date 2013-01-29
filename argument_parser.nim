import os, strutils, tables, math

# - Types

type
  Tparameter_specification* = object
    ## Holds the expectations of a parameter.
    single_word: string
    double_word: string
    consumes: bool

  Tcommandline_results* = object
    ## Contains the results of the parsing.
    files*: seq[string]
    options*: TTable[string, string]


# - Tparameter_specification procs

proc init*(param: var Tparameter_specification,
    single_word = "", double_word = "", consumes = false) =
  # Initialization helper.
  param.single_word = single_word
  param.double_word = double_word
  param.consumes = consumes

proc new_parameter_specification*(single_word = "",
    double_word = "", consumes = false): Tparameter_specification =
  # Initialization helper for let variables.
  result.init(single_word, double_word, consumes)

# - Tcommandline_results procs

proc init*(param: var Tcommandline_results; files: seq[string] = @[];
    options: TTable[string, string] = initTable[string, string](4)) =
  # Initialization helper.
  param.files = files
  param.options = options

proc `$`*(data: Tcommandline_results): string =
  # Stringifies a Tcommandline_results structure for debug output
  var dict: seq[string] = @[]
  for key, value in data.options:
    dict.add("$1: $2" % [key.escape(), value.escape()])
  result = "Tcommandline_result{files:[$1], options:{$2}}" % [join(
    map(data.files) do (x: string) -> string: x.escape(), ", "),
    join(dict, ", ")]

# - Parse code

proc parse*(expected: seq[Tparameter_specification],
    args: seq[TaintedString] = nil): Tcommandline_results =
  result.init()
  # Prepare the input parameter list, maybe get it from the OS if not available.
  var args = args
  if args == nil:
    let total_params = ParamCount()
    echo "Got no explicit args, retrieving from OS. Count: ", total_params
    newSeq(args, total_params)
    for i in 0..total_params - 1:
      echo ($i)
      args[i] = paramStr(i + 1)

  # Generate lookup table for each type of parameter based on strings.
  var lookup = initTable[string, Tparameter_specification](
    nextPowerOfTwo(expected.len))
  for i in 0..expected.len-1:
    let
      parameter_specification = expected[i]
      single_switch = "-" & parameter_specification.single_word
      double_switch = "--" & parameter_specification.double_word
    if single_switch.len > 1:
      if lookup.hasKey(single_switch):
        quit("Parameter $1 repeated in input specification" % single_switch)
      else:
        lookup[single_switch] = parameter_specification
    if double_switch.len > 2:
      if lookup.hasKey(double_switch):
        quit("Parameter $1 repeated in input specification" % double_switch)
      else:
        lookup[double_switch] = parameter_specification

  # Loop through the input arguments detecting their type and doing stuff.
  var i = 0
  while i < args.len:
    let arg = args[i]
    #echo "Arg ", $i, " value '", arg, "'"
    if arg.len > 0:
      if lookup.hasKey(arg):
        let param = lookup[arg]
        var next = ""
        if param.consumes:
          if i + 1 < args.len:
            i += 1
            next = args[i]
          else:
            quit("Parameter $1 requires value" % arg)
        #echo "\tFound ", arg, " ", next
        result.options[arg] = next
      else:
        if arg[0] == '-':
          quit("Found unexpected parameter $1" % arg)
        else:
          #echo "Normal parameter"
          result.files.add(arg)
    else:
      #echo "\tEmpty file parameter?"
      result.files.add(arg)
    i += 1

when isMainModule:
  echo "Welcome to argument_parser!"
  parse()
