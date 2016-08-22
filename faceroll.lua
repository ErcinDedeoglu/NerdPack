NeP.Faceroll = {
	buttonMap = { },
}

local faceroll = NeP.Faceroll
local Engine = NeP.Engine

local lnr = LibStub("AceAddon-3.0"):NewAddon("NerdPack", "LibNameplateRegistry-1.0");
local DiesalTools = LibStub('DiesalTools-1.0')
local DiesalStyle = LibStub('DiesalStyle-1.0')
local DiesalGUI = LibStub('DiesalGUI-1.0')
local DiesalMenu = LibStub('DiesalMenu-1.0')
local SharedMedia = LibStub('LibSharedMedia-3.0')

-- Work in Progress...
local display = DiesalGUI:Create('Window')
display:SetTitle('TeST Mode')
display.frame:SetClampedToScreen(true)
display.frame:SetSize(300, 400)
display.frame:SetMinResize(300, 400)
display:Hide()

-- This to put an icon on top of the spell we want
local activeFrame = CreateFrame('Frame', 'activeCastFrame', UIParent)
activeFrame:SetSize(32,32)
activeFrame:SetPoint("CENTER", UIParent, "CENTER")
activeFrame.texture = activeFrame:CreateTexture()
activeFrame.texture:SetTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8")
activeFrame.texture:SetAllPoints(activeFrame)
activeFrame:SetFrameStrata('HIGH')
activeFrame:Hide()

local nBars = {
	"ActionButton",
	"MultiBarBottomRightButton",
	"MultiBarBottomLeftButton",
	"MultiBarRightButton",
	"MultiBarLeftButton"
}
local frame = CreateFrame("FRAME", "FooAddonFrame");
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(self, event, ...)
	wipe(faceroll.buttonMap)
	for _, group in ipairs(nBars) do
		for i =1, 12 do
			local button = _G[group .. i]
			if button then
				local actionType, id, subType = GetActionInfo(ActionButton_CalculateAction(button, "LeftButton"))
				if actionType == 'spell' then
					local spell = GetSpellInfo(id)
					if spell then
						faceroll.buttonMap[spell] = button
					end
				end
			end
		end
	end
end)

local function showActiveSpell(spell)
	local spellButton = faceroll.buttonMap[spell]
	if spellButton then
		activeFrame:SetPoint("CENTER", spellButton, "CENTER")
		activeFrame:Show()
	end
end

-- Hide it
NeP.Timer.Sync("nep_faceroll", function()
	activeFrame:Hide()
end, 0)

function NeP.Engine.FaceRoll()

	-- cast on ground
	function Engine.CastGround(spell, target)
		showActiveSpell(spell)
	end

	-- Cast
	function Engine.Cast(spell, target)
		showActiveSpell(spell)
	end

	-- Macro
	function Engine.Macro(text)
	end

	function Engine.UseItem(name, target)
	end

	function Engine.UseInvItem(slot)
	end

	function Engine.LineOfSight(a, b)
		return NeP.Helpers.infront and UnitExists(b)
	end

	-- Distance
	local rangeCheck = LibStub("LibRangeCheck-2.0")
	function Engine.Distance(a, b)
		if UnitExists(b) then
			local minRange, maxRange = rangeCheck:GetRange(b)
			return maxRange or minRange
		end
		return 0
	end

	-- Infront
	function Engine.Infront(a, b)
		return NeP.Helpers.infront
	end

	local _rangeTable = {
		['melee'] = 1.5,
		['ranged'] = 40,
	}

	function Engine.UnitAttackRange(unitA, unitB, rType)
		if rType then
			return _rangeTable[rType] + 3.5
		end
		return 0
	end

	--[[				Generic OM
	---------------------------------------------------]]
	local function GenericFilter(unit)
		local alreadyExists = false
		if UnitExists(unit) then
			local GUID = UnitGUID(unit)
			-- Enemie Filter
			if UnitCanAttack('player', unit) then
				for i=1, #NeP.OM.unitEnemie do
					local Obj = NeP.OM.unitEnemie[i]
					if Obj.guid == GUID then
						alreadyExists = true
					end
				end
				-- Friendly Filter
			elseif UnitIsFriend('player', unit) then
				for i=1, #NeP.OM.unitFriend do
					local Obj = NeP.OM.unitFriend[i]
					if Obj.guid == GUID then
						alreadyExists = true
					end
				end
			end
		end
		return not alreadyExists
	end

	local nameplates = {}
	
	function lnr:OnEnable()
		self:LNR_RegisterCallback("LNR_ON_NEW_PLATE");
		self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE");
	end

	function lnr:OnDisable()
		self:LNR_UnregisterAllCallbacks();
	end

	function lnr:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)
		local tK = plateData.unitToken
		nameplates[tK] = tK
	end

	function lnr:LNR_ON_RECYCLE_PLATE(eventname, plateFrame, plateData)
		local tK = plateData.unitToken
		nameplates[tK] = nil
	end

	function NeP.OM.Maker()
		-- Self
		NeP.OM.addToOM('player')
		-- Mouseover
		if UnitExists('mouseover') then
			local object = 'mouseover'
			local ObjDistance = Engine.Distance('player', object)
			if GenericFilter(object) then
				if ObjDistance <= 100 then
					NeP.OM.addToOM(object)
				end
			end
		end
		-- Target Cache
		if UnitExists('target') then
			local object = 'target'
			local ObjDistance = Engine.Distance('player', object)
			if GenericFilter(object) then
				if ObjDistance <= 100 then
					NeP.OM.addToOM(object)
				end
			end
		end
		-- If in Group scan frames...
		if IsInGroup() or IsInRaid() then
			local prefix = (IsInRaid() and 'raid') or 'party'
			for i = 1, GetNumGroupMembers() do
				-- Enemie
				local target = prefix..i..'target'
				local ObjDistance = Engine.Distance('player', target)
				if GenericFilter(target) then
					if ObjDistance <= 100 then
						NeP.OM.addToOM(target)
					end
				end
				-- Friendly
				local friendly = prefix..i
				local ObjDistance = Engine.Distance('player', friendly)
				if GenericFilter(friendly) then
					if ObjDistance <= 100 then
						NeP.OM.addToOM(friendly)
					end
				end
			end
		end
		-- Nameplate cache
		for k,_ in pairs(nameplates) do
			local plate = nameplates[k]
			if GenericFilter(plate) then
					NeP.OM.addToOM(plate)
			end
		end
	end

end

NeP.Engine.FaceRoll()