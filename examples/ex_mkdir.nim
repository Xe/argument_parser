import argument_parser, tables, strutils, parseutils

## Example defining a simple mkdir command line program.

const
  PARAM_PERMISSION = "-m"
  PARAM_INTERMEDIATE = "-p"
  PARAM_VERBOSE = "-v"
  PARAM_HELP = @["-h", "--help"]


template P(tnames: varargs[string], thelp: string, ttype = PK_EMPTY,
    tcallback: Tparameter_callback = nil) {.immediate.} =
  ## Helper to avoid repetition of parameter adding boilerplate.
  params.add(new_parameter_specification(ttype, custom_validator = tcallback,
    help_text = thelp, names = tnames))


proc parse_octal(parameter: string; value: var Tparsed_parameter): string =
  ## Custom parser and validator of octal values for PARAM_PERMISSION.
  ##
  ## If the user specifies the PARAM_PERMISSION option this proc will be called
  ## so we can validate the input, and maybe change it. The proc returns a non
  ## empty string if something went wrong with the description of the error,
  ## otherwise execution goes ahead.
  ##
  ## Note how we use this proc to parse a string and internally change it to an
  ## integer, after parsing it with parseutils.parseOct, since the default
  ## argument_parser module doesn't support octal types. Also, see how we
  ## assign a new Tparsed_parameter value to the passed in var value,
  ## effectively changing the type of the object variant from the originally
  ## specified string to int.
  if len(value.str_val) < 1:
    return "The empty string is not a valid value for '$1'" % [parameter]

  var octal_value: int
  let parsed_characters = value.str_val.parseOct(octal_value)
  if parsed_characters < len(value.str_val):
    echo ($value.str_val & ", " & $parsed_characters & ", " & $octal_value)
    return "Couldn't parse all characters of '$1' for $2 option, aborting" %
      [value.str_val, parameter]
  # Here we could add additional validation of input, like max absurd values.
  # Instead we just happily change the parsed value and go ahead.
  value = new_parsed_parameter(PK_INT, octal_value)


proc process_commandline(): Tcommandline_results =
  ## Parses the commandline.
  ##
  ## Returns a Tcommandline_results with at least one positional parameter.
  var params: seq[Tparameter_specification] = @[]

  P(PARAM_HELP, "Shows this help on the commandline", PK_HELP)

  P(PARAM_PERMISSION, "File permissions mask set on created directories, " &
    "specified as octal string", PK_STRING, parse_octal)

  P(PARAM_INTERMEDIATE, "Create intermediate directories as required")
  P(PARAM_VERBOSE, "Be verbose during directory creation")

  result = parse(params)

  if result.positional_parameters.len < 1:
    echo "Error, you need to pass the name of the directory you want to create"
    echo_help(params)
    quit()

  if result.options.hasKey(PARAM_PERMISSION):
    let val = result.options[PARAM_PERMISSION].int_val
    echo("Found option '$1', got as int '$2', octal '0$3'" %
      [PARAM_PERMISSION, $val, val.toOct(3)])

  if result.options.hasKey(PARAM_INTERMEDIATE):
    echo "Will create intermediate directories as required"

  if result.options.hasKey(PARAM_VERBOSE):
    echo "Will be verbose during directory creation"


proc main*() {.procvar.} =
  let args = process_commandline()
  for param in args.positional_parameters:
    echo "Creating dir for '" & param.str_val & "'"


when isMainModule: main()
