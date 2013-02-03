import os, strutils, tables, math, parseutils

# - Types

type
  ## Different types of results for parameter parsing.
  Tparam_kind* = enum PK_EMPTY, PK_INT, PK_FLOAT, PK_STRING, PK_BOOL,
    PK_BIGGEST_INT, PK_BIGGEST_FLOAT

  ## Prototype of parameter callbacks
  ##
  ## A parameter callback is just a custom proc you provide which is invoked
  ## after a parameter is parsed passing the basic type validation. The
  ## callback proc has modification access to the Tparsed_parameter object that
  ## will be put into Tcommandline_results: you can read it and also modify it,
  ## maybe change its type.
  ##
  ## If the callback decides to abort the validation of the parameter, it has
  ## to put into result a non zero length string with a message for the user
  ## explaining why the validation failed, and maybe offer a hint as to what
  ## can be done to pass validation.
  Tparameter_callback* =
    proc (parameter: string; value: var Tparsed_parameter): string

  ## Holds the expectations of a parameter.
  Tparameter_specification* = object
    single_word*: string ## Single dash parameter
    double_word*: string ## Double dash parameter
    consumes*: Tparam_kind ## Expected type of the parameter (empty for none)
    custom_validator*: Tparameter_callback ## Optional custom callback
                                           ## to run after type conversion.

  ## Contains the parsed value from the user.
  ##
  ## This implements an object variant through the kind field. You can 'case'
  ## this field to write a generic proc to deal with parsed parameters, but
  ## nothing prevents you from accessing directly the type of field you want if
  ## you expect only one kind.
  Tparsed_parameter* = object
    case kind*: Tparam_kind
    of PK_EMPTY: nil
    of PK_INT: int_val*: int
    of PK_BIGGEST_INT: big_int_val*: biggestInt
    of PK_FLOAT: float_val*: float
    of PK_BIGGEST_FLOAT: big_float_val*: biggestFloat
    of PK_STRING: str_val*: string
    of PK_BOOL: bool_val*: bool

  ## Contains the results of the parsing.
  Tcommandline_results* = object
    positional_parameters*: seq[Tparsed_parameter]
    options*: TTable[string, Tparsed_parameter]


# - Tparameter_specification procs

proc init*(param: var Tparameter_specification,
    single_word : string, double_word = "", consumes = PK_EMPTY,
    custom_validator : Tparameter_callback = nil) =
  # Initialization helper.
  param.single_word = single_word
  param.double_word = double_word
  param.consumes = consumes
  param.custom_validator = custom_validator

proc new_parameter_specification*(single_word = "",
    double_word = "", consumes = PK_EMPTY,
    custom_validator : Tparameter_callback = nil): Tparameter_specification =
  # Initialization helper for let variables.
  result.init(single_word, double_word, consumes, custom_validator)

# - Tparsed_parameter procs

proc `$`*(data: Tparsed_parameter): string {.procvar.} =
  # Stringifies the value, mostly for debug purposes.
  case data.kind:
  of PK_EMPTY: result = "nil"
  of PK_INT: result = "$1(i)" % $data.int_val
  of PK_BIGGEST_INT: result = "$1(I)" % $data.big_int_val
  of PK_FLOAT: result = "$1(f)" % $data.float_val
  of PK_BIGGEST_FLOAT: result = "$1(F)" % $data.big_float_val
  of PK_STRING: result = "\"" & $data.str_val & "\""
  of PK_BOOL: result = "$1(b)" % $data.bool_val

template new_parsed_parameter*(tkind: Tparam_kind, expr): Tparsed_parameter =
  var result {.gensym.}: Tparsed_parameter
  result.kind = tkind
  when tkind == PK_EMPTY: nil
  elif tkind == PK_INT: result.int_val = expr
  elif tkind == PK_BIGGEST_INT: result.big_int_val = expr
  elif tkind == PK_FLOAT: result.float_val = expr
  elif tkind == PK_BIGGEST_FLOAT: result.big_float_val = expr
  elif tkind == PK_STRING: result.str_val = expr
  elif tkind == PK_BOOL: result.bool_val = expr
  else: {.error: "unknown kind".}
  result

# - Tcommandline_results procs

proc init*(param: var Tcommandline_results;
    positional_parameters: seq[Tparsed_parameter] = @[];
    options: TTable[string, Tparsed_parameter] =
      initTable[string, Tparsed_parameter](4)) =
  # Initialization helper.
  param.positional_parameters = positional_parameters
  param.options = options

proc `$`*(data: Tcommandline_results): string =
  # Stringifies a Tcommandline_results structure for debug output
  var dict: seq[string] = @[]
  for key, value in data.options:
    dict.add("$1: $2" % [escape(key), $value])
  result = "Tcommandline_result{positional_parameters:[$1], options:{$2}}" % [
    join(map(data.positional_parameters, `$`), ", "), join(dict, ", ")]

# - Parse code

template raise_or_quit(exception, message: expr): stmt {.immediate.} =
  ## Avoids repeating if check based on the default quit_on_failure variable.
  if quit_on_failure:
    quit(message)
  else:
    raise newException(exception, message)

template run_custom_proc(parsed_parameter: Tparsed_parameter,
    custom_validator: Tparameter_callback,
    parameter: TaintedString) =
  ## Runs the custom validator if it is not nil.
  ##
  ## Pass in the string of the parameter triggering the call. If the
  if not custom_validator.isNil:
    except:
      raise_or_quit(EInvalidValue, ("Couldn't run custom proc for " &
        "parameter $1:\n$2" % [escape(parameter),
        getCurrentExceptionMsg()]))
    let message = custom_validator(parameter, parsed_parameter)
    if not message.isNil and message.len > 0:
      raise_or_quit(EInvalidValue, ("Failed to validate value for " &
        "parameter $1:\n$2" % [escape(parameter), message]))

proc parse_parameter(quit_on_failure: bool, param, value: string,
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
      raise_or_quit(EOverflow, ("parameter $1 requires an " &
        "integer, but $2 is too large to fit into one") % [param,
        escape(value)])
    except EInvalidValue:
      raise_or_quit(EInvalidValue, ("parameter $1 requires an " &
        "integer, but $2 can't be parsed into one") % [param, escape(value)])
  of PK_STRING:
    result.str_val = value
  of PK_FLOAT:
    try: result.float_val = value.parseFloat
    except EInvalidValue:
      raise_or_quit(EInvalidValue, ("parameter $1 requires a " &
        "float, but $2 can't be parsed into one") % [param, escape(value)])
  of PK_BOOL:
    try: result.bool_val = value.parseBool
    except EInvalidValue:
      raise_or_quit(EInvalidValue, ("parameter $1 requires a " &
        "boolean, but $2 can't be parsed into one. Valid values are: " &
        "y, yes, true, 1, on, n, no, false, 0, off") % [param, escape(value)])
  of PK_BIGGEST_INT:
    try:
      let parsed_len = parseBiggestInt(value, result.big_int_val)
      if value.len != parsed_len or parsed_len < 1:
        raise_or_quit(EInvalidValue, ("parameter $1 requires an " &
          "integer, but $2 can't be parsed completely into one") % [
          param, escape(value)])
    except EInvalidValue:
      raise_or_quit(EInvalidValue, ("parameter $1 requires an " &
        "integer, but $2 can't be parsed into one") % [param, escape(value)])
  of PK_BIGGEST_FLOAT:
    try:
      let parsed_len = parseBiggestFloat(value, result.big_float_val)
      if value.len != parsed_len or parsed_len < 1:
        raise_or_quit(EInvalidValue, ("parameter $1 requires a " &
          "float, but $2 can't be parsed completely into one") % [
          param, escape(value)])
    except EInvalidValue:
      raise_or_quit(EInvalidValue, ("parameter $1 requires a " &
        "float, but $2 can't be parsed into one") % [param, escape(value)])
  of PK_EMPTY:
    nil

proc parse*(expected: seq[Tparameter_specification] = @[],
    type_of_positional_parameters = PK_STRING, args: seq[TaintedString] = nil,
    quit_on_failure = true): Tcommandline_results =
  ## Parses parameters and returns results.
  ##
  ## The expected array should contain a list of the dash parameters you want
  ## to detect, which can have additional values. Non dash parameters are
  ## considered positional parameters for which you can specify a type with
  ## type_of_positional_parameters.
  ##
  ## The args sequence should be the list of parameters passed to your program
  ## without the program binary (usually OSes provide the path to the binary as
  ## the zeroth parameter). If args is nil, the list will be retrieved from the
  ## OS.
  ##
  ## If there is any kind of error and quit_on_failure is true, the quit proc
  ## will be called with a user error message. If quit_on_failure is false
  ## errors will raise exceptions (usually EInvalidValue or EOverflow) instead
  ## for you to catch and handle.

  assert type_of_positional_parameters != PK_EMPTY
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
        raise_or_quit(EInvalidKey,
          "Parameter $1 repeated in input specification" % single_switch)
      else:
        lookup[single_switch] = addr(expected[i])

    if double_switch.len > 2:
      if lookup.hasKey(double_switch):
        raise_or_quit(EInvalidKey,
          "Parameter $1 repeated in input specification" % double_switch)
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
            parsed = parse_parameter(quit_on_failure,
              arg, args[i + 1], param.consumes)
            run_custom_proc(parsed, param.custom_validator, arg)
            i += 1
          else:
            raise newException(EInvalidValue, ("parameter $1 requires a " &
              "value, but none was provided") % [arg])
        #echo "\tFound ", arg, " ", next
        result.options[arg] = parsed
      else:
        if arg[0] == '-':
          raise_or_quit(EInvalidValue, "Found unexpected parameter $1" % arg)
        else:
          #echo "Normal parameter"
          result.positional_parameters.add(parse_parameter(quit_on_failure,
            $(1 + i), arg, type_of_positional_parameters))
    else:
      #echo "\tEmpty file parameter?"
      result.positional_parameters.add(parse_parameter(quit_on_failure,
        $(1 + i), arg, type_of_positional_parameters))

    i += 1


when isMainModule:
  echo "Welcome to argument_parser!"
