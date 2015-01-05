import argument_parser, strutils


proc runtime_test() =
  let
    parsed_param1 = Tparsed_parameter(kind: PK_FLOAT,
      float_val: 3.41)
    parsed_param2 = Tparsed_parameter(kind: PK_BIGGEST_INT,
      big_int_val: 2358123 * 23123)

  try:
    let
      parsed_param3 = Tparsed_parameter(kind: PK_INT, str_val: "231")
    doAssert false
  except EInvalidField:
    echo "Correct exception caught"


const
  compiles_bad_template = compiles((
    let x = new_parsed_parameter(PK_INT, "231"); x))

  compiles_good_template = compiles((
    let x = new_parsed_parameter(PK_INT, 231); x))

  compiles_bad_runtime = compiles((
    let x = Tparsed_parameter(kind: PK_INT, str_val: "231"); x))


proc compile_test() =
  doAssert(not compiles_bad_template)
  doAssert(compiles_good_template)
  doAssert(compiles_bad_runtime)
  echo "Compile time tests passed!"


proc test() =
  let
    age = 33
    value = Tparsed_parameter(kind: PK_STRING, str_val: "valid_$1" % [$age])

  let x = new_parsed_parameter(PK_STRING, "ajajaj")
  var y: Tparam_kind
  y = PK_FLOAT
  #let z = new_parsed_parameter(y, 2.3);
  let z = Tparsed_parameter(kind: y, float_val: 2.3)
  echo z.repr

  compile_test()
  runtime_test()
  echo "Tester finished"

when isMainModule:
  test()
