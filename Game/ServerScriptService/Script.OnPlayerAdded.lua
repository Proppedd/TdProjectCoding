local Players = game:GetService('Players')
local PhysicsService = game:GetService('PhysicsService')

--This player function will set the default values for a user's starting game cash
--And the default value for amount of own towers placed.
Players.PlayerAdded:Connect(function(player)
	
	local cash = Instance.new('IntValue')
	cash.Name = 'Cash'
	cash.Value = 600
	cash.Parent = player

	local PlacedTowers = Instance.new('IntValue')
	PlacedTowers.Name = 'PlacedTowers'
	PlacedTowers.Value = 0
	PlacedTowers.Parent = player
	
	-- This function makes sure that the player does not collide with other players.
	player.CharacterAdded:Connect(function(character)
		for i, object in ipairs(character:GetDescendants()) do
			if object:IsA('BasePart') then
				PhysicsService:SetPartCollisionGroup(object, 'Player')
			end
		end
	end)
end)
