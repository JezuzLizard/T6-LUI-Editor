LUI.CoDRoot = {}

LUI.CoDRoot.EVENT_PAUSE_STATE = "false"
local SetEventPauseState = function(state)
	LUI.UIElement.EVENT_PAUSE_STATE = state
	LUI.CoDRoot.EVENT_PAUSE_STATE = state
end
local GetEventPauseState = function()
	return LUI.CoDRoot.EVENT_PAUSE_STATE
end
local IsPaused = function()
	return LUI.CoDRoot.EVENT_PAUSE_STATE == "true"
end

LUI.CoDRoot.PriorityEvents = {}
LUI.CoDRoot.PriorityEvents["unpause_events"] = 0
LUI.CoDRoot.PriorityEvents["pause_events"] = 1

local IsPriorityEvent = function(event)
	return LUI.CoDRoot.PriorityEvents[event.name] ~= nil
end

local AddEventToQueue = function(menu, event)
	if IsPaused() then
		return
	end
	local eventQueue = menu.eventQueue
	table.insert(eventQueue, event)
	local queueSize = #eventQueue
	if queueSize > 20 then
		DebugPrint("LUI WARNING: Event queue exceeded 20 events! " .. event.name .. ". Size is " .. queueSize)
	end
end

LUI.CoDRoot.ProcessEvent = function (self, event)
	if event.immediate == true or IsPriorityEvent(event) then
		LUI.CoDRoot.ProcessEventNow(self, event)
	else
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

	if GetEventPauseState() == "true" then
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
	if event.name == "pause_events" then
		SetEventPauseState("true")
		print("hello: " .. LUI.CoDRoot.EVENT_PAUSE_STATE)
	elseif event.name == "unpause_events" then
		SetEventPauseState("false")
		print("hello: " .. LUI.CoDRoot.EVENT_PAUSE_STATE)
	end
	if event.name ~= "process_events" then
		Engine.EventProcessed()
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
	return root
end

