local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("MinimalControlPanel")
if oldGui then
	oldGui:Destroy()
end

local theme = {
	bg = Color3.fromRGB(17, 18, 22),
	panel = Color3.fromRGB(23, 24, 29),
	panel2 = Color3.fromRGB(29, 30, 36),
	hover = Color3.fromRGB(36, 37, 44),
	text = Color3.fromRGB(238, 239, 244),
	subtext = Color3.fromRGB(145, 148, 160),
	accent = Color3.fromRGB(132, 102, 255),
	accent2 = Color3.fromRGB(105, 81, 211),
	stroke = Color3.fromRGB(52, 54, 64),
	off = Color3.fromRGB(67, 69, 78)
}

local state = {
	antiFling = false,
	esp = false,
	walkSpeed = false,
	walkSpeedValue = 16,
	menuVisible = true
}

local hotkeys = {
	antiFling = nil,
	esp = nil,
	walkSpeed = nil
}

local waitingForHotkey = nil
local hotkeyButtons = {}
local toggleSetters = {}
local savedWalkSpeed = nil
local savedCollision = {}
local lastSafeCFrame = nil
local espObjects = {}

local function new(className, props, parent)
	local instance = Instance.new(className)
	for key, value in pairs(props or {}) do
		instance[key] = value
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local function corner(parent, radius)
	return new("UICorner", {
		CornerRadius = UDim.new(0, radius or 10)
	}, parent)
end

local function stroke(parent, transparency)
	return new("UIStroke", {
		Color = theme.stroke,
		Thickness = 1,
		Transparency = transparency or 0
	}, parent)
end

local function padding(parent, left, right, top, bottom)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0)
	}, parent)
end

local ScreenGui = new("ScreenGui", {
	Name = "MinimalControlPanel",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999999,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

local Dim = new("Frame", {
	Name = "Dim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.78,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 1
}, ScreenGui)

local Main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(680, 430),
	Position = UDim2.new(0.5, -340, 0.5, -215),
	BackgroundColor3 = theme.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 10
}, ScreenGui)
corner(Main, 14)
stroke(Main, 0.15)

local BackgroundImage = new("ImageLabel", {
	Name = "BackgroundImage",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "",
	ImageTransparency = 0.7,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 10
}, Main)

local BackgroundShade = new("Frame", {
	Name = "BackgroundShade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = theme.bg,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	ZIndex = 11
}, Main)

local TopBar = new("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = theme.panel,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 20,
	Active = true
}, Main)

local Avatar = new("ImageLabel", {
	Name = "Avatar",
	Size = UDim2.fromOffset(38, 38),
	Position = UDim2.fromOffset(16, 13),
	BackgroundColor3 = theme.panel2,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 21
}, TopBar)
corner(Avatar, 19)

local DisplayName = new("TextLabel", {
	Name = "DisplayName",
	Size = UDim2.new(0, 260, 0, 22),
	Position = UDim2.fromOffset(66, 12),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = theme.text,
	TextSize = 15,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 21
}, TopBar)

local UserName = new("TextLabel", {
	Name = "UserName",
	Size = UDim2.new(0, 260, 0, 18),
	Position = UDim2.fromOffset(66, 33),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = theme.subtext,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 21
}, TopBar)

local MenuHint = new("TextLabel", {
	Name = "MenuHint",
	Size = UDim2.fromOffset(150, 28),
	Position = UDim2.new(1, -198, 0, 18),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = theme.subtext,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Right,
	ZIndex = 21
}, TopBar)

local CloseButton = new("TextButton", {
	Name = "Close",
	Size = UDim2.fromOffset(32, 32),
	Position = UDim2.new(1, -46, 0, 16),
	BackgroundColor3 = theme.panel2,
	BorderSizePixel = 0,
	Text = "×",
	TextColor3 = theme.text,
	TextSize = 20,
	Font = Enum.Font.GothamMedium,
	AutoButtonColor = false,
	ZIndex = 21
}, TopBar)
corner(CloseButton, 8)
stroke(CloseButton, 0.35)

local Sidebar = new("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 154, 1, -64),
	Position = UDim2.fromOffset(0, 64),
	BackgroundColor3 = theme.panel,
	BackgroundTransparency = 0.18,
	BorderSizePixel = 0,
	ZIndex = 20
}, Main)

local SidebarLayout = new("UIListLayout", {
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
}, Sidebar)
padding(Sidebar, 10, 10, 16, 10)

local Content = new("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -154, 1, -64),
	Position = UDim2.fromOffset(154, 64),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 20
}, Main)

local pages = {}
local tabButtons = {}

local function createPage(name)
	local page = new("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.accent,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 20
	}, Content)
	local layout = new("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, page)
	padding(page, 18, 18, 18, 18)
	pages[name] = page
	return page
end

local function selectPage(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
	for tabName, button in pairs(tabButtons) do
		button.BackgroundColor3 = tabName == name and theme.accent2 or theme.panel2
		button.TextColor3 = tabName == name and theme.text or theme.subtext
	end
end

local function createTab(name, order)
	local button = new("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = theme.subtext,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 21
	}, Sidebar)
	corner(button, 9)
	button.MouseEnter:Connect(function()
		if not pages[name].Visible then
			button.BackgroundColor3 = theme.hover
		end
	end)
	button.MouseLeave:Connect(function()
		if not pages[name].Visible then
			button.BackgroundColor3 = theme.panel2
		end
	end)
	button.MouseButton1Click:Connect(function()
		selectPage(name)
	end)
	tabButtons[name] = button
	return button
end

local MainPage = createPage("Main")
local VisualsPage = createPage("Visuals")
local SettingsPage = createPage("Settings")

createTab("Main", 1)
createTab("Visuals", 2)
createTab("Settings", 3)

local function createSectionTitle(parent, title, subtitle, order)
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 54 or 34),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 21
	}, parent)

	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.text,
		TextSize = 17,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 22
	}, holder)

	if subtitle then
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 27),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = theme.subtext,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 22
		}, holder)
	end

	return holder
end

local function formatHotkey(keyCode)
	if not keyCode then
		return "KEY"
	end
	local name = keyCode.Name
	if name == "LeftShift" then return "LSHIFT" end
	if name == "RightShift" then return "RSHIFT" end
	if name == "LeftControl" then return "LCTRL" end
	if name == "RightControl" then return "RCTRL" end
	return string.upper(name)
end

local function createToggle(parent, config)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 66),
		BackgroundColor3 = theme.panel,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 21
	}, parent)
	corner(row, 10)
	stroke(row, 0.45)

	new("TextLabel", {
		Size = UDim2.new(1, -180, 0, 22),
		Position = UDim2.fromOffset(16, 12),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = theme.text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 22
	}, row)

	if config.subtitle then
		new("TextLabel", {
			Size = UDim2.new(1, -180, 0, 18),
			Position = UDim2.fromOffset(16, 35),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = theme.subtext,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 22
		}, row)
	end

	local keyButton = new("TextButton", {
		Size = UDim2.fromOffset(74, 30),
		Position = UDim2.new(1, -152, 0.5, -15),
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Text = formatHotkey(hotkeys[config.id]),
		TextColor3 = theme.subtext,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		AutoButtonColor = false,
		ZIndex = 23
	}, row)
	corner(keyButton, 8)
	stroke(keyButton, 0.45)
	hotkeyButtons[config.id] = keyButton

	local track = new("TextButton", {
		Size = UDim2.fromOffset(48, 26),
		Position = UDim2.new(1, -64, 0.5, -13),
		BackgroundColor3 = theme.off,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 23
	}, row)
	corner(track, 13)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = theme.text,
		BorderSizePixel = 0,
		ZIndex = 24
	}, track)
	corner(knob, 10)

	local function applyVisual(enabled)
		track.BackgroundColor3 = enabled and theme.accent or theme.off
		knob:TweenPosition(
			enabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.14,
			true
		)
	end

	local function setState(enabled)
		state[config.id] = enabled
		applyVisual(enabled)
		if config.changed then
			config.changed(enabled)
		end
	end

	toggleSetters[config.id] = setState

	track.MouseButton1Click:Connect(function()
		setState(not state[config.id])
	end)

	keyButton.MouseButton1Click:Connect(function()
		waitingForHotkey = config.id
		keyButton.Text = "PRESS..."
		keyButton.TextColor3 = theme.accent
	end)

	applyVisual(state[config.id])
	return row
end

createSectionTitle(MainPage, "Controls", "Movement and protection", 1)

createToggle(MainPage, {
	id = "antiFling",
	title = "Anti-Fling",
	subtitle = "Local collision and velocity protection",
	order = 2
})

local WalkRow = createToggle(MainPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "1 - 25",
	order = 3,
	height = 104,
	changed = function(enabled)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if enabled then
				if not savedWalkSpeed then
					savedWalkSpeed = humanoid.WalkSpeed
				end
				humanoid.WalkSpeed = state.walkSpeedValue
			else
				if savedWalkSpeed then
					humanoid.WalkSpeed = savedWalkSpeed
				end
				savedWalkSpeed = nil
			end
		end
	end
})

local SpeedValue = new("TextLabel", {
	Size = UDim2.fromOffset(44, 22),
	Position = UDim2.new(1, -60, 0, 66),
	BackgroundTransparency = 1,
	Text = tostring(state.walkSpeedValue),
	TextColor3 = theme.text,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	ZIndex = 23
}, WalkRow)

local Slider = new("Frame", {
	Size = UDim2.new(1, -92, 0, 6),
	Position = UDim2.fromOffset(16, 74),
	BackgroundColor3 = theme.off,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 23
}, WalkRow)
corner(Slider, 3)

local SliderFill = new("Frame", {
	Size = UDim2.fromScale((state.walkSpeedValue - 1) / 24, 1),
	BackgroundColor3 = theme.accent,
	BorderSizePixel = 0,
	ZIndex = 24
}, Slider)
corner(SliderFill, 3)

local SliderKnob = new("Frame", {
	Size = UDim2.fromOffset(14, 14),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new((state.walkSpeedValue - 1) / 24, 0, 0.5, 0),
	BackgroundColor3 = theme.text,
	BorderSizePixel = 0,
	ZIndex = 25
}, Slider)
corner(SliderKnob, 7)

local draggingSlider = false

local function updateSpeedFromX(x)
	local alpha = math.clamp((x - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
	local value = math.clamp(math.floor(1 + alpha * 24 + 0.5), 1, 25)
	state.walkSpeedValue = value
	local normalized = (value - 1) / 24
	SliderFill.Size = UDim2.fromScale(normalized, 1)
	SliderKnob.Position = UDim2.new(normalized, 0, 0.5, 0)
	SpeedValue.Text = tostring(value)

	if state.walkSpeed then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end
end

Slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = true
		updateSpeedFromX(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateSpeedFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = false
	end
end)

local RejoinButton = new("TextButton", {
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundColor3 = theme.panel,
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	Text = "Rejoin current server",
	TextColor3 = theme.text,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	LayoutOrder = 4,
	ZIndex = 21
}, MainPage)
corner(RejoinButton, 10)
stroke(RejoinButton, 0.45)

RejoinButton.MouseEnter:Connect(function()
	RejoinButton.BackgroundColor3 = theme.hover
end)

RejoinButton.MouseLeave:Connect(function()
	RejoinButton.BackgroundColor3 = theme.panel
end)

RejoinButton.MouseButton1Click:Connect(function()
	RejoinButton.Text = "Rejoining..."
	task.spawn(function()
		local ok = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end)
		if not ok then
			RejoinButton.Text = "Rejoin failed"
			task.wait(1.5)
			RejoinButton.Text = "Rejoin current server"
		end
	end)
end)

createSectionTitle(VisualsPage, "Visuals", "Player visibility", 1)

createToggle(VisualsPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "Highlight, display name and distance",
	order = 2
})

createSectionTitle(SettingsPage, "Panel", "Interface preferences", 1)

local BackgroundCard = new("Frame", {
	Size = UDim2.new(1, 0, 0, 102),
	BackgroundColor3 = theme.panel,
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 21
}, SettingsPage)
corner(BackgroundCard, 10)
stroke(BackgroundCard, 0.45)

new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 22),
	Position = UDim2.fromOffset(16, 12),
	BackgroundTransparency = 1,
	Text = "Panel Background",
	TextColor3 = theme.text,
	TextSize = 14,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22
}, BackgroundCard)

new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 18),
	Position = UDim2.fromOffset(16, 34),
	BackgroundTransparency = 1,
	Text = "Roblox asset ID or Roblox asset URL",
	TextColor3 = theme.subtext,
	TextSize = 11,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22
}, BackgroundCard)

local BackgroundBox = new("TextBox", {
	Size = UDim2.new(1, -32, 0, 34),
	Position = UDim2.fromOffset(16, 59),
	BackgroundColor3 = theme.panel2,
	BorderSizePixel = 0,
	PlaceholderText = "rbxassetid://123456789",
	PlaceholderColor3 = theme.subtext,
	Text = "",
	TextColor3 = theme.text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22
}, BackgroundCard)
corner(BackgroundBox, 8)
stroke(BackgroundBox, 0.5)
padding(BackgroundBox, 10, 10, 0, 0)

local function applyBackground(value)
	value = string.gsub(value or "", "%s+", "")
	if value == "" then
		BackgroundImage.Image = ""
		return
	end

	if string.match(value, "^rbxassetid://%d+$") then
		BackgroundImage.Image = value
		return
	end

	if string.match(value, "^%d+$") then
		BackgroundImage.Image = "rbxassetid://" .. value
		return
	end

	local id = string.match(value, "(%d+)")
	if id then
		BackgroundImage.Image = "rbxassetid://" .. id
	end
end

BackgroundBox.FocusLost:Connect(function()
	applyBackground(BackgroundBox.Text)
end)

local HotkeyCard = new("Frame", {
	Size = UDim2.new(1, 0, 0, 78),
	BackgroundColor3 = theme.panel,
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 21
}, SettingsPage)
corner(HotkeyCard, 10)
stroke(HotkeyCard, 0.45)

new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 22),
	Position = UDim2.fromOffset(16, 12),
	BackgroundTransparency = 1,
	Text = "Menu Hotkey",
	TextColor3 = theme.text,
	TextSize = 14,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22
}, HotkeyCard)

new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 22),
	Position = UDim2.fromOffset(16, 39),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = theme.accent,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22
}, HotkeyCard)

local function destroyEsp(player)
	local data = espObjects[player]
	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end
	if data.billboard then
		data.billboard:Destroy()
	end
	espObjects[player] = nil
end

local function ensureEsp(player)
	if player == LocalPlayer then
		return
	end

	local character = player.Character
	if not character then
		destroyEsp(player)
		return
	end

	local head = character:FindFirstChild("Head")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not head or not humanoidRootPart then
		return
	end

	local current = espObjects[player]
	if current and current.character ~= character then
		destroyEsp(player)
		current = nil
	end

	if not current then
		local highlight = new("Highlight", {
			Name = "PlayerESPHighlight",
			Adornee = character,
			FillColor = theme.accent,
			FillTransparency = 0.72,
			OutlineColor = Color3.fromRGB(255, 255, 255),
			OutlineTransparency = 0.18,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = new("BillboardGui", {
			Name = "PlayerESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(190, 38),
			StudsOffset = Vector3.new(0, 2.7, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = new("TextLabel", {
			Name = "Label",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(11, 12, 15),
			BackgroundTransparency = 0.22,
			BorderSizePixel = 0,
			Text = player.DisplayName,
			TextColor3 = theme.text,
			TextStrokeTransparency = 0.75,
			TextSize = 12,
			Font = Enum.Font.GothamSemibold,
			ZIndex = 50
		}, billboard)
		corner(label, 8)
		stroke(label, 0.35)

		current = {
			character = character,
			root = humanoidRootPart,
			highlight = highlight,
			billboard = billboard,
			label = label
		}
		espObjects[player] = current
	end

	current.root = humanoidRootPart

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0
	if localRoot then
		distance = math.floor((localRoot.Position - humanoidRootPart.Position).Magnitude + 0.5)
	end

	current.label.Text = player.DisplayName .. "  •  " .. tostring(distance) .. "m"
end

local function clearEsp()
	for player in pairs(espObjects) do
		destroyEsp(player)
	end
end

local function restoreCollisions()
	for part, oldValue in pairs(savedCollision) do
		if part and part.Parent then
			part.CanCollide = oldValue
		end
	end
	table.clear(savedCollision)
end

local function setMenuVisible(visible)
	state.menuVisible = visible
	Main.Visible = visible
	Dim.Visible = false
end

CloseButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if waitingForHotkey then
		if input.KeyCode == Enum.KeyCode.Escape then
			local button = hotkeyButtons[waitingForHotkey]
			if button then
				button.Text = formatHotkey(hotkeys[waitingForHotkey])
				button.TextColor3 = theme.subtext
			end
			waitingForHotkey = nil
			return
		end

		if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
			hotkeys[waitingForHotkey] = nil
		else
			hotkeys[waitingForHotkey] = input.KeyCode
		end

		local button = hotkeyButtons[waitingForHotkey]
		if button then
			button.Text = formatHotkey(hotkeys[waitingForHotkey])
			button.TextColor3 = theme.subtext
		end

		waitingForHotkey = nil
		return
	end

	local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	if ctrlDown and input.KeyCode == Enum.KeyCode.M then
		setMenuVisible(not state.menuVisible)
		return
	end

	if gameProcessed then
		return
	end

	for id, keyCode in pairs(hotkeys) do
		if keyCode and input.KeyCode == keyCode then
			local setter = toggleSetters[id]
			if setter then
				setter(not state[id])
			end
			return
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if state.walkSpeed and humanoid then
		humanoid.WalkSpeed = state.walkSpeedValue
	end

	if state.antiFling and root then
		local linear = root.AssemblyLinearVelocity.Magnitude
		local angular = root.AssemblyAngularVelocity.Magnitude

		if linear < 90 and angular < 45 then
			lastSafeCFrame = root.CFrame
		end

		if linear > 150 or angular > 75 then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			if lastSafeCFrame then
				root.CFrame = lastSafeCFrame
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, descendant in ipairs(player.Character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if savedCollision[descendant] == nil then
							savedCollision[descendant] = descendant.CanCollide
						end
						descendant.CanCollide = false
					end
				end
			end
		end
	elseif next(savedCollision) then
		restoreCollisions()
	end

	if state.esp then
		for _, player in ipairs(Players:GetPlayers()) do
			ensureEsp(player)
		end
	else
		if next(espObjects) then
			clearEsp()
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	destroyEsp(player)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	lastSafeCFrame = nil
	savedWalkSpeed = nil
	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and state.walkSpeed then
			savedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = state.walkSpeedValue
		end
	end)
end)

task.spawn(function()
	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)
	if ok then
		Avatar.Image = content
	end
end)

selectPage("Main")

