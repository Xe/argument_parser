import argument_parser, strutils, tables

proc process_commandline(): Tcommandline_results =
  let
    p1 = new_parameter_specification(single_word = "a", consumes = pkString)
    p2 = new_parameter_specification(single_word = "i", consumes = pkInt)
    p3 = new_parameter_specification(single_word = "f", consumes = pkFloat)
    p4 = new_parameter_specification(single_word = "b", consumes = pkBool)
    p5 = new_parameter_specification(single_word = "I", consumes = pkBiggestInt)
    p6 = new_parameter_specification(single_word = "F",
      consumes = pkBiggestFloat)
    all_params = @[p1, p2, p3, p4, p5, p6]
  result = parse(all_params)

when isMainModule:
  let ret = process_commandline()
  echo($ret)
