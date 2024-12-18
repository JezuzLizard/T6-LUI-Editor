LUI.UIVerticalList = {}
LUI.UIVerticalList.AddSpacer = function ( self, units, priority )
	local spacer = LUI.UIElement.new( {
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = true,
		bottomAnchor = false,
		top = 0,
		bottom = units
	} )
	spacer:setPriority( priority )
	self:addElement( spacer )
	return spacer
end

LUI.UIVerticalList.new = function (defaultAnimationState)
	local element = LUI.UIElement.new(defaultAnimationState)
	element.id = "LUIVerticalList"
	element:setupUIVerticalList()
	element.addSpacer = LUI.UIVerticalList.AddSpacer
	element.addElement = LUI.UIVerticalList.AddElement
	element.removeElement = LUI.UIVerticalList.RemoveElement
	element.addElementToTop = LUI.UIVerticalList.AddElementToTop
	element.selectElementIndex = LUI.UIVerticalList.SelectElementIndex
	element.addNavigationFailSound = LUI.UIVerticalList.AddNavigationFailSound
	element.addNavigationFocusSound = LUI.UIVerticalList.AddNavigationFocusSound
	element:registerEventHandler( "gain_focus", LUI.UIVerticalList.gainFocus )
	element:registerEventHandler( "gain_focus_skip_disabled", LUI.UIVerticalList.gainFocusSkipDisabled )
	return element
end

LUI.UIVerticalList.AddElement = function ( self, newChildElement )
	LUI.UIElement.addElement( self, newChildElement )
	self:setLayoutCached( false )
	LUI.UIVerticalList.UpdateNavigation( self )
end

LUI.UIVerticalList.RemoveElement = function ( self, childElementToRemove )
	LUI.UIElement.removeElement( self, childElementToRemove )
	self:setLayoutCached( false )
	LUI.UIVerticalList.UpdateNavigation( self )
end

LUI.UIVerticalList.AddElementToTop = function (self, newChildElement)
	local childElement = self:getFirstChild()
	if childElement ~= nil then
		LUI.UIElement.addElementBefore(newChildElement, childElement)
		self:setLayoutCached(false)
		LUI.UIVerticalList.UpdateNavigation(self)
	else
		LUI.UIVerticalList.addElement(self, newChildElement)
		self:setLayoutCached( false )
		LUI.UIVerticalList.UpdateNavigation( self )
	end
end

LUI.UIVerticalList.SelectElementIndex = function ( self, index )
	local childElement = self:getFirstChild()
	local count = 0
	while childElement ~= nil do
		if childElement.m_focusable then
			count = count + 1
			if count == index then
				childElement:processEvent( {
					name = "gain_focus"
				} )
			else
				childElement:processEvent( {
					name = "lose_focus"
				} )
			end
		end
		childElement = childElement:getNextSibling()
	end
end

LUI.UIVerticalList.UpdateNavigation = function ( self, event )
	local firstFocusable, lastFocusable = nil, nil
	local childElement = self:getFirstChild()
	while childElement ~= nil do
		if childElement.m_focusable then
			if firstFocusable == nil then
				firstFocusable = childElement
			end
			if lastFocusable ~= nil then
				lastFocusable.navigation.down = childElement
				childElement.navigation.up = lastFocusable
			end
			if childElement.navigation ~= nil and self.navigation ~= nil then
				if childElement.navigation.left == nil and self.navigation.left ~= nil then
					childElement.navigation.left = self.navigation.left
				end
				if childElement.navigation.right == nil and self.navigation.right ~= nil then
					childElement.navigation.right = self.navigation.right
				end
			end
			if self.navigationFocusSound ~= nil then
				childElement.gainFocusSFX = self.navigationFocusSound
			end
			if childElement.navigationSounds then
				childElement.navigationSounds.up = nil
				childElement.navigationSounds.down = nil
			end
			lastFocusable = childElement
		end
		childElement = childElement:getNextSibling()
	end
	if lastFocusable ~= nil and not self.disableWrapping then
		if self.navigation ~= nil and self.navigation.down ~= nil then
			lastFocusable.navigation.down = self.navigation.down
			self.navigation.down.navigation.up = lastFocusable
		elseif lastFocusable ~= firstFocusable then
			lastFocusable.navigation.down = firstFocusable
			firstFocusable.navigation.up = lastFocusable
		else
			lastFocusable.navigation.down = nil
			lastFocusable.navigation.up = nil
		end
		if self.navigation ~= nil and self.navigation.up ~= nil then
			firstFocusable.navigation.up = self.navigation.up
			self.navigation.up.navigation.down = firstFocusable
		end
	elseif lastFocusable ~= nil and self.disableWrapping and self.navigationFailSound then
		firstFocusable.navigationSounds = {}
		lastFocusable.navigationSounds = {}
		firstFocusable.navigationSounds.up = self.navigationFailSound
		lastFocusable.navigationSounds.down = self.navigationFailSound
	end
end

LUI.UIVerticalList.gainFocus = function (self)
	local firstFocusable = nil
	local childElement = self:getFirstChild()
	while childElement ~= nil do
		if childElement.m_focusable and firstFocusable == nil then
			firstFocusable = childElement
		end
		childElement = childElement:getNextSibling()
	end
	if firstFocusable ~= nil then
		firstFocusable:processEvent({
			name = "gain_focus"
		})
	end
end

LUI.UIVerticalList.gainFocusSkipDisabled = function ( self )
	local firstFocusable, firstNonDisabled = nil, nil
	local childElement = self:getFirstChild()
	while childElement ~= nil do
		if childElement.m_focusable then
			if firstFocusable == nil then
				firstFocusable = childElement
			end
			if not childElement.disabled then
				firstNonDisabled = childElement
				break
			end
		end
		childElement = childElement:getNextSibling()
	end
	if firstNonDisabled ~= nil then
		firstFocusable = firstNonDisabled
	end
	if firstFocusable ~= nil then
		firstFocusable:processEvent( {
			name = "gain_focus"
		} )
	end
end

LUI.UIVerticalList.addNavigationFocusSound = function ( self, sound )
	self.navigationFocusSound = sound
	LUI.UIVerticalList.UpdateNavigation( self )
end

LUI.UIVerticalList.addNavigationFailSound = function ( self, sound )
	self.navigationFailSound = sound
	LUI.UIVerticalList.UpdateNavigation( self )
end