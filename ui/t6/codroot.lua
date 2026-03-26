LUI.CoDRoot = {}

local AddEventToQueue = function(menu, event)
	local eventQueue = menu.eventQueue
	table.insert(eventQueue, event)
	local queueSize = #eventQueue
	if queueSize > 20 then
		DebugPrint("LUI WARNING: Event queue exceeded 20 events! " .. event.name .. ". Size is " .. queueSize)
	end
end

LUI.CoDRoot.ProcessEvent = function (self, event)
	--print(self.id)
	--print(event.name)
	if event.immediate == true or editor_api.f_editor_active() and (event.name == editor_api.TICKER_EVENT or self.id == "UIEditor" or self.id == "UIEditorTicker") then
		LUI.CoDRoot.ProcessEventNow(self, event)
	elseif not editor_api.f_editor_active() then
		AddEventToQueue(self, event)
	end
end

LUI.CoDRoot.ProcessEvents = function (self, event)
	local eventQueue = self.eventQueue
	local eventsToProcess = 0
	local queueSize = #eventQueue
	if queueSize > 60 then
		eventsToProcess = queueSize
		DebugPrint("LUI WARNING: Event queue reached " .. eventsToProcess .. "!. ** Emergency event processing kicked off. ** ")
	elseif queueSize > 40 then
		eventsToProcess = math.floor(queueSize / 10)
		DebugPrint("LUI WARNING: Event queue reached " .. queueSize .. ". Processing " .. eventsToProcess .. " events this frame.")
	else
		eventsToProcess = 1
	end

	if editor_api.f_editor_active() then
		print("PAUSED\n")
		return
	end

	for i = 1, eventsToProcess, 1 do
		local f2_local6 = i
		local nextEvent = eventQueue[1]
		if nextEvent ~= nil then
			table.remove(eventQueue, 1)
			LUI.CoDRoot.ProcessEventNow(self, nextEvent)
		end
	end
end

LUI.CoDRoot.ProcessEventNow = function (self, event)
	if event.name ~= "process_events" then
		Engine.EventProcessed()
	end
	if editor_api.f_editor_active() and (self.id ~= "UIEditor" or self.id ~= "UIEditorTicker") then
		return nil
	end
	self:propagateEvent(event)
	Engine.PIXBeginEvent(event.name)
	local returnVal = LUI.UIElement.processEvent(self, event)
	Engine.PIXEndEvent()
	return returnVal
end

LUI.CoDRoot.DontPropagateEvent = function (self, event)

end

LUI.CoDRoot.PropagateEventToPrimaryRoot = function (self, event)
	if LUI.primaryRoot ~= nil and LUI.primaryRoot ~= self and event.name ~= "resize" and event.name ~= "addmenu" then
		LUI.UIElement.processEvent(LUI.primaryRoot, event)
	end
end

LUI.CoDRoot.CloseAll = function (self, event)
	self:removeAllChildren()
end

LUI.CoDRoot.new = function (name)
	local root = LUI.UIRoot.new(name)
	root.eventQueue = {}
	root.numEvents = 0
	root:registerEventHandler("process_events", LUI.CoDRoot.ProcessEvents)
	root:registerEventHandler("close_all", LUI.CoDRoot.CloseAll)

	if name == "UIRootDrc" then
		root.propagateEvent = LUI.CoDRoot.DontPropagateEvent
	else
		root.propagateEvent = LUI.CoDRoot.PropagateEventToPrimaryRoot
	end

	root.processEvent = LUI.CoDRoot.ProcessEvent
	if LUI.primaryRoot == nil then
		LUI.primaryRoot = root
	end

	root.uieditor = LUI.UIElement.new({
		left = 0,
		top = 0,
		right = 0,
		bottom = 0,
		leftAnchor = false,
		topAnchor = false,
		rightAnchor = false,
		bottomAnchor = false
	})
	root.uieditor.id = "UIEditor"
	root.uieditor.name = "UIEditor_" .. name
	root.uieditor.ticker = LUI.UITimer.new(1000, "uieditor_tick", false, root.uieditor)
	root.uieditor.ticker.id = "UIEditorTicker"
	root.uieditor.ticker.name = "UIEditorTicker_" .. name
	root.uieditor:registerEventHandler("uieditor_tick", editor_tools.MAIN)
	root.uieditor:registerEventHandler("mousemove", editor_api.cb_mousemove_event)
	root.uieditor:addElement(root.uieditor.ticker)
	root:addElement(root.uieditor)

	return root
end

