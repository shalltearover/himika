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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OldGui = PlayerGui:FindFirstChild("KuromiHub")
if OldGui then
	OldGui:Destroy()
end

local OldBlur = Lighting:FindFirstChild("KuromiPanelBlur")
if OldBlur then
	OldBlur:Destroy()
end

for _, name in ipairs({
	"KuromiGraphicsColor",
	"KuromiGraphicsBloom",
	"KuromiGraphicsSun",
	"KuromiGraphicsDepth",
	"KuromiGraphicsAtmosphere"
}) do
	local object = Lighting:FindFirstChild(name)
	if object then
		object:Destroy()
	end
end

local BACKGROUND_ASSET_ID = 10039618753
local HUB_ICON_ASSET_ID = 11878291148

local Theme = {
	Base = Color3.fromRGB(8, 6, 12),
	Surface = Color3.fromRGB(16, 12, 22),
	Surface2 = Color3.fromRGB(22, 16, 30),
	Surface3 = Color3.fromRGB(30, 21, 40),
	SurfaceHover = Color3.fromRGB(38, 27, 50),
	Purple = Color3.fromRGB(154, 91, 225),
	PurpleSoft = Color3.fromRGB(111, 71, 158),
	Pink = Color3.fromRGB(232, 106, 169),
	Red = Color3.fromRGB(239, 73, 84),
	White = Color3.fromRGB(246, 242, 249),
	Muted = Color3.fromRGB(157, 146, 169),
	Off = Color3.fromRGB(56, 47, 65),
	ButtonStroke = Color3.fromRGB(72, 56, 88),
	Black = Color3.fromRGB(4, 3, 6)
}

local State = {
	antiFling = false,
	esp = false,
	walkSpeed = false,
	noclip = false,
	graphicsEnhancement = false,
	lowGraphics = false,
	fpsVisible = false,
	walkSpeedValue = 16,
	graphicsStrength = 60,
	backgroundBlur = 0,
	backgroundBrightness = 55,
	menuVisible = true
}

local Hotkeys = {
	antiFling = nil,
	esp = nil,
	walkSpeed = nil,
	noclip = nil,
	graphicsEnhancement = nil,
	lowGraphics = nil
}

local PanelShortcut = {
	kind = "KeyCode",
	value = Enum.KeyCode.M,
	ctrl = true,
	shift = false,
	alt = false
}

local FpsShortcut = {
	kind = "KeyCode",
	value = Enum.KeyCode.F4,
	ctrl = false,
	shift = false,
	alt = false
}

local Connections = {}
local ToggleSetters = {}
local HotkeyButtons = {}
local Capture = nil
local EspObjects = {}
local SavedLocalCollision = {}
local SavedOtherCollision = {}
local SavedWalkSpeed = nil
local LastSafeCFrame = nil
local GraphicsObjects = {}
local GraphicsSaved = {
	lighting = {},
	parts = {}
}
local LowSaved = {
	lighting = {},
	objects = {}
}
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
		CornerRadius = UDim.new(0, radius or 8)
	}, parent)
end

local function Stroke(parent, transparency, thickness, color)
	return New("UIStroke", {
		Color = color or Theme.ButtonStroke,
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

local function AssetThumbnail(assetId)
	return "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=420&h=420"
end

local function Modifiers()
	return {
		ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl),
		shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift),
		alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
	}
end

local function KeyName(keyCode)
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
	return aliases[keyCode.Name] or string.upper(keyCode.Name)
end

local function FormatBinding(binding)
	if not binding then
		return "SET"
	end

	local parts = {}

	if binding.ctrl then
		table.insert(parts, "CTRL")
	end
	if binding.shift then
		table.insert(parts, "SHIFT")
	end
	if binding.alt then
		table.insert(parts, "ALT")
	end

	if binding.kind == "KeyCode" then
		table.insert(parts, KeyName(binding.value))
	elseif binding.kind == "InputType" then
		local aliases = {
			MouseButton1 = "MOUSE1",
			MouseButton2 = "MOUSE2",
			MouseButton3 = "MOUSE3"
		}
		table.insert(parts, aliases[binding.value.Name] or string.upper(binding.value.Name))
	end

	return table.concat(parts, " + ")
end

local function BindingMatches(binding, input)
	if not binding then
		return false
	end

	local mods = Modifiers()

	if (binding.ctrl or false) ~= mods.ctrl then
		return false
	end
	if (binding.shift or false) ~= mods.shift then
		return false
	end
	if (binding.alt or false) ~= mods.alt then
		return false
	end

	if binding.kind == "KeyCode" then
		return input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == binding.value
	end

	if binding.kind == "InputType" then
		return input.UserInputType == binding.value
	end

	return false
end

local function ToggleBindingMatches(binding, input)
	if not binding then
		return false
	end

	if binding.kind == "KeyCode" then
		return input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == binding.value
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

local PanelBlur = New("BlurEffect", {
	Name = "KuromiPanelBlur",
	Enabled = false,
	Size = 0
}, Lighting)

local Intro = New("CanvasGroup", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 2000
}, ScreenGui)

local IntroScale = New("UIScale", {
	Scale = 0.93
}, Intro)

local IntroIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(76, 76),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.44, 10),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ImageTransparency = 1,
	ZIndex = 2001
}, Intro)

local IntroTitle = New("TextLabel", {
	Size = UDim2.fromOffset(480, 42),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.58, 12),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 28,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 2001
}, Intro)

local IntroLine = New("Frame", {
	Size = UDim2.fromOffset(0, 1),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.65, 0),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 2001
}, Intro)

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(820, 535),
	Position = UDim2.new(0.5, -410, 0.5, -268),
	BackgroundColor3 = Theme.Base,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 16)

local MainScale = New("UIScale", {
	Scale = 0.965
}, Main)

local Background = New("ImageLabel", {
	Size = UDim2.fromScale(1.05, 1.05),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(BACKGROUND_ASSET_ID),
	ImageTransparency = 0.22,
	ImageColor3 = Color3.fromRGB(190, 190, 190),
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 20
}, Main)

local BackgroundShade = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Base,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local SideGlow = New("Frame", {
	Size = UDim2.fromOffset(145, 145),
	Position = UDim2.new(1, -90, 0, -60),
	BackgroundColor3 = Theme.Purple,
	BackgroundTransparency = 0.88,
	BorderSizePixel = 0,
	ZIndex = 22
}, Main)
Corner(SideGlow, 73)

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 78),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.07,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)

local IconBacking = New("Frame", {
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.fromOffset(18, 16),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	ZIndex = 51
}, TopBar)
Corner(IconBacking, 12)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 52
}, IconBacking)

local HubTitle = New("TextLabel", {
	Size = UDim2.fromOffset(250, 24),
	Position = UDim2.fromOffset(78, 17),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 18,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local HubSub = New("TextLabel", {
	Size = UDim2.fromOffset(300, 18),
	Position = UDim2.fromOffset(79, 41),
	BackgroundTransparency = 1,
	Text = "personal control panel",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local ShortcutChip = New("TextLabel", {
	Size = UDim2.fromOffset(112, 30),
	Position = UDim2.new(1, -130, 0, 24),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	Text = "CTRL + M",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.GothamBold,
	ZIndex = 51
}, TopBar)
Corner(ShortcutChip, 9)
Stroke(ShortcutChip, 0.55, 1, Theme.ButtonStroke)

local Sidebar = New("Frame", {
	Size = UDim2.new(0, 178, 1, -78),
	Position = UDim2.fromOffset(0, 78),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	ZIndex = 45
}, Main)

local SidebarSeparator = New("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = Color3.fromRGB(70, 55, 84),
	BackgroundTransparency = 0.75,
	BorderSizePixel = 0,
	ZIndex = 46
}, Sidebar)

local TabsHolder = New("Frame", {
	Size = UDim2.new(1, 0, 1, -72),
	BackgroundTransparency = 1,
	ZIndex = 46
}, Sidebar)
Padding(TabsHolder, 11, 11, 14, 8)

New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, TabsHolder)

local Profile = New("Frame", {
	Size = UDim2.new(1, -22, 0, 56),
	Position = UDim2.new(0, 11, 1, -62),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.42,
	BorderSizePixel = 0,
	ZIndex = 46
}, Sidebar)
Corner(Profile, 10)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(34, 34),
	Position = UDim2.fromOffset(9, 11),
	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 47
}, Profile)
Corner(Avatar, 9)

local ProfileName = New("TextLabel", {
	Size = UDim2.new(1, -54, 0, 17),
	Position = UDim2.fromOffset(51, 10),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.White,
	TextSize = 9,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 47
}, Profile)

local ProfileUser = New("TextLabel", {
	Size = UDim2.new(1, -54, 0, 15),
	Position = UDim2.fromOffset(51, 28),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 47
}, Profile)

local Content = New("Frame", {
	Size = UDim2.new(1, -178, 1, -78),
	Position = UDim2.fromOffset(178, 78),
	BackgroundTransparency = 1,
	ZIndex = 45
}, Main)

local Pages = {}
local Tabs = {}

local function CreatePage(name)
	local page = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Purple,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		Visible = false,
		ZIndex = 45
	}, Content)

	New("UIListLayout", {
		Padding = UDim.new(0, 8),
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

	for tabName, data in pairs(Tabs) do
		local selected = tabName == name

		Tween(data.button, 0.16, {
			BackgroundTransparency = selected and 0.14 or 1,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)

		Tween(data.marker, 0.16, {
			BackgroundTransparency = selected and 0 or 1,
			Size = selected and UDim2.fromOffset(3, 20) or UDim2.fromOffset(3, 6)
		}, Enum.EasingStyle.Quart)
	end
end

local function CreateTab(name, order)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Theme.Muted,
		TextSize = 10,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 47
	}, TabsHolder)
	Corner(button, 8)
	Padding(button, 18, 8, 0, 0)

	local marker = New("Frame", {
		Size = UDim2.fromOffset(3, 6),
		Position = UDim2.new(0, 7, 0.5, -3),
		BackgroundColor3 = Theme.Pink,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 48
	}, button)
	Corner(marker, 2)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.12, {Scale = 1.018}, Enum.EasingStyle.Quad)

		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 0.5,
				TextColor3 = Theme.White
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseLeave, function()
		Tween(scale, 0.12, {Scale = 1}, Enum.EasingStyle.Quad)

		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 1,
				TextColor3 = Theme.Muted
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.07, {Scale = 0.982}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {Scale = 1.018}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, function()
		SelectPage(name)
	end)

	Tabs[name] = {
		button = button,
		marker = marker
	}
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

local function Section(parent, title, subtitle, order)
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 50 or 30),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 15,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, holder)

	if subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.fromOffset(0, 25),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 9,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, holder)
	end
end

local function ActionButton(parent, text, order, callback)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(button, 9)
	Stroke(button, 0.48, 1, Theme.ButtonStroke)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	local shine = New("Frame", {
		Size = UDim2.fromOffset(3, 20),
		Position = UDim2.fromOffset(11, 13),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 47
	}, button)
	Corner(shine, 2)

	Bind(button.MouseEnter, function()
		Tween(button, 0.13, {BackgroundColor3 = Theme.SurfaceHover}, Enum.EasingStyle.Quad)
		Tween(scale, 0.13, {Scale = 1.008}, Enum.EasingStyle.Quad)
		Tween(shine, 0.13, {BackgroundColor3 = Theme.Pink}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(button, 0.13, {BackgroundColor3 = Theme.Surface2}, Enum.EasingStyle.Quad)
		Tween(scale, 0.13, {Scale = 1}, Enum.EasingStyle.Quad)
		Tween(shine, 0.13, {BackgroundColor3 = Theme.Purple}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.06, {Scale = 0.986}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {Scale = 1.008}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, callback)

	return button
end

local function CreateToggle(parent, config)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 64),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 46
	}, parent)
	Corner(row, 10)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(3, 25),
		Position = UDim2.fromOffset(12, 20),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 47
	}, row)
	Corner(accent, 2)

	New("TextLabel", {
		Size = UDim2.new(1, -210, 0, 18),
		Position = UDim2.fromOffset(26, 11),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	if config.subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, -210, 0, 16),
			Position = UDim2.fromOffset(26, 32),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, row)
	end

	local keyButton = New("TextButton", {
		Size = UDim2.fromOffset(74, 28),
		Position = UDim2.new(1, -150, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(Hotkeys[config.id]),
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(keyButton, 7)
	Stroke(keyButton, 0.5, 1, Theme.ButtonStroke)

	local switch = New("TextButton", {
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -58, 0.5, -12),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(switch, 12)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 49
	}, switch)
	Corner(knob, 9)

	local function Apply(enabled)
		Tween(switch, 0.16, {
			BackgroundColor3 = enabled and Theme.Purple or Theme.Off
		}, Enum.EasingStyle.Quad)

		Tween(knob, 0.16, {
			Position = enabled and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Quad)

		Tween(accent, 0.16, {
			BackgroundColor3 = enabled and Theme.Pink or Theme.Purple,
			BackgroundTransparency = enabled and 0 or 0.55
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
		Tween(row, 0.12, {
			BackgroundColor3 = Theme.Surface2,
			BackgroundTransparency = 0.08
		}, Enum.EasingStyle.Quad)
	end)

	Bind(row.MouseLeave, function()
		Tween(row, 0.12, {
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 0.1
		}, Enum.EasingStyle.Quad)
	end)

	Bind(switch.MouseButton1Click, function()
		Set(not State[config.id])
	end)

	Bind(keyButton.MouseButton1Click, function()
		Capture = {
			type = "toggle",
			id = config.id,
			button = keyButton
		}
		keyButton.Text = "PRESS"
		keyButton.TextColor3 = Theme.Pink
	end)

	Apply(false)
	return row
end

local function CreateSlider(row, y, minimum, maximum, initial, callback, percent)
	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(62, 26),
		Position = UDim2.new(1, -76, 0, y - 13),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = tostring(initial) .. (percent and "%" or ""),
		TextColor3 = Theme.White,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 49
	}, row)
	Corner(valueBox, 7)

	local slider = New("Frame", {
		Size = UDim2.new(1, -132, 0, 4),
		Position = UDim2.fromOffset(26, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 48
	}, row)
	Corner(slider, 2)

	local alpha = (initial - minimum) / (maximum - minimum)

	local fill = New("Frame", {
		Size = UDim2.fromScale(alpha, 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 49
	}, slider)
	Corner(fill, 2)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(alpha, 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 50
	}, slider)
	Corner(knob, 6)

	local dragging = false
	local current = initial

	local function SetValue(value)
		local parsed = tonumber(string.gsub(tostring(value), "%%", ""))
		value = math.clamp(math.floor(parsed or current), minimum, maximum)
		current = value

		local newAlpha = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(newAlpha, 1)
		knob.Position = UDim2.new(newAlpha, 0, 0.5, 0)
		valueBox.Text = tostring(value) .. (percent and "%" or "")
		callback(value)
	end

	local function FromX(x)
		local newAlpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		SetValue(minimum + ((maximum - minimum) * newAlpha))
	end

	Bind(slider.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			FromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then

			FromX(input.Position.X)
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

local function ShortcutRow(parent, title, subtitle, order, getBinding, setBinding, captureType)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(row, 10)

	New("TextLabel", {
		Size = UDim2.new(1, -155, 0, 18),
		Position = UDim2.fromOffset(14, 11),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	New("TextLabel", {
		Size = UDim2.new(1, -155, 0, 16),
		Position = UDim2.fromOffset(14, 31),
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	local button = New("TextButton", {
		Size = UDim2.fromOffset(126, 30),
		Position = UDim2.new(1, -140, 0.5, -15),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(getBinding()),
		TextColor3 = Theme.White,
		TextSize = 8,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(button, 7)
	Stroke(button, 0.5, 1, Theme.ButtonStroke)

	Bind(button.MouseButton1Click, function()
		Capture = {
			type = captureType,
			button = button,
			get = getBinding,
			set = setBinding
		}
		button.Text = "PRESS KEY"
		button.TextColor3 = Theme.Pink
	end)

	return button
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

local function ReadClassificationValues(player)
	local values = {}
	local seen = {}
	local character = player.Character

	local function Add(value)
		if value == nil then
			return
		end

		value = tostring(value)

		if value == "" or seen[value] then
			return
		end

		seen[value] = true
		table.insert(values, value)
	end

	local names = {
		"Tag",
		"Class",
		"PlayerClass",
		"CharacterClass",
		"Role",
		"Faction",
		"Type",
		"Category"
	}

	for _, instance in ipairs({player, character}) do
		if instance then
			for _, name in ipairs(names) do
				Add(instance:GetAttribute(name))
			end

			for _, name in ipairs(names) do
				local valueObject = instance:FindFirstChild(name)
				if valueObject and valueObject:IsA("ValueBase") then
					Add(valueObject.Value)
				end
			end

			for _, tag in ipairs(CollectionService:GetTags(instance)) do
				if tag ~= "Player"
					and tag ~= "Character"
					and tag ~= "Humanoid" then

					Add(tag)
				end
			end
		end
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		for _, name in ipairs(names) do
			local valueObject = leaderstats:FindFirstChild(name)
			if valueObject and valueObject:IsA("ValueBase") then
				Add(valueObject.Value)
			end
		end
	end

	if player.Team then
		Add("Team=" .. player.Team.Name)
	end

	table.sort(values)
	return values
end

local function ClassificationSignature(player)
	return table.concat(ReadClassificationValues(player), "|")
end

local function IsDifferentClassification(player)
	local localSignature = ClassificationSignature(LocalPlayer)
	local playerSignature = ClassificationSignature(player)

	if localSignature == "" and playerSignature == "" then
		return false
	end

	return localSignature ~= playerSignature
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

	local different = IsDifferentClassification(player)
	local outlineColor = different and Theme.Red or Theme.Purple
	local data = EspObjects[player]

	if data and data.character ~= character then
		DestroyEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "KuromiESPHighlight",
			Adornee = character,
			FillColor = outlineColor,
			FillTransparency = 0.94,
			OutlineColor = outlineColor,
			OutlineTransparency = 0.02,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = "KuromiESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(210, 28),
			StudsOffset = Vector3.new(0, 2.72, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = New("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextStrokeColor3 = outlineColor,
			TextStrokeTransparency = 0.38,
			TextSize = 11,
			Font = Enum.Font.GothamSemibold,
			ZIndex = 60
		}, billboard)

		data = {
			character = character,
			root = root,
			highlight = highlight,
			billboard = billboard,
			label = label,
			different = different
		}

		EspObjects[player] = data
	end

	if data.different ~= different then
		data.different = different
		data.highlight.FillColor = outlineColor
		data.highlight.OutlineColor = outlineColor
		data.label.TextStrokeColor3 = outlineColor
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot then
		distance = math.floor((localRoot.Position - root.Position).Magnitude + 0.5)
	end

	data.label.Text = player.DisplayName .. "  ·  " .. tostring(distance) .. "m"
end

local function ClearEsp()
	for player in pairs(EspObjects) do
		DestroyEsp(player)
	end
end

local function SaveLighting(property)
	if GraphicsSaved.lighting[property] == nil then
		GraphicsSaved.lighting[property] = Lighting[property]
	end
end

local function ApplyGraphicsStrength()
	local alpha = State.graphicsStrength / 100

	if GraphicsObjects.Color then
		GraphicsObjects.Color.Brightness = 0.005 + 0.03 * alpha
		GraphicsObjects.Color.Contrast = 0.06 + 0.13 * alpha
		GraphicsObjects.Color.Saturation = 0.01 + 0.09 * alpha
	end

	if GraphicsObjects.Bloom then
		GraphicsObjects.Bloom.Intensity = 0.12 + 0.38 * alpha
		GraphicsObjects.Bloom.Size = 22 + 14 * alpha
		GraphicsObjects.Bloom.Threshold = 1.45 - 0.36 * alpha
	end

	if GraphicsObjects.Sun then
		GraphicsObjects.Sun.Intensity = 0.018 + 0.055 * alpha
		GraphicsObjects.Sun.Spread = 0.72 + 0.16 * alpha
	end

	if GraphicsObjects.Depth then
		GraphicsObjects.Depth.FarIntensity = 0.018 + 0.055 * alpha
		GraphicsObjects.Depth.FocusDistance = 72
		GraphicsObjects.Depth.InFocusRadius = 62 - 10 * alpha
	end

	if GraphicsObjects.Atmosphere then
		GraphicsObjects.Atmosphere.Density = 0.11 + 0.07 * alpha
		GraphicsObjects.Atmosphere.Haze = 0.2 + 0.24 * alpha
		GraphicsObjects.Atmosphere.Glare = 0.025 + 0.055 * alpha
	end
end

local function EnableGraphicsEnhancement()
	if next(GraphicsObjects) then
		ApplyGraphicsStrength()
		return
	end

	for _, property in ipairs({
		"GlobalShadows",
		"ShadowSoftness",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"Brightness",
		"ExposureCompensation",
		"Ambient",
		"OutdoorAmbient",
		"ColorShift_Top",
		"ColorShift_Bottom"
	}) do
		SaveLighting(property)
	end

	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.14
	Lighting.EnvironmentDiffuseScale = 0.82
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Brightness = math.max(Lighting.Brightness, 2.15)
	Lighting.ExposureCompensation = 0.045
	Lighting.Ambient = Color3.fromRGB(111, 102, 124)
	Lighting.OutdoorAmbient = Color3.fromRGB(129, 121, 144)
	Lighting.ColorShift_Top = Color3.fromRGB(8, 4, 12)
	Lighting.ColorShift_Bottom = Color3.fromRGB(4, 3, 7)

	GraphicsObjects.Color = New("ColorCorrectionEffect", {
		Name = "KuromiGraphicsColor",
		TintColor = Color3.fromRGB(242, 232, 252)
	}, Lighting)

	GraphicsObjects.Bloom = New("BloomEffect", {
		Name = "KuromiGraphicsBloom"
	}, Lighting)

	GraphicsObjects.Sun = New("SunRaysEffect", {
		Name = "KuromiGraphicsSun"
	}, Lighting)

	GraphicsObjects.Depth = New("DepthOfFieldEffect", {
		Name = "KuromiGraphicsDepth",
		NearIntensity = 0
	}, Lighting)

	GraphicsObjects.Atmosphere = New("Atmosphere", {
		Name = "KuromiGraphicsAtmosphere",
		Color = Color3.fromRGB(222, 211, 232),
		Decay = Color3.fromRGB(100, 87, 116),
		Offset = 0.05
	}, Lighting)

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("BasePart")
			and (object.Material == Enum.Material.Metal
				or object.Material == Enum.Material.Glass
				or object.Material == Enum.Material.DiamondPlate
				or object.Material == Enum.Material.Foil) then

			GraphicsSaved.parts[object] = object.Reflectance

			if object.Material == Enum.Material.Glass then
				object.Reflectance = math.max(object.Reflectance, 0.2)
			elseif object.Material == Enum.Material.Metal then
				object.Reflectance = math.max(object.Reflectance, 0.13)
			else
				object.Reflectance = math.max(object.Reflectance, 0.09)
			end
		end
	end

	ApplyGraphicsStrength()
end

local function DisableGraphicsEnhancement()
	for _, object in pairs(GraphicsObjects) do
		if object then
			object:Destroy()
		end
	end
	table.clear(GraphicsObjects)

	for property, value in pairs(GraphicsSaved.lighting) do
		pcall(function()
			Lighting[property] = value
		end)
	end

	for part, value in pairs(GraphicsSaved.parts) do
		if part and part.Parent then
			part.Reflectance = value
		end
	end

	GraphicsSaved = {
		lighting = {},
		parts = {}
	}
end

local function EnableLowGraphics()
	if LowSaved.lighting.GlobalShadows ~= nil then
		return
	end

	LowSaved.lighting.GlobalShadows = Lighting.GlobalShadows
	LowSaved.lighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
	LowSaved.lighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

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

			LowSaved.objects[object] = {
				property = "Enabled",
				value = object.Enabled
			}
			object.Enabled = false

		elseif object:IsA("BasePart") then
			LowSaved.objects[object] = {
				property = "Material",
				value = object.Material
			}
			object.Material = Enum.Material.SmoothPlastic
		end
	end

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect")
			and not string.find(effect.Name, "^Kuromi") then

			LowSaved.objects[effect] = {
				property = "Enabled",
				value = effect.Enabled
			}
			effect.Enabled = false
		end
	end
end

local function DisableLowGraphics()
	if LowSaved.lighting.GlobalShadows ~= nil then
		Lighting.GlobalShadows = LowSaved.lighting.GlobalShadows
	end

	if LowSaved.lighting.EnvironmentDiffuseScale ~= nil then
		Lighting.EnvironmentDiffuseScale = LowSaved.lighting.EnvironmentDiffuseScale
	end

	if LowSaved.lighting.EnvironmentSpecularScale ~= nil then
		Lighting.EnvironmentSpecularScale = LowSaved.lighting.EnvironmentSpecularScale
	end

	for object, saved in pairs(LowSaved.objects) do
		if object and object.Parent then
			pcall(function()
				object[saved.property] = saved.value
			end)
		end
	end

	LowSaved = {
		lighting = {},
		objects = {}
	}
end

local function GetPlaceId(kind)
	local attributeNames

	if kind == "Game" then
		attributeNames = {
			"GamePlaceId",
			"GameplayPlaceId",
			"MapPlaceId"
		}
	else
		attributeNames = {
			"LobbyPlaceId",
			"HubPlaceId"
		}
	end

	for _, source in ipairs({game, Workspace, ReplicatedStorage}) do
		for _, attributeName in ipairs(attributeNames) do
			local value = source:GetAttribute(attributeName)

			if typeof(value) == "number" and value > 0 then
				return math.floor(value)
			end

			if typeof(value) == "string" then
				local parsed = tonumber(value)
				if parsed and parsed > 0 then
					return math.floor(parsed)
				end
			end
		end
	end

	for _, attributeName in ipairs(attributeNames) do
		local object = ReplicatedStorage:FindFirstChild(attributeName)
			or Workspace:FindFirstChild(attributeName)

		if object and (object:IsA("IntValue") or object:IsA("NumberValue")) then
			if object.Value > 0 then
				return math.floor(object.Value)
			end
		end
	end

	return nil
end

local function SpawnInside(container, kind)
	if not container then
		return nil
	end

	local priority

	if kind == "Game" then
		priority = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn",
			"RoundSpawn",
			"Spawn",
			"SpawnLocation",
			"Start",
			"StartPoint",
			"Entry",
			"Entrance",
			"Teleport",
			"TP"
		}
	else
		priority = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn",
			"Spawn",
			"SpawnLocation",
			"Start",
			"StartPoint",
			"Entry",
			"Entrance",
			"Teleport",
			"TP"
		}
	end

	for _, name in ipairs(priority) do
		local object = container:FindFirstChild(name, true)
		if object then
			if object:IsA("BasePart") then
				return object.CFrame
			elseif object:IsA("Attachment") then
				return object.WorldCFrame
			elseif object:IsA("Model") then
				local primary = object.PrimaryPart
					or object:FindFirstChildWhichIsA("SpawnLocation", true)
					or object:FindFirstChildWhichIsA("BasePart", true)

				if primary then
					return primary.CFrame
				end
			end
		end
	end

	local spawn = container:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return spawn.CFrame
	end

	return nil
end

local function FindLocalDestination(kind)
	local tagNames
	local containerNames
	local directNames

	if kind == "Game" then
		tagNames = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn"
		}

		containerNames = {
			"Game",
			"Gameplay",
			"Map",
			"Arena",
			"Match"
		}

		directNames = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn",
			"RoundSpawn"
		}
	else
		tagNames = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn"
		}

		containerNames = {
			"Lobby",
			"Hub",
			"WaitingRoom"
		}

		directNames = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn"
		}
	end

	for _, tagName in ipairs(tagNames) do
		for _, object in ipairs(CollectionService:GetTagged(tagName)) do
			if object:IsA("BasePart") then
				return object.CFrame
			elseif object:IsA("Attachment") then
				return object.WorldCFrame
			end
		end
	end

	for _, containerName in ipairs(containerNames) do
		local container = Workspace:FindFirstChild(containerName, true)
		if container then
			local cf = SpawnInside(container, kind)
			if cf then
				return cf
			end
		end
	end

	for _, directName in ipairs(directNames) do
		local object = Workspace:FindFirstChild(directName, true)

		if object then
			if object:IsA("BasePart") then
				return object.CFrame
			elseif object:IsA("Attachment") then
				return object.WorldCFrame
			end
		end
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		local destination = object:GetAttribute("Destination")
			or object:GetAttribute("TeleportDestination")
			or object:GetAttribute("Zone")

		if destination and string.lower(tostring(destination)) == string.lower(kind) then
			if object:IsA("BasePart") then
				return object.CFrame
			elseif object:IsA("Attachment") then
				return object.WorldCFrame
			end
		end
	end

	return nil
end

local function TeleportTo(kind, button)
	local placeId = GetPlaceId(kind)

	if placeId and placeId ~= game.PlaceId then
		button.Text = "TELEPORTING..."

		local ok = pcall(function()
			TeleportService:Teleport(placeId, LocalPlayer)
		end)

		if not ok then
			button.Text = "TELEPORT FAILED"

			task.delay(1.2, function()
				if button and button.Parent then
					button.Text = "TELEPORT TO " .. string.upper(kind)
				end
			end)
		end

		return
	end

	local destination = FindLocalDestination(kind)
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if destination and root then
		root.CFrame = destination + Vector3.new(0, 4, 0)
		return
	end

	local old = button.Text
	button.Text = string.upper(kind) .. " SPAWN NOT FOUND"

	task.delay(1.2, function()
		if button and button.Parent then
			button.Text = old
		end
	end)
end

local function ApplyBackgroundSettings()
	local brightness = math.clamp(State.backgroundBrightness / 100, 0, 1)
	local value = 0.35 + brightness * 0.65

	Background.ImageColor3 = Color3.new(value, value, value)

	if State.menuVisible and State.backgroundBlur > 0 then
		PanelBlur.Enabled = true
		PanelBlur.Size = math.floor((State.backgroundBlur / 100) * 24 + 0.5)
	else
		PanelBlur.Enabled = false
		PanelBlur.Size = 0
	end
end

Section(InfoPage, "Kuromi Hub", "Interface information", 1)

local InfoCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 122),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, InfoPage)
Corner(InfoCard, 11)

local InfoAccent = New("Frame", {
	Size = UDim2.fromOffset(4, 78),
	Position = UDim2.fromOffset(14, 22),
	BackgroundColor3 = Theme.Purple,
	BorderSizePixel = 0,
	ZIndex = 47
}, InfoCard)
Corner(InfoAccent, 2)

local InfoIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(62, 62),
	Position = UDim2.fromOffset(32, 20),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -130, 0, 24),
	Position = UDim2.fromOffset(110, 18),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 16,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -130, 0, 18),
	Position = UDim2.fromOffset(110, 46),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName .. "  /  @" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

local InfoFps = New("TextLabel", {
	Size = UDim2.new(1, -130, 0, 18),
	Position = UDim2.fromOffset(110, 69),
	BackgroundTransparency = 1,
	Text = "FPS 0",
	TextColor3 = Theme.Pink,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -44, 0, 17),
	Position = UDim2.fromOffset(32, 94),
	BackgroundTransparency = 1,
	Text = "All runtime options start disabled.",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

Section(MainPage, "Main", "Session and destination controls", 1)

local RejoinButton
RejoinButton = ActionButton(MainPage, "REJOIN CURRENT SERVER", 2, function()
	RejoinButton.Text = "REJOINING..."

	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)

	if not ok then
		RejoinButton.Text = "REJOIN FAILED"

		task.delay(1.2, function()
			if RejoinButton and RejoinButton.Parent then
				RejoinButton.Text = "REJOIN CURRENT SERVER"
			end
		end)
	end
end)

local GameButton
GameButton = ActionButton(MainPage, "TELEPORT TO GAME", 3, function()
	TeleportTo("Game", GameButton)
end)

local LobbyButton
LobbyButton = ActionButton(MainPage, "TELEPORT TO LOBBY", 4, function()
	TeleportTo("Lobby", LobbyButton)
end)

Section(PlayerPage, "Player", "Movement and protection", 1)

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

local WalkRow = CreateToggle(PlayerPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "Editable movement speed",
	order = 4,
	height = 101,
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

CreateSlider(WalkRow, 77, 1, 25, State.walkSpeedValue, function(value)
	State.walkSpeedValue = value

	if State.walkSpeed then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = value
		end
	end
end, false)

Section(VisualPage, "Visual", "Player visibility tools", 1)

CreateToggle(VisualPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "Purple outline by default, red when class or tags differ",
	order = 2
})

local FpsToggle = New("Frame", {
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, VisualPage)
Corner(FpsToggle, 10)

local FpsAccent = New("Frame", {
	Size = UDim2.fromOffset(3, 25),
	Position = UDim2.fromOffset(12, 20),
	BackgroundColor3 = Theme.Purple,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 47
}, FpsToggle)
Corner(FpsAccent, 2)

New("TextLabel", {
	Size = UDim2.new(1, -105, 0, 18),
	Position = UDim2.fromOffset(26, 11),
	BackgroundTransparency = 1,
	Text = "FPS Display",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, FpsToggle)

New("TextLabel", {
	Size = UDim2.new(1, -105, 0, 16),
	Position = UDim2.fromOffset(26, 32),
	BackgroundTransparency = 1,
	Text = "Movable FPS bar at the top of the screen",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, FpsToggle)

local FpsSwitch = New("TextButton", {
	Size = UDim2.fromOffset(46, 24),
	Position = UDim2.new(1, -58, 0.5, -12),
	BackgroundColor3 = Theme.Off,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 48
}, FpsToggle)
Corner(FpsSwitch, 12)

local FpsKnob = New("Frame", {
	Size = UDim2.fromOffset(18, 18),
	Position = UDim2.fromOffset(3, 3),
	BackgroundColor3 = Theme.White,
	BorderSizePixel = 0,
	ZIndex = 49
}, FpsSwitch)
Corner(FpsKnob, 9)

Section(GraphicsPage, "Graphics", "Improve the look of the game or reduce load", 1)

local GraphicsRow = CreateToggle(GraphicsPage, {
	id = "graphicsEnhancement",
	title = "Graphics Enhancement",
	subtitle = "Better shadows, specular lighting, reflections and post processing",
	order = 2,
	height = 101,
	changed = function(enabled)
		if enabled then
			if State.lowGraphics and ToggleSetters.lowGraphics then
				ToggleSetters.lowGraphics(false)
			end

			EnableGraphicsEnhancement()
		else
			DisableGraphicsEnhancement()
		end
	end
})

CreateSlider(GraphicsRow, 77, 0, 100, State.graphicsStrength, function(value)
	State.graphicsStrength = value

	if State.graphicsEnhancement then
		ApplyGraphicsStrength()
	end
end, true)

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "Reduce particles, materials and heavy visual effects",
	order = 3,
	changed = function(enabled)
		if enabled then
			if State.graphicsEnhancement and ToggleSetters.graphicsEnhancement then
				ToggleSetters.graphicsEnhancement(false)
			end

			EnableLowGraphics()
		else
			DisableLowGraphics()
		end
	end
})

Section(SettingsPage, "Settings", "Interface controls", 1)

local BlurRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, SettingsPage)
Corner(BlurRow, 10)

New("TextLabel", {
	Size = UDim2.new(1, -120, 0, 18),
	Position = UDim2.fromOffset(14, 10),
	BackgroundTransparency = 1,
	Text = "Background Blur",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BlurRow)

New("TextLabel", {
	Size = UDim2.new(1, -120, 0, 15),
	Position = UDim2.fromOffset(14, 29),
	BackgroundTransparency = 1,
	Text = "Blur behind the panel",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BlurRow)

CreateSlider(BlurRow, 62, 0, 100, State.backgroundBlur, function(value)
	State.backgroundBlur = value
	ApplyBackgroundSettings()
end, true)

local BrightnessRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, SettingsPage)
Corner(BrightnessRow, 10)

New("TextLabel", {
	Size = UDim2.new(1, -120, 0, 18),
	Position = UDim2.fromOffset(14, 10),
	BackgroundTransparency = 1,
	Text = "Background Brightness",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BrightnessRow)

New("TextLabel", {
	Size = UDim2.new(1, -120, 0, 15),
	Position = UDim2.fromOffset(14, 29),
	BackgroundTransparency = 1,
	Text = "Brightness of the fixed background artwork",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BrightnessRow)

CreateSlider(BrightnessRow, 62, 0, 100, State.backgroundBrightness, function(value)
	State.backgroundBrightness = value
	ApplyBackgroundSettings()
end, true)

ShortcutRow(
	SettingsPage,
	"Panel Shortcut",
	"Open or close the main panel",
	4,
	function()
		return PanelShortcut
	end,
	function(binding)
		PanelShortcut = binding
		ShortcutChip.Text = FormatBinding(PanelShortcut)
	end,
	"panel"
)

ShortcutRow(
	SettingsPage,
	"FPS Shortcut",
	"Show or hide the FPS display",
	5,
	function()
		return FpsShortcut
	end,
	function(binding)
		FpsShortcut = binding
	end,
	"fps"
)

local StatusHud = New("CanvasGroup", {
	Name = "StatusHud",
	Size = UDim2.fromOffset(218, 36),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Active = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 700
}, ScreenGui)
Corner(StatusHud, 10)

local HudScale = New("UIScale", {
	Scale = 0.96
}, StatusHud)

local HudIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(20, 20),
	Position = UDim2.fromOffset(10, 8),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 701
}, StatusHud)

New("TextLabel", {
	Size = UDim2.fromOffset(105, 18),
	Position = UDim2.fromOffset(38, 9),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB",
	TextColor3 = Theme.White,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 701
}, StatusHud)

local FpsLabel = New("TextLabel", {
	Size = UDim2.fromOffset(62, 18),
	Position = UDim2.new(1, -72, 0, 9),
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

local MenuAnimationId = 0
local FpsAnimationId = 0

local function SetMenuVisible(visible)
	MenuAnimationId += 1
	local animationId = MenuAnimationId

	State.menuVisible = visible

	if visible then
		Main.Visible = true
		Main.GroupTransparency = 1
		MainScale.Scale = 0.95
		Background.ImageTransparency = 0.58

		ApplyBackgroundSettings()

		Tween(MainScale, 0.42, {
			Scale = 1
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Main, 0.28, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		Tween(Background, 0.48, {
			ImageTransparency = 0.22
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(SideGlow, 0.5, {
			BackgroundTransparency = 0.88
		}, Enum.EasingStyle.Sine)
	else
		Tween(MainScale, 0.25, {
			Scale = 0.965
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		Tween(Background, 0.22, {
			ImageTransparency = 0.55
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.23, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		PanelBlur.Enabled = false
		PanelBlur.Size = 0

		fade.Completed:Once(function()
			if animationId == MenuAnimationId and not State.menuVisible then
				Main.Visible = false
			end
		end)
	end
end

local function SetFpsVisible(visible)
	FpsAnimationId += 1
	local animationId = FpsAnimationId

	State.fpsVisible = visible

	Tween(FpsSwitch, 0.16, {
		BackgroundColor3 = visible and Theme.Purple or Theme.Off
	}, Enum.EasingStyle.Quad)

	Tween(FpsKnob, 0.16, {
		Position = visible and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
	}, Enum.EasingStyle.Quad)

	Tween(FpsAccent, 0.16, {
		BackgroundColor3 = visible and Theme.Pink or Theme.Purple,
		BackgroundTransparency = visible and 0 or 0.55
	}, Enum.EasingStyle.Quad)

	if visible then
		StatusHud.Visible = true
		StatusHud.GroupTransparency = 1
		HudScale.Scale = 0.96

		Tween(HudScale, 0.3, {
			Scale = 1
		}, Enum.EasingStyle.Quint)

		Tween(StatusHud, 0.2, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine)
	else
		Tween(HudScale, 0.18, {
			Scale = 0.97
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		local fade = Tween(StatusHud, 0.17, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if animationId == FpsAnimationId and not State.fpsVisible then
				StatusHud.Visible = false
			end
		end)
	end
end

Bind(FpsSwitch.MouseButton1Click, function()
	SetFpsVisible(not State.fpsVisible)
end)

Bind(UserInputService.InputBegan, function(input, gameProcessed)
	if Capture then
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == Enum.KeyCode.Escape then

			if Capture.type == "toggle" then
				Capture.button.Text = FormatBinding(Hotkeys[Capture.id])
				Capture.button.TextColor3 = Theme.Muted
			else
				Capture.button.Text = FormatBinding(Capture.get())
				Capture.button.TextColor3 = Theme.White
			end

			Capture = nil
			return
		end

		if Capture.type == "toggle" then
			if input.UserInputType == Enum.UserInputType.Keyboard
				and (input.KeyCode == Enum.KeyCode.Backspace
					or input.KeyCode == Enum.KeyCode.Delete) then

				Hotkeys[Capture.id] = nil

			elseif input.UserInputType == Enum.UserInputType.Keyboard
				and input.KeyCode ~= Enum.KeyCode.Unknown then

				Hotkeys[Capture.id] = {
					kind = "KeyCode",
					value = input.KeyCode
				}

			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then

				Hotkeys[Capture.id] = {
					kind = "InputType",
					value = input.UserInputType
				}
			else
				return
			end

			Capture.button.Text = FormatBinding(Hotkeys[Capture.id])
			Capture.button.TextColor3 = Theme.Muted
			Capture = nil
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode ~= Enum.KeyCode.Unknown
			and input.KeyCode ~= Enum.KeyCode.LeftControl
			and input.KeyCode ~= Enum.KeyCode.RightControl
			and input.KeyCode ~= Enum.KeyCode.LeftShift
			and input.KeyCode ~= Enum.KeyCode.RightShift
			and input.KeyCode ~= Enum.KeyCode.LeftAlt
			and input.KeyCode ~= Enum.KeyCode.RightAlt then

			local mods = Modifiers()

			local binding = {
				kind = "KeyCode",
				value = input.KeyCode,
				ctrl = mods.ctrl,
				shift = mods.shift,
				alt = mods.alt
			}

			Capture.set(binding)
			Capture.button.Text = FormatBinding(binding)
			Capture.button.TextColor3 = Theme.White
			Capture = nil
			return
		end

		return
	end

	if BindingMatches(PanelShortcut, input) then
		SetMenuVisible(not State.menuVisible)
		return
	end

	if BindingMatches(FpsShortcut, input) then
		SetFpsVisible(not State.fpsVisible)
		return
	end

	if gameProcessed then
		return
	end

	for id, binding in pairs(Hotkeys) do
		if ToggleBindingMatches(binding, input) then
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
local visualTime = 0

Bind(RunService.RenderStepped, function(deltaTime)
	frameCount += 1
	elapsed += deltaTime
	visualTime += deltaTime

	local x = math.sin(visualTime * 0.14) * 0.0035
	local y = math.cos(visualTime * 0.11) * 0.0025

	Background.Position = UDim2.fromScale(0.5 + x, 0.5 + y)
	SideGlow.Position = UDim2.new(
		1,
		-90 + math.sin(visualTime * 0.5) * 5,
		0,
		-60 + math.cos(visualTime * 0.4) * 4
	)

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

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = State.walkSpeedValue
		end
	end)
end)

task.spawn(function()
	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size150x150
		)
	end)

	if ok and content then
		Avatar.Image = content
	else
		Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="
			.. tostring(LocalPlayer.UserId)
			.. "&w=150&h=150"
	end
end)

task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({
			Background,
			HubIcon,
			InfoIcon,
			IntroIcon,
			HudIcon,
			Avatar
		})
	end)
end)

local function Cleanup()
	if Destroyed then
		return
	end

	Destroyed = true
	Capture = nil

	State.antiFling = false
	State.esp = false
	State.walkSpeed = false
	State.noclip = false
	State.graphicsEnhancement = false
	State.lowGraphics = false
	State.fpsVisible = false

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed = SavedWalkSpeed
	end

	SavedWalkSpeed = nil

	RestoreLocalCollision()
	RestoreOtherCollision()
	ClearEsp()
	DisableGraphicsEnhancement()
	DisableLowGraphics()

	if PanelBlur and PanelBlur.Parent then
		PanelBlur:Destroy()
	end

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
ShortcutChip.Text = FormatBinding(PanelShortcut)
ApplyBackgroundSettings()
SetFpsVisible(false)

task.spawn(function()
	IntroIcon.Position = UDim2.new(0.5, 0, 0.44, 12)
	IntroTitle.Position = UDim2.new(0.5, 0, 0.58, 13)

	Tween(IntroScale, 0.5, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroIcon, 0.36, {
		ImageTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.44, 0)
	}, Enum.EasingStyle.Quint)

	task.wait(0.08)

	Tween(IntroTitle, 0.36, {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.58, 0)
	}, Enum.EasingStyle.Quint)

	Tween(IntroLine, 0.48, {
		Size = UDim2.fromOffset(190, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.52)

	Tween(IntroScale, 0.3, {
		Scale = 1.025
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	local introFade = Tween(Intro, 0.34, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	introFade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.95
	Background.ImageTransparency = 0.62

	ApplyBackgroundSettings()

	Tween(MainScale, 0.48, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(Main, 0.3, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Sine)

	Tween(Background, 0.52, {
		ImageTransparency = 0.22
	}, Enum.EasingStyle.Quint)
end)

