

--[[
This script allows Batman to use his moveset, animation etc
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterStateChange = ReplicatedStorage:WaitForChild("CharacterStateChange")

CharacterState = ""
local Players = game.Players

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local currently_gliding = false

local gliding_velocity = 5
local glide_multiplier = 5

-- For Testing Purposes
humanoid.JumpPower = 0

local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local playerPosition = humanoidRootPart.Position
local spacebar_counter = 0

local UserInputService = game:GetService("UserInputService")


Glide_Animation = Instance.new("Animation")
Glide_Animation.AnimationId = "rbxassetid://81228590260049"
Glide_Track = humanoid:LoadAnimation(Glide_Animation)

Dive_Animation = Instance.new("Animation")
Dive_Animation.AnimationID = "rbxassetid:///89825363379658"
Dive_Track = humanoid:LoadAnimation(Dive_Animation)

local function check_floor_material()
	if humanoid.FloorMaterial == Enum.Material.Air then
		print("Player is in the AIR!")
		return "Air"
	else
		print("Player is on the GROUND!")
		return "Ground"
	end
end


local function OnPress(key)
	-- if Spacebar pressed within a period of 1s
	--[[
	- Gets Current Time 
	
	- If it is, then it will count the amount of times it was pressed within that time
	- If it was pressed more than 3 times, then it will trigger the Dash function
	]]
	local startTime = tick() -- Get the current time
	
	-- Check floor-material
	-- If on Ground Evade
	-- If on Air, Glide

	if key.KeyCode == Enum.KeyCode.Space then
		-- Lesser than <
		-- Greater than >

		local currentTime = tick() -- Get the current time
		local timeDifference = currentTime - startTime -- Calculate the time difference
		
		if timeDifference <= 1 then
			--print("Spacebar pressed within 1 second!")
			spacebar_counter += 1
			-- print("Spacebar Counter: ", spacebar_counter)
			
			if spacebar_counter >= 2 then
				-- print("Activating Dash")
				spacebar_counter = 0
				
				local ground_material =  check_floor_material()
				if ground_material == "Air" then
					print("GLIDING: IF")
					if CharacterState == "Gliding" then
						-- Already Gliding: Don't Trigger Gliding
						glide_stop()
						return
					else -- Not Gliding: Trigger Gliding
						glide()
					end

				elseif ground_material == "Ground" then
					print("Ground")
					
					task.spawn(function()
						Evade()
					end)
					task.spawn(function()
						Evade_Animation()
					end)
				
				end
			end
		else
			print("Spacebar not pressed within 1 second.")
			spacebar_counter = 0
		end
		
		wait(1)
		spacebar_counter = 0
	end
end

function Evade()
	-- Todo: Implement Server-Scripting
	--this will get the orientation that the player is looking at in the world space
	
	-- print('Evade Active!')
	-- Get the LocalPlayer
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Create a BodyVelocity to apply force
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * 50 -- Adjust the 50 to control the force magnitude
	bodyVelocity.MaxForce = Vector3.new(50000, 0, 50000) -- Limiting the force applied
	bodyVelocity.Parent = humanoidRootPart
	

	-- Apply the force for 0.3 seconds
	wait(0.3)

	-- Remove the BodyVelocity to stop the force
	bodyVelocity:Destroy()
end

function Evade_Animation()
	-- Todo: Implement Animation
	-- print('Evade Animation!')
	
	local Evade_Animation = Instance.new("Animation")
	Evade_Animation.AnimationId = "rbxassetid://106160889075471"
	local Evade_Track = humanoid:LoadAnimation(Evade_Animation)
	
	Evade_Track:Play()
end

function glide_stop()
	-- Todo: Fix index nil with Destroy()
	local glide_force = humanoidRootPart:FindFirstChild("GlideForce")
	glide_force:Destroy()
	Glide_Track:Stop()
	
	CharacterState = ""
	CharacterStateChange:Fire("Normal")

	print("Gliding Stopped")
end

function glide()
	if CharacterState == "Gliding" then -- Stop Gliding
		print("GLIDE FUNCTION: Inactive")
		-- Glide_Track:Stop()
		-- CharacterState= ""

		-- humanoidRootPart:FindFirstChild("GlideForce"):Destroy()
	else -- Start Gliding
		

		CharacterStateChange:Fire("Gliding")
		CharacterState = "Gliding"
		
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

		-- Check if glide_force already exists, otherwise create it
		local glide_force = humanoidRootPart:FindFirstChild("GlideForce")
		if not glide_force then
			-- If glide_force doesn't exist, create a new one
			glide_force = Instance.new("BodyVelocity")
			glide_force.Name = "GlideForce"
			glide_force.MaxForce = Vector3.new(100000, 100000, 100000) -- Apply force on all axes
			glide_force.Parent = humanoidRootPart
		end

		-- Set up the service to update glide direction
		glide_service_setup = game:GetService("RunService").Heartbeat:Connect(function()
			local air_drag_magnitude = 30
			-- Get camera direction
			
			local camera = workspace.CurrentCamera
			-- Todo: https://devforum.roblox.com/t/move-player-forward-according-to-the-direction-theyre-facing/1833620
			local Player_facing_direction = camera.CFrame.LookVector
			local glide_velocity = Player_facing_direction * glide_multiplier

			-- Update GlideForce velocity
			glide_force.Velocity = Vector3.new(glide_velocity.X, -3, glide_velocity.Z)
	

			-- Ensure that the character's orientation remains aligned with the ground (horizontal plane)
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(glide_velocity.X, 0, glide_velocity.Z))

			--print("GDV: ",glide_force.Velocity)
			
			local ground_material =  check_floor_material()
			if ground_material == "Ground" then
				-- Stop Gliding
				glide_service_setup:Disconnect()
				glide_stop()
			end
		end)


		Glide_Track.Looped = true -- Ensure it doesn't loop
		Glide_Track:Play()
	

		-- Wait for the animation to stop, then freeze it
		Glide_Track.Stopped:Connect(function()
			Glide_Track:AdjustSpeed(0) -- Freeze at the last frame
		end)

		local function air_drag()
			--[[
			Slowly Decreases Glide velocity to simulate air, minimum
			glide-velocity is 5 max is 100
			]]
			while CharacterState == "Gliding" do
				print("AIR DRAG: CHECK")
				wait(4)
				-- print("Air Drag: Active")
				if glide_force then
					-- Minimum: 5
					-- Max: 10
					if gliding_velocity > 5 then
						print("Decreasing Velocity")
						gliding_velocity -= 0.2

						print("Gliding Velocity: ", gliding_velocity)
					else
						print("Air Drag: Not Bigger Than 5")
					end
				else
					print("Air Drag: No Glideforce Found")
					-- glide_force.Velocity = Vector3.new(0, gliding_velocity, 0)
				end
			end
		end

		task.spawn(air_drag)

	end
end


local function dive()
	-- Checks if gliding
	--[[
	Based on how long player dives, the gliding multiplier goes up
	capping at 10
	]]
	if CharacterState == "Gliding" then
		print("DIVE FUNCTION: Active")
		CharacterStateChange:Fire("Diving")
		CharacterState = "Diving"
	end
	
	
end

local function dive_animation()
	Dive_Track:Play()
	Dive_Track.Looped = false
	Dive_Track.Stopped:Connect(function()
		Dive_Track:AdjustSpeed(0) -- Freeze at the last frame
	end)
end


local function detective_vision()
	
end  

UserInputService.InputBegan:Connect(OnPress)