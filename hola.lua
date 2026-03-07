local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roundEvent = ReplicatedStorage:WaitForChild("RoundEvent")

local gui = script.Parent

local contador = gui:WaitForChild("Contador")
local killer = gui:WaitForChild("KillerContador")
local survivor = gui:WaitForChild("SurvivorLeft")

roundEvent.OnClientEvent:Connect(function(event,data)

	if event == "Waiting" then
		
		contador.Text = "Waiting Players..."
		killer.Text = "Killers: 0"
		survivor.Text = "0/12"
		
	end
	
	
	if event == "Countdown" then
		
		contador.Text = "Starting in "..data.time
		
	end
	
	
	if event == "RoundStart" then
		
		contador.Text = "03:00"
		killer.Text = "Killers: "..data.killersTotal
		survivor.Text = data.survivorsTotal.."/12"
		
	end
	
	
	if event == "Tick" then
		
		local time = data.time
		
		local minutes = math.floor(time/60)
		local seconds = time % 60
		
		if seconds < 10 then
			seconds = "0"..seconds
		end
		
		contador.Text = minutes..":"..seconds
		
		killer.Text = "Killers: "..data.killersAlive
		survivor.Text = data.survivorsAlive.."/12"
		
	end
	
	
	if event == "RoundEnd" then
		
		contador.Text = "Round End"
		
	end
	
end)
