local NeP, g = NeP, NeP._G
NeP.Core = {}

local unpack = unpack

local last_print = ""
function NeP.Core.Print(_, ...)
	if last_print ~= ... then
		last_print = ...
		print('[|cff'..NeP.Color..'NeP|r]', ...)
	end
end

local d_color = {
	hex = 'FFFFFF',
	rgb = {1,1,1}
}

function NeP.Core.ClassColor(_, unit, type)
	type = type and type:lower() or 'hex'
	if NeP.DSL:Get('exists')(unit) then
		local classid  = select(3, g.UnitClass(unit))
		if classid then
			return NeP.ClassTable:GetClassColor(classid, type)
		end
	end
	return d_color[type]
end

function NeP.Core.Round(_, num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function NeP.Core.GetSpellID(_, spell)
	local _type = type(spell)
	if not spell then
		return
	elseif _type == 'string' and spell:find('^%d') then
		return tonumber(spell)
	end
	local index, stype = NeP.Core:GetSpellBookIndex(spell)
	local spellID = select(7, g.GetSpellInfo(index, stype))
	return spellID
end

function NeP.Core.GetSpellName(_, spell)
	if not spell or type(spell) == 'string' then return spell end
	local spellID = tonumber(spell)
	if spellID then
		return g.GetSpellInfo(spellID)
	end
	return spell
end

function NeP.Core.GetItemID(_, item)
	if not item or type(item) == 'number' then return item end
	local itemID = string.match(select(2, g.GetItemInfo(item)) or '', 'Hitem:(%d+):')
	return tonumber(itemID) or item
end

function NeP.Core.UnitID(_, unit)
	if unit and NeP.DSL:Get('exists')(unit) then
		local guid = NeP.DSL:Get('guid')(unit)
		if guid then
			local type, _, server_id,_,_, npc_id = g.strsplit("-", guid)
			if type == "Player" then
				return tonumber(server_id)
			elseif npc_id then
				return tonumber(npc_id)
			end
		end
	end
end

function NeP.Core.GetSpellBookIndex(_, spell)
	local spellName = NeP.Core:GetSpellName(spell)
	if not spellName then return end
	spellName = spellName:lower()

	for t = 1, g.GetNumSpellTabs() do
		local _, _, offset, numSpells = g.GetSpellTabInfo(t)
		for i = 1, (offset + numSpells) do
			if g.GetSpellBookItemName(i, g.BOOKTYPE_SPELL):lower() == spellName then
				return i, g.BOOKTYPE_SPELL
			end
		end
	end

	local numFlyouts = g.GetNumFlyouts()
	for f = 1, numFlyouts do
		local flyoutID = g.GetFlyoutID(f)
		local _, _, numSlots, isKnown = g.GetFlyoutInfo(flyoutID)
		if isKnown and numSlots > 0 then
			for x = 1, numSlots do
				local spellID, _, isKnownSpell = g.GetFlyoutSlotInfo(flyoutID, x)
				local name = NeP.Core:GetSpellName(spellID)
				if name and isKnownSpell and name:lower() == spellName then
					return spellID, nil
				end
			end
		end
	end

	local numPetSpells = g.HasPetSpells()
	if numPetSpells then
		for i = 1, numPetSpells do
			if g.GetSpellBookItemName(i, g.BOOKTYPE_PET):lower() == spellName then
				return i, g.BOOKTYPE_PET
			end
		end
	end
end

local Run_Cache = {}
function NeP.Core.WhenInGame(_, func, prio)
	if Run_Cache then
		table.insert(Run_Cache, {func = func, prio = prio or -(#Run_Cache)})
	else
		func()
	end
end

function NeP.Core.HexToRGB(_, hex)
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function NeP.Core.string_split(_, string, delimiter)
	local result, from = {}, 1
	local delim_from, delim_to = string.find(string, delimiter, from)
	while delim_from do
		table.insert( result, string.sub(string, from , delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(string, delimiter, from)
	end
	table.insert(result, string.sub(string, from))
	return result
end

local unit_buffs = NeP.Cache.Buffs
function  NeP.Core.UnitBuffL(target, spell, filter)
	if not spell
	or not target then
		return nil
	end
	spell = tostring(spell)
	local key = target .. '-' .. (filter or 'no_filter')
	-- if cached return
	if unit_buffs[key] then
		local found = unit_buffs[key][spell]
		if found then
			return unpack(found)
		end
	end
	-- build a cache
	unit_buffs[key] = {}
	local i, name, data, cnt, tp, duration, expi, caster, canSteal, spellId, isBoss, _ = 1, true
	while name do
		name, _, cnt, tp, duration, expi, caster, canSteal,_,spellId,_, isBoss = g.UnitBuff(target, i, filter)
		if name then
			data = {name, cnt, expi, caster, tp, canSteal, isBoss, duration}
			unit_buffs[key][name] = data
			unit_buffs[key][tostring(spellId)] = data
			i=i+1
		end
	end
	-- return if found
	local found = unit_buffs[key][spell]
	if found then
		return unpack(found)
	end
end

local unit_debuffs = NeP.Cache.Debuffs
function  NeP.Core.UnitDebuffL(target, spell, filter)
	if not spell
	or not target then
		return nil
	end
	spell = tostring(spell)
	local key = target .. '-' .. (filter or 'no_filter')
	-- if cached return
	if unit_debuffs[key] then
		local found = unit_debuffs[key][spell]
		if found then
			return unpack(found)
		end
	end
	-- build a cache
	unit_debuffs[key] = {}
	local i, name, data, cnt, tp, duration, expi, caster, canSteal, spellId, isBoss, _ = 1, true
	while name do
		name, _, cnt, tp, duration, expi, caster, canSteal,_,spellId,_, isBoss = g.UnitDebuff(target, i, filter)
		if name then
			data = {name, cnt, expi, caster, tp, canSteal, isBoss, duration}
			unit_debuffs[key][name] = data
			unit_debuffs[key][tostring(spellId)] = data
			i=i+1
		end
	end
	-- return if found
	local found = unit_debuffs[key][spell]
	if found then
		return unpack(found)
	end
end

function NeP.Core.ForceLoad()
	if not Run_Cache then return end
	table.sort(Run_Cache, function(a,b) return a.prio > b.prio end)
	NeP.Color = NeP.Core:ClassColor('player', 'hex')
	for i=1, #Run_Cache do
		Run_Cache[i].func()
	end
	Run_Cache = nil
end

NeP.Listener:Add("NeP_Core_load", "PLAYER_ENTERING_WORLD", function()
	g.C_Timer.After(local_stream_name and 0 or 1, function()
		NeP.Core.ForceLoad();
	end)
end)
