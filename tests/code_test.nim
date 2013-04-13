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
    type_of_positional_parameters = PK_STRING, args: seq[TaintedString] = nil,
    bad_prefixes = @["-", "--"], end_of_options = "--"):
      expr =
  # Simple wrapper to avoid changing the last default parameter.
  parse(expected, type_of_positional_parameters, args,
    bad_prefixes, end_of_options, quit_on_failure = false)

proc test() =
  #echo "\nParsing default system params"
  let
    p1 = new_parameter_specification(pkString, names = "-a")
    p2 = new_parameter_specification(pkString, names = "--aasd")
    p3 = new_parameter_specification(pkInt, names = "-i")
    p4 = new_parameter_specification(pkFloat, names = "-f")
    p5 = new_parameter_specification(pkBool, names = "-b")
    p6 = new_parameter_specification(pkBiggestInt, names = "-I")
    p7 = new_parameter_specification(pkBiggestFloat, names = "-F")
    all_params = @[p1, p2, p3, p4, p5, p6, p7]

  discard(tp(all_params))

  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s", "ugh"]
  #echo "\nParsing ", join(args, " ")
  var ret = tp(all_params, args = args)
  #echo($ret)
  doAssert ret.options["-a"].strVal == "-wo"
  doAssert ret.options.hasKey("test") == false
  doAssert test_in(ret, "test", str_val)
  doAssert test_in(ret, "--s", str_val) == false
  doAssert test_in(ret, "ugh", str_val)
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

  ret = tp(all_params, PK_INT, @["-i", "-445", "2", "3", "4"])
  doAssert ret.options["-i"].int_val == -445
  doAssert test_in(ret, 2, int_val)
  doAssert test_in(ret, 3, int_val)
  doAssert test_in(ret, 4, int_val)
  doAssert test_in(ret, 5, int_val) == false

  # String tests.
  test_success(tp(all_params, args = @["str test", "-a", "word"]))
  test_success(tp(all_params, args = @["str empty test", "-a", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["str test", "-a"]))

  # Float tests.
  test_success(tp(all_params, args = @["-f", "123.235"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", "abracadabra"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-f", "12.34aadd"]))
  ret = tp(all_params, PK_FLOAT, @["-f", "12.23", "89.2", "3.14"])
  doAssert ret.options["-f"].float_val == 12.23
  doAssert test_in(ret, 89.2, float_val)
  doAssert test_in(ret, 3.14, float_val)
  doAssert test_in(ret, 3.1, float_val) == false

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
  ret = tp(all_params, PK_BIGGEST_INT, @["42", $high(biggestInt)])
  doAssert test_in(ret, 42, big_int_val)
  doAssert test_in(ret, high(biggestInt), big_int_val)
  doAssert test_in(ret, 13, big_int_val) == false

  # Big float tests.
  test_success(tp(all_params, args = @["-F", "123.235"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", ""]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", "abracadabra"]))
  test_failure(EInvalidValue, tp(all_params, args = @["-F", "12.34aadd"]))
  ret = tp(all_params, PK_BIGGEST_FLOAT, @["111.111", "9.01"])
  doAssert test_in(ret, 111.111, big_float_val)
  doAssert test_in(ret, 9.01, big_float_val)
  doAssert test_in(ret, 9.02, big_float_val) == false

  # Using custom procs for transformation of type back to string.
  var c1 = new_parameter_specification(PK_INT, names = "-i")
  ret = tp(@[c1], args = @["-i", "42"])
  doAssert ret.options["-i"].int_val == 42
  # Now repeat transforming to int through a custom post-validator.
  c1.custom_validator =
    proc (parameter: string, value: var Tparsed_parameter): string =
      value = new_parsed_parameter(PK_STRING, $value.int_val)
  ret = tp(@[c1], args = @["-i", "42"])
  doAssert ret.options["-i"].str_val == "42"

  # Change the custom proc to reject values lower than 18.
  c1.custom_validator =
    proc (parameter: string, value: var Tparsed_parameter): string =
      let age = value.int_val
      if age < 18:
        result = "Can't accept minors ($1) parsing arguments" % [$age]
      else:
        value = new_parsed_parameter(PK_STRING, "valid_$1" % [$age])
  ret = tp(@[c1], args = @["-i", "42"])
  doAssert ret.options["-i"].str_val == "valid_42"
  test_failure(EInvalidValue, tp(@[c1], args = @["-i", "17"]))

  # Make sure we disallow multiple parameters being the same.
  test_failure(EInvalidKey,
    tp(@[new_parameter_specification(names = ["-a", "-a"])]))
  # Also repeated keys in different parameters.
  test_failure(EInvalidKey,
    tp(@[new_parameter_specification(names = ["-a", "--alt"]),
      new_parameter_specification(names = ["-p", "--pert"]),
      new_parameter_specification(names = ["-z", "--alt"])]))
  # The following will fail with ambiguos parameter.
  test_failure(EInvalidValue,
    tp(all_params, args = @["-bleah", "something"]))
  # This one won't because we are passing the disambiguator.
  discard(tp(all_params, args = @["--", "-bleah", "something"]))
  # This should work too because we changed the bad prefixes.
  discard(tp(all_params, args = @["-bl", "so"], bad_prefixes = @[]))
  # This should detect new prefixes.
  test_failure(EInvalidValue,
    tp(all_params, args = @["/bl", "so"], bad_prefixes = @["/"]))
  # Mix new prefixes plus end of parsing options.
  discard(tp(all_params, args = @["-*-", "/bĸ", "a"],
    bad_prefixes = @["/"], end_of_options = "-*-"))

  # Test boolean switches using their second version.
  ret = tp(@[new_parameter_specification(names = @["-s", "--silent"])],
    args = @["file1", "--silent"])
  doAssert ret.options.hasKey("-s")
  doAssert (not ret.options.hasKey("--silent"))

  ret = tp(@[new_parameter_specification(names = @["--silent", "-s"])],
    args = @["file1", "--silent"])
  doAssert ret.options.hasKey("--silent")
  doAssert (not ret.options.hasKey("-s"))

  echo "Tester finished"

when isMainModule:
  test()
