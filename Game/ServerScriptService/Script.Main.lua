local ServerStorage = game:GetService('ServerStorage')

local mob = require(script.Bob)
local tower = require(script.Tower)
local map = workspace.Crossroads

local info = workspace.Info
local GameOver = false
--Above are all the listed variables used in this script.

map.Health.Humanoid.HealthChanged:Connect(function()
	if map.Health.Humanoid.Health <= 0 then
		GameOver = true
	end
end)

--Below is a 'for loop' for the game starting countdown.
for i=20, 0, -1 do
	info.Wave.Value = 'Game starting in...' .. i
	task.wait(1)
end

--Below is a 'for loop', which is used to create all the different wave formats.
for wave=1, 20 do
	info.Wave.Value = wave
	
	if wave <= 2 then
		mob.Spawn('Zondy', 5 + wave, map)
		
	elseif wave <= 3 then
		for i=1, 5 do
		mob.Spawn('KevinTran', 8, map)
		end
	elseif wave <=4 then
		for i=1, 5 do
		mob.Spawn('Zondy', 8 + wave, map)
		mob.Spawn('KevinTran', 10 + wave, map)
		mob.Spawn('Transformer', 8 + wave, map)
		end
	elseif wave <= 10 then
		for i=1, 5 do
		mob.Spawn('Zondy', 12, map)
		mob.Spawn('KevinTran', 10, map)
		mob.Spawn('Transformer', 8, map)
		mob.Spawn('LuongTeddyBear', wave, map)
		end
	elseif wave <= 11 then
		for i=1, 5 do
		mob.Spawn('Zondy', 18, map)
		mob.Spawn('Transformer', 20, map)
		mob.Spawn('KevinTran', 21, map)
		mob.Spawn('LuongTeddyBear', wave, map)
		end
	elseif	wave <=16 then
		for i=1, 5 do
		mob.Spawn('LuongTeddyBear', wave, map)
		mob.Spawn('Zondy', 50, map)
		mob.Spawn('KevinTran', 35, map)
		end
	elseif wave <= 20 then
		for i=1, 5 do
		mob.Spawn('LuongTeddyBear', 20, map)
		end
	end
	
--This 'repeat-loop' function will wait until there are no more mobs left in the game.
repeat
	
	task.wait(1)
	until #workspace.Mobs:GetChildren() == 0 or GameOver
	
--The if statement for GameOver will show a DEFEATED sign when
--the player's base has been destroyed and will end the game.
if GameOver then
	info.Wave.Value = 'DEFEATED'
	break
end
	
--This 'for function' gives the countdown for the next wave to start.
	for i=5, 0, -1 do
		info.Wave.Value = 'Next wave starting in...' .. i
		task.wait(1)
	end
end

if info.Wave.Value == 20 then
	info.Wave.Value = 'VICTORY'
end
--Above is the end statement for when the final wave is defeated
--and prints 'VICTORY' once the player has won.



--440, 55
--200, 50