checkUser = function(result)
	user = ""
	rfile = null
	if typeof(result) == "computer" then
		file = result.File("/home")
		rfile = result.File("/root")
	else if typeof(result) == "shell" then
		file = result.host_computer.File("/home")
		rfile = result.host_computer.File("/root")
	end if
	if rfile and rfile.has_permission("r") then
		user = "root"
	else if rfile then
		for folder in file.get_folders
			if folder.has_permission("r") and folder.name != "guest" then user = folder.name
		end for
	end if
	if typeof(result) == "file" then
		file = result
		if file.name != "/" then
			file = file.parent
			while file.name != "/"
				file = file.parent
			end while
		end if
		for folder in file.get_folders
			if folder.name == "root" then
				if folder.has_permission("r") then user = "root"
			end if
			if folder.name == "home" and user != "root" then
				for sub in folder.get_folders
					if sub.has_permission("r") and sub.name != "guest" then user = sub.name
				end for
			end if
		end for
	end if
	if user == "" then user = "guest"
	return user
end function
