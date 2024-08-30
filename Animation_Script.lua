
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterStateChange = ReplicatedStorage:WaitForChild("CharacterStateChange")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local character = Player.Character or Player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- https://create.roblox.com/store/asset/[ID]/Run-Animation 

animation = false

local Idle_Animation = Instance.new("Animation")
Idle_Animation.AnimationId = "rbxassetid://73871608617915"

local Walking_Animation = Instance.new("Animation")
Walking_Animation.AnimationId = "rbxassetid://94360462924271"


local Running_Animation = Instance.new("Animation")
Running_Animation.AnimationId = "rbxassetid://135814899735182/"

-- Loading Animations onto humanoid 
local Idle_Track = humanoid:LoadAnimation(Idle_Animation)
local Walk_Track = humanoid:LoadAnimation(Walking_Animation)
local Running_Track = humanoid:LoadAnimation(Running_Animation)

local walk_speed = 18
local sprint_speed = 30

Idle_Track:Play()

local function Animation_State_Check()
	--[[
	Gets the current 'WalkSpeed', of Player
	if higher than 18
	   - Running Animation
	   
	If == 18 or lower:
	   - Walking Animation
	
	Gets the current 'JumpPower', of Player
	if higher than 0
	   - Jumping Animation
	
	
	Gets the current 'FloorMaterial', of Player
	if 'Air'
	   - Idle Animation
	if 'Ground'
	   - Walking Animation
	]]
	
	if animation == false then -- Gliding or anyother animation not neeeding movement animations
		print("ANIMATION FALSE!!!")
		Idle_Track:Stop()
		Walk_Track:Stop()
		Running_Track:Stop()
		return
	else
		local speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
		print("Current Speed: ",speed)
		-- Lesser than <
		-- Greater than >
		if speed < 0.1  then
			-- print("Idle")
			Walk_Track:Stop()
			Running_Track:Stop()

			Idle_Track:Play()

			-- If speed bigger than 0.1 & Speed less than 18
			-- Walking Animation Trigger
			-- 0.1 -> 29
			-- Todo: Improve code by anticipating edge-cases
		elseif speed > 0.1 and speed < 29 then
			-- print("Walking")
			Idle_Track:Stop()
			Running_Track:Stop()
			Walk_Track:Play()

			-- If speed is greater than walkspeed  & 
		elseif speed > walk_speed  then
			-- print("Running")
			Idle_Track:Stop()
			Walk_Track:Stop()
			Running_Track:Play()

		end
	end

	
	
end

function state_change(Character_State)
	print("STATE CHANGE")
	if Character_State == "Gliding" then
		print("Change State to: Gliding")
		animation = false
	else -- Contineu doing normal animation
		animation = true
		print("Change State to: NONE")
		return
	end
end

-- Fires when character starts/stops moving
humanoid.Running:Connect(Animation_State_Check)

-- Connect the event to the handler function
CharacterStateChange.Event:Connect(state_change)