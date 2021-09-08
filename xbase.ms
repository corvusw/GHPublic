//xbase
//crossbase database management system
//create, edit, view databases
//template and custom databases
//connect to remote databases
//user based permissions

//set launch params
if params.len > 0 then i0 = params[0] else i0 = null
if params.len > 1 then i1 = params[1] else i1 = null

//globals
globals.accepted = 0
globals.actionMap = {}
globals.xbUserContent = []

//formatting
br = (char(10))
tab = (char(9))
white = "<color=white>"
red = "<color=#990000>"
grey = "<color=#75808A>"
green = "<color=#1aff1a>"
blue = "<color=#66ccff>"
pink = "<color=#e141fa>"
unavailable = grey + "<s>"
back = "[x] <b>back</b>"
help = "[h] <b>help</b>"
arrow = white + "<b>></b></color>"

//types
users = "users"
passwords = "passwords"
servers = "servers"
players = "players"
exploits = "exploits"
custom = "custom"

//userLevels
admin = "admin"
guest = "guest"
user = "user"

//config
shell = get_shell
computer = shell.host_computer
computer.create_folder(current_path, "xbase")
baseFolder = computer.File(current_path + "/xbase")
basePath = baseFolder.path
computer.touch(current_path + "/xbase", "users.xb")
xbUserFile = computer.File(basePath + "/users.xb")


/////////////////////
//// encryption ////
///////////////////

encode = function(p)
	out = []
	output = ""
	g = globals
	g.u = []
	ch = ""
	t = function(k)
		ch = bitwise("^", 37, k)
		u.push(ch)
		return ch
	end function
	n = 37
	x = floor((rnd(n) * 50) + 1)
	for i in p
		o = t(i.code) + x
		c = (o) + "."
		out.push(c)
	end for
	output = out.join("")
	return output
end function

decode = function(pass)
	p = pass.split(".")
	out = []
	output = ""
	g = globals
	g.u = []
	ch = ""
	t = function(k)
		ch = bitwise("^", k, 37)
		u.push(ch)
		return ch
	end function
	n = 37
	x = floor((rnd(n) * 50) + 1)
	for i in p
		if i and i != "" then
			o = t(i.to_int - x)
			out.push(char(o))
		end if
	end for
	output = out.join("")
	return output
end function


//////////////////
//// objects ////
////////////////

//create xb object and default attributes
xb = {}
xb.type = null //types: users, passwords, servers, players, exploits, custom
xb.userLevel = guest //userLevels: admin, [userName], guest

//xbUser object
xbUser = new xb
xbUser.file = get_shell.host_computer.File(current_path + "/xbase/users.xb")

xbUser.get = function(userName)
  file = self.file
  content = file.get_content

  if not userName then
    userContent = content.split(">")[1:]
    count = 0
    userList = []
    for user in userContent
      if user.len > 1 then
        editList = []
        count = count + 1
        data = user.split(br)
        for d in data
          if d.len > 1 then
            editList = editList + [d]
          end if
        end for
        name = editList[0].split(":")[1]
        pass = editList[1].split(":")[1]
        level = editList[2].split(":")[1]
        userList = userList + [br + blue + "[" + count + "] " + white + name + grey + " (" + level + ")"]
      end if
    end for
  else
    userPos = content.indexOf("userName:" + userName) - 1
    userData = slice(content, userPos + 1, content.indexOf(">",userPos)-1).split(br)
    passwd = decode(userData[1].split(":")[1])
    level = userData[2].split(":")[1]
    userList = [userName, passwd, level]
  end if
  return userList
end function


xbUser.add = function(userName, userPass, userLevel)
  print(grey + "<i>adding new user: " + userName + " [" + userLevel + "]" + br)
  file = self.file
  newContent = "userName:" + userName + br + "userPass:" + encode(userPass) + br + "userLevel:" + userLevel + br + ">" + br
  file.set_content(file.get_content + newContent)
  wait(1)
end function

xbUser.remove = function(userName)

end function



////////////////////
//// functions ////
//////////////////

//check for launch params or get user input for user/pass
//returns [userName, userPass]
login = function(userName, userPass)
  if not i0 then userName = user_input(grey + "user " + arrow) else userName = i0
  if not i1 then userPass = user_input(grey + "pass " + arrow, 1) else userPass = i1
  return [userName, userPass]
end function

//checks if user exists and verifies password
//returns 1/true or 0/false
//sets globals.userData = [userName, userPass, userLevel] if correct credentials
userCheck = function(userName, userPass)
  xbUserContent = xbUserFile.get_content
  if xbUserContent.indexOf(userName) > 0 then
    xbData = xbUser.get(userName)
    passwd = xbData[1]
    level = xbData[2]

    if  passwd == userPass then
      globals.userData = [userName, passwd, level]
      print(br + green + "user found. logging in...")
      wait(.5)
      globals.accepted = 1
      return 1
    else
      print(br + red + "wrong password")
      wait(.5)
      globals.accepted = 0
      return 0
    end if
  else
    print(br + red + "user not found")
    wait(.5)
    globals.accepted = 0
    return 0
  end if
end function

//generates string for creating database type
typeStr = function(type)
  return "xbType:" + type + br + ">"
end function

//generates line based on reference length
lineStr = function(ref)
  return "<u>." + " " * (ref.len - 25) + "."
end function

//generates page header strings
headerStr = function(text, sub)
  if sub then
    return (grey + "<u>.   </u>    " + text + "    <u>    .")
  else
    return (white + "<u>.   </u>    " + text + "    <u>    .")
  end if
end function

//returns file content of associated .xb file type
//returns null if not found/empty
getContent = function(type)
  content = null
  file = get_shell.host_computer.File(current_path + "/xbase/" + type + ".xb")
  if file.get_content.len > 0 then content = file.get_content
  return content
end function

//add content to an existing database
addContent = function(type,content)
  file = get_shell.host_computer.File(current_path + "/xbase/" + type + ".xb")
end function

addAction = function(file, count)
  globals.actionMap[count] = file
end function

xCheck = function(i)
  if i == "x" or i == "exit" or i == "back" or i == 0 then return 1 else return 0
end function


////////////////
//// menus ////
//////////////

//main menu
menuMain = function()
  print("\n")
  mainHeader = headerStr("welcome " + userName)
  print(lineStr(mainHeader))
  print(mainHeader)
  print(br + grey + "<u>.   </u>    search    <u>    .")
  print(blue + "[1] </color>" + unavailable + "<b>browse</b> databases")//browseMenu
  print(blue + "[2] </color>" + unavailable + "<b>search</b> all folders/files/content")//searchAll
  print(blue + "[3] </color>" + unavailable + "search for a <b>folder</b>")//searchFolder
  print(blue + "[4] </color>" + unavailable + "search for a <b>file</b>")//searchFile
  print(blue + "[5] </color>" + unavailable + "search <b>content</b> of files")//searchContent
  print(br + grey + "<u>.   </u>    database controls    <u>    .")
  print(blue + "[6] </color>" + unavailable + "<b>add</b> new database")//dbAdd
  print(blue + "[7] </color>" + unavailable + "<b>edit</b> a database")//dbEdit
  print(blue + "[8] </color>" + unavailable + "<b>connect</b> to a remote database")//dbConnect
  print(br + grey + "<u>.   </u>    etc    <u>    .")
  print(blue + "[9] </color>" + unavailable + "<b>user</b> settings") //settingsMenu
  if globals.userData[2] == admin then print(blue + "[*] </color>" + unavailable + "<b>admin</b> controls")//adminMenu
  print(blue + "[h] </color>" + unavailable + "<b>help</b>")//call help()
  print(blue + "[x] </color>" + unavailable + "<b>exit</b>")//exit menu loop/close program
  print(lineStr(mainHeader))
end function

//browse menu
browseMenu = function()
  globals.actionMap = {}
  actionMap = globals.actionMap

  mainHeader = headerStr("browsing databases")
  print(br + lineStr(mainHeader))
  print(mainHeader)
  print(br + headerStr(baseFolder.path, 1))

  count = 0
  for file in baseFolder.get_files
    count = count + 1
    addAction(file, count)
  end for

  for action in actionMap
    print(blue + "[" + action.key + "]</color> " + action.value.name)
  end for

  print(br + lineStr(mainHeader))
  print(back)

  while not xCheck(i)
    i = user_input(arrow)
  end while
  i = ""
end function

//search menu
searchMenu = function(folder, file, content)
  if folder and file and content then type = "data"
  if folder then type = "folders"
  if file then type = "files"
  if content then type = "content"
  mainHeader = br + headerStr("searching all " + type)
  print(lineStr(mainHeader))
  print(mainHeader + br)
  while not xCheck(i)
    i = user_input("search " + arrow)
    print("\nnothing found")
    print(lineStr(mainHeader))
    print(back)
  end while
  i = ""
end function

//admin menu
adminMenu = function()
  clear_screen
  mainHeader = headerStr("admin options")
  print(lineStr(mainHeader))
  print(mainHeader)
  print(br + headerStr("user controls", 1))
  print(blue + "[1] </color>" + unavailable + "<b>add</b> new users")
  print(blue + "[2] </color>" + unavailable + "<b>edit</b> existing users")
  print(blue + "[3] </color>" + unavailable + "<b>remove</b> existing users")
  print(br + headerStr("encryption [disabled]", 1))
  print(blue + "[4] </color>" + unavailable + "<b>enable/disable</b> encryption")
  print(blue + "[5] </color>" + unavailable + "change <b>secure</b> encryption key (default: 55)")
  print(blue + "[6] </color>" + unavailable + "change <b>user</b> encryption key (default: 25)")
  print(lineStr(mainHeader))
  print(back + " " + unavailable + help)

  while not xCheck(i)
    i = user_input(br + arrow)
    if i == "1" or i == "add" then
    end if
    if i == "2" or i == "edit" then
      while not xCheck(i)
      clear_screen
        print(headerStr("registered users") + br)
        for line in xbUser.get
          print(line)
        end for
        i = user_input(br + arrow)
      end while
    end if
    if i == "3" or i == "enable/disable" then

    end if
    if i == "4" or i == "secure" then

    end if
    if i == "5" or i == "user" then

    end if
    if i == "h" or i == "help" then

    end if
  end while
  i = ""

end function

//settings menu
settingsMenu = function()
  print("\n")
  mainHeader = headerStr("settings")
  print(lineStr(mainHeader))
  print(mainHeader)
  print(lineStr(mainHeader))
  print(back)

  while not xCheck(i)
    i = user_input(br + arrow)
  end while
  i = ""
end function

//help menu
helpMenu = function()

  print(br + headerStr("help"))
  print(br + headerStr("general", 1))
  print(grey + char(187) + " make selections using line number or bolded word")
  print(grey + char(187) + " x, exit, back, and 0 are interchangable")
  print(grey + char(187) + " options are available based on permissions")
  print(grey + char(187) + " xbase [username] [password] to bypass login")
  print(br + headerStr("browsing", 1))
  print(grey + char(187) + " find/view/edit all .xb files in local file system")
  print(br + headerStr("searching", 1))
  print(grey + char(187) + " search for strings in files, folders, content, or all")
  print(br + headerStr("adding a database", 1))
  print(grey + char(187) + " create a new .xb file or directory")
  print(grey + char(187) + " choose/create a template for content structure")
  print(br + headerStr("editing databases", 1))
  print(grey + char(187) + " update names, permissions and content")
  print(br + headerStr("remote databases", 1))
  print(grey + char(187) + " connect to a remote database to view/add/edit")
  print(grey + char(187) + " use settings to configure remote connections")
  print(lineStr(headerStr("help")))

  print("[x] <b>back</b> [1] " + unavailable + "advanced usage</color>")
  while not xCheck(i)
    i = user_input(arrow)
  end while
  i = ""
end function


////////////////////
//// main code ////
//////////////////

print("\n\n")
    print(pink + "<b>    <u>.     </u>     corTechs     <u>     .")
print(white + "<b><u><i>.     [crossbase data manager]      .")

//login screen
while not globals.accepted
  register = 0

  if not i0 then
    i = user_input(white + "[1] " + grey + "login | " + white + "[2] " + grey + "register | " + white + "[3] " + grey + "help\n" + arrow)
  else
    i = i0
  end if

  if i == "2" then
    content = getContent(users)
    print(br)
    userCreds = login
    userName = userCreds[0]
    userPass = userCreds[1]
    if not content or content.indexOf("userLevel:admin") == null then
      print(br + grey + "creating admin profile...")
      xbUserFile.set_content(typeStr(users))
      user = new xbUser
      user.add(userName, userPass, admin)
      check = userCheck(userName, userPass)
      wait(1)
    else
      print(br + grey + "registering new user")
      user = new xbUser
      user.add(userName, userPass, guest)
      userCheck(userName, userPass)
      wait(.5)
    end if
  else if i == "3" then
    print("\n")
    print(headerStr("help"))
    print(grey + char(187) + " xbase [username] [password] to bypass login")
    print(grey + char(187) + " first registered user is admin")
    print(grey + char(187) + " all others registered from this screen are guest")
    print(grey + char(187) + " username and password must be alphanumerical")
    print(grey + char(187) + " user permissions can be edited by any admin")
    print(grey + char(187) + " see help in main menu for more information")
    print(lineStr(headerStr("help")))
  else
    print(br)
    userCreds = login
    userName = userCreds[0]
    userPass = userCreds[1]
    userCheck(userName, userPass)
    i0 = null; i1 = null
  end if
end while

//main menu controls
count = 0
i = ""
clear_screen
while not xCheck(i)

  count = count + 1
  if not i0 then menuMain
  if not i0 then i = user_input(br + "<b>></b>") else i = i0
  ii = i.split(" ")
  i0 = ii[0]
  if ii.len > 1 then i1 = ii[1]
  if ii.len > 2 then i2 = ii[2]
  if ii.len > 3 then i3 = ii[3]
  if ii.len > 4 then i4 = ii[4]

  if i0 == "browse" or i0 == "1" then
    browseMenu
  end if

  if i0 == "2" or i0 == "search" then
    searchMenu(1,1,1)
  end if

  if i0 == "3" or i0 == "folder" then
    searchMenu(1,0,0)
  end if

  if i0 == "4" or i0 == "file" then
    searchMenu(0,1,0)
  end if

  if i0 == "5" or i0 == "content" then
    searchMenu(0,0,1)
  end if

  if i0 == "*" or i0 == admin then
    if globals.userData[2] == admin then adminMenu
  end if

  if i0 == 9 or i0 == "user" then
    settingsMenu
  end if

  if i0 == "h" or i0 == "help" then
    helpMenu
  end if

  i0 = null
  i1 = null
  i2 = null
  i3 = null
  i4 = null

end while
