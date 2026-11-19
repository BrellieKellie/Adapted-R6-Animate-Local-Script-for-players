-- AnimateServer

-- Original Player (local) Animate script by Roblox's development team
-- Heavily reworked by @LunixHenry2040 
-- August 2026

---------------------------- Script
local Animate = script.Parent

local BindablesF = Animate:WaitForChild("Bindables")
local Bindables = {
	RunSound = BindablesF:WaitForChild("RunSound")
}

---------------------------- Character
local Character : Model = Animate.Parent
local Torso = Character:WaitForChild("Torso")

local Sounds = {
	EmoteSound = Instance.new("Sound"),
}
Sounds.EmoteSound.Name = "EmoteSound"
Sounds.EmoteSound.Parent = Torso
Sounds.EmoteSound.Looped = true
Sounds.EmoteSound.RollOffMaxDistance = 50


-- ========================== Bindables
Bindables.RunSound.OnServerEvent:Connect(function(plr : Player, Sound : Sound, ActionName : string, SetId : string, 
	StartPos : number, Looped : boolean)
	
	if ActionName == "Play" then
		Sound:Play()
	elseif ActionName == "Stop" then
		Sound:Stop()
	elseif ActionName == "Set" then
		Sound.SoundId = SetId
		Sound.TimePosition = StartPos
		Sound.Looped = Looped
		Sound:Play()
	end
	
end)
