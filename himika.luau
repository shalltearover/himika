local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local espEnabled = false
local noclipEnabled = false
local fogDisabled = false
local lightsDisabled = false
local texturesDisabled = false
local speed = 16

local originalFog = {
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd,
	FogColor = Lighting.FogColor,
	Atmosphere = {}
}

local originalLights = {}
local originalTextures = {}

local gui = Instance.new("ScreenGui")
gui.Name = "ProjectPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 390)
main.Position = UDim2.new(0, 20, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 70, 255)
stroke.Thickness = 1.5
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "PROJECT PANEL"
title.TextColor3 = Color3.fromRGB(190, 120, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -55)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = container

local function createButton(text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 38)
	button.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(235, 235, 235)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Text = text
	button.AutoButtonColor = false
	button.Parent = container

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = button

	button.MouseButton1Click:Connect(function()
		callback(button)
	end)

	return button
end

local function updateESP()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local character = target.Character
			if character then
				local highlight = character:FindFirstChild("PurpleESP")

				if espEnabled then
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "PurpleESP"
						highlight.FillColor = Color3.fromRGB(145, 60, 255)
						highlight.OutlineColor = Color3.fromRGB(220, 180, 255)
						highlight.FillTransparency = 0.45
						highlight.OutlineTransparency = 0
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.Parent = character
					end
				elseif highlight then
					highlight:Destroy()
				end
			end
		end
	end
end

local espButton = createButton("ESP: OFF", function(button)
	espEnabled = not espEnabled
	button.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
	updateESP()
end)

local noclipButton = createButton("NOCLIP: OFF", function(button)
	noclipEnabled = not noclipEnabled
	button.Text = "NOCLIP: " .. (noclipEnabled and "ON" or "OFF")
end)

local fogButton = createButton("FOG: ON", function(button)
	fogDisabled = not fogDisabled

	if fogDisabled then
		originalFog.FogStart = Lighting.FogStart
		originalFog.FogEnd = Lighting.FogEnd
		originalFog.FogColor = Lighting.FogColor

		Lighting.FogStart = 1000000
		Lighting.FogEnd = 1000000

		for _, object in ipairs(Lighting:GetChildren()) do
			if object:IsA("Atmosphere") then
				originalFog.Atmosphere[object] = {
					Density = object.Density,
					Haze = object.Haze,
					Glare = object.Glare
				}

				object.Density = 0
				object.Haze = 0
				object.Glare = 0
			end
		end
	else
		Lighting.FogStart = originalFog.FogStart
		Lighting.FogEnd = originalFog.FogEnd
		Lighting.FogColor = originalFog.FogColor

		for atmosphere, values in pairs(originalFog.Atmosphere) do
			if atmosphere.Parent then
				atmosphere.Density = values.Density
				atmosphere.Haze = values.Haze
				atmosphere.Glare = values.Glare
			end
		end
	end

	button.Text = "FOG: " .. (fogDisabled and "OFF" or "ON")
end)

local lightsButton = createButton("LIGHTS: ON", function(button)
	lightsDisabled = not lightsDisabled

	for _, object in ipairs(game:GetDescendants()) do
		if object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") then
			if lightsDisabled then
				if originalLights[object] == nil then
					originalLights[object] = object.Enabled
				end
				object.Enabled = false
			else
				if originalLights[object] ~= nil then
					object.Enabled = originalLights[object]
				end
			end
		end
	end

	button.Text = "LIGHTS: " .. (lightsDisabled and "OFF" or "ON")
end)

local texturesButton = createButton("TEXTURES: ON", function(button)
	texturesDisabled = not texturesDisabled

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Texture") or object:IsA("Decal") then
			if texturesDisabled then
				if originalTextures[object] == nil then
					originalTextures[object] = object.Transparency
				end
				object.Transparency = 1
			else
				if originalTextures[object] ~= nil then
					object.Transparency = originalTextures[object]
				end
			end
		elseif object:IsA("MeshPart") then
			if texturesDisabled then
				if originalTextures[object] == nil then
					originalTextures[object] = object.TextureID
				end
				object.TextureID = ""
			else
				if originalTextures[object] ~= nil then
					object.TextureID = originalTextures[object]
				end
			end
		end
	end

	button.Text = "TEXTURES: " .. (texturesDisabled and "OFF" or "ON")
end)

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 58)
speedFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = container

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 7)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: " .. speed
speedLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = speedFrame

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, -20, 0, 7)
bar.Position = UDim2.new(0, 10, 0, 39)
bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
bar.BorderSizePixel = 0
bar.Parent = speedFrame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = bar

local fill = Instance.new("Frame")
fill.Size = UDim2.new((speed - 1) / 24, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(150, 70, 255)
fill.BorderSizePixel = 0
fill.Parent = bar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 15, 0, 15)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new((speed - 1) / 24, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(210, 170, 255)
knob.BorderSizePixel = 0
knob.Parent = bar

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

local dragging = false

local function setSpeedFromX(x)
	local relative = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
	speed = math.clamp(math.floor(1 + relative * 24 + 0.5), 1, 25)

	local percent = (speed - 1) / 24

	fill.Size = UDim2.new(percent, 0, 1, 0)
	knob.Position = UDim2.new(percent, 0, 0.5, 0)
	speedLabel.Text = "SPEED: " .. speed

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		setSpeedFromX(input.Position.X)
	end
end)

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		setSpeedFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local hideButton = createButton("HIDE UI", function()
	gui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		gui.Enabled = not gui.Enabled
	end
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		local character = player.Character

		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end

	if espEnabled then
		updateESP()
	end
end)

Players.PlayerAdded:Connect(function(target)
	target.CharacterAdded:Connect(function()
		if espEnabled then
			task.wait(0.5)
			updateESP()
		end
	end)
end)

for _, target in ipairs(Players:GetPlayers()) do
	target.CharacterAdded:Connect(function()
		if espEnabled then
			task.wait(0.5)
			updateESP()
		end
	end)
end

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = speed
end)
