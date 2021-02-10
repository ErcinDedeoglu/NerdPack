local NeP, g = NeP, NeP._G

NeP.DSL:Register('spell.cooldown', function(_, spell)
  local start, duration = g.GetSpellCooldown(spell)
  if not start then return 0 end
  return start ~= 0 and (start + duration - g.GetTime()) or 0
end)

NeP.DSL:Register('spell.recharge', function(_, spell)
  local time = g.GetTime()
  local _, _, start, duration = g.GetSpellCharges(spell)
  if start and (start + duration - time) > duration then
    return 0
  end
  return start and (start + duration - time)
end)

NeP.DSL:Register('spell.usable', function(_, spell)
  return not not g.IsUsableSpell(spell)
end)

NeP.DSL:Register('spell.exists', function(_, spell)
  spell = tonumber(spell) and g.GetSpellInfo(spell) or spell
  return spell and g.GetSpellBookItemInfo(spell)
end)

NeP.DSL:Register('spell.charges', function(_, spell)
  local charges, maxCharges, start, duration = g.GetSpellCharges(spell)
  if duration and charges ~= maxCharges then
    charges = charges + ((g.GetTime() - start) / duration)
  end
  return charges or 0
end)

NeP.DSL:Register('spell.count', function(_, spell)
  return select(1, g.GetSpellCount(spell))
end)

NeP.DSL:Register('spell.range', function(target, spell)
  local spellIndex, spellBook = NeP.Core:GetSpellBookIndex(spell)
  return spellIndex and g.IsSpellInRange(spellIndex, spellBook, target) == 1
end)

NeP.DSL:Register('spell.casttime', function(_, spell)
  local CastTime = select(4, g.GetSpellInfo(spell))
  return CastTime and CastTime / 1000 or 0
end)

local _procs = {}
NeP.Listener:Add('NeP_Procs_add', 'SPELL_ACTIVATION_OVERLAY_GLOW_SHOW', function(spellID)
	_procs[spellID] = true
	_procs[g.GetSpellInfo(spellID)] = true
end)

NeP.Listener:Add('NeP_Procs_rem', 'SPELL_ACTIVATION_OVERLAY_GLOW_HIDE', function(spellID)
	_procs[spellID] = nil
	_procs[g.GetSpellInfo(spellID)] = nil
end)

NeP.DSL:Register("spell.proc", function(_, spell)
	return _procs[spell] or _procs[g.GetSpellInfo(spell)] or false
end)

NeP.DSL:Register('power.regen', function(target)
  return select(2, g.GetPowerRegen(target))
end)

NeP.DSL:Register('casttime', function(_, spell)
  return select(3, g.GetSpellInfo(spell))
end)

NeP.DSL:Register('lastcast', function(Unit, Spell)
  -- Convert the spell into name
  Spell = g.GetSpellInfo(Spell)
  -- if Unit is player, returns lasr parser execute.
  if  NeP.DSL:Get('is')('player', Unit) then
    local LastCast = NeP.Parser.LastCast
    return LastCast == Spell, LastCast
  end
  local LastCast = NeP.CombatTracker:LastCast(Unit)
  return LastCast == Spell, LastCast
end)

NeP.DSL:Register('lastcast.succeed', function(Unit, spell)
  spell = g.GetSpellInfo(spell)
  local LastCast = NeP.CombatTracker:LastCast(Unit)
  return LastCast == spell, LastCast
end)

NeP.DSL:Register("lastgcd", function(Unit, Spell)
  -- Convert the spell into name
  Spell = g.GetSpellInfo(Spell)
  -- if Unit is player, returns lasr parser execute.
  if NeP.DSL:Get('is')('player', Unit) then
    local LastCast = NeP.Parser.LastGCD
    return NeP.Parser.LastGCD == Spell, LastCast
  end
  local LastCast = NeP.CombatTracker:LastCast(Unit)
  return LastCast == Spell, LastCast
end)

NeP.DSL:Register("enchant.mainhand", function()
  return g.GetWeaponEnchantInfo()
end)

NeP.DSL:Register("enchant.offhand", function()
  return select(5, g.GetWeaponEnchantInfo())
end)

NeP.DSL:Register("glyph", function(_,spell)
  local spellId = tonumber(spell)
  local glyphName, glyphId
  for i = 1, 6 do
    glyphId = select(4, g.GetGlyphSocketInfo(i))
    if glyphId then
      if spellId then
        if select(4, g.GetGlyphSocketInfo(i)) == spellId then
          return true
        end
      else
        glyphName = NeP.Core:GetSpellName(glyphId)
        if glyphName:find(spell) then
          return true
        end
      end
    end
  end
  return false
end)
