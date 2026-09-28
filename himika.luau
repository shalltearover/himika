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
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local BACKGROUND_ASSET_ID = 10039618753
local HUB_ICON_ASSET_ID = 11878291148

local oldGui = PlayerGui:FindFirstChild("LostHub")
if oldGui then
	oldGui:Destroy()
end

for _, effectName in ipairs({
	"LostHubLightsColor",
	"LostHubLightsBloom",
	"LostHubEnvironmentAtmosphere",
	"LostHubEnvironmentSun",
	"LostHubEnvironmentDepth"
}) do
	local effect = Lighting:FindFirstChild(effectName)
	if effect then
		effect:Destroy()
	end
end

local Theme = {
	Base = Color3.fromRGB(4, 5, 7),
	Surface = Color3.fromRGB(10, 11, 14),
	Surface2 = Color3.fromRGB(15, 17, 21),
	Surface3 = Color3.fromRGB(21, 23, 28),
	Surface4 = Color3.fromRGB(29, 31, 37),
	White = Color3.fromRGB(244, 245, 247),
	Light = Color3.fromRGB(203, 206, 212),
	Muted = Color3.fromRGB(138, 142, 150),
	Muted2 = Color3.fromRGB(92, 96, 104),
	Black = Color3.fromRGB(0, 0, 0),
	Off = Color3.fromRGB(43, 46, 52),
	Purple = Color3.fromRGB(119, 81, 190),
	PurpleBright = Color3.fromRGB(153, 105, 231),
	PurpleSoft = Color3.fromRGB(74, 52, 108),
	Red = Color3.fromRGB(232, 66, 78),
	Stroke = Color3.fromRGB(57, 60, 67)
}

local Language = "en"

local Strings = {
	en = {
		tab_info = "Info",
		tab_main = "Main",
		tab_player = "Player",
		tab_esp = "ESP",
		tab_graphics = "Graphics",
		tab_hotkeys = "Hotkeys",
		tab_status = "Status",
		tab_settings = "Settings",

		top_subtitle = "dark utility interface",
		info_subtitle = "Project information and warnings",
		info_version = "Development build",
		info_runtime = "All runtime features start disabled.",
		note_development_title = "Development",
		note_development_body = "This script is still in development. Features can change while they are being tested.",
		note_performance_title = "Performance",
		note_performance_body = "Options marked in red can increase GPU or CPU load and may cause stutters or freezes on large or generated rooms.",
		note_menu_title = "Menu shortcut",
		note_menu_body = "Left Shift opens or closes the menu. This shortcut is permanent.",

		main_title = "Session",
		main_subtitle = "Server and spawn actions",
		rejoin = "REJOIN CURRENT SERVER",
		rejoin_sub = "Reconnect to the same server instance",
		game_tp = "TELEPORT TO GAME",
		game_tp_sub = "Uses the Game SpawnLocation",
		lobby_tp = "TELEPORT TO LOBBY",
		lobby_tp_sub = "Uses the Lobby SpawnLocation",
		respawn = "RESPAWN",
		respawn_sub = "Respawn the local character",

		player_title = "Player",
		player_subtitle = "Movement and protection",
		anti_fling = "Anti-Fling",
		anti_fling_sub = "Velocity and collision protection",
		noclip = "Noclip",
		noclip_sub = "Disable collision on your character",
		walk_speed = "Walk Speed",
		walk_speed_sub = "Editable movement speed",
		fly = "Fly",
		fly_sub = "Fly toward the mouse cursor",
		fly_notice = "Fly enabled  ·  Q down  ·  E up",
		speed_manip = "Speed Manipulation",
		speed_manip_sub = "Hold V  ·  noclip + WalkSpeed 2",

		esp_title = "Player ESP",
		esp_subtitle = "Purple player overlay with name and distance",
		player_esp = "Player ESP",
		player_esp_sub = "Includes your own character",

		graphics_title = "Graphics",
		graphics_subtitle = "Visual quality and performance",
		better_textures = "Better Textures",
		better_textures_sub = "Precise mesh rendering and reduced model LOD",
		better_lights = "Better Lights",
		better_lights_sub = "Future lighting, shadows and stronger local lights",
		reflections = "Reflections",
		reflections_sub = "Stronger specular response on metal and glass",
		environment = "Environment",
		environment_sub = "Atmosphere, sun rays and depth effects",
		low_graphics = "Low Graphics",
		low_graphics_sub = "Reduce particles, materials and expensive effects",
		full_bright = "Full Bright",
		full_bright_sub = "Increase ambient visibility and remove distant fog",
		fps_display = "FPS Display",
		fps_display_sub = "Number-only counter updated at up to 30 Hz",
		heavy = "HIGH LOAD",

		hotkeys_title = "Hotkeys",
		hotkeys_subtitle = "Click a binding to replace it",
		hold_mode = "Hold",
		toggle_mode = "Toggle",

		status_title = "Runtime Status",
		status_subtitle = "Execution count and current feature states",
		executions = "Executions",
		active = "ACTIVE",
		disabled = "DISABLED",
		none = "None",

		settings_title = "Settings",
		settings_subtitle = "Interface preferences",
		panel_blur = "Panel Blur",
		panel_blur_sub = "Softens only the background inside the menu",
		background_brightness = "Background Brightness",
		background_brightness_sub = "Brightness of the fixed menu artwork",
		language = "Language",
		language_sub = "Choose the interface language",
		english = "English",
		portuguese = "Português",

		instant_interact = "Instant Interact",
		instant_interact_sub = "Set ProximityPrompt hold duration to zero",

		teleporting = "TELEPORTING...",
		teleport_failed = "TELEPORT FAILED",
		spawn_not_found = "SPAWN NOT FOUND",
		rejoining = "REJOINING...",
		rejoin_failed = "REJOIN FAILED",
		press_key = "PRESS KEY",
		set = "SET"
	},
	pt = {
		tab_info = "Info",
		tab_main = "Principal",
		tab_player = "Player",
		tab_esp = "ESP",
		tab_graphics = "Gráficos",
		tab_hotkeys = "Atalhos",
		tab_status = "Status",
		tab_settings = "Configurações",

		top_subtitle = "interface utilitária dark",
		info_subtitle = "Informações e avisos do projeto",
		info_version = "Versão em desenvolvimento",
		info_runtime = "Todos os recursos começam desativados.",
		note_development_title = "Desenvolvimento",
		note_development_body = "Este script ainda está em desenvolvimento. Recursos podem mudar durante os testes.",
		note_performance_title = "Desempenho",
		note_performance_body = "Opções marcadas em vermelho podem aumentar o uso de GPU ou CPU e causar travamentos em salas grandes ou geradas.",
		note_menu_title = "Atalho do menu",
		note_menu_body = "Shift esquerdo abre ou fecha o menu. Esse atalho é permanente.",

		main_title = "Sessão",
		main_subtitle = "Ações de servidor e spawn",
		rejoin = "REENTRAR NO SERVIDOR",
		rejoin_sub = "Reconecta à mesma instância do servidor",
		game_tp = "TELEPORTAR PARA O JOGO",
		game_tp_sub = "Usa o SpawnLocation do Game",
		lobby_tp = "TELEPORTAR PARA O LOBBY",
		lobby_tp_sub = "Usa o SpawnLocation do Lobby",
		respawn = "RESPAWN",
		respawn_sub = "Respawna o personagem local",

		player_title = "Player",
		player_subtitle = "Movimento e proteção",
		anti_fling = "Anti-Fling",
		anti_fling_sub = "Proteção de velocidade e colisão",
		noclip = "Noclip",
		noclip_sub = "Desativa colisão no personagem",
		walk_speed = "Walk Speed",
		walk_speed_sub = "Velocidade de movimento editável",
		fly = "Fly",
		fly_sub = "Voe na direção do cursor",
		fly_notice = "Fly ativado  ·  Q desce  ·  E sobe",
		speed_manip = "Speed Manipulation",
		speed_manip_sub = "Segure V  ·  noclip + WalkSpeed 2",

		esp_title = "Player ESP",
		esp_subtitle = "Overlay roxo com nome e distância",
		player_esp = "Player ESP",
		player_esp_sub = "Inclui o seu próprio personagem",

		graphics_title = "Gráficos",
		graphics_subtitle = "Qualidade visual e desempenho",
		better_textures = "Texturas Melhores",
		better_textures_sub = "Renderização precisa de meshes e menor LOD",
		better_lights = "Luzes Melhores",
		better_lights_sub = "Future lighting, sombras e luzes locais mais fortes",
		reflections = "Reflexos",
		reflections_sub = "Resposta especular mais forte em metal e vidro",
		environment = "Ambiente",
		environment_sub = "Atmosfera, raios solares e profundidade",
		low_graphics = "Gráficos Baixos",
		low_graphics_sub = "Reduz partículas, materiais e efeitos pesados",
		full_bright = "Full Bright",
		full_bright_sub = "Aumenta a visibilidade e remove neblina distante",
		fps_display = "Display de FPS",
		fps_display_sub = "Contador numérico atualizado em até 30 Hz",
		heavy = "PESO ALTO",

		hotkeys_title = "Atalhos",
		hotkeys_subtitle = "Clique em um atalho para substituí-lo",
		hold_mode = "Segurar",
		toggle_mode = "Toggle",

		status_title = "Status de Execução",
		status_subtitle = "Contagem de execuções e estados atuais",
		executions = "Execuções",
		active = "ATIVOS",
		disabled = "DESATIVADOS",
		none = "Nenhum",

		settings_title = "Configurações",
		settings_subtitle = "Preferências da interface",
		panel_blur = "Blur do Painel",
		panel_blur_sub = "Suaviza apenas o background dentro do menu",
		background_brightness = "Brilho do Background",
		background_brightness_sub = "Brilho da arte fixa do menu",
		language = "Idioma",
		language_sub = "Escolha o idioma da interface",
		english = "English",
		portuguese = "Português",

		instant_interact = "Interação Instantânea",
		instant_interact_sub = "Zera o tempo de segurar ProximityPrompt",

		teleporting = "TELEPORTANDO...",
		teleport_failed = "FALHA NO TELEPORTE",
		spawn_not_found = "SPAWN NÃO ENCONTRADO",
		rejoining = "REENTRANDO...",
		rejoin_failed = "FALHA AO REENTRAR",
		press_key = "PRESSIONE UMA TECLA",
		set = "DEFINIR"
	}
}

local Localized = {}

local function T(key)
	return Strings[Language][key] or Strings.en[key] or key
end

local function RegisterText(instance, key)
	table.insert(Localized, {
		instance = instance,
		key = key
	})
	instance.Text = T(key)
	return instance
end

local function RefreshLanguage()
	for _, entry in ipairs(Localized) do
		if entry.instance and entry.instance.Parent then
			entry.instance.Text = T(entry.key)
		end
	end
end

local State = {
	antiFling = false,
	noclip = false,
	walkSpeed = false,
	speedManipulation = false,
	fly = false,
	playerEsp = false,
	betterTextures = false,
	betterLights = false,
	reflections = false,
	environment = false,
	lowGraphics = false,
	fullBright = false,
	fpsVisible = false,
	instantInteract = false,
	walkSpeedValue = 16,
	flySpeed = 30,
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
	betterTextures = nil,
	betterLights = nil,
	reflections = nil,
	environment = nil,
	lowGraphics = nil,
	fullBright = nil,
	fpsVisible = {
		kind = "KeyCode",
		value = Enum.KeyCode.F4
	},
	instantInteract = nil
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
local InstantSaved = {}

local TextureSaved = {}
local LightSaved = {}
local ReflectionSaved = {}
local EnvironmentSaved = {}
local LowSaved = {
	lighting = {},
	objects = {}
}
local FullBrightSaved = {}

local LightsEffects = {}
local EnvironmentEffects = {}

local FlyVelocity = nil
local FlyGyro = nil
local FlyNoticeToken = 0

local PreviousMouseBehavior = Enum.MouseBehavior.Default
local PreviousMouseIconEnabled = true

local SetFpsVisible
local RefreshStatusPage
local ShowFlyNotice

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

local function AssetThumbnail(assetId)
	return "rbxthumb://type=Asset&id="
		.. tostring(assetId)
		.. "&w=420&h=420"
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
		return T("set")
	end

	if binding.kind == "KeyCode" then
		return KeyName(binding.value)
	end

	if binding.kind == "InputType" then
		local aliases = {
			MouseButton1 = "MOUSE1",
			MouseButton2 = "MOUSE2",
			MouseButton3 = "MOUSE3"
		}
		return aliases[binding.value.Name] or string.upper(binding.value.Name)
	end

	return T("set")
end

local function BindingMatches(binding, input)
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
	Scale = 0.96
}, Intro)

local IntroLine = New("Frame", {
	Size = UDim2.fromOffset(0, 1),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Theme.PurpleBright,
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
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(BACKGROUND_ASSET_ID),
	ImageTransparency = 0.30,
	ImageColor3 = Color3.fromRGB(185, 185, 185),
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 20
}, Main)

local BlurLayers = {}

for _, offset in ipairs({
	Vector2.new(-3, 0),
	Vector2.new(3, 0),
	Vector2.new(0, -3),
	Vector2.new(0, 3)
}) do
	local layer = New("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(offset.X, offset.Y),
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
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0.14,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 76),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.10,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)

local HubIconBox = New("Frame", {
	Size = UDim2.fromOffset(42, 42),
	Position = UDim2.fromOffset(18, 17),
	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
	ZIndex = 51
}, TopBar)
Corner(HubIconBox, 10)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(32, 32),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 52
}, HubIconBox)

local TopSubtitle = RegisterText(
	New("TextLabel", {
		Size = UDim2.fromOffset(310, 20),
		Position = UDim2.fromOffset(74, 27),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 51
	}, TopBar),
	"top_subtitle"
)

local ShortcutChip = New("TextLabel", {
	Size = UDim2.fromOffset(92, 28),
	Position = UDim2.new(1, -110, 0, 24),
	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
	Text = "LSHIFT",
	TextColor3 = Theme.Light,
	TextSize = 8,
	Font = Enum.Font.GothamBold,
	ZIndex = 51
}, TopBar)
Corner(ShortcutChip, 8)
Stroke(ShortcutChip, 0.65, 1, Theme.Stroke)

local Sidebar = New("Frame", {
	Size = UDim2.new(0, 180, 1, -76),
	Position = UDim2.fromOffset(0, 76),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.09,
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
	Size = UDim2.new(1, 0, 1, -72),
	BackgroundTransparency = 1,
	ZIndex = 46
}, Sidebar)
Padding(TabsHolder, 11, 11, 14, 8)

New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, TabsHolder)

local Profile = New("TextButton", {
	Size = UDim2.new(1, -22, 0, 58),
	Position = UDim2.new(0, 11, 1, -64),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 46
}, Sidebar)
Corner(Profile, 9)

local Avatar = New("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.fromOffset(9, 11),
	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,
	Image = "",
	ZIndex = 47
}, Profile)
Corner(Avatar, 9)

local ProfileName = New("TextLabel", {
	Size = UDim2.new(1, -56, 0, 17),
	Position = UDim2.fromOffset(53, 10),
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
	Position = UDim2.fromOffset(53, 29),
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
	BorderSizePixel = 0,
	ZIndex = 48
}, Profile)
Corner(UsernameCover, 3)

Bind(Profile.MouseEnter, function()
	Tween(UsernameCover, 0.15, {
		Size = UDim2.new(0, 0, 0, 10),
		BackgroundTransparency = 1
	}, Enum.EasingStyle.Quart)
end)

Bind(Profile.MouseLeave, function()
	Tween(UsernameCover, 0.15, {
		Size = UDim2.new(1, -64, 0, 10),
		BackgroundTransparency = 0
	}, Enum.EasingStyle.Quart)
end)

local Content = New("Frame", {
	Size = UDim2.new(1, -180, 1, -76),
	Position = UDim2.fromOffset(180, 76),
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
			BackgroundTransparency = selected and 0.10 or 1,
			BackgroundColor3 = selected and Theme.Surface3 or Theme.Surface2,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quad)
	end
end

local function CreateTab(name, textKey, order)
	local button = RegisterText(
		New("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Surface2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 47
		}, TabsHolder),
		textKey
	)
	Corner(button, 8)
	Padding(button, 14, 8, 0, 0)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.12, {Scale = 1.014}, Enum.EasingStyle.Quad)
		if not Pages[name].Visible then
			Tween(button, 0.12, {
				BackgroundTransparency = 0.48,
				TextColor3 = Theme.Light
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
		Tween(scale, 0.06, {Scale = 0.986}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.08, {Scale = 1.014}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, function()
		SelectPage(name)
	end)

	Tabs[name] = {
		button = button
	}
end

local InfoPage = CreatePage("Info")
local MainPage = CreatePage("Main")
local PlayerPage = CreatePage("Player")
local EspPage = CreatePage("ESP")
local GraphicsPage = CreatePage("Graphics")
local HotkeysPage = CreatePage("Hotkeys")
local StatusPage = CreatePage("Status")
local SettingsPage = CreatePage("Settings")

CreateTab("Info", "tab_info", 1)
CreateTab("Main", "tab_main", 2)
CreateTab("Player", "tab_player", 3)
CreateTab("ESP", "tab_esp", 4)
CreateTab("Graphics", "tab_graphics", 5)
CreateTab("Hotkeys", "tab_hotkeys", 6)
CreateTab("Status", "tab_status", 7)
CreateTab("Settings", "tab_settings", 8)

local function Section(parent, titleKey, subtitleKey, order)
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitleKey and 50 or 30),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 15,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, holder),
		titleKey
	)

	if subtitleKey then
		RegisterText(
			New("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.fromOffset(0, 25),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Muted,
				TextSize = 9,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 47
			}, holder),
			subtitleKey
		)
	end
end

local function NoteCard(parent, titleKey, bodyKey, order, red)
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(card, 9)

	local dot = New("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.fromOffset(14, 17),
		BackgroundColor3 = red and Theme.Red or Theme.PurpleBright,
		BorderSizePixel = 0,
		ZIndex = 47
	}, card)
	Corner(dot, 3)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -42, 0, 18),
			Position = UDim2.fromOffset(28, 10),
			BackgroundTransparency = 1,
			TextColor3 = red and Theme.Red or Theme.White,
			TextSize = 10,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, card),
		titleKey
	)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -42, 0, 35),
			Position = UDim2.fromOffset(28, 31),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 47
		}, card),
		bodyKey
	)
end

local function ActionButton(parent, titleKey, subtitleKey, order, callback)
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
	Stroke(button, 0.58, 1, Theme.Stroke)

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Purple,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 47
	}, button)
	Corner(overlay, 9)

	local title = RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -28, 0, 18),
			Position = UDim2.fromOffset(14, 9),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 10,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 49
		}, button),
		titleKey
	)

	local subtitle = RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -28, 0, 15),
			Position = UDim2.fromOffset(14, 29),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 49
		}, button),
		subtitleKey
	)

	local scale = New("UIScale", {Scale = 1}, button)

	Bind(button.MouseEnter, function()
		Tween(overlay, 0.14, {
			BackgroundTransparency = 0.91
		}, Enum.EasingStyle.Quad)
		Tween(scale, 0.14, {Scale = 1.005}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(overlay, 0.14, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quad)
		Tween(scale, 0.14, {Scale = 1}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.06, {Scale = 0.988}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.08, {Scale = 1.005}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, callback)

	return {
		button = button,
		title = title,
		subtitle = subtitle,
		titleKey = titleKey,
		subtitleKey = subtitleKey
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

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, config.warning and -205 or -110, 0, 18),
			Position = UDim2.fromOffset(14, 11),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 11,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 48
		}, row),
		config.titleKey
	)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -115, 0, 16),
			Position = UDim2.fromOffset(14, 32),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 48
		}, row),
		config.subtitleKey
	)

	if config.warning then
		local warning = RegisterText(
			New("TextLabel", {
				Size = UDim2.fromOffset(82, 20),
				Position = UDim2.new(1, -150, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(54, 18, 23),
				BackgroundTransparency = 0.06,
				BorderSizePixel = 0,
				TextColor3 = Theme.Red,
				TextSize = 7,
				Font = Enum.Font.GothamBold,
				ZIndex = 49
			}, row),
			"heavy"
		)
		Corner(warning, 6)
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
			Position = enabled
				and UDim2.fromOffset(25, 3)
				or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Quad)
	end

	local function Set(enabled)
		State[config.id] = enabled
		Apply(enabled)

		if config.changed then
			config.changed(enabled)
		end

		if RefreshStatusPage then
			RefreshStatusPage()
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

local function CreateSlider(row, y, minimum, maximum, initial, callback, percent)
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
	Stroke(valueBox, 0.65, 1, Theme.Stroke)

	local track = New("Frame", {
		Size = UDim2.new(1, -140, 0, 4),
		Position = UDim2.fromOffset(14, y),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		ZIndex = 50
	}, row)
	Corner(track, 2)

	local fill = New("Frame", {
		Size = UDim2.fromScale((initial - minimum) / (maximum - minimum), 1),
		BackgroundColor3 = Theme.Purple,
		BorderSizePixel = 0,
		ZIndex = 51
	}, track)
	Corner(fill, 2)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((initial - minimum) / (maximum - minimum), 0, 0.5, 0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 52
	}, track)
	Corner(knob, 7)

	local hitbox = New("TextButton", {
		Size = UDim2.new(1, -122, 0, 30),
		Position = UDim2.fromOffset(5, y - 15),
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
		local numeric = tonumber(value) or current
		numeric = math.clamp(numeric, minimum, maximum)
		numeric = math.floor(numeric + 0.5)
		current = numeric

		local alpha = (numeric - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueBox.Text = tostring(numeric) .. (percent and "%" or "")
		callback(numeric)
	end

	local function SetFromX(x)
		if track.AbsoluteSize.X <= 0 then
			return
		end

		local alpha = math.clamp(
			(x - track.AbsolutePosition.X) / track.AbsoluteSize.X,
			0,
			1
		)
		SetValue(minimum + ((maximum - minimum) * alpha))
	end

	Bind(hitbox.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputChanged, function(input)
		if dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			) then

			SetFromX(input.Position.X)
		end
	end)

	Bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	Bind(valueBox.Focused, function()
		valueBox.Text = tostring(current)
		valueBox.CursorPosition = #valueBox.Text + 1
	end)

	Bind(valueBox.FocusLost, function()
		SetValue(ParseValue(valueBox.Text) or current)
	end)

	SetValue(initial)

	return {
		Set = SetValue,
		Box = valueBox
	}
end

local function CreateHotkeyRow(parent, id, titleKey, subtitleText, order)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(row, 9)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -160, 0, 18),
			Position = UDim2.fromOffset(14, 11),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 10,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, row),
		titleKey
	)

	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 16),
		Position = UDim2.fromOffset(14, 31),
		BackgroundTransparency = 1,
		Text = subtitleText,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, row)

	local button = New("TextButton", {
		Size = UDim2.fromOffset(128, 30),
		Position = UDim2.new(1, -142, 0.5, -15),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(Bindings[id]),
		TextColor3 = Theme.White,
		TextSize = 8,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(button, 7)
	Stroke(button, 0.55, 1, Theme.Stroke)

	HotkeyButtons[id] = button

	Bind(button.MouseButton1Click, function()
		Capture = {
			id = id,
			button = button
		}
		button.Text = T("press_key")
		button.TextColor3 = Theme.PurpleBright
	end)
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
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

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

	if RefreshStatusPage then
		RefreshStatusPage()
	end
end

local function StartSpeedManipulation()
	if State.speedManipulation then
		return
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not humanoid then
		return
	end

	State.speedManipulation = true
	SpeedManipSavedSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 2

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if SpeedManipSavedCollision[object] == nil then
				SpeedManipSavedCollision[object] = object.CanCollide
			end
			object.CanCollide = false
		end
	end

	if RefreshStatusPage then
		RefreshStatusPage()
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
	local root = character and character:FindFirstChild("HumanoidRootPart")

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

	local data = PlayerEspObjects[player]

	if data and data.character ~= character then
		DestroyPlayerEsp(player)
		data = nil
	end

	if not data then
		local highlight = New("Highlight", {
			Name = "LostHubPlayerESP",
			Adornee = character,
			FillColor = Theme.PurpleBright,
			FillTransparency = 0.72,
			OutlineColor = Theme.PurpleBright,
			OutlineTransparency = 0.02,
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
			TextStrokeColor3 = Theme.PurpleBright,
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
			label = label
		}

		PlayerEspObjects[player] = data
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot then
		distance = math.floor((localRoot.Position - root.Position).Magnitude + 0.5)
	end

	data.label.Text = player.DisplayName .. "  ·  " .. tostring(distance) .. "m"
end

local function ClearPlayerEsp()
	for player in pairs(PlayerEspObjects) do
		DestroyPlayerEsp(player)
	end
end

local function ApplyBetterTextureToObject(object)
	if TextureSaved[object] then
		return
	end

	if object:IsA("MeshPart") then
		local saved = {}
		local ok = pcall(function()
			saved.RenderFidelity = object.RenderFidelity
			object.RenderFidelity = Enum.RenderFidelity.Precise
		end)

		if ok then
			TextureSaved[object] = saved
		end

	elseif object:IsA("Model") then
		local saved = {}
		local ok = pcall(function()
			saved.LevelOfDetail = object.LevelOfDetail
			object.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
		end)

		if ok then
			TextureSaved[object] = saved
		end
	end
end

local function EnableBetterTextures()
	for _, object in ipairs(Workspace:GetDescendants()) do
		ApplyBetterTextureToObject(object)
	end
end

local function DisableBetterTextures()
	for object, saved in pairs(TextureSaved) do
		if object and object.Parent then
			pcall(function()
				if saved.RenderFidelity then
					object.RenderFidelity = saved.RenderFidelity
				end
				if saved.LevelOfDetail then
					object.LevelOfDetail = saved.LevelOfDetail
				end
			end)
		end
	end
	table.clear(TextureSaved)
end

local function ApplyBetterLightToObject(object)
	if LightSaved[object] then
		return
	end

	if object:IsA("PointLight")
		or object:IsA("SpotLight")
		or object:IsA("SurfaceLight") then

		LightSaved[object] = {
			type = "light",
			brightness = object.Brightness,
			range = object.Range,
			shadows = object.Shadows
		}

		object.Brightness = math.min(object.Brightness * 1.18 + 0.1, 10)
		object.Range = math.min(object.Range * 1.12 + 1, 100)
		object.Shadows = true

	elseif object:IsA("BasePart") then
		LightSaved[object] = {
			type = "part",
			castShadow = object.CastShadow
		}
		object.CastShadow = true
	end
end

local function EnableBetterLights()
	if not LightSaved._lighting then
		LightSaved._lighting = {
			GlobalShadows = Lighting.GlobalShadows,
			ShadowSoftness = Lighting.ShadowSoftness,
			Brightness = Lighting.Brightness,
			ExposureCompensation = Lighting.ExposureCompensation
		}
	end

	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.06
	Lighting.Brightness = math.max(Lighting.Brightness, 2.35)
	Lighting.ExposureCompensation = 0.05

	pcall(function()
		if LightSaved._technology == nil then
			LightSaved._technology = Lighting.Technology
		end
		Lighting.Technology = Enum.Technology.Future
	end)

	if not LightsEffects.Color then
		LightsEffects.Color = New("ColorCorrectionEffect", {
			Name = "LostHubLightsColor",
			Brightness = 0.02,
			Contrast = 0.11,
			Saturation = 0.07,
			TintColor = Color3.fromRGB(246, 243, 250)
		}, Lighting)
	end

	if not LightsEffects.Bloom then
		LightsEffects.Bloom = New("BloomEffect", {
			Name = "LostHubLightsBloom",
			Intensity = 0.30,
			Size = 28,
			Threshold = 1.1
		}, Lighting)
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		ApplyBetterLightToObject(object)
	end
end

local function DisableBetterLights()
	for _, effect in pairs(LightsEffects) do
		if effect then
			effect:Destroy()
		end
	end
	table.clear(LightsEffects)

	local lightingSaved = LightSaved._lighting
	local technologySaved = LightSaved._technology

	for object, saved in pairs(LightSaved) do
		if typeof(object) == "Instance" and object.Parent then
			if saved.type == "light" then
				object.Brightness = saved.brightness
				object.Range = saved.range
				object.Shadows = saved.shadows
			elseif saved.type == "part" then
				object.CastShadow = saved.castShadow
			end
		end
	end

	if lightingSaved then
		Lighting.GlobalShadows = lightingSaved.GlobalShadows
		Lighting.ShadowSoftness = lightingSaved.ShadowSoftness
		Lighting.Brightness = lightingSaved.Brightness
		Lighting.ExposureCompensation = lightingSaved.ExposureCompensation
	end

	if technologySaved then
		pcall(function()
			Lighting.Technology = technologySaved
		end)
	end

	table.clear(LightSaved)
end

local function ApplyReflectionToObject(object)
	if ReflectionSaved[object] then
		return
	end

	if object:IsA("BasePart")
		and (
			object.Material == Enum.Material.Metal
			or object.Material == Enum.Material.Glass
			or object.Material == Enum.Material.DiamondPlate
			or object.Material == Enum.Material.Foil
		) then

		ReflectionSaved[object] = object.Reflectance

		if object.Material == Enum.Material.Glass then
			object.Reflectance = math.max(object.Reflectance, 0.28)
		elseif object.Material == Enum.Material.Metal then
			object.Reflectance = math.max(object.Reflectance, 0.20)
		else
			object.Reflectance = math.max(object.Reflectance, 0.14)
		end
	end
end

local function EnableReflections()
	if ReflectionSaved._lighting == nil then
		ReflectionSaved._lighting = {
			specular = Lighting.EnvironmentSpecularScale,
			diffuse = Lighting.EnvironmentDiffuseScale
		}
	end

	Lighting.EnvironmentSpecularScale = 1
	Lighting.EnvironmentDiffuseScale = math.max(Lighting.EnvironmentDiffuseScale, 0.9)

	for _, object in ipairs(Workspace:GetDescendants()) do
		ApplyReflectionToObject(object)
	end
end

local function DisableReflections()
	local lightingSaved = ReflectionSaved._lighting

	for object, reflectance in pairs(ReflectionSaved) do
		if typeof(object) == "Instance" and object.Parent then
			object.Reflectance = reflectance
		end
	end

	if lightingSaved then
		Lighting.EnvironmentSpecularScale = lightingSaved.specular
		Lighting.EnvironmentDiffuseScale = lightingSaved.diffuse
	end

	table.clear(ReflectionSaved)
end

local function EnableEnvironment()
	if not EnvironmentSaved.lighting then
		EnvironmentSaved.lighting = {
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			ColorShift_Top = Lighting.ColorShift_Top,
			ColorShift_Bottom = Lighting.ColorShift_Bottom,
			FogEnd = Lighting.FogEnd
		}
	end

	if not State.fullBright then
		Lighting.Ambient = Color3.fromRGB(118, 121, 132)
		Lighting.OutdoorAmbient = Color3.fromRGB(146, 149, 160)
	end

	Lighting.ColorShift_Top = Color3.fromRGB(8, 6, 12)
	Lighting.ColorShift_Bottom = Color3.fromRGB(3, 3, 5)
	Lighting.FogEnd = math.max(Lighting.FogEnd, 1200)

	if not EnvironmentEffects.Atmosphere then
		EnvironmentEffects.Atmosphere = New("Atmosphere", {
			Name = "LostHubEnvironmentAtmosphere",
			Density = 0.18,
			Offset = 0.04,
			Color = Color3.fromRGB(218, 220, 228),
			Decay = Color3.fromRGB(85, 88, 98),
			Glare = 0.08,
			Haze = 0.42
		}, Lighting)
	end

	if not EnvironmentEffects.Sun then
		EnvironmentEffects.Sun = New("SunRaysEffect", {
			Name = "LostHubEnvironmentSun",
			Intensity = 0.07,
			Spread = 0.86
		}, Lighting)
	end

	if not EnvironmentEffects.Depth then
		EnvironmentEffects.Depth = New("DepthOfFieldEffect", {
			Name = "LostHubEnvironmentDepth",
			FarIntensity = 0.10,
			FocusDistance = 75,
			InFocusRadius = 58,
			NearIntensity = 0
		}, Lighting)
	end
end

local function DisableEnvironment()
	for _, effect in pairs(EnvironmentEffects) do
		if effect then
			effect:Destroy()
		end
	end
	table.clear(EnvironmentEffects)

	local saved = EnvironmentSaved.lighting
	if saved then
		if not State.fullBright then
			Lighting.Ambient = saved.Ambient
			Lighting.OutdoorAmbient = saved.OutdoorAmbient
		end
		Lighting.ColorShift_Top = saved.ColorShift_Top
		Lighting.ColorShift_Bottom = saved.ColorShift_Bottom
		Lighting.FogEnd = saved.FogEnd
	end

	EnvironmentSaved = {}
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
	LowSaved.lighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
	LowSaved.lighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(Workspace:GetDescendants()) do
		ApplyLowToObject(object)
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
	Lighting.Brightness = math.max(Lighting.Brightness, 2.6)
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

	if State.environment then
		EnableEnvironment()
	end
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

local function ApplyPanelBackground()
	local brightness = math.clamp(State.backgroundBrightness / 100, 0, 1)
	local value = 0.32 + brightness * 0.68
	local color = Color3.new(value, value, value)

	Background.ImageColor3 = color

	local blur = math.clamp(State.panelBlur / 100, 0, 1)

	for _, data in ipairs(BlurLayers) do
		local layer = data.image
		layer.ImageColor3 = color
		layer.ImageTransparency = 1 - (0.17 * blur)
		layer.Position = UDim2.fromOffset(
			data.offset.X * (0.5 + 1.4 * blur),
			data.offset.Y * (0.5 + 1.4 * blur)
		)
	end

	Background.ImageTransparency = 0.28 + (0.12 * blur)
	BackgroundShade.BackgroundTransparency = 0.14 - (0.03 * blur)
end

local function GetPlaceId(kind)
	local names = kind == "Game"
		and {"GamePlaceId", "GameplayPlaceId", "MapPlaceId"}
		or {"LobbyPlaceId", "HubPlaceId"}

	for _, source in ipairs({game, Workspace, ReplicatedStorage}) do
		for _, name in ipairs(names) do
			local value = source:GetAttribute(name)
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

	return nil
end

local function SpawnCFrame(object)
	if not object then
		return nil
	end

	if object:IsA("BasePart") or object:IsA("SpawnLocation") then
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

	local names = kind == "Game"
		and {
			"GameSpawn", "GameplaySpawn", "MapSpawn", "ArenaSpawn",
			"MatchSpawn", "RoundSpawn", "SpawnLocation", "Spawn",
			"StartPoint", "Start", "Entrance"
		}
		or {
			"LobbySpawn", "HubSpawn", "WaitingSpawn",
			"SpawnLocation", "Spawn", "StartPoint", "Start", "Entrance"
		}

	for _, name in ipairs(names) do
		local object = container:FindFirstChild(name, true)
		local cf = SpawnCFrame(object)
		if cf then
			return cf
		end
	end

	local spawn = container:FindFirstChildWhichIsA("SpawnLocation", true)
	return spawn and spawn.CFrame or nil
end

local function FindDestinationSpawn(kind)
	local containers = kind == "Game"
		and {"Game", "Gameplay", "Map", "Arena", "Match"}
		or {"Lobby", "Hub", "WaitingRoom"}

	for _, containerName in ipairs(containers) do
		local container = Workspace:FindFirstChild(containerName, true)
		if container then
			local cf = FindSpawnInside(container, kind)
			if cf then
				return cf
			end
		end
	end

	return nil
end

local function TeleportTo(kind, card)
	local placeId = GetPlaceId(kind)

	if placeId and placeId ~= game.PlaceId then
		card.title.Text = T("teleporting")

		local ok = pcall(function()
			TeleportService:Teleport(placeId, LocalPlayer)
		end)

		if not ok then
			card.title.Text = T("teleport_failed")
			task.delay(1.2, function()
				if card.title and card.title.Parent then
					card.title.Text = T(kind == "Game" and "game_tp" or "lobby_tp")
				end
			end)
		end
		return
	end

	local destination = FindDestinationSpawn(kind)
	local character = LocalPlayer.Character

	if destination and character then
		character:PivotTo(destination + Vector3.new(0, 4, 0))
		return
	end

	card.title.Text = T("spawn_not_found")
	task.delay(1.2, function()
		if card.title and card.title.Parent then
			card.title.Text = T(kind == "Game" and "game_tp" or "lobby_tp")
		end
	end)
end

Section(InfoPage, "info_subtitle", nil, 1)

local InfoCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 94),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, InfoPage)
Corner(InfoCard, 9)

New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 28),
	Position = UDim2.fromOffset(14, 14),
	BackgroundTransparency = 1,
	Text = "LOST HUB",
	TextColor3 = Theme.White,
	TextSize = 18,
	Font = Enum.Font.GothamBlack,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, InfoCard)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(14, 46),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, InfoCard),
	"info_version"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 16),
		Position = UDim2.fromOffset(14, 67),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted2,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, InfoCard),
	"info_runtime"
)

NoteCard(InfoPage, "note_development_title", "note_development_body", 3, false)
NoteCard(InfoPage, "note_performance_title", "note_performance_body", 4, true)
NoteCard(InfoPage, "note_menu_title", "note_menu_body", 5, false)

Section(MainPage, "main_title", "main_subtitle", 1)

local RejoinCard
RejoinCard = ActionButton(
	MainPage,
	"rejoin",
	"rejoin_sub",
	2,
	function()
		RejoinCard.title.Text = T("rejoining")
		local ok = pcall(function()
			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				game.JobId,
				LocalPlayer
			)
		end)

		if not ok then
			RejoinCard.title.Text = T("rejoin_failed")
			task.delay(1.2, function()
				if RejoinCard.title and RejoinCard.title.Parent then
					RejoinCard.title.Text = T("rejoin")
				end
			end)
		end
	end
)

local GameCard
GameCard = ActionButton(
	MainPage,
	"game_tp",
	"game_tp_sub",
	3,
	function()
		TeleportTo("Game", GameCard)
	end
)

local LobbyCard
LobbyCard = ActionButton(
	MainPage,
	"lobby_tp",
	"lobby_tp_sub",
	4,
	function()
		TeleportTo("Lobby", LobbyCard)
	end
)

ActionButton(
	MainPage,
	"respawn",
	"respawn_sub",
	5,
	function()
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end
)

Section(PlayerPage, "player_title", "player_subtitle", 1)

CreateToggle(PlayerPage, {
	id = "antiFling",
	titleKey = "anti_fling",
	subtitleKey = "anti_fling_sub",
	order = 2
})

CreateToggle(PlayerPage, {
	id = "noclip",
	titleKey = "noclip",
	subtitleKey = "noclip_sub",
	order = 3,
	changed = function(enabled)
		if not enabled and not State.speedManipulation then
			RestoreLocalCollision()
		end
	end
})

local WalkRow = CreateToggle(PlayerPage, {
	id = "walkSpeed",
	titleKey = "walk_speed",
	subtitleKey = "walk_speed_sub",
	order = 4,
	height = 102,
	changed = function(enabled)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			if enabled then
				if SavedWalkSpeed == nil then
					SavedWalkSpeed = humanoid.WalkSpeed
				end
				if not State.speedManipulation then
					humanoid.WalkSpeed = State.walkSpeedValue
				end
			else
				if SavedWalkSpeed ~= nil and not State.speedManipulation then
					humanoid.WalkSpeed = SavedWalkSpeed
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
		if State.walkSpeed and not State.speedManipulation then
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = value
			end
		end
	end,
	false
)

local FlyRow = CreateToggle(PlayerPage, {
	id = "fly",
	titleKey = "fly",
	subtitleKey = "fly_sub",
	order = 5,
	height = 102,
	changed = function(enabled)
		if enabled then
			CreateFly()
			if ShowFlyNotice then
				ShowFlyNotice()
			end
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

Section(EspPage, "esp_title", "esp_subtitle", 1)

CreateToggle(EspPage, {
	id = "playerEsp",
	titleKey = "player_esp",
	subtitleKey = "player_esp_sub",
	order = 2,
	changed = function(enabled)
		if not enabled then
			ClearPlayerEsp()
		end
	end
})

Section(GraphicsPage, "graphics_title", "graphics_subtitle", 1)

local HighFeatureIds = {
	"betterTextures",
	"betterLights",
	"reflections",
	"environment"
}

local function DisableLowIfNeeded()
	if State.lowGraphics and ToggleSetters.lowGraphics then
		ToggleSetters.lowGraphics(false)
	end
end

CreateToggle(GraphicsPage, {
	id = "betterTextures",
	titleKey = "better_textures",
	subtitleKey = "better_textures_sub",
	order = 2,
	warning = true,
	changed = function(enabled)
		if enabled then
			DisableLowIfNeeded()
			EnableBetterTextures()
		else
			DisableBetterTextures()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "betterLights",
	titleKey = "better_lights",
	subtitleKey = "better_lights_sub",
	order = 3,
	warning = true,
	changed = function(enabled)
		if enabled then
			DisableLowIfNeeded()
			EnableBetterLights()
		else
			DisableBetterLights()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "reflections",
	titleKey = "reflections",
	subtitleKey = "reflections_sub",
	order = 4,
	warning = true,
	changed = function(enabled)
		if enabled then
			DisableLowIfNeeded()
			EnableReflections()
		else
			DisableReflections()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "environment",
	titleKey = "environment",
	subtitleKey = "environment_sub",
	order = 5,
	warning = true,
	changed = function(enabled)
		if enabled then
			DisableLowIfNeeded()
			EnableEnvironment()
		else
			DisableEnvironment()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	titleKey = "low_graphics",
	subtitleKey = "low_graphics_sub",
	order = 6,
	changed = function(enabled)
		if enabled then
			for _, id in ipairs(HighFeatureIds) do
				if State[id] and ToggleSetters[id] then
					ToggleSetters[id](false)
				end
			end
			EnableLowGraphics()
		else
			DisableLowGraphics()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "fullBright",
	titleKey = "full_bright",
	subtitleKey = "full_bright_sub",
	order = 7,
	changed = function(enabled)
		if enabled then
			EnableFullBright()
		else
			DisableFullBright()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "fpsVisible",
	titleKey = "fps_display",
	subtitleKey = "fps_display_sub",
	order = 8,
	changed = function(enabled)
		if SetFpsVisible then
			SetFpsVisible(enabled)
		end
	end
})

Section(HotkeysPage, "hotkeys_title", "hotkeys_subtitle", 1)

local hotkeyRows = {
	{"speedManipulation", "speed_manip", "V  ·  Hold", 2},
	{"fly", "fly", "Toggle", 3},
	{"antiFling", "anti_fling", "Toggle", 4},
	{"noclip", "noclip", "Toggle", 5},
	{"walkSpeed", "walk_speed", "Toggle", 6},
	{"playerEsp", "player_esp", "Toggle", 7},
	{"betterTextures", "better_textures", "Toggle", 8},
	{"betterLights", "better_lights", "Toggle", 9},
	{"reflections", "reflections", "Toggle", 10},
	{"environment", "environment", "Toggle", 11},
	{"lowGraphics", "low_graphics", "Toggle", 12},
	{"fullBright", "full_bright", "Toggle", 13},
	{"fpsVisible", "fps_display", "Toggle", 14},
	{"instantInteract", "instant_interact", "Toggle", 15}
}

for _, config in ipairs(hotkeyRows) do
	CreateHotkeyRow(
		HotkeysPage,
		config[1],
		config[2],
		config[3],
		config[4]
	)
end

Section(StatusPage, "status_title", "status_subtitle", 1)

local StatusSummary = New("Frame", {
	Size = UDim2.new(1, 0, 0, 78),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 46
}, StatusPage)
Corner(StatusSummary, 9)

local ExecutionsLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 22),
	Position = UDim2.fromOffset(14, 13),
	BackgroundTransparency = 1,
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, StatusSummary)

local ActiveCountLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 18),
	Position = UDim2.fromOffset(14, 42),
	BackgroundTransparency = 1,
	TextColor3 = Theme.PurpleBright,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, StatusSummary)

local ActiveCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 110),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, StatusPage)
Corner(ActiveCard, 9)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		TextColor3 = Theme.PurpleBright,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, ActiveCard),
	"active"
)

local ActiveList = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 70),
	Position = UDim2.fromOffset(14, 34),
	BackgroundTransparency = 1,
	TextColor3 = Theme.Light,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 47
}, ActiveCard)

local DisabledCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 132),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 4,
	ZIndex = 46
}, StatusPage)
Corner(DisabledCard, 9)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, DisabledCard),
	"disabled"
)

local DisabledList = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 92),
	Position = UDim2.fromOffset(14, 34),
	BackgroundTransparency = 1,
	TextColor3 = Theme.Muted2,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 47
}, DisabledCard)

local FeatureNameKeys = {
	{"antiFling", "anti_fling"},
	{"noclip", "noclip"},
	{"walkSpeed", "walk_speed"},
	{"speedManipulation", "speed_manip"},
	{"fly", "fly"},
	{"playerEsp", "player_esp"},
	{"betterTextures", "better_textures"},
	{"betterLights", "better_lights"},
	{"reflections", "reflections"},
	{"environment", "environment"},
	{"lowGraphics", "low_graphics"},
	{"fullBright", "full_bright"},
	{"fpsVisible", "fps_display"},
	{"instantInteract", "instant_interact"}
}

RefreshStatusPage = function()
	local active = {}
	local disabled = {}

	for _, entry in ipairs(FeatureNameKeys) do
		local name = T(entry[2])
		if State[entry[1]] then
			table.insert(active, name)
		else
			table.insert(disabled, name)
		end
	end

	ExecutionsLabel.Text = T("executions")
		.. ": "
		.. tostring(_G.LostHubExecutionCount or 1)

	ActiveCountLabel.Text = T("active")
		.. ": "
		.. tostring(#active)

	ActiveList.Text = #active > 0
		and table.concat(active, "  ·  ")
		or T("none")

	DisabledList.Text = #disabled > 0
		and table.concat(disabled, "  ·  ")
		or T("none")
end

Section(SettingsPage, "settings_title", "settings_subtitle", 1)

CreateToggle(SettingsPage, {
	id = "instantInteract",
	titleKey = "instant_interact",
	subtitleKey = "instant_interact_sub",
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

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 18),
		Position = UDim2.fromOffset(14, 10),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, BlurRow),
	"panel_blur"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 15),
		Position = UDim2.fromOffset(14, 29),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, BlurRow),
	"panel_blur_sub"
)

CreateSlider(
	BlurRow,
	63,
	0,
	100,
	State.panelBlur,
	function(value)
		State.panelBlur = value
		ApplyPanelBackground()
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

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 18),
		Position = UDim2.fromOffset(14, 10),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, BrightnessRow),
	"background_brightness"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 15),
		Position = UDim2.fromOffset(14, 29),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, BrightnessRow),
	"background_brightness_sub"
)

CreateSlider(
	BrightnessRow,
	63,
	0,
	100,
	State.backgroundBrightness,
	function(value)
		State.backgroundBrightness = value
		ApplyPanelBackground()
	end,
	true
)

local LanguageRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 5,
	ZIndex = 46
}, SettingsPage)
Corner(LanguageRow, 9)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 18),
		Position = UDim2.fromOffset(14, 11),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, LanguageRow),
	"language"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 16),
		Position = UDim2.fromOffset(14, 32),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, LanguageRow),
	"language_sub"
)

local LanguageButton = New("TextButton", {
	Size = UDim2.fromOffset(128, 30),
	Position = UDim2.new(1, -142, 0.5, -15),
	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
	Text = "English",
	TextColor3 = Theme.White,
	TextSize = 8,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
	ZIndex = 48
}, LanguageRow)
Corner(LanguageButton, 7)
Stroke(LanguageButton, 0.55, 1, Theme.Stroke)

local function ApplyLanguage()
	RefreshLanguage()

	LanguageButton.Text = Language == "en"
		and Strings.en.english
		or Strings.pt.portuguese

	for id, button in pairs(HotkeyButtons) do
		if button and button.Parent then
			button.Text = FormatBinding(Bindings[id])
		end
	end

	RefreshStatusPage()
end

Bind(LanguageButton.MouseButton1Click, function()
	Language = Language == "en" and "pt" or "en"
	ApplyLanguage()
end)

Bind(Profile.MouseButton1Click, function()
	SelectPage("Status")
end)

local StatusHud = New("CanvasGroup", {
	Name = "StatusHud",
	Size = UDim2.fromOffset(68, 34),
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.04,
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

local FlyNotice = RegisterText(
	New("TextLabel", {
		Size = UDim2.fromOffset(260, 34),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 54),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		TextColor3 = Theme.White,
		TextSize = 9,
		Font = Enum.Font.GothamSemibold,
		Visible = false,
		TextTransparency = 1,
		BackgroundTransparency = 1,
		ZIndex = 702
	}, ScreenGui),
	"fly_notice"
)
Corner(FlyNotice, 9)

ShowFlyNotice = function()
	FlyNoticeToken += 1
	local token = FlyNoticeToken

	FlyNotice.Visible = true
	FlyNotice.TextTransparency = 1
	FlyNotice.BackgroundTransparency = 1

	Tween(FlyNotice, 0.18, {
		TextTransparency = 0,
		BackgroundTransparency = 0.05
	}, Enum.EasingStyle.Sine)

	task.delay(2.2, function()
		if token ~= FlyNoticeToken then
			return
		end

		local fade = Tween(FlyNotice, 0.18, {
			TextTransparency = 1,
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Sine)

		fade.Completed:Once(function()
			if token == FlyNoticeToken then
				FlyNotice.Visible = false
			end
		end)
	end)
end

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
	local id = MenuAnimationId

	State.menuVisible = visible

	if visible then
		PreviousMouseBehavior = UserInputService.MouseBehavior
		PreviousMouseIconEnabled = UserInputService.MouseIconEnabled

		Main.Visible = true
		Main.GroupTransparency = 1
		MainScale.Scale = 0.955
		Background.ImageTransparency = 0.60

		ApplyPanelBackground()

		Tween(MainScale, 0.38, {
			Scale = 1
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Main, 0.26, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		Tween(Background, 0.44, {
			ImageTransparency = 0.28 + (0.12 * State.panelBlur / 100)
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		StopSpeedManipulation()

		Tween(MainScale, 0.22, {
			Scale = 0.965
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		local fade = Tween(Main, 0.21, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

		fade.Completed:Once(function()
			if id == MenuAnimationId and not State.menuVisible then
				Main.Visible = false
				UserInputService.MouseBehavior = PreviousMouseBehavior
				UserInputService.MouseIconEnabled = PreviousMouseIconEnabled
			end
		end)
	end
end

SetFpsVisible = function(visible)
	FpsAnimationId += 1
	local id = FpsAnimationId
	State.fpsVisible = visible

	if visible then
		StatusHud.Visible = true
		StatusHud.GroupTransparency = 1
		HudScale.Scale = 0.96

		Tween(HudScale, 0.25, {
			Scale = 1
		}, Enum.EasingStyle.Quint)

		Tween(StatusHud, 0.18, {
			GroupTransparency = 0
		}, Enum.EasingStyle.Sine)
	else
		local fade = Tween(StatusHud, 0.16, {
			GroupTransparency = 1
		}, Enum.EasingStyle.Sine)

		Tween(HudScale, 0.16, {
			Scale = 0.97
		}, Enum.EasingStyle.Quart)

		fade.Completed:Once(function()
			if id == FpsAnimationId and not State.fpsVisible then
				StatusHud.Visible = false
			end
		end)
	end
end

Bind(UserInputService.InputBegan, function(input, gameProcessed)
	if Capture then
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == Enum.KeyCode.Escape then

			Capture.button.Text = FormatBinding(Bindings[Capture.id])
			Capture.button.TextColor3 = Theme.White
			Capture = nil
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard
			and (
				input.KeyCode == Enum.KeyCode.Backspace
				or input.KeyCode == Enum.KeyCode.Delete
			) then

			Bindings[Capture.id] = nil
			Capture.button.Text = T("set")
			Capture.button.TextColor3 = Theme.White
			Capture = nil
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

		Capture.button.Text = FormatBinding(Bindings[Capture.id])
		Capture.button.TextColor3 = Theme.White
		Capture = nil
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.LeftShift then

		SetMenuVisible(not State.menuVisible)
		return
	end

	if UserInputService:GetFocusedTextBox() then
		return
	end

	if BindingMatches(Bindings.speedManipulation, input) then
		StartSpeedManipulation()
		return
	end

	if gameProcessed then
		return
	end

	for id, binding in pairs(Bindings) do
		if id ~= "speedManipulation"
			and BindingMatches(binding, input) then

			local setter = ToggleSetters[id]
			if setter then
				setter(not State[id])
			end
			return
		end
	end
end)

Bind(UserInputService.InputEnded, function(input)
	if BindingMatches(Bindings.speedManipulation, input) then
		StopSpeedManipulation()
	end
end)

Bind(RunService.Stepped, function()
	local character = LocalPlayer.Character

	if State.noclip and character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				if SavedLocalCollision[object] == nil then
					SavedLocalCollision[object] = object.CanCollide
				end
				object.CanCollide = false
			end
		end
	elseif not State.speedManipulation and next(SavedLocalCollision) then
		RestoreLocalCollision()
	end

	if State.speedManipulation and character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = 2
		end

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				if SpeedManipSavedCollision[object] == nil then
					SpeedManipSavedCollision[object] = object.CanCollide
				end
				object.CanCollide = false
			end
		end
	end
end)

Bind(RunService.Heartbeat, function()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if State.walkSpeed and humanoid and not State.speedManipulation then
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
				for _, object in ipairs(player.Character:GetDescendants()) do
					if object:IsA("BasePart") then
						if SavedOtherCollision[object] == nil then
							SavedOtherCollision[object] = object.CanCollide
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
	if State.betterTextures then
		task.defer(function()
			if object.Parent then
				ApplyBetterTextureToObject(object)
			end
		end)
	end

	if State.betterLights then
		task.defer(function()
			if object.Parent then
				ApplyBetterLightToObject(object)
			end
		end)
	end

	if State.reflections then
		task.defer(function()
			if object.Parent then
				ApplyReflectionToObject(object)
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

	if State.instantInteract and object:IsA("ProximityPrompt") then
		task.defer(function()
			if object.Parent then
				if InstantSaved[object] == nil then
					InstantSaved[object] = object.HoldDuration
				end
				object.HoldDuration = 0
			end
		end)
	end
end)

local FrameCount = 0
local FrameElapsed = 0
local FpsAccumulator = 0
local StatusAccumulator = 0
local CurrentFps = 0

Bind(RunService.RenderStepped, function(deltaTime)
	FrameCount += 1
	FrameElapsed += deltaTime
	FpsAccumulator += deltaTime
	StatusAccumulator += deltaTime

	if State.menuVisible then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end

	if State.fly and FlyVelocity and FlyGyro then
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root and Camera then
			local targetPosition = Mouse.Hit.Position
			local forward = targetPosition - root.Position

			if forward.Magnitude > 0.001 then
				forward = forward.Unit
			else
				forward = Camera.CFrame.LookVector
			end

			local right = forward:Cross(Vector3.yAxis)

			if right.Magnitude > 0.001 then
				right = right.Unit
			else
				right = Camera.CFrame.RightVector
			end

			local movement = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				movement += forward
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				movement -= forward
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				movement += right
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				movement -= right
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.E) then
				movement += Vector3.yAxis
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
				movement -= Vector3.yAxis
			end

			if movement.Magnitude > 0 then
				movement = movement.Unit * State.flySpeed
			end

			FlyVelocity.Velocity = movement
			FlyGyro.CFrame = CFrame.lookAt(
				root.Position,
				root.Position + forward
			)
		end
	end

	if FrameElapsed >= 0.5 then
		CurrentFps = math.floor((FrameCount / FrameElapsed) + 0.5)
		FrameCount = 0
		FrameElapsed = 0
	end

	if FpsAccumulator >= (1 / 30) then
		FpsLabel.Text = tostring(CurrentFps)
		FpsAccumulator = 0
	end

	if StatusAccumulator >= 0.4 then
		RefreshStatusPage()
		StatusAccumulator = 0
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
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid and State.walkSpeed then
			SavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = State.walkSpeedValue
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
		Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="
			.. tostring(LocalPlayer.UserId)
			.. "&w=150&h=150"
	end
end)

task.spawn(function()
	local preload = {Background, HubIcon, Avatar}
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
	State.betterTextures = false
	State.betterLights = false
	State.reflections = false
	State.environment = false
	State.lowGraphics = false
	State.fullBright = false
	State.fpsVisible = false
	State.instantInteract = false

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed = SavedWalkSpeed
	end

	SavedWalkSpeed = nil

	RestoreLocalCollision()
	RestoreOtherCollision()
	ClearPlayerEsp()
	DisableBetterTextures()
	DisableBetterLights()
	DisableReflections()
	DisableEnvironment()
	DisableLowGraphics()
	DisableFullBright()
	DisableInstantInteract()

	for _, connection in ipairs(Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(Connections)

	UserInputService.MouseBehavior = PreviousMouseBehavior
	UserInputService.MouseIconEnabled = PreviousMouseIconEnabled

	if ScreenGui and ScreenGui.Parent then
		ScreenGui:Destroy()
	end

	if _G.LostHubCleanup == Cleanup then
		_G.LostHubCleanup = nil
	end
end

_G.LostHubCleanup = Cleanup

SelectPage("Info")
ApplyPanelBackground()
SetFpsVisible(false)
RefreshStatusPage()
ApplyLanguage()

task.spawn(function()
	Tween(IntroScale, 0.45, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(IntroLine, 0.48, {
		Size = UDim2.fromOffset(180, 1)
	}, Enum.EasingStyle.Quint)

	task.wait(0.55)

	local fade = Tween(Intro, 0.30, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	Tween(IntroScale, 0.30, {
		Scale = 1.02
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	fade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false

	PreviousMouseBehavior = UserInputService.MouseBehavior
	PreviousMouseIconEnabled = UserInputService.MouseIconEnabled

	Main.Visible = true
	Main.GroupTransparency = 1
	MainScale.Scale = 0.955
	Background.ImageTransparency = 0.62

	ApplyPanelBackground()

	Tween(MainScale, 0.42, {
		Scale = 1
	}, Enum.EasingStyle.Quint)

	Tween(Main, 0.26, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Sine)

	Tween(Background, 0.44, {
		ImageTransparency = 0.28 + (0.12 * State.panelBlur / 100)
	}, Enum.EasingStyle.Quint)
end)

