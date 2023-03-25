-- minGUI events loop, must be call by love.update
function minGUI_update_events(dt)
	--=====================================================================
	-- timer events
	--=====================================================================
	
	-- increment base timer
	minGUI.timer = minGUI.timer + dt

	-- scan for ptimers
	for i, v in ipairs(minGUI.ptimer) do
		-- a timer should send an event...
		if math.floor(minGUI.timer * 1000) - v.timer >= v.delay then
			-- send the good event
			table.insert(minGUI.tstack, {eventTimer = i, eventType = MG_EVENT_TIMER_TICK})
			
			-- restart timer
			v.timer = math.floor(minGUI.timer * 1000)
		end
	end

	--=====================================================================
	-- mouse events
	--=====================================================================
	
	-- get mouse position
	minGUI.mouse.x, minGUI.mouse.y = love.mouse.getPosition()
	
	-- check for mouse down
	for i = 1, 3 do
		minGUI.mouse.oldmbtn[i] = minGUI.mouse.mbtn[i]
		minGUI.mouse.mbtn[i] = love.mouse.isDown(i)
		
		-- the user has pressed or released a mouse button ?
		minGUI.mouse.mpressed[i] = false
		minGUI.mouse.mreleased[i] = false
		
		if minGUI.mouse.oldmbtn[i] == false and minGUI.mouse.mbtn[i] == true then
			-- button pressed
			minGUI.mouse.mpressed[i] = true
		elseif minGUI.mouse.oldmbtn[i] == true and minGUI.mouse.mbtn[i] == false then
			-- button released
			minGUI.mouse.mreleased[i] = true
		end
	end

	-- flag used to check if a gadget is still focused
	getfocusFlag = false
	
	-- click loops
	for b = 1, 3 do
		-- click on a gadget ?
		if minGUI.mouse.mpressed[b] == true then
			for i, v in ipairs(minGUI.gtree) do
				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					-- click on a button inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									if b == MG_LEFT_BUTTON then
										v.down = true
										getfocusFlag = true
									end
								end
							end
						end
					-- click on a button in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								if b == MG_LEFT_BUTTON then
									v.down = true
									getfocusFlag = true
								end
							end
						end
					end
				elseif v.tp == MG_STRING then
					-- click on a string inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									minGUI.gfocus = i
									getfocusFlag = true
								end
							end
						end
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								minGUI.gfocus = i
								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_CHECKBOX then
					local width = minGUI.sprite[MG_CHECKBOX_IMAGE]:getWidth()
					local height = minGUI.sprite[MG_CHECKBOX_IMAGE]:getHeight()
					
					-- click on a checkbox inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - height) / 2) and minGUI.mouse.y < w.y + v.y + ((v.height - height) * 3 / 2) then
									if b == MG_LEFT_BUTTON then
										-- reverse state
										if v.checked == false then v.checked = true else v.checked = false end

										getfocusFlag = true
									end
								end
							end
						end
					-- click on a checkbox in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + width then
							if minGUI.mouse.y >= v.y + ((v.height - height) / 2) and minGUI.mouse.y < v.y + ((v.height - height) * 3 / 2) then
								if b == MG_LEFT_BUTTON then
									-- reverse state
									if v.checked == false then v.checked = true else v.checked = false end

									getfocusFlag = true
								end
							end
						end
					end
				elseif v.tp == MG_OPTION then
					local width = minGUI.sprite[MG_OPTION_IMAGE]:getWidth()
					local height = minGUI.sprite[MG_OPTION_IMAGE]:getHeight()
					
					-- click on an option gadget inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - height) / 2) and minGUI.mouse.y < w.y + v.y + ((v.height - height) * 3 / 2) then
									if b == MG_LEFT_BUTTON then
										-- uncheck all options of the same parent
										minGUI_uncheck_option(v, num)
										
										-- check the currently clicked option
										v.checked = true

										getfocusFlag = true
									end
								end
							end
						end
					-- click on an option gadget in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + width then
							if minGUI.mouse.y >= v.y + ((v.height - height) / 2) and minGUI.mouse.y < v.y + ((v.height - height) * 3 / 2) then
								if b == MG_LEFT_BUTTON then
									-- uncheck all options of the same parent
									minGUI_uncheck_option(v, num)
										
									-- check the currently clicked option
									v.checked = true

									getfocusFlag = true
								end
							end
						end
					end
				elseif v.tp == MG_SPIN then
					-- get up and down buttons width & height
					local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
					local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
					local height = fullHeight / 2

					-- click on a spin gadget inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]						
						
						if w ~= nil then
							-- click on up button
							if minGUI.mouse.x >= w.x + v.x + v.width - width and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) + height then
									if b == MG_LEFT_BUTTON then
										v.timer = minGUI.timer
										v.btnUp = true
										v.press = 0
										getfocusFlag = true
										
										v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
									end
								end
							end
							
							-- click on down button
							if minGUI.mouse.x >= w.x + v.x + v.width - width and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
									if b == MG_LEFT_BUTTON then
										v.timer = minGUI.timer
										v.btnDown = true
										v.press = 0
										getfocusFlag = true
										
										v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
									end
								end
							end
							
							-- click on the text area
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + (v.width - width) then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									if b == MG_LEFT_BUTTON then
										minGUI.gfocus = i
										v.down = true
										getfocusFlag = true
									end
								end
							end							
						end
					-- click on a button in the main canvas...
					else
						-- click on up button
						if minGUI.mouse.x >= v.x + v.width - width and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) + height then
								if b == MG_LEFT_BUTTON then
									v.timer = minGUI.timer
									v.btnUp = true
									v.press = 0
									getfocusFlag = true
										
									v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
								end
							end
						end

						-- click on down button
						if minGUI.mouse.x >= v.x + v.width - width and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) + (2 * height) then
								if b == MG_LEFT_BUTTON then
									v.timer = minGUI.timer
									v.btnDown = true
									v.press = 0
									getfocusFlag = true
										
									v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
								end
							end
						end

						-- click on the text area
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + (v.width - width) then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								if b == MG_LEFT_BUTTON then
									minGUI.gfocus = i
									v.down = true
									getfocusFlag = true
								end
							end
						end
					end
				elseif v.tp == MG_CANVAS then
					-- click on a canvas inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									if b == MG_LEFT_BUTTON then
										table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_PRESSED})

										v.down = true
										getfocusFlag = true
									end
								end
							end
						end
					-- click on a canvas in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								if b == MG_LEFT_BUTTON then
									table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_PRESSED})
										
									v.down = true
									getfocusFlag = true
								end
							end
						end
					end
				end
			end
			
			-- focus lost ?
			if b == MG_LEFT_BUTTON then
				if getfocusFlag == false then
					minGUI.gfocus = nil
				end
			end
		end
		
		-- button continue to be down on a gadget ?
		if minGUI.mouse.mbtn[b] == true then
			for i, v in ipairs(minGUI.gtree) do
				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					-- a button inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x < w.x + v.x or minGUI.mouse.x >= w.x + v.x + v.width then
								if b == MG_LEFT_BUTTON then v.down = false end
							elseif minGUI.mouse.y < w.y + v.y or minGUI.mouse.y >= w.y + v.y + v.height then
								if b == MG_LEFT_BUTTON then v.down = false end
							end
						end
					-- a button in the main canvas...
					else
						if minGUI.mouse.x < v.x or minGUI.mouse.x >= v.x + v.width then
							if b == MG_LEFT_BUTTON then v.down = false end
						elseif minGUI.mouse.y < v.y or minGUI.mouse.y >= v.y + v.height then
							if b == MG_LEFT_BUTTON then v.down = false end
						end
					end
				elseif v.tp == MG_SPIN then
					-- get up and down buttons width & height
					local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
					local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
					local height = fullHeight / 2

					-- a spin gadget inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then						
							if minGUI.mouse.x < w.x + v.x + v.width - width or minGUI.mouse.x >= w.x + v.x + v.width then
								if b == MG_LEFT_BUTTON then v.btnUp = false end
							elseif minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) or minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) + height then
								if b == MG_LEFT_BUTTON then v.btnUp = false end
							end
							
							if v.btnUp == true then
								local t = minGUI.timer - v.timer
								
								if v.press == 0 then
									if t >= MG_SLOW_DELAY then
										v.timer = minGUI.timer
										v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)									
										v.press = v.press + 1
									end

								elseif v.press > 0 then
									if t >= MG_QUICK_DELAY then
										v.timer = minGUI.timer
										v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
										v.press = v.press + 1
									end
								end
							end
							
							if minGUI.mouse.x < w.x + v.x + v.width - width or minGUI.mouse.x >= w.x + v.x + v.width then
								if b == MG_LEFT_BUTTON then v.btnDown = false end
							elseif minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) + height or minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
								if b == MG_LEFT_BUTTON then v.btnDown = false end
							end
							
							if v.btnDown == true then
								local t = minGUI.timer - v.timer
								
								if v.press == 0 then
									if t >= MG_SLOW_DELAY then
										v.timer = minGUI.timer
										v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
										v.press = v.press + 1
									end
								elseif v.press > 0 then
									if t >= MG_QUICK_DELAY then
										v.timer = minGUI.timer
										v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
										v.press = v.press + 1
									end
								end
							end
						end
					-- a spin gadget in the main canvas...
					else
						if minGUI.mouse.x < v.x + v.width - width or minGUI.mouse.x >= v.x + v.width then
							if b == MG_LEFT_BUTTON then v.btnUp = false end
						elseif minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) or minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) + height then
							if b == MG_LEFT_BUTTON then v.btnUp = false end
						end

						if v.btnUp == true then
							local t = minGUI.timer - v.timer
								
							if v.press == 0 then
								if t >= MG_SLOW_DELAY then
									v.timer = minGUI.timer
									v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
									v.press = v.press + 1
								end
							elseif v.press > 0 then
								if t >= MG_QUICK_DELAY then
									v.timer = minGUI.timer
									v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
									v.press = v.press + 1
								end
							end
						end

						if minGUI.mouse.x < v.x + v.width - width or minGUI.mouse.x >= v.x + v.width then
							if b == MG_LEFT_BUTTON then v.btnDown = false end
						elseif minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) + height or minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) + (2 * height) then
							if b == MG_LEFT_BUTTON then v.btnDown = false end
						end
							
						if v.btnDown == true then
							local t = minGUI.timer - v.timer
								
							if v.press == 0 then
								if t >= MG_SLOW_DELAY then
									v.timer = minGUI.timer
									v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
									v.press = v.press + 1
								end
							elseif v.press > 0 then
								if t >= MG_QUICK_DELAY then
									v.timer = minGUI.timer
									v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
									v.press = v.press + 1
								end
							end
						end
					end
				elseif v.tp == MG_CANVAS then
					-- a canvas inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x < w.x + v.x or minGUI.mouse.x >= w.x + v.x + v.width then
								if b == MG_LEFT_BUTTON then v.down = false end
							elseif minGUI.mouse.y < w.y + v.y or minGUI.mouse.y >= w.y + v.y + v.height then
								if b == MG_LEFT_BUTTON then v.down = false end
							end
							
							if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_DOWN}) end
						end
					-- a canvas in the main canvas...
					else
						if minGUI.mouse.x < v.x or minGUI.mouse.x >= v.x + v.width then
							if b == MG_LEFT_BUTTON then v.down = false end
						elseif minGUI.mouse.y < v.y or minGUI.mouse.y >= v.y + v.height then
							if b == MG_LEFT_BUTTON then v.down = false end
						end
							
						if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_DOWN}) end
					end
				end
			end
		end

		-- release button on a gadget ?
		if minGUI.mouse.mreleased[b] == true then
			for i, v in ipairs(minGUI.gtree) do
				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					-- a button inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									if b == MG_LEFT_BUTTON then
										if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_RELEASED}) end
										
										v.down = false										
									end
								end
							end
						end
					-- a button in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								if b == MG_LEFT_BUTTON then
									if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_RELEASED}) end
										
									v.down = false										
								end
							end
						end
					end
				elseif v.tp == MG_SPIN then
					-- release the key pressed
					v.press = 0

					-- get up and down buttons width & height
					local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
					local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
					local height = fullHeight / 2

					-- a spin gadget inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x + v.width - width and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) + height then
									if b == MG_LEFT_BUTTON then
										v.btnUp = false
									end
								end
							end
							
							if minGUI.mouse.x >= w.x + v.x + v.width - width and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < w.y + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
									if b == MG_LEFT_BUTTON then
										v.btnDown = false
									end
								end
							end
						end
					-- a spin gadget in the main canvas...
					else
						if minGUI.mouse.x >= v.x + v.width - width and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) + height then
								if b == MG_LEFT_BUTTON then
									v.btnUp = false
								end
							end
						end
							
						if minGUI.mouse.x >= v.x + v.width - width and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < v.y + ((v.height - fullHeight) / 2) + (2 * height) then
								if b == MG_LEFT_BUTTON then
									v.btnDown = false
								end
							end
						end
					end
				elseif v.tp == MG_CANVAS then
					-- a canvas inside a panel...
					if v.parent ~= nil then
						local w = minGUI.ptree[v.parent]
						
						if w ~= nil then
							if minGUI.mouse.x >= w.x + v.x and minGUI.mouse.x < w.x + v.x + v.width then
								if minGUI.mouse.y >= w.y + v.y and minGUI.mouse.y < w.y + v.y + v.height then
									if b == MG_LEFT_BUTTON then
										if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_RELEASED}) end
										
										v.down = false										
									end
								end
							end
						end
					-- a canvas in the main canvas...
					else
						if minGUI.mouse.x >= v.x and minGUI.mouse.x < v.x + v.width then
							if minGUI.mouse.y >= v.y and minGUI.mouse.y < v.y + v.height then
								if b == MG_LEFT_BUTTON then
									if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_MOUSE_RELEASED}) end
										
									v.down = false										
								end
							end
						end
					end
				end
			end
		end
	end

	--=====================================================================
	-- keyboard events
	--=====================================================================
		
	-- if a gadget has the focus...
	if minGUI.gfocus ~= nil then
		-- if the gadget exists
		if minGUI.gtree[minGUI.gfocus] ~= nil then
			-- if it is a string gadget...
			if minGUI.gtree[minGUI.gfocus].tp == MG_STRING then
				-- if the string gadget is editable
				if minGUI.gtree[minGUI.gfocus].editable == true then
					-- if backspace has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].backspace == 0 then
						-- if backspace is pressed now...
						if love.keyboard.isDown("backspace") == true then
							-- remove the last UTF-8 character.
							local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

							if byteoffset then
								minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							end

							-- calculate the new offset value for the text
							minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)

							-- count the first backspace, and get the timer
							minGUI.gtree[minGUI.gfocus].backspace = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if backspace has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].backspace > 0 then
						-- if backspace is released now...
						if love.keyboard.isDown("backspace") == false then
							minGUI.gtree[minGUI.gfocus].backspace = 0
						else
							-- if backspace is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].backspace == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- remove the last UTF-8 character.
									local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

									if byteoffset then
										minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
									end

									-- calculate the new offset value for the text
									minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
									-- reset kbdelay and increment backspace
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
								end
							-- if backspace is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].backspace > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- remove the last UTF-8 character.
									local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

									if byteoffset then
										minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
									end

									-- calculate the new offset value for the text
									minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
									-- reset kbdelay and increment backspace
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
								end
							end
						end
					end
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_SPIN then
				-- if backspace has not yet been pressed...
				if minGUI.gtree[minGUI.gfocus].backspace == 0 then
					-- if backspace is pressed now...
					if love.keyboard.isDown("backspace") == true then
						-- remove the last UTF-8 character.
						local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

						if byteoffset then
							minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
							if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
							if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
						end

						-- calculate the new offset value for the text
						minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)

						-- count the first backspace, and get the timer
						minGUI.gtree[minGUI.gfocus].backspace = 1
						minGUI.kbdelay = minGUI.timer
					end
					
				-- if backspace has been pressed...
				elseif minGUI.gtree[minGUI.gfocus].backspace > 0 then
					-- if backspace is released now...
					if love.keyboard.isDown("backspace") == false then
						minGUI.gtree[minGUI.gfocus].backspace = 0
					else
						-- if backspace is still pressed, and has been pressed only one time
						if minGUI.gtree[minGUI.gfocus].backspace == 1 then
							-- wait for keyboard slow delay
							if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
								-- remove the last UTF-8 character.
								local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

								if byteoffset then
									minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
									if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
									if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
								end

								-- calculate the new offset value for the text
								minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
								-- reset kbdelay and increment backspace
								minGUI.kbdelay = minGUI.timer
								minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
							end
						-- if backspace is still pressed, and has been pressed for multiple times
						elseif minGUI.gtree[minGUI.gfocus].backspace > 1 then
							-- wait for keyboard quick delay
							if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
								-- remove the last UTF-8 character.
								local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

								if byteoffset then
									minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
									if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
									if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
								end

								-- calculate the new offset value for the text
								minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
								-- reset kbdelay and increment backspace
								minGUI.kbdelay = minGUI.timer
								minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
							end
						end
					end
				end
			end
		end
	end	
end

-- function to input text, and
-- write it  in a gadget
function minGUI_textinput(t)
	-- if a gadget has the focus...
	if minGUI.gfocus ~= nil then
		-- if the gadget exists
		if minGUI.gtree[minGUI.gfocus] ~= nil then
			-- if it is a string gadget...
			if minGUI.gtree[minGUI.gfocus].tp == MG_STRING then
				-- if the gadget is editable...
				if minGUI.gtree[minGUI.gfocus].editable == true then
					-- add last character to the text
					minGUI.gtree[minGUI.gfocus].text = minGUI.gtree[minGUI.gfocus].text .. t
					
					-- calculate the new offset value for the text
					minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_SPIN then
				if t >= "0" and t <= "9" then
					-- add last character to the text
					minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text .. t, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue)
						
					-- calculate the new offset value for the text
					minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
				end
			end
		end
	end
end
