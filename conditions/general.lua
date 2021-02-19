local NeP, g = NeP, NeP._G

local function checkChanneling(target)
  local name, _, _, startTime, endTime, _, notInterruptible = g.UnitChannelInfo(target)
  if name then return name, startTime, endTime, notInterruptible end
end

local function checkCasting(target)
  local name, startTime, endTime, notInterruptible = checkChanneling(target)
  if name then return name, startTime, endTime, notInterruptible end
  name, _, _, startTime, endTime, _, _, notInterruptible = g.UnitCastingInfo(target)
  if name then return name, startTime, endTime, notInterruptible end
end

NeP.DSL:Register('true', function()
  return true
end)

NeP.DSL:Register('false', function()
  return false
end)

NeP.DSL:Register('timetomax', function(target)
  local max = g.UnitPowerMax(target)
  local curr = g.UnitPower(target)
  local regen = select(2, g.GetPowerRegen(target))
  return (max - curr) * (1.0 / regen)
end)

NeP.DSL:Register('toggle', function(_, toggle)
  return NeP.Config:Read('TOGGLE_STATES', toggle:lower(), false)
end)

NeP.DSL:Register('casting.percent', function(target)
  local name, startTime, endTime = checkCasting(target)
  if name then
    local castLength = (endTime - startTime) / 1000 or 0
    local secondsDone = g.GetTime() - (startTime / 1000) or 0
    return ((secondsDone/castLength)*100) or 0
  end
  return 0
end)

NeP.DSL:Register('channeling.percent', function(target)
  local name, startTime, endTime = checkChanneling(target)
  if name then
    local castLength = (endTime - startTime) / 1000 or 0
    local secondsDone = g.GetTime() - (startTime / 1000) or 0
    return ((secondsDone/castLength)*100) or 0
  end
  return 0
end)

NeP.DSL:Register('casting.delta', function(target)
  local name, startTime, endTime, notInterruptible = checkCasting(target)
  if name and not notInterruptible then
    local castLength = (endTime - startTime) / 1000 or 0
    local secondsLeft = endTime / 1000 - g.GetTime() or 0
    return secondsLeft or 0, castLength or 0
  end
  return 0
end)

NeP.DSL:Register('channeling', function (target, spell)
  local name = checkChanneling(target)
  spell = NeP.Core:GetSpellName(spell)
  return spell and (name == spell)
end)

NeP.DSL:Register('casting', function(target, spell)
  local name = checkCasting(target)
  spell = NeP.Core:GetSpellName(spell)
  return spell and (name == spell)
end)

NeP.DSL:Register('interruptAt', function (target, spell)
  if NeP.DSL:Get('is')('player', target) then return false end
  if spell and NeP.DSL:Get('toggle')(nil, 'Interrupts') then
    local stopAt = (tonumber(spell) or 35) + math.random(-5, 5)
    local secondsLeft, castLength = NeP.DSL:Get('casting.delta')(target)
    return secondsLeft ~= 0 and (100 - (secondsLeft / castLength * 100)) > stopAt
  end
end)

local TimeOutTable ={}

--USAGE: timeout(TIMER_NAME, SECONDS)
NeP.DSL:Register('timeout', function(_, args)
  local name, time = g.strsplit(',', args, 2)
   if not TimeOutTable[name] then TimeOutTable[name] = true;
    g.C_Timer.After(tonumber(time), function() TimeOutTable[name] = nil end);
    return true; end
   return not TimeOutTable[name]
end)

local TimeOutUnitTable ={}

--USAGE: UNIT.targettimeout(TIMER_NAME, SECONDS)
NeP.DSL:Register('targettimeout', function(target, args)
  target = NeP.DSL:Get('guid')(target)
  local name, time = g.strsplit(',', args, 2)
   if not TimeOutUnitTable[target..name] then TimeOutUnitTable[target..name] = true;
    g.C_Timer.After(tonumber(time), function() TimeOutUnitTable[target..name] = nil end);
    return true; end
   return not TimeOutUnitTable[target..name]
end)

NeP.DSL:Register('isnear', function(target, args)
  local targetID, distance = g.strsplit(',', args, 2)
  targetID = tonumber(targetID) or 0
  distance = tonumber(distance) or 60
  for _, Obj in pairs(NeP.OM:Get('Enemy')) do
    if Obj.id == targetID then
      return NeP.Protected.Distance('player', target) <= distance
    end
  end
end)

NeP.DSL:Register('gcd', function()
  local class = select(3,g.UnitClass("player"))
  -- Some class's always have GCD = 1
  if class == 4
  or (class == 11 and g.GetShapeshiftForm() == 2)
  or (class == 10 and g.GetSpecialization() ~= 2) then
    return 1
  end
  return math.floor((1.5 / ((g.GetHaste() / 100) + 1)) * 10^3 ) / 10^3
end)

NeP.DSL:Register('ui', function(_, args)
  local key, UI_key = g.strsplit(",", args, 2)
  UI_key = UI_key or NeP.CR.CR.name
  return NeP.Interface:Fetch(UI_key, key)
end)
