
-- PoC ENABLE UIEDITOR FUNCTIONALITY
editor_api.E_STATE_DISABLED = 0
editor_api.E_STATE_ENABLED = 1

editor_api.E_STATE_STRINGS = {}
editor_api.E_STATE_STRINGS[1] = "UIEditor Disabled"
editor_api.E_STATE_STRINGS[2] = "UIEditor Activated"

editor_api.V_STATE_INIT = false
editor_api.V_STATE = editor_api.E_STATE_DISABLED
editor_api.V_LAST_STATE = editor_api.V_STATE

editor_api.f_toggle_editor = function()
	-- detect luireload to disable editor preventing permanent blackscreen
	if not editor_api.V_STATE_INIT then
		Engine.SetDvar("uieditor_enabled", 0)
		editor_api.V_STATE_INIT = true
	end

	local new_state = UIExpression.DvarInt(nil, "uieditor_enabled")
	editor_api.V_STATE = LUI.clamp(new_state, editor_api.E_STATE_DISABLED, editor_api.E_STATE_ENABLED)
	if editor_api.V_LAST_STATE ~= editor_api.V_STATE then
		editor_api.V_LAST_STATE = editor_api.V_STATE
		print(editor_api.E_STATE_STRINGS[editor_api.V_STATE + 1])
	end
end

editor_api.f_editor_active = function()
	return editor_api.V_STATE == editor_api.E_STATE_ENABLED
end

--[[
DESIRED ABILITES OF THE API
1. View possible elements to edit in layers derived from priority separated further by owner menu
	a. Invisible elements must be viewable as well
2. Edit individual elements specific properties

]]--

-- PoC MOVE ELEMENT BASED ON USER INPUT FUNCTIONALITY
editor_api.V_CURRENT_MOVING_ELEMENT = nil

--[[
editor_api.f_animstate_get_animstates = function(element)
	return element.m_animationStates
end

editor_api.f_animstate_get_animstates_kvps = function(element)
	return pairs(element.m_animationStates)
end

editor_api.f_animstate_get_animstates_keys = function(element)
	local keys = {}

	local index = 1
	for k, v in editor_api.f_animstate_get_animstates_kvps(element) do
		keys[index] = k
		index = index + 1
	end
	return keys
end
]]--

editor_api.f_animstate_has_state = function(element, statename)
	return element.m_animationStates[statename] ~= nil
end

editor_api.f_animstate_get_state = function(element, statename)
	return element.m_animationStates[statename]
end

--[[
editor_api.f_animstate_apply_overrides = function(root, menu, event)

end
]]--

editor_api.f_animstate_get_pos = function(element, statename, as_table)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	if not animstate then
		return -1, -1, -1, -1
	end

	return animstate.left, animstate.top, animstate.right, animstate.bottom
end

--[[
editor_api.f_animstate_get_anchors = function(element, statename, as_table)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	return animstate.leftAnchor, animstate.topAnchor, animstate.rightAnchor, animstate.bottomAnchor
end
--]]
--[[
editor_api.f_animstate_get_zoom = function(element, statename)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	return animstate.zoom
end

editor_api.f_animstate_get_rot = function(element, statename, as_table)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	return animstate.xRot, animstate.yRot, animstate.zRot
end

editor_api.f_animstate_get_scale = function(element, statename)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	return animstate.scale
end
]]--

editor_api.f_animstate_get_color = function(element, statename, as_table)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	if as_table ~= nil and as_table then
		local table = {
			red = animstate.red,
			green = animstate.green,
			blue = animstate.blue,
			alpha = animstate.alpha
		}
		return table
	end
	return animstate.red, animstate.green, animstate.blue, animstate.alpha
end
--[[
editor_api.f_animstate_get_alpha_multiplier = function(element, statename)
	local animstate = editor_api.f_animstate_get_state(element, statename)

	return animstate.alphaMultiplier
end

editor_api.f_animstate_get_spacing = function(element, statename)
	local animstate = editor_api.f_animstate_get(element, statename)

	return animstate.spacing
end

editor_api.f_animstate_get_shader_vectors = function(element, statename, as_table)
	local animstate = editor_api.f_animstate_get(element, statename)

	return animstate.shaderVector0, animstate.shaderVector1, animstate.shaderVector2, animstate.shaderVector3, animstate.shaderVector4
end

editor_api.f_animstate_get_material = function(element, statename)
	local animstate = editor_api.f_animstate_get(element, statename)

	return animstate.material
end

editor_api.f_animstate_get_font = function(element, statename)
	local animstate = editor_api.f_animstate_get(element, statename)

	return animstate.font
end

editor_api.f_trans_set_element_pos = function(element, x, y)

end

editor_api.f_trans_add_element_pos = function(element, x, y)

end

editor_api.f_trans_subtract_element_pos = function(element, x, y)

end

editor_api.f_trans_reset_element_pos = function(element)

end

editor_api.f_trans_set_element_anchors = function(element, left, right, top, bottom)

end

editor_api.f_trans_reset_element_anchors = function(element)

end

editor_api.f_trans_restore_element_anchors = function(element)

end

-- this can be used by the API to allow interpolation of existing animstates, or switching between existing animstates
-- or creating new ones to swap between
editor_api.f_set_target_element_animstate = function(element, animstate_name)

end

editor_api.f_animstate_play = function(element, animstate_name)

end

editor_api.f_animstate_new = function(element, animstate_name, animstate_table_as_str)

end

editor_api.f_animstate_remove = function(element, animstate_name)

end
]]--
editor_api.f_set_target_element = function(element)
	editor_api.V_CURRENT_MOVING_ELEMENT = element
end

editor_api.V_ELEMENT_ANIMATION_STATE_OVERRIDES = {}


-- PoC ADVANCE LUI FRAME

-- PoC ELEMENT ITERATORS

--[[
editor_api.itr_cb_in_focus = function (element, ...)
	return element:isInFocus()
end

editor_api.itr_cb_by_key = function (element, key, value, ...)
	return element[key] == value
end
]]--

editor_api.itr_cb_mouse_inside = function(element, ...)
	local inside, mouse_x, mouse_y = LUI.UIElement.IsMouseInsideElement(element, editor_api.V_MOUSE_CURSOR_POS)

	return inside
end

editor_api.f_get_root = function()
	if UIExpression.IsInGame() == 1 then
		return LUI.roots.UIRoot0
	else
		return LUI.roots.UIRootFull
	end
end

editor_api.itr_find_element_first_of = function (element, callback, cb_arg1, cb_arg2, cb_arg3)
	if callback(element, cb_arg1, cb_arg2, cb_arg3) then
		return element
	end
	local child = element:getFirstChild()
	while child ~= nil do
		local result = editor_api.itr_find_element_first_of(child, callback, cb_arg1, cb_arg2, cb_arg3)
		if result ~= nil then
			return result
		end
		child = child:getNextSibling()
	end
end

--[[
editor_api.itr_find_elements_internal = function(array, element, max_depth, current_depth, callback, cb_arg1, cb_arg2, cb_arg3)
	current_depth = current_depth + 1
	if max_depth ~= nil and current_depth > max_depth then
		return
	end

	if not callback or callback(element, cb_arg1, cb_arg2, cb_arg3) then
		array[#array + 1] = element
	end

	local child = element:getFirstChild()
	while child ~= nil do
		editor_api.itr_find_elements_internal(array, child, max_depth, current_depth, callback, cb_arg1, cb_arg2, cb_arg3)
		child = child:getNextSibling()
	end

	current_depth = current_depth - 1
end

editor_api.itr_find_elements = function (element, max_depth, callback, cb_arg1, cb_arg2, cb_arg3)
	local array = {}
	editor_api.itr_find_elements_internal(array, element, max_depth, 0, callback, cb_arg1, cb_arg2, cb_arg3)
	return array
end
]]--
editor_api.f_is_editor_event = function(event)
	return editor_api.T_EVENTS_PRIVATE[event.name] ~= nil or editor_api.T_EVENTS_PUBLIC[event.name] ~= nil
end


--[[
	LUI.Element Methods
	local readOnlyAnimationStateTable = getAnimationState(animstateName)
	local readOnlyAnimationStateNamesTable = getAnimationStateNames()
]]