//secure system
// ONLY RUN 'home' on your home PC. all others could lock you out permanently!

if params.len > 0 then i1 = params[0] else exit("usage: sec [home/h] or [server/s] or [remote/r]")
  if i1 == "home" or i1 == "h" then home = true else home = null
if params.len > 1 then i2 = params[1] else i2 = null
  if i2 == "server" or i2 == "s" then server = true else server = null
if params.len > 2 then i3 = params[2] else i3 = null
  if i3 == "remote" or i3 == "r" then remote = true else remote = null
  funct = ""
  if home then
    funct = "[home]"
  else if server then
    funct = "[server]"
  else if remote then
    funct = "[remote]"
  end if

  passFileCheck = function(folder)
		if folder.name == "etc" then
			print("checking /etc")
			for file in folder.get_files
				if file.name == "passwd" then
					passFile = get_shell.host_computer.File("/etc/passwd")
					del = passFile.delete
					if del == "" then print("/etc/passwd removed") else print(del)
				end if
			end for
		end if

		if folder.name == "root" then
			print("checking /root/Config")
			for file in folder.get_folders
				if file.name == "Config" then
					cFiles = get_shell.host_computer.File("/root/Config").get_files
					for cFile in cFiles
						if cFile.name != "Map.conf" then del = cFile.delete else del = null
						if del != null then
							if del == "" then print(cFile.name + " removed") else print(del)
						end if
					end for
				end if
			end for
		end if
	end function

  main = get_shell.host_computer.File("/")
  if i2 then main = i2.File("/")

  folders = main.get_folders
  files = main.get_files

  main.set_group("root",1)
  main.set_owner("root",1)

  print("\nsecuring <b>" + funct + "</b>")

  if folders then
    for folder in folders
      fpath = folder.path

        folder.set_group("root",1)
        folder.set_owner("root",1)
        folder.chmod("g+rwx", 1)
        folder.chmod("o+rwx", 1)
        folder.chmod("u+rwx", 1)
        print("resetting perms in " + fpath)

      if home then
        folder.chmod("o-rwx", 1)
        folder.chmod("g-rwx", 1)
        folder.chmod("u-rwx", 1)
        if fpath == "/bin" or fpath == "/usr" or fpath == "/home" then
          folder.chmod("g-rwx", 1)
          folder.chmod("g+rx",1)
        end if
        folder.chmod("u+rwx", 1)
        if folder.name == "home" then
          homeFolders = folder.get_folders
          for homeFolder in homeFolders
            if homeFolder.name == "guest" then
              guestDel = homeFolder.delete
              if guestDel == 1 then print("guest folder removed") else print(guestDel)
            end if
          end for
        end if
        passFileCheck(folder)

      else if server then
        folder.chmod("g-rwx", 1)
        folder.chmod("o-rwx", 1)
        folder.chmod("u-rwx", 1)
          if folder.name == "home" then
            homeFolders = folder.get_folders
            for homeFolder in homeFolders
              if homeFolder.name == "guest" then
                guestDel = homeFolder.delete
                if guestDel == 1 then print("guest folder removed") else print(guestDel)
              end if
            end for
          end if
          passFileCheck(folder)

      else if remote then
        main.set_group("other",1)
        main.set_owner("other",1)
        folder.chmod("g+rwx", 1)
        folder.chmod("o+rwx", 1)
        folder.chmod("u+rwx", 1)
      end if
    end for
  else
    print("can't access folders")
  end if
