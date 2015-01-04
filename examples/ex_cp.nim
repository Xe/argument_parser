import argument_parser, tables, strutils, parseutils

## Example defining a simple copy command line program.

const
  PARAM_PRESERVE_ALL = "-a"
  PARAM_FORCE = "-f"
  PARAM_FOLLOW_SOME_SYMBOLIC_LINKS = "-H"
  PARAM_INTERACTIVE = "-i"
  PARAM_FOLLOW_ALL_SYMBOLIC_LINKS = "-L"
  PARAM_NO_OVERWRITE = "-n"
  PARAM_FOLLOW_NO_SYMBOLIC_LINKS = "-P"
  PARAM_PRESERVE_ATTRIBUTES = "-p"
  PARAM_RECURSIVE = "-R"
  PARAM_VERBOSE = "-v"
  PARAM_HELP = "-h"


template P(tnames: varargs[string], thelp: string) =
  ## Helper to avoid repetition of parameter adding boilerplate.
  params.add(new_parameter_specification(PK_EMPTY,
    help_text = thelp, names = tnames))


template got(param: string) =
  ## Just dump the detected options on output.
  if result.options.hasKey(param): echo("Found option '$1'." % [param])


proc process_commandline(): Tcommandline_results =
  ## Parses the commandline.
  ##
  ## Returns a Tcommandline_results with at least two positional parameter,
  ## where the last parameter is implied to be the destination of the copying.
  var params: seq[Tparameter_specification] = @[]

  P(PARAM_PRESERVE_ALL, ("Same as $1 $2 $3 options, preserves " &
    "structure and attributes of files but not directory structure") % [
    PARAM_PRESERVE_ATTRIBUTES, PARAM_FOLLOW_NO_SYMBOLIC_LINKS, PARAM_RECURSIVE])
  P(PARAM_FORCE, "Force overwrite destination files")
  P(PARAM_FOLLOW_SOME_SYMBOLIC_LINKS,
    "Follow symbolic links on the command line")
  P(PARAM_INTERACTIVE, "Prompt before overwritting destination")
  P(PARAM_FOLLOW_ALL_SYMBOLIC_LINKS, "Follow all symbolic links recursively")
  P(PARAM_NO_OVERWRITE, "Do not overwrite destination")
  P(PARAM_FOLLOW_NO_SYMBOLIC_LINKS, "No symbolic links are followed")
  P(PARAM_PRESERVE_ATTRIBUTES, "Attributes are preserved to destination")
  P(PARAM_RECURSIVE, "Follow source directories recursively")
  P(PARAM_VERBOSE, "Be verbose about actions")

  params.add(new_parameter_specification(PK_HELP,
    help_text = "Shows this help on the commandline", names = PARAM_HELP))

  result = parse(params)

  if result.positional_parameters.len < 2:
    echo "Missing parameters, you need to pass the source and dest targets."
    echo_help(params)
    quit()

  got(PARAM_PRESERVE_ALL)
  got(PARAM_FORCE)
  got(PARAM_FOLLOW_SOME_SYMBOLIC_LINKS)
  got(PARAM_INTERACTIVE)
  got(PARAM_FOLLOW_ALL_SYMBOLIC_LINKS)
  got(PARAM_NO_OVERWRITE)
  got(PARAM_FOLLOW_NO_SYMBOLIC_LINKS)
  got(PARAM_PRESERVE_ATTRIBUTES)
  got(PARAM_RECURSIVE)
  got(PARAM_VERBOSE)


proc main*() {.procvar.} =
  let args = process_commandline()
  let dest = args.positional_parameters[args.positional_parameters.len - 1]
  for i in 0..args.positional_parameters.len - 2:
    echo "Copying $1 -> $2" % [args.positional_parameters[i].str_val,
      dest.str_val]


when isMainModule: main()
