--================
-- minLevelEditor
--
-- by DjPoke
-- (MIT) 2023
--================

-- require minGUI
require "minGUI.minGUI"

-- default love.load function
function love.load()
	MAX_MAP_SIZE = 128
	MAX_TILESET_SIZE = 64
	DEFAULT_MAP_SIZE = 64
	
	BLACK = {r = 0, g = 0, b = 0, a = 1}
	GREY = {r = 0.5, g = 0.5, b = 0.5, a = 1}
	RED = {r = 1, g = 0, b = 0, a = 1}
	
	tileSize = 16
	tileset = nil
	tileid = 0
	tilequad = nil
	tilex = 0
	tiley = 0
	tilesetZoom = 1
	tilemapZoom = 1
	mapWidth = DEFAULT_MAP_SIZE
	mapHeight = DEFAULT_MAP_SIZE
	tilesetWidth = 0
	tilesetHeight = 0
	
	export_string = ""
	steps = 0
	xexport = 0
	yexport = 0
	
	-- create quads array
	quad = {}
	
	for x = 0, MAX_TILESET_SIZE - 1 do
		quad[x] = {}
		
		for y = 0, MAX_TILESET_SIZE - 1 do
			quad[x][y] = nil
		end
	end

	-- create walls map
	wallMap = {}
	
	for x = 0, MAX_TILESET_SIZE - 1 do
		wallMap[x] = {}
		
		for y = 0, MAX_TILESET_SIZE - 1 do
			wallMap[x][y] = false
		end
	end
			
	-- create a map array
	map = {}
	
	for x = 0, MAX_MAP_SIZE - 1 do
		map[x] = {}
		
		for y = 0, MAX_MAP_SIZE - 1 do
			map[x][y] = 0
		end
	end
			
	-- initialize minGUI
	minGUI_init()
	
	-- set background color
	minGUI:set_bgcolor(0.5, 0.5, 0.5, 1)

	-- add all panels
	minGUI:add_panel(1, 0, 0, 128, 577)
	minGUI:add_panel(2, 128, 0, 1060, 577)
	minGUI:add_panel(3, 1188, 0, 548, 577)
	minGUI:add_panel(4, 8, 8, 112, 96)
	minGUI:add_panel(5, 8, 112, 112, 96)
	minGUI:add_panel(6, 8, 216, 112, 96)
	
	-- add canvas gadgets for tilemap and tileset
	minGUI:add_canvas(1, 8, 8, 1024, 512, nil, 2)
	minGUI:add_canvas(2, 8, 8, 512, 512, nil, 3)

	-- clear the canvas in black
	minGUI:clear_canvas(1, 0, 0, 0, 1)
	minGUI:clear_canvas(2, 0, 0, 0, 1)

	-- select tile size
	minGUI:add_label(3, 8, 8, 100, 25, "TILE SIZE", MG_ALIGN_CENTER,  4)
	minGUI:add_option(4, 8, 37, 100, 25, "16x16 pixels", 4)
	minGUI:add_option(5, 8, 64, 100, 25, "32x32 pixels", 4)	
	minGUI:set_gadget_state(4, true)
	
	-- load a tileset
	minGUI:add_label(6, 8, 8, 100, 25, "TILESET", MG_ALIGN_CENTER,  5)
	minGUI:add_string(7, 8, 37, 100, 25, "", nil, 5)
	minGUI:add_button(8, 8, 64, 100, 25, "Load", 5)

	-- zoom x 2 checkboxes
	minGUI:add_checkbox(9, 8, 548, 100, 25, "Zoom x 2", 2)

	-- zoom x 2 checkboxes
	minGUI:add_checkbox(10, 8, 548, 100, 25, "Zoom x 2", 3)

	-- button to copy the map to clipboard
	minGUI:add_button(11, 420, 548, 160, 25, "Copy map to clipboard", 2)

	minGUI:add_label(12, 8, 8, 100, 25, "MAP SIZE", MG_ALIGN_CENTER,  6)
	minGUI:add_spin(13, 8, 37, 100, 25, mapWidth, 1, MAX_MAP_SIZE, 6)
	minGUI:add_spin(14, 8, 64, 100, 25, mapHeight, 1, MAX_MAP_SIZE, 6)

	minGUI:add_button(15, 320, 548, 100, 25, "Clear the map", 2)

	-- button to copy the collision map to clipboard
	minGUI:add_button(16, 180, 548, 220, 25, "Copy collision's map to clipboard", 3)
	
	-- add scrollbars to the tilemap
	minGUI:add_scrollbar(17, 8, 520, 1024, 20, 0, 0, MAX_MAP_SIZE - 1, 1, nil, 2)
	minGUI:add_scrollbar(18, 1032, 8, 20, 512, 0, 0, MAX_MAP_SIZE - 1, 1, MG_SCROLLBAR_VERTICAL, 2)

	-- add scrollbars to the tileset
	minGUI:add_scrollbar(19, 8, 520, 512, 20, 0, 0, MAX_TILESET_SIZE - 1, MAX_TILESET_SIZE, nil, 3)
	minGUI:add_scrollbar(20, 520, 8, 20, 512, 0, 0, MAX_TILESET_SIZE - 1, MAX_TILESET_SIZE, MG_SCROLLBAR_VERTICAL, 3)

	-- draw grids
	redraw_tilemap_grid()
	redraw_tileset_grid()
	
	-- reset default focuset gadget
	minGUI:set_focus(nil)
end

-- default love.textinput function
function love.textinput(t)
	-- send text input to minGUI
    minGUI_textinput(t)
end

-- default love.update function
function love.update(dt)
	-- update events list for minGUI
	minGUI_update_events(dt)

	-- ============================================
	
	-- exit on escape key
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	-- ============================================

	oldmapWidth = mapWidth
	oldmapHeight = mapHeight
	
	local w = minGUI:get_gadget_text(13)
	local h = minGUI:get_gadget_text(14)
	
	if w ~= "" then mapWidth = tonumber(w) end
	if h ~= "" then mapHeight = tonumber(h) end
	
	if oldmapWidth ~= mapWidth or oldmapHeight ~= mapHeight then
		minGUI:clear_canvas(1, 0, 0, 0, 1)
		
		redraw_tilemap()
		redraw_tilemap_grid()
	end
		
	-- ============================================
		
	-- get tile size
	if minGUI:get_gadget_state(4) == true then
		if tileSize == 32 then
			tileSize = 16

			-- reset quad size
			requad_all()
			
			-- clear the map
			clear_map()
			
			-- redraw tileset
			redraw_tileset()
			redraw_tileset_grid()
			
			-- redraw tilemap
			redraw_tilemap()
			redraw_tilemap_grid()
		end
	elseif minGUI:get_gadget_state(5) == true then
		if tileSize == 16 then			
			tileSize = 32

			-- reset quad size
			requad_all()
			
			-- clear the map
			clear_map()

			-- redraw tileset
			redraw_tileset()
			redraw_tileset_grid()
			
			-- redraw tilemap
			redraw_tilemap()
			redraw_tilemap_grid()
		end
	end

	-- ============================================

	-- get the zoom for the tilemap
	if minGUI:get_gadget_state(9) == true then
		if tilemapZoom == 1 then
			tilemapZoom = 2
			
			redraw_tilemap()
			redraw_tilemap_grid()
		end
	else
		if tilemapZoom == 2 then
			tilemapZoom = 1			
			
			redraw_tilemap()
			redraw_tilemap_grid()
		end
	end

	-- ============================================	

	-- get the zoom for the tileset
	if minGUI:get_gadget_state(10) == true then
		if tilesetZoom == 1 then
			tilesetZoom = 2
			
			redraw_tileset()
			redraw_tileset_grid()
		end
	else
		if tilesetZoom == 2 then
			tilesetZoom = 1
			
			redraw_tileset()
			redraw_tileset_grid()
		end
	end
	

	-- draw the selected tile
	if tileset ~= nil then
		if tilex > (tilesetWidth / tileSize) - 1 then tilex = (tilesetWidth / tileSize) - 1 end
		if tiley > (tilesetHeight / tileSize) - 1 then tiley = (tilesetHeight / tileSize) - 1 end
		
		if (minGUI.timer * 500) % 500 < 250 then
			minGUI:draw_rectangle_to_canvas(2, "line", tilex * tileSize * tilesetZoom, tiley * tileSize * tilesetZoom, tileSize * tilesetZoom, tileSize * tilesetZoom, { r = 0, g = 0, b = 0, a = 1})
		else
			minGUI:draw_rectangle_to_canvas(2, "line", tilex * tileSize * tilesetZoom, tiley * tileSize * tilesetZoom, tileSize * tilesetZoom, tileSize * tilesetZoom, { r = 1, g = 1, b = 1, a = 1})
		end
	end

	-- ============================================
		
	-- get new events
	local eventGadget, eventType = minGUI:get_gadget_events()
	
	-- if button 8 has been clicked, load the tileset
	if eventType == MG_EVENT_LEFT_MOUSE_CLICK then
		if eventGadget == 8 then
			load_tileset()
		elseif eventGadget == 11 then
			-- export the map
			export_string = "map = {\r\n"

			for yexport = 0, mapHeight - 1 do
				for xexport = 0, mapWidth - 1 do
					export_string = export_string .. map[xexport][yexport] .. ","
				end

				-- linefeed
				export_string = export_string .. "\r\n"
			end
					
			-- remove last comma
			local byteoffset = utf8.offset(export_string, -1)

			if byteoffset then
				export_string = string.sub(export_string, 1, byteoffset - 1)
			end

			export_string = export_string .. "}"

			love.system.setClipboardText(export_string)
		elseif eventGadget == 2 then
			if tileset ~= nil then
				tilex = math.floor((minGUI.mouse.x - minGUI:get_panel_x(3) - minGUI:get_gadget_x(2)) / (tileSize * tilesetZoom))
				tiley = math.floor((minGUI.mouse.y - minGUI:get_panel_y(3) - minGUI:get_gadget_y(2)) / (tileSize * tilesetZoom))
				
				if tilex > (tilesetWidth / tileSize) - 1 then tilex = (tilesetWidth / tileSize) - 1 end
				if tiley > (tilesetHeight / tileSize) - 1 then tiley = (tilesetHeight / tileSize) - 1 end
				
				tileid = tilex + (tiley * (tilesetWidth / tileSize))
				
				redraw_tileset()
				redraw_tileset_grid()
			end
		elseif eventGadget == 15 then
			minGUI:clear_canvas(1, 0, 0, 0, 1)
			clear_map()
			redraw_tilemap()
			redraw_tilemap_grid()
		elseif eventGadget == 16 then
			-- export the map
			export_string = "collisions_map = {\r\n"

			for yexport = 0, math.floor(tilesetHeight / tileSize) - 1 do
				for xexport = 0, math.floor(tilesetWidth / tileSize) - 1 do
					local v = 0
					
					if wallMap[xexport][yexport] == true then v = 1 end
					
					export_string = export_string .. tostring(v) .. ","
				end

				-- linefeed
				export_string = export_string .. "\r\n"
			end

			-- remove last comma
			local byteoffset = utf8.offset(export_string, -1)

			if byteoffset then
				export_string = string.sub(export_string, 1, byteoffset - 1)
			end

			export_string = export_string .. "}"

			love.system.setClipboardText(export_string)
		end				
	-- if the left mouse is down on the canvas 1
	elseif eventType == MG_EVENT_LEFT_MOUSE_DOWN then
		if eventGadget == 1 then
			if tileset ~= nil then
				local x2 = math.floor((minGUI.mouse.x - minGUI:get_panel_x(2) - minGUI:get_gadget_x(1)) / (tileSize * tilemapZoom))
				local y2 = math.floor((minGUI.mouse.y - minGUI:get_panel_y(2) - minGUI:get_gadget_y(1)) / (tileSize * tilemapZoom))
				
				if x2 < mapWidth then
					if y2 < mapHeight then
				
						local x = x2 * (tileSize * tilemapZoom)
						local y = y2 * (tileSize * tilemapZoom)
				
						map[x2][y2] = tileid
				
						minGUI:draw_rectangle_to_canvas(1, "fill", x, y, tileSize * tilemapZoom, tileSize * tilemapZoom, BLACK)
						minGUI:draw_quad_to_canvas(1, tileset, quad[map[x2][y2]], x, y, tilemapZoom, tilemapZoom)

						local ty = math.floor(tileid / (tilesetWidth / tileSize))
						local tx = tileid - (ty * (tilesetWidth / tileSize))
						
						if wallMap[tx][ty] == false then
							minGUI:draw_rectangle_to_canvas(1, "line", x, y, tileSize * tilemapZoom, tileSize * tilemapZoom, GREY)
						else
							minGUI:draw_rectangle_to_canvas(1, "line", x, y, tileSize * tilemapZoom, tileSize * tilemapZoom, RED)
							minGUI:draw_rectangle_to_canvas(1, "line", x + 1, y + 1, (tileSize * tilemapZoom) - 2, (tileSize * tilemapZoom) - 2, RED)
						end
					end
				end
			end
		end
	-- if the right mouse is down on the canvas 1
	elseif eventType == MG_EVENT_RIGHT_MOUSE_DOWN then
		if eventGadget == 1 then
			if tileset ~= nil then
				local x2 = math.floor((minGUI.mouse.x - minGUI:get_panel_x(2) - minGUI:get_gadget_x(1)) / (tileSize * tilemapZoom))
				local y2 = math.floor((minGUI.mouse.y - minGUI:get_panel_y(2) - minGUI:get_gadget_y(1)) / (tileSize * tilemapZoom))
				
				if x2 < mapWidth then
					if y2 < mapHeight then
				
						local x = x2 * (tileSize * tilemapZoom)
						local y = y2 * (tileSize * tilemapZoom)
				
						map[x2][y2] = 0
				
						minGUI:draw_rectangle_to_canvas(1, "fill", x, y, tileSize * tilemapZoom, tileSize * tilemapZoom, BLACK)
						minGUI:draw_quad_to_canvas(1, tileset, quad[map[x2][y2]], x, y, tilemapZoom, tilemapZoom)
						minGUI:draw_rectangle_to_canvas(1, "line", x, y, tileSize * tilemapZoom, tileSize * tilemapZoom, GREY)
					end
				end
			end
		end
	-- if right mouse click on canvas 2
	elseif eventType == MG_EVENT_RIGHT_MOUSE_CLICK then
		if eventGadget == 2 then
			if tileset ~= nil then
				local x = math.floor((minGUI.mouse.x - minGUI:get_panel_x(3) - minGUI:get_gadget_x(2)) / (tileSize * tilesetZoom))
				local y = math.floor((minGUI.mouse.y - minGUI:get_panel_y(3) - minGUI:get_gadget_y(2)) / (tileSize * tilesetZoom))
				
				if x > (tilesetWidth * tilesetZoom / tileSize) - 1 then x = (tilesetWidth * tilesetZoom / tileSize) - 1 end
				if y > (tilesetHeight * tilesetZoom / tileSize) - 1 then y = (tilesetHeight * tilesetZoom / tileSize) - 1 end

				if wallMap[x][y] == false then wallMap[x][y] = true else wallMap[x][y] = false end

				redraw_tileset()
				redraw_tileset_grid()
				redraw_tilemap()
				redraw_tilemap_grid()
			end
		end
	end
end

-- default love.draw function
function love.draw()
	-- draw created gadgets from minGUI
	minGUI_draw_all()
	
	if export == true then love.graphics.print(tostring(xexport), 0, 0) end
end

--================================================

-- draw the grid on the first canvas
function redraw_tilemap_grid()
	-- draw the grid on first canvas, on top of the tilemap
	for y = 0, mapHeight - 1 do
		for x = 0, mapWidth - 1 do
			local x2 = x * tileSize * tilemapZoom
			local y2 = y * tileSize * tilemapZoom
			
			if tileset == nil then
				minGUI:draw_rectangle_to_canvas(1, "line", x2, y2, tileSize * tilemapZoom, tileSize * tilemapZoom, GREY)
			else
				local t = map[x][y]
			
				local ty = math.floor(t / (tilesetWidth / tileSize))
				local tx = t - (ty * (tilesetWidth / tileSize))
			
				if wallMap[tx][ty] == false then
					minGUI:draw_rectangle_to_canvas(1, "line", x2, y2, tileSize * tilemapZoom, tileSize * tilemapZoom, GREY)
				else
					minGUI:draw_rectangle_to_canvas(1, "line", x2, y2, tileSize * tilemapZoom, tileSize * tilemapZoom, RED)
					minGUI:draw_rectangle_to_canvas(1, "line", x2 + 1, y2 + 1, (tileSize * tilemapZoom) - 2, (tileSize * tilemapZoom) - 2, RED)
				end
			end
		end
	end
end

-- draw the grid on the second canvas
function redraw_tileset_grid()
	local tx = tilesetWidth
	local ty = tilesetHeight
	
	for y = 0, ty - 1, tileSize do
		for x = 0, tx - 1, tileSize do
			if wallMap[math.floor(x / tileSize)][math.floor(y / tileSize)] == false then
				minGUI:draw_rectangle_to_canvas(2, "line", x * tilesetZoom, y * tilesetZoom, tileSize * tilesetZoom, tileSize * tilesetZoom, GREY)
			else
				minGUI:draw_rectangle_to_canvas(2, "line", x * tilesetZoom, y * tilesetZoom, tileSize * tilesetZoom, tileSize * tilesetZoom, RED)
				minGUI:draw_rectangle_to_canvas(2, "line", (x * tilesetZoom) + 1, (y * tilesetZoom) + 1, (tileSize * tilesetZoom) - 2, (tileSize * tilesetZoom) - 2, RED)
			end
		end
	end
end

-- redraw the tilemap
function redraw_tilemap()
	minGUI:clear_canvas(1, 0, 0, 0, 1)
	
	-- exit function on error
	if tileset == nil then return end

	-- draw the grid on first canvas, and the tilemap
	for y = 0, (mapHeight - 1) * tileSize * tilemapZoom, tileSize * tilemapZoom do
		for x = 0, (mapWidth - 1) * tileSize * tilemapZoom, tileSize * tilemapZoom do
			local x2 = math.floor(x / (tileSize * tilemapZoom))
			local y2 = math.floor(y / (tileSize * tilemapZoom))
			
			minGUI:draw_quad_to_canvas(1, tileset, quad[map[x2][y2]], x, y, tilemapZoom, tilemapZoom)
		end
	end
end

-- redraw the tileset
function redraw_tileset()
	minGUI:clear_canvas(2, 0, 0, 0, 1)
	
	if tileset ~= nil then
		minGUI:draw_image_to_canvas(2, tileset, 0, 0, tilesetZoom, tilesetZoom)
		
		tilesetWidth = tileset:getWidth()
		tilesetHeight = tileset:getHeight()
	end
end
		
-- draw and drop
function love.filedropped(file)
	filename = file:getFilename()
	ext = filename:match("%.%w+$")

	if ext == ".png" then
		minGUI:set_gadget_text(7, "temp.png")

		file:open("r")
		local fileData = file:read("data")

		local success, message = love.filesystem.write("temp.png", fileData)

		if success then
			load_tileset()
		else
			minGUI:error_message("File can't be imported !")
		end
	else
		minGUI:error_message("Must be a png file ! ")
	end
end

-- load a tileset function
function load_tileset()
	-- does the file exists ?
	if minGUI_get_file_exists(minGUI:get_gadget_text(7)) == true then
		-- load the tileset
		tileset = love.graphics.newImage(minGUI:get_gadget_text(7))
		
		if tileset:getWidth() > MAX_TILESET_SIZE * 32 or tileset:getWidth() > MAX_TILESET_SIZE * 32 then
			minGUI:error_message("Tileset is too big !")
			
			tileset = nil
		else				
			-- draw it to the canvas
			redraw_tileset()
			redraw_tileset_grid()
	
			-- setup the selected tile
			tilex = 0
			tiley = 0
			tile = tilex + (tiley * (tilesetWidth / tileSize))
			
			-- reset quad size
			requad_all()
			
			-- reset walls
			reset_walls()
		
			-- clear the map
			clear_map()
			redraw_tilemap()
			redraw_tilemap_grid()
		end
	end
end

-- reset quad size
function requad_all()
	for y = 0, (tilesetHeight / tileSize) - 1 do
		for x = 0, (tilesetWidth / tileSize) - 1 do
			quad[x + (y * (tilesetWidth / tileSize))] = love.graphics.newQuad(x * tileSize, y * tileSize, tileSize, tileSize, tilesetWidth, tilesetHeight)
		end
	end
end

-- clear the full tilemap
function clear_map()
	for x = 0, MAX_MAP_SIZE - 1 do
		for y = 0, MAX_MAP_SIZE - 1 do
			map[x][y] = 0
		end
	end
end

-- reset walls
function reset_walls()
	for x = 0, MAX_TILESET_SIZE - 1 do
		for y = 0, MAX_TILESET_SIZE - 1 do
			wallMap[x][y] = false
		end
	end
end
