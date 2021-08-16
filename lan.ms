//scans local network
//use 'lan' to display all connections with ports
//use 'lan all' to display all connections regardless of port status

c = get_shell.host_computer
r = get_router
devices = r.devices_lan_ip
deviceList = []
if params.len > 0 then i1 = params[0] else i1 = null
print("\n")

for device in devices
	lanDevice = get_router(device)
	if lanDevice then
		if deviceList.indexOf(lanDevice.local_ip) == null then deviceList.push(lanDevice.local_ip)
	end if
end for

for device in devices
	ports = null
	if get_switch(device) == null and get_router != null then
		deviceInfo = "router"
	else
		deviceInfo = "switch"
	end if

	lanDevice = get_router(device)
	if lanDevice then
		if device == c.local_ip then device = "<color=green>" + device + "</color>"
		firewall_rules = lanDevice.firewall_rules
		if firewall_rules and firewall_rules.len > 0 then firewall = "(firewall)" else firewall = ""
		print("<b>[" + device + "]</b> " + deviceInfo + " " + firewall)
		for subDevice in lanDevice.devices_lan_ip
			if deviceList.indexOf(subDevice) == null then

				ports = lanDevice.device_ports(subDevice)
				if ports.len > 0 or i1 == "all" then
					if subDevice == c.local_ip then subDevice = "<color=green>" + subDevice + "</color>"
					print("<b>   [" + subDevice + "]")
					portPrint = ""
					for port in ports
						if lanDevice.port_info(port) != null then info = lanDevice.port_info(port).split(" ")[0] else info = null
						if info != null then
							if port.is_closed then
								port_status = "-"
							else
								port_status = "o"
							end if
							portPrint = portPrint + ("<i>      " +  port_status + " " + port.port_number + " " + info + " " + "\n")
						end if
					end for
					if portPrint != "<i>      [" then print(portPrint)
				end if
			end if
		end for
	end if
end for
