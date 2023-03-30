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
				-- get panel offset for gadgets inside a panel
				local ox = 0
				local oy = 0
					
				if v.parent ~= nil then
					local w = minGUI.ptree[v.parent]
						
					if w ~= nil then
						ox = w.x
						oy = w.y
					end
				end

				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								v.down.left = true
								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_STRING then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							minGUI.gfocus = i
							getfocusFlag = true
						end
					end
				elseif v.tp == MG_CHECKBOX then
					local width = minGUI.sprite[MG_CHECKBOX_IMAGE]:getWidth()
					local height = minGUI.sprite[MG_CHECKBOX_IMAGE]:getHeight()
					
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - height) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - height) * 3 / 2) then
							if b == MG_LEFT_BUTTON then
								-- reverse state
								if v.checked == false then v.checked = true else v.checked = false end

								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_OPTION then
					local width = minGUI.sprite[MG_OPTION_IMAGE]:getWidth()
					local height = minGUI.sprite[MG_OPTION_IMAGE]:getHeight()

					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - height) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - height) * 3 / 2) then
							if b == MG_LEFT_BUTTON then
								-- uncheck all options of the same parent
								minGUI_uncheck_option(v, num)
										
								-- check the currently clicked option
								v.checked = true

								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_SPIN then
					-- get up and down buttons width & height
					local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
					local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
					local height = fullHeight / 2

					if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height then
							if b == MG_LEFT_BUTTON then
								v.timer = minGUI.timer
								v.btnUp = true
								v.press = 0
								getfocusFlag = true
										
								v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
							end
						end
					end

					if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
							if b == MG_LEFT_BUTTON then
								v.timer = minGUI.timer
								v.btnDown = true
								v.press = 0
								getfocusFlag = true
										
								v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
							end
						end
					end

					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + (v.width - width) then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								minGUI.gfocus = i
								v.down.left = true
								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_CANVAS then					
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
										
								v.down.left = true
								getfocusFlag = true
							end
								
							if b == MG_RIGHT_BUTTON then
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_PRESSED})
										
								v.down.right = true
								getfocusFlag = true
							end
						end
					end
				elseif v.tp == MG_EDITOR then					
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							minGUI.gfocus = i
							getfocusFlag = true
						end
					end
				elseif v.tp == MG_SCROLLBAR then
					local value = 0
					
					if bit.band(v.flags, MG_SCROLLBAR_VERTICAL) == MG_SCROLLBAR_VERTICAL then
						if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
							if minGUI.mouse.y >= oy + v.y + v.size and minGUI.mouse.y < oy + v.y + v.height - v.size then
								v.down = true
								value = ((minGUI.mouse.y - (oy + v.y + v.size)) / v.real_height) * (v.maxValue - v.minValue)
							end
						end
					else
						if minGUI.mouse.x >= ox + v.x + v.size and minGUI.mouse.x < ox + v.x + v.width - v.size then
							if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
								v.down = true
								value = ((minGUI.mouse.x - (ox + v.x + v.size)) / v.real_width) * (v.maxValue - v.minValue)
							end
						end
					end

					if v.down == true then
						if b == MG_LEFT_BUTTON then
							getfocusFlag = true

							local lng1 = (v.maxValue - v.minValue)
							local lng2 = lng1 / v.stepsValue
						
							value = value - v.minValue
							value = math.floor(value / lng2)
							value = value * lng1 / (v.stepsValue - 1)
							value = value + v.minValue
							value = math.min(math.max(value, v.minValue), v.maxValue)
							v.value = value
								
							if v.value < v.minValue then v.value = v.minValue end
							if v.value > v.maxValue then v.value = v.maxValue end
							
							table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
						end
					end

					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
							if b == MG_LEFT_BUTTON then
								v.timer = minGUI.timer
								v.down1 = true
								getfocusFlag = true
								v.value = v.value - v.inc
								
								if v.value < v.minValue then v.value = v.minValue end
							
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
							end
						end
					end

					if minGUI.mouse.x >= ox + v.x + v.width - v.size and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + v.height - v.size and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								v.timer = minGUI.timer
								v.down2 = true
								getfocusFlag = true
								v.value = v.value + v.inc

								if v.value > v.maxValue then v.value = v.maxValue end
							
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
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
				-- get panel offset for gadgets inside a panel
				local ox = 0
				local oy = 0
					
				if v.parent ~= nil then
					local w = minGUI.ptree[v.parent]
						
					if w ~= nil then
						ox = w.x
						oy = w.y
					end
				end

				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.width then
						if b == MG_LEFT_BUTTON then v.down.left = false end
						if b == MG_RIGHT_BUTTON then v.down.right = false end
					elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then v.down.left = false end
						if b == MG_RIGHT_BUTTON then v.down.right = false end
					end
				elseif v.tp == MG_SPIN then					
					-- get up and down buttons width & height
					local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
					local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
					local height = fullHeight / 2

					if minGUI.mouse.x < ox + v.x + v.width - width or minGUI.mouse.x >= ox + v.x + v.width then
						if b == MG_LEFT_BUTTON then v.btnUp = false end
					elseif minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) or minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height then
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

					if minGUI.mouse.x < ox + v.x + v.width - width or minGUI.mouse.x >= ox + v.x + v.width then
						if b == MG_LEFT_BUTTON then v.btnDown = false end
					elseif minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height or minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
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
				elseif v.tp == MG_CANVAS then
					if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.width then
						if b == MG_LEFT_BUTTON then v.down.left = false end
						if b == MG_RIGHT_BUTTON then v.down.right = false end
					elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then v.down.left = false end
						if b == MG_RIGHT_BUTTON then v.down.right = false end
					end

					if b == MG_LEFT_BUTTON then
						if v.down.left == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN}) end
					end
					
					if b == MG_RIGHT_BUTTON then
						if v.down.right == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_DOWN}) end
					end
				elseif v.tp == MG_SCROLLBAR then
					local value = 0
					
					if bit.band(v.flags, MG_SCROLLBAR_VERTICAL) == MG_SCROLLBAR_VERTICAL then
						if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.size then
							if b == MG_LEFT_BUTTON then v.down = false end
						elseif minGUI.mouse.y < oy + v.y + v.size or minGUI.mouse.y >= oy + v.y + v.height - v.size then
							if b == MG_LEFT_BUTTON then v.down = false end
						else
							value = ((minGUI.mouse.y - (oy + v.y + v.size)) / v.real_height) * (v.maxValue - v.minValue)
						end
					else
						if minGUI.mouse.x < ox + v.x + v.size or minGUI.mouse.x >= ox + v.x + v.width - v.size then
							if b == MG_LEFT_BUTTON then v.down = false end
						elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.size then
							if b == MG_LEFT_BUTTON then v.down = false end
						else
							value = ((minGUI.mouse.x - (ox + v.x + v.size)) / v.real_width) * (v.maxValue - v.minValue)
						end
					end
					
					if v.down == true then
						local lng1 = (v.maxValue - v.minValue)
						local lng2 = lng1 / v.stepsValue
						
						value = value - v.minValue
						value = math.floor(value / lng2)
						value = value * lng1 / (v.stepsValue - 1)
						value = value + v.minValue
						value = math.min(math.max(value, v.minValue), v.maxValue)
						v.value = value
								
						if v.value < v.minValue then v.value = v.minValue end
						if v.value > v.maxValue then v.value = v.maxValue end
							
						if b == MG_LEFT_BUTTON then
							table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
						end
					end

					
					if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.size then
						if b == MG_LEFT_BUTTON then v.down1 = false end
					elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.size then
						if b == MG_LEFT_BUTTON then v.down1 = false end
					end
					
					if v.down1 == true then
						local t = minGUI.timer - v.timer
								
						if t >= MG_MEDIUM_DELAY then
							v.timer = minGUI.timer
							v.value = v.value - v.inc
								
							if v.value < v.minValue then v.value = v.minValue end
							
							if b == MG_LEFT_BUTTON then
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
							end
						end
					end

					if minGUI.mouse.x < ox + v.x + v.width - v.size or minGUI.mouse.x >= ox + v.x + v.width then
						if b == MG_LEFT_BUTTON then v.down2 = false end
					elseif minGUI.mouse.y < oy + v.y + v.height - v.size or minGUI.mouse.y >= oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then v.down2 = false end
					end

					if v.down2 == true then
						local t = minGUI.timer - v.timer
								
						if t >= MG_MEDIUM_DELAY then
							v.timer = minGUI.timer
							v.value = v.value + v.inc
							
							if v.value > v.maxValue then v.value = v.maxValue end
							
							if b == MG_LEFT_BUTTON then
								table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
							end
						end
					end
				end
			end
		end

		-- release button on a gadget ?
		if minGUI.mouse.mreleased[b] == true then
			for i, v in ipairs(minGUI.gtree) do
				-- get panel offset for gadgets inside a panel
				local ox = 0
				local oy = 0
					
				if v.parent ~= nil then
					local w = minGUI.ptree[v.parent]
						
					if w ~= nil then
						ox = w.x
						oy = w.y
					end
				end

				if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								if v.down.left == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
										
								v.down.left = false										
							end
								
							if b == MG_RIGHT_BUTTON then
								if v.down.right == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_RELEASED}) end
										
								v.down.right = false										
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

					if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height then
							if b == MG_LEFT_BUTTON then
								v.btnUp = false
							end
						end
					end
							
					if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
							if b == MG_LEFT_BUTTON then
								v.btnDown = false
							end
						end
					end
				elseif v.tp == MG_CANVAS then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								if v.down.left == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
										
								v.down.left = false
							end
								
							if b == MG_RIGHT_BUTTON then
								if v.down.left == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_RELEASED}) end
										
								v.down.right = false
							end
						end
					end
				elseif v.tp == MG_SCROLLBAR then
					if bit.band(v.flags, MG_SCROLLBAR_VERTICAL) == MG_SCROLLBAR_VERTICAL then
						if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
							if minGUI.mouse.y >= oy + v.y + v.size and minGUI.mouse.y < oy + v.y + v.height - v.size then
								if b == MG_LEFT_BUTTON then
									if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end

									v.down = false
								end
							end
						end
					else
						if minGUI.mouse.x >= ox + v.x + v.size and minGUI.mouse.x < ox + v.x + v.width - v.size then
							if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
								if b == MG_LEFT_BUTTON then
									if v.down == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end

									v.down = false
								end
							end
						end
					end

					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
							if b == MG_LEFT_BUTTON then
								if v.down1 == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
										
								v.down1 = false										
							end
						end
					end

					if minGUI.mouse.x >= ox + v.x + v.width - v.size and minGUI.mouse.x < ox + v.x + v.width then
						if minGUI.mouse.y >= oy + v.y + v.height - v.size and minGUI.mouse.y < oy + v.y + v.height then
							if b == MG_LEFT_BUTTON then
								if v.down2 == true then table.insert(minGUI.estack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
										
								v.down2 = false										
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
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_EDITOR then
				-- if the editor gadget is editable
				if minGUI.gtree[minGUI.gfocus].editable == true then
					-- explode text
					local t = {}
					
					t = minGUI_explode(minGUI.gtree[minGUI.gfocus].text, "\n")
					
					-- function to move up
					local move_up = function(self)
						if minGUI.gtree[minGUI.gfocus].cursory > 0 then
							minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory - 1
							
							if minGUI.gtree[minGUI.gfocus].cursorx > utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
								minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
							end
						end
					end

					-- function to move down
					local move_down = function(self)
						-- if not on the last line...
						if minGUI.gtree[minGUI.gfocus].cursory < #t - 1 then
							-- increment cursor y
							minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory + 1

							if minGUI.gtree[minGUI.gfocus].cursorx > utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
								minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
							end
						elseif utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) == 0 then
							minGUI.gtree[minGUI.gfocus].cursorx = 0
						else
							minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
						end
					end

					-- function to move left
					local move_left = function(self)
						minGUI.gtree[minGUI.gfocus].cursorx = minGUI.gtree[minGUI.gfocus].cursorx - 1
							
						if minGUI.gtree[minGUI.gfocus].cursorx < 0 then
							minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory - 1
							
							if minGUI.gtree[minGUI.gfocus].cursory >= 0 then
								minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
							else
								minGUI.gtree[minGUI.gfocus].cursorx = 0
								minGUI.gtree[minGUI.gfocus].cursory = 0
							end
						end
					end

					-- function to move right
					local move_right = function(self)
						if minGUI.gtree[minGUI.gfocus].cursory < #t then
							minGUI.gtree[minGUI.gfocus].cursorx = minGUI.gtree[minGUI.gfocus].cursorx + 1

							if minGUI.gtree[minGUI.gfocus].cursorx > utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
								minGUI.gtree[minGUI.gfocus].cursorx = 0
								minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory + 1
								
								if minGUI.gtree[minGUI.gfocus].cursory > #t then
									minGUI.gtree[minGUI.gfocus].cursory = #t
								end
							end
						end							
					end

					-- remove character at left from cursor
					local remove_left_char = function(self)
						-- if on the last line...
						if minGUI.gtree[minGUI.gfocus].cursory == #t - 1 then
							local count = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
							
							if count == 0 then
								move_left()
								
								table.remove(t)
								
								minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							elseif minGUI.gtree[minGUI.gfocus].cursorx == 0 then
								local rt = t[minGUI.gtree[minGUI.gfocus].cursory + 1]
								
								minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory])
								t[minGUI.gtree[minGUI.gfocus].cursory] = t[minGUI.gtree[minGUI.gfocus].cursory] .. rt
								
								table.remove(t, minGUI.gtree[minGUI.gfocus].cursory + 1)

								minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory - 1								
								minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							else
								t[minGUI.gtree[minGUI.gfocus].cursory + 1] = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 1, -2)
								minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							
								move_left()
							end							
						elseif minGUI.gtree[minGUI.gfocus].cursorx > 0 or minGUI.gtree[minGUI.gfocus].cursory > 0 then
							if minGUI.gtree[minGUI.gfocus].cursorx == 0 then
								local count = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
								
								if count == 0 then
									table.remove(t, minGUI.gtree[minGUI.gfocus].cursory + 1)

									minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory - 1								
									minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
									minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
								else
									local rt = t[minGUI.gtree[minGUI.gfocus].cursory + 1]

									table.remove(t, minGUI.gtree[minGUI.gfocus].cursory + 1)								

									minGUI.gtree[minGUI.gfocus].cursory = minGUI.gtree[minGUI.gfocus].cursory - 1								
									minGUI.gtree[minGUI.gfocus].cursorx = utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1])
									t[minGUI.gtree[minGUI.gfocus].cursory + 1] = t[minGUI.gtree[minGUI.gfocus].cursory + 1] .. rt
									minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
								end
							else
								local lt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 1, minGUI.gtree[minGUI.gfocus].cursorx - 1)
								local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 1)

								t[minGUI.gtree[minGUI.gfocus].cursory + 1] = lt .. rt

								minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")

								move_left()
							end
						end
					end

					-- remove character at right from cursor
					local remove_right_char = function(self)
						-- if there is a text on the line to delete a character...
						if t[minGUI.gtree[minGUI.gfocus].cursory + 1] ~= nil then
							if t[minGUI.gtree[minGUI.gfocus].cursory + 2] == nil and minGUI.gtree[minGUI.gfocus].cursorx == utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
							elseif utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) > 0 then
								-- if the cursor is at the beginning of the text
								if minGUI.gtree[minGUI.gfocus].cursorx == 0 then
									t[minGUI.gtree[minGUI.gfocus].cursory + 1] = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 2, utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]))
	
									minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
								-- if the cursor is in the middle of the text
								elseif minGUI.gtree[minGUI.gfocus].cursorx < utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
									local lt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 1, minGUI.gtree[minGUI.gfocus].cursorx)
									local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 2)
	
									t[minGUI.gtree[minGUI.gfocus].cursory + 1] = lt .. rt
	
									minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
								else
									t[minGUI.gtree[minGUI.gfocus].cursory + 1] = t[minGUI.gtree[minGUI.gfocus].cursory + 1] .. t[minGUI.gtree[minGUI.gfocus].cursory + 2]
									table.remove(t, minGUI.gtree[minGUI.gfocus].cursory + 2)
		
									minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
								end
							end
						end
					end
					
					-- if home key is pressed now...
					if love.keyboard.isDown("home") == true then
						minGUI.gtree[minGUI.gfocus].cursorx = 0
					end

					-- if end key is pressed now...
					if love.keyboard.isDown("end") == true then
						minGUI:set_cursor_xy(minGUI.gfocus, -1, minGUI.gtree[minGUI.gfocus].cursory)
					end
					
					-- pressed return ?
					local ret = function(self)
						if minGUI.gtree[minGUI.gfocus].cursorx == 0 then
							table.insert(t, minGUI.gtree[minGUI.gfocus].cursory + 1, "")
							
							minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							
							move_down()
						elseif minGUI.gtree[minGUI.gfocus].cursorx < utf8.len(t[minGUI.gtree[minGUI.gfocus].cursory + 1]) then
							local lt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 1, minGUI.gtree[minGUI.gfocus].cursorx)
							local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 1)
							
							t[minGUI.gtree[minGUI.gfocus].cursory + 1] = lt
							
							table.insert(t, minGUI.gtree[minGUI.gfocus].cursory + 2, rt)
							
							minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							
							move_down()
							
							minGUI.gtree[minGUI.gfocus].cursorx = 0
						else
							local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 1)
							
							table.insert(t, minGUI.gtree[minGUI.gfocus].cursory + 2, rt)
							
							minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
							
							move_down()
							
							minGUI.gtree[minGUI.gfocus].cursorx = 0
						end
					end
					
					-- if backspace has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].backspace == 0 then
						-- if backspace is pressed now...
						if love.keyboard.isDown("backspace") == true then
							-- remove character at cursor
							remove_left_char()

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
									-- remove character at cursor
									remove_left_char()

									-- reset kbdelay and increment backspace
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
								end
							-- if backspace is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].backspace > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- remove character at cursor
									remove_left_char()
									
									-- reset kbdelay and increment backspace
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
								end
							end
						end
					end
															
					-- if delete key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].delete == 0 then
						-- if delete key is pressed now...
						if love.keyboard.isDown("delete") == true then
							-- remove character at cursor
							remove_right_char()

							-- count the first delete key, and get the timer
							minGUI.gtree[minGUI.gfocus].delete = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if delete key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].delete > 0 then
						-- if delete key is released now...
						if love.keyboard.isDown("delete") == false then
							minGUI.gtree[minGUI.gfocus].delete = 0
						else
							-- if delete key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].delete == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- remove character at cursor
									remove_right_char()

									-- reset kbdelay and increment delete key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].delete = minGUI.gtree[minGUI.gfocus].delete + 1
								end
							-- if delete key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].delete > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- remove character at cursor
									remove_right_char()
									
									-- reset kbdelay and increment delete key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].delete = minGUI.gtree[minGUI.gfocus].delete + 1
								end
							end
						end
					end
															
					-- if left arrow key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].left == 0 then
						-- if left arrow is pressed now...
						if love.keyboard.isDown("left") == true then
							-- move left
							move_left()
							
							-- count the first left key, and get the timer
							minGUI.gtree[minGUI.gfocus].left = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if left key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].left > 0 then
						-- if left key is released now...
						if love.keyboard.isDown("left") == false then
							minGUI.gtree[minGUI.gfocus].left = 0
						else
							-- if left key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].left == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- move left
									move_left()

									-- reset kbdelay and increment left key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].left = minGUI.gtree[minGUI.gfocus].left + 1
								end
							-- if left key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].left > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- move left
									move_left()
									
									-- reset kbdelay and increment left key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].left = minGUI.gtree[minGUI.gfocus].left + 1
								end
							end
						end
					end
					
					-- if right arrow key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].right == 0 then
						-- if right arrow is pressed now...
						if love.keyboard.isDown("right") == true then
							-- move right
							move_right()
							
							-- count the first right key, and get the timer
							minGUI.gtree[minGUI.gfocus].right = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if right key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].right > 0 then
						-- if right key is released now...
						if love.keyboard.isDown("right") == false then
							minGUI.gtree[minGUI.gfocus].right = 0
						else
							-- if right key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].right == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- move right
									move_right()

									-- reset kbdelay and increment right key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].right = minGUI.gtree[minGUI.gfocus].right + 1
								end
							-- if right key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].right > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- move right
									move_right()
									
									-- reset kbdelay and increment right key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].right = minGUI.gtree[minGUI.gfocus].right + 1
								end
							end
						end
					end

					-- if up arrow key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].up == 0 then
						-- if up arrow is pressed now...
						if love.keyboard.isDown("up") == true then
							-- move up
							move_up()
							
							-- count the first up key, and get the timer
							minGUI.gtree[minGUI.gfocus].up = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if up key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].up > 0 then
						-- if up key is released now...
						if love.keyboard.isDown("up") == false then
							minGUI.gtree[minGUI.gfocus].up = 0
						else
							-- if up key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].up == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- move up
									move_up()

									-- reset kbdelay and increment up key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].up = minGUI.gtree[minGUI.gfocus].up + 1
								end
							-- if up key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].up > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- move up
									move_up()
									
									-- reset kbdelay and increment up key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].up = minGUI.gtree[minGUI.gfocus].up + 1
								end
							end
						end
					end
					
					-- if down arrow key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].down == 0 then
						-- if down arrow is pressed now...
						if love.keyboard.isDown("down") == true then
							-- move down
							move_down()
							
							-- count the first down key, and get the timer
							minGUI.gtree[minGUI.gfocus].down = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if down key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].down > 0 then
						-- if down key is released now...
						if love.keyboard.isDown("down") == false then
							minGUI.gtree[minGUI.gfocus].down = 0
						else
							-- if down key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].down == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- move down
									move_down()

									-- reset kbdelay and increment down key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].down = minGUI.gtree[minGUI.gfocus].down + 1
								end
							-- if down key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].down > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- move down
									move_down()
									
									-- reset kbdelay and increment down key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].down = minGUI.gtree[minGUI.gfocus].down + 1
								end
							end
						end
					end
					
					-- if return arrow key has not yet been pressed...
					if minGUI.gtree[minGUI.gfocus].ret == 0 then
						-- if ret arrow is pressed now...
						if love.keyboard.isDown("return") == true then
							-- move ret
							ret()
							
							-- count the first ret key, and get the timer
							minGUI.gtree[minGUI.gfocus].ret = 1
							minGUI.kbdelay = minGUI.timer
						end
					-- if ret key has been pressed...
					elseif minGUI.gtree[minGUI.gfocus].ret > 0 then
						-- if ret key is released now...
						if love.keyboard.isDown("return") == false then
							minGUI.gtree[minGUI.gfocus].ret = 0
						else
							-- if ret key is still pressed, and has been pressed only one time
							if minGUI.gtree[minGUI.gfocus].ret == 1 then
								-- wait for keyboard slow delay
								if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
									-- move ret
									ret()

									-- reset kbdelay and increment ret key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].ret = minGUI.gtree[minGUI.gfocus].ret + 1
								end
							-- if ret key is still pressed, and has been pressed for multiple times
							elseif minGUI.gtree[minGUI.gfocus].ret > 1 then
								-- wait for keyboard quick delay
								if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
									-- move ret
									ret()
									
									-- reset kbdelay and increment ret key
									minGUI.kbdelay = minGUI.timer
									minGUI.gtree[minGUI.gfocus].ret = minGUI.gtree[minGUI.gfocus].ret + 1
								end
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
function minGUI_textinput(c)
	-- if a gadget has the focus...
	if minGUI.gfocus ~= nil then
		-- if the gadget exists
		if minGUI.gtree[minGUI.gfocus] ~= nil then
			-- if it is a string gadget...
			if minGUI.gtree[minGUI.gfocus].tp == MG_STRING then
				-- if the gadget is editable...
				if minGUI.gtree[minGUI.gfocus].editable == true then
					-- add last character to the text
					minGUI.gtree[minGUI.gfocus].text = minGUI.gtree[minGUI.gfocus].text .. c

					-- calculate the new offset value for the text
					minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_SPIN then
				if c >= "0" and c <= "9" then
					-- add last character to the text
					minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text .. c, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue)
						
					-- calculate the new offset value for the text
					minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_EDITOR then
				-- if the gadget is editable...
				if minGUI.gtree[minGUI.gfocus].editable == true then
					-- explode text
					local t = {}
					
					t = minGUI_explode(minGUI.gtree[minGUI.gfocus].text, "\n")

					-- add the character to the text
					if minGUI.gtree[minGUI.gfocus].cursory == #t then
						t[minGUI.gtree[minGUI.gfocus].cursory + 1] = c
						minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
						minGUI.gtree[minGUI.gfocus].cursorx = minGUI.gtree[minGUI.gfocus].cursorx + 1
					elseif minGUI.gtree[minGUI.gfocus].cursorx == 0 then
						local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 1)
					
						t[minGUI.gtree[minGUI.gfocus].cursory + 1] = c .. rt
						minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
						minGUI.gtree[minGUI.gfocus].cursorx = minGUI.gtree[minGUI.gfocus].cursorx + 1
					else
						local lt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], 1, minGUI.gtree[minGUI.gfocus].cursorx)
						local rt = minGUI_sub_string(t[minGUI.gtree[minGUI.gfocus].cursory + 1], minGUI.gtree[minGUI.gfocus].cursorx + 1)
					
						t[minGUI.gtree[minGUI.gfocus].cursory + 1] = lt .. c .. rt
						minGUI.gtree[minGUI.gfocus].text = minGUI_assemble(t, "\n")
						minGUI.gtree[minGUI.gfocus].cursorx = minGUI.gtree[minGUI.gfocus].cursorx + 1
					end
				end
			end
		end
	end
end
