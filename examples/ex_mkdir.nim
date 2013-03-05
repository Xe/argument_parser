import argument_parser, tables, strutils

## Example defining a simple mkdir command line program.

const
  PARAM_PERMISSION = "-m"
  PARAM_INTERMEDIATE = "-p"
  PARAM_VERBOSE = "-v"
  PARAM_HELP = @["-h", "--help"]

proc process_commandline(): Tcommandline_results =
  ## Parses the commandline.
  ##
  ## Returns a Tcommandline_results with at least one positional parameter.
  let
    p1 = new_parameter_specification(PK_HELP,
      help_text = "Shows this help on the commandline", names = PARAM_HELP)
    p2 = new_parameter_specification(PK_STRING,
      help_text = "File permissions mask set on created directories",
      names = PARAM_PERMISSION)
    p3 = new_parameter_specification(
      help_text = "Create intermediate directories as required",
      names = PARAM_INTERMEDIATE)
    p4 = new_parameter_specification(
      help_text = "Be verbose during directory creation", names = PARAM_VERBOSE)
    all_params = @[p1, p2, p3, p4]

  result = parse(all_params)

  if result.positional_parameters.len < 1:
    echo "Error, you need to pass the name of the directory you want to create"
    echo_help(all_params)
    quit()

  if result.options.hasKey(PARAM_PERMISSION):
    echo("Did found option '$1', but we won't parse '$2' in this example" %
      [PARAM_PERMISSION, result.options[PARAM_PERMISSION].str_val])

  if result.options.hasKey(PARAM_INTERMEDIATE):
    echo "Will create intermediate directories as required"

  if result.options.hasKey(PARAM_VERBOSE):
    echo "Will be verbose during directory creation"


when isMainModule:
  let args = process_commandline()
  for param in args.positional_parameters:
    echo "Creating dir for '" & param.str_val & "'"
