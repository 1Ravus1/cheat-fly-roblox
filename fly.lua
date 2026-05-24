local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local flying = false
local flySpeed = 10
local speedMod = 15 -- Multiplicateur ultra puissant (vitesse TGV au niveau 10)

-- UI Principale AMOLED + RGB
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "DeltaFlyNoclipRGBBoosted"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 170, 0, 120)
main.Position = UDim2.new(0.2, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 2
main.Active = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -25, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.Text = " FLY + NOCLIP BOOSTÉ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 12
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left

local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0, 25, 0, 25)
mini.Position = UDim2.new(1, -25, 0, 0)
mini.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mini.Text = "_"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)

local ico = Instance.new("TextButton", sg)
ico.Size = UDim2.new(0, 45, 0, 45)
ico.Position = UDim2.new(0.2, 0, 0.3, 0)
ico.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ico.BorderSizePixel = 2
ico.Text = "FLY"
ico.Font = Enum.Font.SourceSansBold
ico.Visible = false

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 35)
toggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggle.Text = "STATUT : OFF"
toggle.TextColor3 = Color3.fromRGB(255, 50, 50)
toggle.Font = Enum.Font.SourceSansBold

local label = Instance.new("TextLabel", main)
label.Size = UDim2.new(1, -20, 0, 20)
label.Position = UDim2.new(0, 10, 0, 75)
label.BackgroundTransparency = 1
label.Text = "VITESSE : 10 (MAX)"
label.TextColor3 = Color3.fromRGB(255, 255, 255)

local btnM = Instance.new("TextButton", main)
btnM.Size = UDim2.new(0, 35, 0, 20)
btnM.Position = UDim2.new(0, 10, 0, 95)
btnM.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnM.Text = "-"
btnM.TextColor3 = Color3.fromRGB(255, 255, 255)

local btnP = Instance.new("TextButton", main)
btnP.Size = UDim2.new(0, 35, 0, 20)
btnP.Position = UDim2.new(1, -45, 0, 95)
btnP.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnP.Text = "+"
btnP.TextColor3 = Color3.fromRGB(255, 255, 255)

------------------------------------------------------------------------
-- LOGIQUE EFFET RGB (RAINBOW COULEUR COUTOUR)
------------------------------------------------------------------------
local hue = 0
RunService.RenderStepped:Connect(function()
	hue = hue + 0.005
	if hue > 1 then hue = 0 end
	local rgbColor = Color3.fromHSV(hue, 1, 1)
	
	main.BorderColor3 = rgbColor
	ico.BorderColor3 = rgbColor
	ico.TextColor3 = rgbColor
	mini.TextColor3 = rgbColor
	btnM.BackgroundColor3 = rgbColor
	btnP.BackgroundColor3 = rgbColor
end)

------------------------------------------------------------------------
-- LOGIQUE FLY LIBRE (CAMERA ACTION) + NOCLIP
------------------------------------------------------------------------
local bVel, bGyro
local flyConnection
local noclipConnection

local function startVol()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	
	hum.PlatformStand = true
	
	bGyro = Instance.new("BodyGyro", hrp)
	bGyro.P = 9e4
	bGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bGyro.cframe = hrp.CFrame
	
	bVel = Instance.new("BodyVelocity", hrp)
	bVel.velocity = Vector3.new(0, 0, 0)
	bVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
	
	-- Boucle de vol synchronisée sur la direction de ta caméra
	flyConnection = RunService.Heartbeat:Connect(function()
		if flying and hrp and bVel and bGyro then
			local cam = workspace.CurrentCamera
			if cam and hum.MoveDirection.Magnitude > 0 then
				bVel.velocity = cam.CFrame.LookVector * (flySpeed * speedMod)
				bGyro.cframe = cam.CFrame
			else
				bVel.velocity = Vector3.new(0, 0, 0) -- Stop net dans les airs
			end
		end
	end)

	-- Boucle Noclip pour passer à travers les blocs et murs
	noclipConnection = RunService.Stepped:Connect(function()
		if flying and char then
			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function stopVol()
	flying = false
	if flyConnection then flyConnection:Disconnect() end
	if noclipConnection then noclipConnection:Disconnect() end
	if bVel then bVel:Destroy() end
	if bGyro then bGyro:Destroy() end
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.PlatformStand = false
	end
end

-- Events des boutons
toggle.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		toggle.Text = "STATUT : ON"
		toggle.TextColor3 = Color3.fromRGB(0, 255, 100)
		startVol()
	else
		toggle.Text = "STATUT : OFF"
		toggle.TextColor3 = Color3.fromRGB(255, 50, 50)
		stopVol()
	end
end)

btnM.MouseButton1Click:Connect(function()
	if flySpeed > 1 then 
		flySpeed = flySpeed - 1 
		label.Text = "VITESSE : " .. flySpeed
	end
end)
btnP.MouseButton1Click:Connect(function()
	if flySpeed < 10 then 
		flySpeed = flySpeed + 1 
		local txt = "VITESSE : " .. flySpeed
		if flySpeed == 10 then txt = "VITESSE : 10 (MAX)" end
		label.Text = txt
	end
end)

-- Réduction du menu en icône flottante
mini.MouseButton1Click:Connect(function() main.Visible = false ico.Position = main.Position ico.Visible = true end)
ico.MouseButton1Click:Connect(function() ico.Visible = false main.Position = ico.Position main.Visible = true end)

-- Système Drag pour déplacer l'UI au doigt (Glisser-Déposer)
local function drag(f)
	local toggle, start, pStart
	f.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			toggle = true start = i.Position pStart = f.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then toggle = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and toggle then
			local d = i.Position - start
			TweenService:Create(f, TweenInfo.new(0.05), {Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)}):Play()
		end
	end)
end
drag(main) drag(ico)