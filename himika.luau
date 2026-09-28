if _G.LostHubCleanup then
	pcall(_G.LostHubCleanup)
	_G.LostHubCleanup = nil
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
local previousExecutionCount = math.max(
	tonumber(_G.LostHubExecutionCount) or 0,
	tonumber(LocalPlayer:GetAttribute("LostHubExecutionCount")) or 0
)
_G.LostHubExecutionCount = previousExecutionCount + 1
pcall(function()
	LocalPlayer:SetAttribute("LostHubExecutionCount", _G.LostHubExecutionCount)
end)

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
	Base = Color3.fromRGB(5, 5, 8),
	Surface = Color3.fromRGB(12, 11, 16),
	Surface2 = Color3.fromRGB(19, 17, 25),
	Surface3 = Color3.fromRGB(29, 25, 39),
	Surface4 = Color3.fromRGB(39, 34, 50),
	White = Color3.fromRGB(244, 243, 248),
	Light = Color3.fromRGB(207, 203, 216),
	Muted = Color3.fromRGB(145, 139, 156),
	Muted2 = Color3.fromRGB(96, 91, 106),
	Black = Color3.fromRGB(0, 0, 0),
	Off = Color3.fromRGB(49, 45, 58),
	Purple = Color3.fromRGB(126, 82, 188),
	PurpleBright = Color3.fromRGB(177, 126, 239),
	PurpleSoft = Color3.fromRGB(73, 49, 101),
	Red = Color3.fromRGB(222, 82, 94),
	Stroke = Color3.fromRGB(61, 55, 72)
}

local Language = "en"

local Strings = {
	en = {
		tab_info = "Info",
		tab_main = "Main",
		tab_player = "Player",
		tab_esp = "ESP",
		tab_graphics = "Graphics",
		tab_status = "Status",
		tab_settings = "Settings",

		top_subtitle = "K",
		info_subtitle = "Build notes and runtime warnings",
		info_version = "Development build",
		info_runtime = "Runtime features start disabled.",
		note_development_title = "Development",
		note_development_body = "This build is still being tested. Features and behavior may change.",
		note_performance_title = "Performance",
		note_performance_body = "Red labels mark heavier options that may reduce performance in large or generated rooms.",
		note_menu_title = "Menu shortcut",
		note_menu_body = "Ctrl opens or closes the menu by default. You can change it in Settings.",

		main_title = "Session",
		main_subtitle = "Server and spawn controls",
		rejoin = "REJOIN SERVER",
		rejoin_sub = "Reconnect to this server instance",
		game_tp = "GO TO GAME",
		game_tp_sub = "Teleport to the Game SpawnLocation",
		lobby_tp = "GO TO LOBBY",
		lobby_tp_sub = "Teleport to the Lobby SpawnLocation",
		respawn = "RESPAWN",
		respawn_sub = "Respawn your character",

		player_title = "Player",
		player_subtitle = "Movement and protection",
		anti_fling = "Anti-Fling",
		anti_fling_sub = "Limits unwanted velocity and collision pushes",
		noclip = "Noclip",
		noclip_sub = "Disable collision on your character",
		walk_speed = "Walk Speed",
		walk_speed_sub = "Set your movement speed",
		fly = "Fly",
		fly_sub = "Move freely through the air",
		fly_notice = "Fly enabled  ·  Q down  ·  E up",
		speed_manip = "Speed Manipulation",
		speed_manip_sub = "Hold the assigned key for noclip + WalkSpeed 2",

		esp_title = "Player ESP",
		esp_subtitle = "Player names and distance overlay",
		player_esp = "Player ESP",
		player_esp_sub = "Show names and distance for players",

		graphics_title = "Graphics",
		graphics_subtitle = "Visual quality and performance",
		graphics_boost = "Enhanced Graphics",
		graphics_boost_sub = "Boost lighting, reflections, atmosphere and detail",
		better_textures = "Better Textures",
		better_textures_sub = "Sharper mesh rendering and reduced model LOD",
		better_lights = "Better Lights",
		better_lights_sub = "Future lighting, shadows and stronger local lights",
		reflections = "Reflections",
		reflections_sub = "Increase specular response on reflective materials",
		environment = "Environment",
		environment_sub = "Atmosphere, sun rays and depth effects",
		low_graphics = "Low Graphics",
		low_graphics_sub = "Reduce particles, materials and expensive effects",
		full_bright = "Full Bright",
		full_bright_sub = "Increase visibility and reduce distant fog",
		fps_display = "FPS Counter",
		fps_display_sub = "Numeric FPS counter updated at up to 30 Hz",
		heavy = "HEAVY",

		status_title = "Runtime Status",
		status_subtitle = "Executions and current features",
		executions = "Executions",
		active = "ENABLED",
		disabled = "DISABLED",
		none = "None",

		settings_title = "Settings",
		settings_subtitle = "Interface and interaction",
		menu_hotkey = "Menu Shortcut",
		menu_hotkey_sub = "Key used to open and close the menu",
		panel_blur = "Panel Blur",
		panel_blur_sub = "Soften the artwork inside the menu",
		background_brightness = "Background Brightness",
		background_brightness_sub = "Adjust the menu artwork brightness",
		ui_transparency = "Interface Transparency",
		ui_transparency_sub = "Adjust cards, option surfaces and buttons",
		language = "Language",
		language_sub = "Switch between ENG and PT-BR",
		english = "ENG",
		portuguese = "PT-BR",

		instant_interact = "Instant Interact",
		instant_interact_sub = "Remove ProximityPrompt hold time",

		teleporting = "TELEPORTING...",
		teleport_failed = "TELEPORT FAILED",
		spawn_not_found = "SPAWN NOT FOUND",
		rejoining = "REJOINING...",
		rejoin_failed = "REJOIN FAILED",
		press_key = "PRESS A KEY",
		set = "..."
	},
	ptbr = {
		tab_info = "Info",
		tab_main = "Principal",
		tab_player = "Jogador",
		tab_esp = "ESP",
		tab_graphics = "Gráficos",
		tab_status = "Status",
		tab_settings = "Ajustes",

		top_subtitle = "painel utilitário",
		info_subtitle = "Notas da versão e avisos",
		info_version = "Versão em desenvolvimento",
		info_runtime = "Os recursos começam desativados.",
		note_development_title = "Desenvolvimento",
		note_development_body = "Esta versão ainda está em testes. Recursos e comportamentos podem mudar.",
		note_performance_title = "Desempenho",
		note_performance_body = "Rótulos vermelhos indicam opções mais pesadas, que podem reduzir o desempenho em salas grandes ou geradas.",
		note_menu_title = "Atalho do menu",
		note_menu_body = "Ctrl abre ou fecha o menu por padrão. Você pode trocar a tecla nos Ajustes.",

		main_title = "Sessão",
		main_subtitle = "Controles de servidor e spawn",
		rejoin = "REENTRAR NO SERVIDOR",
		rejoin_sub = "Reconecta a esta mesma instância",
		game_tp = "IR PARA O JOGO",
		game_tp_sub = "Teleporta para o SpawnLocation do jogo",
		lobby_tp = "IR PARA O LOBBY",
		lobby_tp_sub = "Teleporta para o SpawnLocation do lobby",
		respawn = "REAPARECER",
		respawn_sub = "Faz seu personagem reaparecer",

		player_title = "Jogador",
		player_subtitle = "Movimento e proteção",
		anti_fling = "Anti-Fling",
		anti_fling_sub = "Limita impulsos de velocidade e colisões",
		noclip = "Noclip",
		noclip_sub = "Desativa a colisão do seu personagem",
		walk_speed = "Velocidade",
		walk_speed_sub = "Define a velocidade de movimento",
		fly = "Voo",
		fly_sub = "Permite se mover livremente pelo ar",
		fly_notice = "Voo ativado  ·  Q desce  ·  E sobe",
		speed_manip = "Manipulação de Velocidade",
		speed_manip_sub = "Segure a tecla escolhida para noclip + WalkSpeed 2",

		esp_title = "ESP de Jogadores",
		esp_subtitle = "Nome e distância dos jogadores na tela",
		player_esp = "ESP de Jogadores",
		player_esp_sub = "Mostra nome e distância dos jogadores",

		graphics_title = "Gráficos",
		graphics_subtitle = "Qualidade visual e desempenho",
		graphics_boost = "Gráficos Aprimorados",
		graphics_boost_sub = "Melhora iluminação, reflexos, atmosfera e detalhes",
		better_textures = "Texturas Aprimoradas",
		better_textures_sub = "Melhora meshes e reduz a perda de detalhe por LOD",
		better_lights = "Iluminação Aprimorada",
		better_lights_sub = "Usa Future, sombras e luzes locais mais fortes",
		reflections = "Reflexos",
		reflections_sub = "Aumenta o brilho especular de materiais reflexivos",
		environment = "Ambiente",
		environment_sub = "Adiciona atmosfera, raios solares e profundidade",
		low_graphics = "Gráficos Leves",
		low_graphics_sub = "Reduz partículas, materiais e efeitos pesados",
		full_bright = "Visibilidade Máxima",
		full_bright_sub = "Aumenta a luz ambiente e reduz a neblina distante",
		fps_display = "Contador de FPS",
		fps_display_sub = "Mostra apenas o FPS, atualizado em até 30 Hz",
		heavy = "PESADO",

		status_title = "Status da Execução",
		status_subtitle = "Execuções e recursos atuais",
		executions = "Execuções",
		active = "ATIVOS",
		disabled = "DESATIVADOS",
		none = "Nenhum",

		settings_title = "Ajustes",
		settings_subtitle = "Interface e interação",
		menu_hotkey = "Atalho do Menu",
		menu_hotkey_sub = "Tecla usada para abrir e fechar o menu",
		panel_blur = "Desfoque do Painel",
		panel_blur_sub = "Suaviza a arte dentro do menu",
		background_brightness = "Brilho do Fundo",
		background_brightness_sub = "Ajusta o brilho da arte do menu",
		ui_transparency = "Transparência da Interface",
		ui_transparency_sub = "Ajusta cartões, opções e botões",
		language = "Idioma",
		language_sub = "Alterna entre ENG e PT-BR",
		english = "ENG",
		portuguese = "PT-BR",

		instant_interact = "Interação Instantânea",
		instant_interact_sub = "Remove o tempo de segurar do ProximityPrompt",

		teleporting = "TELEPORTANDO...",
		teleport_failed = "FALHA NO TELEPORTE",
		spawn_not_found = "SPAWN NÃO ENCONTRADO",
		rejoining = "REENTRANDO...",
		rejoin_failed = "FALHA AO REENTRAR",
		press_key = "PRESSIONE UMA TECLA",
		set = "..."
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
	graphicsBoost = false,
	lowGraphics = false,
	fullBright = false,
	fpsVisible = false,
	instantInteract = false,
	walkSpeedValue = 16,
	flySpeed = 30,
	panelBlur = 0,
	backgroundBrightness = 48,
	uiTransparency = 8,
	menuVisible = true
}

local Bindings = {
	menu = {
		kind = "Control"
	},
	antiFling = nil,
	noclip = nil,
	walkSpeed = nil,
	speedManipulation = {
		kind = "KeyCode",
		value = Enum.KeyCode.V
	},
	fly = nil,
	playerEsp = nil,
	graphicsBoost = nil,
	lowGraphics = nil,
	fullBright = nil,
	fpsVisible = {
		kind = "KeyCode",
		value = Enum.KeyCode.F4
	},
	instantInteract = nil
}

local HotkeyCapable = {
	antiFling = true,
	noclip = true,
	walkSpeed = true,
	speedManipulation = true,
	fly = true,
	playerEsp = true,
	graphicsBoost = true,
	lowGraphics = true,
	fullBright = true,
	fpsVisible = true,
	instantInteract = true
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

	if binding.kind == "Control" then
		return "CTRL"
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

	if binding.kind == "Control" then
		return input.UserInputType == Enum.UserInputType.Keyboard
			and (
				input.KeyCode == Enum.KeyCode.LeftControl
				or input.KeyCode == Enum.KeyCode.RightControl
			)
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

local function SameBinding(a, b)
	if not a or not b then
		return false
	end

	if a.kind == "Control" and b.kind == "Control" then
		return true
	end

	return a.kind == b.kind and a.value == b.value
end

local function AssignBinding(id, binding)
	if id ~= "menu"
		and binding
		and Bindings.menu
		and SameBinding(Bindings.menu, binding) then

		local button = HotkeyButtons[id]
		if button and button.Parent then
			button.TextColor3 = Theme.Red
			task.delay(0.28, function()
				if button and button.Parent then
					button.Text = FormatBinding(Bindings[id])
					button.TextColor3 = Theme.Light
				end
			end)
		end
		return false
	end

	if binding then
		for otherId, otherBinding in pairs(Bindings) do
			if otherId ~= id and SameBinding(otherBinding, binding) then
				if id == "menu" or otherId ~= "menu" then
					Bindings[otherId] = nil
					local otherButton = HotkeyButtons[otherId]
					if otherButton and otherButton.Parent then
						otherButton.Text = FormatBinding(nil)
						otherButton.TextColor3 = Theme.Light
					end
				end
			end
		end
	end

	if id == "menu" and not binding then
		binding = {kind = "Control"}
	end

	Bindings[id] = binding

	local button = HotkeyButtons[id]
	if button and button.Parent then
		button.Text = FormatBinding(binding)
		button.TextColor3 = Theme.Light
	end

	return true
end

local function BeginHotkeyCapture(id, button)
	if Capture and Capture.button and Capture.button.Parent then
		Capture.button.Text = FormatBinding(Bindings[Capture.id])
		Capture.button.TextColor3 = Theme.Light
	end

	Capture = {
		id = id,
		button = button
	}

	button.Text = "..."
	button.TextColor3 = Theme.PurpleBright
end

local function IsForbiddenHotkey(keyCode)
	local forbidden = {
		Unknown = true,
		Escape = true,
		Tab = true,
		LeftSuper = true,
		RightSuper = true,
		LeftMeta = true,
		RightMeta = true,
		Menu = true,
	}

	return forbidden[keyCode.Name] == true
end

local UITransparencyTargets = {}

local function ResolveUITransparency(baseTransparency)
	local amount = math.clamp((State.uiTransparency or 0) / 100, 0, 0.92)
	local base = math.clamp(baseTransparency or 0, 0, 1)
	return math.clamp(base + ((1 - base) * amount), 0, 0.97)
end

local function RegisterUITransparency(instance, baseTransparency)
	UITransparencyTargets[instance] = baseTransparency or 0
	if instance and instance.Parent then
		instance.BackgroundTransparency = ResolveUITransparency(baseTransparency or 0)
	end
	return instance
end

local function ApplyUITransparency()
	for instance, baseTransparency in pairs(UITransparencyTargets) do
		if instance and instance.Parent then
			instance.BackgroundTransparency = ResolveUITransparency(baseTransparency)
		else
			UITransparencyTargets[instance] = nil
		end
	end
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
	BackgroundColor3 = Theme.Base,
	BackgroundTransparency = 0,
	GroupTransparency = 0,
	ZIndex = 2000
}, ScreenGui)

local IntroBackdrop = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(8, 7, 12),
	BorderSizePixel = 0,
	ZIndex = 2000
}, Intro)

local IntroGradient = New("UIGradient", {
	Rotation = -35,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 6, 9)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(18, 13, 27)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 10))
	})
}, IntroBackdrop)

local IntroGlow = New("Frame", {
	Size = UDim2.fromOffset(250, 250),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Theme.Purple,
	BackgroundTransparency = 0.88,
	BorderSizePixel = 0,
	ZIndex = 2001
}, Intro)
Corner(IntroGlow, 125)

local IntroGlowGradient = New("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.28),
		NumberSequenceKeypoint.new(0.62, 0.74),
		NumberSequenceKeypoint.new(1, 1)
	})
}, IntroGlow)

local IntroRing = New("Frame", {
	Size = UDim2.fromOffset(118, 118),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Rotation = -18,
	ZIndex = 2002
}, Intro)
Corner(IntroRing, 59)
local IntroRingStroke = Stroke(IntroRing, 0.35, 1.4, Theme.PurpleBright)

local IntroRingInner = New("Frame", {
	Size = UDim2.fromOffset(94, 94),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 2002
}, Intro)
Corner(IntroRingInner, 47)
Stroke(IntroRingInner, 0.72, 1, Theme.Light)

local IntroCenter = New("CanvasGroup", {
	Size = UDim2.fromOffset(80, 80),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ZIndex = 2004
}, Intro)
Corner(IntroCenter, 22)
Stroke(IntroCenter, 0.34, 1, Theme.Stroke)

local IntroIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(54, 54),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ImageTransparency = 0,
	ZIndex = 2005
}, IntroCenter)

local IntroIconScale = New("UIScale", {
	Scale = 0.72
}, IntroCenter)

local IntroRingScale = New("UIScale", {
	Scale = 0.76
}, IntroRing)

local IntroProgress = New("Frame", {
	Size = UDim2.fromOffset(168, 3),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 92),
	BackgroundColor3 = Theme.Surface3,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	ZIndex = 2003
}, Intro)
Corner(IntroProgress, 2)

local IntroProgressFill = New("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = Theme.PurpleBright,
	BorderSizePixel = 0,
	ZIndex = 2004
}, IntroProgress)
Corner(IntroProgressFill, 2)

local IntroDots = {}
for index = 1, 3 do
	local dot = New("Frame", {
		Size = UDim2.fromOffset(5, 5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, (index - 2) * 14, 0.5, 111),
		BackgroundColor3 = index == 2 and Theme.PurpleBright or Theme.Light,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 2004
	}, Intro)
	Corner(dot, 3)
	table.insert(IntroDots, dot)
end

local IntroSparkles = {}
for index = 1, 8 do
	local angle = math.rad((index - 1) * 45)
	local radius = index % 2 == 0 and 82 or 72
	local dot = New("Frame", {
		Size = UDim2.fromOffset(index % 3 == 0 and 4 or 3, index % 3 == 0 and 4 or 3),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius),
		BackgroundColor3 = index % 2 == 0 and Theme.PurpleBright or Theme.White,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 2003
	}, Intro)
	Corner(dot, 3)
	table.insert(IntroSparkles, dot)
end

local Main = New("CanvasGroup", {
	Name = "Main",
	Size = UDim2.fromOffset(900, 580),
	Position = UDim2.new(0.5, -450, 0.5, -290),
	BackgroundColor3 = Theme.Base,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20
}, ScreenGui)
Corner(Main, 9)

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
Corner(Background, 9)

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
	Corner(layer, 12)
	table.insert(BlurLayers, {
		image = layer,
		offset = offset
	})
end

local BackgroundShade = New("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Black,
	BackgroundTransparency = 0.20,
	BorderSizePixel = 0,
	ZIndex = 21
}, Main)
Corner(BackgroundShade, 9)

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 68),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.10,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 50
}, Main)
RegisterUITransparency(TopBar, 0.10)

local HubIconBox = New("Frame", {
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.fromOffset(14, 11),
	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
	ZIndex = 51
}, TopBar)
Corner(HubIconBox, 10)
RegisterUITransparency(HubIconBox, 0)

local HubIcon = New("ImageLabel", {
	Size = UDim2.fromOffset(34, 34),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = AssetThumbnail(HUB_ICON_ASSET_ID),
	ZIndex = 52
}, HubIconBox)

local Sidebar = New("Frame", {
	Size = UDim2.new(0, 190, 1, -68),
	Position = UDim2.fromOffset(0, 68),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.09,
	BorderSizePixel = 0,
	ZIndex = 45
}, Main)
RegisterUITransparency(Sidebar, 0.09)

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
RegisterUITransparency(Profile, 0.25)

local ProfileScale = New("UIScale", {Scale = 1}, Profile)

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
	TextSize = 12,
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
	TextSize = 10,
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
	Tween(UsernameCover, 0.20, {
		Size = UDim2.new(0, 0, 0, 10),
		BackgroundTransparency = 1
	}, Enum.EasingStyle.Quint)
	Tween(ProfileScale, 0.20, {Scale = 1.018}, Enum.EasingStyle.Quint)
	Tween(Profile, 0.20, {BackgroundColor3 = Theme.Surface3}, Enum.EasingStyle.Quart)
end)

Bind(Profile.MouseLeave, function()
	Tween(UsernameCover, 0.20, {
		Size = UDim2.new(1, -64, 0, 10),
		BackgroundTransparency = 0
	}, Enum.EasingStyle.Quint)
	Tween(ProfileScale, 0.20, {Scale = 1}, Enum.EasingStyle.Quint)
	Tween(Profile, 0.20, {BackgroundColor3 = Theme.Surface2}, Enum.EasingStyle.Quart)
end)

Bind(Profile.MouseButton1Down, function()
	Tween(ProfileScale, 0.07, {Scale = 0.975}, Enum.EasingStyle.Quart)
end)

Bind(Profile.MouseButton1Up, function()
	Tween(ProfileScale, 0.16, {Scale = 1.018}, Enum.EasingStyle.Back)
end)

local Content = New("Frame", {
	Size = UDim2.new(1, -190, 1, -68),
	Position = UDim2.fromOffset(190, 68),
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

local CurrentPageName = nil
local PageAnimationId = 0

local function SelectPage(name)
	local target = Pages[name]
	if not target then
		return
	end

	PageAnimationId += 1
	local animationId = PageAnimationId
	local previousName = CurrentPageName
	local previous = previousName and Pages[previousName] or nil

	if previous and previous ~= target then
		Tween(previous, 0.16, {
			Position = UDim2.fromOffset(-10, 0)
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.14, function()
			if animationId == PageAnimationId and previous ~= Pages[CurrentPageName] then
				previous.Visible = false
				previous.Position = UDim2.fromOffset(0, 0)
			end
		end)
	end

	target.Visible = true
	target.Position = previous == target
		and target.Position
		or UDim2.fromOffset(12, 0)

	Tween(target, 0.24, {
		Position = UDim2.fromOffset(0, 0)
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	CurrentPageName = name

	for tabName, data in pairs(Tabs) do
		local selected = tabName == name

		Tween(data.button, 0.18, {
			BackgroundTransparency = selected
				and ResolveUITransparency(0.10)
				or 1,
			BackgroundColor3 = selected and Theme.Surface3 or Theme.Surface2,
			TextColor3 = selected and Theme.White or Theme.Muted
		}, Enum.EasingStyle.Quart)

		Tween(data.indicator, 0.22, {
			Size = selected
				and UDim2.fromOffset(3, 18)
				or UDim2.fromOffset(3, 0),
			BackgroundTransparency = selected and 0 or 1
		}, Enum.EasingStyle.Quint)
	end
end

local function CreateTab(name, textKey, order)
	local button = RegisterText(
		New("TextButton", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Surface2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextColor3 = Theme.Muted,
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 47
		}, TabsHolder),
		textKey
	)
	Corner(button, 8)
	Padding(button, 15, 8, 0, 0)

	local indicator = New("Frame", {
		Size = UDim2.fromOffset(3, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 5, 0.5, 0),
		BackgroundColor3 = Theme.PurpleBright,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 48
	}, button)
	Corner(indicator, 2)

	local scale = New("UIScale", {
		Scale = 1
	}, button)

	Bind(button.MouseEnter, function()
		Tween(scale, 0.16, {Scale = 1.022}, Enum.EasingStyle.Quint)
		if not Pages[name].Visible then
			Tween(button, 0.16, {
				BackgroundTransparency = ResolveUITransparency(0.42),
				TextColor3 = Theme.Light
			}, Enum.EasingStyle.Quart)
		end
	end)

	Bind(button.MouseLeave, function()
		Tween(scale, 0.18, {Scale = 1}, Enum.EasingStyle.Quint)
		if not Pages[name].Visible then
			Tween(button, 0.16, {
				BackgroundTransparency = 1,
				TextColor3 = Theme.Muted
			}, Enum.EasingStyle.Quart)
		end
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.07, {Scale = 0.975}, Enum.EasingStyle.Quart)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.16, {Scale = 1.018}, Enum.EasingStyle.Back)
	end)

	Bind(button.MouseButton1Click, function()
		SelectPage(name)
	end)

	Tabs[name] = {
		button = button,
		indicator = indicator
	}
end

local InfoPage = CreatePage("Info")
local MainPage = CreatePage("Main")
local PlayerPage = CreatePage("Player")
local EspPage = CreatePage("ESP")
local GraphicsPage = CreatePage("Graphics")
local StatusPage = CreatePage("Status")
local SettingsPage = CreatePage("Settings")

CreateTab("Info", "tab_info", 1)
CreateTab("Main", "tab_main", 2)
CreateTab("Player", "tab_player", 3)
CreateTab("ESP", "tab_esp", 4)
CreateTab("Graphics", "tab_graphics", 5)
CreateTab("Settings", "tab_settings", 6)

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
			TextSize = 18,
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
				TextSize = 11,
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
	RegisterUITransparency(card, 0.08)

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
			TextSize = 13,
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
			TextSize = 10,
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
	RegisterUITransparency(button, 0.02)

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
			TextSize = 13,
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
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 49
		}, button),
		subtitleKey
	)

	local scale = New("UIScale", {Scale = 1}, button)

	Bind(button.MouseEnter, function()
		Tween(overlay, 0.18, {
			BackgroundTransparency = ResolveUITransparency(0.87)
		}, Enum.EasingStyle.Quart)
		Tween(scale, 0.18, {Scale = 1.012}, Enum.EasingStyle.Quint)
	end)

	Bind(button.MouseLeave, function()
		Tween(overlay, 0.18, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quart)
		Tween(scale, 0.20, {Scale = 1}, Enum.EasingStyle.Quint)
	end)

	Bind(button.MouseButton1Down, function()
		Tween(scale, 0.07, {Scale = 0.974}, Enum.EasingStyle.Quart)
	end)

	Bind(button.MouseButton1Up, function()
		Tween(scale, 0.16, {Scale = 1.012}, Enum.EasingStyle.Back)
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

local function CreateInlineHotkey(row, id, options)
	options = options or {}

	local button = New("TextButton", {
		Size = UDim2.fromOffset(options.width or 72, 28),
		Position = UDim2.new(1, options.buttonOffset or -174, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(Bindings[id]),
		TextColor3 = Theme.Light,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 50
	}, row)
	Corner(button, 6)
	Stroke(button, 0.68, 1, Theme.Stroke)
	RegisterUITransparency(button, 0)

	local reset = New("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, options.resetOffset or -96, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Theme.Muted2,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 50
	}, row)
	Corner(reset, 6)
	Stroke(reset, 0.68, 1, Theme.Stroke)
	RegisterUITransparency(reset, 0)

	HotkeyButtons[id] = button

	Bind(button.MouseEnter, function()
		Tween(button, 0.16, {
			BackgroundColor3 = Theme.Surface3,
			TextColor3 = Theme.White
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		if not Capture or Capture.id ~= id then
			Tween(button, 0.16, {
				BackgroundColor3 = Theme.Surface2,
				TextColor3 = Theme.Light
			}, Enum.EasingStyle.Quad)
		end
	end)

	Bind(reset.MouseEnter, function()
		Tween(reset, 0.16, {
			BackgroundColor3 = Color3.fromRGB(43, 24, 29),
			TextColor3 = Theme.Red
		}, Enum.EasingStyle.Quad)
	end)

	Bind(reset.MouseLeave, function()
		Tween(reset, 0.16, {
			BackgroundColor3 = Theme.Surface2,
			TextColor3 = Theme.Muted2
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, function()
		BeginHotkeyCapture(id, button)
	end)

	Bind(reset.MouseButton1Click, function()
		if Capture and Capture.id == id then
			Capture = nil
		end
		AssignBinding(id, nil)
	end)

	return button, reset
end

local function CreateToggle(parent, config)
	local hasHotkey = HotkeyCapable[config.id] == true
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.height or 64),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		LayoutOrder = config.order,
		ZIndex = 46
	}, parent)
	Corner(row, 7)
	Stroke(row, 0.82, 1, Theme.Stroke)
	RegisterUITransparency(row, 0.04)

	local overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 46
	}, row)
	Corner(overlay, 7)

	local rightReserve = hasHotkey and 225 or 82
	if config.warning then
		rightReserve += 92
	end

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -rightReserve, 0, 18),
			Position = UDim2.fromOffset(14, 11),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 14,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 48
		}, row),
		config.titleKey
	)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -rightReserve, 0, 16),
			Position = UDim2.fromOffset(14, 32),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 48
		}, row),
		config.subtitleKey
	)

	if config.warning then
		local warningOffset = hasHotkey and -264 or -150
		local warning = RegisterText(
			New("TextLabel", {
				Size = UDim2.fromOffset(76, 20),
				Position = UDim2.new(1, warningOffset, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(46, 22, 27),
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				TextColor3 = Theme.Red,
				TextSize = 9,
				Font = Enum.Font.GothamBold,
				ZIndex = 49
			}, row),
			"heavy"
		)
		Corner(warning, 5)
	end

	if hasHotkey then
		CreateInlineHotkey(row, config.id)
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
	RegisterUITransparency(switch, 0)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 50
	}, switch)
	Corner(knob, 9)

	local knobScale = New("UIScale", {Scale = 1}, knob)

	local function Apply(enabled)
		Tween(switch, 0.20, {
			BackgroundColor3 = enabled and Theme.Purple or Theme.Off
		}, Enum.EasingStyle.Quart)

		Tween(knob, 0.22, {
			Position = enabled
				and UDim2.fromOffset(25, 3)
				or UDim2.fromOffset(3, 3)
		}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		knobScale.Scale = 0.82
		Tween(knobScale, 0.22, {
			Scale = 1
		}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
		Tween(overlay, 0.18, {
			BackgroundTransparency = ResolveUITransparency(0.76)
		}, Enum.EasingStyle.Quart)
	end)

	Bind(row.MouseLeave, function()
		Tween(overlay, 0.18, {
			BackgroundTransparency = 1
		}, Enum.EasingStyle.Quart)
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
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 54
	}, row)
	Corner(valueBox, 7)
	Stroke(valueBox, 0.65, 1, Theme.Stroke)
	RegisterUITransparency(valueBox, 0)

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
		Tween(fill, 0.10, {
			Size = UDim2.fromScale(alpha, 1)
		}, Enum.EasingStyle.Quart)
		Tween(knob, 0.10, {
			Position = UDim2.new(alpha, 0, 0.5, 0)
		}, Enum.EasingStyle.Quart)
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

local function CreateHotkeyRow(parent, id, titleKey, subtitleKey, order)
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 46
	}, parent)
	Corner(row, 7)
	Stroke(row, 0.82, 1, Theme.Stroke)
	RegisterUITransparency(row, 0.04)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -185, 0, 20),
			Position = UDim2.fromOffset(14, 10),
			BackgroundTransparency = 1,
			TextColor3 = Theme.White,
			TextSize = 14,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, row),
		titleKey
	)

	RegisterText(
		New("TextLabel", {
			Size = UDim2.new(1, -185, 0, 18),
			Position = UDim2.fromOffset(14, 34),
			BackgroundTransparency = 1,
			TextColor3 = Theme.Muted,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 47
		}, row),
		subtitleKey
	)

	local button = New("TextButton", {
		Size = UDim2.fromOffset(72, 28),
		Position = UDim2.new(1, -174, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = FormatBinding(Bindings[id]),
		TextColor3 = Theme.White,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(button, 6)
	Stroke(button, 0.68, 1, Theme.Stroke)
	RegisterUITransparency(button, 0)

	local reset = New("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -96, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Theme.Muted,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		ZIndex = 48
	}, row)
	Corner(reset, 6)
	Stroke(reset, 0.68, 1, Theme.Stroke)
	RegisterUITransparency(reset, 0)

	HotkeyButtons[id] = button

	Bind(button.MouseEnter, function()
		Tween(button, 0.12, {
			BackgroundColor3 = Theme.Surface3
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseLeave, function()
		Tween(button, 0.12, {
			BackgroundColor3 = Theme.Surface2
		}, Enum.EasingStyle.Quad)
	end)

	Bind(reset.MouseEnter, function()
		Tween(reset, 0.12, {
			BackgroundColor3 = Color3.fromRGB(45, 20, 25),
			TextColor3 = Theme.Red
		}, Enum.EasingStyle.Quad)
	end)

	Bind(reset.MouseLeave, function()
		Tween(reset, 0.12, {
			BackgroundColor3 = Theme.Surface2,
			TextColor3 = Theme.Muted
		}, Enum.EasingStyle.Quad)
	end)

	Bind(button.MouseButton1Click, function()
		BeginHotkeyCapture(id, button)
	end)

	Bind(reset.MouseButton1Click, function()
		if Capture and Capture.id == id then
			Capture = nil
		end
		if id == "menu" then
			AssignBinding(id, {kind = "Control"})
		else
			AssignBinding(id, nil)
		end
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
			TextSize = 12,
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

local UltraGraphicsSaved = {
	lighting = nil,
	terrain = nil,
	objects = {},
	effects = {},
	replacedEffects = {},
	atmosphere = nil,
	createdAtmosphere = false
}
local UltraGraphicsConnection = nil

local function SaveObjectProperty(object, property)
	if not UltraGraphicsSaved.objects[object] then
		UltraGraphicsSaved.objects[object] = {}
	end

	local saved = UltraGraphicsSaved.objects[object]
	if saved[property] == nil then
		local ok, value = pcall(function()
			return object[property]
		end)
		if ok then
			saved[property] = value
		end
	end
end

local function ApplyUltraGraphicsToObject(object)
	if object:IsA("BasePart") then
		SaveObjectProperty(object, "CastShadow")
		object.CastShadow = true

		if object.Material == Enum.Material.Metal then
			SaveObjectProperty(object, "Reflectance")
			object.Reflectance = math.max(object.Reflectance, 0.08)
		elseif object.Material == Enum.Material.Glass then
			SaveObjectProperty(object, "Reflectance")
			object.Reflectance = math.max(object.Reflectance, 0.05)
		end
	end

	if object:IsA("PointLight")
		or object:IsA("SpotLight")
		or object:IsA("SurfaceLight") then

		SaveObjectProperty(object, "Enabled")
		SaveObjectProperty(object, "Shadows")
		object.Enabled = true
		object.Shadows = true
	end

	if object:IsA("ParticleEmitter") then
		SaveObjectProperty(object, "Enabled")
		SaveObjectProperty(object, "LightEmission")
		object.Enabled = true
		object.LightEmission = math.max(object.LightEmission, 0.1)
	end

	if object:IsA("Beam") then
		SaveObjectProperty(object, "Enabled")
		object.Enabled = true
	end

	if object:IsA("Trail") then
		SaveObjectProperty(object, "Enabled")
		object.Enabled = true
	end

	if object:IsA("SurfaceAppearance") then
		SaveObjectProperty(object, "AlphaMode")
		object.AlphaMode = Enum.AlphaMode.Overlay
	end
end

local function SaveEffectProperties(effect, properties)
	local saved = {}
	for _, property in ipairs(properties) do
		saved[property] = effect[property]
	end
	return saved
end

local function GetOrCreateUltraEffect(className, name, properties)
	local tracked = UltraGraphicsSaved.effects[name]
	if tracked and tracked.object and tracked.object.Parent then
		return tracked.object
	end

	local object = Lighting:FindFirstChild(name)

	if object and object.ClassName ~= className then
		local ok, clone = pcall(function()
			return object:Clone()
		end)
		if ok and clone then
			UltraGraphicsSaved.replacedEffects[name] = clone
		end
		object:Destroy()
		object = nil
	end

	if not object then
		object = Instance.new(className)
		object.Name = name
		object.Parent = Lighting
		UltraGraphicsSaved.effects[name] = {
			object = object,
			created = true
		}
	else
		UltraGraphicsSaved.effects[name] = {
			object = object,
			created = false,
			properties = SaveEffectProperties(object, properties)
		}
	end

	return object
end

local function EnableUltraGraphics()
	if not UltraGraphicsSaved.lighting then
		UltraGraphicsSaved.lighting = {
			GlobalShadows = Lighting.GlobalShadows,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			PrioritizeLightingQuality = Lighting.PrioritizeLightingQuality,
			ShadowSoftness = Lighting.ShadowSoftness,
			Brightness = Lighting.Brightness,
			ExposureCompensation = Lighting.ExposureCompensation,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient
		}
	end

	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.PrioritizeLightingQuality = true
	Lighting.ShadowSoftness = 0.2
	Lighting.Brightness = 2.5
	Lighting.ExposureCompensation = 0.05

	Lighting.Ambient = Color3.fromRGB(25, 25, 30)
	Lighting.OutdoorAmbient = Color3.fromRGB(125, 125, 135)

	local bloom = GetOrCreateUltraEffect(
		"BloomEffect",
		"UltraBloom",
		{"Enabled", "Intensity", "Size", "Threshold"}
	)
	bloom.Enabled = true
	bloom.Intensity = 0.35
	bloom.Size = 32
	bloom.Threshold = 1.1

	local color = GetOrCreateUltraEffect(
		"ColorCorrectionEffect",
		"UltraColor",
		{"Enabled", "Brightness", "Contrast", "Saturation", "TintColor"}
	)
	color.Enabled = true
	color.Brightness = 0.01
	color.Contrast = 0.08
	color.Saturation = 0.08
	color.TintColor = Color3.fromRGB(255, 250, 245)

	local rays = GetOrCreateUltraEffect(
		"SunRaysEffect",
		"UltraSunRays",
		{"Enabled", "Intensity", "Spread"}
	)
	rays.Enabled = true
	rays.Intensity = 0.075
	rays.Spread = 0.85

	local depth = GetOrCreateUltraEffect(
		"DepthOfFieldEffect",
		"UltraDepthOfField",
		{"Enabled", "FocusDistance", "InFocusRadius", "NearIntensity", "FarIntensity"}
	)
	depth.Enabled = true
	depth.FocusDistance = 25
	depth.InFocusRadius = 70
	depth.NearIntensity = 0.04
	depth.FarIntensity = 0.08

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
		UltraGraphicsSaved.createdAtmosphere = true
	elseif not UltraGraphicsSaved.atmosphere then
		UltraGraphicsSaved.atmosphere = {
			object = atmosphere,
			Density = atmosphere.Density,
			Offset = atmosphere.Offset,
			Glare = atmosphere.Glare,
			Haze = atmosphere.Haze,
			Color = atmosphere.Color,
			Decay = atmosphere.Decay
		}
	end

	atmosphere.Density = 0.22
	atmosphere.Offset = 0.1
	atmosphere.Glare = 0.15
	atmosphere.Haze = 1.2
	atmosphere.Color = Color3.fromRGB(220, 225, 235)
	atmosphere.Decay = Color3.fromRGB(100, 105, 120)

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		if not UltraGraphicsSaved.terrain then
			UltraGraphicsSaved.terrain = {
				object = terrain,
				WaterReflectance = terrain.WaterReflectance,
				WaterTransparency = terrain.WaterTransparency,
				WaterWaveSize = terrain.WaterWaveSize,
				WaterWaveSpeed = terrain.WaterWaveSpeed
			}
		end

		terrain.WaterReflectance = 1
		terrain.WaterTransparency = 0.25
		terrain.WaterWaveSize = 0.15
		terrain.WaterWaveSpeed = 12
	end

	local descendants = Workspace:GetDescendants()
	for i, object in ipairs(descendants) do
		pcall(ApplyUltraGraphicsToObject, object)

		if i % 250 == 0 then
			task.wait()
		end
	end

	if not UltraGraphicsConnection then
		UltraGraphicsConnection = Workspace.DescendantAdded:Connect(function(object)
			task.defer(function()
				if State.graphicsBoost and object.Parent then
					pcall(ApplyUltraGraphicsToObject, object)
				end
			end)
		end)
		table.insert(Connections, UltraGraphicsConnection)
	end
end

local function DisableUltraGraphics()
	if UltraGraphicsConnection then
		pcall(function()
			UltraGraphicsConnection:Disconnect()
		end)
		UltraGraphicsConnection = nil
	end

	for object, properties in pairs(UltraGraphicsSaved.objects) do
		if object and object.Parent then
			for property, value in pairs(properties) do
				pcall(function()
					object[property] = value
				end)
			end
		end
	end
	table.clear(UltraGraphicsSaved.objects)

	if UltraGraphicsSaved.terrain then
		local terrain = UltraGraphicsSaved.terrain.object
		if terrain and terrain.Parent then
			for _, property in ipairs({
				"WaterReflectance",
				"WaterTransparency",
				"WaterWaveSize",
				"WaterWaveSpeed"
			}) do
				pcall(function()
					terrain[property] = UltraGraphicsSaved.terrain[property]
				end)
			end
		end
	end
	UltraGraphicsSaved.terrain = nil

	if UltraGraphicsSaved.createdAtmosphere then
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if atmosphere then
			atmosphere:Destroy()
		end
	elseif UltraGraphicsSaved.atmosphere then
		local saved = UltraGraphicsSaved.atmosphere
		local atmosphere = saved.object
		if atmosphere and atmosphere.Parent then
			atmosphere.Density = saved.Density
			atmosphere.Offset = saved.Offset
			atmosphere.Glare = saved.Glare
			atmosphere.Haze = saved.Haze
			atmosphere.Color = saved.Color
			atmosphere.Decay = saved.Decay
		end
	end
	UltraGraphicsSaved.atmosphere = nil
	UltraGraphicsSaved.createdAtmosphere = false

	for name, data in pairs(UltraGraphicsSaved.effects) do
		local object = data.object
		if data.created then
			if object and object.Parent then
				object:Destroy()
			end
		elseif object and object.Parent and data.properties then
			for property, value in pairs(data.properties) do
				pcall(function()
					object[property] = value
				end)
			end
		end
	end
	table.clear(UltraGraphicsSaved.effects)

	for name, clone in pairs(UltraGraphicsSaved.replacedEffects) do
		if clone then
			local existing = Lighting:FindFirstChild(name)
			if existing then
				existing:Destroy()
			end
			clone.Parent = Lighting
		end
	end
	table.clear(UltraGraphicsSaved.replacedEffects)

	if UltraGraphicsSaved.lighting then
		for property, value in pairs(UltraGraphicsSaved.lighting) do
			pcall(function()
				Lighting[property] = value
			end)
		end
	end
	UltraGraphicsSaved.lighting = nil
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
	if not next(FullBrightSaved) then
		for _, property in ipairs({
			"Ambient",
			"OutdoorAmbient",
			"Brightness",
			"ExposureCompensation",
			"FogEnd"
		}) do
			FullBrightSaved[property] = Lighting[property]
		end
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

	if State.graphicsBoost then
		EnableUltraGraphics()
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
	local blur = math.clamp(State.panelBlur / 100, 0, 1)
	local color = Color3.new(brightness, brightness, brightness)

	Background.ImageColor3 = color
	Background.ImageTransparency = 0.05 + (0.18 * blur)

	for _, data in ipairs(BlurLayers) do
		local layer = data.image
		layer.ImageColor3 = color
		layer.ImageTransparency = 1 - (0.18 * blur)
		layer.Position = UDim2.fromOffset(
			data.offset.X * (0.6 + 1.7 * blur),
			data.offset.Y * (0.6 + 1.7 * blur)
		)
	end

	BackgroundShade.BackgroundTransparency = ResolveUITransparency(0.04 + (0.50 * brightness))
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

local function ContainsAny(textValue, words)
	local lower = string.lower(textValue or "")
	for _, word in ipairs(words) do
		if string.find(lower, word, 1, true) then
			return true
		end
	end
	return false
end

local function DestinationScore(object, kind)
	local gameWords = {"game", "gameplay", "map", "arena", "match", "round", "start"}
	local lobbyWords = {"lobby", "hub", "waiting", "spawn"}
	local wanted = kind == "Game" and gameWords or lobbyWords
	local unwanted = kind == "Game" and {"lobby", "hub", "waiting"} or {"game", "gameplay", "map", "arena", "match", "round"}

	local score = 0

	if object:IsA("SpawnLocation") then
		score += 4
	end

	if ContainsAny(object.Name, wanted) then
		score += 8
	end

	if ContainsAny(object.Name, unwanted) then
		score -= 10
	end

	for _, attributeName in ipairs({
		"Destination",
		"TeleportDestination",
		"Zone",
		"SpawnType",
		"Area",
		"Room"
	}) do
		local value = object:GetAttribute(attributeName)
		if value then
			local asText = tostring(value)
			if string.lower(asText) == string.lower(kind) then
				score += 20
			elseif ContainsAny(asText, wanted) then
				score += 12
			elseif ContainsAny(asText, unwanted) then
				score -= 12
			end
		end
	end

	for _, tag in ipairs(CollectionService:GetTags(object)) do
		if ContainsAny(tag, wanted) then
			score += 12
		elseif ContainsAny(tag, unwanted) then
			score -= 12
		end
	end

	local parent = object.Parent
	local depth = 0
	while parent and parent ~= Workspace and depth < 6 do
		if ContainsAny(parent.Name, wanted) then
			score += 5
		end
		if ContainsAny(parent.Name, unwanted) then
			score -= 6
		end
		parent = parent.Parent
		depth += 1
	end

	return score
end

local function FindDestinationSpawn(kind)
	local bestObject = nil
	local bestScore = -math.huge

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("SpawnLocation")
			or object:IsA("BasePart")
			or object:IsA("Attachment") then

			local score = DestinationScore(object, kind)

			if score > bestScore then
				bestScore = score
				bestObject = object
			end
		end
	end

	if bestObject and bestScore > 0 then
		return SpawnCFrame(bestObject)
	end

	local containers = kind == "Game"
		and {"Game", "Gameplay", "Map", "Arena", "Match", "Round"}
		or {"Lobby", "Hub", "WaitingRoom", "Waiting"}

	for _, containerName in ipairs(containers) do
		local container = Workspace:FindFirstChild(containerName, true)
		if container then
			local cf = FindSpawnInside(container, kind)
			if cf then
				return cf
			end
		end
	end

	local firstSpawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	return firstSpawn and firstSpawn.CFrame or nil
end

local function TeleportCharacterTo(cf)
	local character = LocalPlayer.Character
	if not character or not cf then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local target = cf + Vector3.new(0, 4, 0)

	for _ = 1, 3 do
		character:PivotTo(target)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		task.wait()
	end

	return true
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

	if TeleportCharacterTo(destination) then
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
RegisterUITransparency(InfoCard, 0.08)

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
		TextSize = 11,
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
		TextSize = 10,
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
	order = 2,
	warning = true
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

CreateHotkeyRow(
	PlayerPage,
	"speedManipulation",
	"speed_manip",
	"speed_manip_sub",
	6
)

Section(EspPage, "esp_title", "esp_subtitle", 1)

CreateToggle(EspPage, {
	id = "playerEsp",
	titleKey = "player_esp",
	subtitleKey = "player_esp_sub",
	order = 2,
	warning = true,
	changed = function(enabled)
		if not enabled then
			ClearPlayerEsp()
		end
	end
})

Section(GraphicsPage, "graphics_title", "graphics_subtitle", 1)

CreateToggle(GraphicsPage, {
	id = "graphicsBoost",
	titleKey = "graphics_boost",
	subtitleKey = "graphics_boost_sub",
	order = 2,
	warning = true,
	changed = function(enabled)
		if enabled then
			if State.lowGraphics and ToggleSetters.lowGraphics then
				ToggleSetters.lowGraphics(false)
			end
			EnableUltraGraphics()
			if State.fullBright then
				EnableFullBright()
			end
		else
			DisableUltraGraphics()
		end
	end
})

CreateToggle(GraphicsPage, {
	id = "lowGraphics",
	titleKey = "low_graphics",
	subtitleKey = "low_graphics_sub",
	order = 3,
	changed = function(enabled)
		if enabled then
			if State.graphicsBoost and ToggleSetters.graphicsBoost then
				ToggleSetters.graphicsBoost(false)
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
	order = 4,
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
	order = 5,
	changed = function(enabled)
		if SetFpsVisible then
			SetFpsVisible(enabled)
		end
	end
})

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
RegisterUITransparency(StatusSummary, 0.08)

local ExecutionsLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 22),
	Position = UDim2.fromOffset(14, 13),
	BackgroundTransparency = 1,
	TextColor3 = Theme.White,
	TextSize = 13,
	Font = Enum.Font.GothamSemibold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, StatusSummary)

local ActiveCountLabel = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 18),
	Position = UDim2.fromOffset(14, 42),
	BackgroundTransparency = 1,
	TextColor3 = Theme.PurpleBright,
	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 47
}, StatusSummary)

local ActiveCard = New("Frame", {
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 46
}, StatusPage)
Corner(ActiveCard, 9)
RegisterUITransparency(ActiveCard, 0.08)

local ActiveList = New("TextLabel", {
	Size = UDim2.new(1, -28, 0, 58),
	Position = UDim2.fromOffset(14, 13),
	BackgroundTransparency = 1,
	TextColor3 = Theme.Light,
	TextSize = 10,
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
RegisterUITransparency(DisabledCard, 0.08)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 10,
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
	TextSize = 10,
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
	{"graphicsBoost", "graphics_boost"},
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

CreateHotkeyRow(
	SettingsPage,
	"menu",
	"menu_hotkey",
	"menu_hotkey_sub",
	3
)

local BlurRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 4,
	ZIndex = 46
}, SettingsPage)
Corner(BlurRow, 9)
RegisterUITransparency(BlurRow, 0.08)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 18),
		Position = UDim2.fromOffset(14, 10),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 14,
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
		TextSize = 10,
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
	LayoutOrder = 5,
	ZIndex = 46
}, SettingsPage)
Corner(BrightnessRow, 9)
RegisterUITransparency(BrightnessRow, 0.08)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 18),
		Position = UDim2.fromOffset(14, 10),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 14,
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
		TextSize = 10,
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

local TransparencyRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 84),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 6,
	ZIndex = 46
}, SettingsPage)
Corner(TransparencyRow, 9)
RegisterUITransparency(TransparencyRow, 0.08)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 18),
		Position = UDim2.fromOffset(14, 10),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, TransparencyRow),
	"ui_transparency"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -125, 0, 15),
		Position = UDim2.fromOffset(14, 29),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Muted,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 47
	}, TransparencyRow),
	"ui_transparency_sub"
)

CreateSlider(
	TransparencyRow,
	63,
	0,
	90,
	State.uiTransparency,
	function(value)
		State.uiTransparency = value
		ApplyUITransparency()
		ApplyPanelBackground()
	end,
	true
)

local LanguageRow = New("Frame", {
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	LayoutOrder = 7,
	ZIndex = 46
}, SettingsPage)
Corner(LanguageRow, 9)
RegisterUITransparency(LanguageRow, 0.08)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(1, -160, 0, 18),
		Position = UDim2.fromOffset(14, 11),
		BackgroundTransparency = 1,
		TextColor3 = Theme.White,
		TextSize = 14,
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
		TextSize = 10,
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
	Text = "ENG",
	TextColor3 = Theme.White,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
	ZIndex = 48
}, LanguageRow)
Corner(LanguageButton, 7)
Stroke(LanguageButton, 0.55, 1, Theme.Stroke)
RegisterUITransparency(LanguageButton, 0)

local function ApplyLanguage()
	RefreshLanguage()

	LanguageButton.Text = Language == "en"
		and Strings.en.english
		or Strings.ptbr.portuguese

	for id, button in pairs(HotkeyButtons) do
		if button and button.Parent then
			button.Text = FormatBinding(Bindings[id])
		end
	end

	RefreshStatusPage()
end

Bind(LanguageButton.MouseButton1Click, function()
	Language = Language == "en" and "ptbr" or "en"
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
RegisterUITransparency(StatusHud, 0.04)

local HudScale = New("UIScale", {
	Scale = 0.96
}, StatusHud)

local FpsLabel = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "0",
	TextColor3 = Theme.White,
	TextSize = 13,
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
		TextSize = 11,
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

		-- Set this once when opening. Do not force it every frame:
		-- Roblox can still switch mouse behavior while RMB controls the camera.
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		Main.Visible = true
		ApplyPanelBackground()
		ApplyUITransparency()

		Main.GroupTransparency = 1
		MainScale.Scale = 0.88
		Main.Rotation = -0.65

		TopBar.Position = UDim2.fromOffset(0, -14)
		Sidebar.Position = UDim2.fromOffset(-24, 68)
		Content.Position = UDim2.fromOffset(218, 68)

		local targetBackgroundTransparency =
			0.05 + (0.18 * math.clamp(State.panelBlur / 100, 0, 1))

		Background.ImageTransparency = math.min(
			0.90,
			targetBackgroundTransparency + 0.54
		)

		Tween(MainScale, 0.58, {
			Scale = 1
		}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		Tween(Main, 0.38, {
			GroupTransparency = 0,
			Rotation = 0
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(TopBar, 0.44, {
			Position = UDim2.fromOffset(0, 0)
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Sidebar, 0.50, {
			Position = UDim2.fromOffset(0, 68)
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Content, 0.54, {
			Position = UDim2.fromOffset(190, 68)
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		Tween(Background, 0.58, {
			ImageTransparency = targetBackgroundTransparency
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		StopSpeedManipulation()

		Tween(MainScale, 0.30, {
			Scale = 0.91
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		Tween(Main, 0.28, {
			GroupTransparency = 1,
			Rotation = 0.42
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

		Tween(TopBar, 0.24, {
			Position = UDim2.fromOffset(0, -9)
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		Tween(Sidebar, 0.27, {
			Position = UDim2.fromOffset(-16, 68)
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		Tween(Content, 0.28, {
			Position = UDim2.fromOffset(208, 68)
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		Tween(Background, 0.24, {
			ImageTransparency = 0.86
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		task.delay(0.31, function()
			if id == MenuAnimationId and not State.menuVisible then
				Main.Visible = false
				Main.Rotation = 0
				TopBar.Position = UDim2.fromOffset(0, 0)
				Sidebar.Position = UDim2.fromOffset(0, 68)
				Content.Position = UDim2.fromOffset(190, 68)
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

		local capturedId = Capture.id
		local newBinding = nil

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if IsForbiddenHotkey(input.KeyCode) then
				Tween(Capture.button, 0.10, {
					TextColor3 = Theme.Red
				}, Enum.EasingStyle.Quad)

				task.delay(0.25, function()
					if Capture and Capture.button and Capture.button.Parent then
						Capture.button.TextColor3 = Theme.PurpleBright
					end
				end)

				return
			end

			if input.KeyCode == Enum.KeyCode.LeftControl
				or input.KeyCode == Enum.KeyCode.RightControl then
				newBinding = {
					kind = "Control"
				}
			else
				newBinding = {
					kind = "KeyCode",
					value = input.KeyCode
				}
			end

		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then

			newBinding = {
				kind = "InputType",
				value = input.UserInputType
			}
		else
			return
		end

		AssignBinding(capturedId, newBinding)
		Capture = nil
		return
	end

	if UserInputService:GetFocusedTextBox() then
		return
	end

	if BindingMatches(Bindings.menu, input) then
		SetMenuVisible(not State.menuVisible)
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
			and id ~= "menu"
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
	local preload = {Background, HubIcon, IntroIcon, Avatar}
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
	State.graphicsBoost = false
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
	DisableUltraGraphics()
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
ApplyUITransparency()
SetFpsVisible(false)
RefreshStatusPage()
ApplyLanguage()

task.spawn(function()
	-- A longer, softer intro: icon reveal, orbit, loading pulse and progress.
	Tween(IntroGradient, 5.10, {
		Rotation = 155
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	Tween(IntroRing, 5.05, {
		Rotation = 188
	}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	Tween(IntroRingScale, 0.72, {
		Scale = 1
	}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	Tween(IntroCenter, 0.66, {
		GroupTransparency = 0
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	Tween(IntroIconScale, 0.78, {
		Scale = 1
	}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	Tween(IntroProgressFill, 4.85, {
		Size = UDim2.fromScale(1, 1)
	}, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	task.spawn(function()
		for cycle = 1, 5 do
			if Destroyed then
				return
			end

			Tween(IntroGlow, 0.48, {
				Size = UDim2.fromOffset(278, 278),
				BackgroundTransparency = 0.91
			}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

			Tween(IntroIconScale, 0.48, {
				Scale = 1.045
			}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

			task.wait(0.48)

			Tween(IntroGlow, 0.48, {
				Size = UDim2.fromOffset(250, 250),
				BackgroundTransparency = 0.86
			}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

			Tween(IntroIconScale, 0.48, {
				Scale = 1
			}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

			task.wait(0.48)
		end
	end)

	task.spawn(function()
		for cycle = 1, 5 do
			for index, dot in ipairs(IntroDots) do
				if Destroyed then
					return
				end

				Tween(dot, 0.20, {
					Position = UDim2.new(0.5, (index - 2) * 14, 0.5, 107),
					BackgroundTransparency = 0.06,
					Size = UDim2.fromOffset(7, 7)
				}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

				task.wait(0.09)

				Tween(dot, 0.28, {
					Position = UDim2.new(0.5, (index - 2) * 14, 0.5, 111),
					BackgroundTransparency = 0.48,
					Size = UDim2.fromOffset(5, 5)
				}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			end
			task.wait(0.35)
		end
	end)

	task.spawn(function()
		for cycle = 1, 4 do
			for index, sparkle in ipairs(IntroSparkles) do
				local alpha = ((cycle + index) % 3 == 0) and 0.18 or 0.68
				Tween(sparkle, 0.42, {
					BackgroundTransparency = alpha,
					Rotation = sparkle.Rotation + 25
				}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			end
			task.wait(0.72)
		end
	end)

	task.wait(5.05)

	if Destroyed then
		return
	end

	Tween(IntroIconScale, 0.36, {
		Scale = 0.88
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	Tween(IntroRingScale, 0.40, {
		Scale = 1.12
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	local fade = Tween(Intro, 0.48, {
		GroupTransparency = 1
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	fade.Completed:Wait()

	if Destroyed then
		return
	end

	Intro.Visible = false
	SetMenuVisible(true)
end)

