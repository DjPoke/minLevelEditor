-- function to call from love.load()
function minGUI_init()
	-- set default filter
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	-- constants
	MG_PANEL = 1
	MG_BUTTON = 2
	MG_BUTTON_IMAGE = 3
	MG_LABEL = 4
	MG_STRING = 5 -- todo! finish it
	MG_CANVAS = 6
	MG_CHECKBOX = 7
	MG_OPTION = 8
	MG_SPIN = 9
	MG_EDITOR = 10 -- todo!
	MG_SCROLLBAR = 11 -- todo!
	
	MG_PANEL_IMAGE = 1
	MG_BUTTON_UP_IMAGE = 2
	MG_BUTTON_DOWN_IMAGE = 3
	MG_CHECKBOX_IMAGE = 4
	MG_OPTION_IMAGE = 5
	MG_SPIN_IMAGE = 6
	MG_SPIN_BUTTON_UP_IMAGE = 7
	MG_SPIN_BUTTON_DOWN_IMAGE = 8
	
	MG_LEFT_BUTTON = 1
	MG_RIGHT_BUTTON = 2
	MG_MIDDLE_BUTTON = 3
	
	MG_DEFAULT_FONT = 1
	
	MG_SLOW_DELAY = 0.5
	MG_QUICK_DELAY = 0.05
	
	MG_ALIGN_LEFT = 1
	MG_ALIGN_RIGHT = 2
	MG_ALIGN_CENTER = 3
	
	MG_NOT_EDITABLE = 1

	MG_EVENT_MOUSE_PRESSED = 1
	MG_EVENT_MOUSE_DOWN = 2
	MG_EVENT_MOUSE_RELEASED = 3
	MG_EVENT_MOUSE_CLICK = 3
	
	MG_EVENT_TIMER_TICK = 1
	
	-- init minGUI table
	minGUI = {
		-- attributes
		bgcolor = {r = 0.5, g = 0.5, b = 0.5, a = 1.0}, -- background color
		ptree = {}, -- panel's tree
		gtree = {}, -- gadgets's tree
		mouse = {x = 0, y = 0, oldmbtn = {}, mbtn = {}, mpressed = {}, mreleased = {}}, -- mouse events
		estack = {}, -- events stack
		ptimer = {}, -- programmable timers
		tstack = {}, -- timers events stack
		timer = 0, -- time from start of the app
		kbdelay = 0,
		gfocus = nil, -- gadget focused
		sprite = {}, -- sprites
		font = {}, -- fonts
		numFont = MG_DEFAULT_FONT, -- selected font
		exitProcess = false,
		--
		-- methods ==============================
		--
		-- start a timer, with a delay in milliseconds
		start_timer = function(self, num, delay)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(delay, "number") then minGUI_error_message("Wrong delay value"); return end
			
			minGUI.ptimer[num] = {delay = delay, timer = math.floor(minGUI.timer * 1000)}
		end,
		-- stop a timer
		stop_timer = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end

			minGUI.ptimer[num] = nil
		end,
		-- set background colors (red, green, blue, alpha)
		set_bgcolor = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.bgcolor.r = r
			minGUI.bgcolor.g = g
			minGUI.bgcolor.b = b
			minGUI.bgcolor.a = a
		end,
		load_font = function(self, num, path, size)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			local t = love.filesystem.getInfo(path, "file")

			if t ~= nil and t.type == "file" and t.size > 0 then
				minGUI.font[num] = love.graphics.newFont(path, size)
			end
		end,
		-- set font number
		set_font = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if minGUI.font[num] ~= nil then minGUI.numFont = num end
		end,
		get_gadget_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.estack == 0 then
				return nil, nil
			else
				local eventGadget = minGUI.estack[#minGUI.estack].eventGadget
				local eventType = minGUI.estack[#minGUI.estack].eventType
				
				table.remove(minGUI.estack, #minGUI.estack)

				return eventGadget, eventType
			end
		end,
		get_timer_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.tstack == 0 then
				return nil, nil
			else
				local eventTimer = minGUI.tstack[#minGUI.tstack].eventTimer
				local eventType = minGUI.tstack[#minGUI.tstack].eventType
				
				table.remove(minGUI.tstack, #minGUI.tstack)

				return eventTimer, eventType
			end
		end,
		set_gadget_text = function(self, num, text)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("Wrong text for gadget " .. num); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING then
						-- replace the text
						minGUI.gtree[num].text = text
					
						minGUI_shift_text(num, text)
					elseif minGUI.gtree[num].tp == MG_LABEL then
						-- replace the text
						minGUI.gtree[num].text = text
					end
				else
					-- if the gadget is a spin gadget...
					if minGUI.gtree[num].tp == MG_SPIN then
						-- replace the value
						minGUI.gtree[num].text = frameTextValue(math.floor(tonumber(text) + 0.5), minGUI.gtree[num].minValue, minGUI.gtree[num].maxValue)

						minGUI_shift_text(num, text)
					end				
				end
			end
		end,
		get_gadget_text = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING then
						-- return the text
						return minGUI.gtree[num].text
					elseif minGUI.gtree[num].tp == MG_LABEL then
						-- return the text
						return minGUI.gtree[num].text
					elseif minGUI.gtree[num].tp == MG_SPIN then						
						-- return the text value
						return minGUI.gtree[num].text					
					end
				end
			end
		end,
		set_gadget_state = function(self, num, state)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(state, "boolean") then minGUI_error_message("Wrong state for gadget " .. num); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- if the gadget is an option gadget...
					if minGUI.gtree[num].tp == MG_OPTION then
						-- uncheck all options of the same parent
						minGUI_uncheck_option(minGUI.gtree[num], num)
					end
					
					-- check the gadget
					minGUI.gtree[num].checked = state
				end
			end
		end,
		get_gadget_state = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- return the gadget state
					return minGUI.gtree[num].checked
				end
			end
		end,
		clear_canvas = function(self, num, red, green, blue, alpha)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if red == nil or red < 0.0 or red > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if green == nil or green < 0.0 or green > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if blue == nil or blue < 0.0 or blue > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if alpha == nil or alpha < 0.0 or alpha > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- clear the canvas
			love.graphics.clear(red, green, blue, alpha)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_text_to_canvas = function(self, num, text, x, y, color, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("Wrong text value for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if not minGUI_check_param2(scalex, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(scaley, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			if scalex == nil then scalex = 1 end
			if scaley == nil then scaley = 1 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(color.r, color.g, color.b, color.a)

			-- draw the image
			love.graphics.print(text, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_image_to_canvas = function(self, num, image, x, y, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if image == nil then minGUI_error_message("Wrong image for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(1, 1, 1, 1)

			-- draw the image
			love.graphics.draw(image, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_quad_to_canvas = function(self, num, image, quad, x, y, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if image == nil then minGUI_error_message("Wrong image for gadget " .. num); return end
			if quad == nil then minGUI_error_message("Wrong quad for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(1, 1, 1, 1)

			-- draw the image
			love.graphics.draw(image, quad, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_point_to_canvas = function(self, num, x, y, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a point
			love.graphics.points(x, y)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_line_to_canvas = function(self, num, x1, y1, x2, y2, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param2(x1, "number") then minGUI_error_message("Wrong x1 for gadget " .. num); return end
			if not minGUI_check_param2(y1, "number") then minGUI_error_message("Wrong y1 for gadget " .. num); return end
			if not minGUI_check_param2(x2, "number") then minGUI_error_message("Wrong x2 for gadget " .. num); return end
			if not minGUI_check_param2(y2, "number") then minGUI_error_message("Wrong y2 for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x1 == nil then x1 = 0 end
			if y1 == nil then y1 = 0 end
			if x2 == nil then x2 = 0 end
			if y2 == nil then y2 = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a line
			love.graphics.line(x1, y1, x2, y2)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_arc_to_canvas = function(self, num, mode, x, y, radius, angle1, angle2, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI_error_message("Wrong radius for gadget " .. num); return end
			if not minGUI_check_param(angle1, "number") then minGUI_error_message("Wrong 1st angle for gadget " .. num); return end
			if not minGUI_check_param(angle2, "number") then minGUI_error_message("Wrong 2nd angle for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw an arc
			love.graphics.arc(mode, x, y, radius, angle1, angle2)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_rectangle_to_canvas = function(self, num, mode, x, y, width, height, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a rectangle
			love.graphics.rectangle(mode, x, y, width, height)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_rounded_rectangle_to_canvas = function(self, num, mode, x, y, width, height, rx, ry, segments, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a rectangle
			love.graphics.rectangle(mode, x, y, width, height, rx, ry, segments)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_circle_to_canvas = function(self, num, mode, x, y, radius, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI_error_message("Wrong radius for gadget " .. num); return end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw the polygon
			love.graphics.polygon(mode, vertices)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_polygon_to_canvas = function(self, num, mode, vertices, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("Wrong mode for gadget " .. num); return end
			if vertices == nil then minGUI_error_message("Wrong vertice value for gadget " .. num); return end
			for i = 1, #vertices do
				if type(vertices[i]) ~= "number" then minGUI_error_message("Wrong vertice value for gadget " .. num); return end
			end
			if color.r == nil then color.r = 0 end
			if color.g == nil then color.g = 0 end
			if color.b == nil then color.b = 0 end
			if color.a == nil then color.a = 1 end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("Wrong alpha color for gadget " .. num); return end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw the polygon
			love.graphics.polygon(mode, vertices)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		get_panel_x = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			
			return minGUI.ptree[num].x
		end,
		get_panel_y = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			
			return minGUI.ptree[num].y
		end,
		get_gadget_x = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			
			return minGUI.gtree[num].x
		end,
		get_gadget_y = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value"); return end
			
			return minGUI.gtree[num].y
		end,
		-- add a panel to the panel's tree
		add_panel = function(self, num, x, y, width, height)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for panel"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for panel " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for panel " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for panel " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for panel " .. num); return end

			if minGUI.ptree[num] == nil then
				if width > 0 and height > 0 then
					minGUI.ptree[num] = {
						num = num, tp = MG_PANEL, x = x, y = y, width = width, height = height,
						canvas = love.graphics.newCanvas(width, height)
					}
				end
			end
		end,
		-- add a button to the gadgets's tree
		add_button = function(self, num, x, y, width, height, text, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for button"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for button " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for button " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for button " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for button " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("Wrong text for button " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for button " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON, x = x, y = y, width = width, height = height, text = text, parent = parent, down = false,
							r = 0, g = 0, b = 0, a = 1,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
		end,
		-- add a button image to the gadgets's tree
		add_button_image = function(self, num, x, y, width, height, image, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for button image"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for button image " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for button image " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for button image " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for button image " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for button image " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON_IMAGE, x = x, y = y, width = width, height = height, text = text, parent = parent, down = false,
							image = image,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
		end,
		-- add a label to the gadgets's tree
		add_label = function(self, num, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for label"); return end
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("Wrong x for label " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("Wrong y for label " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for label " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for label " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("Wrong text for label " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for label " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- default alignement to left
			if flags == nil then
				flags = MG_ALIGN_LEFT
			elseif type(flags) == "number" then
				flags = bit.band(flags, MG_ALIGN_CENTER)
							
				if flags == 0 then flags = MG_ALIGN_LEFT end
			else
				minGUI_error_message("Wrong flags for label " .. num)
				love.event.quit(1)
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then

						minGUI.gtree[num] = {
							num = num, tp = MG_LABEL, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rpaper = 0.5, gpaper = 0.5, bpaper = 0.5, apaper = 1,
							rpen = 0, gpen = 0, bpen = 0, apen = 1,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
		end,
		-- add an editable string gadget to the gadgets's tree
		add_string = function(self, num, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for string"); return end
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("Wrong x for string " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("Wrong y for string " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for string " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for string " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("Wrong text for string " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for string " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("Wrong flags for string " .. num)
				love.event.quit(1)
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						-- editable by default
						if flags == nil then flags = 0 end
						
						minGUI.gtree[num] = {
							num = num, tp = MG_STRING, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = 0, gborder = 0, bborder = 0, aborder = 1,
							rpaper = 1, gpaper = 1, bpaper = 1, apaper = 1,
							rpapergreyed = 0.75, gpapergreyed = 0.75, bpapergreyed = 0.75, apapergreyed = 1,
							rpen = 0, gpen = 0, bpen = 0, apen = 1,
							offset = 0, editable = true, backspace = 0,
							canvas = love.graphics.newCanvas(width - 4, height - 4)
						}
						
						-- set to not editable ?
						if bit.band(flags, MG_NOT_EDITABLE) == MG_NOT_EDITABLE then
							minGUI.gtree[num].editable = false
						end
						
						-- shift text left, if needed
						minGUI_shift_text(num, text)
						
						-- set the focus to the last editable gadget
						minGUI.gfocus = num
					end
				end
			end
		end,
		-- add a canvas gadget to the gadgets's tree
		add_canvas = function(self, num, x, y, width, height, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for canvas"); return end
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("Wrong x for canvas " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("Wrong y for canvas " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for canvas " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for canvas " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for canvas " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("Wrong flags for canvas " .. num)
				love.event.quit(1)
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_CANVAS, x = x, y = y, width = width, height = height, flags = flags, parent = parent, down = false,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
		
			-- fill the canvas in white
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", 0, 0, minGUI.gtree[num].width, minGUI.gtree[num].height)
	
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		-- add a checkbox to the gadgets's tree
		add_checkbox = function(self, num, x, y, width, height, text, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for checkbox"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for checkbox " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for checkbox " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for checkbox " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for checkbox " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("Wrong text for checkbox " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for checkbox " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_CHECKBOX, x = x, y = y, width = width, height = height, text = text, parent = parent,
							checked = false,
							r = 0, g = 0, b = 0, a = 1,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
		end,
		-- add an option gadget to the gadgets's tree
		add_option = function(self, num, x, y, width, height, text, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for option"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for option " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for option " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for option " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for option " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("Wrong text for option " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for option " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_OPTION, x = x, y = y, width = width, height = height, text = text, parent = parent,
							checked = false,
							r = 0, g = 0, b = 0, a = 1,
							canvas = love.graphics.newCanvas(width, height)
						}
					end
				end
			end
		end,
		-- add a spin gadget to the gadgets's tree
		add_spin = function(self, num, x, y, width, height, value, minValue, maxValue, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for spin"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("Wrong x for spin " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("Wrong y for spin " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for spin " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for spin " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI_error_message("Wrong value for spin " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI_error_message("Wrong min value for spin " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI_error_message("Wrong max value for spin " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for spin " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if maxValue == nil then maxValue = 9 end

			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)
			
			local value = math.min(math.max(math.floor(value + 0.5), minValue), maxValue)
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_SPIN, x = x, y = y, width = width, height = height, parent = parent,
							down = false, btnUp = false, btnDown = false,
							text = tostring(value), minValue = minValue, maxValue = maxValue, timer = 0,
							rpaper = 1, gpaper = 1, bpaper = 1, apaper = 1,
							rpen = 0, gpen = 0, bpen = 0, apen = 1,
							offset = 0, backspace = 0, press = 0,
							canvas = love.graphics.newCanvas(width, height)
						}
												
						-- shift text left, if needed
						minGUI_shift_text(num, text)

						-- set the focus to the last editable gadget
						minGUI.gfocus = num
					end
				end
			end
		end,
		-- add an editor gadget to the gadgets's tree
		add_editor = function(self, num, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("Wrong num value for editor"); return end
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("Wrong x for editor " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("Wrong y for editor " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("Wrong width for editor " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("Wrong height for editor " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("Wrong text for editor " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("Wrong parent for editor " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("Wrong flags for editor " .. num)
				love.event.quit(1)
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.ptree[parent] ~= nil then
					if width > 0 and height > 0 then
						-- editable by default
						if flags == nil then flags = 0 end
						
						minGUI.gtree[num] = {
							num = num, tp = MG_EDITOR, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = 0, gborder = 0, bborder = 0, aborder = 1,
							rpaper = 1, gpaper = 1, bpaper = 1, apaper = 1,
							rpapergreyed = 0.75, gpapergreyed = 0.75, bpapergreyed = 0.75, apapergreyed = 1,
							rpen = 0, gpen = 0, bpen = 0, apen = 1,
							editable = true, cursorx = 0, cursory = 0,
							canvas = love.graphics.newCanvas(width - 4, height - 4)
						}
						
						-- set to not editable ?
						if bit.band(flags, MG_NOT_EDITABLE) == MG_NOT_EDITABLE then
							minGUI.gtree[num].editable = false
						end
						
						-- set the focus to the last editable gadget
						minGUI.gfocus = num
					end
				end
			end
		end
	}
	
	-- set events to default
	minGUI.mouse.x, minGUI.mouse.y = love.mouse.getPosition()
	
	for i = 1, 3 do
		minGUI.mouse.oldmbtn[i] = false
		minGUI.mouse.mbtn[i] = love.mouse.isDown(i)
		minGUI.mouse.mpressed[i] = false
		minGUI.mouse.mreleased[i] = false
	end
	
	-- load 9-slice sprites
	minGUI_load_9slice(MG_PANEL_IMAGE, "minGUI/theme/panel.png")
	minGUI_load_9slice(MG_BUTTON_UP_IMAGE, "minGUI/theme/button_up.png")
	minGUI_load_9slice(MG_BUTTON_DOWN_IMAGE, "minGUI/theme/button_down.png")
	minGUI_load_9slice(MG_SPIN_IMAGE, "minGUI/theme/spin.png")

	-- load sprites
	minGUI_load_sprite(MG_CHECKBOX_IMAGE, "minGUI/theme/checkbox.png")
	minGUI_load_sprite(MG_OPTION_IMAGE, "minGUI/theme/option.png")
	minGUI_load_sprite(MG_SPIN_BUTTON_UP_IMAGE, "minGUI/theme/spin_buttons_up.png")
	minGUI_load_sprite(MG_SPIN_BUTTON_DOWN_IMAGE, "minGUI/theme/spin_buttons_down.png")
	
	-- load default fonts
	minGUI.font[MG_DEFAULT_FONT] = love.graphics.newFont(12)
end