c = get_shell.host_computer
var = c.File("/var/")
print("\naccessing logs...")
c.touch("/var","system.bak")
file = c.File("/var/system.log")
if file then file.delete
bak = c.File("/var/system.bak")
if bak then
  bak.set_content("\n\n\n\n\n\n\n                      :)")
  bak.move("/var", "system.log")
end if
wait(.2)
file = c.File("/var/system.log")
if file then
  if file.size < 1000 then
    print("\n*logs corrupted*\n")
    file.chmod("u+rw", 1)
    file.chmod("g+rw", 1)
    file.chmod("o+rw", 1)
  else
    ("\nlog **corruption failed**\n")
  end if
end if
