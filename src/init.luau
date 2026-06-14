--[[

	Folding Doors Support for ModuluxV2 by TurkishLifts

			VERSION: v1.0.2  DATE:14/06/2026

]]--

--!nocheck

local module = {}

local State = {
	Status = "Closed"
}

function module.init(controller : {})
	local ConfigModule = script.Config
	local TweenService = game:GetService("TweenService")
	
	if not ConfigModule then warn("Config Module not found!"); return end
	
	local Config = require(ConfigModule)
	
	local JanitorModule = require(
		(script:FindFirstChild("Dependencies") and script:FindFirstChild("Dependencies"):FindFirstChild("Janitor")) 
			or game:GetService("ReplicatedStorage"):FindFirstChild("Janitor")
	)
	local Janitor = JanitorModule.new()
	
	--local Lift : Model = controller.Source
	local Car : Model = controller.Car
	local Platform : BasePart = controller.Platform
	local API: BindableEvent = controller.API
	
	local Folding_Doors : Model = Car:FindFirstChild("Folding_Doors")
	
	if not Folding_Doors then warn("Folding_Doors NOT found!"); return end
	
	local function CreateWeld(Hoster : BasePart, Part0 : BasePart, Part1 : BasePart)
		local weld = Instance.new("WeldConstraint",Hoster)
		weld.Part0 = Part0
		weld.Part1 = Part1
	end

	for _,Door : Model in ipairs(Folding_Doors:GetChildren()) do
		if not Door:IsA("Model") then continue end

		local Open : BasePart = Door:FindFirstChild("Open")
		local Closed : BasePart = Door:FindFirstChild("Closed")
		local DoorPart : BasePart = Door:FindFirstChild("Door")
		
		if not (DoorPart and Open and Closed) then continue end
		
		for _,p in ipairs(Door:GetChildren()) do
			if p:IsA("BasePart") then p.Anchored = true end
		end
		
		Open.CanCollide = false
		Closed.CanCollide = false
	end
	
	local Tweens : {Tween} = {}
	local TWEEN_FUNCTIONS = {
        CancelTweens = function()
            for _,Tween : Tween in ipairs(Tweens) do
                Tween:Cancel()
            end
            Tweens = {}
        end,
        PlayTweens = function()
            for _,Tween : Tween in ipairs(Tweens) do
                Tween:Play()
            end
        end,
        ClearTweens = function()
            Tweens = {}
        end,
    }
	
	local function OpenDoor()
		task.wait(Config.Opening.Delay)
		
		if State.Status ~= "Closed" and State.Status ~= "Open" then
			TWEEN_FUNCTIONS.CancelTweens()
		end

		State.Status = "Opening"
		for _,Door : Model in ipairs(Folding_Doors:GetChildren()) do
			if not Door:IsA("Model") then continue end
			
			local Open : BasePart = Door:FindFirstChild("Open")
			local Closed : BasePart = Door:FindFirstChild("Closed")
			local DoorPart : BasePart = Door:FindFirstChild("Door")
			
			DoorPart.Anchored = true
			
			if not (DoorPart and Open and Closed) then continue end
			
			local TI = TweenInfo.new(Config.Opening.Time, Config.Opening.EasingStyle, Config.Opening.EasingDirection)
			local TW = TweenService:Create(DoorPart,TI, { ["CFrame"] = Open.CFrame })

			table.insert(Tweens,TW)
		end
		
		TWEEN_FUNCTIONS.PlayTweens()
		
		task.wait(Config.Opening.Time)
		
		if State.Status == "Opening" then
			State.Status = "Open"
			TWEEN_FUNCTIONS.ClearTweens()
			
			for _,v in ipairs(Folding_Doors:GetChildren()) do
				for _,p in ipairs(v:GetDescendants()) do
					if p:IsA("WeldConstraint") then
                        if not p.Parent:IsA("BasePart") then continue end

                        p.Parent.Anchored = true
						p:Destroy()
					end
				end
			end

		end
	end
	
	local function CloseDoor()
		task.wait(Config.Closing.Delay)
		if State.Status ~= "Closed" and State.Status ~= "Open" then
			TWEEN_FUNCTIONS.CancelTweens()
		end
		State.Status = "Closing"
		for _,Door : Model in ipairs(Folding_Doors:GetChildren()) do
			local Open : BasePart = Door:FindFirstChild("Open")
			local Closed : BasePart = Door:FindFirstChild("Closed")
			local DoorPart : BasePart = Door:FindFirstChild("Door")
			
			if not (DoorPart and Open and Closed) then continue end
			
			DoorPart.Anchored = true
			local TI = TweenInfo.new(Config.Closing.Time, Config.Closing.EasingStyle, Config.Closing.EasingDirection)
			local TW = TweenService:Create(DoorPart,TI, { ["CFrame"] = Closed.CFrame })
			
			table.insert(Tweens,TW)
		end
		
		TWEEN_FUNCTIONS.PlayTweens()
		
		task.wait(Config.Closing.Time)
		
		if State.Status == "Closing" then
			State.Status = "Closed"
			for _,v in ipairs(Folding_Doors:GetChildren()) do
				if not v:IsA("Model") then continue end
				for _,p in ipairs(v:GetChildren()) do
					if not p:IsA("BasePart") then continue end
					CreateWeld(p,p,Platform)
					p.Anchored = false
				end
			end
			
		end
	end
	Janitor:Add(
		API.Event:Connect(function(protocol,params)
			if protocol == "on_door_open" then
				OpenDoor()
			elseif protocol == "on_door_close" then
				CloseDoor()
			end
		end)
	)
	
	Janitor:Add(
		script.Destroying:Connect(function()
			Janitor:Cleanup()
		end)
	)
	
end

return module
