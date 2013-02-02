import argument_parser, strutils, tables

template test_failure(exception, code: expr): stmt =
  try:
    let pos = instantiationInfo()
    discard(code)
    echo "Unit test failure at $1:$2 with '$3'" % [pos.filename,
      $pos.line, astToStr(code)]
    doAssert false, "A test expecting failure succeeded?"
  except exception:
    nil

#template test_success(code: expr) {.immediate.} = echo($code)
template test_success(code: expr) {.immediate.} = discard(code)

template test_in(commandline_parameters, expected_value, attribute: expr):
    expr {.immediate.} =
  ## Returns true if the expected value is found in the commandline parameters.
  ##
  ## Pass the attribute to check in the Tparsed_parameter object.
  var result {.gensym.}: bool = false
  for parameter in commandline_parameters.positional_parameters:
    if parameter.attribute == expected_value:
      result = true
      break
  result

template tp(expected: seq[Tparameter_specification] = @[],
    type_of_positional_parameters = PK_STRING, args: seq[TaintedString] = nil):
      expr =
  # Simple wrapper to avoid changing the last default parameter.
  parse(expected, type_of_positional_parameters, args,
    quit_on_failure = false)

proc test() =
  #echo "\nParsing default system params"
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

  discard(tp(all_params))

  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s", "ugh"]
  #echo "\nParsing ", join(args, " ")
  let ret2 = tp(all_params, args = args)
  #echo($ret2)
  doAssert ret2.options["-a"].strVal == "-wo"
  doAssert ret2.options.hasKey("test") == false
  doAssert test_in(ret2, "test", str_val)
  doAssert test_in(ret2, "--s", str_val) == false
  doAssert test_in(ret2, "ugh", str_val)
  test_failure(EInvalidValue, tp(all_params, PK_INT, args))

  # Integer tests.
  test_success(tp(all_params, args = @["int test", "-i", "445"]))
  test_success(tp(all_params, args = @["int test", "-i", "-445"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-i", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-i", "0x02"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-i", "fail"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-i", "234.12"]))
  test_failure(EOverflow, tp(all_params, args = @["-i", $high(int) & "0"]))
  test_success(tp(all_params, PK_INT, @["-i", "-445", "2", "3", "4"]))
  test_failure(EInvalidValue,
    tp(all_params, PK_INT, @["-i", "-445", "2", "3", "4.3"]))
  let ret_int = tp(all_params, PK_INT, @["-i", "-445", "2", "3", "4"])
  doAssert ret_int.options["-i"].int_val == -445
  doAssert test_in(ret_int, 2, int_val)
  doAssert test_in(ret_int, 3, int_val)
  doAssert test_in(ret_int, 4, int_val)
  doAssert test_in(ret_int, 5, int_val) == false

  # String tests.
  test_success(tp(all_params, args = @["str test", "-a", "word"]))
  test_success(tp(all_params, args = @["str empty test", "-a", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["str test", "-a"]))

  # Float tests.
  test_success(tp(all_params, args = @["-f", "123.235"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", "abracadabra"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", "12.34aadd"]))
  let ret_float = tp(all_params, PK_FLOAT, @["-f", "12.23", "89.2", "3.14"])
  doAssert ret_float.options["-f"].float_val == 12.23
  doAssert test_in(ret_float, 89.2, float_val)
  doAssert test_in(ret_float, 3.14, float_val)
  doAssert test_in(ret_float, 3.1, float_val) == false

  # Boolean tests.
  for param in @["y", "yes", "true", "1", "on", "n", "no", "false", "0", "off"]:
    test_success(tp(all_params, args = @["-b", param]))
  test_failure(EInvalidValue, tp(all_params, args = @["-b", "t"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-b", ""]))
  doAssert test_in(tp(all_params, PK_BOOL, @["y"]), true, bool_val)
  doAssert test_in(tp(all_params, PK_BOOL, @["0"]), false, bool_val)

  # Big integer tests.
  test_success(tp(all_params, args = @["int test", "-I", "445"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-I", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-I", "fail"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-I", "234.12"]))
  test_failure(EOverflow, tp(all_params,
    args = @["-I", $high(biggestInt) & "0"]))
  let ret_bigint = tp(all_params, PK_BIGGEST_INT, @["42", $high(biggestInt)])
  doAssert test_in(ret_bigint, 42, big_int_val)
  doAssert test_in(ret_bigint, high(biggestInt), big_int_val)
  doAssert test_in(ret_bigint, 13, big_int_val) == false

  # Big float tests.
  test_success(tp(all_params, args = @["-F", "123.235"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", "abracadabra"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", "12.34aadd"]))
  let ret_bigfloat = tp(all_params, PK_BIGGEST_FLOAT, @["111.111", "9.01"])
  doAssert test_in(ret_bigfloat, 111.111, big_float_val)
  doAssert test_in(ret_bigfloat, 9.01, big_float_val)
  doAssert test_in(ret_bigfloat, 9.02, big_float_val) == false

  # Using custom procs for transformation of type back to string.
  var c1 = new_parameter_specification(single_word = "i", consumes = PK_INT)
  c1.custom_validator =
    proc (parameter: string, value: var Tparsed_parameter): string =
      echo "Hey there debug $1, parsed $2" % [parameter, $value]
      var new_value : Tparsed_parameter
      new_value.kind = PK_STRING
      new_value.str_val = $value.int_val
      value = new_value
      echo ($value)
      result = ""
  let ret_c1 = tp(@[c1], args = @["-i", "42"])
  echo ($ret_c1)
  doAssert ret_c1.options["-i"].str_val == "42"
  echo "Tester finished"

when isMainModule:
  test()
