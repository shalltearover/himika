if _G.LostHubCleanup then
	pcall(_G.LostHubCleanup)
	_G.LostHubCleanup = nil
end

_G.LostHubExecutionCount = (_G.LostHubExecutionCount or 0) + 1

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
local Camera = Workspace.CurrentCamera

local BACKGROUND_ASSET_ID = 10039618753
local HUB_ICON_ASSET_ID = 11878291148

local OldGui = PlayerGui:FindFirstChild("LostHub")
if OldGui then
	OldGui:Destroy()
end

for _, name in ipairs({
	"LostHubColor",
	"LostHubBloom",
	"LostHubSun",
	"LostHubDepth",
	"LostHubAtmosphere"
}) do
	local object = Lighting:FindFirstChild(name)
	if object then
		object:Destroy()
	end
end

local Theme = {
	Base = Color3.fromRGB(5, 6, 8),
	Surface = Color3.fromRGB(11, 12, 15),
	Surface2 = Color3.fromRGB(16, 18, 22),
	Surface3 = Color3.fromRGB(22, 24, 29),
	Surface4 = Color3.fromRGB(29, 31, 37),
	White = Color3.fromRGB(242, 243, 246),
	Light = Color3.fromRGB(205, 208, 214),
	Muted = Color3.fromRGB(139, 143, 151),
	Muted2 = Color3.fromRGB(91, 95, 103),
	Black = Color3.fromRGB(1, 2, 3),
	Off = Color3.fromRGB(45, 48, 55),
	Purple = Color3.fromRGB(127, 88, 196),
	PurpleBright = Color3.fromRGB(159, 111, 235),
	PurpleSoft = Color3.fromRGB(82, 61, 119),
	Red = Color3.fromRGB(231, 70, 82),
	ButtonStroke = Color3.fromRGB(59, 62, 69)
}

local State = {
	antiFling = false,
	noclip = false,
	walkSpeed = false,
	speedManipulation = false,
	fly = false,
	playerEsp = false,
	objectiveEsp = false,
	itemEsp = false,
	entityEsp = false,
	instantInteract = false,
	graphicsEnhancement = false,
	lowGraphics = false,
	fullBright = false,
	fpsVisible = false,
	walkSpeedValue = 16,
	flySpeed = 30,
	graphicsStrength = 60,
	panelBlur = 0,
	backgroundBrightness = 55,
	menuVisible = true
}

local Bindings = {
	antiFling = nil,
	noclip = nil,
	walkSpeed = nil,
	speedManipulation = {
		kind = "KeyCode",
		value = Enum.KeyCode.V
	},
	fly = nil,
	playerEsp = nil,
	objectiveEsp = nil,
	itemEsp = nil,
	entityEsp = nil,
	instantInteract = nil,
	graphicsEnhancement = nil,
	lowGraphics = nil,
	fullBright = nil,
	fpsVisible = {
		kind = "KeyCode",
		value = Enum.KeyCode.F4
	}
}

local PanelShortcut = {
	kind = "KeyCode",
	value = Enum.KeyCode.M,
	ctrl = true,
	shift = false,
	alt = false
}

local Connections = {}
local ToggleSetters = {}
local HotkeyButtons = {}
local Capture = nil
local Destroyed = false

local SavedLocalCollision = {}
local SavedOtherCollision = {}
local SavedWalkSpeed = nil
local LastSafeCFrame = nil

local SpeedManipSavedCollision = {}
local SpeedManipSavedSpeed = nil

local PlayerEspObjects = {}
local WorldEspObjects = {
	Objective = {},
	Item = {},
	Entity = {}
}

local InstantSaved = {}

local GraphicsObjects = {}
local GraphicsSaved = {
	lighting = {},
	objects = {}
}

local LowSaved = {
	lighting = {},
	objects = {}
}

local FullBrightSaved = {}

local FlyVelocity = nil
local FlyGyro = nil

local PreviousMouseBehavior = Enum.MouseBehavior.Default
local PreviousMouseIconEnabled = true

local ProfilePanelOpen = false
local SetFpsVisible
local RefreshProfilePanel

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
	return "rbxthumb://type=Asset&id="
		.. tostring(assetId)
		.. "&w=420&h=420"
end

local function GetModifiers()
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

		table.insert(
			parts,
			aliases[binding.value.Name]
				or string.upper(binding.value.Name)
		)
	end

	return table.concat(parts, " + ")
end

local function BindingMatches(binding, input, modifiersMatter)
	if not binding then
		return false
	end

	if modifiersMatter then
		local modifiers = GetModifiers()

		if (binding.ctrl or false) ~= modifiers.ctrl then
			return false
		end

		if (binding.shift or false) ~= modifiers.shift then
			return false
		end

		if (binding.alt or false) ~= modifiers.alt then
			return false
		end
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

local function FocusedTextBox()
	return UserInputService:GetFocusedTextBox() ~= nil
end

local ScreenGui = New("ScreenGui", {
	Name = "LostHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 2147483647,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

local Intro = New("CanvasGroup", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 2000
}, ScreenGui)

local IntroScale = New("UIScale", {
	Scale = 0.94
}, Intro)

local IntroIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(72, 72),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.44, 12),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ImageTransparency = 1,
	ZIndex = 2001
}, Intro)

local IntroTitle = New("TextLabel", {
	Size = UDim2.fromOffset(500, 42),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.58, 12),
	BackgroundTransparency = 1,
	Text = "LOST HUB",
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
	BackgroundColor3 = Theme.Purple,
	BorderSizePixel = 0,
	ZIndex = 2001
}, Intro)

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(850, 555),
	Position = UDim2.new(0.5, -425, 0.5, -278),
	BackgroundColor3 = Theme.Base,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 12)

local MainScale = New("UIScale", {
	Scale = 0.96
}, Main)

local Background = New("ImageLabel", {
	Size = UDim2.fromScale(1.05, 1.05),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(BACKGROUND_ASSET_ID),
	ImageTransparency = 0.32,
	ImageColor3 = Color3.fromRGB(185, 185, 185),
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 20
}, Main)

local BlurLayers = {}

for _, offset in ipairs({
	Vector2.new(-3, 0),
	Vector2.new(3, 0),
	Vector2.new(0, -3),
	Vector2.new(0, 3),
	Vector2.new(-2, -2),
	Vector2.new(2, 2)
}) do
	local layer = New("ImageLabel", {
		Size = UDim2.fromScale(1.05, 1.05),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, offset.X, 0.5, offset.Y),
		BackgroundTransparency = 1,
		Image = AssetThumbnail(BACKGROUND_ASSET_ID),
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(185, 185, 185),
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 20
	}, Main)

	table.insert(BlurLayers, {
		image = layer,
		offset = offset
	})
end

local BackgroundShade = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Base,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 78),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)

local HubIconBox = New("Frame", {
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.fromOffset(18, 17),
	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
	ZIndex = 51
}, TopBar)
Corner(HubIconBox, 10)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(34, 34),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 52
}, HubIconBox)

local HubTitle = New("TextLabel", {
	Size = UDim2.fromOffset(260, 24),
	Position = UDim2.fromOffset(76, 17),
	BackgroundTransparency = 1,
	Text = "LOST HUB",
	TextColor3 = Theme.White,
	TextSize = 18,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51
}, TopBar)

local HubSub = New("TextLabel", {
	Size = UDim2.fromOffset(310, 18),
	Position = UDim2.fromOffset(77, 42),
	BackgroundTransparency = 1,
	Text = "dark utility interface",
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
	BorderSizePixel = 0,
	Text = "CTRL + M",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.GothamBold,
	ZIndex = 51
}, TopBar)
Corner(ShortcutChip, 8)
Stroke(ShortcutChip, 0.6, 1, Theme.ButtonStroke)

local Sidebar = New("Frame", {
	Size = UDim2.new(0, 184, 1, -78),
	Position = UDim2.fromOffset(0, 78),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	ZIndex = 45
}, Main)

local SidebarSeparator = New("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = Theme.Surface4,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 46
}, Sidebar)

local TabsHolder = New("Frame", {
	Size = UDim2.new(1, 0, 1, -76),
	BackgroundTransparency = 1,
	ZIndex = 46
}, Sidebar)
Padding(TabsHolder, 11, 11, 14, 8)

New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, TabsHolder)

local Profile = New("TextButton", {
	Size = UDim2.new(1, -22, 0, 60),
	Position = UDim2.new(0, 11, 1, -66),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.24,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 46
}, Sidebar)
Corner(Profile, 9)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.fromOffset(9, 12),
	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 47
}, Profile)
Corner(Avatar, 9)

local ProfileName = New("TextLabel", {
	Size = UDim2.new(1, -56, 0, 17),
	Position = UDim2.fromOffset(53, 11),
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
	Size = UDim2.new(1, -56, 0, 15),
	Position = UDim2.fromOffset(53, 30),
	BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name,
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	ZIndex = 47
}, Profile)

local UsernameCover = New("Frame", {
	Size = UDim2.new(1, -64, 0, 10),
	Position = UDim2.fromOffset(55, 33),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = 48
}, Profile)
Corner(UsernameCover, 3)

Bind(Profile.MouseEnter, function()
	Tween(UsernameCover, 0.16, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 10)
	}, Enum.EasingStyle.Quart)
end)

Bind(Profile.MouseLeave, function()
	Tween(UsernameCover, 0.16, {
		BackgroundTransparency = 0,
		Size = UDim2.new(1, -64, 0, 10)
	}, Enum.EasingStyle.Quart)
end)

local Content = New("Frame", {
	Size = UDim2.new(1, -184, 1, -78),
	Position = UDim2.fromOffset(184, 78),
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
			BackgroundTransparency = selected and 0.08 or 1,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)

		Tween(data.marker, 0.15, {
			BackgroundTransparency = selected and 0 or 1,
			Size = selected and UDim2.fromOffset(3, 20)
				or UDim2.fromOffset(3, 5)
		}, Enum.EasingStyle.Quad)
	end
end

local function CreateTab(name, order)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
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
		Size = UDim2.fromOffset(3, 5),
		Position = UDim2.new(0, 7, 0.5, -2),
		BackgroundColor3 = Theme.PurpleBright,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 48
	}, button)
	Corner(marker, 2)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.12, {
			Scale = 1.015
		}, Enum.EasingStyle.Quad)

		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 0.48,
				TextColor3 = Theme.White
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseLeave, function()
		Tween(scale, 0.12, {
			Scale = 1
		}, Enum.EasingStyle.Quad)

		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 1,
				TextColor3 = Theme.Muted
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.06, {
			Scale = 0.985
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {
			Scale = 1.015
		}, Enum.EasingStyle.Quad)
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
local HotkeysPage = CreatePage("Hotkeys")
local SettingsPage = CreatePage("Settings")

CreateTab("Info", 1)
CreateTab("Main", 2)
CreateTab("Player", 3)
CreateTab("Visual", 4)
CreateTab("Graphics", 5)
CreateTab("Hotkeys", 6)
CreateTab("Settings", 7)

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

local function NoteCard(parent, title, body, order)
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(card, 9)

	local marker = New("Frame", {
		Size = UDim2.fromOffset(3, 34),
		Position = UDim2.fromOffset(13, 18),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 47
	}, card)
	Corner(marker, 2)

	New("TextLabel", {
		Size = UDim2.new(1, -40, 0, 18),
		Position = UDim2.fromOffset(27, 12),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, card)

	New("TextLabel", {
		Size = UDim2.new(1, -40, 0, 32),
		Position = UDim2.fromOffset(27, 31),
		BackgroundTransparency = 1,
		Text = body,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 47
	}, card)

	return card
end

local function ActionButton(parent, text, subtitle, order, callback)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(button, 9)
	Stroke(button, 0.5, 1, Theme.ButtonStroke)

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 47
	}, button)
	Corner(overlay, 9)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(3, 26),
		Position = UDim2.fromOffset(12, 14),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 48
	}, button)
	Corner(accent, 2)

	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, -48, 0, 18),
		Position = UDim2.fromOffset(27, 9),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 49
	}, button)

	local subtitleLabel = New("TextLabel", {
		Size = UDim2.new(1, -48, 0, 15),
		Position = UDim2.fromOffset(27, 29),
		BackgroundTransparency = 1,
		Text = subtitle or "",
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 49
	}, button)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(overlay, 0.14, {
			BackgroundTransparency = 0.88
		}, Enum.EasingStyle.Quad)

		Tween(scale, 0.14, {
			Scale = 1.006
		}, Enum.EasingStyle.Quad)

		Tween(accent, 0.14, {
			BackgroundColor3 = Theme.PurpleBright
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(overlay, 0.14, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quad)

		Tween(scale, 0.14, {
			Scale = 1
		}, Enum.EasingStyle.Quad)

		Tween(accent, 0.14, {
			BackgroundColor3 = Theme.Purple
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.06, {
			Scale = 0.987
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.09, {
			Scale = 1.006
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, callback)

	return {
		button = button,
		title = titleLabel,
		subtitle = subtitleLabel
	}
end

local function CreateToggle(parent, config)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 64),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 46
	}, parent)
	Corner(row, 9)

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 46
	}, row)
	Corner(overlay, 9)

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
		Size = UDim2.new(1, -110, 0, 18),
		Position = UDim2.fromOffset(26, 11),
		BackgroundTransparency = 1,
		Text = config.title,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 48
	}, row)

	if config.subtitle then
		New("TextLabel", {
			Size = UDim2.new(1, -110, 0, 16),
			Position = UDim2.fromOffset(26, 32),
			BackgroundTransparency = 1,
			Text = config.subtitle,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 48
		}, row)
	end

	local switch = New("TextButton", {
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -58, 0.5, -12),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 49
	}, row)
	Corner(switch, 12)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 50
	}, switch)
	Corner(knob, 9)

	local function Apply(enabled)
		Tween(switch, 0.16, {
			BackgroundColor3 = enabled and Theme.Purple or Theme.Off
		}, Enum.EasingStyle.Quad)

		Tween(knob, 0.16, {
			Position = enabled and UDim2.fromOffset(25, 3)
				or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Quad)

		Tween(accent, 0.16, {
			BackgroundColor3 = enabled
				and Theme.PurpleBright
				or Theme.Purple,
			BackgroundTransparency = enabled and 0 or 0.55
		}, Enum.EasingStyle.Quad)
	end

	local function Set(enabled)
		State[config.id] = enabled
		Apply(enabled)

		if config.changed then
			config.changed(enabled)
		end

		if RefreshProfilePanel then
			RefreshProfilePanel()
		end
	end

	ToggleSetters[config.id] = Set

	Bind(row.MouseEnter, function()
		Tween(overlay, 0.12, {
			BackgroundTransparency = 0.72
		}, Enum.EasingStyle.Quad)
	end)

	Bind(row.MouseLeave, function()
		Tween(overlay, 0.12, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quad)
	end)

	Bind(switch.MouseButton1Click, function()
		Set(not State[config.id])
	end)

	Apply(false)
	return row
end

local function CreateSlider(
	row,
	y,
	minimum,
	maximum,
	initial,
	callback,
	percent
)
	local current = initial
	local dragging = false

	local valueBox = New("TextBox", {
		Size = UDim2.fromOffset(66, 28),
		Position = UDim2.new(1, -80, 0, y - 14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = tostring(initial) .. (percent and "%" or ""),
		TextColor3 = Theme.White,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 54
	}, row)
	Corner(valueBox, 7)
	Stroke(valueBox, 0.65, 1, Theme.ButtonStroke)

	local track = New("Frame", {
		Size = UDim2.new(1, -140, 0, 4),
		Position = UDim2.fromOffset(26, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		ZIndex = 50
	}, row)
	Corner(track, 2)

	local alpha = (initial - minimum) / (maximum - minimum)

	local fill = New("Frame", {
		Size = UDim2.fromScale(alpha, 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 51
	}, track)
	Corner(fill, 2)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(alpha, 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 52
	}, track)
	Corner(knob, 7)

	local hitbox = New("TextButton", {
		Size = UDim2.new(1, -124, 0, 30),
		Position = UDim2.fromOffset(18, y - 15),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		ZIndex = 53
	}, row)

	local function ParseValue(text)
		local cleaned = tostring(text):gsub(",", ".")
		local numberText = cleaned:match("%-?%d+%.?%d*")

		return tonumber(numberText)
	end

	local function SetValue(value)
		local numeric = tonumber(value)

		if not numeric then
			numeric = current
		end

		numeric = math.clamp(numeric, minimum, maximum)

		if math.floor(minimum) == minimum
			and math.floor(maximum) == maximum then

			numeric = math.floor(numeric + 0.5)
		end

		current = numeric

		local newAlpha = (numeric - minimum) / (maximum - minimum)

		fill.Size = UDim2.fromScale(newAlpha, 1)
		knob.Position = UDim2.new(newAlpha, 0, 0.5, 0)

		if math.floor(numeric) == numeric then
			valueBox.Text = tostring(math.floor(numeric))
				.. (percent and "%" or "")
		else
			valueBox.Text = string.format("%.1f", numeric)
				.. (percent and "%" or "")
		end

		callback(numeric)
	end

	local function SetFromX(x)
		if track.AbsoluteSize.X <= 0 then
			return
		end

		local newAlpha = math.clamp(
			(x - track.AbsolutePosition.X)
				/ track.AbsoluteSize.X,
			0,
			1
		)

		SetValue(
			minimum
				+ ((maximum - minimum) * newAlpha)
		)
	end

	Bind(hitbox.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetFromX(input.Position.X)

			Tween(knob, 0.1, {
				Size = UDim2.fromOffset(17, 17)
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			SetFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false

			Tween(knob, 0.1, {
				Size = UDim2.fromOffset(14, 14)
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(valueBox.Focused, function()
		valueBox.Text = tostring(current)
		valueBox.CursorPosition = #valueBox.Text + 1
	end)

	Bind(valueBox.FocusLost, function()
		local parsed = ParseValue(valueBox.Text)
		SetValue(parsed or current)
	end)

	SetValue(initial)

	return {
		Set = SetValue,
		Box = valueBox
	}
end

local function CreateHotkeyRow(
	parent,
	id,
	title,
	subtitle,
	order,
	mode,
	isPanelShortcut
)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(row, 9)

	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 18),
		Position = UDim2.fromOffset(14, 11),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 16),
		Position = UDim2.fromOffset(14, 31),
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	local function CurrentBinding()
		if isPanelShortcut then
			return PanelShortcut
		end

		return Bindings[id]
	end

	local button = New("TextButton", {
		Size = UDim2.fromOffset(128, 30),
		Position = UDim2.new(1, -142, 0.5, -15),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(CurrentBinding()),
		TextColor3 = Theme.White,
		TextSize = 8,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(button, 7)
	Stroke(button, 0.5, 1, Theme.ButtonStroke)

	HotkeyButtons[id or "panel"] = button

	Bind(button.MouseButton1Click, function()
		Capture = {
			type = isPanelShortcut and "panel" or "action",
			id = id,
			button = button,
			mode = mode
		}

		button.Text = "PRESS KEY"
		button.TextColor3 = Theme.PurpleBright
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

local function StopSpeedManipulation()
	if not State.speedManipulation then
		return
	end

	State.speedManipulation = false

	local character = LocalPlayer.Character
	local humanoid = character
		and character:FindFirstChildOfClass("Humanoid")

	if not State.noclip then
		for part, value in pairs(SpeedManipSavedCollision) do
			if part and part.Parent then
				part.CanCollide = value
			end
		end
	end

	table.clear(SpeedManipSavedCollision)

	if humanoid then
		if State.walkSpeed then
			humanoid.WalkSpeed = State.walkSpeedValue
		elseif SpeedManipSavedSpeed then
			humanoid.WalkSpeed = SpeedManipSavedSpeed
		end
	end

	SpeedManipSavedSpeed = nil

	if RefreshProfilePanel then
		RefreshProfilePanel()
	end
end

local function StartSpeedManipulation()
	if State.speedManipulation then
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character
		and character:FindFirstChildOfClass("Humanoid")

	if not character or not humanoid then
		return
	end

	State.speedManipulation = true
	SpeedManipSavedSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 5

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if SpeedManipSavedCollision[object] == nil then
				SpeedManipSavedCollision[object] = object.CanCollide
			end

			object.CanCollide = false
		end
	end

	if RefreshProfilePanel then
		RefreshProfilePanel()
	end
end

local function DestroyFly()
	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyGyro then
		FlyGyro:Destroy()
		FlyGyro = nil
	end
end

local function CreateFly()
	DestroyFly()

	if not State.fly then
		return
	end

	local character = LocalPlayer.Character
	local root = character
		and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	FlyVelocity = New("BodyVelocity", {
		Name = "LostHubFlyVelocity",
		MaxForce = Vector3.new(1e9, 1e9, 1e9),
		P = 12500,
		Velocity = Vector3.zero
	}, root)

	FlyGyro = New("BodyGyro", {
		Name = "LostHubFlyGyro",
		MaxTorque = Vector3.new(1e9, 1e9, 1e9),
		P = 9000,
		D = 350,
		CFrame = root.CFrame
	}, root)
end

local function ClassificationSignature(player)
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

				if valueObject
					and valueObject:IsA("ValueBase") then

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

			if valueObject
				and valueObject:IsA("ValueBase") then

				Add(valueObject.Value)
			end
		end
	end

	if player.Team then
		Add("Team=" .. player.Team.Name)
	end

	table.sort(values)
	return table.concat(values, "|")
end

local function DifferentClassification(player)
	return ClassificationSignature(player)
		~= ClassificationSignature(LocalPlayer)
end

local function DestroyPlayerEsp(player)
	local data = PlayerEspObjects[player]

	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	PlayerEspObjects[player] = nil
end

local function EnsurePlayerEsp(player)
	if player == LocalPlayer then
		return
	end

	local character = player.Character

	if not character then
		DestroyPlayerEsp(player)
		return
	end

	local head = character:FindFirstChild("Head")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not head or not root then
		return
	end

	local different = DifferentClassification(player)
	local color = different and Theme.Red or Theme.PurpleBright
	local data = PlayerEspObjects[player]

	if data and data.character ~= character then
		DestroyPlayerEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "LostHubPlayerESP",
			Adornee = character,
			FillColor = color,
			FillTransparency = 0.72,
			OutlineColor = color,
			OutlineTransparency = 0.01,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = "LostHubPlayerESPLabel",
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
			TextStrokeColor3 = color,
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
			different = different
		}

		PlayerEspObjects[player] = data
	end

	if data.different ~= different then
		data.different = different
		data.highlight.FillColor = color
		data.highlight.OutlineColor = color
		data.label.TextStrokeColor3 = color
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter
		and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot then
		distance = math.floor(
			(localRoot.Position - root.Position).Magnitude + 0.5
		)
	end

	data.label.Text = player.DisplayName
		.. "  ·  "
		.. tostring(distance)
		.. "m"
end

local function ClearPlayerEsp()
	for player in pairs(PlayerEspObjects) do
		DestroyPlayerEsp(player)
	end
end

local function IsPlayerCharacter(object)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character
			and object:IsDescendantOf(player.Character) then

			return true
		end
	end

	return false
end

local function GetAdorneePart(object)
	if object:IsA("BasePart") then
		return object
	end

	if object:IsA("Model") then
		return object.PrimaryPart
			or object:FindFirstChild("HumanoidRootPart")
			or object:FindFirstChildWhichIsA("BasePart", true)
	end

	if object:IsA("Tool") then
		return object:FindFirstChild("Handle")
			or object:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function HasTag(object, tags)
	for _, tag in ipairs(tags) do
		if CollectionService:HasTag(object, tag) then
			return true
		end
	end

	return false
end

local function HasTruthyAttribute(object, names)
	for _, name in ipairs(names) do
		local value = object:GetAttribute(name)

		if value == true then
			return true
		end

		if typeof(value) == "string"
			and string.lower(value) == "true" then

			return true
		end
	end

	return false
end

local function AncestorNameContains(object, words)
	local current = object.Parent
	local depth = 0

	while current
		and current ~= Workspace
		and depth < 5 do

		local lower = string.lower(current.Name)

		for _, word in ipairs(words) do
			if string.find(lower, word, 1, true) then
				return true
			end
		end

		current = current.Parent
		depth += 1
	end

	return false
end

local function ClassifyWorldObject(object)
	if not (
		object:IsA("Model")
		or object:IsA("BasePart")
		or object:IsA("Tool")
	) then
		return nil
	end

	if IsPlayerCharacter(object) then
		return nil
	end

	local name = string.lower(object.Name)

	if HasTag(object, {
		"Objective",
		"Objectives",
		"Goal",
		"MissionObjective"
	})
		or HasTruthyAttribute(object, {
			"Objective",
			"IsObjective",
			"Goal"
		})
		or string.find(name, "objective", 1, true)
		or AncestorNameContains(object, {
			"objectives",
			"missions",
			"goals"
		}) then

		return "Objective"
	end

	if HasTag(object, {
		"Item",
		"Items",
		"Pickup",
		"Loot",
		"Collectible"
	})
		or HasTruthyAttribute(object, {
			"Item",
			"IsItem",
			"Pickup",
			"Loot"
		})
		or object:IsA("Tool")
		or AncestorNameContains(object, {
			"items",
			"loot",
			"pickups"
		}) then

		return "Item"
	end

	if HasTag(object, {
		"Entity",
		"Entities",
		"Enemy",
		"Monster"
	})
		or HasTruthyAttribute(object, {
			"Entity",
			"IsEntity",
			"Enemy",
			"Monster"
		})
		or string.find(name, "entity", 1, true)
		or string.find(name, "enemy", 1, true)
		or string.find(name, "monster", 1, true)
		or AncestorNameContains(object, {
			"entities",
			"enemies",
			"monsters"
		}) then

		return "Entity"
	end

	return nil
end

local WorldEspStyle = {
	Objective = {
		color = Theme.White,
		fill = 0.86
	},
	Item = {
		color = Color3.fromRGB(190, 194, 204),
		fill = 0.88
	},
	Entity = {
		color = Theme.Red,
		fill = 0.8
	}
}

local function WorldEspEnabled(kind)
	if kind == "Objective" then
		return State.objectiveEsp
	end

	if kind == "Item" then
		return State.itemEsp
	end

	if kind == "Entity" then
		return State.entityEsp
	end

	return false
end

local function DestroyWorldEsp(kind, object)
	local data = WorldEspObjects[kind][object]

	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	WorldEspObjects[kind][object] = nil
end

local function EnsureWorldEsp(object, forcedKind)
	if not object or not object.Parent then
		return
	end

	local kind = forcedKind or ClassifyWorldObject(object)

	if not kind or not WorldEspEnabled(kind) then
		return
	end

	local part = GetAdorneePart(object)

	if not part then
		return
	end

	if WorldEspObjects[kind][object] then
		return
	end

	local style = WorldEspStyle[kind]

	local highlight = New("Highlight", {
		Name = "LostHub" .. kind .. "ESP",
		Adornee = object,
		FillColor = style.color,
		FillTransparency = style.fill,
		OutlineColor = style.color,
		OutlineTransparency = 0.08,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	}, ScreenGui)

	local billboard = New("BillboardGui", {
		Name = "LostHub" .. kind .. "ESPLabel",
		Adornee = part,
		Size = UDim2.fromOffset(220, 26),
		StudsOffset = Vector3.new(0, 2.2, 0),
		AlwaysOnTop = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global
	}, ScreenGui)

	local label = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = object.Name,
		TextColor3 = style.color,
		TextStrokeColor3 = Theme.Black,
		TextStrokeTransparency = 0.3,
		TextSize = 10,
		Font = Enum.Font.GothamSemibold,
		ZIndex = 60
	}, billboard)

	WorldEspObjects[kind][object] = {
		highlight = highlight,
		billboard = billboard,
		label = label,
		part = part
	}
end

local function ClearWorldEsp(kind)
	for object in pairs(WorldEspObjects[kind]) do
		DestroyWorldEsp(kind, object)
	end
end

local function ScanWorldEsp(kind)
	if not WorldEspEnabled(kind) then
		return
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		if ClassifyWorldObject(object) == kind then
			EnsureWorldEsp(object, kind)
		end
	end
end

local function UpdateWorldEspDistances()
	local character = LocalPlayer.Character
	local root = character
		and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	for kind, objects in pairs(WorldEspObjects) do
		for object, data in pairs(objects) do
			if not object.Parent
				or not data.part
				or not data.part.Parent then

				DestroyWorldEsp(kind, object)
			else
				local distance = math.floor(
					(root.Position - data.part.Position).Magnitude + 0.5
				)

				data.label.Text = object.Name
					.. "  ·  "
					.. tostring(distance)
					.. "m"
			end
		end
	end
end

local function SaveLighting(property)
	if GraphicsSaved.lighting[property] == nil then
		GraphicsSaved.lighting[property] = Lighting[property]
	end
end

local function EnhanceObject(object)
	if GraphicsSaved.objects[object] then
		return
	end

	if object:IsA("BasePart")
		and (
			object.Material == Enum.Material.Metal
			or object.Material == Enum.Material.Glass
			or object.Material == Enum.Material.DiamondPlate
			or object.Material == Enum.Material.Foil
		) then

		GraphicsSaved.objects[object] = {
			type = "part",
			reflectance = object.Reflectance
		}

		if object.Material == Enum.Material.Glass then
			object.Reflectance = math.max(object.Reflectance, 0.2)
		elseif object.Material == Enum.Material.Metal then
			object.Reflectance = math.max(object.Reflectance, 0.13)
		else
			object.Reflectance = math.max(object.Reflectance, 0.09)
		end

	elseif object:IsA("PointLight")
		or object:IsA("SpotLight")
		or object:IsA("SurfaceLight") then

		GraphicsSaved.objects[object] = {
			type = "light",
			brightness = object.Brightness,
			range = object.Range,
			shadows = object.Shadows
		}

		object.Brightness = math.min(object.Brightness * 1.08, 8)
		object.Range = math.min(object.Range * 1.08, 80)
		object.Shadows = true
	end
end

local function ApplyGraphicsStrength()
	local alpha = State.graphicsStrength / 100

	if GraphicsObjects.Color then
		GraphicsObjects.Color.Brightness = 0.004 + 0.025 * alpha
		GraphicsObjects.Color.Contrast = 0.04 + 0.12 * alpha
		GraphicsObjects.Color.Saturation = 0.01 + 0.08 * alpha
	end

	if GraphicsObjects.Bloom then
		GraphicsObjects.Bloom.Intensity = 0.09 + 0.31 * alpha
		GraphicsObjects.Bloom.Size = 20 + 15 * alpha
		GraphicsObjects.Bloom.Threshold = 1.5 - 0.35 * alpha
	end

	if GraphicsObjects.Sun then
		GraphicsObjects.Sun.Intensity = 0.012 + 0.045 * alpha
		GraphicsObjects.Sun.Spread = 0.72 + 0.16 * alpha
	end

	if GraphicsObjects.Depth then
		GraphicsObjects.Depth.FarIntensity = 0.012 + 0.045 * alpha
		GraphicsObjects.Depth.FocusDistance = 72
		GraphicsObjects.Depth.InFocusRadius = 64 - 10 * alpha
	end

	if GraphicsObjects.Atmosphere then
		GraphicsObjects.Atmosphere.Density = 0.09 + 0.07 * alpha
		GraphicsObjects.Atmosphere.Haze = 0.14 + 0.22 * alpha
		GraphicsObjects.Atmosphere.Glare = 0.018 + 0.045 * alpha
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
	Lighting.ShadowSoftness = 0.12
	Lighting.EnvironmentDiffuseScale = 0.88
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Brightness = math.max(Lighting.Brightness, 2.15)
	Lighting.ExposureCompensation = 0.03
	Lighting.Ambient = Color3.fromRGB(105, 107, 114)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 130, 138)
	Lighting.ColorShift_Top = Color3.fromRGB(5, 4, 8)
	Lighting.ColorShift_Bottom = Color3.fromRGB(2, 2, 4)

	GraphicsObjects.Color = New("ColorCorrectionEffect", {
		Name = "LostHubColor",
		TintColor = Color3.fromRGB(241, 239, 246)
	}, Lighting)

	GraphicsObjects.Bloom = New("BloomEffect", {
		Name = "LostHubBloom"
	}, Lighting)

	GraphicsObjects.Sun = New("SunRaysEffect", {
		Name = "LostHubSun"
	}, Lighting)

	GraphicsObjects.Depth = New("DepthOfFieldEffect", {
		Name = "LostHubDepth",
		NearIntensity = 0
	}, Lighting)

	GraphicsObjects.Atmosphere = New("Atmosphere", {
		Name = "LostHubAtmosphere",
		Color = Color3.fromRGB(215, 216, 222),
		Decay = Color3.fromRGB(95, 97, 106),
		Offset = 0.04
	}, Lighting)

	for _, object in ipairs(Workspace:GetDescendants()) do
		EnhanceObject(object)
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

	for object, saved in pairs(GraphicsSaved.objects) do
		if object and object.Parent then
			if saved.type == "part" then
				object.Reflectance = saved.reflectance
			elseif saved.type == "light" then
				object.Brightness = saved.brightness
				object.Range = saved.range
				object.Shadows = saved.shadows
			end
		end
	end

	GraphicsSaved = {
		lighting = {},
		objects = {}
	}
end

local function ApplyLowToObject(object)
	if LowSaved.objects[object] then
		return
	end

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

local function EnableLowGraphics()
	if LowSaved.lighting.GlobalShadows ~= nil then
		return
	end

	LowSaved.lighting.GlobalShadows = Lighting.GlobalShadows
	LowSaved.lighting.EnvironmentDiffuseScale =
		Lighting.EnvironmentDiffuseScale
	LowSaved.lighting.EnvironmentSpecularScale =
		Lighting.EnvironmentSpecularScale

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(Workspace:GetDescendants()) do
		ApplyLowToObject(object)
	end

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect")
			and not string.find(effect.Name, "^LostHub") then

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
		Lighting.GlobalShadows =
			LowSaved.lighting.GlobalShadows
	end

	if LowSaved.lighting.EnvironmentDiffuseScale ~= nil then
		Lighting.EnvironmentDiffuseScale =
			LowSaved.lighting.EnvironmentDiffuseScale
	end

	if LowSaved.lighting.EnvironmentSpecularScale ~= nil then
		Lighting.EnvironmentSpecularScale =
			LowSaved.lighting.EnvironmentSpecularScale
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

local function EnableFullBright()
	if next(FullBrightSaved) then
		return
	end

	for _, property in ipairs({
		"Ambient",
		"OutdoorAmbient",
		"Brightness",
		"ExposureCompensation",
		"FogEnd"
	}) do
		FullBrightSaved[property] = Lighting[property]
	end

	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	Lighting.Brightness = math.max(Lighting.Brightness, 2.5)
	Lighting.ExposureCompensation = 0.15
	Lighting.FogEnd = 100000
end

local function DisableFullBright()
	for property, value in pairs(FullBrightSaved) do
		pcall(function()
			Lighting[property] = value
		end)
	end

	table.clear(FullBrightSaved)
end

local function EnableInstantInteract()
	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("ProximityPrompt") then
			if InstantSaved[object] == nil then
				InstantSaved[object] = object.HoldDuration
			end

			object.HoldDuration = 0
		end
	end
end

local function DisableInstantInteract()
	for prompt, duration in pairs(InstantSaved) do
		if prompt and prompt.Parent then
			prompt.HoldDuration = duration
		end
	end

	table.clear(InstantSaved)
end

local function GetPlaceId(kind)
	local names

	if kind == "Game" then
		names = {
			"GamePlaceId",
			"GameplayPlaceId",
			"MapPlaceId"
		}
	else
		names = {
			"LobbyPlaceId",
			"HubPlaceId"
		}
	end

	for _, source in ipairs({
		game,
		Workspace,
		ReplicatedStorage
	}) do
		for _, name in ipairs(names) do
			local value = source:GetAttribute(name)

			if typeof(value) == "number"
				and value > 0 then

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

	return nil
end

local function SpawnCFrame(object)
	if not object then
		return nil
	end

	if object:IsA("SpawnLocation")
		or object:IsA("BasePart") then

		return object.CFrame
	end

	if object:IsA("Attachment") then
		return object.WorldCFrame
	end

	return nil
end

local function FindSpawnInside(container, kind)
	if not container then
		return nil
	end

	local names

	if kind == "Game" then
		names = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn",
			"RoundSpawn",
			"SpawnLocation",
			"Spawn",
			"StartPoint",
			"Start",
			"Entrance"
		}
	else
		names = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn",
			"SpawnLocation",
			"Spawn",
			"StartPoint",
			"Start",
			"Entrance"
		}
	end

	for _, name in ipairs(names) do
		local object = container:FindFirstChild(name, true)
		local cf = SpawnCFrame(object)

		if cf then
			return cf
		end
	end

	local spawn = container:FindFirstChildWhichIsA(
		"SpawnLocation",
		true
	)

	if spawn then
		return spawn.CFrame
	end

	return nil
end

local function FindDestinationSpawn(kind)
	local tagged
	local containers
	local direct

	if kind == "Game" then
		tagged = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn"
		}

		containers = {
			"Game",
			"Gameplay",
			"Map",
			"Arena",
			"Match"
		}

		direct = {
			"GameSpawn",
			"GameplaySpawn",
			"MapSpawn",
			"ArenaSpawn",
			"MatchSpawn",
			"RoundSpawn"
		}
	else
		tagged = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn"
		}

		containers = {
			"Lobby",
			"Hub",
			"WaitingRoom"
		}

		direct = {
			"LobbySpawn",
			"HubSpawn",
			"WaitingSpawn"
		}
	end

	for _, tagName in ipairs(tagged) do
		for _, object in ipairs(
			CollectionService:GetTagged(tagName)
		) do
			local cf = SpawnCFrame(object)

			if cf then
				return cf
			end
		end
	end

	for _, containerName in ipairs(containers) do
		local container = Workspace:FindFirstChild(
			containerName,
			true
		)

		if container then
			local cf = FindSpawnInside(container, kind)

			if cf then
				return cf
			end
		end
	end

	for _, name in ipairs(direct) do
		local object = Workspace:FindFirstChild(name, true)
		local cf = SpawnCFrame(object)

		if cf then
			return cf
		end
	end

	return nil
end

local function TeleportTo(kind, card)
	local placeId = GetPlaceId(kind)

	if placeId and placeId ~= game.PlaceId then
		card.title.Text = "TELEPORTING..."

		local ok = pcall(function()
			TeleportService:Teleport(
				placeId,
				LocalPlayer
			)
		end)

		if not ok then
			card.title.Text = "TELEPORT FAILED"

			task.delay(1.2, function()
				if card.title and card.title.Parent then
					card.title.Text =
						"TELEPORT TO "
						.. string.upper(kind)
				end
			end)
		end

		return
	end

	local destination = FindDestinationSpawn(kind)
	local character = LocalPlayer.Character

	if destination and character then
		character:PivotTo(
			destination + Vector3.new(0, 4, 0)
		)

		return
	end

	local oldText = card.title.Text
	card.title.Text =
		string.upper(kind)
		.. " SPAWN NOT FOUND"

	task.delay(1.2, function()
		if card.title and card.title.Parent then
			card.title.Text = oldText
		end
	end)
end

local function ApplyPanelBackgroundSettings()
	local brightness = math.clamp(
		State.backgroundBrightness / 100,
		0,
		1
	)

	local value = 0.34 + brightness * 0.66
	local color = Color3.new(value, value, value)

	Background.ImageColor3 = color

	local blurAmount = math.clamp(
		State.panelBlur / 100,
		0,
		1
	)

	for _, data in ipairs(BlurLayers) do
		local image = data.image
		local offset = data.offset * (0.4 + 1.4 * blurAmount)

		image.Position = UDim2.new(
			0.5,
			offset.X,
			0.5,
			offset.Y
		)

		image.ImageColor3 = color
		image.ImageTransparency =
			1 - (0.14 * blurAmount)
	end

	Background.ImageTransparency =
		0.28 + (0.12 * blurAmount)

	BackgroundShade.BackgroundTransparency =
		0.12 - (0.03 * blurAmount)
end

Section(InfoPage, "Lost Hub", "Status and notes", 1)

local InfoCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 110),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, InfoPage)
Corner(InfoCard, 9)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 24),
	Position = UDim2.fromOffset(15, 16),
	BackgroundTransparency = 1,
	Text = "LOST HUB",
	TextColor3 = Theme.White,
	TextSize = 17,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 18),
	Position = UDim2.fromOffset(15, 43),
	BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName,
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

local InfoFps = New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 18),
	Position = UDim2.fromOffset(15, 65),
	BackgroundTransparency = 1,
	Text = "0",
	TextColor3 = Theme.PurpleBright,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 16),
	Position = UDim2.fromOffset(15, 87),
	BackgroundTransparency = 1,
	Text = "All runtime features start disabled.",
	TextColor3 = Theme.Muted2,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

NoteCard(
	InfoPage,
	"Development",
	"Lost Hub is still in active development. Features can change while the project is being tested.",
	3
)

NoteCard(
	InfoPage,
	"Generated Rooms",
	"ESP, graphics modes and instant interactions also monitor content created after the script starts.",
	4
)

NoteCard(
	InfoPage,
	"FPS Display",
	"The counter shows numbers only and refreshes at up to 30 Hz.",
	5
)

Section(MainPage, "Main", "Session and spawn actions", 1)

local RejoinCard
RejoinCard = ActionButton(
	MainPage,
	"REJOIN CURRENT SERVER",
	"Reconnect to the same server instance",
	2,
	function()
		RejoinCard.title.Text = "REJOINING..."

		local ok = pcall(function()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				game.JobId,
				LocalPlayer
			)
		end)

		if not ok then
			RejoinCard.title.Text = "REJOIN FAILED"

			task.delay(1.2, function()
				if RejoinCard.title
					and RejoinCard.title.Parent then

					RejoinCard.title.Text =
						"REJOIN CURRENT SERVER"
				end
			end)
		end
	end
)

local GameCard
GameCard = ActionButton(
	MainPage,
	"TELEPORT TO GAME",
	"Uses the Game SpawnLocation",
	3,
	function()
		TeleportTo("Game", GameCard)
	end
)

local LobbyCard
LobbyCard = ActionButton(
	MainPage,
	"TELEPORT TO LOBBY",
	"Uses the Lobby SpawnLocation",
	4,
	function()
		TeleportTo("Lobby", LobbyCard)
	end
)

local RespawnCard
RespawnCard = ActionButton(
	MainPage,
	"RESPAWN",
	"Respawn the local character",
	5,
	function()
		local character = LocalPlayer.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.Health = 0
		end
	end
)

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
		if not enabled
			and not State.speedManipulation then

			RestoreLocalCollision()
		end
	end
})

local WalkRow = CreateToggle(PlayerPage, {
	id = "walkSpeed",
	title = "Walk Speed",
	subtitle = "Editable movement speed",
	order = 4,
	height = 102,
	changed = function(enabled)
		local character = LocalPlayer.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			if enabled then
				if SavedWalkSpeed == nil then
					SavedWalkSpeed = humanoid.WalkSpeed
				end

				if not State.speedManipulation then
					humanoid.WalkSpeed =
						State.walkSpeedValue
				end
			else
				if SavedWalkSpeed ~= nil
					and not State.speedManipulation then

					humanoid.WalkSpeed =
						SavedWalkSpeed
				end

				SavedWalkSpeed = nil
			end
		end
	end
})

CreateSlider(
	WalkRow,
	77,
	1,
	25,
	State.walkSpeedValue,
	function(value)
		State.walkSpeedValue = value

		if State.walkSpeed
			and not State.speedManipulation then

			local character = LocalPlayer.Character
			local humanoid = character
				and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.WalkSpeed = value
			end
		end
	end,
	false
)

local FlyRow = CreateToggle(PlayerPage, {
	id = "fly",
	title = "Fly",
	subtitle = "WASD movement · E up · Q down",
	order = 5,
	height = 102,
	changed = function(enabled)
		if enabled then
			CreateFly()
		else
			DestroyFly()
		end
	end
})

CreateSlider(
	FlyRow,
	77,
	5,
	100,
	State.flySpeed,
	function(value)
		State.flySpeed = value
	end,
	false
)

Section(VisualPage, "Visual", "Player and world overlays", 1)

CreateToggle(VisualPage, {
	id = "playerEsp",
	title = "Player ESP",
	subtitle = "Purple overlay · red when class or tags differ",
	order = 2,
	changed = function(enabled)
		if not enabled then
			ClearPlayerEsp()
		end
	end
})

CreateToggle(VisualPage, {
	id = "objectiveEsp",
	title = "Objective ESP",
	subtitle = "Highlight tagged or classified objectives",
	order = 3,
	changed = function(enabled)
		if enabled then
			ScanWorldEsp("Objective")
		else
			ClearWorldEsp("Objective")
		end
	end
})

CreateToggle(VisualPage, {
	id = "itemEsp",
	title = "Items ESP",
	subtitle = "Highlight items, loot and pickups",
	order = 4,
	changed = function(enabled)
		if enabled then
			ScanWorldEsp("Item")
		else
			ClearWorldEsp("Item")
		end
	end
})

CreateToggle(VisualPage, {
	id = "entityEsp",
	title = "Entities ESP",
	subtitle = "Highlight entities, enemies and monsters",
	order = 5,
	changed = function(enabled)
		if enabled then
			ScanWorldEsp("Entity")
		else
			ClearWorldEsp("Entity")
		end
	end
})

CreateToggle(VisualPage, {
	id = "fpsVisible",
	title = "FPS Display",
	subtitle = "Number-only movable FPS counter",
	order = 6,
	changed = function(enabled)
		if SetFpsVisible then
			SetFpsVisible(enabled)
		end
	end
})

Section(GraphicsPage, "Graphics", "Visual quality and performance", 1)

local GraphicsRow = CreateToggle(GraphicsPage, {
	id = "graphicsEnhancement",
	title = "High Graphics",
	subtitle = "Better lights, shadows, reflections and post processing",
	order = 2,
	height = 102,
	changed = function(enabled)
		if enabled then
			if State.lowGraphics
				and ToggleSetters.lowGraphics then

				ToggleSetters.lowGraphics(false)
			end

			EnableGraphicsEnhancement()
		else
			DisableGraphicsEnhancement()
		end
	end
})

CreateSlider(
	GraphicsRow,
	77,
	0,
	100,
	State.graphicsStrength,
	function(value)
		State.graphicsStrength = value

		if State.graphicsEnhancement then
			ApplyGraphicsStrength()
		end
	end,
	true
)

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	title = "Low Graphics",
	subtitle = "Reduce materials, particles and heavy effects",
	order = 3,
	changed = function(enabled)
		if enabled then
			if State.graphicsEnhancement
				and ToggleSetters.graphicsEnhancement then

				ToggleSetters.graphicsEnhancement(false)
			end

			EnableLowGraphics()
		else
			DisableLowGraphics()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "fullBright",
	title = "Full Bright",
	subtitle = "Increase ambient visibility and remove distant fog",
	order = 4,
	changed = function(enabled)
		if enabled then
			EnableFullBright()
		else
			DisableFullBright()
		end
	end
})

Section(SettingsPage, "Interaction", "Interaction and interface options", 1)

CreateToggle(SettingsPage, {
	id = "instantInteract",
	title = "Instant Interact",
	subtitle = "Set ProximityPrompt hold time to zero",
	order = 2,
	changed = function(enabled)
		if enabled then
			EnableInstantInteract()
		else
			DisableInstantInteract()
		end
	end
})

local BlurRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, SettingsPage)
Corner(BlurRow, 9)

New("TextLabel", {
	Size = UDim2.new(1, -125, 0, 18),
	Position = UDim2.fromOffset(14, 10),
	BackgroundTransparency = 1,
	Text = "Panel Blur",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BlurRow)

New("TextLabel", {
	Size = UDim2.new(1, -125, 0, 15),
	Position = UDim2.fromOffset(14, 29),
	BackgroundTransparency = 1,
	Text = "Softens only the Lost Hub artwork",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BlurRow)

CreateSlider(
	BlurRow,
	63,
	0,
	100,
	State.panelBlur,
	function(value)
		State.panelBlur = value
		ApplyPanelBackgroundSettings()
	end,
	true
)

local BrightnessRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 4,
	ZIndex = 46
}, SettingsPage)
Corner(BrightnessRow, 9)

New("TextLabel", {
	Size = UDim2.new(1, -125, 0, 18),
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
	Size = UDim2.new(1, -125, 0, 15),
	Position = UDim2.fromOffset(14, 29),
	BackgroundTransparency = 1,
	Text = "Brightness of the Lost Hub artwork",
	TextColor3 = Theme.Muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, BrightnessRow)

CreateSlider(
	BrightnessRow,
	63,
	0,
	100,
	State.backgroundBrightness,
	function(value)
		State.backgroundBrightness = value
		ApplyPanelBackgroundSettings()
	end,
	true
)

Section(HotkeysPage, "Hotkeys", "Click a binding to replace it", 1)

CreateHotkeyRow(
	HotkeysPage,
	"panel",
	"Panel",
	"Open or close Lost Hub",
	2,
	"toggle",
	true
)

CreateHotkeyRow(
	HotkeysPage,
	"speedManipulation",
	"Speed Manipulation",
	"Hold key · noclip + WalkSpeed 5",
	3,
	"hold",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"fpsVisible",
	"FPS Display",
	"Show or hide the FPS counter",
	4,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"fly",
	"Fly",
	"Toggle fly mode",
	5,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"antiFling",
	"Anti-Fling",
	"Toggle Anti-Fling",
	6,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"noclip",
	"Noclip",
	"Toggle Noclip",
	7,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"walkSpeed",
	"Walk Speed",
	"Toggle Walk Speed",
	8,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"playerEsp",
	"Player ESP",
	"Toggle Player ESP",
	9,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"objectiveEsp",
	"Objective ESP",
	"Toggle Objective ESP",
	10,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"itemEsp",
	"Items ESP",
	"Toggle Items ESP",
	11,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"entityEsp",
	"Entities ESP",
	"Toggle Entities ESP",
	12,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"instantInteract",
	"Instant Interact",
	"Toggle Instant Interact",
	13,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"graphicsEnhancement",
	"High Graphics",
	"Toggle High Graphics",
	14,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"lowGraphics",
	"Low Graphics",
	"Toggle Low Graphics",
	15,
	"toggle",
	false
)

CreateHotkeyRow(
	HotkeysPage,
	"fullBright",
	"Full Bright",
	"Toggle Full Bright",
	16,
	"toggle",
	false
)

local ProfilePanel = New("CanvasGroup", {
	Size = UDim2.fromOffset(330, 260),
	Position = UDim2.new(0, 196, 1, -276),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 900
}, Main)
Corner(ProfilePanel, 10)

local ProfilePanelScale = New("UIScale", {
	Scale = 0.97
}, ProfilePanel)

New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 22),
	Position = UDim2.fromOffset(14, 13),
	BackgroundTransparency = 1,
	Text = "PROFILE STATUS",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 901
}, ProfilePanel)

local ExecutionLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 18),
	Position = UDim2.fromOffset(14, 39),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 901
}, ProfilePanel)

New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 18),
	Position = UDim2.fromOffset(14, 67),
	BackgroundTransparency = 1,
	Text = "ACTIVE",
	TextColor3 = Theme.PurpleBright,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 901
}, ProfilePanel)

local ActiveLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 70),
	Position = UDim2.fromOffset(14, 87),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Theme.Light,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 901
}, ProfilePanel)

New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 18),
	Position = UDim2.fromOffset(14, 160),
	BackgroundTransparency = 1,
	Text = "DISABLED",
	TextColor3 = Theme.Muted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 901
}, ProfilePanel)

local DisabledLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 78),
	Position = UDim2.fromOffset(14, 180),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Theme.Muted2,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 901
}, ProfilePanel)

local ProfileStateNames = {
	{"antiFling", "Anti-Fling"},
	{"noclip", "Noclip"},
	{"walkSpeed", "Walk Speed"},
	{"speedManipulation", "Speed Manipulation"},
	{"fly", "Fly"},
	{"playerEsp", "Player ESP"},
	{"objectiveEsp", "Objective ESP"},
	{"itemEsp", "Items ESP"},
	{"entityEsp", "Entities ESP"},
	{"instantInteract", "Instant Interact"},
	{"graphicsEnhancement", "High Graphics"},
	{"lowGraphics", "Low Graphics"},
	{"fullBright", "Full Bright"},
	{"fpsVisible", "FPS Display"}
}

RefreshProfilePanel = function()
	ExecutionLabel.Text = "Executions: "
		.. tostring(_G.LostHubExecutionCount or 1)

	local active = {}
	local disabled = {}

	for _, entry in ipairs(ProfileStateNames) do
		if State[entry[1]] then
			table.insert(active, entry[2])
		else
			table.insert(disabled, entry[2])
		end
	end

	ActiveLabel.Text = #active > 0
		and table.concat(active, "  ·  ")
		or "None"

	DisabledLabel.Text = #disabled > 0
		and table.concat(disabled, "  ·  ")
		or "None"
end

Bind(Profile.MouseButton1Click, function()
	ProfilePanelOpen = not ProfilePanelOpen

	if ProfilePanelOpen then
		RefreshProfilePanel()

		ProfilePanel.Visible = true
		ProfilePanel.GroupTransparency = 1
		ProfilePanelScale.Scale = 0.97

		Tween(ProfilePanel, 0.18, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine)

		Tween(ProfilePanelScale, 0.22, {
			Scale = 1
		}, Enum.EasingStyle.Quint)
	else
		local fade = Tween(ProfilePanel, 0.16, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine)

		Tween(ProfilePanelScale, 0.16, {
			Scale = 0.98
		}, Enum.EasingStyle.Quart)

		fade.Completed:Once(function()
			if not ProfilePanelOpen then
				ProfilePanel.Visible = false
			end
		end)
	end
end)

local StatusHud = New("CanvasGroup", {
	Name = "StatusHud",
	Size = UDim2.fromOffset(70, 34),
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
Corner(StatusHud, 9)

local HudScale = New("UIScale", {
	Scale = 0.96
}, StatusHud)

local FpsLabel = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "0",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
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
				if input.UserInputState
					== Enum.UserInputState.End then

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
		PreviousMouseBehavior = UserInputService.MouseBehavior
		PreviousMouseIconEnabled =
			UserInputService.MouseIconEnabled

		Main.Visible = true
		Main.GroupTransparency = 1
		MainScale.Scale = 0.95
		Background.ImageTransparency = 0.62

		ApplyPanelBackgroundSettings()

		Tween(MainScale, 0.42, {
			Scale = 1
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Main, 0.28, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		Tween(Background, 0.5, {
			ImageTransparency =
				0.28 + (0.12 * State.panelBlur / 100)
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		StopSpeedManipulation()

		Tween(MainScale, 0.25, {
			Scale = 0.965
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.23, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if animationId == MenuAnimationId
				and not State.menuVisible then

				Main.Visible = false

				UserInputService.MouseBehavior =
					PreviousMouseBehavior

				UserInputService.MouseIconEnabled =
					PreviousMouseIconEnabled
			end
		end)
	end
end

SetFpsVisible = function(visible)
	FpsAnimationId += 1
	local animationId = FpsAnimationId

	State.fpsVisible = visible

	if visible then
		StatusHud.Visible = true
		StatusHud.GroupTransparency = 1
		HudScale.Scale = 0.96

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

		local fade = Tween(StatusHud, 0.17, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if animationId == FpsAnimationId
				and not State.fpsVisible then

				StatusHud.Visible = false
			end
		end)
	end

	if RefreshProfilePanel then
		RefreshProfilePanel()
	end
end

Bind(UserInputService.InputBegan, function(input, gameProcessed)
	if Capture then
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == Enum.KeyCode.Escape then

			if Capture.type == "panel" then
				Capture.button.Text =
					FormatBinding(PanelShortcut)
			else
				Capture.button.Text =
					FormatBinding(Bindings[Capture.id])
			end

			Capture.button.TextColor3 = Theme.White
			Capture = nil
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and (
				input.KeyCode == Enum.KeyCode.Backspace
				or input.KeyCode == Enum.KeyCode.Delete
			) then

			if Capture.type == "panel" then
				PanelShortcut = nil
			else
				Bindings[Capture.id] = nil
			end

			Capture.button.Text = "SET"
			Capture.button.TextColor3 = Theme.White
			Capture = nil
			return
		end

		if Capture.type == "panel" then
			if input.UserInputType == Enum.UserInputType.Keyboard
				and input.KeyCode ~= Enum.KeyCode.Unknown
				and input.KeyCode ~= Enum.KeyCode.LeftControl
				and input.KeyCode ~= Enum.KeyCode.RightControl
				and input.KeyCode ~= Enum.KeyCode.LeftShift
				and input.KeyCode ~= Enum.KeyCode.RightShift
				and input.KeyCode ~= Enum.KeyCode.LeftAlt
				and input.KeyCode ~= Enum.KeyCode.RightAlt then

				local mods = GetModifiers()

				PanelShortcut = {
					kind = "KeyCode",
					value = input.KeyCode,
					ctrl = mods.ctrl,
					shift = mods.shift,
					alt = mods.alt
				}

				Capture.button.Text =
					FormatBinding(PanelShortcut)

				ShortcutChip.Text =
					FormatBinding(PanelShortcut)

				Capture.button.TextColor3 = Theme.White
				Capture = nil
			end

			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode ~= Enum.KeyCode.Unknown then

			Bindings[Capture.id] = {
				kind = "KeyCode",
				value = input.KeyCode
			}

		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then

			Bindings[Capture.id] = {
				kind = "InputType",
				value = input.UserInputType
			}
		else
			return
		end

		Capture.button.Text =
			FormatBinding(Bindings[Capture.id])

		Capture.button.TextColor3 = Theme.White
		Capture = nil
		return
	end

	if BindingMatches(PanelShortcut, input, true) then
		SetMenuVisible(not State.menuVisible)
		return
	end

	if FocusedTextBox() then
		return
	end

	if BindingMatches(
		Bindings.speedManipulation,
		input,
		false
	) then
		StartSpeedManipulation()
		return
	end

	if gameProcessed then
		return
	end

	for id, binding in pairs(Bindings) do
		if id ~= "speedManipulation"
			and BindingMatches(binding, input, false) then

			local setter = ToggleSetters[id]

			if setter then
				setter(not State[id])
			end

			return
		end
	end
end)

Bind(UserInputService.InputEnded, function(input)
	if BindingMatches(
		Bindings.speedManipulation,
		input,
		false
	) then
		StopSpeedManipulation()
	end
end)

Bind(RunService.Stepped, function()
	local character = LocalPlayer.Character

	if State.noclip and character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				if SavedLocalCollision[object] == nil then
					SavedLocalCollision[object] =
						object.CanCollide
				end

				object.CanCollide = false
			end
		end
	elseif not State.speedManipulation
		and next(SavedLocalCollision) then

		RestoreLocalCollision()
	end

	if State.speedManipulation and character then
		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = 5
		end

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				if SpeedManipSavedCollision[object] == nil then
					SpeedManipSavedCollision[object] =
						object.CanCollide
				end

				object.CanCollide = false
			end
		end
	end
end)

Bind(RunService.Heartbeat, function()
	local character = LocalPlayer.Character
	local humanoid = character
		and character:FindFirstChildOfClass("Humanoid")
	local root = character
		and character:FindFirstChild("HumanoidRootPart")

	if State.walkSpeed
		and humanoid
		and not State.speedManipulation then

		humanoid.WalkSpeed = State.walkSpeedValue
	end

	if State.antiFling and root then
		local linear =
			root.AssemblyLinearVelocity.Magnitude
		local angular =
			root.AssemblyAngularVelocity.Magnitude

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
			if player ~= LocalPlayer
				and player.Character then

				for _, object in ipairs(
					player.Character:GetDescendants()
				) do
					if object:IsA("BasePart") then
						if SavedOtherCollision[object] == nil then
							SavedOtherCollision[object] =
								object.CanCollide
						end

						object.CanCollide = false
					end
				end
			end
		end
	elseif next(SavedOtherCollision) then
		RestoreOtherCollision()
	end

	if State.playerEsp then
		for _, player in ipairs(Players:GetPlayers()) do
			EnsurePlayerEsp(player)
		end
	elseif next(PlayerEspObjects) then
		ClearPlayerEsp()
	end
end)

Bind(Workspace.DescendantAdded, function(object)
	if State.graphicsEnhancement then
		task.defer(function()
			if object.Parent then
				EnhanceObject(object)
			end
		end)
	end

	if State.lowGraphics then
		task.defer(function()
			if object.Parent then
				ApplyLowToObject(object)
			end
		end)
	end

	if State.instantInteract
		and object:IsA("ProximityPrompt") then

		task.defer(function()
			if object.Parent then
				if InstantSaved[object] == nil then
					InstantSaved[object] =
						object.HoldDuration
				end

				object.HoldDuration = 0
			end
		end)
	end

	task.defer(function()
		if object.Parent then
			local kind = ClassifyWorldObject(object)

			if kind and WorldEspEnabled(kind) then
				EnsureWorldEsp(object, kind)
			end
		end
	end)
end)

Bind(Lighting.ChildAdded, function(object)
	if State.lowGraphics
		and object:IsA("PostEffect")
		and not string.find(object.Name, "^LostHub") then

		task.defer(function()
			if object.Parent then
				LowSaved.objects[object] = {
					property = "Enabled",
					value = object.Enabled
				}

				object.Enabled = false
			end
		end)
	end
end)

local FrameCount = 0
local FrameElapsed = 0
local FpsUiAccumulator = 0
local VisualTime = 0
local WorldEspAccumulator = 0
local ProfileAccumulator = 0
local CurrentFps = 0

Bind(RunService.RenderStepped, function(deltaTime)
	FrameCount += 1
	FrameElapsed += deltaTime
	FpsUiAccumulator += deltaTime
	VisualTime += deltaTime
	WorldEspAccumulator += deltaTime
	ProfileAccumulator += deltaTime

	if State.menuVisible then
		UserInputService.MouseBehavior =
			Enum.MouseBehavior.Default

		UserInputService.MouseIconEnabled = true
	end

	if State.fly and FlyVelocity and FlyGyro then
		local character = LocalPlayer.Character
		local root = character
			and character:FindFirstChild("HumanoidRootPart")

		if root and Camera then
			local movement = Vector3.zero

			local look = Camera.CFrame.LookVector
			local right = Camera.CFrame.RightVector

			local flatLook = Vector3.new(
				look.X,
				0,
				look.Z
			)

			local flatRight = Vector3.new(
				right.X,
				0,
				right.Z
			)

			if flatLook.Magnitude > 0 then
				flatLook = flatLook.Unit
			end

			if flatRight.Magnitude > 0 then
				flatRight = flatRight.Unit
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.W
			) then
				movement += flatLook
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.S
			) then
				movement -= flatLook
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.D
			) then
				movement += flatRight
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.A
			) then
				movement -= flatRight
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.E
			) then
				movement += Vector3.yAxis
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.Q
			) then
				movement -= Vector3.yAxis
			end

			if movement.Magnitude > 0 then
				movement = movement.Unit
					* State.flySpeed
			end

			FlyVelocity.Velocity = movement

			FlyGyro.CFrame = CFrame.lookAt(
				root.Position,
				root.Position + Camera.CFrame.LookVector
			)
		end
	end

	local x = math.sin(VisualTime * 0.12) * 0.003
	local y = math.cos(VisualTime * 0.1) * 0.002

	Background.Position =
		UDim2.fromScale(0.5 + x, 0.5 + y)

	if FrameElapsed >= 0.5 then
		CurrentFps = math.floor(
			(FrameCount / FrameElapsed) + 0.5
		)

		FrameCount = 0
		FrameElapsed = 0
	end

	if FpsUiAccumulator >= (1 / 30) then
		local text = tostring(CurrentFps)

		FpsLabel.Text = text
		InfoFps.Text = text

		FpsUiAccumulator = 0
	end

	if WorldEspAccumulator >= 0.25 then
		UpdateWorldEspDistances()
		WorldEspAccumulator = 0
	end

	if ProfileAccumulator >= 0.4 then
		if ProfilePanelOpen then
			RefreshProfilePanel()
		end

		ProfileAccumulator = 0
	end
end)

Bind(Players.PlayerRemoving, function(player)
	DestroyPlayerEsp(player)
end)

Bind(LocalPlayer.CharacterAdded, function(character)
	LastSafeCFrame = nil
	SavedWalkSpeed = nil

	RestoreLocalCollision()
	StopSpeedManipulation()
	DestroyFly()

	task.spawn(function()
		local humanoid =
			character:WaitForChild("Humanoid", 10)

		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed =
				State.walkSpeedValue
		end

		if State.fly then
			task.wait(0.3)
			CreateFly()
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
		Avatar.Image =
			"rbxthumb://type=AvatarHeadShot&id="
			.. tostring(LocalPlayer.UserId)
			.. "&w=150&h=150"
	end
end)

task.spawn(function()
	local preload = {
		Background,
		HubIcon,
		IntroIcon,
		Avatar
	}

	for _, data in ipairs(BlurLayers) do
		table.insert(preload, data.image)
	end

	pcall(function()
		ContentProvider:PreloadAsync(preload)
	end)
end)

local function Cleanup()
	if Destroyed then
		return
	end

	Destroyed = true
	Capture = nil

	StopSpeedManipulation()
	DestroyFly()

	State.antiFling = false
	State.noclip = false
	State.walkSpeed = false
	State.fly = false
	State.playerEsp = false
	State.objectiveEsp = false
	State.itemEsp = false
	State.entityEsp = false
	State.instantInteract = false
	State.graphicsEnhancement = false
	State.lowGraphics = false
	State.fullBright = false
	State.fpsVisible = false

	local character = LocalPlayer.Character
	local humanoid = character
		and character:FindFirstChildOfClass("Humanoid")

	if humanoid and SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed = SavedWalkSpeed
	end

	SavedWalkSpeed = nil

	RestoreLocalCollision()
	RestoreOtherCollision()
	ClearPlayerEsp()
	ClearWorldEsp("Objective")
	ClearWorldEsp("Item")
	ClearWorldEsp("Entity")
	DisableInstantInteract()
	DisableGraphicsEnhancement()
	DisableLowGraphics()
	DisableFullBright()

	for _, connection in ipairs(Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(Connections)

	UserInputService.MouseBehavior =
		PreviousMouseBehavior

	UserInputService.MouseIconEnabled =
		PreviousMouseIconEnabled

	if ScreenGui and ScreenGui.Parent then
		ScreenGui:Destroy()
	end

	if _G.LostHubCleanup == Cleanup then
		_G.LostHubCleanup = nil
	end
end

_G.LostHubCleanup = Cleanup

SelectPage("Info")
ShortcutChip.Text = FormatBinding(PanelShortcut)
ApplyPanelBackgroundSettings()
SetFpsVisible(false)
RefreshProfilePanel()

task.spawn(function()
	IntroIcon.Position =
		UDim2.new(0.5, 0, 0.44, 12)

	IntroTitle.Position =
		UDim2.new(0.5, 0, 0.58, 12)

	Tween(IntroScale, 0.48, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroIcon, 0.34, {
		ImageTransparency = 0,
		Position = UDim2.new(
			0.5,
			0,
			0.44,
			0
		)
	}, Enum.EasingStyle.Quint)

	task.wait(0.08)

	Tween(IntroTitle, 0.34, {
		TextTransparency = 0,
		Position = UDim2.new(
			0.5,
			0,
			0.58,
			0
		)
	}, Enum.EasingStyle.Quint)

	Tween(IntroLine, 0.46, {
		Size = UDim2.fromOffset(180, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.48)

	Tween(IntroScale, 0.28, {
		Scale = 1.02
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	local introFade = Tween(Intro, 0.32, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	introFade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false

	PreviousMouseBehavior =
		UserInputService.MouseBehavior

	PreviousMouseIconEnabled =
		UserInputService.MouseIconEnabled

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.955
	Background.ImageTransparency = 0.62

	ApplyPanelBackgroundSettings()

	Tween(MainScale, 0.46, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(Main, 0.28, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Sine)

	Tween(Background, 0.5, {
		ImageTransparency =
			0.28 + (0.12 * State.panelBlur / 100)
	}, Enum.EasingStyle.Quint)
end)

