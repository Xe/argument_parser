import argument_parser, strutils

when isMainModule:
  echo "Parsing default system params"
  let p1 = new_parameter_specification(single_letter = 'a', consumes = true)
  let p2 = new_parameter_specification(double_word = "aasd", consumes = true)
  let ret1 = parse(@[p1, p2])
  echo ($ret1)
  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s"]
  echo "Parsing ", join(args, " ")
  let ret2 = parse(@[p1, p2], args)
  echo ($ret2)
