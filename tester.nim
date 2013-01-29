import argument_parser, strutils, tables

template test_failure(exception, code: expr): stmt =
  try:
    let pos = instantiationInfo()
    discard(code)
    echo "Unit test failure at $1:$2 with '$3'" % [pos.filename,
      $pos.line, astToStr(code)]
    assert false, "A test expecting failure succeeded?"
  except exception:
    nil

template test_success(code: expr) {.immediate.} = echo($code)

proc test() =
  echo "\nParsing default system params"
  let
    p1 = new_parameter_specification(single_word = "a", consumes = pkString)
    p2 = new_parameter_specification(double_word = "aasd", consumes = pkString)
    p3 = new_parameter_specification(single_word = "i", consumes = pkInt)
    p4 = new_parameter_specification(single_word = "f", consumes = pkFloat)
    p5 = new_parameter_specification(single_word = "b", consumes = pkBool)
    p6 = new_parameter_specification(single_word = "I", consumes = pkBiggestInt)
    p7 = new_parameter_specification(single_word = "F",
      consumes = pkBiggestFloat)
    all_params = @[p1, p2, p3, p4, p5, p6, p7]

  let ret1 = parse(all_params)
  echo($ret1)

  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s"]
  echo "\nParsing ", join(args, " ")
  let ret2 = parse(all_params, args)
  echo($ret2)
  assert ret2.options["-a"].strVal == "-wo"
  assert (not ret2.options.hasKey("test"))
  assert "test" in ret2.files

  # Integer tests.
  test_success(parse(all_params, @["int test", "-i", "445"]))
  test_success(parse(all_params, @["int test", "-i", "-445"]))
  test_failure(EInvalidValue, parse(all_params, @["-i", "fail"]))
  test_failure(EInvalidValue, parse(all_params, @["-i", "234.12"]))
  test_failure(EOverflow, parse(all_params, @["-i", $high(int) & "0"]))

  # String tests.
  test_success(parse(all_params, @["str test", "-a", "word"]))
  test_failure(EInvalidValue, parse(all_params, @["str test", "-a"]))

  # Float tests.
  test_success(parse(all_params, @["-f", "123.235"]))
  test_failure(EInvalidValue, parse(all_params, @["-f", "abracadabra"]))
  test_failure(EInvalidValue, parse(all_params, @["-f", "12.34aadd"]))

  # Boolean tests.
  for param in @["y", "yes", "true", "1", "on", "n", "no", "false", "0", "off"]:
    test_success(parse(all_params, @["-b", param]))
  test_failure(EInvalidValue, parse(all_params, @["-b", "t"]))

  # Big integer tests.
  test_success(parse(all_params, @["int test", "-I", "445"]))
  test_failure(EInvalidValue, parse(all_params, @["-I", "fail"]))
  test_failure(EInvalidValue, parse(all_params, @["-I", "234.12"]))
  test_failure(EOverflow, parse(all_params, @["-I", $high(biggestInt) & "0"]))

  # Big float tests.
  test_success(parse(all_params, @["-F", "123.235"]))
  test_failure(EInvalidValue, parse(all_params, @["-F", "abracadabra"]))
  test_failure(EInvalidValue, parse(all_params, @["-F", "12.34aadd"]))

  echo "Tester finished"

when isMainModule:
  test()
