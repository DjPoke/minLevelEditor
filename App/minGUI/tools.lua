-- check for a parameter
function minGUI_check_param(v, t)
	if v == nil or type(v) ~= t then return false else return true end
end

-- check a parameter (accepts nill)
function minGUI_check_param2(v, t)
	if v == nil then
		return true
	elseif type(v) ~= t then
		return false
	end
	
	return true
end

-- throw a message
function minGUI_error_message(msg)
	love.window.showMessageBox("error", msg, "error", true)
	minGUI.exitProcess = true
	
	love.event.quit()
end

-- shift text left, if needed
function minGUI_shift_text(num, text)
	-- reset offset
	minGUI.gtree[num].offset = 0

	while minGUI.font[minGUI.numFont]:getWidth(text) >= minGUI.gtree[num].width - 6 do
		-- get the first letter's size, in pixels
		text = minGUI_sub_string(text, 2)
						
		-- shift the text left of one character
		minGUI.gtree[num].offset = minGUI.gtree[num].offset + 1
	end
end

-- utf8 string.sub
function minGUI_sub_string(text, v1, v2)
	if v1 == nil then v1 = 1 end
	if v2 == nil then v2 = -1 end
	
	-- get the byte offset to the last UTF-8 character in the string.
	local byteoffset1 = utf8.offset(text, v1)

	-- get the byte offset to the last UTF-8 character in the string.
	local byteoffset2 = utf8.offset(text, v2)

	-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
    return string.sub(text, byteoffset1, byteoffset2)
end

-- uncheck all option gadgets of the same parent
function minGUI_uncheck_option(v, num)
	for j, w in ipairs(minGUI.gtree) do
		-- if an other gadget than the option one is checked...
		if j ~= num then
			-- if the new gadget is an option one...
			if w.tp == MG_OPTION then
				-- if he has the same parent...
				if w.parent == v.parent then
					-- uncheck it !
					w.checked = false
				end
			end
		end
	end
end

-- check if a file exists
function minGUI_get_file_exists(path)
	local info = love.filesystem.getInfo(path)
	
	if info ~= nil and info.type == "file" and info.size > 0 then
		return true
	end
	
	return false
end

-- check if a folder exists
function minGUI_get_folder_exists(path)
	local info = love.filesystem.getInfo(path)
	
	if info ~= nil and info.type == "directory" then
		return true
	end
	
	return false
end

-- frame a text value between min and max values
function frameTextValue(t, mn, mx)
	if t == "" then t = "0" end
	
	local v = tonumber(t)
	
	if v < mn then v = mn end
	if v > mx then v = mx end
	
	t = tostring(v)
	
	return t
end

-- increment text value
function IncTextValue(t)
	if t == "" then t = "0" end
	
	local v = tonumber(t) + 1

	t = tostring(v)	

	return t
end

-- decrement text value
function DecTextValue(t)
	if t == "" then t = "0" end
	
	local v = tonumber(t) - 1

	t = tostring(v)	

	return t
end
