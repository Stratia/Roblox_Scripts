
-- Try to get the module script
local success, item_logic = pcall(function()
	return require(game.ServerScriptService:WaitForChild("Batman_Add_items"))
end)

if not success then
	warn("Failed to get the 'Batman_Add_items' module: " .. tostring(item_logic))
	return
end


-- Reference to the part
local part = script.Parent
local player_touching = false
local debounce = false -- Debounce flag to prevent multiple triggers

-- Function to handle when a player touches the part
local function onPartTouched(hit)
	-- Get the character and player from the hit object
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	-- Check if it's a valid player and if they aren't already touching the part
	if player and not player_touching and not debounce then
		player_touching = true  -- Set the flag to indicate the player is touching the part
		debounce = true  -- Set debounce to prevent multiple triggers
		print("Player Touched the Part")
		change_character_model(player)
		
	end
end

-- Function to handle when a player stops touching the part
local function onPartTouchEnded(hit)
	-- Get the character and player from the hit object
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	-- Check if it's a valid player and they were touching the part
	if player and player_touching then
		player_touching = false  -- Reset the flag to allow triggering again
		debounce = false  -- Reset debounce to allow re-triggering
		print("Player Stepped Off the Part")
	end
end

-- Connect the functions to the part's events
part.Touched:Connect(onPartTouched)
part.TouchEnded:Connect(onPartTouchEnded)

function change_character_model(player)
	local modelParent = game.Workspace -- The location where the model is stored
	local model = modelParent:FindFirstChild("Batman")

	if model then -- If the Batman model exists
		-- Clone the Batman model
		local characterClone = model:Clone()

		-- Remove the existing character model if it exists
		if player.Character then
			player.Character:Destroy()
		end

		-- Set the player's Character to the new model
		player.Character = characterClone

		-- Parent the new character model to the Workspace
		characterClone.Parent = game.Workspace

		-- Set the position of the new character model to the previous character's position
		local oldCharacterHumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
		if oldCharacterHumanoidRootPart then
			characterClone:SetPrimaryPartCFrame(oldCharacterHumanoidRootPart.CFrame)
		end

		-- Call additional logic for the new character model
		get_random_teleportation_point(characterClone)
		item_logic.add_items_batman(player) -- Ensure `player` is passed instead of `characterClone` if the function requires player
	else
		warn("Batman model not found in Workspace!")
	end
end


function get_random_teleportation_point(character)
	-- Randomly selects parts from Tele_points
	local Teleporation_Points = workspace.Tele_Points:GetChildren()
	local chosenNumber = math.random(1, #Teleporation_Points)
	
	print("Table: ", Teleporation_Points)
	print("Number:", chosenNumber)
	
	local part_instance = Teleporation_Points[chosenNumber]
	local part_pos = part_instance.Position

	teleport_to_location(character, part_pos)
	
end

function teleport_to_location(character, position)
	print("TELEPORTED")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		humanoidRootPart.CFrame = CFrame.new(position)
	end
end
