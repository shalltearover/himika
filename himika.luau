local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Old = PlayerGui:FindFirstChild("KuromiHub")
if Old then
	Old:Destroy()
end

local Theme = {
	Base = Color3.fromRGB(10, 8, 14),
	BaseSoft = Color3.fromRGB(15, 11, 21),
	Panel = Color3.fromRGB(20, 15, 28),
	Panel2 = Color3.fromRGB(29, 21, 40),
	Panel3 = Color3.fromRGB(38, 27, 52),
	Purple = Color3.fromRGB(161, 102, 238),
	PurpleSoft = Color3.fromRGB(115, 75, 170),
	Pink = Color3.fromRGB(239, 118, 184),
	White = Color3.fromRGB(247, 243, 251),
	Muted = Color3.fromRGB(165, 151, 180),
	Stroke = Color3.fromRGB(74, 55, 95),
	Off = Color3.fromRGB(60, 49, 70),
	Danger = Color3.fromRGB(205, 91, 124)
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
local FlingAttachment = nil
local FlingAngular = nil
local ShaderObjects = {}
local LowGraphicsSaved = {
	lighting = {},
	objects = {}
}

local function New(className, properties, parent)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		object[key] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function Corner(parent, radius)
	return New("UICorner", {
		CornerRadius = UDim.new(0, radius or 10)
	}, parent)
end

local function Stroke(parent, transparency, thickness, color)
	return New("UIStroke", {
		Color = color or Theme.Stroke,
		Transparency = transparency or 0,
		Thickness = thickness or 1
	}, parent)
end

local function Padding(parent, left, right, top, bottom)
	return New("UIPadding", {
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
			style or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	tween:Play()
	return tween
end

local function FormatHotkey(binding)
	if not binding then
		return "SET"
	end

	if binding.kind == "KeyCode" then
		local name = binding.value.Name
		local aliases = {
			LeftControl = "LCTRL",
			RightControl = "RCTRL",
			LeftShift = "LSHIFT",
			RightShift = "RSHIFT",
			LeftAlt = "LALT",
			RightAlt = "RALT",
			Backquote = "`",
			Minus = "-",
			Equals = "=",
			LeftBracket = "[",
			RightBracket = "]",
			Semicolon = ";",
			Quote = "'",
			Comma = ",",
			Period = ".",
			Slash = "/",
			BackSlash = "\\"
		}
		return aliases[name] or string.upper(name)
	end

	if binding.kind == "InputType" then
		local aliases = {
			MouseButton1 = "MOUSE1",
			MouseButton2 = "MOUSE2",
			MouseButton3 = "MOUSE3"
		}
		return aliases[binding.value.Name] or string.upper(binding.value.Name)
	end

	return "SET"
end

local function BindingMatches(binding, input)
	if not binding then
		return false
	end

	if binding.kind == "KeyCode" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == binding.value
	end

	if binding.kind == "InputType" then
		return input.UserInputType == binding.value
	end

	return false
end

local ScreenGui = New("ScreenGui", {
	Name = "KuromiHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 2147483647,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

local Intro = New("CanvasGroup", {
	Name = "Intro",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Base,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 1000
}, ScreenGui)

local IntroScale = New("UIScale", {
	Scale = 0.94
}, Intro)

local IntroCenter = New("Frame", {
	Size = UDim2.fromOffset(520, 180),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 1001
}, Intro)

local IntroLineTop = New("Frame", {
	Size = UDim2.fromOffset(0, 1),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 18),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 1002
}, IntroCenter)

local IntroLineBottom = New("Frame", {
	Size = UDim2.fromOffset(0, 1),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 1, -18),
	BackgroundColor3 = Theme.Purple,
	BorderSizePixel = 0,
	ZIndex = 1002
}, IntroCenter)

local IntroTitle = New("TextLabel", {
	Size = UDim2.fromOffset(500, 58),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.48, 0),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 35,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 1002
}, IntroCenter)

local IntroSubtitle = New("TextLabel", {
	Size = UDim2.fromOffset(500, 28),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.73, 0),
	BackgroundTransparency = 1,
	Text = "PERSONAL CONTROL PANEL",
	TextColor3 = Theme.Muted,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
	ZIndex = 1002
}, IntroCenter)

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(780, 510),
	Position = UDim2.new(0.5, -390, 0.5, -255),
	BackgroundColor3 = Theme.BaseSoft,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 18)
Stroke(Main, 0.08, 1.2, Theme.PurpleSoft)

local MainScale = New("UIScale", {
	Scale = 0.94
}, Main)

local BackgroundImage = New("ImageLabel", {
	Name = "BackgroundImage",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "",
	ImageTransparency = 0.72,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 20
}, Main)

local BackgroundOverlay = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.BaseSoft,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local Accent = New("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 50
}, Main)

local TopBar = New("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 40
}, Main)

local BrandBlock = New("Frame", {
	Size = UDim2.fromOffset(8, 42),
	Position = UDim2.fromOffset(20, 20),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 41
}, TopBar)
Corner(BrandBlock, 4)

local HubName = New("TextLabel", {
	Size = UDim2.fromOffset(300, 30),
	Position = UDim2.fromOffset(42, 14),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 22,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 41
}, TopBar)

local HubSub = New("TextLabel", {
	Size = UDim2.fromOffset(300, 18),
	Position = UDim2.fromOffset(43, 44),
	BackgroundTransparency = 1,
	Text = "BLACK / PURPLE CONTROL INTERFACE",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 41
}, TopBar)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(38, 38),
	Position = UDim2.new(1, -206, 0, 22),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 41
}, TopBar)
Corner(Avatar, 10)
Stroke(Avatar, 0.2, 1, Theme.Purple)

local DisplayName = New("TextLabel", {
	Size = UDim2.fromOffset(150, 18),
	Position = UDim2.new(1, -158, 0, 20),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.White,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 41
}, TopBar)

local Username = New("TextLabel", {
	Size = UDim2.fromOffset(150, 18),
	Position = UDim2.new(1, -158, 0, 41),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 41
}, TopBar)

local Sidebar = New("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 182, 1, -82),
	Position = UDim2.fromOffset(0, 82),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	ZIndex = 35
}, Main)
Padding(Sidebar, 12, 12, 16, 12)

New("UIListLayout", {
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
}, Sidebar)

local Content = New("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -182, 1, -82),
	Position = UDim2.fromOffset(182, 82),
	BackgroundTransparency = 1,
	ZIndex = 35
}, Main)

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
	local page = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Purple,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 35
	}, Content)

	New("UIListLayout", {
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
		Tween(button, 0.16, {
			BackgroundColor3 = selected and Theme.Panel3 or Theme.Panel2,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)

		local marker = button:FindFirstChild("Marker")
		if marker then
			Tween(marker, 0.16, {
				BackgroundTransparency = selected and 0 or 1
			}, Enum.EasingStyle.Quad)
		end
	end
end

local function CreateTab(name, order)
	local button = New("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Theme.Muted,
		TextSize = 12,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 36
	}, Sidebar)
	Corner(button, 10)
	Padding(button, 18, 10, 0, 0)

	local marker = New("Frame", {
		Name = "Marker",
		Size = UDim2.fromOffset(3, 20),
		Position = UDim2.new(0, 7, 0.5, -10),
		BackgroundColor3 = Theme.Pink,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 37
	}, button)
	Corner(marker, 2)

	button.MouseEnter:Connect(function()
		if not Pages[name].Visible then
			Tween(button, 0.12, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
		end
	end)

	button.MouseLeave:Connect(function()
		if not Pages[name].Visible then
			Tween(button, 0.12, {BackgroundColor3 = Theme.Panel2}, Enum.EasingStyle.Quad)
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
local PanelPage = CreatePage("Panel")

CreateTab("Main", 1)
CreateTab("Visuals", 2)
CreateTab("Graphics", 3)
CreateTab("Panel", 4)

local ShortcutLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	LayoutOrder = 20,
	ZIndex = 36
}, Sidebar)

local function Section(parent, title, subtitle, order)
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 54 or 34),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 36
	}, parent)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 17,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 37
	}, holder)

	if subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 28),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 37
		}, holder)
	end
end

local function CreateToggle(parent, config)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 68),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.01,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 36
	}, parent)
	Corner(row, 12)
	Stroke(row, 0.42)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(3, 28),
		Position = UDim2.fromOffset(14, 20),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 37
	}, row)
	Corner(accent, 2)

	New("TextLabel", {
		Size = UDim2.new(1, -210, 0, 21),
		Position = UDim2.fromOffset(29, 13),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = Theme.White,
		TextSize = 13,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 37
	}, row)

	if config.subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, -210, 0, 18),
			Position = UDim2.fromOffset(29, 36),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 37
		}, row)
	end

	local keyButton = New("TextButton", {
		Size = UDim2.fromOffset(76, 30),
		Position = UDim2.new(1, -156, 0.5, -15),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = FormatHotkey(Hotkeys[config.id]),
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 38
	}, row)
	Corner(keyButton, 9)
	Stroke(keyButton, 0.45)

	local switch = New("TextButton", {
		Size = UDim2.fromOffset(50, 28),
		Position = UDim2.new(1, -64, 0.5, -14),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 38
	}, row)
	Corner(switch, 14)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 39
	}, switch)
	Corner(knob, 11)

	local function Apply(enabled)
		Tween(switch, 0.16, {
			BackgroundColor3 = enabled and Theme.Purple or Theme.Off
		}, Enum.EasingStyle.Quad)

		Tween(knob, 0.16, {
			Position = enabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Quad)

		Tween(accent, 0.16, {
			BackgroundColor3 = enabled and Theme.Pink or Theme.Purple,
			BackgroundTransparency = enabled and 0 or 0.45
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
		keyButton.Text = "PRESS KEY"
		keyButton.TextColor3 = Theme.Pink
	end)

	Apply(State[config.id])
	return row
end

local function CreateEditableSlider(row, y, minimum, maximum, initial, callback)
	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(62, 28),
		Position = UDim2.new(1, -78, 0, y - 14),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = tostring(initial),
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 39
	}, row)
	Corner(valueBox, 8)
	Stroke(valueBox, 0.45)

	local slider = New("Frame", {
		Size = UDim2.new(1, -132, 0, 6),
		Position = UDim2.fromOffset(29, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 38
	}, row)
	Corner(slider, 3)

	local normalized = (initial - minimum) / (maximum - minimum)

	local fill = New("Frame", {
		Size = UDim2.fromScale(normalized, 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 39
	}, slider)
	Corner(fill, 3)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(15, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(normalized, 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 40
	}, slider)
	Corner(knob, 8)
	Stroke(knob, 0.3, 1, Theme.Pink)

	local dragging = false
	local current = initial

	local function SetValue(value)
		value = math.clamp(math.floor(tonumber(value) or current), minimum, maximum)
		current = value

		local alpha = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueBox.Text = tostring(value)
		callback(value)
	end

	local function UpdateFromX(x)
		local alpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		local value = minimum + ((maximum - minimum) * alpha)
		SetValue(value)
	end

	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UpdateFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	valueBox.FocusLost:Connect(function()
		SetValue(valueBox.Text)
	end)

	return {
		Set = SetValue,
		Box = valueBox
	}
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

	FlingAttachment = New("Attachment", {
		Name = "KuromiFlingAttachment"
	}, root)

	FlingAngular = New("AngularVelocity", {
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

	local data = EspObjects[player]

	if data and data.character ~= character then
		DestroyEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "KuromiESPHighlight",
			Adornee = character,
			FillColor = Theme.Purple,
			FillTransparency = 0.76,
			OutlineColor = Theme.Pink,
			OutlineTransparency = 0.06,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = "KuromiESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(200, 36),
			StudsOffset = Vector3.new(0, 2.7, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = New("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Base,
			BackgroundTransparency = 0.18,
			BorderSizePixel = 0,
			TextColor3 = Theme.White,
			TextSize = 11,
			Font = Enum.Font.GothamSemibold,
			ZIndex = 60
		}, billboard)
		Corner(label, 8)
		Stroke(label, 0.25, 1, Theme.Purple)

		data = {
			character = character,
			root = root,
			highlight = highlight,
			billboard = billboard,
			label = label
		}

		EspObjects[player] = data
	end

	data.root = root

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot then
		distance = math.floor((localRoot.Position - root.Position).Magnitude + 0.5)
	end

	data.label.Text = player.DisplayName .. "  |  " .. tostring(distance) .. "m"
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

	ShaderObjects.Color = New("ColorCorrectionEffect", {
		Name = "KuromiColor",
		Brightness = 0.02,
		Contrast = 0.14,
		Saturation = 0.08,
		TintColor = Color3.fromRGB(235, 220, 255)
	}, Lighting)

	ShaderObjects.Bloom = New("BloomEffect", {
		Name = "KuromiBloom",
		Intensity = 0.3,
		Size = 28,
		Threshold = 1.15
	}, Lighting)

	ShaderObjects.Sun = New("SunRaysEffect", {
		Name = "KuromiSunRays",
		Intensity = 0.06,
		Spread = 0.82
	}, Lighting)

	ShaderObjects.Depth = New("DepthOfFieldEffect", {
		Name = "KuromiDepth",
		FarIntensity = 0.07,
		FocusDistance = 70,
		InFocusRadius = 60,
		NearIntensity = 0
	}, Lighting)
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
	if LowGraphicsSaved.lighting.GlobalShadows ~= nil then
		return
	end

	LowGraphicsSaved.lighting.GlobalShadows = Lighting.GlobalShadows
	LowGraphicsSaved.lighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
	LowGraphicsSaved.lighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("ParticleEmitter")
			or object:IsA("Trail")
			or object:IsA("Beam")
			or object:IsA("Smoke")
			or object:IsA("Fire")
			or object:IsA("Sparkles") then

			LowGraphicsSaved.objects[object] = {
				property = "Enabled",
				value = object.Enabled
			}
			object.Enabled = false

		elseif object:IsA("BasePart") then
			LowGraphicsSaved.objects[object] = {
				property = "Material",
				value = object.Material
			}
			object.Material = Enum.Material.SmoothPlastic

		elseif object:IsA("Decal") or object:IsA("Texture") then
			LowGraphicsSaved.objects[object] = {
				property = "Transparency",
				value = object.Transparency
			}
			object.Transparency = math.max(object.Transparency, 0.35)
		end
	end

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") and not string.find(effect.Name, "^Kuromi") then
			LowGraphicsSaved.objects[effect] = {
				property = "Enabled",
				value = effect.Enabled
			}
			effect.Enabled = false
		end
	end
end

local function DisableLowGraphics()
	if LowGraphicsSaved.lighting.GlobalShadows ~= nil then
		Lighting.GlobalShadows = LowGraphicsSaved.lighting.GlobalShadows
	end

	if LowGraphicsSaved.lighting.EnvironmentDiffuseScale ~= nil then
		Lighting.EnvironmentDiffuseScale = LowGraphicsSaved.lighting.EnvironmentDiffuseScale
	end

	if LowGraphicsSaved.lighting.EnvironmentSpecularScale ~= nil then
		Lighting.EnvironmentSpecularScale = LowGraphicsSaved.lighting.EnvironmentSpecularScale
	end

	for object, saved in pairs(LowGraphicsSaved.objects) do
		if object and object.Parent then
			object[saved.property] = saved.value
		end
	end

	LowGraphicsSaved = {
		lighting = {},
		objects = {}
	}
end

Section(MainPage, "Player", "Movement and local character controls", 1)

CreateToggle(MainPage, {
	id = "antiFling",
	title = "Anti-Fling",
	subtitle = "Velocity and collision protection",
	order = 2
})

CreateToggle(MainPage, {
	id = "noclip",
	title = "Noclip",
	subtitle = "Disable collision on your character",
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
	subtitle = "Editable movement speed",
	order = 4,
	height = 108,
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

CreateEditableSlider(WalkRow, 81, 1, 25, State.walkSpeedValue, function(value)
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
	subtitle = "Editable local spin force",
	order = 5,
	height = 108,
	changed = function()
		UpdateFling()
	end
})

CreateEditableSlider(FlingRow, 81, 10, 220, State.flingForce, function(value)
	State.flingForce = value

	if FlingAngular then
		FlingAngular.AngularVelocity = Vector3.new(0, value, 0)
	end
end)

local Rejoin = New("TextButton", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	Text = "REJOIN CURRENT SERVER",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
	LayoutOrder = 6,
	ZIndex = 36
}, MainPage)
Corner(Rejoin, 12)
Stroke(Rejoin, 0.4)

Rejoin.MouseEnter:Connect(function()
	Tween(Rejoin, 0.12, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
end)

Rejoin.MouseLeave:Connect(function()
	Tween(Rejoin, 0.12, {BackgroundColor3 = Theme.Panel}, Enum.EasingStyle.Quad)
end)

Rejoin.MouseButton1Click:Connect(function()
	Rejoin.Text = "REJOINING..."

	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)

	if not ok then
		Rejoin.Text = "REJOIN FAILED"
		task.wait(1.2)
		Rejoin.Text = "REJOIN CURRENT SERVER"
	end
end)

Section(VisualsPage, "Visuals", "Player visibility tools", 1)

CreateToggle(VisualsPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "Highlight, display name and distance",
	order = 2
})

Section(GraphicsPage, "Graphics", "Visual quality and performance", 1)

CreateToggle(GraphicsPage, {
	id = "shaders",
	title = "Visual Enhancement",
	subtitle = "Bloom, color correction and depth",
	order = 2,
	changed = function(enabled)
		if enabled then
			if State.lowGraphics and ToggleSetters.lowGraphics then
				ToggleSetters.lowGraphics(false)
			end
			EnableShaders()
		else
			DisableShaders()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "Reduce effects, particles and heavy materials",
	order = 3,
	changed = function(enabled)
		if enabled then
			if State.shaders and ToggleSetters.shaders then
				ToggleSetters.shaders(false)
			end
			EnableLowGraphics()
		else
			DisableLowGraphics()
		end
	end
})

Section(PanelPage, "Panel Settings", "Interface-only configuration", 1)

local BackgroundCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 114),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 36
}, PanelPage)
Corner(BackgroundCard, 12)
Stroke(BackgroundCard, 0.4)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 13),
	BackgroundTransparency = 1,
	Text = "Panel Background",
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 37
}, BackgroundCard)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 18),
	Position = UDim2.fromOffset(15, 36),
	BackgroundTransparency = 1,
	Text = "Roblox image asset ID or asset URL",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 37
}, BackgroundCard)

local BackgroundBox = New("TextBox", {
	Size = UDim2.new(1, -30, 0, 38),
	Position = UDim2.fromOffset(15, 65),
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
	ZIndex = 37
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

local PanelInfo = New("Frame", {
	Size = UDim2.new(1, 0, 0, 86),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 36
}, PanelPage)
Corner(PanelInfo, 12)
Stroke(PanelInfo, 0.4)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 14),
	BackgroundTransparency = 1,
	Text = "Menu Shortcut",
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 37
}, PanelInfo)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 43),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 37
}, PanelInfo)

local StatusHud = New("Frame", {
	Name = "StatusHud",
	Size = UDim2.fromOffset(240, 38),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 500
}, ScreenGui)
Corner(StatusHud, 10)
Stroke(StatusHud, 0.15, 1, Theme.PurpleSoft)

local HudAccent = New("Frame", {
	Size = UDim2.fromOffset(3, 18),
	Position = UDim2.fromOffset(12, 10),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 501
}, StatusHud)
Corner(HudAccent, 2)

local HudTitle = New("TextLabel", {
	Size = UDim2.fromOffset(105, 20),
	Position = UDim2.fromOffset(25, 9),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB",
	TextColor3 = Theme.White,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 501
}, StatusHud)

local FpsLabel = New("TextLabel", {
	Size = UDim2.fromOffset(92, 20),
	Position = UDim2.new(1, -104, 0, 9),
	BackgroundTransparency = 1,
	Text = "FPS 0",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Right,
	ZIndex = 501
}, StatusHud)

local function MakeDraggable(handle, target)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

MakeDraggable(TopBar, Main)
MakeDraggable(StatusHud, StatusHud)

local MenuTweenToken = 0

local function SetMenuVisible(visible)
	MenuTweenToken += 1
	local token = MenuTweenToken
	State.menuVisible = visible

	if visible then
		Main.Visible = true
		Main.GroupTransparency = 1
		MainScale.Scale = 0.93

		Tween(MainScale, 0.28, {
			Scale = 1
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Main, 0.24, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	else
		Tween(MainScale, 0.2, {
			Scale = 0.95
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.18, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if token == MenuTweenToken and not State.menuVisible then
				Main.Visible = false
			end
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if WaitingForHotkey then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
			local button = HotkeyButtons[WaitingForHotkey]
			if button then
				button.Text = FormatHotkey(Hotkeys[WaitingForHotkey])
				button.TextColor3 = Theme.Muted
			end
			WaitingForHotkey = nil
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and (input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete) then

			Hotkeys[WaitingForHotkey] = nil
		elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			Hotkeys[WaitingForHotkey] = {
				kind = "KeyCode",
				value = input.KeyCode
			}
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then

			Hotkeys[WaitingForHotkey] = {
				kind = "InputType",
				value = input.UserInputType
			}
		else
			return
		end

		local button = HotkeyButtons[WaitingForHotkey]
		if button then
			button.Text = FormatHotkey(Hotkeys[WaitingForHotkey])
			button.TextColor3 = Theme.Muted
		end

		WaitingForHotkey = nil
		return
	end

	local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

	if input.UserInputType == Enum.UserInputType.Keyboard
		and ctrlDown
		and input.KeyCode == Enum.KeyCode.M then

		SetMenuVisible(not State.menuVisible)
		return
	end

	if gameProcessed then
		return
	end

	for id, binding in pairs(Hotkeys) do
		if BindingMatches(binding, input) then
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

local frameCount = 0
local elapsed = 0

RunService.RenderStepped:Connect(function(deltaTime)
	frameCount += 1
	elapsed += deltaTime

	if elapsed >= 0.5 then
		local fps = math.floor((frameCount / elapsed) + 0.5)
		FpsLabel.Text = "FPS " .. tostring(fps)
		frameCount = 0
		elapsed = 0
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
	local ok, image = pcall(function()
		return Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	if ok then
		Avatar.Image = image
	end
end)

SelectPage("Main")

task.spawn(function()
	Tween(IntroScale, 0.55, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroLineTop, 0.55, {
		Size = UDim2.fromOffset(390, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.12)

	Tween(IntroTitle, 0.38, {
		TextTransparency = 0
	}, Enum.EasingStyle.Quad)

	task.wait(0.1)

	Tween(IntroSubtitle, 0.34, {
		TextTransparency = 0
	}, Enum.EasingStyle.Quad)

	Tween(IntroLineBottom, 0.55, {
		Size = UDim2.fromOffset(260, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.75)

	Tween(IntroScale, 0.28, {
		Scale = 1.035
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

	local fade = Tween(Intro, 0.42, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	fade.Completed:Wait()
	Intro.Visible = false

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.92

	Tween(MainScale, 0.42, {
		Scale = 1
	}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	Tween(Main, 0.3, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end)

