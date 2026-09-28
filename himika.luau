if _G.KuromiHubCleanup then
	pcall(_G.KuromiHubCleanup)
	_G.KuromiHubCleanup = nil
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Existing = PlayerGui:FindFirstChild("KuromiHub")
if Existing then
	Existing:Destroy()
end

for _, name in ipairs({
	"KuromiColor",
	"KuromiBloom",
	"KuromiSunRays",
	"KuromiDepth",
	"KuromiAtmosphere"
}) do
	local object = Lighting:FindFirstChild(name)
	if object then
		object:Destroy()
	end
end

local Theme = {
	Base = Color3.fromRGB(8, 7, 12),
	BaseSoft = Color3.fromRGB(13, 10, 19),
	Panel = Color3.fromRGB(19, 14, 27),
	Panel2 = Color3.fromRGB(27, 20, 38),
	Panel3 = Color3.fromRGB(36, 26, 51),
	Panel4 = Color3.fromRGB(45, 32, 62),
	Purple = Color3.fromRGB(157, 94, 235),
	PurpleSoft = Color3.fromRGB(108, 67, 163),
	Pink = Color3.fromRGB(235, 109, 178),
	PinkSoft = Color3.fromRGB(198, 89, 150),
	White = Color3.fromRGB(247, 243, 251),
	Muted = Color3.fromRGB(165, 151, 181),
	Stroke = Color3.fromRGB(72, 53, 93),
	Off = Color3.fromRGB(58, 47, 68),
	Black = Color3.fromRGB(5, 4, 8),
	Success = Color3.fromRGB(129, 210, 170)
}

local State = {
	antiFling = false,
	esp = false,
	walkSpeed = false,
	noclip = false,
	invisible = false,
	shaders = false,
	lowGraphics = false,
	walkSpeedValue = 16,
	shaderStrength = 65,
	menuVisible = true
}

local Hotkeys = {
	antiFling = nil,
	esp = nil,
	walkSpeed = nil,
	noclip = nil,
	invisible = nil,
	shaders = nil,
	lowGraphics = nil
}

local Connections = {}
local ToggleSetters = {}
local HotkeyButtons = {}
local WaitingForHotkey = nil
local EspObjects = {}
local SavedLocalCollision = {}
local SavedOtherCollision = {}
local SavedWalkSpeed = nil
local LastSafeCFrame = nil
local ShaderObjects = {}
local ShaderSaved = {
	lighting = {},
	parts = {}
}
local LowGraphicsSaved = {
	lighting = {},
	objects = {}
}
local InvisibleSaved = {}
local Destroyed = false

local function Bind(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Connections, connection)
	return connection
end

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
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 2000
}, ScreenGui)

local IntroScale = New("UIScale", {
	Scale = 0.9
}, Intro)

local IntroCenter = New("Frame", {
	Size = UDim2.fromOffset(560, 220),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 2001
}, Intro)

local IntroIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(74, 74),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.34, 0),
	BackgroundTransparency = 1,
	Image = "rbxassetid://8287008384",
	ImageColor3 = Theme.White,
	ImageTransparency = 1,
	ZIndex = 2002
}, IntroCenter)

local IntroLine = New("Frame", {
	Size = UDim2.fromOffset(0, 2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.58, 0),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 2002
}, IntroCenter)
Corner(IntroLine, 1)

local IntroTitle = New("TextLabel", {
	Size = UDim2.fromOffset(520, 48),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.72, 0),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 32,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 2002
}, IntroCenter)

local IntroSub = New("TextLabel", {
	Size = UDim2.fromOffset(520, 24),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.87, 0),
	BackgroundTransparency = 1,
	Text = "CONTROL INTERFACE",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
	ZIndex = 2002
}, IntroCenter)

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(820, 540),
	Position = UDim2.new(0.5, -410, 0.5, -270),
	BackgroundColor3 = Theme.BaseSoft,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 18)
Stroke(Main, 0.06, 1.2, Theme.PurpleSoft)

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
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local Accent = New("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
	ZIndex = 60
}, Main)

local AccentGradient = New("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Purple),
		ColorSequenceKeypoint.new(0.5, Theme.Pink),
		ColorSequenceKeypoint.new(1, Theme.Purple)
	}),
	Offset = Vector2.new(-1, 0)
}, Accent)

local TopBar = New("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 86),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)

local HubIconBox = New("Frame", {
	Size = UDim2.fromOffset(52, 52),
	Position = UDim2.fromOffset(18, 17),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	ZIndex = 51
}, TopBar)
Corner(HubIconBox, 13)
Stroke(HubIconBox, 0.14, 1, Theme.Purple)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(38, 38),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://8287008384",
	ImageColor3 = Theme.White,
	ZIndex = 52
}, HubIconBox)

local HubName = New("TextLabel", {
	Size = UDim2.fromOffset(300, 30),
	Position = UDim2.fromOffset(84, 16),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 22,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local HubSub = New("TextLabel", {
	Size = UDim2.fromOffset(320, 18),
	Position = UDim2.fromOffset(85, 47),
	BackgroundTransparency = 1,
	Text = "PERSONAL CONTROL INTERFACE",
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(40, 40),
	Position = UDim2.new(1, -210, 0, 23),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 51
}, TopBar)
Corner(Avatar, 11)
Stroke(Avatar, 0.2, 1, Theme.Purple)

local DisplayName = New("TextLabel", {
	Size = UDim2.fromOffset(150, 18),
	Position = UDim2.new(1, -160, 0, 21),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.White,
	TextSize = 12,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 51
}, TopBar)

local Username = New("TextLabel", {
	Size = UDim2.fromOffset(150, 18),
	Position = UDim2.new(1, -160, 0, 43),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 51
}, TopBar)

local Sidebar = New("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 188, 1, -86),
	Position = UDim2.fromOffset(0, 86),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.03,
	BorderSizePixel = 0,
	ZIndex = 45
}, Main)
Padding(Sidebar, 12, 12, 15, 12)

New("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
}, Sidebar)

local Content = New("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -188, 1, -86),
	Position = UDim2.fromOffset(188, 86),
	BackgroundTransparency = 1,
	ZIndex = 45
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
		ZIndex = 45
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
				Size = selected and UDim2.fromOffset(3, 22) or UDim2.fromOffset(3, 6),
				BackgroundTransparency = selected and 0 or 0.7
			}, Enum.EasingStyle.Quart)
		end
	end
end

local function CreateTab(name, order)
	local button = New("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Theme.Muted,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 46
	}, Sidebar)
	Corner(button, 10)
	Padding(button, 19, 10, 0, 0)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	local marker = New("Frame", {
		Name = "Marker",
		Size = UDim2.fromOffset(3, 6),
		Position = UDim2.new(0, 7, 0.5, -3),
		BackgroundColor3 = Theme.Pink,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 47
	}, button)
	Corner(marker, 2)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.12, {Scale = 1.025}, Enum.EasingStyle.Quad)
		if not Pages[name].Visible then
			Tween(button, 0.12, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseLeave, function()
		Tween(scale, 0.12, {Scale = 1}, Enum.EasingStyle.Quad)
		if not Pages[name].Visible then
			Tween(button, 0.12, {BackgroundColor3 = Theme.Panel2}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.08, {Scale = 0.98}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.1, {Scale = 1.025}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, function()
		SelectPage(name)
	end)

	TabButtons[name] = button
end

local InfoPage = CreatePage("Info")
local MainPage = CreatePage("Main")
local PlayerPage = CreatePage("Player")
local VisualPage = CreatePage("Visual")
local GraphicsPage = CreatePage("Graphics")
local SettingsPage = CreatePage("Settings")

CreateTab("Info", 1)
CreateTab("Main", 2)
CreateTab("Player", 3)
CreateTab("Visual", 4)
CreateTab("Graphics", 5)
CreateTab("Settings", 6)

local ShortcutLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	LayoutOrder = 20,
	ZIndex = 46
}, Sidebar)

local function Section(parent, title, subtitle, order)
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 54 or 34),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 17,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
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
			ZIndex = 47
		}, holder)
	end
end

local function ButtonCard(parent, text, order, callback)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(button, 12)
	Stroke(button, 0.42)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(button, 0.12, {BackgroundColor3 = Theme.Panel3}, Enum.EasingStyle.Quad)
		Tween(scale, 0.12, {Scale = 1.012}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(button, 0.12, {BackgroundColor3 = Theme.Panel}, Enum.EasingStyle.Quad)
		Tween(scale, 0.12, {Scale = 1}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.07, {Scale = 0.985}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {Scale = 1.012}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, callback)

	return button
end

local function CreateToggle(parent, config)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 68),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.01,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 46
	}, parent)
	Corner(row, 12)
	Stroke(row, 0.42)

	local rowScale = New("UIScale", {
		Scale = 1
	}, row)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(3, 28),
		Position = UDim2.fromOffset(14, 20),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 47
	}, row)
	Corner(accent, 2)

	New("TextLabel", {
		Size = UDim2.new(1, -215, 0, 21),
		Position = UDim2.fromOffset(29, 13),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = Theme.White,
		TextSize = 13,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	if config.subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, -215, 0, 18),
			Position = UDim2.fromOffset(29, 36),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, row)
	end

	local keyButton = New("TextButton", {
		Size = UDim2.fromOffset(78, 30),
		Position = UDim2.new(1, -158, 0.5, -15),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = FormatHotkey(Hotkeys[config.id]),
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
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
		ZIndex = 48
	}, row)
	Corner(switch, 14)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 49
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

	Bind(row.MouseEnter, function()
		Tween(rowScale, 0.12, {Scale = 1.008}, Enum.EasingStyle.Quad)
		Tween(row, 0.12, {BackgroundColor3 = Theme.Panel2}, Enum.EasingStyle.Quad)
	end)

	Bind(row.MouseLeave, function()
		Tween(rowScale, 0.12, {Scale = 1}, Enum.EasingStyle.Quad)
		Tween(row, 0.12, {BackgroundColor3 = Theme.Panel}, Enum.EasingStyle.Quad)
	end)

	Bind(switch.MouseButton1Down, function()
		Tween(rowScale, 0.07, {Scale = 0.992}, Enum.EasingStyle.Quad)
	end)

	Bind(switch.MouseButton1Up, function()
		Tween(rowScale, 0.08, {Scale = 1.008}, Enum.EasingStyle.Quad)
	end)

	Bind(switch.MouseButton1Click, function()
		Set(not State[config.id])
	end)

	Bind(keyButton.MouseEnter, function()
		Tween(keyButton, 0.12, {BackgroundColor3 = Theme.Panel4}, Enum.EasingStyle.Quad)
	end)

	Bind(keyButton.MouseLeave, function()
		Tween(keyButton, 0.12, {BackgroundColor3 = Theme.Panel2}, Enum.EasingStyle.Quad)
	end)

	Bind(keyButton.MouseButton1Click, function()
		WaitingForHotkey = config.id
		keyButton.Text = "PRESS KEY"
		keyButton.TextColor3 = Theme.Pink
	end)

	Apply(State[config.id])
	return row
end

local function CreateEditableSlider(row, y, minimum, maximum, initial, callback)
	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(64, 28),
		Position = UDim2.new(1, -80, 0, y - 14),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Text = tostring(initial),
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 49
	}, row)
	Corner(valueBox, 8)
	Stroke(valueBox, 0.45)

	local slider = New("Frame", {
		Size = UDim2.new(1, -136, 0, 6),
		Position = UDim2.fromOffset(29, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 48
	}, row)
	Corner(slider, 3)

	local normalized = (initial - minimum) / (maximum - minimum)

	local fill = New("Frame", {
		Size = UDim2.fromScale(normalized, 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 49
	}, slider)
	Corner(fill, 3)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(15, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(normalized, 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 50
	}, slider)
	Corner(knob, 8)
	Stroke(knob, 0.28, 1, Theme.Pink)

	local dragging = false
	local current = initial

	local function SetValue(value)
		value = math.clamp(math.floor(tonumber(value) or current), minimum, maximum)
		current = value

		local alpha = (value - minimum) / (maximum - minimum)
		Tween(fill, 0.1, {Size = UDim2.fromScale(alpha, 1)}, Enum.EasingStyle.Quad)
		Tween(knob, 0.1, {Position = UDim2.new(alpha, 0, 0.5, 0)}, Enum.EasingStyle.Quad)
		valueBox.Text = tostring(value)
		callback(value)
	end

	local function UpdateFromX(x)
		local alpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		SetValue(minimum + ((maximum - minimum) * alpha))
	end

	Bind(slider.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			UpdateFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then

			UpdateFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	Bind(valueBox.FocusLost, function()
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

local function RestoreInvisible()
	for object, saved in pairs(InvisibleSaved) do
		if object and object.Parent then
			if object:IsA("BasePart") then
				object.LocalTransparencyModifier = saved
			elseif object:IsA("Decal") or object:IsA("Texture") then
				object.Transparency = saved
			end
		end
	end
	table.clear(InvisibleSaved)
end

local function ApplyInvisible()
	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if InvisibleSaved[object] == nil then
				InvisibleSaved[object] = object.LocalTransparencyModifier
			end
			object.LocalTransparencyModifier = 1
		elseif object:IsA("Decal") or object:IsA("Texture") then
			if InvisibleSaved[object] == nil then
				InvisibleSaved[object] = object.Transparency
			end
			object.Transparency = 1
		end
	end
end

local function GetTagsForPlayer(player)
	local found = {}
	local seen = {}

	local function AddTags(instance)
		if not instance then
			return
		end

		for _, tag in ipairs(CollectionService:GetTags(instance)) do
			if not seen[tag] then
				seen[tag] = true
				table.insert(found, tag)
			end
		end
	end

	AddTags(player)
	AddTags(player.Character)

	table.sort(found)
	return found
end

local function TagColor(tags)
	if #tags == 0 then
		return Theme.Purple, Theme.Pink
	end

	local text = table.concat(tags, "|")
	local hash = 0

	for i = 1, #text do
		hash = (hash * 31 + string.byte(text, i)) % 360
	end

	local fill = Color3.fromHSV(hash / 360, 0.58, 1)
	local outline = Color3.fromHSV(((hash + 38) % 360) / 360, 0.52, 1)

	return fill, outline
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

	local tags = GetTagsForPlayer(player)
	local fillColor, outlineColor = TagColor(tags)
	local tagText = #tags > 0 and table.concat(tags, ", ") or "PLAYER"

	local data = EspObjects[player]

	if data and data.character ~= character then
		DestroyEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "KuromiESPHighlight",
			Adornee = character,
			FillColor = fillColor,
			FillTransparency = 0.78,
			OutlineColor = outlineColor,
			OutlineTransparency = 0.03,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = "KuromiESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(220, 54),
			StudsOffset = Vector3.new(0, 3.05, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local card = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Base,
			BackgroundTransparency = 0.13,
			BorderSizePixel = 0,
			ZIndex = 60
		}, billboard)
		Corner(card, 9)
		Stroke(card, 0.16, 1, outlineColor)

		local marker = New("Frame", {
			Size = UDim2.fromOffset(3, 32),
			Position = UDim2.fromOffset(9, 11),
			BackgroundColor3 = fillColor,
			BorderSizePixel = 0,
			ZIndex = 61
		}, card)
		Corner(marker, 2)

		local title = New("TextLabel", {
			Size = UDim2.new(1, -30, 0, 18),
			Position = UDim2.fromOffset(20, 7),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 61
		}, card)

		local info = New("TextLabel", {
			Size = UDim2.new(1, -30, 0, 16),
			Position = UDim2.fromOffset(20, 26),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 9,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 61
		}, card)

		local tagLabel = New("TextLabel", {
			Size = UDim2.fromOffset(78, 18),
			Position = UDim2.new(1, -87, 0, 6),
			BackgroundColor3 = fillColor,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			TextColor3 = Theme.White,
			TextSize = 8,
			Font = Enum.Font.GothamBold,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 62
		}, card)
		Corner(tagLabel, 6)

		data = {
			character = character,
			root = root,
			highlight = highlight,
			billboard = billboard,
			card = card,
			marker = marker,
			title = title,
			info = info,
			tagLabel = tagLabel,
			tagSignature = ""
		}

		EspObjects[player] = data
	end

	data.root = root

	local signature = table.concat(tags, "|")
	if data.tagSignature ~= signature then
		data.tagSignature = signature
		data.highlight.FillColor = fillColor
		data.highlight.OutlineColor = outlineColor
		data.marker.BackgroundColor3 = fillColor
		data.tagLabel.BackgroundColor3 = fillColor

		local cardStroke = data.card:FindFirstChildOfClass("UIStroke")
		if cardStroke then
			cardStroke.Color = outlineColor
		end
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot then
		distance = math.floor((localRoot.Position - root.Position).Magnitude + 0.5)
	end

	data.title.Text = player.DisplayName
	data.info.Text = "@" .. player.Name .. "  |  " .. tostring(distance) .. "m"
	data.tagLabel.Text = tagText
end

local function ClearEsp()
	for player in pairs(EspObjects) do
		DestroyEsp(player)
	end
end

local function SaveLightingProperty(name)
	if ShaderSaved.lighting[name] == nil then
		ShaderSaved.lighting[name] = Lighting[name]
	end
end

local function ApplyShaderStrength()
	local value = State.shaderStrength / 100

	local color = ShaderObjects.Color
	local bloom = ShaderObjects.Bloom
	local sun = ShaderObjects.Sun
	local depth = ShaderObjects.Depth

	if color then
		color.Brightness = 0.01 + (0.04 * value)
		color.Contrast = 0.08 + (0.16 * value)
		color.Saturation = 0.02 + (0.12 * value)
	end

	if bloom then
		bloom.Intensity = 0.16 + (0.42 * value)
		bloom.Size = 24 + (18 * value)
		bloom.Threshold = 1.35 - (0.35 * value)
	end

	if sun then
		sun.Intensity = 0.025 + (0.08 * value)
		sun.Spread = 0.72 + (0.18 * value)
	end

	if depth then
		depth.FarIntensity = 0.03 + (0.1 * value)
		depth.FocusDistance = 65
		depth.InFocusRadius = 60 - (12 * value)
	end
end

local function EnableShaders()
	if next(ShaderObjects) then
		ApplyShaderStrength()
		return
	end

	for _, property in ipairs({
		"GlobalShadows",
		"ShadowSoftness",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"Brightness",
		"ExposureCompensation"
	}) do
		SaveLightingProperty(property)
	end

	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.18
	Lighting.EnvironmentDiffuseScale = 0.72
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Brightness = math.max(Lighting.Brightness, 2.2)
	Lighting.ExposureCompensation = 0.06

	ShaderObjects.Color = New("ColorCorrectionEffect", {
		Name = "KuromiColor",
		TintColor = Color3.fromRGB(240, 224, 255)
	}, Lighting)

	ShaderObjects.Bloom = New("BloomEffect", {
		Name = "KuromiBloom"
	}, Lighting)

	ShaderObjects.Sun = New("SunRaysEffect", {
		Name = "KuromiSunRays"
	}, Lighting)

	ShaderObjects.Depth = New("DepthOfFieldEffect", {
		Name = "KuromiDepth",
		NearIntensity = 0
	}, Lighting)

	ShaderObjects.Atmosphere = New("Atmosphere", {
		Name = "KuromiAtmosphere",
		Density = 0.18,
		Offset = 0.08,
		Color = Color3.fromRGB(210, 194, 230),
		Decay = Color3.fromRGB(92, 72, 115),
		Glare = 0.06,
		Haze = 0.5
	}, Lighting)

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("BasePart")
			and (object.Material == Enum.Material.Metal
				or object.Material == Enum.Material.Glass
				or object.Material == Enum.Material.DiamondPlate
				or object.Material == Enum.Material.Foil) then

			ShaderSaved.parts[object] = object.Reflectance

			if object.Material == Enum.Material.Glass then
				object.Reflectance = math.max(object.Reflectance, 0.18)
			else
				object.Reflectance = math.max(object.Reflectance, 0.1)
			end
		end
	end

	ApplyShaderStrength()
end

local function DisableShaders()
	for _, object in pairs(ShaderObjects) do
		if object then
			object:Destroy()
		end
	end
	table.clear(ShaderObjects)

	for property, value in pairs(ShaderSaved.lighting) do
		pcall(function()
			Lighting[property] = value
		end)
	end

	for part, value in pairs(ShaderSaved.parts) do
		if part and part.Parent then
			part.Reflectance = value
		end
	end

	ShaderSaved = {
		lighting = {},
		parts = {}
	}
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
			object.Transparency = math.max(object.Transparency, 0.4)
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
			pcall(function()
				object[saved.property] = saved.value
			end)
		end
	end

	LowGraphicsSaved = {
		lighting = {},
		objects = {}
	}
end

local function FindTeleportTarget(kind)
	local exactNames

	if kind == "Map" then
		exactNames = {
			"MapSpawn",
			"MapSpawnLocation",
			"MapTeleport",
			"MapTP",
			"Map"
		}
	else
		exactNames = {
			"LobbySpawn",
			"LobbySpawnLocation",
			"LobbyTeleport",
			"LobbyTP",
			"Lobby"
		}
	end

	for _, name in ipairs(exactNames) do
		local object = Workspace:FindFirstChild(name, true)
		if object and (object:IsA("BasePart") or object:IsA("SpawnLocation") or object:IsA("Model")) then
			return object
		end
	end

	local loweredKind = string.lower(kind)

	for _, object in ipairs(Workspace:GetDescendants()) do
		if (object:IsA("BasePart") or object:IsA("SpawnLocation") or object:IsA("Model"))
			and string.find(string.lower(object.Name), loweredKind, 1, true) then

			return object
		end
	end

	return nil
end

local function TeleportToTarget(kind, button)
	local target = FindTeleportTarget(kind)
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not target or not root then
		local old = button.Text
		button.Text = kind:upper() .. " TARGET NOT FOUND"
		task.delay(1.2, function()
			if button and button.Parent then
				button.Text = old
			end
		end)
		return
	end

	if target:IsA("Model") then
		root.CFrame = target:GetPivot() + Vector3.new(0, 4, 0)
	else
		root.CFrame = target.CFrame + Vector3.new(0, 4, 0)
	end
end

Section(InfoPage, "Kuromi Hub", "Runtime information", 1)

local InfoCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 132),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, InfoPage)
Corner(InfoCard, 12)
Stroke(InfoCard, 0.4)

local InfoIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(66, 66),
	Position = UDim2.fromOffset(16, 18),
	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,
	Image = "rbxassetid://8287008384",
	ImageColor3 = Theme.White,
	ZIndex = 47
}, InfoCard)
Corner(InfoIcon, 15)
Stroke(InfoIcon, 0.18, 1, Theme.Purple)

New("TextLabel", {
	Size = UDim2.new(1, -110, 0, 26),
	Position = UDim2.fromOffset(98, 18),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 18,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -110, 0, 20),
	Position = UDim2.fromOffset(98, 48),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName .. "  |  @" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

local InfoFps = New("TextLabel", {
	Size = UDim2.new(1, -110, 0, 20),
	Position = UDim2.fromOffset(98, 72),
	BackgroundTransparency = 1,
	Text = "FPS 0",
	TextColor3 = Theme.Pink,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -32, 0, 18),
	Position = UDim2.fromOffset(16, 102),
	BackgroundTransparency = 1,
	Text = "CTRL + M TO OPEN OR CLOSE THE PANEL",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

Section(MainPage, "Session", "Server and destination actions", 1)

local Rejoin = ButtonCard(MainPage, "REJOIN CURRENT SERVER", 2, function()
end)

Bind(Rejoin.MouseButton1Click, function()
	Rejoin.Text = "REJOINING..."

	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)

	if not ok then
		Rejoin.Text = "REJOIN FAILED"
		task.delay(1.2, function()
			if Rejoin and Rejoin.Parent then
				Rejoin.Text = "REJOIN CURRENT SERVER"
			end
		end)
	end
end)

local TeleportMap = ButtonCard(MainPage, "TELEPORT TO MAP", 3, function()
end)

Bind(TeleportMap.MouseButton1Click, function()
	TeleportToTarget("Map", TeleportMap)
end)

local TeleportLobby = ButtonCard(MainPage, "TELEPORT TO LOBBY", 4, function()
end)

Bind(TeleportLobby.MouseButton1Click, function()
	TeleportToTarget("Lobby", TeleportLobby)
end)

Section(PlayerPage, "Player", "Movement and local character controls", 1)

CreateToggle(PlayerPage, {
	id = "antiFling",
	title = "Anti-Fling",
	subtitle = "Velocity and collision protection",
	order = 2
})

CreateToggle(PlayerPage, {
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

CreateToggle(PlayerPage, {
	id = "invisible",
	title = "Invisible",
	subtitle = "Local character visibility",
	order = 4,
	changed = function(enabled)
		if enabled then
			ApplyInvisible()
		else
			RestoreInvisible()
		end
	end
})

local WalkRow = CreateToggle(PlayerPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "Editable movement speed",
	order = 5,
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

Section(VisualPage, "Visual", "Player visibility", 1)

CreateToggle(VisualPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "Name, username, distance and tag-aware color",
	order = 2
})

Section(GraphicsPage, "Graphics", "Lighting, reflections and performance", 1)

local ShaderRow = CreateToggle(GraphicsPage, {
	id = "shaders",
	title = "Enhanced Shaders",
	subtitle = "Reflections, shadows, bloom, atmosphere and lighting",
	order = 2,
	height = 108,
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

CreateEditableSlider(ShaderRow, 81, 0, 100, State.shaderStrength, function(value)
	State.shaderStrength = value

	if State.shaders then
		ApplyShaderStrength()
	end
end)

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "Reduce effects, materials and particles",
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

Section(SettingsPage, "Settings", "Panel-only configuration", 1)

local BackgroundCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 114),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, SettingsPage)
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
	ZIndex = 47
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
	ZIndex = 47
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
	ZIndex = 47
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

Bind(BackgroundBox.FocusLost, function()
	ApplyBackground(BackgroundBox.Text)
end)

local ShortcutCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 86),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, SettingsPage)
Corner(ShortcutCard, 12)
Stroke(ShortcutCard, 0.4)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 14),
	BackgroundTransparency = 1,
	Text = "Menu Shortcut",
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, ShortcutCard)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 22),
	Position = UDim2.fromOffset(15, 43),
	BackgroundTransparency = 1,
	Text = "CTRL + M",
	TextColor3 = Theme.Pink,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, ShortcutCard)

local StatusHud = New("CanvasGroup", {
	Name = "StatusHud",
	Size = UDim2.fromOffset(250, 40),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.03,
	BorderSizePixel = 0,
	Active = true,
	GroupTransparency = 1,
	ZIndex = 700
}, ScreenGui)
Corner(StatusHud, 10)
Stroke(StatusHud, 0.12, 1, Theme.PurpleSoft)

local HudScale = New("UIScale", {
	Scale = 0.94
}, StatusHud)

local HudMarker = New("Frame", {
	Size = UDim2.fromOffset(3, 20),
	Position = UDim2.fromOffset(12, 10),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 701
}, StatusHud)
Corner(HudMarker, 2)

local HudIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(22, 22),
	Position = UDim2.fromOffset(25, 9),
	BackgroundTransparency = 1,
	Image = "rbxassetid://8287008384",
	ImageColor3 = Theme.White,
	ZIndex = 701
}, StatusHud)

New("TextLabel", {
	Size = UDim2.fromOffset(105, 20),
	Position = UDim2.fromOffset(54, 10),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB",
	TextColor3 = Theme.White,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 701
}, StatusHud)

local FpsLabel = New("TextLabel", {
	Size = UDim2.fromOffset(76, 20),
	Position = UDim2.new(1, -88, 0, 10),
	BackgroundTransparency = 1,
	Text = "FPS 0",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Right,
	ZIndex = 701
}, StatusHud)

local function MakeDraggable(handle, target)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil

	Bind(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = target.Position

			Bind(input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Bind(handle.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			dragInput = input
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
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
		MainScale.Scale = 0.9

		Tween(MainScale, 0.34, {
			Scale = 1
		}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		Tween(Main, 0.25, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	else
		Tween(MainScale, 0.22, {
			Scale = 0.92
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.2, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if token == MenuTweenToken and not State.menuVisible then
				Main.Visible = false
			end
		end)
	end
end

Bind(UserInputService.InputBegan, function(input, gameProcessed)
	if WaitingForHotkey then
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == Enum.KeyCode.Escape then

			local button = HotkeyButtons[WaitingForHotkey]
			if button then
				button.Text = FormatHotkey(Hotkeys[WaitingForHotkey])
				button.TextColor3 = Theme.Muted
			end

			WaitingForHotkey = nil
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and (input.KeyCode == Enum.KeyCode.Backspace
				or input.KeyCode == Enum.KeyCode.Delete) then

			Hotkeys[WaitingForHotkey] = nil

		elseif input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode ~= Enum.KeyCode.Unknown then

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

Bind(RunService.Stepped, function()
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

	if State.invisible then
		ApplyInvisible()
	end
end)

Bind(RunService.Heartbeat, function()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if State.walkSpeed and humanoid then
		humanoid.WalkSpeed = State.walkSpeedValue
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
local animationTime = 0

Bind(RunService.RenderStepped, function(deltaTime)
	frameCount += 1
	elapsed += deltaTime
	animationTime += deltaTime

	AccentGradient.Offset = Vector2.new(((animationTime * 0.22) % 2) - 1, 0)

	if elapsed >= 0.5 then
		local fps = math.floor((frameCount / elapsed) + 0.5)
		local text = "FPS " .. tostring(fps)
		FpsLabel.Text = text
		InfoFps.Text = text
		frameCount = 0
		elapsed = 0
	end
end)

Bind(Players.PlayerRemoving, function(player)
	DestroyEsp(player)
end)

Bind(LocalPlayer.CharacterAdded, function(character)
	LastSafeCFrame = nil
	SavedWalkSpeed = nil
	RestoreLocalCollision()
	RestoreInvisible()

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = State.walkSpeedValue
		end

		if State.invisible then
			task.wait(0.2)
			ApplyInvisible()
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

local function Cleanup()
	if Destroyed then
		return
	end

	Destroyed = true
	WaitingForHotkey = nil

	State.antiFling = false
	State.esp = false
	State.walkSpeed = false
	State.noclip = false
	State.invisible = false
	State.shaders = false
	State.lowGraphics = false

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed = SavedWalkSpeed
	end

	SavedWalkSpeed = nil

	RestoreLocalCollision()
	RestoreOtherCollision()
	RestoreInvisible()
	ClearEsp()
	DisableShaders()
	DisableLowGraphics()

	for _, connection in ipairs(Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(Connections)

	if ScreenGui and ScreenGui.Parent then
		ScreenGui:Destroy()
	end

	if _G.KuromiHubCleanup == Cleanup then
		_G.KuromiHubCleanup = nil
	end
end

_G.KuromiHubCleanup = Cleanup

SelectPage("Info")

task.spawn(function()
	Tween(IntroScale, 0.5, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroIcon, 0.34, {
		ImageTransparency = 0
	}, Enum.EasingStyle.Quad)

	task.wait(0.1)

	Tween(IntroLine, 0.52, {
		Size = UDim2.fromOffset(300, 2)
	}, Enum.EasingStyle.Quint)

	task.wait(0.08)

	Tween(IntroTitle, 0.34, {
		TextTransparency = 0
	}, Enum.EasingStyle.Quad)

	task.wait(0.08)

	Tween(IntroSub, 0.3, {
		TextTransparency = 0
	}, Enum.EasingStyle.Quad)

	task.wait(0.65)

	Tween(IntroScale, 0.22, {
		Scale = 1.04
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

	local introFade = Tween(Intro, 0.38, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	introFade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.9
	Main.Position = UDim2.new(0.5, -410, 0.5, -245)

	Tween(MainScale, 0.42, {
		Scale = 1
	}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	Tween(Main, 0.3, {
		GroupTransparency = 0,
		Position = UDim2.new(0.5, -410, 0.5, -270)
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	StatusHud.GroupTransparency = 1
	HudScale.Scale = 0.92

	task.wait(0.08)

	Tween(HudScale, 0.32, {
		Scale = 1
	}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	Tween(StatusHud, 0.24, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Quad)
end)

