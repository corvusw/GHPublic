metaxploit = include_lib("/lib/metaxploit.so")
if not metaxploit then metaxploit = include_lib(parent_path(program_path) + "/metaxploit.so")
if not metaxploit then print("no metaxploit")
shell = get_shell
computer = shell.host_computer
currentVer = null
metaLib = metaxploit.load("/root/metaxploit.so")
memVer = metaLib.version
oldVer = null
clear_screen
while true
  clear_screen
  shell.apt_install("metaxploit.so")
  file = computer.File("/lib/metaxploit.so")
  file.move("/root")
  file.chmod("o-rwx")
  file.chmod("g-rwx")
  file.chmod("u-rwx")
  clear_screen
  print("\n\n<u><color=white>monitoring metaxploit</color></u>")
  metaLib = metaxploit.load("/root/metaxploit.so")
  localVer = metaLib.version
  if memVer != localVer then
    print("**metaxploit.so updated**")
    oldVer = memVer
    memVer = localVer
  else
    print("<color=#505050>version: " + localVer)
    if oldVer then print("<color=#505050> old version: " + oldVer + "\n")
  end if
  wait(5)
end while
