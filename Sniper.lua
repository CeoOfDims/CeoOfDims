-- FullBright + AntiLag + ESP + Persistent WalkSpeed (40) + Credit GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local createdESPs = {}
local desiredSpeed = 40

----------------------------------------------------
-- FULLBRIGHT
----------------------------------------------------
local function applyFullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

----------------------------------------------------
-- ANTI-LAG
----------------------------------------------------
local function applyAntiLag()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or
           obj:IsA("Trail") or
           obj:IsA("Smoke") or
           obj:IsA("Fire") or
           obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end

    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ShadowSoftness = 0

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

----------------------------------------------------
-- ESP
----------------------------------------------------
local function getCharacter()
	local char = localPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char
	end
	return nil
end

local function createESP(target)
	if createdESPs[target] then return end
	if not target:IsA("Model") then return end

	local root = target:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("Ga nemu HumanoidRootPart di:", target.Name)
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Name"
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 120, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = target

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "The Rake"
	label.TextColor3 = Color3.fromRGB(255, 100, 100)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Name = "RakeLabel"
	label.Parent = billboard

	createdESPs[target] = {
		root = root,
		label = label,
	}
end

----------------------------------------------------
-- WALKSPEED (Persistent Bypass)
----------------------------------------------------
local function monitorHumanoid(humanoid)
	if not humanoid then return end

	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if humanoid.WalkSpeed ~= desiredSpeed then
			humanoid.WalkSpeed = desiredSpeed
		end
	end)

	humanoid.WalkSpeed = desiredSpeed

	RunService.RenderStepped:Connect(function()
		if humanoid and humanoid.WalkSpeed ~= desiredSpeed then
			humanoid.WalkSpeed = desiredSpeed
		end
	end)
end

local function setupCharacter(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		char.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				monitorHumanoid(child)
			end
		end)
	else
		monitorHumanoid(hum)
	end
end

----------------------------------------------------
-- GUI: Credit Label
----------------------------------------------------
local function createCreditGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CeoOfDims_CreditGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel")
	label.Name = "CreditLabel"
	label.Size = UDim2.new(0, 200, 0, 25)
	label.Position = UDim2.new(1, -210, 1, -30) -- Pojok kanan bawah
	label.BackgroundTransparency = 0.5
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.Text = "Made by CeoOfDims"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = screenGui
end

----------------------------------------------------
-- INIT
----------------------------------------------------
applyFullBright()
applyAntiLag()
createCreditGUI()

-- Setup WalkSpeed
localPlayer.CharacterAdded:Connect(setupCharacter)
if localPlayer.Character then
	setupCharacter(localPlayer.Character)
end

-- Update terus FullBright dan ESP
RunService.RenderStepped:Connect(function()
	-- FullBright auto fix
	if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
	if Lighting.ClockTime ~= 12 then Lighting.ClockTime = 12 end
	if Lighting.FogEnd ~= 100000 then Lighting.FogEnd = 100000 end
	if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
	if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	end

	-- ESP Update
	local char = getCharacter()
	if not char then return end
	local playerPos = char.HumanoidRootPart.Position

	for target, data in pairs(createdESPs) do
		if target and data.root and data.label then
			local dist = (playerPos - data.root.Position).Magnitude
			data.label.Text = string.format("The Rake (%.1f studs)", dist)
		end
	end
end)

-- Loop cari NPC
task.spawn(function()
	while true do
		for _, model in pairs(Workspace:GetChildren()) do
			if model:IsA("Model") and model.Name == "RakoofNPC" then
				createESP(model)
			end
		end
		wait(2)
	end
end)
