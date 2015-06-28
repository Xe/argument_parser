import
  bb_nake, bb_os, osproc, htmlparser, xmltree, strtabs, times,
  argument_parser, sequtils

const name = "argument_parser"

let
  modules = @[name]
  rst_files = @["docs"/"changes", "docs"/"release_steps",
    "LICENSE", "README"]


proc mangle_idx(filename, prefix: string): string =
  ## Reads `filename` and returns it as a string with `prefix` applied.
  ##
  ## All the paths in the idx file will be prefixed with `prefix`. This is done
  ## adding the prefix to the second *column* which is meant to be the html
  ## file reference.
  result = ""
  for line in filename.lines:
    var cols = to_seq(line.split('\t'))
    if cols.len > 1: cols[1] = prefix/cols[1]
    result.add(cols.join("\t") & "\n")


proc collapse_idx(base_dir: string) =
  ## Walks `base_dir` recursively collapsing idx files.
  ##
  ## The files are collapsed to the base directory using the semi full relative
  ## path replacing path separators with underscores. The contents of the idx
  ## files are modified to contain the relative path.
  let
    base_dir = if base_dir.len < 1: "." else: base_dir
    filter = {pcFile, pcLinkToFile, pcDir, pcLinkToDir}
  for path in base_dir.walk_dir_rec(filter):
    let (dir, name, ext) = path.split_file
    # Ignore files which are not an index.
    if ext != ".idx": continue
    # Ignore files found in the base_dir.
    if dir.same_file(base_dir): continue
    # Ignore paths starting with a dot
    if name[0] == '.': continue
    # Extract the parent paths.
    let dest = base_dir/(name & ext)
    var relative_dir = dir[base_dir.len .. <dir.len]
    if relative_dir[0] == DirSep or relative_dir[0] == AltSep:
      relative_dir.delete(0, 0)
    assert(not relative_dir.is_absolute)

    echo "Flattening ", path, " to ", dest
    dest.write_file(mangle_idx(path, relative_dir))


proc change_rst_links_to_html(html_file: string) =
  ## Opens the file, iterates hrefs and changes them to .html if they are .rst.
  let html = loadHTML(html_file)
  var DID_CHANGE: bool

  for a in html.findAll("a"):
    let href = a.attrs["href"]
    if not href.isNil:
      let (dir, filename, ext) = splitFile(href)
      if cmpIgnoreCase(ext, ".rst") == 0:
        a.attrs["href"] = dir / filename & ".html"
        DID_CHANGE = true

  if DID_CHANGE:
    writeFile(html_file, $html)


proc needs_refresh(target: string, src: varargs[string]): bool =
  assert len(src) > 0, "Pass some parameters to check for"
  var TARGET_TIME: float
  try:
    TARGET_TIME = toSeconds(getLastModificationTime(target))
  except OSError:
    return true

  for s in src:
    let srcTime = toSeconds(getLastModificationTime(s))
    if srcTime > TARGET_TIME:
      return true

iterator all_rst_files(): tuple[src, dest: string] =
  for rst_name in rst_files:
    var R: tuple[src, dest: string]
    R.src = rst_name & ".rst"
    # Ignore files if they don't exist.
    if not R.src.existsFile:
      echo "Ignoring missing ", R.src
      continue
    R.dest = rst_name & ".html"
    yield R

proc nimble_install() =
  direshell("nimble install -y")
  echo "Installed."


proc doc(open_files = false) =
  ## Generates HTML documentation files.
  ##
  ## If `open_files` is true the ``open`` command will be called for each
  ## generated HTML file.
  for module in modules:
    let
      nim_file = module & ".nim"
      html_file = module & ".html"
    if not html_file.needs_refresh(nim_file): continue
    if not shell(nim_exe & " doc --verbosity:0 --index:on", module):
      quit("Could not generate html doc for " & module)
    else:
      echo "Generated " & html_file
      if open_files: shell("open " & html_file)

  # Generate html files from the rst docs.
  for rst_file, html_file in all_rst_files():
    if not html_file.needs_refresh(rst_file): continue
    let
      (dir, name, ext) = rst_file.split_file
      prev_dir = get_current_dir()

    if dir.len > 0: cd(dir)

    if not shell(nim_exe & " rst2html --verbosity:0 --index:on", name & ext):
      quit("Could not generate html doc for " & rst_file)
    else:
      change_rst_links_to_html(html_file.extract_filename)
      echo rst_file & " -> " & html_file

    cd(prev_dir)
    if open_files: shell("open " & html_file)

  collapse_idx(".")
  direShell nimExe, "buildIndex --verbosity:0 ."
  echo "All done"

proc doco() = doc(open_files = true)

proc check_docs() =
  for rst_file, html_file in all_rst_files():
    echo "Testing ", rst_file
    let (output, exit) = execCmdEx("rst2html.py " & rst_file & " > /dev/null")
    if output.len > 0 or exit != 0:
      echo "Failed python processing of " & rst_file
      echo output


proc clean() =
  nimcache_dir.remove_dir
  for path in dot_walk_dir_rec("."):
    let ext = splitFile(path).ext.to_lower
    if ext in [".html", ".idx", ".exe"]:
      echo "Removing ", path
      path.removeFile()


proc dist_doc() =
    clean()
    doc()

    let dir = dist_dir / name & "-" & argument_parser.version_str & "-docs"
    dist_dir.remove_dir
    dist_dir.create_dir

    for html_file in concat(glob("*.html"), glob("docs"/"*.html")):
      html_file.cp(dir/html_file)

    dir.pack_dir


proc build_examples() =
  ## Builds all the examples in release mode.
  with_dir("examples"):
    for cfg in walk_files("*.nim.cfg"):
      let
        nim = cfg.change_file_ext("").change_file_ext("nim")
      echo "Compiling ", nim
      dire_shell(nim_exe, "c --verbosity:0 --hints:off", nim)


proc run_tests() =
  run_test_subdirectories("tests")


proc md5() =
  ## Inspects files in zip and generates markdown for github.
  let templ = """
Add the following notes to the release info:

[See the changes log](https://github.com/gradha/argument_parser/blob/v$1/docs/changes.rst).

Binary MD5 checksums:""" % [argument_parser.version_str]
  show_md5_for_github(templ)

proc web() = switch_to_gh_pages()
proc postweb() = switch_back_from_gh_pages()

task "install", "Uses nimble to install " & name & " locally.": nimble_install()
task "i", "Alias for `install`.": nimble_install()
task "doc", "Generates HTML version of the documentation.": doc()
task "clean", "Removes temporal files, mainly.": clean()
task "ex", "Build example binaries.": build_examples()
task "test", "Runs test suite.": run_tests()

if sybil_witness.exists_file:
  task "check_doc", "Validates a subset of rst files.": check_docs()
  task "web", "Renders gh-pages, don't use unless you are gradha.": web()
  task "postweb", "Gradha uses this like portals, don't touch!": postweb()
  task "dist_doc", "Generates zip with documentation.": dist_doc()
  task "md5", "Computes md5 of files found in dist subdirectory.": md5()

when defined(macosx):
  task "doco", "Like 'doc' but also calls 'open' on generated HTML.": doco()
