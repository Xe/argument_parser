import argument_parser, strutils

when isMainModule:
  echo "Parsing default system params"
  parse()
  let args = @["test", "toca me la", "-a", "-wo", "rd", "--aasd", "--s"]
  echo "Parsing ", join(args, " ")
  parse(args)
