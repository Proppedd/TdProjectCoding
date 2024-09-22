local Players = game:GetService('Players')

local Health = {}

-- All the below coding || Refer to 'Python Graphics' Booklet: 15. Boundaries: EntireChapter
function Health.Setup(model, screenGui)
	local newHealthBar = script.HealthGui:Clone()
	newHealthBar.Adornee = model:WaitForChild('Head')
	newHealthBar.Parent = Players.LocalPlayer.PlayerGui:WaitForChild('Billboards')
	
	if model.Name == 'Health' then
		newHealthBar.MaxDistance = 100
		newHealthBar.Size = UDim2.new(0, 466, 0, 29)
	else
		newHealthBar.MaxDistance = 30
		newHealthBar.Size = UDim2.new(0, 150, 0, 10)
	end
	
	Health.UpdateHealth(newHealthBar, model)
	if screenGui then
		Health.UpdateHealth(screenGui, model)
	end
	
	model.Humanoid.HealthChanged:Connect(function()
		Health.UpdateHealth(newHealthBar, model)	
		
		if screenGui then
			Health.UpdateHealth(screenGui, model)
		end
	end)

end

function Health.UpdateHealth(gui, model)
	local humanoid = model:WaitForChild('Humanoid')
	
	if humanoid and gui then
		local percent = humanoid.Health / humanoid.MaxHealth
		gui.Size = UDim2.new(math.max(percent, 0), 0, 1, 0)
	
		if humanoid.Health <= 0 then
			if model.Name == 'Health' then
				gui.Health.Text = '00000000000000'
				
			else
				gui.Health.Text = model.Name .. ' DEAD'
				task.wait(0.1)
				gui:Destroy()
			end
			
		else
		gui.Health.Text = model.Name .. ': ' .. humanoid.Health .. '/' .. humanoid.MaxHealth
		end
	end
end

return Health
