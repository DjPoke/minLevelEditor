-- draw a gadget
function minGUI_draw_gadget(w, ox, oy)
	-- draw buttons
	if w.tp == MG_BUTTON then		
		if not w.down.left then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, w.width, w.height, w.canvas)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, w.width, w.height, w.canvas)
		end
		
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.r, w.g, w.b, w.a)

		-- print the text centered
		love.graphics.print(w.text, ((w.width - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) - 1, ((w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2) - 1)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	-- draw button images
	elseif w.tp == MG_BUTTON_IMAGE then
		if not w.down.left then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, w.width, w.height, w.canvas)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, w.width, w.height, w.canvas)
		end

		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- draw the image
		if not w.down.left then
			love.graphics.draw(w.image, 4, 4, 0, (w.width - 8) / w.image:getWidth(), (w.height - 8) / w.image:getHeight())
		else
			love.graphics.draw(w.image, 3, 3, 0, (w.width - 6) / w.image:getWidth(), (w.height - 6) / w.image:getHeight())
		end
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	-- draw labels
	elseif w.tp == MG_LABEL then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

		-- print the text with differents alignments
		if w.flags == MG_ALIGN_LEFT then
			love.graphics.print(w.text, 0, ((w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2) - 1)
		elseif w.flags == MG_ALIGN_RIGHT then
			love.graphics.print(w.text, w.width - minGUI.font[minGUI.numFont]:getWidth(w.text), ((w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2) - 1)
		elseif w.flags == MG_ALIGN_CENTER then
			love.graphics.print(w.text, ((w.width - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) - 1, ((w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2) - 1)
		end
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	elseif w.tp == MG_STRING then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		if w.editable == true then
			love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.clear(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

		-- print the text
		if w.text ~= "" then
			text = minGUI_sub_string(w.text, w.offset + 1)
			love.graphics.print(text, 0, ((w.height - 4 - minGUI.font[minGUI.numFont]:getHeight(text)) / 2) - 1)
		end
								
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the border
		love.graphics.setColor(w.rborder, w.gborder, w.bborder, w.aborder)
		love.graphics.rectangle("line", ox + w.x, oy + w.y, w.width, w.height)
		
		-- draw 'inside' border
		if w.editable == true then
			love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.setColor(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
		
		love.graphics.rectangle("fill", ox + w.x + 1, oy + w.y + 1, w.width - 2, w.height - 2)

		-- draw the canvas
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x + 2, oy + w.y + 2)
	elseif w.tp == MG_CANVAS then
		-- draw the canvas on screen
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	elseif w.tp == MG_CHECKBOX then		
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
		
		-- draw checkbox button
		minGUI_draw_sprite(MG_CHECKBOX_IMAGE, 0, (w.height - 14) / 2)
		
		-- draw a black box inside if checked
		if w.checked == true then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", 4, (w.height - 5) / 2, 6, 6)
		end
	
		-- draw the text at the right of the button
		love.graphics.setFont(minGUI.font[minGUI.numFont])
		love.graphics.setColor(w.r, w.g, w.b, w.a)
		love.graphics.print(w.text, 16, (w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2)

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	elseif w.tp == MG_OPTION then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
	
		-- draw option button
		minGUI_draw_sprite(MG_OPTION_IMAGE, 0, (w.height - 14) / 2)

		-- draw a black box inside if checked
		if w.checked == true then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", 4, (w.height - 5) / 2, 6, 6)
		end

		-- draw the text at the right of the button
		love.graphics.setFont(minGUI.font[minGUI.numFont])
		love.graphics.setColor(w.r, w.g, w.b, w.a)
		love.graphics.print(w.text, 16, (w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	elseif w.tp == MG_SPIN then
		-- draw spin value
		minGUI_draw_9slice(MG_SPIN_IMAGE, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth() - 1, w.height, w.canvas)

		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)

		-- draw spin buttons
		local btnUp = love.graphics.newQuad(0, 0, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight())
		local btnDown = love.graphics.newQuad(0, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight())
		
		if w.btnUp == false then
			minGUI_draw_quad(MG_SPIN_BUTTON_UP_IMAGE, btnUp, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()))
		else
			minGUI_draw_quad(MG_SPIN_BUTTON_DOWN_IMAGE, btnUp, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()))
		end

		if w.btnDown == false then
			minGUI_draw_quad(MG_SPIN_BUTTON_UP_IMAGE, btnDown, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2))
		else
			minGUI_draw_quad(MG_SPIN_BUTTON_DOWN_IMAGE, btnDown, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2))
		end

		-- draw the text value in its area
		love.graphics.setFont(minGUI.font[minGUI.numFont])
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.print(w.text, (((w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()) - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2), (w.height - minGUI.font[minGUI.numFont]:getHeight(w.text)) / 2)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
	elseif w.tp == MG_EDITOR then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		if w.editable == true then
			love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.clear(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

		-- print the text
		if w.text ~= "" then
			love.graphics.print(w.text, 0, 0)
		end
								
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the border
		love.graphics.setColor(w.rborder, w.gborder, w.bborder, w.aborder)
		love.graphics.rectangle("line", ox + w.x, oy + w.y, w.width, w.height)
		
		-- draw 'inside' border
		if w.editable == true then
			love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.setColor(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
		
		love.graphics.rectangle("fill", ox + w.x + 1, oy + w.y + 1, w.width - 2, w.height - 2)

		-- draw the canvas
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(w.canvas, ox + w.x + 2, oy + w.y + 2)
	end
end


-- function to call from love.draw()
function minGUI_draw_all()
	love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
	love.graphics.setColor(1, 1, 1, 1)

	-- draw panels and their gadgets
	for i, v in ipairs(minGUI.ptree) do
		-- draw panels first
		if v.tp == MG_PANEL then
			minGUI_draw_9slice(MG_PANEL_IMAGE, v.width, v.height, v.canvas)
			
			love.graphics.draw(v.canvas, v.x, v.y)

			-- draw sons gadgets
			for j, w in ipairs(minGUI.gtree) do
				if w.parent == v.num then
					minGUI_draw_gadget(w, v.x, v.y)

					-- draw cursor on focused object,if needed
					if minGUI.gfocus ~= nil and minGUI.gfocus == j then
						if minGUI.gtree[j] ~= nil then
							w = minGUI.gtree[j]
				
							-- if the focused gadget is a string gadget...
							if w.tp == MG_STRING then
								local t = math.floor(minGUI.timer * 1000) % 1000

								if t < 500 then
									minGUI_draw_text_cursor(w, v.x, v.y)
								else
									minGUI_hide_text_cursor(w, v.x, v.y)
								end
							-- if the focused gadget is a spin gadget...
							elseif w.tp == MG_SPIN then
								local t = math.floor(minGUI.timer * 1000) % 1000
						
								if t < 500 then
									minGUI_draw_text_cursor(w, v.x, v.y)
								else
									minGUI_hide_text_cursor(w, v.x, v.y)
								end
							-- if the focused gadget is an editor gadget...
							elseif w.tp == MG_EDITOR then
								local t = math.floor(minGUI.timer * 1000) % 1000
						
								if t < 500 then
									minGUI_draw_editor_cursor(w, v.x, v.y)
								else
									minGUI_hide_editor_cursor(w, v.x, v.y)
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- draw gadgets without panels
	for j, w in ipairs(minGUI.gtree) do
		if w.parent == nil then
			minGUI_draw_gadget(w, 0, 0)

			-- draw cursor on focused object,if needed
			if minGUI.gfocus ~= nil and minGUI.gfocus == j then
				if minGUI.gtree[j] ~= nil then
					w = minGUI.gtree[j]
			
					-- if the focused gadget is a string gadget...
					if w.tp == MG_STRING then
						local t = math.floor(minGUI.timer * 1000) % 1000
				
						if t < 500 then
							minGUI_draw_text_cursor(w, 0, 0)
						else
							minGUI_hide_text_cursor(w, 0, 0)
						end
					-- if the focused gadget is a spin gadget...
					elseif w.tp == MG_SPIN then
						local t = math.floor(minGUI.timer * 1000) % 1000
						
						if t < 500 then
							minGUI_draw_text_cursor(w, 0, 0)
						else
							minGUI_hide_text_cursor(w, 0, 0)
						end
					-- if the focused gadget is an editor gadget...
					elseif w.tp == MG_EDITOR then
						local t = math.floor(minGUI.timer * 1000) % 1000
						
						if t < 500 then
							minGUI_draw_editor_cursor(w, 0, 0)
						else
							minGUI_hide_editor_cursor(w, 0, 0)
						end
					end
				end
			end
		end
	end
	
end

-- draw the text cursor in the focused gadget
function minGUI_draw_text_cursor(w, ox, oy)
	local xc = 0
	local yc = 0
	
	if w.tp == MG_STRING then
		xc = ox + w.x + 2 + minGUI.font[minGUI.numFont]:getWidth(string.sub(w.text, w.offset + 1))
		yc = oy + w.y + ((w.height - 2) - minGUI.font[minGUI.numFont]:getHeight("|")) / 2
	elseif w.tp == MG_SPIN then
		
		xc = ox + w.x + (((w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()) - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) + minGUI.font[minGUI.numFont]:getWidth(w.text)
		yc = oy + w.y + ((w.height - 2) - minGUI.font[minGUI.numFont]:getHeight("|")) / 2
	end
		
	love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
	love.graphics.rectangle("fill", xc, yc, 1, minGUI.font[minGUI.numFont]:getHeight("|"))	
	love.graphics.setColor(1, 1, 1, 1)
end

-- hide the text cursor in the focused gadget
function minGUI_hide_text_cursor(w, ox, oy)
	local xc = 0
	local yc = 0
	
	if w.tp == MG_STRING then
		xc = ox + w.x + 2 + minGUI.font[minGUI.numFont]:getWidth(string.sub(w.text, w.offset + 1))
		yc = oy + w.y + ((w.height - 2) - minGUI.font[minGUI.numFont]:getHeight("|")) / 2
	elseif w.tp == MG_SPIN then
		xc = ox + w.x + 2 + minGUI.font[minGUI.numFont]:getWidth(string.sub(w.text, w.offset + 1))
		yc = oy + w.y + ((w.height - 2) - minGUI.font[minGUI.numFont]:getHeight("|")) / 2
	end
	
	love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
	love.graphics.rectangle("fill", xc, yc, 1, minGUI.font[minGUI.numFont]:getHeight("|"))	
	love.graphics.setColor(1, 1, 1, 1)
end

-- draw the editor cursor
function minGUI_draw_editor_cursor(w, ox, oy)
	local xc = ox + w.x + 2
	local yc = oy + w.y + 2

	-- explode utf8 text
	t = {}

	t = minGUI_explode(w.text, "\n")
	
	--search for cursor y position
	for y = 0, w.cursory - 1 do
		yc = yc + minGUI.font[minGUI.numFont]:getHeight(t[y + 1])
	end
	
	--search for cursor x position
	if w.cursory == #t then
		-- don't move xc if at last line...
	else
		for x = 0, w.cursorx - 1 do
			local c = string.sub(t[w.cursory + 1], x + 1, x + 1)
			
			xc = xc + minGUI.font[minGUI.numFont]:getWidth(c)
		end
	end
	
	love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
	love.graphics.rectangle("fill", xc, yc, 1, minGUI.font[minGUI.numFont]:getHeight("|"))	
	love.graphics.setColor(1, 1, 1, 1)
end

-- hide the editor cursor
function minGUI_hide_editor_cursor(w, ox, oy)
	local xc = ox + w.x + 2
	local yc = oy + w.y + 2
	local t = {}
	
	-- separate sentences
	for str in string.gmatch(w.text, "\n") do
		table.insert(t, str)
	end
	
	--search for cursor position
	for y = 1, w.cursory do
		--yc = yc + minGUI.font[minGUI.numFont]:getHeight(t[y - 1])
	end
		
	for x = 1, w.cursorx do
		---xc = xc + minGUI.font[minGUI.numFont]:getWidth(t[x - 1])
	end
		
	love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
	love.graphics.rectangle("fill", xc, yc, 1, minGUI.font[minGUI.numFont]:getHeight("|"))	
	love.graphics.setColor(1, 1, 1, 1)
end

-- load 9-slice sprite
function minGUI_load_9slice(num, filename)
	if minGUI_get_file_exists(filename) == true then
		minGUI.sprite[num] = love.graphics.newImage(filename)
	else
		minGUI_error_message("Can't load the file " .. filename)
	end
end

-- load a sprite
function minGUI_load_sprite(num, filename)
	if minGUI_get_file_exists(filename) == true then
		minGUI.sprite[num] = love.graphics.newImage(filename)
	else
		minGUI_error_message("Can't load the file " .. filename)
	end
end

-- draw a 9-slice sprite
function minGUI_draw_9slice(num, width, height, canvas)
	-- can't go under a special size
	if width <= 0 then return end
	if height <= 0 then return end
	
	-- parts of images
	local p = {}
	
	-- quads size x & y
	local qsx = minGUI.sprite[num]:getWidth() / 3
	local qsy = minGUI.sprite[num]:getHeight() / 3
	
	-- maximum number of rows and columns of quads
	local tx = math.floor(width / qsx)
	local ty = math.floor(height / qsy)

	-- unused pieces of tiles
	local px = (width - (tx * qsx)) / tx
	local py = (height - (ty * qsy)) / ty

	-- real size of tiles
	local rsx = qsx + px
	local rsy = qsy + py
	
	-- scale x & y values
	local sx = rsx / qsx
	local sy = rsy / qsy
	
	-- get limits
	local limitx = tx - 1
	local limity = ty - 1
	
	-- separate texture in 9 quads
	p[1] = love.graphics.newQuad(0, 0, qsx, qsy, minGUI.sprite[num])
	p[2] = love.graphics.newQuad(qsx, 0, qsx, qsy, minGUI.sprite[num])
	p[3] = love.graphics.newQuad(qsx * 2, 0, qsx, qsy, minGUI.sprite[num])
	p[4] = love.graphics.newQuad(0, qsy, qsx, qsy, minGUI.sprite[num])
	p[5] = love.graphics.newQuad(qsx, qsy, qsx, qsy, minGUI.sprite[num])
	p[6] = love.graphics.newQuad(qsx * 2, qsy, qsx, qsy, minGUI.sprite[num])
	p[7] = love.graphics.newQuad(0, qsy * 2, qsx, qsy, minGUI.sprite[num])
	p[8] = love.graphics.newQuad(qsx, qsy * 2, qsx, qsy, minGUI.sprite[num])
	p[9] = love.graphics.newQuad(qsx * 2, qsy * 2, qsx, qsy, minGUI.sprite[num])

	-- draw the quads on the canvas
	--=============================

	-- render to the canvas
	love.graphics.setCanvas(canvas)

	-- draw top left corner
	love.graphics.draw(minGUI.sprite[num], p[1], 0, 0, 0, sx, sy)

	-- draw top right corner
	love.graphics.draw(minGUI.sprite[num], p[3], (limitx * rsx), 0, 0, sx, sy)

	-- draw bottom left corner
	love.graphics.draw(minGUI.sprite[num], p[7], 0, (limity * rsy), 0, sx, sy)
			
	-- draw bottom right corner
	love.graphics.draw(minGUI.sprite[num], p[9], (limitx * rsx), (limity * rsy), 0, sx, sy)

	-- draw edges
	for x9 = 1, limitx - 1 do
		love.graphics.draw(minGUI.sprite[num], p[2], (x9 * rsx), 0, 0, sx, sy)
		love.graphics.draw(minGUI.sprite[num], p[8], (x9 * rsx), (limity * rsy), 0, sx, sy)
	end
	
	for y9 = 1, limity - 1 do
		love.graphics.draw(minGUI.sprite[num], p[4], 0, (y9 * rsy), 0, sx, sy)
		love.graphics.draw(minGUI.sprite[num], p[6], (limitx * rsx), (y9 * rsy), 0, sx, sy)
	end
		
	-- draw center
	for y9 = 1, limity - 1 do
		for x9 = 1, limitx - 1 do		
			love.graphics.draw(minGUI.sprite[num], p[5], (x9 * rsx), (y9 * rsy), 0, sx, sy)
		end
	end
	
	-- render to window
	love.graphics.setCanvas()
end

-- draw a single sprite
function minGUI_draw_sprite(num, x, y)
	-- draw the image
	love.graphics.draw(minGUI.sprite[num], x, y)
end

-- draw a quad of a sprite
function minGUI_draw_quad(num, quad, x, y)
	-- draw the quad
	love.graphics.draw(minGUI.sprite[num], quad, x, y)
end