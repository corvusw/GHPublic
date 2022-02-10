
//handleFile: use 'computer.File([path] or "/file/path")' with file objects
//use handleFile(file) to set FakeComputer
//initialize with computer = new FakeComputer
//then use computer.File("file/path")
//use getFolders(file) to get a list of all folders/sub of the passed file object

//returns a list of all folders/subfolders of the passed file object
getFolders = function(file)
	folders = []
	nFolders = []
	for folder in file.get_folders
		folders = folders + [folder]
		nFolders = nFolders + [folder.path]
	end for
	for r in range(10)
		for folder in folders
				for subFolder in folder.get_folders
					if nFolders.indexOf(subFolder.path) == null then
						folders = folders + [subFolder]
						nFolders = nFolders + [subFolder.path]
					end if
				end for
		end for
	end for
	return folders
end function

//returns the root file of the passed file object
getRoot = function(file)
        while file.name != "/"
		file = file.parent
	end while
        return file
end function

//set up fake computer object
FakeComputer = {}
//initialize fake computer result paramater (result = exploited file obj)
FakeComputer.result = null

//creates and assigns fake computer object
handleFile = function(file)
	//set fake computer paramater to passed file object
	FakeComputer.result = file
	//create fake computer object .File function
	FakeComputer.File = function(path)
		//sets file to passed file obj
		file = self.result
		//sets file to root of passed file system
		file = getRoot(file)
		//get a list of all folders on file system
		folders = getFolders(file)
		//loops all folders looking for requested directory
		for f in folders
			if f.path == path then
				file = f
				continue
			end if
			//searches all directories for requested file
			if f.get_files then
				for n in f.get_files
					if n.path == path then
						file = n
						continue
					end if
				end for
			end if
		end for
		//returns requested file
		return file
	end function
end function


//ie:
//result = meta.overflow(mem,val)
//handleFile(result)
//computer = new FakeComputer
//passFile = computer.File("/etc/passwd")
//print(passFile.get_content)
