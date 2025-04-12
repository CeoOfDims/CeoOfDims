-- FINAL SCRIPT: ESP WendigoAI + FullBright + No Fog + Far View + AntiLag + AntiReset WalkSpeed/Lighting + Watermark
-- By ChatGPT & CeoOfDims

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === SETTINGS ===
local WALKSPEED = 50 -- Ganti kecepatan yang lo mau
local FIELD_OF_VIEW = 90
local BRIGHTNESS = 5

-- === ANTI-RESET WALKSPEED ===
local function applyWalkSpeedLoop(char)
	local humanoid = char:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	task.spawn(function()
		while humanoid and humanoid.Parent do
			if humanoid.WalkSpeed ~= WALKSPEED then
				humanoid.WalkSpeed = WALKSPEED
			end
			task.wait(0.5)
		end
	end)
end

if LocalPlayer.Character then
	applyWalkSpeedLoop(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
	applyWalkSpeedLoop(char)
end)

-- === ANTI-RESET FULLBRIGHT + NO FOG LOOP ===
task.spawn(function()
	while true do
		pcall(function()
			Lighting.Brightness = BRIGHTNESS
			Lighting.ClockTime = 12
			Lighting.FogEnd = 1e10
			Lighting.FogStart = 0
			Lighting.FogColor = Color3.new(1, 1, 1)
			Lighting.GlobalShadows = false
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		end)
		task.wait(1)
	end
end)

-- === FAR VIEW ===
pcall(function()
	Camera.FieldOfView = FIELD_OF_VIEW
end)

-- === ANTILAG ===
pcall(function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
			v:Destroy()
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		elseif v:IsA("BasePart") then
			v.CastShadow = false
		end
	end

	if workspace:FindFirstChildOfClass("Terrain") then
		workspace:FindFirstChildOfClass("Terrain").Decoration = false
	end

	Lighting:ClearAllChildren()
end)

-- === ESP KHUSUS WENDIGOAI ===
local espTag

local function createESP()
	local model = workspace:FindFirstChild("AI") and workspace.AI:FindFirstChild("WendigoAI")
	if not model then return end

	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local tag = Drawing.new("Text")
	tag.Size = 14
	tag.Center = true
	tag.Outline = true
	tag.Color = Color3.fromRGB(255, 85, 0)
	tag.Text = "WendigoAI"
	tag.Visible = true

	espTag = {
		Model = model,
		Part = hrp,
		Tag = tag
	}
end

local function removeESP()
	if espTag and espTag.Tag then
		espTag.Tag:Remove()
	end
	espTag = nil
end

RunService.RenderStepped:Connect(function()
	if not espTag or not espTag.Model or not espTag.Model.Parent then
		removeESP()
		createESP()
	end

	if espTag and espTag.Part and espTag.Part:IsA("BasePart") then
		local screenPos, onScreen = Camera:WorldToViewportPoint(espTag.Part.Position)
		local distance = (Camera.CFrame.Position - espTag.Part.Position).Magnitude

		espTag.Tag.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
		espTag.Tag.Text = string.format("WendigoAI [%.0f]", distance)
		espTag.Tag.Visible = onScreen
	end
end)

-- === WATERMARK: "Made by CeoOfDims" KIRI BAWAH ===
local watermark = Drawing.new("Text")
watermark.Text = "Made by CeoOfDims"
watermark.Size = 14
watermark.Outline = true
watermark.Color = Color3.fromRGB(255, 255, 255)
watermark.Center = false
watermark.Visible = true

RunService.RenderStepped:Connect(function()
	watermark.Position = Vector2.new(10, Camera.ViewportSize.Y - 25)
end)
