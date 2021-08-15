//file management list
//advanced file management and navigation
//see bottom for details

if params.len > 0 then i1 = params[0] else i1 = null
if params.len > 1 then i2 = params[1] else i2 = null
if params.len > 2 then i3 = params[2] else i3 = null
lsCheck = true
folder = null
isFile = false
  while lsCheck == true
    globals.userList = []
    subFolderFiles = null
    subOutput = ""
    mult = 0.001
    files = null
    folderList = []
    fileList = ""
    fileMap = {}
    userSel = null
    fileCount = 0
    count = 0
    action = null
    subCheck = true
    stop = false
    noCheck = false
    fileCheck = false
    compCheck = false
    shellCheck = false
    remoteCheck = false
    printCheck = false

    if i1 == "-u" then
      noCheck = true
      lsCheck = false
    else if i1 == "h" or i1 == "help" then
      computer = get_shell.host_computer
      folder = computer.File(current_path)
      userSel = "h"
      i1 = null
    end if

    if typeof(i1) == "shell" then
      shell = i1
      shellCheck = true
    else
      shell = get_shell
    end if

    if not folder then
      if typeof(i1) == "computer" then
        computer = i1
        folder = computer.File("/")
        compCheck = true
      else if typeof(i1) == "file" then
        computer = null
        folder = i1
        fileCheck = true
      else if shellCheck then
        computer = i1.host_computer
        folder = computer.File("/")
      else if i1 and i1.hasIndex("/") then
        computer = get_shell.host_computer
        folder = computer.File(i1)
      else if i1 == null then
        computer = get_shell.host_computer
        folder = computer.File(home_dir)
      else
        computer = get_shell.host_computer
        folder = computer.File(current_path)
      end if
      if compCheck or shellCheck or fileCheck then remoteCheck = true
      if noCheck and not remoteCheck then folder = computer.File("/")
    end if


    folderBak = folder
    if folder == null then
      print("directory not found")
    else
      files = folder.get_folders + folder.get_files
      folderList = folder.get_folders
    end if

    addAction = function(action, count)
      globals.actionList = actionList + "<color=#75808A>" + count + ".<b><color=white>[" + action + "] "
      if not folder.is_binary and folder.name.indexOf(".src") > 0 then
        if count % 4 == 0 then globals.actionList = globals.actionList + "\n"
      else
        if count % 3 == 0 then globals.actionList = globals.actionList + "\n"
      end if
      actionMap[count] = action
    end function

    if isFile then
      print("\n<color=#75808A><i>editing " + folder.name + "\n")
      editCheck = true
      while editCheck == true
        globals.actionList = ""
        action = null
        count = 1
        aCount = 0
        actionMap = {}

        allActions = ["view","add", "clear", "build", "launch", "move", "copy", "rename", "delete", "perms", "empty"]

        for action in allActions
          if aCount == 0 and not folder.is_binary and folder.has_permission("r") then
            addAction(action, count)
            count = count + 1
          else if aCount > 0 and aCount <3 and not folder.is_binary and folder.has_permission("w") then
            addAction(action, count)
            count = count + 1
          else if aCount == 3 and folder.name.indexOf(".src") > 0 and folder.has_permission("w") and typeof(i1) != "computer" then
              addAction(action, count)
              count = count + 1
          else if aCount == 4 and folder.is_binary and not folder.is_folder and folder.has_permission("x") then
              addAction(action, count)
              count = count + 1
          else if aCount > 4 and aCount < 10 and folder.has_permission("w") then
            addAction(action, count)
            count = count + 1
          else if aCount == 10 and folder.is_folder and folder.has_permission("w") then
            addAction(action, count)
          end if
          aCount = aCount + 1
        end for

        globals.actionList = actionList + "<color=#75808A>0.<b><color=white>[exit]"
        print(globals.actionList)
        action = user_input("<color=#75808A>edit file: " + folder.path + "<color=white> <b>></b>")

        if action != "0" and typeof(action.to_int) == "number" then action = actionMap[action.to_int]
        if action == "view" then print("\n<color=#75808A><u><i>" + folder.name + " contents:\n" + folder.get_content + "\n")
        if action == "add" then
          editText = user_input("<color=#75808A>add content <b><color=white>></b>")
          if editText != "" then
            if editText.hasIndex("/") then
              editOut = ""
              editText = editText.split("/")
              for line in editText
                if line == editText[editText.len - 1] then
                  editOut = editOut + line
                else
                  editOut = editOut + line + "\n"
                end if
              end for
              editText = editOut
            end if
          end if
          if folder.get_content.len == 0 then
            addText = folder.set_content(folder.get_content +  editText)
          else
            addText = folder.set_content(folder.get_content +  editText)
          end if
          if addText then print("\n<color=#75808A><i>text added to " + folder.name + "\n") else print("\nfailed to add text")
        end if

        if action == "clear" then
          clear = folder.set_content("")
          if clear == 1 then print("\n<color=#75808A><i>content cleared\n") else print("\n<color=#75808A><i>bad permissions\n")
        end if

        if action == "move" then
          origFolder = folder.parent
          dest = user_input("<b><color=white>[/dest/path] ></b>")
          mvFile = folder.move(dest, folder.name)
          if mvFile == 1 then print("\n<color=#75808A><i>" + file.name + " moved to " + dest + "\n") else print("\n" + mvFile)
          folder = origFolder
          action = "0"
        end if

        if action == "delete" then
          if user_input("\n<b><color=white>this will permanently remove " + folder.name + "... continue? \n<color=#75808A>[1] or [0]<color=white><b>></b>") == "1" then
            if folder.path == "/" then
              folderBak = folder
            else
              folderBak = folder.parent
            end if
            folder.delete
            editFolderCheck = false
            folder = folderBak
            files = folder.get_folders + folder.get_files
            folderList = folder.get_folders
            action = "0"
          end if
        end if

        if action == "copy" then
          copySel = user_input("<color=white>[/dest/path] ></b>")
          print("\n")
          wait(.1)
          cp = folder.copy(copySel)
          if cp == 1 then print("\n<color=#75808A><i>" + folder.name + " copied to " + copySel + "\n")
        end if

        if action == "rename" then
          newName = user_input("<color=white>[name] ></b>")
          oldName = folder.name
          if folder.parent.path == "/" then renamePath = folder.parent.path else renamePath = folder.parent.path + "/"
          mv = folder.move(renamePath,newName)
          if mv == 1 then print("\n<color=#75808A><i>" + oldName + " renamed to " + newName + "\n") else print(mv)
          print(renamePath + newName)
          folder = computer.File(renamePath + newName)
          folderList = folder.get_folders
        end if

        if action == "build" then
          build = shell.build(folder.path, folder.parent.path)
          if build == "" then print("\n<color=#75808A> binary created: " + folder.path.split(".src")[0] + "\n" ) else print("failed")
        end if

        if action == "launch" then
          args = user_input("<color=#75808A>params <color=white></b>>")
          print("\n<color=#75808A><i>launching " + folder.name + "...")
          shell.launch(folder.path, args)
          print("\n")
        end if

        if action == "empty" then
          if user_input("\n<b><color=white>this will remove all contents of /" + folder.name + "... continue? \n<color=#75808A>[1] or [0]<color=white><b>></b>") == "1" then
            delFiles = folder.get_files + folder.get_folders
            for delFile in delFiles
              if delFile.is_folder then
                print("<color=#75808A><i>removing folder: " + delFile.name)
                delFile.delete
              else
                print("<color=#75808A><i>removing file: " + delFile.name)
                delFile.delete
              end if
            end for
            print("\n")
          end if
        end if

        if action == "perms" then
          userPrint = ""
          permPrint = ""
          ownerCheck = false
          groupCheck = false
          otherCheck = false
          permList = ""

          mainSel = user_input("\n<color=#75808A>1.<b><color=white>[grant all] <color=#75808A></b>2.<b><color=white>[remove all] <color=#75808A></b>3.<b><color=white>[custom]\n<color=white><b>></b>")

          if mainSel == "1" then
            ownerCheck = true
            groupCheck = true
            otherCheck = true
            addSel = "+"
            permList = "rwx"
            recSel = "2"
          else if mainSel == "2" then
            ownerCheck = true
            groupCheck = true
            otherCheck = true
            addSel = "-"
            permList = "rwx"
            recSel = "2"
          else if mainSel == "3" then
            userSel = user_input("<color=#75808A>1.<b><color=white>[owner] <color=#75808A></b>2.<b><color=white>[group] <color=#75808A></b>3.<b><color=white>[other]\n<color=#75808A>" + folder.path + " <color=white><b> ></b>")

            if userSel.indexOf("1") != null then ownerCheck = true
            if userSel.indexOf("2") != null then groupCheck = true
            if userSel.indexOf("3") != null then otherCheck = true

            addSel = user_input("<b><color=white>[+]</b> or <b>[-] \n<color=#75808A>" + folder.path + " <color=white><b> ></b>")
            if addSel != "-" then addSel = "+"
            permSel = user_input("<color=#75808A>1.<b><color=white>[read] <color=#75808A></b>2.<b><color=white>[write] <color=#75808A></b>3.<b><color=white>[execute]\n<color=#75808A>" + folder.path + " <color=white><b> ></b>")
            for each in permSel
              if each == "1" then permList = "r"
              if each == "2" then permList = permList + "w"
              if each == "3" then permList = permList + "x"
            end for
            if folder.is_folder then recSel = user_input("<color=#75808A>1.<b><color=white>[individual] <color=#75808A>2.<b><color=white>[recursive] \n<color=#75808A>" + folder.path + " <color=white><b> ></b>") else recSel = "1"
          end if
          print("\n")
          if ownerCheck then
            perms = "u" + addSel + permList
            if recSel == "2" then
              permChange = folder.chmod(perms, 1)
            else
              permChange = folder.chmod(perms)
            end if
            if permChange == "" then print("<color=#75808A><i>u" + addSel + permList)
          end if

          if groupCheck then
            perms = "g" + addSel + permList
            if recSel == "2" then
              permChange = folder.chmod(perms, 1)
            else
              permChange = folder.chmod(perms)
            end if
            if permChange == "" then print("<color=#75808A><i>g" + addSel + permList)
          end if

          if otherCheck then
            perms = "o" + addSel + permList
            if recSel == "2" then
              permChange = folder.chmod(perms, 1)
            else
              permChange = folder.chmod(perms)
            end if
            if permChange == "" then print("<color=#75808A><i>o" + addSel + permList)
          end if
          if permChange == "" then print("\n<color=#75808A>permissions updated\n")
        end if

        if action == "0" or action == "x" then
          editCheck = false
          isFile = false
          if not folder.is_folder then folder = folder.parent
        end if

      end while

      if typeof(i1) == "file" and not folder.is_folder then folder = folder.parent

      files = folder.get_folders + folder.get_files
      folderList = folder.get_folders
      folderBak = folder
    end if

    count = 0
    for file in files
      count = count + 1
      fileMap[count] = file
    end for

    count = 0
    if not noCheck then print("\n<color=#b4ebfa>|<u>. |" + folder.permissions + "<b><u>|" + folder.owner[0] + folder.group[0] + "|  <b>" + folder.path + "            .</u>|")
    if folderList and not noCheck then
      print("\n<color=#b4ebfa><b><u>| folders: |</u></b>")
    end if

    for file in files

      subFolder = null
      subOutput = ""
      subFolderFiles = null
      name = file.name
      filePerms = file.permissions
      owner = file.owner[0]
      size = file.size
      sizeBak = file.size
      group = file.group[0]
      path = file.path
      if file.path == "/" then
        pPath = "/"
      else
        pPath = file.parent.path
      end if
      userDelList = []
      fileCount = fileCount + 1

      if file.is_folder then
        if typeof(i1) == "file" then
          subFolder = i1
        else
          subFolder = computer.File(path)
        end if

        subFolderFiles = subFolder.get_folders + subFolder.get_files
        if not noCheck then print("<color=#75808A><b>" + fileCount + ".<color=white></b><u>|" + filePerms + "<b><u>|" + owner + group + "| " + file.name + " |</u>")
      else
        subOutput = "<color=#75808A><b>" + fileCount + ".<color=white></b><u>|" + filePerms + "<b><u>|" + owner + group + "| " + pPath + " |</u>"
      end if

      if path != "/bin" then
        if subFolderFiles == null then
          subFolderFiles = files
          subCheck = false
        end if

        count = 0

        if subFolderFiles != null then
          for subFolderFile in subFolderFiles
            count = count + 1
            if not subFolderFile.is_folder then isFolder = ("") else isFolder = ("|_|")
            subNameFile = subFolderFile.name
            subPerms = subFolderFile.permissions
            owner = subFolderFile.owner[0]
            group = subFolderFile.group[0]
            size = subFolderFile.size.to_int
            if path == "/var" then
              if subNameFile == "system.log" then
                globals.logSize = size
                globals.logName = subNameFile
              end if
            end if
            if path == "/home" then
              if subNameFile != "guest" and subNameFile != "root" then
                userList = userList + [subNameFile]
              end if
            end if

            if size > 1000 then
              size = floor(size * mult)
              if size > 1000 then
                size = floor(size * mult) + "mb"
              else
                size = size + "kb"
              end if
            else
              size = size + "b"
            end if
            if size == "0b" then size = "-"
            subOutput = subOutput + "<color=#75808A> |" + subPerms + "|" + owner + group + "| " + subNameFile + " " + size + " " + isFolder + "\n"
          end for
        end if
        if not file.is_folder then


          size = sizeBak.to_int
          if size > 1000 then
            size = floor(size * mult)
            if size > 1000 then
              size = floor(size * mult) + "mb"
            else
              size = size + "kb"
            end if
          else
            size = size + "b"
          end if
          if size == "0b" then size = "-"

          fileList = fileList + "<color=#75808A>" + fileCount + ".</b>|" + file.permissions + "|" + owner + group + "| <color=white>" + name + " <color=#75808A>" + size + " " + "\n"
        end if

      end if

      if not noCheck and subCheck then
        if file.path != "/bin" and subOutput.len < 1 then subOutput = "    <color=#75808A><i>(empty)"
        print(format_columns(subOutput))
        subOutput = ""
      end if
    end for
    globals.userList = userList

    if i1 == "-u" then
      print(userList)
    end if

    if files.len < 1 then print("                    <color=#75808A><i>(empty)\n")

    if not noCheck then
      wait(.5)

      if fileList then
        print("\n<color=#b4ebfa><b><u>| files: |</u></b>")
        print(format_columns(fileList))
      end if

      if folder and i2 != "-p" then
        if folder and folder.len > 0 then
          if not noCheck then
            count = 0
            cn = 0
            folderSel = ""

            if folderList then print("\n<u><b><color=#b4ebfa>[folders]")
            for folder in folderList
              count = count + 1
              cn = cn + 1
              folderSel = folderSel + "<color=#75808A>" + count + ".<color=white><b>[/" + folder.name + "] "
              if cn == 5 and folderList.len > count then
                cn = 0
                folderSel = folderSel + "\n"
              end if
            end for
            if folderSel then print(folderSel + "\n")

            cn = 0
            fileSel = ""
            fileList = folderBak.get_files

            if fileList and not noCheck then
              print("<u><b><color=#b4ebfa>[files]")
              for file in fileList
                count = count + 1
                cn = cn + 1
                fileSel = fileSel + "<color=#75808A>" + count + ".<b><color=white>[" + file.name + "] "
                if cn == 3 and folderList.len > count then
                  cn = 0
                  fileSel = fileSel + "\n"
                end if
              end for
            end if
            if fileSel then print(fileSel + "\n")
          end if
        end if
      end if

      folder = folderBak

      if not noCheck and not userSel then
        if i2 == "-p" then userSel = "x" else userSel = null
        if not userSel then userSel = user_input("<color=#75808A>" + folder.path + "<color=white> <b>></b>")


        if userSel == "x" or userSel == "exit" then
          lsCheck = false
          continue

        else if userSel == "*" then
          if remoteCheck then
            print("unavailable")
          else
            folder = computer.File(home_dir)
          end if

        else if userSel == "+" and folder.has_permission("w") then
          nameAccept = false
          typeAccept = false
          while not typeAccept
            print("<color=#75808A>1.<b><color=white>[file]</b> <color=#75808A>2.<color=white><b>[folder]</b>")
            selType = user_input("<color=#75808A>type <color=white><b>[#] ></b>")
            if selType == "0" then break
            if selType == "1" or selType == "2" then typeAccept = true
          end while

          while not nameAccept
            if selType == "0" then break
            selName = user_input("<color=#75808A>name <color=white><b>></b>")

            if selName.indexOf(" ") == null then
              nameAccept = true
            else
              print("alpha/num only")
              continue
            end if

            if selType == "1" then
              editText = user_input("<color=#75808A>content <color=white><b>></b>")

              if editText.hasIndex("/") then
                editOut = ""
                editText = editText.split("/")
                for line in editText
                  editOut = editOut + line + "\n"
                end for
                editText = editOut
              end if

              computer.touch(folder.path,selName)
              newFile = computer.File(folder.path + "/" + selName)
              newFile.set_content(editText)
            end if

            if selType == "2" then computer.create_folder(folder.path,selName)
          end while

        else if userSel == "/*" then
          isFile = true


        else if userSel == "-" and folder.has_permission("w") then
          delSel = user_input("<color=#75808A>delete <color=white><b>[#]</b> <color=#75808A>or <color=white><b>[#.#.#] ></b>")
          if delSel.hasIndex(".") then userDelList = delSel.split(".") else userDelList = null

          for sel in userDelList
            if typeof(sel.to_int) == "number" and sel.to_int != 0 then
              if typeof(i1) == "file" then
                file = i1(fileMap[sel.to_int])
              else
                file = computer.File(fileMap[sel.to_int].path)
              end if
              file.delete
            end if
          end for
        end if
      end if

      if typeof(userSel.to_int) == "number" then
        userSel = userSel.to_int
        if userSel != null then
          if userSel == 0 then
            isFile = false
            if folder.path == "/" then
                folder = computer.File("/")
            else
              if computer != null then
                folder = computer.File(folder.parent.path)
              else
                folder = i1.parent
                print(folder)
              end if
            end if
          else
            if fileMap.hasIndex(userSel) then
              if typeof(i1) == "file" then
                folder = folder(fileMap[userSel])
              else if i2 == "-f" then
                return computer.File(fileMap[userSel].path)
              else
                folder = computer.File(fileMap[userSel].path)
              end if
              if not folder.is_folder then isFile = true
            else
              folder = computer.File(folder.path)
            end if
          end if
        end if
      else
        if userSel == "/" then
            folder = computer.File("/")
        end if
        if userSel.hasIndex("/") and not userSel.indexOf("*") and userSel.len > 1 then
            folder = computer.File(userSel)
        end if

        if userSel == "help" or userSel == "h" then
          print("\n<u><color=white>|.     <color=#e141fa><b>corTechs </b>[file managment list]</i><color=white>     .|</u>")
          print("<color=white><b>launch options:")
          print("   <color=#75808A><color=#75808A><b>fml <color=white><b>[/folder/path]</b><color=#75808A> - launch directly to path</i>")
          print("   <color=#75808A><color=#75808A><b>fml <color=white><b>[/folder/path] [-p]</b><color=#75808A> - print path contents</i>")
          print("   <color=#75808A><color=#75808A><b>fml <color=white><b>[-u]</b><color=#75808A> - print local users</i>")
          print("\n<b><color=white>usage:</b>")
          print("   <color=#75808A>edit functions are available based on file type and privileges")
          print("   <color=#75808A>delete multiple files/folders with <b><color=white>[-]</b><color=#75808A> (. separator [#.#.#])")
          print("   <color=#75808A>navigate with <color=white><b>[#]</b> <color=#75808A>or directly to path with <color=white><b>[/folder/path]</b>")
          print("   <color=#75808A>edit current folder with <color=white><b>[/*]</b>")
          print("   <color=#75808A>edit file: select file with <color=white><b>[#]</b><color=#75808A> for available edit options")
          print("      <color=#75808A>leave input blank for no selection/no changes")
          print("      <color=#75808A>use / for new line when adding content")
          print("      <color=#75808A>select text/.src files to view/add/remove text")
          print("      <color=#75808A>select .src files to build")
          print("      <color=#75808A>select binary files to launch")
          print("   <color=#75808A>permissions: no separator for multiple selections")
          print("      <color=#75808A>ie: [123] to select user, group, and other")
          print("      <color=#75808A>     [23] to select group and other")
          print("\n<b><color=white>controls:</b>")
          print("<b><color=white>   [#]</b><i><color=#75808A> select")
          print("<b><color=white>   /*</b><i><color=#75808A> edit current folder")
          print("<b><color=white>   *</b><i><color=#75808A> move to home directory")
          print("<b><color=white>   /</b><i><color=#75808A> return to top")
          print("<b><color=white>   0</b><i><color=#75808A> up folder/cancel")
          print("<b><color=white>   +</b><i><color=#75808A> add file/folder")
          print("<b><color=white>   -</b><i><color=#75808A> delete files/folders (.)")
          print("<b><color=white>   h</b><i><color=#75808A> help")
          print("<b><color=white>   x</b><i><color=#75808A> exit")
          print(" ")
          user_input(" <color=#75808A><i>continue <color=white><b>>")
          userSel = null
        end if
      end if
    end if
  end if
end while
