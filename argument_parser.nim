import os

proc parse*(args: seq[TaintedString] = nil) =
  var args = args
  if args == nil:
    let total_params = ParamCount()
    echo "Got no explicit args, retrieving from OS. Count: ", total_params
    newSeq(args, total_params)
    for i in 0..total_params - 1:
      echo ($i)
      args[i] = paramStr(i + 1)

  for index, arg in args:
    echo "Arg ", $index, " value '", arg, "'"
    if arg.len > 0:
      if arg[0] == '-':
        if arg.len > 1:
          if arg[1] == '-':
            if arg.len > 3:
              echo "\tDouble dash word parameter"
            else:
              echo "\tDouble dash letter parameter? broken"
          else:
            if arg.len > 2:
              echo "\tSingle dash word parameter"
            else:
              echo "\tSingle dash letter parameter"
        else:
          echo "Single dash parameter, stdin/stdout?"
      else:
        echo "Normal parameter"
    else:
      echo "\tEmpty file parameter?"

when isMainModule:
  echo "Welcome to argument_parser!"
  parse()
