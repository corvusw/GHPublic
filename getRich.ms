//launch with no params for collection w/ no decipher
//params:
//[a] - auto decipher on discovery
//[d] - decipher all encrypted accounts in bank.db
//encrypted/deciphered accounts can be mixed in bank.db

metaxploit = include_lib("/lib/metaxploit.so")
if not metaxploit then metaxploit = include_lib(parent_path(program_path) + "/metaxploit.so")
if not metaxploit then exit("\n<color=white>no metaxploit")
cryptools = include_lib("/lib/crypto.so")
if not cryptools then cryptools = include_lib(parent_path(program_path) + "/crypto.so")
if not cryptools then print("\n<color=white>no cryptools")
if params.len > 0 then decode = true else decode = false
c = get_shell.host_computer
count = 0
metaLib = null
globals.deviceList = []
c.touch(current_path, "bank.db")
bankFile = c.File(current_path + "/bank.db")

rng = function()
  return floor((rnd * 255) + 1)
end function

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

getRoot = function(file)
        while file.name != "/"
		file = file.parent
	end while
        return file
end function

FakeComputer = {}
FakeComputer.result = null

handleFile = function(file)
	FakeComputer.result = file
	FakeComputer.File = function(path)
		file = self.result
		file = getRoot(file)
		folders = getFolders(file)
		for f in folders
			if f.path == path then
				file = f
				continue
			end if
			if f.get_files then
				for n in f.get_files
					if n.path == path then
						file = n
						continue
					end if
				end for
			end if
		end for
		return file
	end function
end function

getMeta = function(decode)
  print("scanning...")
  net_session = null
  passwd = "cor"
    while true
      clear_screen
      globals.deviceList = []
      ports = []
      ip = rng + "." + rng + "." + rng + "." + rng
      if is_valid_ip(ip) then
        router = get_router(ip)
        if router then
          globals.deviceList = router.devices_lan_ip
          ports = router.used_ports
          if ports and ports.len > 0 then
            for port in ports
              if port != 0 then port = port.port_number
              net_session = metaxploit.net_use(ip,port)
              if net_session then
                metaLib = net_session.dump_lib
                if metaLib then
              		libInfo = metaLib.lib_name + " v." + metaLib.version
              		vulnMap = {}
              		fileMap = {}
            			c.touch(current_path, "vuln.db")
            			file = c.File(current_path + "/vuln.db")
              		content = file.get_content
              		if content.len > 80000 then print("**database size limit reached**")
              		if content.indexOf(libInfo) != null then
              			libIndex = content.indexOf(libInfo)
              			memFile = slice(content, libIndex, content.indexOf(">",libIndex)).split(char(10))
              			memFile.remove(0)
              			memFile.remove(memFile.len - 1)
              			for line in memFile
              				line = line.split(":")
              				mem = line[0]
              				values = line[1].split(" ")
              				for value in values
            				    result = metaLib.overflow(mem, value, passwd)
                        if typeof(result) == "shell" or typeof(result) == "computer" or typeof(result) == "file" then
                          if typeof(result) == "file" then
                            handleFile(result)
                            computer = new FakeComputer
                          else if typeof(result) == "computer" then
                            computer = result
                          else if typeof(result) == "shell" then
                            computer = result.host_computer
                          end if
                          for file in computer.File("/home").get_folders
                            if file.name != "guest" then
                              if decode then
                                cont = computer.File(file.path + "/Config/Bank.txt").get_content
                                cont = cont.split(":")
                                if bankFile.get_content.indexOf(cont[0]) == null then password = cryptools.decipher(cont[1])
                                if bankFile.get_content.indexOf(cont[0]) == null then bankFile.set_content(bankFile.get_content + "\n" + cont[0]+ ":" + password)
                              else
                                cont = computer.File(file.path + "/Config/Bank.txt").get_content
                                cont = cont.split(":")
                                if bankFile.get_content.indexOf(cont[0]) == null then bankFile.set_content(bankFile.get_content + "\n" + computer.File(file.path + "/Config/Bank.txt").get_content)
                              end if
                            end if
                          end for
                        end if
              				end for
              			end for
              		else
              			if metaLib then print("scanning library: " + libInfo + "\n")
              			memory = metaxploit.scan(metaLib)
              			if not memory then print("no exploits detected.")
              			for mem in memory
              				address = metaxploit.scan_address(metaLib, mem).split("Unsafe check:")
              				userList = null
              				for add in address
              					if add == address[0] then continue
              					value = add[add.indexOf("<b>")+3:add.indexOf("</b>")]
              					if vulnMap.hasIndex(mem) then
              						if vulnMap[mem].indexOf(value) == null then
              							vulnMap[mem] = (vulnMap[mem] + [value])
              						end if
              					else
              						vulnMap[mem] = [value]
              					end if
              						result = metaLib.overflow(mem, value, passwd)
              				end for
              			end for
              			vulnCont = ""
            				for vuln in vulnMap
            					value = vuln.value.join(" ")
            					vulnCont = vulnCont + vuln.key + ":" + value + char(10)
            				end for
              			if content.indexOf(libInfo) == null then file.set_content(content + char(10) + libInfo + char(10) + vulnCont + ">")
              		end if
                end if
              end if
            end for
          end if
        end if
      end if
    end while
  end if
end function

decodeFile = function()
  data = bankFile.get_content.split("\n")
  for line in data
    if line.len > 30 then
    lineCont = line.split(":")
    password = cryptools.decipher(lineCont[1])
    cont = bankFile.get_content
    cont.remove(line)
    bankFile.set_content(cont + "\n" + lineCont[0]+ ":" + password)
    end if
  end for
end function

if params.len > 0 then
  if params[0] == "d" then
    decodeFile
  else if params[0] == "a" then
    getMeta(true)
  end if
else
  getMeta(false)
end if
