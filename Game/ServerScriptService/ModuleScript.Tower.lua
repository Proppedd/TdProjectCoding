local ServerStorage = game:GetService('ServerStorage')
local PhysicsService = game:GetService('PhysicsService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Player = game:GetService('Players')

local events = ReplicatedStorage:WaitForChild('Events')
local spawnTowerEvent = events:WaitForChild('SpawnTower')
local functions = ReplicatedStorage:WaitForChild('Functions')
local requestTowerFunction = functions:WaitForChild('RequestTower')

local maxTowers = 25
local tower = {}

--The FindNearestTarget(newTower, Range) function sets the targetting for the towers placed
--To attack the enemy closest to the individual tower.
function FindNearestTarget(newTower, Range)
	local nearestTarget = nil

	for i, target in ipairs(workspace.Mobs:GetChildren()) do
		local distance = (target.HumanoidRootPart.Position - newTower.HumanoidRootPart.Position).Magnitude

		if distance < Range then
			print(target.Name, 'is the nearest target found')
			nearestTarget = target
			Range = distance
		end
	end

	return nearestTarget
end

function tower.Attack(newTower, player)
	local Config = newTower.Config
	local target = FindNearestTarget(newTower, Config.Range.Value)
	
	if target and target:FindFirstChild('Humanoid') and target.Humanoid.Health > 0 then
		
		local targetCFrame = CFrame.lookAt(newTower.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
		newTower.HumanoidRootPart.CFrame = targetCFrame
		
		target.Humanoid:TakeDamage(Config.Damage.Value)
		
		if target.Humanoid.Health <= 0 then
			player.Cash.Value += target.Humanoid.MaxHealth
		end
		
		task.wait(Config.Firerate.Value)
	end

	task.wait(0.1)
	
	tower.Attack(newTower, player)
end

function tower.Spawn(player, name, cframe)
	local allowedToSpawn = tower.CheckSpawn(player, name)
	
	if allowedToSpawn then
		
		local newTower = ReplicatedStorage.Towers[name]:Clone()
		newTower.HumanoidRootPart.CFrame = cframe
		newTower.Parent = workspace.Towers
		newTower.HumanoidRootPart:SetNetworkOwner(nil)
		
		local CFrame = Instance.new("CFrameValue")
		CFrame = Vector3.new(math.huge, math.huge, math.huge)
		CFrame = newTower.HumanoidRootPart.CFrame

		for i, object in ipairs(newTower:GetDescendants()) do
			if object:IsA('BasePart') then
				PhysicsService:SetPartCollisionGroup(object, 'Tower')
			end
		end
		
		player.Cash.Value -= newTower.Config.Price.Value
		player.PlacedTowers.Value += 1
		
		coroutine(tower.Attack(newTower, player))
	else
		warn("Requested tower does not exist:", name)
	end
end

spawnTowerEvent.OnServerEvent:Connect(tower.Spawn)

function tower.CheckSpawn(player, name)
	local towerExists = ReplicatedStorage.Towers:FindFirstChild(name)

	if towerExists then
		if towerExists.Config.Price.Value <= player.Cash.Value then
			if player.PlacedTowers.Value < maxTowers then
				return true
			else
				warn('Cannot place any more towers')
			end
		else
			warn('Not enough cash')
		end
	end
	
	return false
end
requestTowerFunction.OnServerInvoke = tower.CheckSpawn

return tower
