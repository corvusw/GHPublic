//resets global libraries
//useful for creating vulnerabilities for missions
// or hunting secure libraries

//launch with 'reset [port# or /file/path.so]'

//use file path for local attacks and port for random remote attacks
//must attack the most recent version of target library
//must have the most recent version of metaxploit.so

metaxploit = include_lib("/lib/metaxploit.so")
if not metaxploit then metaxploit = include_lib(parent_path(program_path) + "/metaxploit.so")
if not metaxploit then print("<color=white>no metaxploit")

c = get_shell.host_computer
count = 0
metaLib = null
globals.deviceList = []
if params.len > 0 then i1 = params[0] else i1 = user_input("<color=white>[/file/path.so(local)] or [port#] >")

rng = function()
  return floor((rnd * 255) + 1)
end function

getMeta = function()
  print("scanning...")
  net_session = null
  if typeof(i1.to_int) != "number" then
    return metaxploit.load(i1)
  else
    while true
      ip = rng + "." + rng + "." + rng + "." + rng
      if is_valid_ip(ip) then
        router = get_router(ip)
        if router != null then
          globals.deviceList = []
          globals.deviceList = router.devices_lan_ip
          ports = router.used_ports
          if ports.len > 0 then
            for port in ports
              net_session = null
              if router.port_info(port).hasIndex(i1 + "\n") then
                net_session = metaxploit.net_use(ip,i1.to_int)
                if net_session then
                  return net_session.dump_lib
                  continue
                end if
              end if
            end for
          end if
        end if
      end if
    end while
  end if
end function

libReset = function(lib)
  metaLib = getMeta
  if metaLib then
    while true
      if count > 0 then
        vCheck = true
        if count % 100 then clear_screen
        while vCheck
          metaLib = getMeta
          if metaLib.version != memVer then
            if count != 1 then exit("\n<color=white>" + metaLib.lib_name + " updated to " + " v." + metaLib.version + "\n")
            metaLib = getMeta
          else
            vCheck = false
          end if
        end while
        libInfo = metaLib.lib_name + " v." + metaLib.version
        print("<color=white>scanning " + libInfo + "...")
      else if count == 0 then
        vCheck = false
        while not vCheck
          libInfo = metaLib.lib_name + " v." + metaLib.version
          print("<color=white>scanning " + libInfo + "...")
          if user_input("<color=white>correct version? [y/n] >") == "n" then
            metaLib = getMeta
          else
            memVer = metaLib.version
            vCheck = true
          end if
        end while
      end if
      vulnMap = {}
      fileMap = {}
      count = count + 1
      c.touch(current_path, "vuln.db")
      file = c.File(current_path + "/vuln.db")
      content = file.get_content
      if content.indexOf(libInfo) != null then
        libIndex = content.indexOf(libInfo)
        memFile = slice(content, libIndex, content.indexOf(">",libIndex)).split(char(10))
        memFile.remove(0)
        memFile.remove(memFile.len - 1)
        if i1.hasIndex("/") then num = 100000 else num = 10
        for x in range(num)
          for line in memFile
            line = line.split(":")
            mem = line[0]
            values = line[1].split(" ")
            for value in values
              if i1.to_int == 0 and globals.deviceList.len > 0 then
                for device in globals.deviceList
                  print(device)
                  result = metaLib.overflow(mem, value, device)
                end for
              else
                result = metaLib.overflow(mem, value, "pass")
              end if
            end for
          end for
        end for
      else
        memory = metaxploit.scan(metaLib)
        if not memory then print("no exploits detected.")
        password = null
        for mem in memory
          address = metaxploit.scan_address(metaLib, mem).split("Unsafe check:")
          userList = null
          for add in address
            if add == address[0] then continue
            value = add[add.indexOf("<b>")+3:add.indexOf("</b>")]
            if i1.to_int == 0 and globals.deviceList.len > 0 then
              for device in globals.deviceList
                print(device)
                result = metaLib.overflow(mem, value, device)
              end for
            else
              result = metaLib.overflow(mem, value, "pass")
            end if
            if result then
              if vulnMap.hasIndex(mem) then
                if vulnMap[mem].indexOf(value) == null then
                  vulnMap[mem] = (vulnMap[mem] + [value])
                end if
              else
                vulnMap[mem] = [value]
              end if
            end if
          end for
        end for
        vulnCont = ""
          for vuln in vulnMap
            value = vuln.value.join(" ")
            vulnCont = vulnCont + vuln.key + ":" + value + char(10)
          end for
        if content.indexOf(libInfo) == null then file.set_content(content + char(10) + libInfo + char(10) + vulnCont + ">")
      end if
    end while
  end if
end function

libReset(i1)
