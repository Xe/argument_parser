import argument_parser, tables, strutils, parseutils

## Example defining a subset of git's functionality
##
## The point of this example is to show that you are not required to use
## options with dashes, you can use normal words too and mix them.
##
## At the moment, however, the parser is still too simple and doesn't handle
## branched options which are required for a true git commandline. That is, all
## the options you specify apply at the same time, so you can't exclude one
## switch being available only for a specific command.
##
## This is planned to be improved in the future both through branched switches
## (https://github.com/gradha/argument_parser/issues/18) and by opening the
## parsing state machine for custom procs which will allow any kind of
## behaviour you want (https://github.com/gradha/argument_parser/issues/19).
##
## Also, the look of the generated help is really bad with mixed commands and
## options. Custom help output will be allowed.

const
  PARAM_VERSION = @["--version"]
  PARAM_HELP = @["--help"]
  PARAM_CONFIG = @["-c"]
  PARAM_PAGINATE = @["-p", "--paginate"]
  COMMAND_ADD = "add"
  COMMAND_MV = "mv"
  COMMAND_RM = "rm"
  COMMAND_DIFF = "diff"
  COMMANDS = @[COMMAND_ADD, COMMAND_MV, COMMAND_RM, COMMAND_DIFF]


type
  Tgit_commandline_results = object of Tcommandline_results ## \
    ## Inherits the normal object to add more fields for convenience.
    command: string


template P(tnames: varargs[string], thelp: string, ttype = PK_EMPTY,
    tcallback : Tparameter_callback = nil) =
  ## Helper to avoid repetition of parameter adding boilerplate.
  params.add(new_parameter_specification(ttype, custom_validator = tcallback,
    help_text = thelp, names = tnames))


template got(param: varargs[string]) =
  ## Just dump the detected options on output.
  if result.options.hasKey(param[0]): echo("Found option '$1'." % [param[0]])


proc parse_configuration_parameter(parameter: string;
    value: var Tparsed_parameter): string =
  ## Simple validator of configuration parameters for PARAM_CONFIG.
  ##
  ## If the user specifies the PARAM_CONFIG option this proc will be called
  ## so we can validate the input. The proc returns a non empty string if
  ## something went wrong with the description of the error, otherwise
  ## execution goes ahead.
  ##
  ## We won't actually parse the validity of the values, but we can try to make
  ## sure there are at least two values separated by an equal sign.
  ##
  ## This validator only accepts values without changing the final output.
  let chunks = split(value.str_val, '=')
  if chunks.len != 2:
    return "Bad syntax for configuration parameter, use x=y"

  for chunk in chunks:
    if chunk.len < 1:
      return "Bad syntax for configuration parameter, use x=y"

  echo "Found valid configuration parameter %1" % [value.str_val]


proc process_commandline(): Tgit_commandline_results =
  ## Parses the commandline.
  ##
  ## Returns a Tcommandline_results with at least two positional parameter,
  ## where the last parameter is implied to be the destination of the copying.
  var params : seq[Tparameter_specification] = @[]

  P(PARAM_VERSION, "Shows the version of the program")
  P(PARAM_HELP, "Shows this help on the commandline", PK_HELP)
  P(PARAM_CONFIG, "Passes a configuration parameter to the command in x=y form",
    PK_STRING, parse_configuration_parameter)
  P(PARAM_PAGINATE, "Pipe all output into less")
  P(COMMAND_ADD, "Add file contents to the index")
  P(COMMAND_MV, "Move or rename a file, a directory, or a symlink")
  P(COMMAND_RM, "Remove files from the working tree and from the index")
  P(COMMAND_DIFF, "Show changes using common diff tools")

  # Cast the result so we don't have to write our own manual assignment proc.
  Tcommandline_results(result) = parse(params)

  if result.options.hasKey(PARAM_VERSION[0]):
    echo "Version 3.1415"
    quit()

  var found_commands : seq[string] = @[]
  for command in COMMANDS:
    if result.options.hasKey(command):
      found_commands.add(command)

  if found_commands.len < 1:
    echo "Please specify a command to work with"
    echo_help(params)
    quit()

  if found_commands.len > 1:
    echo "Please specify a single command to work with, can't use " &
      "$1 at the same time" % [join(found_commands, "|")]
    echo_help(params)
    quit()

  if result.options.hasKey(COMMAND_MV) and result.positional_parameters.len > 2:
    echo "The move command requires a single source and dest params"
    echo_help(params)
    quit()

  if result.positional_parameters.len < 1:
    echo "Pass some paths to work on"
    echo_help(params)
    quit()

  got(PARAM_PAGINATE)

  if result.options.hasKey(PARAM_CONFIG[0]):
    echo "Passing config '$1' to command" % [
      result.options[PARAM_CONFIG[0]].str_val]

  result.command = found_commands[0]


when isMainModule:
  let args = process_commandline()
  echo "Using command '$1'" % [args.command]
  for param in args.positional_parameters:
    echo "Acting on $1" % param.str_val
