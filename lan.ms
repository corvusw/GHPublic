//terminal based scanlan
//prints network chain
//subnet pathways
//device types
//open/closed ports


r = get_router
deviceList = []
devices = r.devices_lan_ip
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
		firewall_rules = lanDevice.firewall_rules
		if firewall_rules and firewall_rules.len > 0 then firewall = "(firewall)" else firewall = ""
		print("<b>[" + device + "]</b> " + deviceInfo + " " + firewall)
		for subDevice in lanDevice.devices_lan_ip
			if deviceList.indexOf(subDevice) == null then
				ports = lanDevice.device_ports(subDevice)
				if ports.len > 0 then
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
