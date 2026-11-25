
-- Original Player (local) Animate script (humanoidAnimatePlayEmote.lua) by Roblox's development team
-- Adapted by @LunixHenry2040
-- August 2026

---------------------------------- Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")


---------------------------------- Text Chat
local GeneralChannel : TextChannel = TextChatService:WaitForChild("TextChannels").RBXGeneral


---------------------------------- Player
local Player = Players.LocalPlayer

-- Character
local Character : Model = script.Parent
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
local Animator : Animator = Humanoid:WaitForChild("Animator")

local Torso = Character:WaitForChild("Torso")

local Joints = {
	["Neck"] = Torso:WaitForChild("Neck"),
	["Left Shoulder"] = Torso:WaitForChild("Left Shoulder"),
	["Right Shoulder"] = Torso:WaitForChild("Right Shoulder"),
	["Left Hip"] = Torso:WaitForChild("Left Hip"),
	["Right Hip"] = Torso:WaitForChild("Right Hip"),
}


-- Rig scale
local userAnimateScaleRunSuccess, userAnimateScaleRunValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun") end)
local userAnimateScaleRun = userAnimateScaleRunSuccess and userAnimateScaleRunValue

-- Return the character's model scale, or 1 if it doesn't have a scale
function getRigScale()
	if userAnimateScaleRun then
		return Character:GetScale()
	else
		return 1
	end
end


---------------------------------- Script Instances
local BindablesF = script:WaitForChild("Bindables")
local Bindables = {
	RunSound = BindablesF:WaitForChild("RunSound"),
	PlayEmote = BindablesF:WaitForChild("PlayEmote")
}


local AnimationsF = script:WaitForChild("Animations")


---------------------------------- Data & Status



local Data = require(script:WaitForChild("Data"))
local Settings = Data.Settings

local Status = {
	HumanoidSpeed = 0,
	
	Pose = "Standing",
	lastTick = 0,
	
	CurrentAnim = "",
	CurrentAnimInstance = nil,
	CurrentAnimTrack = nil,
	CurrentAnimIsPlayingHandler = nil,
	CurrentAnimSpeed = 1.0,
	AnimTable = {},
}

local Sounds = {
	EmoteSound = Torso:WaitForChild("EmoteSound"),
}



--------------------------------------------------------------------
--------------------------------------------------------------------
---------------------------------- Animation Configurations


-- Configure or add the animation set specified by the name and file list.
function configureAnimationSet(name, fileList)
	
	-- Disconnect any existing connections (before adding new ones)
	if Status.AnimTable[name] then
		for _, connection in Status.AnimTable[name].connections do
			connection:disconnect()
		end
	end
	
	-- Reset anim values
	Status.AnimTable[name] = {}
	Status.AnimTable[name].count = 0
	Status.AnimTable[name].totalWeight = 0	
	Status.AnimTable[name].connections = {}

	-- check for config values
	local config = AnimationsF:FindFirstChild(name)
	if config then
		
		-- Load the Animation, its anims and configs into the AnimTable
		
		-- Add new connections for when it changes again
		table.insert(Status.AnimTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
		table.insert(Status.AnimTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
		
		-- Loop through its animation objects 
		-- add them as anims to the table
		local idx = 1
		for _, childPart in pairs(config:GetChildren()) do
			if (childPart:IsA("Animation")) then
				
				-- Add new connections for the animation
				table.insert(Status.AnimTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
				
				Status.AnimTable[name][idx] = {}
				Status.AnimTable[name][idx].anim = childPart
				
				local weightObject = childPart:FindFirstChild("Weight")
				Status.AnimTable[name][idx].weight = if weightObject then weightObject.Value else 1
				
				Status.AnimTable[name][idx].sound = fileList[idx].soundid
				Status.AnimTable[name][idx].soundstartpos = fileList[idx].soundstartpos
				Status.AnimTable[name].count = Status.AnimTable[name].count + 1
				Status.AnimTable[name].totalWeight = Status.AnimTable[name].totalWeight + Status.AnimTable[name][idx].weight
				--			print(name .. " [" .. idx .. "] " .. Status.AnimTable[name][idx].anim.AnimationId .. " (" .. Status.AnimTable[name][idx].weight .. ")")
				
				idx = idx + 1
				
			end
		end
	end

	-- Fallback to defaults
	-- If an animation object is not found for this anim, create it
	if Status.AnimTable[name].count <= 0 then
		for idx, anim in fileList do
			Status.AnimTable[name][idx] = {}
			Status.AnimTable[name][idx].anim = Instance.new("Animation")
			Status.AnimTable[name][idx].anim.Name = name
			Status.AnimTable[name][idx].anim.AnimationId = anim.id
			Status.AnimTable[name][idx].weight = anim.weight
			Status.AnimTable[name][idx].sound = anim.soundid
			Status.AnimTable[name][idx].soundstartpos = anim.soundstartpos
			Status.AnimTable[name].count = Status.AnimTable[name].count + 1
			Status.AnimTable[name].totalWeight = Status.AnimTable[name].totalWeight + anim.weight
			--			print(name .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
		end
	end
end


-- When the animation objects are added or removed, reflect the changes in the script library
function OnScriptChild(child)
	local fileList = Data.AnimLibrary[child.Name]
	if not fileList then return end
	configureAnimationSet(child.Name, fileList)
end

AnimationsF.ChildAdded:connect(OnScriptChild)
AnimationsF.ChildRemoved:connect(OnScriptChild)


-- Clear any existing animation tracks
-- Fixes issue with characters that are moved in and out of the Workspace, accumulating tracks
if Animator then
	local animTracks = Animator:GetPlayingAnimationTracks()
	for i, track in animTracks do
		track:Stop(0)
		track:Destroy()
	end
end


-- Initial setup of the animation table 
for name, fileList in Data.AnimLibrary do 
	configureAnimationSet(name, fileList)
end	


--------------------------------------------------------------------
---------------------------------- Animation Handling

-- Stops all animation playback (and for emotes, their sounds). Returns the animation name that was previously played.
function stopAllAnimations(fadeTime)
	
	-- Stop all playing tracks (rogue ones)
	for i, AnimTrack : AnimationTrack in Animator:GetPlayingAnimationTracks() do
		for i, obj in AnimationsF:GetDescendants() do
			if obj:IsA("Animation") then
				if AnimTrack.Animation.AnimationId == obj.AnimationId then
					AnimTrack:Stop(fadeTime or nil)
				end
			end
		end
	end
	
	
	local oldAnim = Status.CurrentAnim

	-- Return to idle if finishing a emote
	if Data.Emotes.NonDances[oldAnim] or Data.Emotes.Dances[oldAnim] then
		oldAnim = "idle"
	end
	
	-- Clear the current anim and stop playback
	Status.CurrentAnim = ""
	Status.CurrentAnimInstance = nil
	if Status.CurrentAnimIsPlayingHandler then Status.CurrentAnimIsPlayingHandler:disconnect() end
	
	if (Status.CurrentAnimTrack) then
		if fadeTime then
			Status.CurrentAnimTrack:Stop(fadeTime)
		else
			Status.CurrentAnimTrack:Stop()
		end
		
		Bindables.RunSound:FireServer(Sounds.EmoteSound, "Stop", nil, nil, nil)
		Status.CurrentAnimTrack:Destroy()
		Status.CurrentAnimTrack = nil
		
	end
	
	script:SetAttribute("IsPlayingEmote", false)
	
	return oldAnim
end


-- Set the speed of the current animation
function setAnimationSpeed(speed)
	if speed == Status.CurrentAnimSpeed then return end
	Status.CurrentAnimSpeed = speed
	Status.CurrentAnimTrack:AdjustSpeed(Status.CurrentAnimSpeed)
end


-- Run when a keyframe is reached in the current animation
function onAnimationEnded()
	
	-- Idle when finished, or replay the animation if it loops
	if not Status.CurrentAnimTrack.IsPlaying then
		
		local repeatAnim = Status.CurrentAnim
		-- return to idle if finishing an emote
		if (Data.Emotes.NonDances[repeatAnim] == false)
			or (Data.Emotes.Dances[repeatAnim] == false) then
			stopAllAnimations(0.1)
			repeatAnim = "idle"
		end
		
		local animSpeed = Status.CurrentAnimSpeed
		playAnimation(repeatAnim, 0.1, Humanoid)
		setAnimationSpeed(animSpeed)
	end
end


-- Play an animation from the animation table.
function playAnimation(animName, transitionTime) 
	
	local fileList = Status.AnimTable[animName]
	
	if not fileList then return end
	
	-- Randomize for anim
	local roll = math.random(1, fileList.totalWeight) 
	local origRoll = roll
	local idx = 1
	while (roll > fileList[idx].weight) do
		roll = roll - fileList[idx].weight
		idx = idx + 1
	end
	--print(animName .. " " .. idx .. " [" .. origRoll .. "]")
	
	-- Get the animation and sound
	local item = fileList[idx]
	local anim = item.anim
	local sound = item.sound
	local soundstartpos = item.soundstartpos
	
	if anim == Status.CurrentAnimInstance then return end
	

	-- Play the animation		
	if Status.CurrentAnimTrack then
		Status.CurrentAnimTrack:Stop(transitionTime)
		Status.CurrentAnimTrack:Destroy()
	end

	Status.CurrentAnimSpeed = 1.0

	-- Load the AnimationTrack
	Status.CurrentAnimTrack = Animator:LoadAnimation(anim)

	-- Play the animation
	Status.CurrentAnimTrack:Play(transitionTime)
	Status.CurrentAnim = animName
	Status.CurrentAnimInstance = anim
	
	-- Run the sound if it exists
	Bindables.RunSound:FireServer(Sounds.EmoteSound, "Stop", nil, nil, nil)
	if sound then
		Bindables.RunSound:FireServer(Sounds.EmoteSound, "Set", sound, soundstartpos, Data.Emotes.NonDances[animName] or Data.Emotes.Dances[animName])
	end

	-- Set up keyframe name triggers
	if Status.CurrentAnimIsPlayingHandler then
		Status.CurrentAnimIsPlayingHandler:Disconnect()
	end
	Status.CurrentAnimIsPlayingHandler = Status.CurrentAnimTrack:GetPropertyChangedSignal("IsPlaying"):Connect(onAnimationEnded)


end



-- Stop all animations and play the idle animation
function resetToIdle()
	stopAllAnimations(0.25)
	playAnimation("idle", 0.1, Humanoid)
	Status.Pose = "Standing"
end

function resetToMovement()
	stopAllAnimations(0.25)
	onRunning(Status.HumanoidSpeed)
end


script:GetAttributeChangedSignal("IsAnimationChanged"):Connect(function()
	if not script:GetAttribute("IsAnimationChanged") then return end
	task.spawn(resetToMovement)
end)

AnimationsF.idle.Animation1.Changed:Connect(resetToIdle)
AnimationsF.idle.Animation2.Changed:Connect(resetToIdle)





--------------------------------------------------------------------
---------------------------------- Character State Machine and Functions

function onRunning(speed) 
	if (script:GetAttribute("IsPlayingEmote") and Humanoid.MoveDirection.Magnitude <= 0) then return end
	
	Status.HumanoidSpeed = speed
	
	speed /= getRigScale()
	stopAllAnimations(0.25)
	
	if speed > 0.01 then
		
		if Humanoid.WalkSpeed > StarterPlayer.CharacterWalkSpeed + 1 then
			playAnimation("run", 0.1, Humanoid)
			setAnimationSpeed(speed / 20)
			Status.Pose = "Running"
		else
			playAnimation("walk", 0.1, Humanoid)
			Status.Pose = "Walking"
			setAnimationSpeed(speed / 14.5)
		end
		
	else
		if not script:GetAttribute("IsPlayingEmote") then
			task.wait()
			playAnimation("idle", 0.1, Humanoid)
			Status.Pose = "Standing"
		end
		
	end
end

function onDied()
	Status.Pose = "Dead"
	TweenService:Create(Sounds.EmoteSound, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {PlaybackSpeed = 0}):Play()
end

function onJumping()
	playAnimation("jump", 0.1, Humanoid)
	Status.Pose = "Jumping"
end

function onClimbing(speed)
	speed /= getRigScale()

	playAnimation("climb", 0.1, Humanoid)
	setAnimationSpeed(speed / 6)
	Status.Pose = "Climbing"
end

function onGettingUp()
	Status.Pose = "GettingUp"
end

function onFreeFall()
	Status.Pose = "FreeFall"
end

function onFallingDown()
	Status.Pose = "FallingDown"
end

function onSeated()
	Status.Pose = "Seated"
	
	while Status.Pose == "Seated" do
		task.wait()
		playAnimation("sit", 0.5, Humanoid)
	end
end

function onPlatformStanding()
	Status.Pose = "PlatformStanding"
	playAnimation("platformstand", 0.3, Humanoid)
end

function onSwimming(speed)
	if speed > 0 then
		Status.Pose = "Running"
	else
		Status.Pose = "Standing"
	end
end


Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)
Humanoid.PlatformStanding:connect(onPlatformStanding)
Humanoid.Swimming:connect(onSwimming)




function move(t)
	
	------ Time Math Values (CURRENTLY UNUSED)
	local deltaTime = t - Status.lastTick
	Status.lastTick = t
	
	if (Status.Pose == "FreeFall") then
		playAnimation("fall", Settings.FallTransitionTime, Humanoid)
			
	elseif (Status.Pose == "Dead" 
			or Status.Pose == "GettingUp" 
			or Status.Pose == "FallingDown" 
			or Status.Pose == "PlatformStanding") then
			
		stopAllAnimations()
	end
	
end


-- Keep track of the time
function initTime() 
	while Character and Character.Parent do
		local t = task.wait()
		move(t)
		print(Status.Pose)
	end
end

task.spawn(initTime)


--------------------------------------------------------------------
---------------------------------- Emotes

Player.Chatted:connect(function(msg)
	local emote = ""
	if msg == "/e dance" then
		emote = Data.EmotesTables.Dances[math.random(1, #Data.EmotesTables.Dances)]
	elseif msg == "/e random" then
		emote = Data.EmotesTables.NonDances[math.random(1, #Data.EmotesTables.NonDances)]
	elseif (string.sub(msg, 1, 3) == "/e ") then
		emote = string.sub(msg, 4)
	elseif (string.sub(msg, 1, 7) == "/emote ") then
		emote = string.sub(msg, 8)
	elseif string.lower(msg) == "afk" then
		emote = "afk"
	end

	if (Data.Emotes.NonDances[emote] ~= nil or Data.Emotes.Dances[emote] ~= nil) and Status.Pose == "Standing" then
		playAnimation(emote, 0.25, Humanoid)
		script:SetAttribute("IsPlayingEmote", true)
		GeneralChannel:DisplaySystemMessage('Played emote: "'..emote..'".' )
	end
	
end)



---------------------------------- Initialization
task.spawn(resetToIdle)
