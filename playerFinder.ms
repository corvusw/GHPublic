findProxy = function()
	clear_screen
	c = get_shell.host_computer
	count = 0
	pcount = 0
	r = range(-1,1)
	rng = function()
		return floor((rnd * 255) + 1)
	end function
	print("<color=white>scanning...")
	while true
		ip = rng + "." + rng + "." + rng + "." + rng
		print("<color=#75808A><s>" + ip)
		if is_valid_ip(ip) then
			count = count + 1
			router = get_router(ip)
			if router != null then
				ports = router.used_ports
				if ports.len == 1 and router.devices_lan_ip.len < 3 then
					for port in ports
						if router.port_info(port).indexOf("ssh ") == 0 or router.port_info(port).indexOf("rshell") == 0 and not port.is_closed and not router.port_info(port).indexOf("unknown") > 0 then
							print("\n<color=red>****************</color>\n<color=white><u><b>" + ip)
							print("<color=white>" + router.port_info(port) + " - " + port.port_number)
							print("<color=red>****************</color>\n")
							c.touch(current_path,"players.db")
							file = c.File(current_path + "/players.db")
							file.set_content(file.get_content + "\n" + ip)
							pcount = pcount + 1
						end if
					end for
				end if
			end if
		end if
		if not count % 7 then
			if pcount > 0 then print("<color=red><b>[" + pcount + " players found]")
			print("<color=white>" + count + " IPs scanned")
		end if
	end while
end function
findProxy
