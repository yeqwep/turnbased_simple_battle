-- --------------------------------------
-- Group Button Selector Module
-- --------------------------------------
local M = {}

local COLOR_SELECTED = vmath.vector4(0, 1.0, 1.0, .25) -- 黄色
local COLOR_NORMAL   = vmath.vector4(1.0, 1.0, 1.0, 0) -- 白

-- --------------------------------------
-- Set color
-- --------------------------------------
local function update_selection(ctx)
	for i, node in ipairs(ctx.buttons.box) do
		if i == ctx.selected_index then
			gui.set_color(node, COLOR_SELECTED)
		else
			gui.set_color(node, COLOR_NORMAL)
		end
	end
end
-- --------------------------------------
-- Update enabled buttons
-- --------------------------------------
local ENABLED_TEXT_COLOR = vmath.vector4(1, 1, 1, 1)
local DISABLED_TEXT_COLOR = vmath.vector4(.5, .5, .5, 1)

local function update_enabled(ctx, enabled_buttons)
	ctx.enabled_buttons = enabled_buttons

	if ctx.enabled_buttons then
		for i, node in ipairs(ctx.buttons.text) do
			if enabled_buttons[i] == true then
				gui.set_color(node, ENABLED_TEXT_COLOR)
			else
				gui.set_color(node, DISABLED_TEXT_COLOR)
			end
		end
	else
		for _, node in ipairs(ctx.buttons.text) do
			gui.set_color(node, ENABLED_TEXT_COLOR)
		end
	end
end
-- --------------------------------------
-- initialize, input, update settings, clear
-- --------------------------------------
function M.create(button_ids, keys, enabled_buttons, callback, on_back)
	local ctx = {
		buttons = {box={},text={}},
		enabled_buttons = enabled_buttons,
		selected_index = 1,
		hover_index = nil,
		callback = callback ,
		on_page_left = nil,
		on_page_right = nil,
		on_back = on_back
	}

	for _, nodes in ipairs(button_ids) do
		local node_box = nodes[keys.box]
		local node_text = nodes[keys.text]
		table.insert(ctx.buttons.box, node_box)
		table.insert(ctx.buttons.text, node_text)
	end
	update_selection(ctx)
	update_enabled(ctx, enabled_buttons)

	return ctx
end

function M.on_input(ctx, action_id, action)
	if action_id == hash("up") and action.released then
		local index = ctx.selected_index or 1
		index = index - 1
		if index < 1 then index = #ctx.buttons.box end
		ctx.selected_index = index
	elseif action_id == hash("down") and action.released then
		local index = ctx.selected_index or 0
		index = index + 1
		if index > #ctx.buttons.box then index = 1 end
		ctx.selected_index = index
	elseif action_id == hash("left") and action.released and ctx.on_page_left then
		ctx.on_page_left()
	elseif action_id == hash("right") and action.released and ctx.on_page_right then
		ctx.on_page_right()
	elseif action_id == hash("b") and action.released and ctx.on_back then
		ctx.on_back()
	elseif action_id == hash("space") and action.released then
		if not ctx.selected_index then
			ctx.selected_index = 1
		else
			if ctx.enabled_buttons then
				if ctx.enabled_buttons[ctx.hover_index] == false then

					return
				end
			end
			ctx.callback(ctx.selected_index)
			return
		end
	end

	if action.x and action.y then
		ctx.hover_index = nil
		for i, node in ipairs(ctx.buttons.box) do
			if gui.pick_node(node, action.x, action.y) then
				if ctx.hover_index ~= i then
					ctx.hover_index = i
					ctx.selected_index = i
					break
				end
			end
		end
		if action.released and ctx.hover_index then
			if ctx.enabled_buttons then
				if ctx.enabled_buttons[ctx.hover_index] == false then
					
					return
				end
			end
			ctx.callback(ctx.selected_index)
			return
		end
	end
	update_selection(ctx)
end

function M.update_setting(ctx, enabled_buttons)
	update_enabled(ctx, enabled_buttons)
end

function M.clear(ctx)
	for k in pairs(ctx) do
		ctx[k] = nil
	end
end

return M