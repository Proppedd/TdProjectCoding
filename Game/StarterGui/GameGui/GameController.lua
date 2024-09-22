local Players = game:GetService('Players')
local PhysicsService = game:GetService('PhysicsService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local modules = ReplicatedStorage:WaitForChild('Modules')
local health = require(modules:WaitForChild('Health'))

local Cash = Players.LocalPlayer:WaitForChild('Cash')
local events = ReplicatedStorage:WaitForChild('Events')
local functions = ReplicatedStorage:WaitForChild('Functions')
local requestTowerFunction = functions:WaitForChild('RequestTower')
local towers = ReplicatedStorage:WaitForChild('Towers')
local spawnTowerEvent = events:WaitForChild('SpawnTower')
local camera = workspace.CurrentCamera
local gui = script.Parent
local map = workspace:WaitForChild('Crossroads')
local base = map:WaitForChild('Health')
local info = workspace:WaitForChild('Info')

local towerToSpawn = nil
local canPlace = false
local TowerRotation = 0
local MaxTowers = 25
local PlacedTowers = 0
--Above is all the listed variables used for this script(yes I know its a lot but its that I need for the game to run properly lol)

--This local function sets up the screen interface to display the gameplay information on screen.
local function SetupGui()
	health.Setup(base, gui.GameInfo.Health)

	workspace.Mobs.ChildAdded:Connect(function(mob)
		health.Setup(mob)
	end)

	info.Wave.Changed:Connect(function(change)
		gui.GameInfo.Wave.Text = 'Wave:' .. change
	end)

	Cash.Changed:Connect(function(change)
		gui.GameInfo.Stats.Cash.Text = '$' .. Cash.Value
	end)
	gui.GameInfo.Stats.Cash.Text = '$' .. Cash.Value
end

SetupGui()

--This function will snap the tower placement system to follow with the cursor
--So then the tower placeholder will follow where the cursor is located in the screenGui.
-- || Refer to 'Python Graphics' Booklet: 13. User Controls(Page 3): Task 4-Mouse Clicks
local function MouseRaycast(blacklist)
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()
	
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = blacklist
	
	local rayCastResult =  workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
	
	return rayCastResult
end
--This local function will remove the tower that was placed on the client side,
--So that the user can click on the buttonGui again and spawn another tower.
local function RemovePlaceholderTower()
	if towerToSpawn then
		towerToSpawn:Destroy()
		towerToSpawn  = nil
		TowerRotation = 0
	end
end
-- This local function is used to spawn the tower on the client side when the user
-- CLicks on the buttonGui.
local function AddPlaceholderTower(name)
	local towerExists = towers:FindFirstChild(name)
	if towerExists then
		RemovePlaceholderTower()
		towerToSpawn = towerExists:Clone()
		towerToSpawn.Parent = workspace.Towers
		
		for i, object in ipairs(towerToSpawn:GetDescendants()) do
			if object:IsA('BasePart') then
				PhysicsService:SetPartCollisionGroup(object, 'Tower')
				object.Material = Enum.Material.ForceField
			end
		end
	end
end
-- This local function is used to set the collisions for the 'Soldier' tower.
local function ColorplaceholderTower(color)
	if towerToSpawn then
		for i, object in ipairs(towerToSpawn:GetDescendants()) do
			if object:IsA('BasePart') then
				PhysicsService:SetPartCollisionGroup(object, 'Tower')
				object.Color = color
			end
		end
	end
end


--This is the button generator script, where the coding for the button to select a tower and place it is implemented
for i, tower in pairs(towers:GetChildren()) do
	local button = gui.Towers.Template:Clone()
	local Config = tower:WaitForChild('Config')
	button.Name = tower.Name
	button.Image = Config.Image.Texture
	button.Visible = true
	button.Price.Text = '$' .. Config.Price.Value	
	
	button.Parent = gui.Towers
	
	button.Activated:Connect(function()
		local allowedToSpawn = requestTowerFunction:InvokeServer(tower.Name)
		if allowedToSpawn then
			AddPlaceholderTower(tower.Name)
		end
	end)
end
-- This function removes the tower that was placed
-- So that a new tower can be placed
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	
	if towerToSpawn then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if canPlace then
				spawnTowerEvent:FireServer(towerToSpawn.Name, towerToSpawn.PrimaryPart.CFrame)
				PlacedTowers += 1
				gui.Towers.Title.Text = 'Soldiers: ' .. PlacedTowers .. '/' .. MaxTowers
				RemovePlaceholderTower()
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			TowerRotation += 90
			towerToSpawn:SetPrimaryPartCFrame(towerToSpawn.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(TowerRotation), 0))
		end
	end
	

end)

-- This function sets the position of the tower to be placed based on the mouse's position
RunService.RenderStepped:Connect(function()
	if towerToSpawn then
		local result = MouseRaycast({towerToSpawn})
		if result and result.Instance then
			if result.Instance.Parent.Name == 'TowerArea' then
				canPlace = true
				ColorplaceholderTower(Color3.new(0,1,0))
			else
				canPlace = false
				ColorplaceholderTower(Color3.new(1,0,0))

			end
			local x = result.Position.X
			local y = result.Position.Y + 2.5
			local z = result.Position.Z

			local cframe = CFrame.new(x,y,z) * CFrame.Angles(0, math.rad(TowerRotation), 0)
			towerToSpawn:SetPrimaryPartCFrame(cframe)
		end
	end
end)