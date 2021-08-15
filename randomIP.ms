//target random IP. to target specific library, pass 'lib' as string ("http","smtp","ssh","empl", etc)
rndIP = function(lib)
	rng = function()
		return floor((rnd * 255) + 1)
	end function
	print("\n")
	while true
		print("<color=white>searching...")
		ip = rng + "." + rng + "." + rng + "." + rng
		if is_valid_ip(ip) then
			router = get_router(ip)
			if router != null then
				if lib != null then
					ports = router.used_ports
						for port in ports
							if router.port_info(port).indexOf(lib) == 0 and not port.is_closed then
								return ip
								continue
							end if
						end for
				else
					return ip
					continue
				end if
			end if
		end if
	end while
end function
