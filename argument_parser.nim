import os, strutils, tables, math, parseutils

# - Types

type
  ## Different types of results for parameter parsing.
  Tparam_kind* = enum PK_EMPTY, PK_INT, PK_FLOAT, PK_STRING, PK_BOOL,
    PK_BIGGEST_INT, PK_BIGGEST_FLOAT

  Tparameter_specification* = object
    ## Holds the expectations of a parameter.
    single_word: string
    double_word: string
    consumes: Tparam_kind

  Tparsed_parameter* = object
    case kind*: Tparam_kind
    of PK_EMPTY: nil
    of PK_INT: int_val*: int
    of PK_BIGGEST_INT: big_int_val*: biggestInt
    of PK_FLOAT: float_val*: float
    of PK_BIGGEST_FLOAT: big_float_val: biggestFloat
    of PK_STRING: str_val*: string
    of PK_BOOL: bool_val*: bool

  Tcommandline_results* = object
    ## Contains the results of the parsing.
    files*: seq[string]
    options*: TTable[string, Tparsed_parameter]


# - Tparameter_specification procs

proc init*(param: var Tparameter_specification,
    single_word = "", double_word = "", consumes = PK_EMPTY) =
  # Initialization helper.
  param.single_word = single_word
  param.double_word = double_word
  param.consumes = consumes

proc new_parameter_specification*(single_word = "",
    double_word = "", consumes = PK_EMPTY): Tparameter_specification =
  # Initialization helper for let variables.
  result.init(single_word, double_word, consumes)

# - Tparsed_parameter procs

proc `$`*(data: Tparsed_parameter): string =
  # Stringifies the value.
  case data.kind:
  of PK_EMPTY: result = "nil"
  of PK_INT: result = $data.int_val
  of PK_BIGGEST_INT: result = $data.big_int_val
  of PK_FLOAT: result = $data.float_val
  of PK_BIGGEST_FLOAT: result = $data.big_float_val
  of PK_STRING: result = $data.str_val
  of PK_BOOL: result = $data.bool_val

# - Tcommandline_results procs

proc init*(param: var Tcommandline_results; files: seq[string] = @[];
    options: TTable[string, Tparsed_parameter] =
      initTable[string, Tparsed_parameter](4)) =
  # Initialization helper.
  param.files = files
  param.options = options

proc `$`*(data: Tcommandline_results): string =
  # Stringifies a Tcommandline_results structure for debug output
  var dict: seq[string] = @[]
  for key, value in data.options:
    dict.add("$1: $2" % [escape(key), escape($value)])
  result = "Tcommandline_result{files:[$1], options:{$2}}" % [join(
    map(data.files) do (x: string) -> string: x.escape(), ", "),
    join(dict, ", ")]

# - Parse code

proc parse_parameter(param, value: string,
    param_kind: Tparam_kind): Tparsed_parameter =
  ## Tries to parse a text according to the specified type.
  ##
  ## Pass the parameter string which requires a value and the text the user
  ## passed in for it. It will be parsed according to the param_kind. This proc
  ## will raise (EInvalidValue, EOverflow) if something can't be parsed.
  result.kind = param_kind
  case param_kind:
  of PK_INT:
    try: result.int_val = value.parseInt
    except EOverflow:
      raise newException(EOverflow, ("parameter $1 requires an " &
        "integer, but $2 is too large to fit into one") % [escape(param),
        escape(value)])
    except EInvalidValue:
      raise newException(EInvalidValue, ("parameter $1 requires an " &
        "integer, but $2 can't be parsed into one") % [escape(param),
        escape(value)])
  of PK_STRING:
    result.str_val = value
  of PK_FLOAT:
    try: result.float_val = value.parseFloat
    except EInvalidValue:
      raise newException(EInvalidValue, ("parameter $1 requires a " &
        "float, but $2 can't be parsed into one") % [escape(param),
        escape(value)])
  of PK_BOOL:
    try: result.bool_val = value.parseBool
    except EInvalidValue:
      raise newException(EInvalidValue, ("parameter $1 requires a " &
        "boolean, but $2 can't be parsed into one. Valid values are: " &
        "y, yes, true, 1, on, n, no, false, 0, off") % [escape(param),
        escape(value)])
  of PK_BIGGEST_INT:
    try:
      let parsed_len = parseBiggestInt(value, result.big_int_val)
      if value.len != parsed_len or parsed_len < 1:
        raise newException(EInvalidValue, ("parameter $1 requires an " &
          "integer, but $2 can't be parsed completely into one") % [
          escape(param), escape(value)])
    except EInvalidValue:
      raise newException(EInvalidValue, ("parameter $1 requires an " &
        "integer, but $2 can't be parsed into one") % [escape(param),
        escape(value)])
  of PK_BIGGEST_FLOAT:
    try:
      let parsed_len = parseBiggestFloat(value, result.big_float_val)
      if value.len != parsed_len or parsed_len < 1:
        raise newException(EInvalidValue, ("parameter $1 requires a " &
          "float, but $2 can't be parsed completely into one") % [
          escape(param), escape(value)])
    except EInvalidValue:
      raise newException(EInvalidValue, ("parameter $1 requires a " &
        "float, but $2 can't be parsed into one") % [escape(param),
        escape(value)])
  of PK_EMPTY:
    nil

proc parse*(expected: seq[Tparameter_specification],
    args: seq[TaintedString] = nil): Tcommandline_results =
  var expected = expected
  result.init()
  # Prepare the input parameter list, maybe get it from the OS if not available.
  var args = args
  if args == nil:
    let total_params = ParamCount()
    #echo "Got no explicit args, retrieving from OS. Count: ", total_params
    newSeq(args, total_params)
    for i in 0..total_params - 1:
      #echo ($i)
      args[i] = paramStr(i + 1)

  # Generate lookup table for each type of parameter based on strings.
  var lookup = initTable[string, ptr Tparameter_specification](
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
        lookup[single_switch] = addr(expected[i])
    if double_switch.len > 2:
      if lookup.hasKey(double_switch):
        quit("Parameter $1 repeated in input specification" % double_switch)
      else:
        lookup[double_switch] = addr(expected[i])

  # Loop through the input arguments detecting their type and doing stuff.
  var i = 0
  while i < args.len:
    let arg = args[i]
    #echo "Arg ", $i, " value '", arg, "'"
    if arg.len > 0:
      if lookup.hasKey(arg):
        var parsed : Tparsed_parameter
        let param = lookup[arg]
        if param.consumes != PK_EMPTY:
          if i + 1 < args.len:
            parsed = parse_parameter(arg, args[i + 1], param.consumes)
            i += 1
          else:
            raise newException(EInvalidValue, ("parameter $1 requires a " &
              "value, but none was provided") % [escape(arg)])
        #echo "\tFound ", arg, " ", next
        result.options[arg] = parsed
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
