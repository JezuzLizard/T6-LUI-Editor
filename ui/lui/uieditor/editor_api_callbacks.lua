-- PoC STORE EDITOR PERSISTENT DATA

editor_api.f_callbacks_element_construction = function(element, default_animstate)
	if not element then
		error("ELEMENT CONSTRUCTION FAILED???")
	end

	if element.uieditor then
		error("ELEMENT CONSTRUCTION ALREADY REGISTERED UIEDITOR???")
	end
	element.uieditor = {}
end

--[[
editor_api.f_callbacks_element_freed = function(element)

end

editor_api.f_callbacks_element_child_added = function(element)

end

editor_api.f_callbacks_element_child_added_before = function(element)

end

editor_api.f_callbacks_element_child_added_after = function(element)

end

editor_api.f_callbacks_element_child_can_be_added = function(element)

end

editor_api.f_callbacks_element_child_removed = function(element)

end

--]]
editor_api.f_callbacks_element_event_registered = function(element, event_name, event_handler)
	
	return true
end
--[[
editor_api.f_callbacks_element_event_processed_begin = function(element)

end

editor_api.f_callbacks_element_event_processed_end = function(element)

end

local check_for_menu_created_overrides = function(menu, event)

end
--]]

editor_api.f_callbacks_menu_created = function(menu, event)

end

editor_api.V_MOUSE_CURSOR_POS = {}

local uieditor_track_mouse_pos_cb = function(root, event)
	editor_api.V_MOUSE_CURSOR_POS.rootName = event.rootName
	editor_api.V_MOUSE_CURSOR_POS.x = event.x
	editor_api.V_MOUSE_CURSOR_POS.y = event.y
end
local mousemove_event_table = {}
mousemove_event_table.V_ALLOW_PROPAGATION = false
mousemove_event_table.C_F_ACTION_FUNC = uieditor_track_mouse_pos_cb

editor_api.T_EVENTS_PRIVATE = {}
editor_api.T_EVENTS_PRIVATE["mousemove"] = mousemove_event_table

editor_api.cb_mousemove_event = function(menu, event)
	editor_api.T_EVENTS_PRIVATE["mousemove"].C_F_ACTION_FUNC(menu, event)
end

--[[
local uieditor_element_add_move_cb = function(root, event)
	local argv = editor_api.f_callbacks_editor_argv
	local argc = #argv

	if argc < 4 then
		print("UIEDITOR CMD USAGE: uieditor_element_add_move <left> <top> <right> <bottom>")
		return
	end

	if not editor_api.V_CURRENT_MOVING_ELEMENT then
		print("UIEDITOR CMD USAGE: uieditor_element_add_move: invalid element")
		return
	end

	local element = editor_api.V_CURRENT_MOVING_ELEMENT
	local new_left, new_top, new_right, new_bottom = tonumber(argv[1]), tonumber(argv[2]), tonumber(argv[3]), tonumber(argv[4])
	local old_left, old_top, old_right, old_bottom = editor_api.f_animstate_get_pos(element, "default")

	local animstate = {
		left = old_left + new_left,
		top = old_top + new_top,
		right = old_right + new_right,
		bottom = old_bottom + new_bottom
	}
	element:registerAnimationState("uieditor_move", animstate)
	element:animateToState("uieditor_move")
	local cur_left, cur_top, cur_right, cur_bottom = editor_api.f_animstate_get_pos(element, "uieditor_move")

	print(string.format("uieditor_element_add_move: old{%d, %d, %d, %d} new{%d, %d, %d, %d}", old_left, old_top, old_right, old_bottom, current_animstate.left, current_animstate.top, current_animstate.right, current_animstate.bottom))
end
]]--

local uieditor_element_set_color_cb = function(root, cmdname, cmdargs)
	local argv = cmdargs
	local argc = #argv

	if argc < 4 then
		print("UIEDITOR CMD USAGE: uieditor_element_add_move <left> <top> <right> <bottom>")
		return
	end

	if not editor_api.V_CURRENT_MOVING_ELEMENT then
		print("UIEDITOR CMD USAGE: uieditor_element_add_move: invalid element")
		return
	end

	local element = editor_api.V_CURRENT_MOVING_ELEMENT
	local old_color = nil
	if editor_api.f_animstate_has_state(element, "uieditor_color") then
		old_color = editor_api.f_animstate_get_color(element, "uieditor_color", true)
	end
	
	local new_color = {
		red = LUI.clamp(tonumber(argv[1]), 0.0, 1.0),
		green = LUI.clamp(tonumber(argv[2]), 0.0, 1.0),
		blue = LUI.clamp(tonumber(argv[3]), 0.0, 1.0),
		alpha = LUI.clamp(tonumber(argv[4]), 0.0, 1.0)
	}

	element:registerAnimationState("uieditor_color", new_color)
	element:animateToState("uieditor_color")
	local cur_color = editor_api.f_animstate_get_color(element, "uieditor_color")

	local old_color_str
	if old_color then
		old_color_str = string.format("%.3f, %.3f, %.3f, %.3f", old_color.red, old_color.greed, old_color.blue, old_color.alpha)
	end
	
	local cur_color_str = string.format("%.3f, %.3f, %.3f, %.3f", cur_color.red, cur_color.greed, cur_color.blue, cur_color.alpha)
	print(string.format("uieditor_element_add_move: old={%s} new={%s}", old_color_str, cur_color_str))
end

--[[
editor_api.f_callbacks_editor_argc = function(root, event)
	local index = 0
	while event["arg" .. (index + 1)] ~= nil do
		index = index + 1
	end

	return index
end
]]--

editor_api.f_callbacks_editor_argv = function(root, event)
	local args = {}
	local index = 0
	local arg = event["arg" .. (index + 1)]
	while arg ~= nil do
		index = index + 1
		args[#args + 1] = arg
		arg = event["arg" .. (index + 1)]
	end

	return args
end

-- min args 1: callbackname
-- arg1: name of itr callback to use to find element
local uieditor_set_target_element_cb = function(root, eventname, args)
	local element = nil
	local root = editor_api.f_get_root()

	element = editor_api.itr_find_element_first_of(root, editor_api.itr_cb_mouse_inside)
	if element ~= nil then
		print("SET ELEMENT TO " .. element:getFullID())
		editor_api.f_set_target_element(element)
	end
end

local uieditor_execute_user_command_cb = function(root, cmdname, cmdargs)
	if editor_api.T_EVENTS_PRIVATE[cmdname] == nil then
		return
	end

	editor_api.T_EVENTS_PRIVATE[cmdname](root, cmdname, cmdargs)
end

editor_api.T_EVENTS_PUBLIC = {}
editor_api.T_EVENTS_PUBLIC["uieditor_user_event"] = uieditor_execute_user_command_cb
--editor_api.T_EVENTS_PUBLIC["uieditor_element_add_move"] = uieditor_element_add_move_cb
editor_api.T_EVENTS_PRIVATE["element_set_color"] = uieditor_element_set_color_cb
editor_api.T_EVENTS_PRIVATE["set_target_element"] = uieditor_set_target_element_cb

editor_api.TICKER_EVENT = "uieditor_tick"

editor_api.f_is_standard_event = function(event)
	return editor_api.T_EVENTS_PRIVATE[event.name] ~= nil
end

editor_api.f_is_custom_event = function(event)
	return editor_api.T_EVENTS_PUBLIC[event.name] ~= nil
end

editor_api.f_event_allowed_propagation = function(event)
	return editor_api.T_EVENTS_PRIVATE[event.name].V_ALLOW_PROPAGATION
end

editor_api.f_callbacks_editor_event = function(root, event)
	if not editor_api.f_is_editor_event(event) then
		return true
	end
	--[[
	if editor_api.f_is_standard_event(event) then
		editor_api.T_EVENTS_PRIVATE[event.name].C_F_ACTION_FUNC(root, event)
		return editor_api.f_event_allowed_propagation(event)
	end
	]]--
	local args = event.cmdargs
	editor_api.T_EVENTS_PUBLIC[event.name](root, event.cmdname, args)
end