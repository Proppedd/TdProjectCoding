local ServerStorage = game:GetService('ServerStorage')
local PhysicsService = game:GetService('PhysicsService')

local mob = {}

--This function variable will make the enemies walk along the map track.
--Refer to 'Python Graphics' Booklet: 19. Maze: Task 2-Creating The Maze, Task 2-Creatin The Maze(Cont.)
function mob.Move(mob, map)
	local humanoid = mob:WaitForChild('Humanoid')
	local waypoints = map.Waypoints
	
	for waypoint=1, #waypoints:GetChildren() do
		humanoid:MoveTo(waypoints[waypoint].Position)
		humanoid.MoveToFinished:Wait()
	end
	
	mob:Destroy()
	
	map.Health.Humanoid:TakeDamage(humanoid.Health)
	
end


function mob.Spawn(name, quantity, map)
	local mobExists = ServerStorage.Mobs:FindFirstChild(name)
	
	if mobExists then
		for i=1, quantity do
			task.wait(0.5)		
			local newMob = mobExists:Clone()
			newMob.HumanoidRootPart.CFrame = map.Start.CFrame
			newMob.Parent = workspace.Mobs
			newMob.HumanoidRootPart:SetNetworkOwner(nil)
			
			for i, object in ipairs(newMob:GetDescendants()) do
				if object:IsA('BasePart') then
					PhysicsService:SetPartCollisionGroup(object, 'Mob')
				end
			end
			
			newMob.Humanoid.Died:Connect(function()
				task.wait(0.2)
				newMob:Destroy()
			end)
			
			coroutine.wrap(mob.Move)(newMob, map)
		end
	else
		warn("Requested mob does not exist:", name)
	end
end

return mob
