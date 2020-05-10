local _, NeP = ...
local L = NeP.Locale

-- MasterToggle
NeP.Interface:AddToggle({
  key = 'mastertoggle',
  name = 'MasterToggle',
  text = L:TA('mainframe', 'MasterToggle'),
  icon = 'Interface\\ICONS\\Ability_repair.png',
  func = function(_, button)
    if button == "RightButton" then
      NeP.Interface:DropMenu()
      NeP.Interface:UpdateCRs()
    end
  end,
  nohide = true
})

--Interrupts
NeP.Interface:AddToggle({
  key = 'interrupts',
  name = 'Interrupts',
  text = L:TA('mainframe', 'Interrupts'),
  icon = 'Interface\\ICONS\\Ability_Kick.png',
  nohide = true
})

-- Cooldowns
NeP.Interface:AddToggle({
  key = 'cooldowns',
  name = 'Cooldowns',
  text = L:TA('mainframe', 'Cooldowns'),
  icon = 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png',
  nohide = true
})

--Multitarget
NeP.Interface:AddToggle({
  key = 'aoe',
  name = 'Multitarget',
  text = L:TA('mainframe', 'AoE'),
  icon = 'Interface\\ICONS\\Ability_Druid_Starfall.png',
  nohide = true
})
