local NeP = NeP
NeP.BossID = {}

--BossIDs Lib
NeP.BossID.table = NeP._G.LibStub("LibBossIDs-1.0").BossIDs
local T = NeP.BossID.table

function NeP.BossID.Add(_,...)
  if type(...) == 'table' then
    for id in pairs(...) do
      id = tonumber(id)
      if id then
        T[id] = true
      end
    end
  else
    local id = tonumber(...)
    if id then
      T[id] = true
    end
  end
end

local function WoWBossID(unit)
  if not unit then return false end
  for i=1, 4 do
    if NeP.DSL:Get('is')(unit, "boss"..i) then
      return true
    end
  end
end

local function UnitID(unit)
  if tonumber(unit) then
    return nil, tonumber(unit)
  else
    local guid = NeP.DSL:Get('guid')(unit)
    if not guid then return end
    local unitid = select(6, NeP._G.strsplit("-",guid))
    return unit, tonumber(unitid)
  end
end

function NeP.BossID.Eval(_, unit)
  if not unit then return false end
  local unit2, unitid = UnitID(unit)
  return unit2 and NeP.DSL:Get('exists')(unit2) and WoWBossID(unit2) or T[unitid]
end

function NeP.BossID.Get()
  return T
end

NeP.BossID:Add({
  -- The Nighthold
  [102263] = true, -- Skorpyron
  [101002] = true, -- Krosus
  [104415] = true, -- Chronomatic Anomaly
  [104288] = true, -- Trilliax
  [103758] = true, -- Star Augur Etraeus
  [105503] = true, -- Gul'dan
  [110965] = true, -- Grand Magistrix Elisande
  [107699] = true, -- Spellblade Aluriel
  [104528] = true, -- High Botanist Tel'arn
  [103685] = true, -- Tichondrius
  [166608] = true, -- Mueh'zala (SL - De Other Side)
})
