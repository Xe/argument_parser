import ex_cp, ex_wget, ex_git, ex_mkdir

# Dummy test to verify examples compile. We don't want to call those procs
# since we don't get anything out of them, but at least we can show their
# addresses.
proc test() =
  echo cast[int](ex_cp.main)
  echo cast[int](ex_wget.main)
  echo cast[int](ex_git.main)
  echo cast[int](ex_mkdir.main)
  echo "Good."


when isMainModule: test()
