
function! vim_seq_diag#Generate_diagram(pluginPath)
  let buf = getline(1, '$')
  "for substitute here needs 4 backslashs, but remember it's inside of double
  "quota string, so actually 8 backslashs literally
  call map(buf, 'substitute' . "(v:val, '\\', '\\\\\\\\', 'g')")
  call map(buf, 'substitute' . "(v:val, '`', '\\\\`', 'g')")

  let tmpl = a:pluginPath . '/tmpl.html'
  let tmpDir = "/tmp/vim-js-seq/"
  if exists("g:generate_diagram_tmp_dir")
    let tmpDir = g:generate_diagram_tmp_dir
  endif
  
  call system("mkdir " . tmpDir)
  "TODO check file already exists?
  let copycommand = "cp "
  let pluginPath = a:pluginPath . '/'
  if has("windows")
	let copycommand = "copy /Y "
	let pluginPath = a:pluginPath . '\'
	let tmpDir = substitute(tmpDir, '/', '\', 'g')
	let tmpl = substitute(tmpl, '/', '\', 'g')
  endif
  call system(copycommand . pluginPath . 'underscore-min.js' . " " . tmpDir)
  call system(copycommand . pluginPath . 'raphael-min.js' . " " . tmpDir)
  call system(copycommand . pluginPath . 'sequence-diagram-min.js' . " " . tmpDir)
  call system(copycommand . pluginPath . 'browser.min.js' . " " . tmpDir)

  let out = tmpDir . "out.html"
  call system(copycommand . tmpl . " " . out)

  let originTab = tabpagenr()
  execute "tabe " . out
  "append the theme first to avoid the position of placeholder changes
  if g:generate_diagram_theme_hand == 1
    call append(17, ["'hand'"])
  else
    call append(17, ["'simple'"])
  endif

  call append(15, buf)
  silent :w!
  :bd
  execute "tabn " . originTab 

  if has('mac')
    call system("osascript " . a:pluginPath . '/applescript/active.scpt')
  elseif has("windows")
	echo "HTML file generated in: " . out
  else
    call system("xdg-open " . out)
  endif
endfunction

