local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Existing = PlayerGui:FindFirstChild("KuromiHub")
if Existing then
	Existing:Destroy()
end

local Theme = {
	Background = Color3.fromRGB(12, 9, 17),
	Panel = Color3.fromRGB(20, 15, 29),
	Panel2 = Color3.fromRGB(29, 21, 42),
	Panel3 = Color3.fromRGB(38, 27, 55),
	Purple = Color3.fromRGB(172, 108, 255),
	PurpleDark = Color3.fromRGB(104, 62, 158),
	Pink = Color3.fromRGB(255, 133, 201),
	HotPink = Color3.fromRGB(255, 93, 180),
	White = Color3.fromRGB(249, 244, 255),
	Muted = Color3.fromRGB(173, 159, 190),
	Stroke = Color3.fromRGB(79, 56, 105),
	Off = Color3.fromRGB(62, 49, 76),
	Black = Color3.fromRGB(7, 5, 10)
}

local State = {
	antiFling = false,
	esp = false,
	walkSpeed = false,
	noclip = false,
	fling = false,
	shaders = false,
	lowGraphics = false,
	walkSpeedValue = 16,
	flingForce = 85,
	menuVisible = true
}

local Hotkeys = {
	antiFling = nil,
	esp = nil,
	walkSpeed = nil,
	noclip = nil,
	fling = nil,
	shaders = nil,
	lowGraphics = nil
}

local ToggleSetters = {}
local HotkeyButtons = {}
local WaitingForHotkey = nil
local EspObjects = {}
local SavedLocalCollision = {}
local SavedOtherCollision = {}
local SavedWalkSpeed = nil
local LastSafeCFrame = nil
local SavedGraphics = {}
local ShaderObjects = {}
local FlingAttachment = nil
local FlingAngular = nil

local function Create(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function Corner(parent, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 10)
	}, parent)
end

local function Stroke(parent, transparency, thickness, color)
	return Create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	}, parent)
end

local function Padding(parent, left, right, top, bottom)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0)
	}, parent)
end

local function Tween(object, duration, properties, style, direction)
	local tween = TweenService:Create(
		object,
		TweenInfo.new(
			duration,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	tween:Play()
	return tween
end

local ScreenGui = Create("ScreenGui", {
	Name = "KuromiHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 2147483647,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

local Intro = Create("CanvasGroup", {
	Name = "Intro",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 1000
}, ScreenGui)

local IntroGlow = Create("Frame", {
	Size = UDim2.fromOffset(280, 280),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Theme.Purple,
	BackgroundTransparency = 0.82,
	BorderSizePixel = 0,
	ZIndex = 1001
}, Intro)
Corner(IntroGlow, 140)

local IntroIcon = Create("TextLabel", {
	Size = UDim2.fromOffset(100, 100),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, -58),
	BackgroundTransparency = 1,
	Text = "☠︎",
	TextColor3 = Theme.Pink,
	TextSize = 72,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 1002
}, Intro)

local IntroTitle = Create("TextLabel", {
	Size = UDim2.fromOffset(420, 54),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 24),
	BackgroundTransparency = 1,
	Text = "kuromi hub!",
	TextColor3 = Theme.White,
	TextSize = 34,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 1002
}, Intro)

local IntroSubtitle = Create("TextLabel", {
	Size = UDim2.fromOffset(420, 30),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 66),
	BackgroundTransparency = 1,
	Text = "♡ mischievous mode enabled ♡",
	TextColor3 = Theme.Muted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
	ZIndex = 1002
}, Intro)

local Dim = Create("Frame", {
	Name = "Dim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0.72,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 1
}, ScreenGui)

local MainGroup = Create("CanvasGroup", {
	Name = "MainGroup",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	GroupTransparency = 1,
	ZIndex = 10
}, ScreenGui)

local Main = Create("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(760, 500),
	Position = UDim2.new(0.5, -380, 0.5, -230),
	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 10
}, MainGroup)
Corner(Main, 18)
Stroke(Main, 0.1, 1.2, Theme.PurpleDark)

local BackgroundImage = Create("ImageLabel", {
	Name = "BackgroundImage",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "",
	ImageTransparency = 0.68,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 10
}, Main)

local BackgroundShade = Create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	ZIndex = 11
}, Main)

local AccentTop = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 3),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 40
}, Main)

local TitleBar = Create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 30
}, Main)

local BrandIcon = Create("TextLabel", {
	Size = UDim2.fromOffset(52, 52),
	Position = UDim2.fromOffset(18, 16),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Text = "☠︎",
	TextColor3 = Theme.Pink,
	TextSize = 31,
	Font = Enum.Font.GothamBlack,
	ZIndex = 31
}, TitleBar)
Corner(BrandIcon, 14)
Stroke(BrandIcon, 0.15, 1, Theme.Pink)

local HubName = Create("TextLabel", {
	Size = UDim2.new(0, 250, 0, 30),
	Position = UDim2.fromOffset(84, 14),
	BackgroundTransparency = 1,
	Text = "kuromi hub!",
	TextColor3 = Theme.White,
	TextSize = 22,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 31
}, TitleBar)

local HubSubtitle = Create("TextLabel", {
	Size = UDim2.new(0, 270, 0, 20),
	Position = UDim2.fromOffset(85, 45),
	BackgroundTransparency = 1,
	Text = "black • purple • chaos",
	TextColor3 = Theme.Muted,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 31
}, TitleBar)

local Avatar = Create("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.new(1, -236, 0, 24),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 31
}, TitleBar)
Corner(Avatar, 18)
Stroke(Avatar, 0.25, 1, Theme.Purple)

local DisplayName = Create("TextLabel", {
	Size = UDim2.fromOffset(135, 19),
	Position = UDim2.new(1, -190, 0, 22),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.White,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 31
}, TitleBar)

local Username = Create("TextLabel", {
	Size = UDim2.fromOffset(135, 17),
	Position = UDim2.new(1, -190, 0, 42),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 31
}, TitleBar)

local Close = Create("TextButton", {
	Size = UDim2.fromOffset(34, 34),
	Position = UDim2.new(1, -48, 0, 25),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Text = "×",
	TextColor3 = Theme.White,
	TextSize = 19,
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	ZIndex = 31
}, TitleBar)
Corner(Close, 10)
Stroke(Close, 0.3)

local Sidebar = Create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 174, 1, -84),
	Position = UDim2.fromOffset(0, 84),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	ZIndex = 25
}, Main)
Padding(Sidebar, 12, 12, 16, 12)

local SidebarLayout = Create("UIListLayout", {
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
}, Sidebar)

local Content = Create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -174, 1, -84),
	Position = UDim2.fromOffset(174, 84),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 25
}, Main)

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
	local page = Create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Purple,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 25
	}, Content)
	Create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, page)
	Padding(page, 18, 18, 18, 18)
	Pages[name] = page
	return page
end

local function SelectPage(name)
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end
	for tabName, button in pairs(TabButtons) do
		local selected = tabName == name
		Tween(button, 0.18, {
			BackgroundColor3 = selected and Theme.PurpleDark or Theme.Panel2,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)
	end
end

local function CreateTab(name, icon, order)
	local button = Create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = icon .. "   " .. name,
		TextColor3 = Theme.Muted,
		TextSize = 12,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 26
	}, Sidebar)
	Corner(button, 10)
	Padding(button, 14, 8, 0, 0)
	button.MouseEnter:Connect(function()
		if not Pages[name].Visible then
			Tween(button, 0.14, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
		end
	end)
	button.MouseLeave:Connect(function()
		if not Pages[name].Visible then
			Tween(button, 0.14, {BackgroundColor3 = Theme.Panel2}, Enum.EasingStyle.Quad)
		end
	end)
	button.MouseButton1Click:Connect(function()
		SelectPage(name)
	end)
	TabButtons[name] = button
end

local MainPage = CreatePage("Main")
local VisualsPage = CreatePage("Visuals")
local GraphicsPage = CreatePage("Graphics")
local SettingsPage = CreatePage("Settings")

CreateTab("Main", "⌁", 1)
CreateTab("Visuals", "◉", 2)
CreateTab("Graphics", "✦", 3)
CreateTab("Settings", "⚙", 4)

local KeyHint = Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	LayoutOrder = 20,
	ZIndex = 26
}, Sidebar)

local function CreateSection(parent, title, subtitle, order)
	local holder = Create("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 54 or 34),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 26
	}, parent)

	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 17,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 27
	}, holder)

	if subtitle then
		Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 28),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 27
		}, holder)
	end

	return holder
end

local function FormatHotkey(keyCode)
	if not keyCode then
		return "KEY"
	end
	local name = keyCode.Name
	if name == "LeftShift" then return "LSHIFT" end
	if name == "RightShift" then return "RSHIFT" end
	if name == "LeftControl" then return "LCTRL" end
	if name == "RightControl" then return "RCTRL" end
	if name == "MouseButton1" then return "M1" end
	return string.upper(name)
end

local function CreateToggle(parent, config)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 68),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 26
	}, parent)
	Corner(row, 12)
	Stroke(row, 0.42)

	local iconBubble = Create("TextLabel", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.fromOffset(14, 17),
		BackgroundColor3 = Theme.Panel3,
		BorderSizePixel = 0,
		Text = config.icon or "♡",
		TextColor3 = Theme.Pink,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		ZIndex = 27
	}, row)
	Corner(iconBubble, 10)

	Create("TextLabel", {
		Size = UDim2.new(1, -220, 0, 20),
		Position = UDim2.fromOffset(58, 13),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = Theme.White,
		TextSize = 13,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 27
	}, row)

	if config.subtitle then
		Create("TextLabel", {
			Size = UDim2.new(1, -220, 0, 18),
			Position = UDim2.fromOffset(58, 35),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 27
		}, row)
	end

	local keyButton = Create("TextButton", {
		Size = UDim2.fromOffset(66, 30),
		Position = UDim2.new(1, -142, 0.5, -15),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = FormatHotkey(Hotkeys[config.id]),
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 28
	}, row)
	Corner(keyButton, 9)
	Stroke(keyButton, 0.45)

	local switch = Create("TextButton", {
		Size = UDim2.fromOffset(50, 28),
		Position = UDim2.new(1, -64, 0.5, -14),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 28
	}, row)
	Corner(switch, 14)

	local knob = Create("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 29
	}, switch)
	Corner(knob, 11)

	local function Apply(enabled)
		Tween(switch, 0.16, {
			BackgroundColor3 = enabled and Theme.Purple or Theme.Off
		}, Enum.EasingStyle.Quad)
		Tween(knob, 0.16, {
			Position = enabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Quad)
		Tween(iconBubble, 0.16, {
			BackgroundColor3 = enabled and Theme.PurpleDark or Theme.Panel3,
			TextColor3 = enabled and Theme.White or Theme.Pink
		}, Enum.EasingStyle.Quad)
	end

	local function Set(enabled)
		State[config.id] = enabled
		Apply(enabled)
		if config.changed then
			config.changed(enabled)
		end
	end

	ToggleSetters[config.id] = Set
	HotkeyButtons[config.id] = keyButton

	switch.MouseButton1Click:Connect(function()
		Set(not State[config.id])
	end)

	keyButton.MouseButton1Click:Connect(function()
		WaitingForHotkey = config.id
		keyButton.Text = "PRESS"
		keyButton.TextColor3 = Theme.Pink
	end)

	Apply(State[config.id])
	return row
end

local function CreateSlider(parent, row, y, minimum, maximum, initial, callback, suffix)
	local valueLabel = Create("TextLabel", {
		Size = UDim2.fromOffset(64, 22),
		Position = UDim2.new(1, -80, 0, y - 11),
		BackgroundTransparency = 1,
		Text = tostring(initial) .. (suffix or ""),
		TextColor3 = Theme.Pink,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 28
	}, row)

	local slider = Create("Frame", {
		Size = UDim2.new(1, -106, 0, 6),
		Position = UDim2.fromOffset(58, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 28
	}, row)
	Corner(slider, 3)

	local normalized = (initial - minimum) / (maximum - minimum)

	local fill = Create("Frame", {
		Size = UDim2.fromScale(normalized, 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 29
	}, slider)
	Corner(fill, 3)

	local knob = Create("Frame", {
		Size = UDim2.fromOffset(15, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(normalized, 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 30
	}, slider)
	Corner(knob, 8)
	Stroke(knob, 0.3, 1, Theme.Pink)

	local dragging = false

	local function Update(x)
		local alpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		local value = math.floor(minimum + (maximum - minimum) * alpha + 0.5)
		local displayAlpha = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(displayAlpha, 1)
		knob.Position = UDim2.new(displayAlpha, 0, 0.5, 0)
		valueLabel.Text = tostring(value) .. (suffix or "")
		callback(value)
	end

	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Update(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			Update(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return slider
end

local function RestoreLocalCollision()
	for part, value in pairs(SavedLocalCollision) do
		if part and part.Parent then
			part.CanCollide = value
		end
	end
	table.clear(SavedLocalCollision)
end

local function RestoreOtherCollision()
	for part, value in pairs(SavedOtherCollision) do
		if part and part.Parent then
			part.CanCollide = value
		end
	end
	table.clear(SavedOtherCollision)
end

local function RemoveFling()
	if FlingAngular then
		FlingAngular:Destroy()
		FlingAngular = nil
	end
	if FlingAttachment then
		FlingAttachment:Destroy()
		FlingAttachment = nil
	end
end

local function UpdateFling()
	RemoveFling()
	if not State.fling then
		return
	end

	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	FlingAttachment = Create("Attachment", {
		Name = "KuromiFlingAttachment"
	}, root)

	FlingAngular = Create("AngularVelocity", {
		Name = "KuromiFlingVelocity",
		Attachment0 = FlingAttachment,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		MaxTorque = math.huge,
		AngularVelocity = Vector3.new(0, State.flingForce, 0)
	}, root)
end

local function DestroyEsp(player)
	local data = EspObjects[player]
	if not data then
		return
	end
	if data.highlight then
		data.highlight:Destroy()
	end
	if data.billboard then
		data.billboard:Destroy()
	end
	EspObjects[player] = nil
end

local function EnsureEsp(player)
	if player == LocalPlayer then
		return
	end

	local character = player.Character
	if not character then
		DestroyEsp(player)
		return
	end

	local head = character:FindFirstChild("Head")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not head or not root then
		return
	end

	local current = EspObjects[player]
	if current and current.character ~= character then
		DestroyEsp(player)
		current = nil
	end

	if not current then
		local highlight = Create("Highlight", {
			Name = "KuromiESPHighlight",
			Adornee = character,
			FillColor = Theme.Purple,
			FillTransparency = 0.76,
			OutlineColor = Theme.Pink,
			OutlineTransparency = 0.05,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = Create("BillboardGui", {
			Name = "KuromiESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(200, 38),
			StudsOffset = Vector3.new(0, 2.7, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = Create("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Black,
			BackgroundTransparency = 0.18,
			BorderSizePixel = 0,
			Text = player.DisplayName,
			TextColor3 = Theme.White,
			TextSize = 11,
			Font = Enum.Font.GothamSemibold,
			ZIndex = 60
		}, billboard)
		Corner(label, 9)
		Stroke(label, 0.25, 1, Theme.Purple)

		current = {
			character = character,
			root = root,
			highlight = highlight,
			billboard = billboard,
			label = label
		}
		EspObjects[player] = current
	end

	current.root = root

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0
	if localRoot then
		distance = math.floor((localRoot.Position - root.Position).Magnitude + 0.5)
	end

	current.label.Text = player.DisplayName .. "  ♡  " .. tostring(distance) .. "m"
end

local function ClearEsp()
	for player in pairs(EspObjects) do
		DestroyEsp(player)
	end
end

local function EnableShaders()
	if next(ShaderObjects) then
		return
	end

	local color = Create("ColorCorrectionEffect", {
		Name = "KuromiColor",
		Brightness = 0.02,
		Contrast = 0.14,
		Saturation = 0.08,
		TintColor = Color3.fromRGB(235, 218, 255)
	}, Lighting)

	local bloom = Create("BloomEffect", {
		Name = "KuromiBloom",
		Intensity = 0.35,
		Size = 28,
		Threshold = 1.2
	}, Lighting)

	local sun = Create("SunRaysEffect", {
		Name = "KuromiSunRays",
		Intensity = 0.07,
		Spread = 0.82
	}, Lighting)

	local depth = Create("DepthOfFieldEffect", {
		Name = "KuromiDepth",
		FarIntensity = 0.08,
		FocusDistance = 70,
		InFocusRadius = 55,
		NearIntensity = 0
	}, Lighting)

	ShaderObjects = {
		color = color,
		bloom = bloom,
		sun = sun,
		depth = depth
	}
end

local function DisableShaders()
	for _, object in pairs(ShaderObjects) do
		if object then
			object:Destroy()
		end
	end
	table.clear(ShaderObjects)
end

local function EnableLowGraphics()
	if next(SavedGraphics) then
		return
	end

	SavedGraphics.GlobalShadows = Lighting.GlobalShadows
	SavedGraphics.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
	SavedGraphics.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	SavedGraphics.Technology = Lighting.Technology

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
			SavedGraphics[object] = object.Enabled
			object.Enabled = false
		elseif object:IsA("BasePart") then
			SavedGraphics[object] = object.Material
			if object.Material ~= Enum.Material.SmoothPlastic then
				object.Material = Enum.Material.SmoothPlastic
			end
		elseif object:IsA("Decal") or object:IsA("Texture") then
			SavedGraphics[object] = object.Transparency
			object.Transparency = math.max(object.Transparency, 0.35)
		end
	end

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") and effect.Name ~= "KuromiColor" and effect.Name ~= "KuromiBloom" and effect.Name ~= "KuromiSunRays" and effect.Name ~= "KuromiDepth" then
			SavedGraphics[effect] = effect.Enabled
			effect.Enabled = false
		end
	end
end

local function DisableLowGraphics()
	if SavedGraphics.GlobalShadows ~= nil then
		Lighting.GlobalShadows = SavedGraphics.GlobalShadows
	end
	if SavedGraphics.EnvironmentDiffuseScale ~= nil then
		Lighting.EnvironmentDiffuseScale = SavedGraphics.EnvironmentDiffuseScale
	end
	if SavedGraphics.EnvironmentSpecularScale ~= nil then
		Lighting.EnvironmentSpecularScale = SavedGraphics.EnvironmentSpecularScale
	end

	for object, value in pairs(SavedGraphics) do
		if typeof(object) == "Instance" and object.Parent then
			if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") or object:IsA("PostEffect") then
				object.Enabled = value
			elseif object:IsA("BasePart") then
				object.Material = value
			elseif object:IsA("Decal") or object:IsA("Texture") then
				object.Transparency = value
			end
		end
	end

	table.clear(SavedGraphics)
end

CreateSection(MainPage, "Player", "movement and character controls", 1)

CreateToggle(MainPage, {
	id = "antiFling",
	title = "Anti-Fling",
	subtitle = "velocity and collision protection",
	icon = "✦",
	order = 2
})

CreateToggle(MainPage, {
	id = "noclip",
	title = "Noclip",
	subtitle = "disable collision on your character",
	icon = "◇",
	order = 3,
	changed = function(enabled)
		if not enabled then
			RestoreLocalCollision()
		end
	end
})

local WalkRow = CreateToggle(MainPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "movement speed",
	icon = "➜",
	order = 4,
	height = 106,
	changed = function(enabled)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if enabled then
				if SavedWalkSpeed == nil then
					SavedWalkSpeed = humanoid.WalkSpeed
				end
				humanoid.WalkSpeed = State.walkSpeedValue
			else
				if SavedWalkSpeed ~= nil then
					humanoid.WalkSpeed = SavedWalkSpeed
				end
				SavedWalkSpeed = nil
			end
		end
	end
})

CreateSlider(WalkRow, WalkRow, 79, 1, 25, State.walkSpeedValue, function(value)
	State.walkSpeedValue = value
	if State.walkSpeed then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end
end)

local FlingRow = CreateToggle(MainPage, {
	id = "fling",
	title = "Self Fling",
	subtitle = "local spin force",
	icon = "↻",
	order = 5,
	height = 106,
	changed = function()
		UpdateFling()
	end
})

CreateSlider(FlingRow, FlingRow, 79, 10, 220, State.flingForce, function(value)
	State.flingForce = value
	if FlingAngular then
		FlingAngular.AngularVelocity = Vector3.new(0, value, 0)
	end
end)

local Rejoin = Create("TextButton", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "↻   rejoin current server",
	TextColor3 = Theme.White,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	LayoutOrder = 6,
	ZIndex = 26
}, MainPage)
Corner(Rejoin, 12)
Stroke(Rejoin, 0.4)

Rejoin.MouseEnter:Connect(function()
	Tween(Rejoin, 0.14, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
end)

Rejoin.MouseLeave:Connect(function()
	Tween(Rejoin, 0.14, {BackgroundColor3 = Theme.Panel}, Enum.EasingStyle.Quad)
end)

Rejoin.MouseButton1Click:Connect(function()
	Rejoin.Text = "↻   rejoining..."
	local success = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)
	if not success then
		Rejoin.Text = "×   rejoin failed"
		task.wait(1.2)
		Rejoin.Text = "↻   rejoin current server"
	end
end)

CreateSection(VisualsPage, "Visuals", "player visibility", 1)

CreateToggle(VisualsPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "highlight, name and distance",
	icon = "◉",
	order = 2
})

CreateSection(GraphicsPage, "Graphics", "visual quality and performance", 1)

CreateToggle(GraphicsPage, {
	id = "shaders",
	title = "Kuromi Shaders",
	subtitle = "bloom, color, sun rays and depth",
	icon = "✦",
	order = 2,
	changed = function(enabled)
		if enabled then
			EnableShaders()
		else
			DisableShaders()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "reduce particles, materials and effects",
	icon = "▣",
	order = 3,
	changed = function(enabled)
		if enabled then
			EnableLowGraphics()
		else
			DisableLowGraphics()
		end
	end
})

CreateSection(SettingsPage, "Settings", "customize the hub", 1)

local BackgroundCard = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 112),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 26
}, SettingsPage)
Corner(BackgroundCard, 12)
Stroke(BackgroundCard, 0.4)

Create("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 13),
	BackgroundTransparency = 1,
	Text = "Panel Background",
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, BackgroundCard)

Create("TextLabel", {
	Size = UDim2.new(1, -30, 0, 18),
	Position = UDim2.fromOffset(15, 36),
	BackgroundTransparency = 1,
	Text = "Roblox image asset ID or asset URL",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, BackgroundCard)

local BackgroundBox = Create("TextBox", {
	Size = UDim2.new(1, -30, 0, 38),
	Position = UDim2.fromOffset(15, 64),
	BackgroundColor3 = Theme.Panel2,
	BorderSizePixel = 0,
	PlaceholderText = "rbxassetid://123456789",
	PlaceholderColor3 = Theme.Muted,
	Text = "",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.Gotham,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, BackgroundCard)
Corner(BackgroundBox, 9)
Stroke(BackgroundBox, 0.5)
Padding(BackgroundBox, 11, 11, 0, 0)

local function ApplyBackground(value)
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
	ApplyBackground(BackgroundBox.Text)
end)

local HotkeyInfo = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 26
}, SettingsPage)
Corner(HotkeyInfo, 12)
Stroke(HotkeyInfo, 0.4)

Create("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 13),
	BackgroundTransparency = 1,
	Text = "Menu Hotkey",
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, HotkeyInfo)

Create("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 42),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 27
}, HotkeyInfo)

local function SetMenuVisible(visible)
	State.menuVisible = visible
	if visible then
		MainGroup.Visible = true
		Main.Position = UDim2.new(0.5, -380, 0.5, -216)
		MainGroup.GroupTransparency = 1
		Tween(MainGroup, 0.22, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
		Tween(Main, 0.28, {Position = UDim2.new(0.5, -380, 0.5, -250)}, Enum.EasingStyle.Back)
	else
		local tween = Tween(MainGroup, 0.18, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
		Tween(Main, 0.18, {Position = UDim2.new(0.5, -380, 0.5, -230)}, Enum.EasingStyle.Quad)
		tween.Completed:Once(function()
			if not State.menuVisible then
				MainGroup.Visible = false
			end
		end)
	end
end

Close.MouseButton1Click:Connect(function()
	SetMenuVisible(false)
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

TitleBar.InputBegan:Connect(function(input)
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

TitleBar.InputChanged:Connect(function(input)
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

	if WaitingForHotkey then
		if input.KeyCode == Enum.KeyCode.Escape then
			local button = HotkeyButtons[WaitingForHotkey]
			if button then
				button.Text = FormatHotkey(Hotkeys[WaitingForHotkey])
				button.TextColor3 = Theme.Muted
			end
			WaitingForHotkey = nil
			return
		end

		if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
			Hotkeys[WaitingForHotkey] = nil
		else
			Hotkeys[WaitingForHotkey] = input.KeyCode
		end

		local button = HotkeyButtons[WaitingForHotkey]
		if button then
			button.Text = FormatHotkey(Hotkeys[WaitingForHotkey])
			button.TextColor3 = Theme.Muted
		end

		WaitingForHotkey = nil
		return
	end

	local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	if ctrlDown and input.KeyCode == Enum.KeyCode.M then
		SetMenuVisible(not State.menuVisible)
		return
	end

	if gameProcessed then
		return
	end

	for id, keyCode in pairs(Hotkeys) do
		if keyCode and input.KeyCode == keyCode then
			local setter = ToggleSetters[id]
			if setter then
				setter(not State[id])
			end
			return
		end
	end
end)

RunService.Stepped:Connect(function()
	local character = LocalPlayer.Character

	if State.noclip and character then
		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if SavedLocalCollision[descendant] == nil then
					SavedLocalCollision[descendant] = descendant.CanCollide
				end
				descendant.CanCollide = false
			end
		end
	elseif next(SavedLocalCollision) then
		RestoreLocalCollision()
	end
end)

RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if State.walkSpeed and humanoid then
		humanoid.WalkSpeed = State.walkSpeedValue
	end

	if State.fling and FlingAngular then
		FlingAngular.AngularVelocity = Vector3.new(0, State.flingForce, 0)
	end

	if State.antiFling and root then
		local linear = root.AssemblyLinearVelocity.Magnitude
		local angular = root.AssemblyAngularVelocity.Magnitude

		if linear < 90 and angular < 45 then
			LastSafeCFrame = root.CFrame
		end

		if linear > 150 or angular > 75 then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			if LastSafeCFrame then
				root.CFrame = LastSafeCFrame
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, descendant in ipairs(player.Character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if SavedOtherCollision[descendant] == nil then
							SavedOtherCollision[descendant] = descendant.CanCollide
						end
						descendant.CanCollide = false
					end
				end
			end
		end
	elseif next(SavedOtherCollision) then
		RestoreOtherCollision()
	end

	if State.esp then
		for _, player in ipairs(Players:GetPlayers()) do
			EnsureEsp(player)
		end
	elseif next(EspObjects) then
		ClearEsp()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	DestroyEsp(player)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	LastSafeCFrame = nil
	SavedWalkSpeed = nil
	RestoreLocalCollision()
	RemoveFling()

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = State.walkSpeedValue
		end

		if State.fling then
			task.wait(0.5)
			UpdateFling()
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

SelectPage("Main")

task.spawn(function()
	MainGroup.Visible = false
	IntroIcon.Size = UDim2.fromOffset(72, 72)
	IntroGlow.Size = UDim2.fromOffset(80, 80)

	Tween(IntroGlow, 0.6, {
		Size = UDim2.fromOffset(280, 280),
		BackgroundTransparency = 0.82
	}, Enum.EasingStyle.Back)

	Tween(IntroIcon, 0.4, {
		TextTransparency = 0,
		Size = UDim2.fromOffset(100, 100)
	}, Enum.EasingStyle.Back)

	task.wait(0.2)

	Tween(IntroTitle, 0.45, {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.5, 18)
	}, Enum.EasingStyle.Quint)

	task.wait(0.12)

	Tween(IntroSubtitle, 0.4, {
		TextTransparency = 0
	}, Enum.EasingStyle.Quad)

	task.wait(0.8)

	local fade = Tween(Intro, 0.45, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Quad)

	fade.Completed:Wait()
	Intro.Visible = false

	MainGroup.Visible = true
	Main.Position = UDim2.new(0.5, -380, 0.5, -210)
	Tween(MainGroup, 0.32, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Quad)
	Tween(Main, 0.42, {
		Position = UDim2.new(0.5, -380, 0.5, -250)
	}, Enum.EasingStyle.Back)
end)

