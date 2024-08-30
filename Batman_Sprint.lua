


-- Player Sprint Script

local player = game.Players.LocalPlayer -- Represents actual Player (Kick/Ban or See ID)
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") -- Represents physical Player (Health, etc)

local input_service = game:GetService("UserInputService")

local sprinting = false
local walk_speed = 15
local sprint_speed = 30

-- print("Script Active")

local function toggle_spring(input, gameProcessedEvent)
	-- Triggers everytime input is given
	-- print("Ensuring Working")
	if input.KeyCode == Enum.KeyCode.LeftShift then -- If left-shift pressed
		if sprinting then
			humanoid.WalkSpeed = walk_speed
			-- print("Switching To Walk-Speed")
			sprinting = false
		else
			humanoid.WalkSpeed = sprint_speed
			sprinting = true
			-- print("Switching To Run-Speed")
		end
	end
end

local function sprint_end(input)
	-- print("Spring Ended")
	humanoid.WalkSpeed = walk_speed
	sprinting = false
end

input_service.InputBegan:Connect(toggle_spring)
-- input_service.InputEnded:Connect(sprint_end)
