cryptools = include_lib("/lib/crypto.so")
thisComp = get_shell.host_computer
interface = thisComp.network_devices.split(" ")[0]
cryptools.airmon("start", interface)
networks = thisComp.wifi_networks(interface)
outPrint = ""
c = 0

for net in networks
	c = c + 1
	netsp = net.split(" ")
	outPrint = outPrint + "\n" + c + ". " + netsp[1] + " " + netsp[2]
end for

print("\n<color=white>" + outPrint)
input = user_input("\n<color=#505050>[network# maxAcks]\n<color=#505050><i>ie: [2 15000] (maxAcks optional. default: 10k)\n<color=white><b>></b>")
c = 0
if input.len > 1 then
	max = input.split(" ")[1].to_int
	input = input.split(" ")[0]
else
	max = 10000
end if

for net in networks
	c = c + 1
	if c == input.to_int then
		netsp = net.split(" ")
		print("\nconnecting to " + netsp[2])
		bssid = netsp[0]
		essid = netsp[2]

		result = cryptools.aireplay(bssid, essid, max)
		file = thisComp.File(parent_path(program_path) + "/file.cap")
		pass = cryptools.aircrack(file.path)
		if file then del = file.delete else print("can't find " + parent_path(program_path) + "/file.cap")
		if del == "" then print("file.cap removed") else print(file.delete)
		print("found password: " + pass)
		if pass != null then connect = thisComp.connect_wifi(interface, bssid, essid, pass)
		if connect == 1 then
			print("***connected to " + netsp[2] + "***")
		else if connect == null then
			print("can't find network")
		else
			print(connect)
		end if
	end if
end for
