import argument_parser, strutils, tables

when isMainModule:
  echo "Parsing default system params"
  let p1 = new_parameter_specification(single_word = "a", consumes = true)
  let p2 = new_parameter_specification(double_word = "aasd", consumes = true)
  let ret1 = parse(@[p1, p2])
  echo ($ret1)
  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s"]
  echo "Parsing ", join(args, " ")
  let ret2 = parse(@[p1, p2], args)
  echo ($ret2)
  assert ret2.options["-a"] == "-wo"
  assert (not ret2.options.hasKey("test"))
  assert "test" in ret2.files
