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

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("KuromiHub")
if oldGui then
	oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("KuromiPanelBlur")
if oldBlur then
	oldBlur:Destroy()
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
	Base = Color3.fromRGB(8, 7, 11),
	Panel = Color3.fromRGB(17, 13, 23),
	PanelSoft = Color3.fromRGB(23, 17, 31),
	PanelHover = Color3.fromRGB(30, 22, 40),
	Purple = Color3.fromRGB(153, 94, 222),
	PurpleSoft = Color3.fromRGB(104, 67, 147),
	Pink = Color3.fromRGB(226, 105, 169),
	White = Color3.fromRGB(244, 241, 247),
	Muted = Color3.fromRGB(154, 143, 165),
	Off = Color3.fromRGB(54, 45, 62),
	ButtonStroke = Color3.fromRGB(70, 54, 87),
	Black = Color3.fromRGB(4, 3, 6)
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
	shaderStrength = 60,
	backgroundBlur = 0,
	backgroundBrightness = 55,
	menuVisible = true,
	fpsVisible = true
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
local InvisibleLocalSaved = {}
local ShaderObjects = {}
local ShaderSaved = {
	lighting = {},
	parts = {}
}
local LowGraphicsSaved = {
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

local function GetRemote()
	local remote = ReplicatedStorage:FindFirstChild("KuromiHubRemote")
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end
	return nil
end

local function FireServer(action, value)
	local remote = GetRemote()
	if remote then
		remote:FireServer(action, value)
		return true
	end
	return false
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
		local names = {
			MouseButton1 = "MOUSE1",
			MouseButton2 = "MOUSE2",
			MouseButton3 = "MOUSE3"
		}
		table.insert(parts, names[binding.value.Name] or string.upper(binding.value.Name))
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

local function SimpleBindingMatches(binding, input)
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

local BlurEffect = New("BlurEffect", {
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
	Scale = 0.92
}, Intro)

local IntroCenter = New("Frame", {
	Size = UDim2.fromOffset(520, 180),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 2001
}, Intro)

local IntroIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(72, 72),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.33, 8),
	BackgroundTransparency = 1,
	Image = "rbxassetid://95904040684372",
	ImageColor3 = Theme.White,
	ImageTransparency = 1,
	ZIndex = 2002
}, IntroCenter)

local IntroTitle = New("TextLabel", {
	Size = UDim2.fromOffset(500, 44),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.68, 8),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 29,
	Font = Enum.Font.GothamBlack,
	TextTransparency = 1,
	ZIndex = 2002
}, IntroCenter)

local IntroLine = New("Frame", {
	Size = UDim2.fromOffset(0, 1),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.88, 0),
	BackgroundColor3 = Theme.Pink,
	BorderSizePixel = 0,
	ZIndex = 2002
}, IntroCenter)

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(790, 520),
	Position = UDim2.new(0.5, -395, 0.5, -260),
	BackgroundColor3 = Theme.Base,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 14)

local MainScale = New("UIScale", {
	Scale = 0.965
}, Main)

local BackgroundImage = New("ImageLabel", {
	Name = "Background",
	Size = UDim2.fromScale(1.06, 1.06),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://139771740411083",
	ImageTransparency = 0.32,
	ImageColor3 = Color3.fromRGB(185, 185, 185),
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 20
}, Main)

local BackgroundShade = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Base,
	BackgroundTransparency = 0.18,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 76),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(42, 42),
	Position = UDim2.fromOffset(18, 17),
	BackgroundTransparency = 1,
	Image = "rbxassetid://95904040684372",
	ImageColor3 = Theme.White,
	ZIndex = 51
}, TopBar)

local HubTitle = New("TextLabel", {
	Size = UDim2.fromOffset(260, 26),
	Position = UDim2.fromOffset(70, 15),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 19,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local HubSubtitle = New("TextLabel", {
	Size = UDim2.fromOffset(300, 18),
	Position = UDim2.fromOffset(71, 40),
	BackgroundTransparency = 1,
	Text = "PERSONAL CONTROL PANEL",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local ShortcutChip = New("TextLabel", {
	Size = UDim2.fromOffset(112, 30),
	Position = UDim2.new(1, -130, 0, 23),
	BackgroundColor3 = Theme.PanelSoft,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Text = "CTRL + M",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	ZIndex = 51
}, TopBar)
Corner(ShortcutChip, 8)

local Sidebar = New("Frame", {
	Size = UDim2.new(0, 172, 1, -76),
	Position = UDim2.fromOffset(0, 76),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	ZIndex = 45
}, Main)

local TabsHolder = New("Frame", {
	Size = UDim2.new(1, 0, 1, -74),
	BackgroundTransparency = 1,
	ZIndex = 46
}, Sidebar)
Padding(TabsHolder, 10, 10, 12, 8)

New("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
}, TabsHolder)

local Profile = New("Frame", {
	Size = UDim2.new(1, -20, 0, 58),
	Position = UDim2.new(0, 10, 1, -66),
	BackgroundTransparency = 1,
	ZIndex = 46
}, Sidebar)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.fromOffset(0, 11),
	BackgroundColor3 = Theme.PanelSoft,
	BorderSizePixel = 0,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
	ZIndex = 47
}, Profile)
Corner(Avatar, 10)

local ProfileName = New("TextLabel", {
	Size = UDim2.new(1, -48, 0, 18),
	Position = UDim2.fromOffset(47, 11),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.White,
	TextSize = 10,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 47
}, Profile)

local ProfileUser = New("TextLabel", {
	Size = UDim2.new(1, -48, 0, 16),
	Position = UDim2.fromOffset(47, 29),
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
	Size = UDim2.new(1, -172, 1, -76),
	Position = UDim2.fromOffset(172, 76),
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

		Tween(data.button, 0.15, {
			BackgroundTransparency = selected and 0.18 or 1,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)

		Tween(data.marker, 0.15, {
			BackgroundTransparency = selected and 0 or 1,
			Size = selected and UDim2.fromOffset(2, 18) or UDim2.fromOffset(2, 5)
		}, Enum.EasingStyle.Quad)
	end
end

local function CreateTab(name, order)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.PanelSoft,
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
	Corner(button, 7)
	Padding(button, 17, 8, 0, 0)

	local marker = New("Frame", {
		Size = UDim2.fromOffset(2, 5),
		Position = UDim2.new(0, 7, 0.5, -2),
		BackgroundColor3 = Theme.Pink,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 48
	}, button)
	Corner(marker, 1)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.12, {Scale = 1.018}, Enum.EasingStyle.Quad)
		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 0.55,
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
		Tween(scale, 0.07, {Scale = 0.985}, Enum.EasingStyle.Quad)
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
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.PanelSoft,
		BackgroundTransparency = 0.02,
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
	Stroke(button, 0.42, 1, Theme.ButtonStroke)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(button, 0.12, {BackgroundColor3 = Theme.PanelHover}, Enum.EasingStyle.Quad)
		Tween(scale, 0.12, {Scale = 1.01}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(button, 0.12, {BackgroundColor3 = Theme.PanelSoft}, Enum.EasingStyle.Quad)
		Tween(scale, 0.12, {Scale = 1}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.07, {Scale = 0.985}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {Scale = 1.01}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, callback)

	return button
end

local function CreateToggle(parent, config)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 62),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.16,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 46
	}, parent)
	Corner(row, 9)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(2, 24),
		Position = UDim2.fromOffset(12, 19),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 47
	}, row)
	Corner(accent, 1)

	New("TextLabel", {
		Size = UDim2.new(1, -210, 0, 18),
		Position = UDim2.fromOffset(25, 11),
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
			Position = UDim2.fromOffset(25, 31),
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
		BackgroundColor3 = Theme.PanelSoft,
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
			BackgroundTransparency = enabled and 0 or 0.6
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
		Tween(row, 0.12, {BackgroundTransparency = 0.04}, Enum.EasingStyle.Quad)
	end)

	Bind(row.MouseLeave, function()
		Tween(row, 0.12, {BackgroundTransparency = 0.16}, Enum.EasingStyle.Quad)
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
		BackgroundColor3 = Theme.PanelSoft,
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
		Position = UDim2.fromOffset(25, y),
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

	local function SetFromX(x)
		local newAlpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		SetValue(minimum + ((maximum - minimum) * newAlpha))
	end

	Bind(slider.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then

			SetFromX(input.Position.X)
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

local function ShortcutRow(parent, title, subtitle, order, bindingGetter, bindingSetter, captureType)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.16,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(row, 9)

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
		BackgroundColor3 = Theme.PanelSoft,
		BorderSizePixel = 0,
		Text = FormatBinding(bindingGetter()),
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
			get = bindingGetter,
			set = bindingSetter
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

local function RestoreLocalInvisible()
	for object, value in pairs(InvisibleLocalSaved) do
		if object and object.Parent then
			if object:IsA("BasePart") then
				object.LocalTransparencyModifier = value
			elseif object:IsA("Decal") or object:IsA("Texture") then
				object.Transparency = value
			end
		end
	end
	table.clear(InvisibleLocalSaved)
end

local function ApplyLocalInvisible()
	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if InvisibleLocalSaved[object] == nil then
				InvisibleLocalSaved[object] = object.LocalTransparencyModifier
			end
			object.LocalTransparencyModifier = 1
		elseif object:IsA("Decal") or object:IsA("Texture") then
			if InvisibleLocalSaved[object] == nil then
				InvisibleLocalSaved[object] = object.Transparency
			end
			object.Transparency = 1
		end
	end
end

local function CollectClassSignature(player)
	local values = {}
	local seen = {}

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
		"Class",
		"PlayerClass",
		"Role",
		"Type",
		"Faction",
		"TeamClass",
		"Category"
	}

	local character = player.Character

	for _, instance in ipairs({player, character}) do
		if instance then
			for _, name in ipairs(names) do
				Add(instance:GetAttribute(name))
			end

			for _, name in ipairs(names) do
				local child = instance:FindFirstChild(name)
				if child and child:IsA("ValueBase") then
					Add(child.Value)
				end
			end

			for _, tag in ipairs(CollectionService:GetTags(instance)) do
				if tag ~= "Player" and tag ~= "Character" then
					Add(tag)
				end
			end
		end
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		for _, name in ipairs(names) do
			local child = leaderstats:FindFirstChild(name)
			if child and child:IsA("ValueBase") then
				Add(child.Value)
			end
		end
	end

	if player.Team then
		Add("TEAM:" .. player.Team.Name)
	end

	table.sort(values)
	return table.concat(values, "|")
end

local function SignatureColor(player, signature)
	if player.Team and signature == "TEAM:" .. player.Team.Name then
		return player.Team.TeamColor.Color
	end

	if signature == "" then
		return Theme.Purple
	end

	local hash = 0
	for i = 1, #signature do
		hash = (hash * 33 + string.byte(signature, i)) % 360
	end

	return Color3.fromHSV(hash / 360, 0.58, 1)
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

	local signature = CollectClassSignature(player)
	local color = SignatureColor(player, signature)
	local data = EspObjects[player]

	if data and data.character ~= character then
		DestroyEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "KuromiESPHighlight",
			Adornee = character,
			FillColor = color,
			FillTransparency = 0.82,
			OutlineColor = color,
			OutlineTransparency = 0.04,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = "KuromiESPBillboard",
			Adornee = head,
			Size = UDim2.fromOffset(220, 30),
			StudsOffset = Vector3.new(0, 2.75, 0),
			AlwaysOnTop = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = New("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextColor3 = color,
			TextStrokeColor3 = Theme.Black,
			TextStrokeTransparency = 0.25,
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
			signature = nil
		}

		EspObjects[player] = data
	end

	if data.signature ~= signature then
		data.signature = signature
		data.highlight.FillColor = color
		data.highlight.OutlineColor = color
		data.label.TextColor3 = color
	end

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

local function SaveLighting(name)
	if ShaderSaved.lighting[name] == nil then
		ShaderSaved.lighting[name] = Lighting[name]
	end
end

local function ApplyShaderStrength()
	local alpha = State.shaderStrength / 100

	if ShaderObjects.Color then
		ShaderObjects.Color.Brightness = 0.005 + 0.035 * alpha
		ShaderObjects.Color.Contrast = 0.07 + 0.16 * alpha
		ShaderObjects.Color.Saturation = 0.02 + 0.1 * alpha
	end

	if ShaderObjects.Bloom then
		ShaderObjects.Bloom.Intensity = 0.12 + 0.45 * alpha
		ShaderObjects.Bloom.Size = 20 + 20 * alpha
		ShaderObjects.Bloom.Threshold = 1.4 - 0.38 * alpha
	end

	if ShaderObjects.Sun then
		ShaderObjects.Sun.Intensity = 0.02 + 0.075 * alpha
		ShaderObjects.Sun.Spread = 0.7 + 0.2 * alpha
	end

	if ShaderObjects.Depth then
		ShaderObjects.Depth.FarIntensity = 0.025 + 0.085 * alpha
		ShaderObjects.Depth.FocusDistance = 70
		ShaderObjects.Depth.InFocusRadius = 58 - 12 * alpha
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
		"ExposureCompensation",
		"Ambient",
		"OutdoorAmbient",
		"ColorShift_Top",
		"ColorShift_Bottom"
	}) do
		SaveLighting(property)
	end

	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.12
	Lighting.EnvironmentDiffuseScale = 0.78
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Brightness = math.max(Lighting.Brightness, 2.2)
	Lighting.ExposureCompensation = 0.05
	Lighting.Ambient = Color3.fromRGB(105, 94, 120)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 118, 144)
	Lighting.ColorShift_Top = Color3.fromRGB(10, 5, 14)
	Lighting.ColorShift_Bottom = Color3.fromRGB(5, 4, 8)

	ShaderObjects.Color = New("ColorCorrectionEffect", {
		Name = "KuromiColor",
		TintColor = Color3.fromRGB(241, 228, 255)
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
		Density = 0.16,
		Offset = 0.08,
		Color = Color3.fromRGB(218, 205, 233),
		Decay = Color3.fromRGB(93, 77, 111),
		Glare = 0.08,
		Haze = 0.42
	}, Lighting)

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("BasePart")
			and (object.Material == Enum.Material.Metal
				or object.Material == Enum.Material.Glass
				or object.Material == Enum.Material.DiamondPlate
				or object.Material == Enum.Material.Foil) then

			ShaderSaved.parts[object] = object.Reflectance

			if object.Material == Enum.Material.Glass then
				object.Reflectance = math.max(object.Reflectance, 0.22)
			elseif object.Material == Enum.Material.Metal then
				object.Reflectance = math.max(object.Reflectance, 0.14)
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
		end
	end

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect")
			and not string.find(effect.Name, "^Kuromi") then

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

local function ObjectCFrame(object)
	if not object then
		return nil
	end

	if object:IsA("BasePart") then
		return object.CFrame
	end

	if object:IsA("Attachment") then
		return object.WorldCFrame
	end

	if object:IsA("Model") then
		return object:GetPivot()
	end

	if object:IsA("Folder") then
		local part = object:FindFirstChildWhichIsA("BasePart", true)
		if part then
			return part.CFrame
		end

		local model = object:FindFirstChildWhichIsA("Model", true)
		if model then
			return model:GetPivot()
		end
	end

	return nil
end

local function FindTarget(kind)
	local aliases
	local tags
	local words

	if kind == "Map" then
		aliases = {
			"Game",
			"GameSpawn",
			"GameSpawnLocation",
			"GameTeleport",
			"Gameplay",
			"GameplaySpawn",
			"Map",
			"MapSpawn",
			"MapSpawnLocation",
			"MapTeleport",
			"Arena",
			"ArenaSpawn",
			"Match",
			"MatchSpawn",
			"RoundSpawn"
		}
		tags = {
			"GameSpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn"
		}
		words = {
			"game",
			"map",
			"arena",
			"match",
			"round"
		}
	else
		aliases = {
			"Lobby",
			"LobbySpawn",
			"LobbySpawnLocation",
			"LobbyTeleport",
			"Hub",
			"HubSpawn",
			"WaitingRoom",
			"WaitingSpawn"
		}
		tags = {
			"LobbySpawn",
			"HubSpawn"
		}
		words = {
			"lobby",
			"hub",
			"waiting"
		}
	end

	for _, tag in ipairs(tags) do
		for _, object in ipairs(CollectionService:GetTagged(tag)) do
			local cf = ObjectCFrame(object)
			if cf then
				return cf
			end
		end
	end

	for _, name in ipairs(aliases) do
		local object = Workspace:FindFirstChild(name, true)
		local cf = ObjectCFrame(object)
		if cf then
			return cf
		end
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		local destination = object:GetAttribute("Destination")
			or object:GetAttribute("Teleport")
			or object:GetAttribute("Zone")

		if destination then
			local lower = string.lower(tostring(destination))
			for _, word in ipairs(words) do
				if string.find(lower, word, 1, true) then
					local cf = ObjectCFrame(object)
					if cf then
						return cf
					end
				end
			end
		end
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		local lower = string.lower(object.Name)

		for _, word in ipairs(words) do
			if string.find(lower, word, 1, true) then
				local cf = ObjectCFrame(object)
				if cf then
					return cf
				end
			end
		end
	end

	return nil
end

local function TeleportLocal(kind, button)
	local cf = FindTarget(kind)
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if cf and root then
		root.CFrame = cf + Vector3.new(0, 4, 0)
		return true
	end

	local old = button.Text
	button.Text = string.upper(kind) .. " TARGET NOT FOUND"

	task.delay(1.2, function()
		if button and button.Parent then
			button.Text = old
		end
	end)

	return false
end

local function ApplyBackgroundSettings()
	local brightness = math.clamp(State.backgroundBrightness / 100, 0, 1)
	local value = 0.34 + brightness * 0.66
	BackgroundImage.ImageColor3 = Color3.new(value, value, value)

	if State.menuVisible and State.backgroundBlur > 0 then
		BlurEffect.Enabled = true
		BlurEffect.Size = math.floor((State.backgroundBlur / 100) * 24 + 0.5)
	else
		BlurEffect.Enabled = false
		BlurEffect.Size = 0
	end
end

Section(InfoPage, "Kuromi Hub", "Interface information", 1)

local InfoCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 116),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, InfoPage)
Corner(InfoCard, 9)

local InfoIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(58, 58),
	Position = UDim2.fromOffset(14, 16),
	BackgroundTransparency = 1,
	Image = "rbxassetid://95904040684372",
	ImageColor3 = Theme.White,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -100, 0, 24),
	Position = UDim2.fromOffset(88, 16),
	BackgroundTransparency = 1,
	Text = "KUROMI HUB!",
	TextColor3 = Theme.White,
	TextSize = 16,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -100, 0, 18),
	Position = UDim2.fromOffset(88, 44),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName .. "  |  @" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

local InfoFps = New("TextLabel", {
	Size = UDim2.new(1, -100, 0, 18),
	Position = UDim2.fromOffset(88, 67),
	BackgroundTransparency = 1,
	Text = "FPS 0",
	TextColor3 = Theme.Pink,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

Section(MainPage, "Main", "Session actions", 1)

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

local MapButton
MapButton = ActionButton(MainPage, "TELEPORT TO MAP", 3, function()
	if not FireServer("Teleport", "Map") then
		TeleportLocal("Map", MapButton)
	end
end)

local LobbyButton
LobbyButton = ActionButton(MainPage, "TELEPORT TO LOBBY", 4, function()
	if not FireServer("Teleport", "Lobby") then
		TeleportLocal("Lobby", LobbyButton)
	end
end)

Section(PlayerPage, "Player", "Local character controls", 1)

CreateToggle(PlayerPage, {
	id = "antiFling",
	title = "Anti-Fling",
	subtitle = "Velocity and collision protection",
	order = 2
})

CreateToggle(PlayerPage, {
	id = "noclip",
	title = "Noclip",
	subtitle = "Disable character collision",
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
	subtitle = "Replicated when the server helper is installed",
	order = 4,
	changed = function(enabled)
		local replicated = FireServer("Invisible", enabled)

		if replicated then
			RestoreLocalInvisible()
		elseif enabled then
			ApplyLocalInvisible()
		else
			RestoreLocalInvisible()
		end
	end
})

local WalkRow = CreateToggle(PlayerPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "Editable movement speed",
	order = 5,
	height = 100,
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

CreateSlider(WalkRow, 76, 1, 25, State.walkSpeedValue, function(value)
	State.walkSpeedValue = value

	if State.walkSpeed then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end
end, false)

Section(VisualPage, "Visual", "Player visibility", 1)

CreateToggle(VisualPage, {
	id = "esp",
	title = "Players ESP",
	subtitle = "Name and distance, colorized by class, tag or team",
	order = 2
})

Section(GraphicsPage, "Graphics", "Lighting and performance", 1)

local ShaderRow = CreateToggle(GraphicsPage, {
	id = "shaders",
	title = "Enhanced Shaders",
	subtitle = "Reflections, shadows, lighting and atmosphere",
	order = 2,
	height = 100,
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

CreateSlider(ShaderRow, 76, 0, 100, State.shaderStrength, function(value)
	State.shaderStrength = value
	if State.shaders then
		ApplyShaderStrength()
	end
end, true)

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "Reduce materials, particles and post effects",
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

Section(SettingsPage, "Settings", "Interface configuration", 1)

local BlurRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.16,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, SettingsPage)
Corner(BlurRow, 9)

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
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.16,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, SettingsPage)
Corner(BrightnessRow, 9)

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
	Text = "Brightness of the fixed panel artwork",
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

local PanelShortcutButton = ShortcutRow(
	SettingsPage,
	"Panel Shortcut",
	"Shortcut used to open and close the menu",
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

local FpsShortcutButton = ShortcutRow(
	SettingsPage,
	"FPS Shortcut",
	"Shortcut used to show or hide the FPS HUD",
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
	Size = UDim2.fromOffset(220, 36),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Active = true,
	GroupTransparency = 1,
	ZIndex = 700
}, ScreenGui)
Corner(StatusHud, 9)

local HudScale = New("UIScale", {
	Scale = 0.95
}, StatusHud)

local HudIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(20, 20),
	Position = UDim2.fromOffset(10, 8),
	BackgroundTransparency = 1,
	Image = "rbxassetid://95904040684372",
	ImageColor3 = Theme.White,
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
	Size = UDim2.fromOffset(64, 18),
	Position = UDim2.new(1, -74, 0, 9),
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
local HudAnimationId = 0

local function SetMenuVisible(visible)
	MenuAnimationId += 1
	local id = MenuAnimationId

	State.menuVisible = visible

	if visible then
		Main.Visible = true
		Main.GroupTransparency = 1
		MainScale.Scale = 0.965
		BackgroundImage.ImageTransparency = 0.62

		ApplyBackgroundSettings()

		Tween(MainScale, 0.38, {
			Scale = 1
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Main, 0.26, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		Tween(BackgroundImage, 0.42, {
			ImageTransparency = 0.32
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		Tween(MainScale, 0.24, {
			Scale = 0.975
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		Tween(BackgroundImage, 0.2, {
			ImageTransparency = 0.58
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.22, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		BlurEffect.Enabled = false
		BlurEffect.Size = 0

		fade.Completed:Once(function()
			if id == MenuAnimationId and not State.menuVisible then
				Main.Visible = false
			end
		end)
	end
end

local function SetFpsVisible(visible)
	HudAnimationId += 1
	local id = HudAnimationId

	State.fpsVisible = visible

	if visible then
		StatusHud.Visible = true
		StatusHud.GroupTransparency = 1
		HudScale.Scale = 0.95

		Tween(HudScale, 0.28, {
			Scale = 1
		}, Enum.EasingStyle.Quint)

		Tween(StatusHud, 0.2, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine)
	else
		Tween(HudScale, 0.18, {
			Scale = 0.97
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		local tween = Tween(StatusHud, 0.17, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		tween.Completed:Once(function()
			if id == HudAnimationId and not State.fpsVisible then
				StatusHud.Visible = false
			end
		end)
	end
end

Bind(UserInputService.InputBegan, function(input, gameProcessed)
	if Capture then
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == Enum.KeyCode.Escape then

			if Capture.type == "toggle" then
				Capture.button.Text = FormatBinding(Hotkeys[Capture.id])
			else
				Capture.button.Text = FormatBinding(Capture.get())
			end

			Capture.button.TextColor3 = Theme.Muted
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
		if SimpleBindingMatches(binding, input) then
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

	if State.invisible and not GetRemote() then
		ApplyLocalInvisible()
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

local frames = 0
local elapsed = 0
local animationTime = 0

Bind(RunService.RenderStepped, function(deltaTime)
	frames += 1
	elapsed += deltaTime
	animationTime += deltaTime

	local driftX = math.sin(animationTime * 0.17) * 0.004
	local driftY = math.cos(animationTime * 0.13) * 0.003
	BackgroundImage.Position = UDim2.fromScale(0.5 + driftX, 0.5 + driftY)

	if elapsed >= 0.5 then
		local fps = math.floor((frames / elapsed) + 0.5)
		local text = "FPS " .. tostring(fps)

		FpsLabel.Text = text
		InfoFps.Text = text

		frames = 0
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
	RestoreLocalInvisible()

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = State.walkSpeedValue
		end

		if State.invisible then
			task.wait(0.2)

			if not FireServer("Invisible", true) then
				ApplyLocalInvisible()
			end
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
	end
end)

local function Cleanup()
	if Destroyed then
		return
	end

	Destroyed = true
	Capture = nil

	pcall(function()
		FireServer("Invisible", false)
	end)

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
	RestoreLocalInvisible()
	ClearEsp()
	DisableShaders()
	DisableLowGraphics()

	if BlurEffect and BlurEffect.Parent then
		BlurEffect:Destroy()
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

task.spawn(function()
	IntroIcon.Position = UDim2.new(0.5, 0, 0.33, 15)
	IntroTitle.Position = UDim2.new(0.5, 0, 0.68, 12)

	Tween(IntroScale, 0.48, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroIcon, 0.34, {
		ImageTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.33, 0)
	}, Enum.EasingStyle.Quint)

	task.wait(0.08)

	Tween(IntroTitle, 0.34, {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.68, 0)
	}, Enum.EasingStyle.Quint)

	Tween(IntroLine, 0.48, {
		Size = UDim2.fromOffset(220, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.55)

	local introFade = Tween(Intro, 0.34, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	Tween(IntroScale, 0.34, {
		Scale = 1.025
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	introFade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.965
	BackgroundImage.ImageTransparency = 0.7

	Tween(MainScale, 0.46, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(Main, 0.3, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Sine)

	Tween(BackgroundImage, 0.5, {
		ImageTransparency = 0.32
	}, Enum.EasingStyle.Quint)

	StatusHud.GroupTransparency = 1
	HudScale.Scale = 0.95

	task.wait(0.08)

	Tween(HudScale, 0.28, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(StatusHud, 0.2, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Sine)

	ApplyBackgroundSettings()
end)

