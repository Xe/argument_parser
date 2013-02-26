import argument_parser, strutils, tables

proc process_commandline(): Tcommandline_results =
  let
    p1 = new_parameter_specification(pkString,
      help_text = "Three weird params", names = @["-alt", "-a", "--arg"])
    p2 = new_parameter_specification(pkString,
      help_text = "This one felt so lonely", names = "--aasd")
    p3 = new_parameter_specification(pkInt,
      help_text = "Integers for the win!", names = "-i")
    p4 = new_parameter_specification(pkFloat,
      help_text = "Meh, floats are superior", names = @["-f", "--floatts"])
    p5 = new_parameter_specification(pkBool,
      help_text = "The next parameter always lies", names = "-b")
    p6 = new_parameter_specification(pkBiggestInt,
      help_text = "Admire my size", names = "-I")
    p7 = new_parameter_specification(pkBiggestFloat,
      help_text = "Admire my precission", names = "-F")
    all_params = @[p1, p2, p3, p4, p5, p6, p7]
  echo_help(all_params)
  quit()
  result = parse(all_params)

when isMainModule:
  let ret = process_commandline()
  echo($ret)
