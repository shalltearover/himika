-- K HUB V6 — PARTE 1/2

if _G.KHubCleanup then
	pcall(_G.KHubCleanup)
	_G.KHubCleanup = nil
elseif _G.LostHubCleanup then
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
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

local previousExecutionCount = math.max(
	tonumber(_G.KHubExecutionCount) or 0,
	tonumber(LocalPlayer:GetAttribute("KHubExecutionCount")) or 0
)

_G.KHubExecutionCount = previousExecutionCount + 1

pcall(function()
	LocalPlayer:SetAttribute(
		"KHubExecutionCount",
		_G.KHubExecutionCount
	)
end)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local GuiParent = PlayerGui

pcall(function()
	if typeof(gethui) == "function" then
		local candidate = gethui()

		if typeof(candidate) == "Instance" then
			GuiParent = candidate
		end
	end
end)

local BACKGROUND_ASSET_ID = 10039618753
local HUB_ICON_ASSET_ID = 11878291148

local oldGui =
	GuiParent:FindFirstChild("KHub")
	or GuiParent:FindFirstChild("LostHub")
	or PlayerGui:FindFirstChild("KHub")
	or PlayerGui:FindFirstChild("LostHub")

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
	Base = Color3.fromRGB(5, 6, 8),
	Surface = Color3.fromRGB(9, 10, 13),
	Surface2 = Color3.fromRGB(14, 15, 19),
	Surface3 = Color3.fromRGB(20, 21, 26),
	Surface4 = Color3.fromRGB(29, 30, 36),

	White = Color3.fromRGB(242, 243, 246),
	Light = Color3.fromRGB(198, 201, 208),

	Muted = Color3.fromRGB(126, 130, 139),
	Muted2 = Color3.fromRGB(78, 82, 91),

	Black = Color3.fromRGB(0, 0, 0),

	Off = Color3.fromRGB(38, 40, 46),

	Purple = Color3.fromRGB(117, 105, 151),
	PurpleBright = Color3.fromRGB(158, 146, 191),
	PurpleSoft = Color3.fromRGB(55, 50, 70),

	Red = Color3.fromRGB(224, 92, 102),
	Green = Color3.fromRGB(126, 188, 151),

	Stroke = Color3.fromRGB(39, 41, 48)
}

local Language = "en"

local Strings = {
	en = {
		tab_info = "Info",
		tab_main = "Main",
		tab_player = "Player",
		tab_esp = "ESP",
		tab_graphics = "Graphics",
		tab_fps = "FPS",
		tab_macros = "Macros",
		tab_status = "Status",
		tab_settings = "Settings",

		top_subtitle = "utility panel",

		info_subtitle = "Build notes and runtime warnings",
		info_version = "Development build",
		info_runtime = "Runtime features start disabled.",

		note_development_title = "Development",
		note_development_body =
			"This build is still being tested. Features and behavior may change.",

		note_performance_title = "Performance",
		note_performance_body =
			"Red labels mark heavier options that may reduce performance in large or generated rooms.",

		note_menu_title = "Menu shortcut",
		note_menu_body =
			"Ctrl opens or closes the menu by default. You can change it in Settings.",

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
		anti_fling_sub =
			"Limits unwanted velocity and collision pushes",

		noclip = "Noclip",
		noclip_sub =
			"Disable collision on your character",

		walk_speed = "Walk Speed",
		walk_speed_sub =
			"Set your movement speed",

		fly = "Fly",
		fly_sub =
			"Move freely through the air",

		fly_notice =
			"Fly enabled  ·  Q down  ·  E up",

		speed_manip =
			"Movement Manipulation",

		speed_manip_sub =
			"Hold the key to use noclip with WalkSpeed 2",

		fov =
			"Field of View",

		fov_sub =
			"Adjust the camera field of view",

		freecam =
			"Freecam",

		freecam_sub =
			"Detach the camera and move it with WASD + Q/E",

		freecam_speed =
			"Freecam Speed",

		spectate =
			"Spectate Player",

		spectate_sub =
			"Follow another player and switch targets inline",

		auto_walk =
			"Auto Walk",

		auto_walk_sub =
			"Walk through detected objectives in sequence",

		esp_title =
			"ESP",

		esp_subtitle =
			"Players and potentially hostile entities",

		player_esp =
			"Player ESP",

		player_esp_sub =
			"Show names and distance for players",

		friend_esp =
			"Friend ESP",

		friend_esp_sub =
			"Add a star and green styling to friends on the normal player label",

		entity_esp =
			"Entity ESP",

		entity_esp_sub =
			"Highlight detected NPCs and entities",

		esp_filters =
			"ESP Filters",

		esp_filters_sub =
			"Choose what ESP elements are rendered",

		esp_names =
			"Names",

		esp_names_sub =
			"Show names above ESP targets",

		esp_distance =
			"Distance",

		esp_distance_sub =
			"Show distance from your character",

		esp_highlight =
			"Highlight",

		esp_highlight_sub =
			"Render an outline through walls",

		entity_hostile_only =
			"Hostile Entities Only",

		entity_hostile_only_sub =
			"Ignore neutral NPCs when possible",

		entity_spawn_warning =
			"Entity Spawn Warning",

		entity_spawn_warning_sub =
			"Show a warning when a hostile entity appears",

		item_esp =
			"Gear ESP",

		item_esp_sub =
			"Show only world Tools that can be picked up as gear",

		objective_esp =
			"Objective ESP",

		objective_esp_sub =
			"Highlight tagged objectives, keys and progression targets",

		graphics_title =
			"Graphics",

		graphics_subtitle =
			"Visual quality and performance",

		graphics_boost =
			"Enhanced Graphics",

		graphics_boost_sub =
			"Boost lighting, reflections, atmosphere and detail",

		better_textures =
			"Better Textures",

		better_textures_sub =
			"Sharper mesh rendering and reduced model LOD",

		better_lights =
			"Better Lights",

		better_lights_sub =
			"Future lighting, shadows and stronger local lights",

		reflections =
			"Reflections",

		reflections_sub =
			"Increase specular response on reflective materials",

		environment =
			"Environment",

		environment_sub =
			"Atmosphere, sun rays and depth effects",

		low_graphics =
			"Low Graphics",

		low_graphics_sub =
			"Reduce particles, materials and expensive effects",

		full_bright =
			"Full Bright",

		full_bright_sub =
			"Increase visibility and reduce distant fog",

		fps_display =
			"FPS Counter",

		fps_display_sub =
			"Numeric FPS counter updated at up to 30 Hz",

		clock_display =
			"Clock",

		clock_display_sub =
			"Show your local time on screen",

		date_display =
			"Date",

		date_display_sub =
			"Show the date to the left of the FPS counter",

		no_fog =
			"No Fog",

		no_fog_sub =
			"Remove distance fog and atmosphere haze",

		brightness =
			"Brightness",

		brightness_sub =
			"Override Lighting brightness while enabled",

		hide_particles =
			"Hide Particles",

		hide_particles_sub =
			"Disable particles, trails, beams and emitters",

		performance_mode =
			"Performance Mode",

		performance_mode_sub =
			"Reduce expensive effects, materials and shadows",

		heavy =
			"HEAVY",

		fps_title =
			"FPS Tools",

		fps_subtitle =
			"Aim and camera helpers for shooter testing",

		aimbot =
			"Aimbot",

		aimbot_sub =
			"Aim at the closest valid player while the aim key is held",

		aim_key =
			"Aim Key",

		aim_key_sub =
			"Hold this key to engage the aimbot",

		aim_wall_check =
			"Wall Check",

		aim_wall_check_sub =
			"Ignore targets hidden behind geometry",

		aim_ignore_friends =
			"Ignore Friends",

		aim_ignore_friends_sub =
			"Never select Roblox friends as aim targets",

		aim_team_check =
			"Team Check",

		aim_team_check_sub =
			"Ignore players on your current team",

		aim_fov =
			"Aim FOV",

		aim_smooth =
			"Aim Smoothness",

		macros_title =
			"Macros",

		macros_subtitle =
			"Record inputs and configure hold actions",

		macro_recorder =
			"Macro Recorder",

		macro_recorder_sub =
			"Records keyboard keys and mouse buttons with timing",

		macro_record =
			"RECORD",

		macro_stop =
			"STOP",

		macro_play =
			"PLAY",

		macro_clear =
			"CLEAR",

		auto_clicker =
			"Auto Clicker",

		auto_clicker_sub =
			"Click repeatedly while the assigned key is held",

		auto_click_key =
			"Auto Click Key",

		auto_click_key_sub =
			"Hold this key while Auto Clicker is enabled",

		clicks_per_second =
			"Clicks Per Second",

		status_title =
			"Runtime Status",

		status_subtitle =
			"Executions and current features",

		executions =
			"Executions",

		active =
			"ENABLED",

		disabled =
			"DISABLED",

		none =
			"None",

		settings_title =
			"Settings",

		settings_subtitle =
			"Interface and interaction",

		menu_hotkey =
			"Menu Shortcut",

		menu_hotkey_sub =
			"Key used to open and close the menu",

		panel_blur =
			"Panel Blur",

		panel_blur_sub =
			"Background blur is fixed at 90%",

		background_brightness =
			"Background Brightness",

		background_brightness_sub =
			"Adjust the menu artwork brightness",

		ui_transparency =
			"Interface Transparency",

		ui_transparency_sub =
			"Adjust cards, option surfaces and buttons",

		ui_scale =
			"UI Scale",

		ui_scale_sub =
			"Resize the whole K hub interface",

		remember_settings =
			"Remember Settings",

		remember_settings_sub =
			"Restore your K hub setup on the next execution",

		search =
			"Search this tab...",

		language =
			"Language",

		language_sub =
			"Switch between ENG and PT-BR",

		english =
			"ENG",

		portuguese =
			"PT-BR",

		instant_interact =
			"Instant Interact",

		instant_interact_sub =
			"Remove ProximityPrompt hold time",

		teleporting =
			"TELEPORTING...",

		teleport_failed =
			"TELEPORT FAILED",

		spawn_not_found =
			"SPAWN NOT FOUND",

		rejoining =
			"REJOINING...",

		rejoin_failed =
			"REJOIN FAILED",

		press_key =
			"PRESS A KEY",

		set =
			"..."
	},

	ptbr = {
		tab_info =
			"Info",

		tab_main =
			"Principal",

		tab_player =
			"Jogador",

		tab_esp =
			"ESP",

		tab_graphics =
			"Gráficos",

		tab_fps =
			"FPS",

		tab_macros =
			"Macros",

		tab_status =
			"Status",

		tab_settings =
			"Ajustes",

		top_subtitle =
			"painel utilitário",

		info_subtitle =
			"Notas da versão e avisos",

		info_version =
			"Versão em desenvolvimento",

		info_runtime =
			"Os recursos começam desativados.",

		note_development_title =
			"Desenvolvimento",

		note_development_body =
			"Esta versão ainda está em testes. Recursos e comportamentos podem mudar.",

		note_performance_title =
			"Desempenho",

		note_performance_body =
			"Rótulos vermelhos indicam opções mais pesadas, que podem reduzir o desempenho em salas grandes ou geradas.",

		note_menu_title =
			"Atalho do menu",

		note_menu_body =
			"Ctrl abre ou fecha o menu por padrão. Você pode trocar a tecla nos Ajustes.",

		main_title =
			"Sessão",

		main_subtitle =
			"Controles de servidor e spawn",

		rejoin =
			"REENTRAR NO SERVIDOR",

		rejoin_sub =
			"Reconecta a esta mesma instância",

		game_tp =
			"IR PARA O JOGO",

		game_tp_sub =
			"Teleporta para o SpawnLocation do jogo",

		lobby_tp =
			"IR PARA O LOBBY",

		lobby_tp_sub =
			"Teleporta para o SpawnLocation do lobby",

		respawn =
			"REAPARECER",

		respawn_sub =
			"Faz seu personagem reaparecer",

		player_title =
			"Jogador",

		player_subtitle =
			"Movimento e proteção",

		anti_fling =
			"Anti-Fling",

		anti_fling_sub =
			"Limita impulsos de velocidade e colisões",

		noclip =
			"Noclip",

		noclip_sub =
			"Desativa a colisão do seu personagem",

		walk_speed =
			"Velocidade",

		walk_speed_sub =
			"Define a velocidade de movimento",

		fly =
			"Voo",

		fly_sub =
			"Permite se mover livremente pelo ar",

		fly_notice =
			"Voo ativado  ·  Q desce  ·  E sobe",

		speed_manip =
			"Manipulação de Movimento",

		speed_manip_sub =
			"Segure a tecla para usar noclip com WalkSpeed 2",

		fov =
			"Campo de Visão",

		fov_sub =
			"Ajusta o campo de visão da câmera",

		freecam =
			"Câmera Livre",

		freecam_sub =
			"Solta a câmera e move com WASD + Q/E",

		freecam_speed =
			"Velocidade da Câmera",

		spectate =
			"Observar Jogador",

		spectate_sub =
			"Acompanha outro jogador e troca o alvo na própria opção",

		auto_walk =
			"Auto Walk",

		auto_walk_sub =
			"Caminha pelos objetivos detectados na ordem",

		esp_title =
			"ESP",

		esp_subtitle =
			"Jogadores e entidades potencialmente hostis",

		player_esp =
			"ESP de Jogadores",

		player_esp_sub =
			"Mostra nome e distância dos jogadores",

		friend_esp =
			"ESP de Amigos",

		friend_esp_sub =
			"Adiciona uma estrela e destaque verde ao nome normal dos amigos",

		entity_esp =
			"ESP de Entidades",

		entity_esp_sub =
			"Destaca NPCs e entidades detectadas",

		esp_filters =
			"Filtros do ESP",

		esp_filters_sub =
			"Escolha quais elementos aparecem no ESP",

		esp_names =
			"Nomes",

		esp_names_sub =
			"Mostra o nome acima dos alvos",

		esp_distance =
			"Distância",

		esp_distance_sub =
			"Mostra a distância até o personagem",

		esp_highlight =
			"Contorno",

		esp_highlight_sub =
			"Mostra o contorno através das paredes",

		entity_hostile_only =
			"Somente Entidades Hostis",

		entity_hostile_only_sub =
			"Ignora NPCs neutros quando possível",

		entity_spawn_warning =
			"Aviso de Spawn de Entidade",

		entity_spawn_warning_sub =
			"Mostra um aviso quando uma entidade hostil aparece",

		item_esp =
			"ESP de Gears",

		item_esp_sub =
			"Mostra apenas Tools do mapa que podem ser pegas como gear",

		objective_esp =
			"ESP de Objetivos",

		objective_esp_sub =
			"Destaca objetivos, chaves e alvos de progresso",

		graphics_title =
			"Gráficos",

		graphics_subtitle =
			"Qualidade visual e desempenho",

		graphics_boost =
			"Gráficos Aprimorados",

		graphics_boost_sub =
			"Melhora iluminação, reflexos, atmosfera e detalhes",

		better_textures =
			"Texturas Aprimoradas",

		better_textures_sub =
			"Melhora meshes e reduz a perda de detalhe por LOD",

		better_lights =
			"Iluminação Aprimorada",

		better_lights_sub =
			"Usa Future, sombras e luzes locais mais fortes",

		reflections =
			"Reflexos",

		reflections_sub =
			"Aumenta o brilho especular de materiais reflexivos",

		environment =
			"Ambiente",

		environment_sub =
			"Adiciona atmosfera, raios solares e profundidade",

		low_graphics =
			"Gráficos Leves",

		low_graphics_sub =
			"Reduz partículas, materiais e efeitos pesados",

		full_bright =
			"Visibilidade Máxima",

		full_bright_sub =
			"Aumenta a luz ambiente e reduz a neblina distante",

		fps_display =
			"Contador de FPS",

		fps_display_sub =
			"Mostra apenas o FPS, atualizado em até 30 Hz",

		clock_display =
			"Relógio",

		clock_display_sub =
			"Mostra sua hora local na tela",

		date_display =
			"Data",

		date_display_sub =
			"Mostra a data à esquerda do contador de FPS",

		no_fog =
			"Sem Neblina",

		no_fog_sub =
			"Remove a neblina distante e a névoa da atmosfera",

		brightness =
			"Brilho",

		brightness_sub =
			"Substitui o brilho do Lighting enquanto estiver ativo",

		hide_particles =
			"Ocultar Partículas",

		hide_particles_sub =
			"Desativa partículas, trails, beams e emissores",

		performance_mode =
			"Modo Desempenho",

		performance_mode_sub =
			"Reduz efeitos, materiais e sombras pesadas",

		heavy =
			"PESADO",

		fps_title =
			"Ferramentas FPS",

		fps_subtitle =
			"Auxílios de mira e câmera para testar jogos de tiro",

		aimbot =
			"Aimbot",

		aimbot_sub =
			"Mira no jogador válido mais próximo enquanto a tecla de mira estiver pressionada",

		aim_key =
			"Tecla de Mira",

		aim_key_sub =
			"Segure esta tecla para ativar a mira automática",

		aim_wall_check =
			"Verificar Paredes",

		aim_wall_check_sub =
			"Ignora jogadores escondidos atrás do cenário",

		aim_ignore_friends =
			"Ignorar Amigos",

		aim_ignore_friends_sub =
			"Nunca escolhe amigos do Roblox como alvo",

		aim_team_check =
			"Verificar Time",

		aim_team_check_sub =
			"Ignora jogadores do mesmo time",

		aim_fov =
			"FOV da Mira",

		aim_smooth =
			"Suavidade da Mira",

		macros_title =
			"Macros",

		macros_subtitle =
			"Grave entradas e configure ações por tecla",

		macro_recorder =
			"Gravador de Macro",

		macro_recorder_sub =
			"Grava teclas e botões do mouse mantendo o tempo entre ações",

		macro_record =
			"GRAVAR",

		macro_stop =
			"PARAR",

		macro_play =
			"REPRODUZIR",

		macro_clear =
			"LIMPAR",

		auto_clicker =
			"Auto Clicker",

		auto_clicker_sub =
			"Clica repetidamente enquanto a tecla definida estiver pressionada",

		auto_click_key =
			"Tecla do Auto Click",

		auto_click_key_sub =
			"Segure esta tecla com o Auto Clicker ativado",

		clicks_per_second =
			"Cliques por Segundo",

		status_title =
			"Status da Execução",

		status_subtitle =
			"Execuções e recursos atuais",

		executions =
			"Execuções",

		active =
			"ATIVOS",

		disabled =
			"DESATIVADOS",

		none =
			"Nenhum",

		settings_title =
			"Ajustes",

		settings_subtitle =
			"Interface e interação",

		menu_hotkey =
			"Atalho do Menu",

		menu_hotkey_sub =
			"Tecla usada para abrir e fechar o menu",

		panel_blur =
			"Desfoque do Painel",

		panel_blur_sub =
			"O desfoque do fundo fica fixo em 90%",

		background_brightness =
			"Brilho do Fundo",

		background_brightness_sub =
			"Ajusta o brilho da arte do menu",

		ui_transparency =
			"Transparência da Interface",

		ui_transparency_sub =
			"Ajusta cartões, opções e botões",

		ui_scale =
			"Escala da Interface",

		ui_scale_sub =
			"Redimensiona toda a interface do K hub",

		remember_settings =
			"Lembrar Ajustes",

		remember_settings_sub =
			"Restaura sua configuração na próxima execução",

		search =
			"Buscar nesta aba...",

		language =
			"Idioma",

		language_sub =
			"Alterna entre ENG e PT-BR",

		english =
			"ENG",

		portuguese =
			"PT-BR",

		instant_interact =
			"Interação Instantânea",

		instant_interact_sub =
			"Remove o tempo de segurar do ProximityPrompt",

		teleporting =
			"TELEPORTANDO...",

		teleport_failed =
			"FALHA NO TELEPORTE",

		spawn_not_found =
			"SPAWN NÃO ENCONTRADO",

		rejoining =
			"REENTRANDO...",

		rejoin_failed =
			"FALHA AO REENTRAR",

		press_key =
			"PRESSIONE UMA TECLA",

		set =
			"..."
	}
}

local Localized = {}

local function T(key)
	return Strings[Language][key]
		or Strings.en[key]
		or key
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
	friendEsp = false,
	entityEsp = false,

	lowGraphics = false,
	fullBright = false,

	fpsVisible = false,
	clockVisible = false,
	dateVisible = false,

	instantInteract = false,

	fov = false,
	freecam = false,
	spectate = false,

	autoWalk = false,

	aimbot = false,
	aimWallCheck = true,
	aimIgnoreFriends = true,
	aimTeamCheck = true,

	autoClickerEnabled = false,

	espShowNames = true,
	espShowDistance = true,
	espHighlight = true,

	entityOnlyHostile = true,
	entitySpawnWarning = false,

	itemEsp = false,
	objectiveEsp = false,

	noFog = false,
	brightness = false,

	hideParticles = false,
	performanceMode = false,

	rememberSettings = false,

	walkSpeedValue = 16,
	flySpeed = 30,
	freecamSpeed = 36,

	fovValue = 70,
	brightnessValue = 2.5,

	aimFov = 160,
	aimSmooth = 10,

	autoClickCps = 10,

	panelBlur = 90,
	backgroundBrightness = 34,
	uiTransparency = 5,
	uiScale = 100,

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
	fov = nil,
	freecam = nil,
	spectate = nil,
	autoWalk = nil,

	playerEsp = nil,
	friendEsp = nil,
	entityEsp = nil,

	itemEsp = nil,
	objectiveEsp = nil,

	noFog = nil,
	brightness = nil,
	hideParticles = nil,
	performanceMode = nil,

	lowGraphics = nil,
	fullBright = nil,

	fpsVisible = {
		kind = "KeyCode",
		value = Enum.KeyCode.F4
	},

	clockVisible = nil,
	dateVisible = nil,

	aimHold = {
		kind = "InputType",
		value = Enum.UserInputType.MouseButton2
	},

	autoClickerHold = {
		kind = "KeyCode",
		value = Enum.KeyCode.F6
	},

	instantInteract = nil
}

local HotkeyCapable = {
	antiFling = true,
	noclip = true,
	walkSpeed = true,
	speedManipulation = true,

	fly = true,
	fov = true,
	freecam = true,

	spectate = false,
	autoWalk = true,

	playerEsp = true,
	friendEsp = true,
	entityEsp = true,
	itemEsp = true,
	objectiveEsp = true,

	noFog = true,
	brightness = true,
	hideParticles = true,
	performanceMode = true,

	lowGraphics = false,
	fullBright = true,

	fpsVisible = true,
	clockVisible = true,
	dateVisible = true,

	aimbot = false,

	autoClickerEnabled = false,

	instantInteract = true
}

local Extra = {
	SearchBoxes = {},

	FriendEspObjects = {},
	FriendCache = {},
	FriendPending = {},

	ItemEspObjects = {},
	ObjectiveEspObjects = {},

	WarnedEntities = {},

	ParticleSaved = {},
	VisualSaved = {},

	SpectateIndex = 1,
	SelectedSpectate = nil,

	Freecam = {},

	Macro = {
		events = {},
		recording = false,
		playing = false,
		started = 0
	},

	AimHeld = false,

	AutoClickHeld = false,
	AutoClickToken = 0,

	AutoWalkToken = 0,
	AutoWalkVisited = {},

	SettingsFile = "khub_settings.json"
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

local SpeedManipSavedSpeed = nil

local PlayerEspObjects = {}
local EntityEspObjects = {}

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

local PreviousMouseBehavior =
	Enum.MouseBehavior.Default

local PreviousMouseIconEnabled =
	true

local SetFpsVisible
local SetClockVisible
local RefreshStatusPage
local ShowFlyNotice

local function Bind(signal, callback)
	local connection =
		signal:Connect(callback)

	table.insert(
		Connections,
		connection
	)

	return connection
end

local function New(
	className,
	properties,
	parent
)
	local object =
		Instance.new(className)

	for key, value in pairs(
		properties or {}
	) do
		local ok, err =
			pcall(function()
				object[key] = value
			end)

		if not ok then
			warn(
				("[K hub] Failed to set %s.%s: %s")
					:format(
						className,
						tostring(key),
						tostring(err)
					)
			)
		end
	end

	if parent then
		local ok, err =
			pcall(function()
				object.Parent = parent
			end)

		if not ok then
			warn(
				("[K hub] Failed to parent %s: %s")
					:format(
						className,
						tostring(err)
					)
			)
		end
	end

	return object
end

local function Corner(parent, radius)
	return New(
		"UICorner",
		{
			CornerRadius =
				UDim.new(
					0,
					radius or 8
				)
		},
		parent
	)
end

local function Stroke(
	parent,
	transparency,
	thickness,
	color
)
	return New(
		"UIStroke",
		{
			Color =
				color or Theme.Stroke,

			Transparency =
				transparency or 0,

			Thickness =
				thickness or 1
		},
		parent
	)
end

local function Padding(
	parent,
	left,
	right,
	top,
	bottom
)
	return New(
		"UIPadding",
		{
			PaddingLeft =
				UDim.new(0, left or 0),

			PaddingRight =
				UDim.new(0, right or 0),

			PaddingTop =
				UDim.new(0, top or 0),

			PaddingBottom =
				UDim.new(0, bottom or 0)
		},
		parent
	)
end

local function Tween(
	object,
	duration,
	properties,
	style,
	direction
)
	local tween =
		TweenService:Create(
			object,
			TweenInfo.new(
				duration,
				style
					or Enum.EasingStyle.Quart,
				direction
					or Enum.EasingDirection.Out
			),
			properties
		)

	tween:Play()

	return tween
end

local function AssetThumbnail(assetId)
	return
		"rbxthumb://type=Asset&id="
		.. tostring(assetId)
		.. "&w=420&h=420"
end

local function KeyName(keyCode)
	if Language == "ptbr" then
		local ok, localized =
			pcall(function()
				return
					UserInputService:
					GetStringForKeyCode(
						keyCode
					)
			end)

		if
			ok
			and localized
			and localized ~= ""
		then
			return
				string.upper(
					localized
				)
		end
	end

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

	return
		aliases[keyCode.Name]
		or string.upper(
			keyCode.Name
		)
end

local function FormatBinding(binding)
	if not binding then
		return T("set")
	end

	if binding.kind == "Control" then
		return "CTRL"
	end

	if binding.kind == "KeyCode" then
		return KeyName(
			binding.value
		)
	end

	if binding.kind == "InputType" then
		local aliases = {
			MouseButton1 = "MOUSE1",
			MouseButton2 = "MOUSE2",
			MouseButton3 = "MOUSE3"
		}

		return
			aliases[
				binding.value.Name
			]
			or string.upper(
				binding.value.Name
			)
	end

	return T("set")
end

local function BindingMatches(
	binding,
	input
)
	if not binding then
		return false
	end

	if binding.kind == "Control" then
		return
			input.UserInputType
				== Enum.UserInputType.Keyboard
			and (
				input.KeyCode
					== Enum.KeyCode.LeftControl
				or input.KeyCode
					== Enum.KeyCode.RightControl
			)
	end

	if binding.kind == "KeyCode" then
		return
			input.UserInputType
				== Enum.UserInputType.Keyboard
			and input.KeyCode
				== binding.value
	end

	if binding.kind == "InputType" then
		return
			input.UserInputType
				== binding.value
	end

	return false
end

local function SameBinding(a, b)
	if not a or not b then
		return false
	end

	if
		a.kind == "Control"
		and b.kind == "Control"
	then
		return true
	end

	return
		a.kind == b.kind
		and a.value == b.value
end

local function AssignBinding(
	id,
	binding
)
	if
		id ~= "menu"
		and binding
		and Bindings.menu
		and SameBinding(
			Bindings.menu,
			binding
		)
	then
		local button =
			HotkeyButtons[id]

		if
			button
			and button.Parent
		then
			button.TextColor3 =
				Theme.Red

			task.delay(
				0.28,
				function()
					if
						button
						and button.Parent
					then
						button.Text =
							FormatBinding(
								Bindings[id]
							)

						button.TextColor3 =
							Theme.Light
					end
				end
			)
		end

		return false
	end

	if binding then
		for otherId, otherBinding
			in pairs(Bindings)
		do
			if
				otherId ~= id
				and SameBinding(
					otherBinding,
					binding
				)
			then
				if
					id == "menu"
					or otherId ~= "menu"
				then
					Bindings[otherId] =
						nil

					local otherButton =
						HotkeyButtons[
							otherId
						]

					if
						otherButton
						and otherButton.Parent
					then
						otherButton.Text =
							FormatBinding(nil)

						otherButton.TextColor3 =
							Theme.Light
					end
				end
			end
		end
	end

	if
		id == "menu"
		and not binding
	then
		binding = {
			kind = "Control"
		}
	end

	Bindings[id] = binding

	local button =
		HotkeyButtons[id]

	if
		button
		and button.Parent
	then
		button.Text =
			FormatBinding(binding)

		button.TextColor3 =
			Theme.Light
	end

	if Extra.SaveSettings then
		Extra.SaveSettings()
	end

	return true
end

local function BeginHotkeyCapture(
	id,
	button
)
	if
		Capture
		and Capture.button
		and Capture.button.Parent
	then
		Capture.button.Text =
			FormatBinding(
				Bindings[
					Capture.id
				]
			)

		Capture.button.TextColor3 =
			Theme.Light
	end

	Capture = {
		id = id,
		button = button
	}

	button.Text = "..."

	button.TextColor3 =
		Theme.PurpleBright
end

local function IsForbiddenHotkey(
	keyCode
)
	local forbidden = {
		Unknown = true,
		Escape = true,
		Tab = true,

		LeftSuper = true,
		RightSuper = true,

		LeftMeta = true,
		RightMeta = true,

		Menu = true
	}

	return
		forbidden[keyCode.Name]
		== true
end

local UITransparencyTargets = {}

local function ResolveUITransparency(
	baseTransparency
)
	local amount =
		math.clamp(
			(State.uiTransparency or 0)
				/ 100,
			0,
			0.92
		)

	local base =
		math.clamp(
			baseTransparency or 0,
			0,
			1
		)

	return
		math.clamp(
			base
				+ (
					(1 - base)
					* amount
				),
			0,
			0.97
		)
end

local function RegisterUITransparency(
	instance,
	baseTransparency
)
	UITransparencyTargets[instance] =
		baseTransparency or 0

	if
		instance
		and instance.Parent
	then
		instance.BackgroundTransparency =
			ResolveUITransparency(
				baseTransparency or 0
			)
	end

	return instance
end

local function ApplyUITransparency()
	for instance, baseTransparency
		in pairs(
			UITransparencyTargets
		)
	do
		if
			instance
			and instance.Parent
		then
			instance.BackgroundTransparency =
				ResolveUITransparency(
					baseTransparency
				)
		else
			UITransparencyTargets[
				instance
			] = nil
		end
	end
end

Extra.EncodeBinding =
	function(binding)
		if not binding then
			return nil
		end

		if binding.kind == "Control" then
			return {
				kind = "Control"
			}
		end

		if
			binding.kind == "KeyCode"
			and binding.value
		then
			return {
				kind = "KeyCode",
				value =
					binding.value.Name
			}
		end

		if
			binding.kind == "InputType"
			and binding.value
		then
			return {
				kind = "InputType",
				value =
					binding.value.Name
			}
		end

		return nil
	end

Extra.DecodeBinding =
	function(data)
		if type(data) ~= "table" then
			return nil
		end

		if data.kind == "Control" then
			return {
				kind = "Control"
			}
		end

		if
			data.kind == "KeyCode"
			and data.value
			and Enum.KeyCode[
				data.value
			]
		then
			return {
				kind = "KeyCode",
				value =
					Enum.KeyCode[
						data.value
					]
			}
		end

		if
			data.kind == "InputType"
			and data.value
			and Enum.UserInputType[
				data.value
			]
		then
			return {
				kind = "InputType",
				value =
					Enum.UserInputType[
						data.value
					]
			}
		end

		return nil
	end

Extra.SaveSettings =
	function()
		if not State.rememberSettings then
			return
		end

		local data = {
			version = 5,
			language = Language,
			state = {},
			bindings = {}
		}

		for key, value
			in pairs(State)
		do
			if
				key ~= "menuVisible"
				and (
					type(value) == "boolean"
					or type(value) == "number"
					or type(value) == "string"
				)
			then
				data.state[key] =
					value
			end
		end

		for id, binding
			in pairs(Bindings)
		do
			data.bindings[id] =
				Extra.EncodeBinding(
					binding
				)
		end

		_G.KHubRemembered =
			data

		pcall(function()
			if
				typeof(writefile)
				== "function"
			then
				writefile(
					Extra.SettingsFile,
					game:GetService(
						"HttpService"
					):JSONEncode(
						data
					)
				)
			end
		end)
	end

Extra.ClearSavedSettings =
	function()
		_G.KHubRemembered =
			nil

		pcall(function()
			if
				typeof(delfile)
					== "function"
				and typeof(isfile)
					== "function"
				and isfile(
					Extra.SettingsFile
				)
			then
				delfile(
					Extra.SettingsFile
				)
			end
		end)
	end

Extra.LoadSettings =
	function()
		local data =
			_G.KHubRemembered

		if type(data) ~= "table" then
			pcall(function()
				if
					typeof(readfile)
						== "function"
					and typeof(isfile)
						== "function"
					and isfile(
						Extra.SettingsFile
					)
				then
					data =
						game:GetService(
							"HttpService"
						):JSONDecode(
							readfile(
								Extra.SettingsFile
							)
						)
				end
			end)
		end

		if
			type(data) ~= "table"
			or type(data.state)
				~= "table"
			or data.state.rememberSettings
				~= true
		then
			return
		end

		for key, value
			in pairs(data.state)
		do
			if
				State[key] ~= nil
				and key ~= "menuVisible"
			then
				State[key] = value
			end
		end

		State.panelBlur = 90

		if
			data.language == "en"
			or data.language == "ptbr"
		then
			Language =
				data.language
		end

		if
			type(data.bindings)
				== "table"
		then
			for id, encoded
				in pairs(
					data.bindings
				)
			do
				if
					Bindings[id] ~= nil
					or id == "menu"
				then
					Bindings[id] =
						Extra.DecodeBinding(
							encoded
						)
				end
			end
		end

		if not Bindings.menu then
			Bindings.menu = {
				kind = "Control"
			}
		end
	end

Extra.LoadSettings()

local ScreenGui =
	New(
		"ScreenGui",
		{
			Name = "KHub",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 2147483647,
			ZIndexBehavior =
				Enum.ZIndexBehavior.Global,
			ScreenInsets =
				Enum.ScreenInsets.None
		},
		GuiParent
	)

local Intro =
	New(
		"CanvasGroup",
		{
			Size =
				UDim2.fromScale(1, 1),

			BackgroundColor3 =
				Theme.Base,

			BackgroundTransparency =
				0,

			GroupTransparency =
				0,

			ZIndex =
				2000
		},
		ScreenGui
	)

local IntroParts = {}

IntroParts.Backdrop =
	New(
		"Frame",
		{
			Size =
				UDim2.fromScale(1, 1),

			BackgroundColor3 =
				Theme.Base,

			BorderSizePixel =
				0,

			ZIndex =
				2000
		},
		Intro
	)

IntroParts.Gradient =
	New(
		"UIGradient",
		{
			Color =
				ColorSequence.new({
					ColorSequenceKeypoint.new(
						0,
						Color3.fromRGB(
							8,
							9,
							12
						)
					),

					ColorSequenceKeypoint.new(
						0.5,
						Color3.fromRGB(
							14,
							14,
							19
						)
					),

					ColorSequenceKeypoint.new(
						1,
						Color3.fromRGB(
							7,
							8,
							10
						)
					)
				}),

			Rotation = -18
		},
		IntroParts.Backdrop
	)

IntroParts.Glow =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					160,
					160
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),

			BackgroundColor3 =
				Theme.PurpleBright,

			BackgroundTransparency =
				0.94,

			BorderSizePixel =
				0,

			ZIndex =
				2001
		},
		Intro
	)

Corner(
	IntroParts.Glow,
	80
)

IntroParts.IconBox =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					82,
					82
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),

			BackgroundColor3 =
				Theme.Surface2,

			BackgroundTransparency =
				0.04,

			BorderSizePixel =
				0,

			ZIndex =
				2003
		},
		Intro
	)

Corner(
	IntroParts.IconBox,
	20
)

IntroParts.IconStroke =
	Stroke(
		IntroParts.IconBox,
		0.50,
		1,
		Theme.Stroke
	)

IntroParts.Icon =
	New(
		"ImageLabel",
		{
			Size =
				UDim2.fromOffset(
					54,
					54
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),

			BackgroundTransparency =
				1,

			Image =
				AssetThumbnail(
					HUB_ICON_ASSET_ID
				),

			ImageTransparency =
				0,

			ZIndex =
				2004
		},
		IntroParts.IconBox
	)

IntroParts.IconScale =
	New(
		"UIScale",
		{
			Scale = 0.72
		},
		IntroParts.IconBox
	)

IntroParts.K =
	New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					28,
					30
				),

			AnchorPoint =
				Vector2.new(
					1,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					-3,
					0.5,
					82
				),

			BackgroundTransparency =
				1,

			Text =
				"K",

			TextColor3 =
				Theme.White,

			TextTransparency =
				1,

			TextSize =
				24,

			Font =
				Enum.Font.GothamBold,

			TextXAlignment =
				Enum.TextXAlignment.Right,

			ZIndex =
				2004
		},
		Intro
	)

IntroParts.Hub =
	New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					52,
					30
				),

			AnchorPoint =
				Vector2.new(
					0,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					3,
					0.5,
					82
				),

			BackgroundTransparency =
				1,

			Text =
				"hub",

			TextColor3 =
				Theme.Muted,

			TextTransparency =
				1,

			TextSize =
				22,

			Font =
				Enum.Font.GothamMedium,

			TextXAlignment =
				Enum.TextXAlignment.Left,

			ZIndex =
				2004
		},
		Intro
	)

IntroParts.Status =
	New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					220,
					18
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0.5,
					116
				),

			BackgroundTransparency =
				1,

			Text =
				"initializing",

			TextColor3 =
				Theme.Muted2,

			TextTransparency =
				1,

			TextSize =
				10,

			Font =
				Enum.Font.GothamMedium,

			ZIndex =
				2004
		},
		Intro
	)

IntroParts.Progress =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					220,
					2
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0.5,
					142
				),

			BackgroundColor3 =
				Theme.Surface4,

			BackgroundTransparency =
				0.20,

			BorderSizePixel =
				0,

			ZIndex =
				2002
		},
		Intro
	)

Corner(
	IntroParts.Progress,
	1
)

IntroParts.ProgressFill =
	New(
		"Frame",
		{
			Size =
				UDim2.fromScale(
					0,
					1
				),

			BackgroundColor3 =
				Theme.PurpleBright,

			BackgroundTransparency =
				0.12,

			BorderSizePixel =
				0,

			ZIndex =
				2003
		},
		IntroParts.Progress
	)

Corner(
	IntroParts.ProgressFill,
	1
)

IntroParts.Dot =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					5,
					5
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					-118,
					0.5,
					142
				),

			BackgroundColor3 =
				Theme.White,

			BackgroundTransparency =
				1,

			BorderSizePixel =
				0,

			ZIndex =
				2004
		},
		Intro
	)

Corner(
	IntroParts.Dot,
	3
)

IntroParts.RingOuter =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					138,
					138
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0.5,
					0
				),

			BackgroundTransparency =
				1,

			ZIndex =
				2001
		},
		Intro
	)

Corner(
	IntroParts.RingOuter,
	69
)

IntroParts.RingStroke =
	Stroke(
		IntroParts.RingOuter,
		1,
		1,
		Theme.PurpleBright
	)

IntroParts.RingInner =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					112,
					112
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0.5,
					0
				),

			BackgroundTransparency =
				1,

			ZIndex =
				2001
		},
		Intro
	)

Corner(
	IntroParts.RingInner,
	56
)

IntroParts.RingInnerStroke =
	Stroke(
		IntroParts.RingInner,
		1,
		1,
		Theme.Stroke
	)

IntroParts.Tagline =
	New(
		"TextLabel",
		{
			Size =
				UDim2.fromOffset(
					320,
					18
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0.5,
					92
				),

			BackgroundTransparency =
				1,

			Text =
				"a small utility space",

			TextColor3 =
				Theme.Muted,

			TextTransparency =
				1,

			TextSize =
				10,

			Font =
				Enum.Font.GothamMedium,

			ZIndex =
				2004
		},
		Intro
	)

IntroParts.SparkA =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					4,
					4
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					-82,
					0.5,
					-38
				),

			BackgroundColor3 =
				Theme.PurpleBright,

			BackgroundTransparency =
				1,

			BorderSizePixel =
				0,

			ZIndex =
				2004
		},
		Intro
	)

Corner(
	IntroParts.SparkA,
	2
)

IntroParts.SparkB =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					3,
					3
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.new(
					0.5,
					76,
					0.5,
					38
				),

			BackgroundColor3 =
				Theme.White,

			BackgroundTransparency =
				1,

			BorderSizePixel =
				0,

			ZIndex =
				2004
		},
		Intro
	)

Corner(
	IntroParts.SparkB,
	2
)

local Main =
	New(
		"CanvasGroup",
		{
			Name =
				"Main",

			Size =
				UDim2.fromOffset(
					940,
					600
				),

			Position =
				UDim2.new(
					0.5,
					-470,
					0.5,
					-300
				),

			BackgroundColor3 =
				Theme.Base,

			BorderSizePixel =
				0,

			ClipsDescendants =
				true,

			GroupTransparency =
				1,

			Visible =
				false,

			ZIndex =
				20
		},
		ScreenGui
	)

Corner(
	Main,
	9
)

local MainScale =
	New(
		"UIScale",
		{
			Scale =
				0.96
		},
		Main
	)

local Background =
	New(
		"ImageLabel",
		{
			Size =
				UDim2.fromScale(
					1,
					1
				),

			Position =
				UDim2.fromScale(
					0,
					0
				),

			BackgroundTransparency =
				1,

			Image =
				AssetThumbnail(
					BACKGROUND_ASSET_ID
				),

			ImageTransparency =
				0.86,

			ImageColor3 =
				Color3.fromRGB(
					118,
					120,
					126
				),

			ScaleType =
				Enum.ScaleType.Crop,

			ZIndex =
				20
		},
		Main
	)

Corner(
	Background,
	9
)

local BlurLayers = {}

for _, offset in ipairs({
	Vector2.new(-3, 0),
	Vector2.new(3, 0),
	Vector2.new(0, -3),
	Vector2.new(0, 3)
}) do
	local layer =
		New(
			"ImageLabel",
			{
				Size =
					UDim2.fromScale(
						1,
						1
					),

				Position =
					UDim2.fromOffset(
						offset.X,
						offset.Y
					),

				BackgroundTransparency =
					1,

				Image =
					AssetThumbnail(
						BACKGROUND_ASSET_ID
					),

				ImageTransparency =
					1,

				ImageColor3 =
					Color3.fromRGB(
						185,
						185,
						185
					),

				ScaleType =
					Enum.ScaleType.Crop,

				ZIndex =
					20
			},
			Main
		)

	Corner(
		layer,
		12
	)

	table.insert(
		BlurLayers,
		{
			image = layer,
			offset = offset
		}
	)
end

local BackgroundShade =
	New(
		"Frame",
		{
			Size =
				UDim2.fromScale(
					1,
					1
				),

			BackgroundColor3 =
				Theme.Black,

			BackgroundTransparency =
				0.08,

			BorderSizePixel =
				0,

			ZIndex =
				21
		},
		Main
	)

Corner(
	BackgroundShade,
	9
)

local TopBar =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,
					0,
					0,
					68
				),

			BackgroundColor3 =
				Theme.Surface,

			BackgroundTransparency =
				0.10,

			BorderSizePixel =
				0,

			Active =
				true,

			ZIndex =
				50
		},
		Main
	)

RegisterUITransparency(
	TopBar,
	0.10
)

local HubIconBox =
	New(
		"Frame",
		{
			Size =
				UDim2.fromOffset(
					46,
					46
				),

			Position =
				UDim2.fromOffset(
					14,
					11
				),

			BackgroundColor3 =
				Theme.Surface2,

			BorderSizePixel =
				0,

			ZIndex =
				51
		},
		TopBar
	)

Corner(
	HubIconBox,
	10
)

RegisterUITransparency(
	HubIconBox,
	0
)

local HubIcon =
	New(
		"ImageLabel",
		{
			Size =
				UDim2.fromOffset(
					34,
					34
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0.5
				),

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),

			BackgroundTransparency =
				1,

			Image =
				AssetThumbnail(
					HUB_ICON_ASSET_ID
				),

			ZIndex =
				52
		},
		HubIconBox
	)

local Sidebar =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					0,
					184,
					1,
					-68
				),

			Position =
				UDim2.fromOffset(
					0,
					68
				),

			BackgroundColor3 =
				Theme.Surface,

			BackgroundTransparency =
				0.09,

			BorderSizePixel =
				0,

			ZIndex =
				45
		},
		Main
	)

RegisterUITransparency(
	Sidebar,
	0.09
)

local SidebarSeparator =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					0,
					1,
					1,
					0
				),

			Position =
				UDim2.new(
					1,
					-1,
					0,
					0
				),

			BackgroundColor3 =
				Theme.Surface4,

			BackgroundTransparency =
				0.55,

			BorderSizePixel =
				0,

			ZIndex =
				46
		},
		Sidebar
	)

local TabsHolder =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,
					0,
					1,
					-72
				),

			BackgroundTransparency =
				1,

			ZIndex =
				46
		},
		Sidebar
	)

Padding(
	TabsHolder,
	11,
	11,
	14,
	8
)

New(
	"UIListLayout",
	{
		Padding =
			UDim.new(
				0,
				5
			),

		SortOrder =
			Enum.SortOrder.LayoutOrder
	},
	TabsHolder
)

local Profile =
	New(
		"TextButton",
		{
			Size =
				UDim2.new(
					1,
					-22,
					0,
					58
				),

			Position =
				UDim2.new(
					0,
					11,
					1,
					-64
				),

			BackgroundColor3 =
				Theme.Surface2,

			BackgroundTransparency =
				0.25,

			BorderSizePixel =
				0,

			Text =
				"",

			AutoButtonColor =
				false,

			ZIndex =
				46
		},
		Sidebar
	)

Corner(
	Profile,
	9
)

RegisterUITransparency(
	Profile,
	0.25
)

local ProfileScale =
	New(
		"UIScale",
		{
			Scale = 1
		},
		Profile
	)

local Avatar =
	New(
		"ImageLabel",
		{
			Size =
				UDim2.fromOffset(
					36,
					36
				),

			Position =
				UDim2.fromOffset(
					9,
					11
				),

			BackgroundColor3 =
				Theme.Surface3,

			BorderSizePixel =
				0,

			Image =
				"",

			ZIndex =
				47
		},
		Profile
	)

Corner(
	Avatar,
	9
)

local ProfileName =
	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,
					-56,
					0,
					17
				),

			Position =
				UDim2.fromOffset(
					53,
					10
				),

			BackgroundTransparency =
				1,

			Text =
				LocalPlayer.DisplayName,

			TextColor3 =
				Theme.White,

			TextSize =
				12,

			Font =
				Enum.Font.GothamSemibold,

			TextXAlignment =
				Enum.TextXAlignment.Left,

			TextTruncate =
				Enum.TextTruncate.AtEnd,

			ZIndex =
				47
		},
		Profile
	)

local ProfileUser =
	New(
		"TextLabel",
		{
			Size =
				UDim2.new(
					1,
					-56,
					0,
					15
				),

			Position =
				UDim2.fromOffset(
					53,
					29
				),

			BackgroundTransparency =
				1,

			Text =
				"@" .. LocalPlayer.Name,

			TextColor3 =
				Theme.Muted,

			TextSize =
				10,

			Font =
				Enum.Font.Gotham,

			TextXAlignment =
				Enum.TextXAlignment.Left,

			TextTruncate =
				Enum.TextTruncate.AtEnd,

			ZIndex =
				47
		},
		Profile
	)

local UsernameCover =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,
					-64,
					0,
					10
				),

			Position =
				UDim2.fromOffset(
					55,
					33
				),

			BackgroundColor3 =
				Theme.Black,

			BorderSizePixel =
				0,

			ZIndex =
				48
		},
		Profile
	)

Corner(
	UsernameCover,
	3
)

Bind(
	Profile.MouseEnter,
	function()
		Tween(
			UsernameCover,
			0.20,
			{
				Size =
					UDim2.new(
						0,
						0,
						0,
						10
					),

				BackgroundTransparency =
					1
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			ProfileScale,
			0.20,
			{
				Scale = 1.018
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			Profile,
			0.20,
			{
				BackgroundColor3 =
					Theme.Surface3
			},
			Enum.EasingStyle.Quart
		)
	end
)

Bind(
	Profile.MouseLeave,
	function()
		Tween(
			UsernameCover,
			0.20,
			{
				Size =
					UDim2.new(
						1,
						-64,
						0,
						10
					),

				BackgroundTransparency =
					0
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			ProfileScale,
			0.20,
			{
				Scale = 1
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			Profile,
			0.20,
			{
				BackgroundColor3 =
					Theme.Surface2
			},
			Enum.EasingStyle.Quart
		)
	end
)

Bind(
	Profile.MouseButton1Down,
	function()
		Tween(
			ProfileScale,
			0.07,
			{
				Scale = 0.975
			},
			Enum.EasingStyle.Quart
		)
	end
)

Bind(
	Profile.MouseButton1Up,
	function()
		Tween(
			ProfileScale,
			0.16,
			{
				Scale = 1.018
			},
			Enum.EasingStyle.Back
		)
	end
)

local Content =
	New(
		"Frame",
		{
			Size =
				UDim2.new(
					1,
					-184,
					1,
					-68
				),

			Position =
				UDim2.fromOffset(
					184,
					68
				),

			BackgroundTransparency =
				1,

			ZIndex =
				45
		},
		Main
	)

local Pages = {}
local PageScrolls = {}
local Tabs = {}

local function CreatePage(name)
	local group =
		New(
			"CanvasGroup",
			{
				Name =
					name .. "Page",

				Size =
					UDim2.fromScale(
						1,
						1
					),

				Position =
					UDim2.fromOffset(
						0,
						0
					),

				BackgroundTransparency =
					1,

				GroupTransparency =
					1,

				Visible =
					false,

				ZIndex =
					45
			},
			Content
		)

	local page =
		New(
			"ScrollingFrame",
			{
				Name =
					name,

				Size =
					UDim2.fromScale(
						1,
						1
					),

				BackgroundTransparency =
					1,

				BorderSizePixel =
					0,

				ScrollBarThickness =
					2,

				ScrollBarImageColor3 =
					Theme.Muted2,

				ScrollBarImageTransparency =
					0.58,

				AutomaticCanvasSize =
					Enum.AutomaticSize.Y,

				CanvasSize =
					UDim2.fromOffset(
						0,
						0
					),

				ZIndex =
					45
			},
			group
		)

	New(
		"UIListLayout",
		{
			Padding =
				UDim.new(
					0,
					9
				),

			SortOrder =
				Enum.SortOrder.LayoutOrder
		},
		page
	)

	Padding(
		page,
		22,
		22,
		18,
		22
	)

	Pages[name] =
		group

	PageScrolls[name] =
		page

	return page
end

local CurrentPageName = nil
local PageAnimationId = 0

local function SelectPage(name)
	local target =
		Pages[name]

	if
		not target
		or CurrentPageName == name
	then
		return
	end

	PageAnimationId += 1

	local animationId =
		PageAnimationId

	local previous =
		CurrentPageName
		and Pages[
			CurrentPageName
		]
		or nil

	CurrentPageName =
		name

	if
		previous
		and previous ~= target
	then
		Tween(
			previous,
			0.12,
			{
				GroupTransparency =
					1
			},
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.In
		)

		task.delay(
			0.12,
			function()
				if
					animationId
						== PageAnimationId
					and previous
						~= Pages[
							CurrentPageName
						]
				then
					previous.Visible =
						false
				end
			end
		)
	end

	target.Visible =
		true

	target.Position =
		UDim2.fromOffset(
			0,
			0
		)

	target.GroupTransparency =
		1

	task.defer(function()
		if
			animationId
				~= PageAnimationId
		then
			return
		end

		Tween(
			target,
			0.22,
			{
				GroupTransparency =
					0
			},
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)
	end)

	for tabName, data
		in pairs(Tabs)
	do
		local selected =
			tabName == name

		Tween(
			data.button,
			0.20,
			{
				BackgroundTransparency =
					selected
					and ResolveUITransparency(
						0.78
					)
					or 1,

				BackgroundColor3 =
					Theme.Surface3,

				TextColor3 =
					selected
					and Theme.White
					or Theme.Muted
			},
			Enum.EasingStyle.Quint
		)
	end
end

local function CreateTab(
	name,
	textKey,
	order
)
	local button =
		RegisterText(
			New(
				"TextButton",
				{
					Size =
						UDim2.new(
							1,
							0,
							0,
							40
						),

					BackgroundColor3 =
						Theme.Surface3,

					BackgroundTransparency =
						1,

					BorderSizePixel =
						0,

					TextColor3 =
						Theme.Muted,

					TextSize =
						13,

					Font =
						Enum.Font.GothamMedium,

					TextXAlignment =
						Enum.TextXAlignment.Left,

					AutoButtonColor =
						false,

					LayoutOrder =
						order,

					ZIndex =
						47
				},
				TabsHolder
			),
			textKey
		)

	Corner(
		button,
		8
	)

	Padding(
		button,
		15,
		8,
		0,
		0
	)

	local scale =
		New(
			"UIScale",
			{
				Scale = 1
			},
			button
		)

	Bind(
		button.MouseEnter,
		function()
			if
				not Pages[name].Visible
			then
				Tween(
					button,
					0.16,
					{
						BackgroundTransparency =
							ResolveUITransparency(
								0.84
							),

						TextColor3 =
							Theme.Light
					},
					Enum.EasingStyle.Quart
				)
			end

			Tween(
				scale,
				0.16,
				{
					Scale =
						1.006
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		button.MouseLeave,
		function()
			if
				not Pages[name].Visible
			then
				Tween(
					button,
					0.16,
					{
						BackgroundTransparency =
							1,

						TextColor3 =
							Theme.Muted
					},
					Enum.EasingStyle.Quart
				)
			end

			Tween(
				scale,
				0.16,
				{
					Scale =
						1
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		button.MouseButton1Down,
		function()
			Tween(
				scale,
				0.07,
				{
					Scale =
						0.985
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		button.MouseButton1Up,
		function()
			Tween(
				scale,
				0.15,
				{
					Scale =
						1.006
				},
				Enum.EasingStyle.Back
			)
		end
	)

	Bind(
		button.MouseButton1Click,
		function()
			SelectPage(name)
		end
	)

	Tabs[name] = {
		button = button
	}
end

local InfoPage =
	CreatePage("Info")

local MainPage =
	CreatePage("Main")

local PlayerPage =
	CreatePage("Player")

local EspPage =
	CreatePage("ESP")

local GraphicsPage =
	CreatePage("Graphics")

local StatusPage =
	CreatePage("Status")

local SettingsPage =
	CreatePage("Settings")

Extra.FpsPage =
	CreatePage("FPS")

Extra.MacroPage =
	CreatePage("Macros")

CreateTab(
	"Info",
	"tab_info",
	1
)

CreateTab(
	"Main",
	"tab_main",
	2
)

CreateTab(
	"Player",
	"tab_player",
	3
)

CreateTab(
	"ESP",
	"tab_esp",
	4
)

CreateTab(
	"FPS",
	"tab_fps",
	5
)

CreateTab(
	"Graphics",
	"tab_graphics",
	6
)

CreateTab(
	"Macros",
	"tab_macros",
	7
)

CreateTab(
	"Settings",
	"tab_settings",
	8
)

local function Section(
	parent,
	titleKey,
	subtitleKey,
	order
)
	local holder =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						subtitleKey
							and 50
							or 30
					),

				BackgroundTransparency =
					1,

				LayoutOrder =
					order,

				ZIndex =
					46
			},
			parent
		)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						22
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.White,

				TextSize =
					18,

				Font =
					Enum.Font.GothamSemibold,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				ZIndex =
					47
			},
			holder
		),
		titleKey
	)

	if subtitleKey then
		RegisterText(
			New(
				"TextLabel",
				{
					Size =
						UDim2.new(
							1,
							0,
							0,
							16
						),

					Position =
						UDim2.fromOffset(
							0,
							25
						),

					BackgroundTransparency =
						1,

					TextColor3 =
						Theme.Muted,

					TextSize =
						11,

					Font =
						Enum.Font.Gotham,

					TextXAlignment =
						Enum.TextXAlignment.Left,

					ZIndex =
						47
				},
				holder
			),
			subtitleKey
		)
	end
end

local function NoteCard(
	parent,
	titleKey,
	bodyKey,
	order,
	red
)
	local card =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						70
					),

				BackgroundColor3 =
					Theme.Surface,

				BackgroundTransparency =
					0.08,

				BorderSizePixel =
					0,

				LayoutOrder =
					order,

				ZIndex =
					46
			},
			parent
		)

	Corner(
		card,
		9
	)

	RegisterUITransparency(
		card,
		0.08
	)

	local dot =
		New(
			"Frame",
			{
				Size =
					UDim2.fromOffset(
						6,
						6
					),

				Position =
					UDim2.fromOffset(
						14,
						17
					),

				BackgroundColor3 =
					red
					and Theme.Red
					or Theme.PurpleBright,

				BorderSizePixel =
					0,

				ZIndex =
					47
			},
			card
		)

	Corner(
		dot,
		3
	)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-42,
						0,
						18
					),

				Position =
					UDim2.fromOffset(
						28,
						10
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					red
					and Theme.Red
					or Theme.White,

				TextSize =
					13,

				Font =
					Enum.Font.GothamSemibold,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				ZIndex =
					47
			},
			card
		),
		titleKey
	)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-42,
						0,
						35
					),

				Position =
					UDim2.fromOffset(
						28,
						31
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.Muted,

				TextSize =
					10,

				Font =
					Enum.Font.Gotham,

				TextWrapped =
					true,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				TextYAlignment =
					Enum.TextYAlignment.Top,

				ZIndex =
					47
			},
			card
		),
		bodyKey
	)
end

local function ActionButton(
	parent,
	titleKey,
	subtitleKey,
	order,
	callback
)
	local button =
		New(
			"TextButton",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						54
					),

				BackgroundColor3 =
					Theme.Surface2,

				BackgroundTransparency =
					0.02,

				BorderSizePixel =
					0,

				Text =
					"",

				AutoButtonColor =
					false,

				ClipsDescendants =
					true,

				LayoutOrder =
					order,

				ZIndex =
					46
			},
			parent
		)

	Corner(
		button,
		9
	)

	Stroke(
		button,
		0.58,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		button,
		0.02
	)

	local overlay =
		New(
			"Frame",
			{
				Size =
					UDim2.fromScale(
						1,
						1
					),

				BackgroundColor3 =
					Theme.White,

				BackgroundTransparency =
					1,

				BorderSizePixel =
					0,

				ZIndex =
					47
			},
			button
		)

	Corner(
		overlay,
		9
	)

	local title =
		RegisterText(
			New(
				"TextLabel",
				{
					Size =
						UDim2.new(
							1,
							-28,
							0,
							18
						),

					Position =
						UDim2.fromOffset(
							14,
							9
						),

					BackgroundTransparency =
						1,

					TextColor3 =
						Theme.White,

					TextSize =
						13,

					Font =
						Enum.Font.GothamSemibold,

					TextXAlignment =
						Enum.TextXAlignment.Left,

					ZIndex =
						49
				},
				button
			),
			titleKey
		)

	local subtitle =
		RegisterText(
			New(
				"TextLabel",
				{
					Size =
						UDim2.new(
							1,
							-28,
							0,
							15
						),

					Position =
						UDim2.fromOffset(
							14,
							29
						),

					BackgroundTransparency =
						1,

					TextColor3 =
						Theme.Muted,

					TextSize =
						10,

					Font =
						Enum.Font.Gotham,

					TextXAlignment =
						Enum.TextXAlignment.Left,

					ZIndex =
						49
				},
				button
			),
			subtitleKey
		)

	local scale =
		New(
			"UIScale",
			{
				Scale = 1
			},
			button
		)

	Bind(
		button.MouseEnter,
		function()
			Tween(
				overlay,
				0.18,
				{
					BackgroundTransparency =
						ResolveUITransparency(
							0.95
						)
				},
				Enum.EasingStyle.Quart
			)

			Tween(
				scale,
				0.18,
				{
					Scale = 1.006
				},
				Enum.EasingStyle.Quint
			)
		end
	)

	Bind(
		button.MouseLeave,
		function()
			Tween(
				overlay,
				0.18,
				{
					BackgroundTransparency =
						1
				},
				Enum.EasingStyle.Quart
			)

			Tween(
				scale,
				0.20,
				{
					Scale = 1
				},
				Enum.EasingStyle.Quint
			)
		end
	)

	Bind(
		button.MouseButton1Down,
		function()
			Tween(
				scale,
				0.07,
				{
					Scale = 0.974
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		button.MouseButton1Up,
		function()
			Tween(
				scale,
				0.16,
				{
					Scale = 1.006
				},
				Enum.EasingStyle.Back
			)
		end
	)

	Bind(
		button.MouseButton1Click,
		callback
	)

	return {
		button = button,
		title = title,
		subtitle = subtitle,
		titleKey = titleKey,
		subtitleKey = subtitleKey
	}
end

local function CreateInlineHotkey(
	row,
	id,
	options
)
	options = options or {}

	local button =
		New(
			"TextButton",
			{
				Size =
					UDim2.fromOffset(
						options.width or 72,
						28
					),

				Position =
					UDim2.new(
						1,
						options.buttonOffset
							or -174,
						0.5,
						-14
					),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				Text =
					FormatBinding(
						Bindings[id]
					),

				TextColor3 =
					Theme.Light,

				TextSize =
					10,

				Font =
					Enum.Font.GothamBold,

				AutoButtonColor =
					false,

				ZIndex =
					50
			},
			row
		)

	Corner(
		button,
		6
	)

	Stroke(
		button,
		0.68,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		button,
		0
	)

	local reset =
		New(
			"TextButton",
			{
				Size =
					UDim2.fromOffset(
						28,
						28
					),

				Position =
					UDim2.new(
						1,
						options.resetOffset
							or -96,
						0.5,
						-14
					),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				Text =
					"×",

				TextColor3 =
					Theme.Muted2,

				TextSize =
					13,

				Font =
					Enum.Font.GothamBold,

				AutoButtonColor =
					false,

				ZIndex =
					50
			},
			row
		)

	Corner(
		reset,
		6
	)

	Stroke(
		reset,
		0.68,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		reset,
		0
	)

	HotkeyButtons[id] =
		button

	Bind(
		button.MouseEnter,
		function()
			Tween(
				button,
				0.16,
				{
					BackgroundColor3 =
						Theme.Surface3,

					TextColor3 =
						Theme.White
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		button.MouseLeave,
		function()
			if
				not Capture
				or Capture.id ~= id
			then
				Tween(
					button,
					0.16,
					{
						BackgroundColor3 =
							Theme.Surface2,

						TextColor3 =
							Theme.Light
					},
					Enum.EasingStyle.Quad
				)
			end
		end
	)

	Bind(
		reset.MouseEnter,
		function()
			Tween(
				reset,
				0.16,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							43,
							24,
							29
						),

					TextColor3 =
						Theme.Red
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		reset.MouseLeave,
		function()
			Tween(
				reset,
				0.16,
				{
					BackgroundColor3 =
						Theme.Surface2,

					TextColor3 =
						Theme.Muted2
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		button.MouseButton1Click,
		function()
			BeginHotkeyCapture(
				id,
				button
			)
		end
	)

	Bind(
		reset.MouseButton1Click,
		function()
			if
				Capture
				and Capture.id == id
			then
				Capture = nil
			end

			AssignBinding(
				id,
				nil
			)
		end
	)

	return button, reset
end

local function CreateToggle(
	parent,
	config
)
	local hasHotkey =
		HotkeyCapable[
			config.id
		] == true

	local row =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						config.height
							or 64
					),

				BackgroundColor3 =
					Theme.Surface,

				BackgroundTransparency =
					0.08,

				BorderSizePixel =
					0,

				LayoutOrder =
					config.order,

				ZIndex =
					46
			},
			parent
		)

	Corner(
		row,
		7
	)

	Stroke(
		row,
		0.86,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		row,
		0.08
	)

	local overlay =
		New(
			"Frame",
			{
				Size =
					UDim2.fromScale(
						1,
						1
					),

				BackgroundColor3 =
					Theme.Surface3,

				BackgroundTransparency =
					1,

				BorderSizePixel =
					0,

				ZIndex =
					46
			},
			row
		)

	Corner(
		overlay,
		7
	)

	local rightReserve =
		config.rightReserve
		or (
			hasHotkey
			and 225
			or 82
		)

	if config.warning then
		rightReserve += 92
	end

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-rightReserve,
						0,
						18
					),

				Position =
					UDim2.fromOffset(
						14,
						11
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.White,

				TextSize =
					14,

				Font =
					Enum.Font.GothamSemibold,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				TextTruncate =
					Enum.TextTruncate.AtEnd,

				ZIndex =
					48
			},
			row
		),
		config.titleKey
	)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-rightReserve,
						0,
						16
					),

				Position =
					UDim2.fromOffset(
						14,
						32
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.Muted,

				TextSize =
					10,

				Font =
					Enum.Font.Gotham,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				TextTruncate =
					Enum.TextTruncate.AtEnd,

				ZIndex =
					48
			},
			row
		),
		config.subtitleKey
	)

	if config.warning then
		local warningOffset =
			hasHotkey
			and -264
			or -150

		local warning =
			RegisterText(
				New(
					"TextLabel",
					{
						Size =
							UDim2.fromOffset(
								76,
								20
							),

						Position =
							UDim2.new(
								1,
								warningOffset,
								0.5,
								-10
							),

						BackgroundColor3 =
							Color3.fromRGB(
								46,
								22,
								27
							),

						BackgroundTransparency =
							0.08,

						BorderSizePixel =
							0,

						TextColor3 =
							Theme.Red,

						TextSize =
							9,

						Font =
							Enum.Font.GothamBold,

						ZIndex =
							49
					},
					row
				),
				"heavy"
			)

		Corner(
			warning,
			5
		)
	end

	if hasHotkey then
		CreateInlineHotkey(
			row,
			config.id
		)
	end

	local switch =
		New(
			"TextButton",
			{
				Size =
					UDim2.fromOffset(
						46,
						24
					),

				Position =
					UDim2.new(
						1,
						-58,
						0.5,
						-12
					),

				BackgroundColor3 =
					Theme.Off,

				BorderSizePixel =
					0,

				Text =
					"",

				AutoButtonColor =
					false,

				ZIndex =
					49
			},
			row
		)

	Corner(
		switch,
		12
	)

	RegisterUITransparency(
		switch,
		0
	)

	local knob =
		New(
			"Frame",
			{
				Size =
					UDim2.fromOffset(
						18,
						18
					),

				Position =
					UDim2.fromOffset(
						3,
						3
					),

				BackgroundColor3 =
					Theme.White,

				BorderSizePixel =
					0,

				ZIndex =
					50
			},
			switch
		)

	Corner(
		knob,
		9
	)

	local knobScale =
		New(
			"UIScale",
			{
				Scale =
					1
			},
			knob
		)

	local function Apply(enabled)
		Tween(
			switch,
			0.20,
			{
				BackgroundColor3 =
					enabled
					and Theme.Purple
					or Theme.Off
			},
			Enum.EasingStyle.Quart
		)

		Tween(
			knob,
			0.22,
			{
				Position =
					enabled
					and UDim2.fromOffset(
						25,
						3
					)
					or UDim2.fromOffset(
						3,
						3
					)
			},
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)

		knobScale.Scale =
			0.82

		Tween(
			knobScale,
			0.22,
			{
				Scale =
					1
			},
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
	end

	local function Set(enabled)
		State[
			config.id
		] = enabled

		Apply(enabled)

		if config.changed then
			config.changed(
				enabled
			)
		end

		if RefreshStatusPage then
			RefreshStatusPage()
		end

		if Extra.SaveSettings then
			Extra.SaveSettings()
		end
	end

	ToggleSetters[
		config.id
	] = Set

	Bind(
		row.MouseEnter,
		function()
			Tween(
				overlay,
				0.18,
				{
					BackgroundTransparency =
						ResolveUITransparency(
							0.90
						)
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		row.MouseLeave,
		function()
			Tween(
				overlay,
				0.18,
				{
					BackgroundTransparency =
						1
				},
				Enum.EasingStyle.Quart
			)
		end
	)

	Bind(
		switch.MouseButton1Click,
		function()
			Set(
				not State[
					config.id
				]
			)
		end
	)

	Apply(
		State[
			config.id
		] == true
	)

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
	local current =
		initial

	local dragging =
		false

	local valueBox =
		New(
			"TextBox",
			{
				Size =
					UDim2.fromOffset(
						66,
						28
					),

				Position =
					UDim2.new(
						1,
						-80,
						0,
						y - 14
					),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				Text =
					tostring(initial)
					.. (
						percent
						and "%"
						or ""
					),

				TextColor3 =
					Theme.White,

				TextSize =
					11,

				Font =
					Enum.Font.GothamBold,

				ClearTextOnFocus =
					false,

				TextXAlignment =
					Enum.TextXAlignment.Center,

				ZIndex =
					54
			},
			row
		)

	Corner(
		valueBox,
		7
	)

	Stroke(
		valueBox,
		0.65,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		valueBox,
		0
	)

	local track =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						-140,
						0,
						4
					),

				Position =
					UDim2.fromOffset(
						14,
						y
					),

				BackgroundColor3 =
					Theme.Off,

				BorderSizePixel =
					0,

				ZIndex =
					50
			},
			row
		)

	Corner(
		track,
		2
	)

	local fill =
		New(
			"Frame",
			{
				Size =
					UDim2.fromScale(
						(
							initial
							- minimum
						)
							/ (
								maximum
								- minimum
							),
						1
					),

				BackgroundColor3 =
					Theme.Purple,

				BorderSizePixel =
					0,

				ZIndex =
					51
			},
			track
		)

	Corner(
		fill,
		2
	)

	local knob =
		New(
			"Frame",
			{
				Size =
					UDim2.fromOffset(
						14,
						14
					),

				AnchorPoint =
					Vector2.new(
						0.5,
						0.5
					),

				Position =
					UDim2.new(
						(
							initial
							- minimum
						)
							/ (
								maximum
								- minimum
							),
						0,
						0.5,
						0
					),

				BackgroundColor3 =
					Theme.White,

				BorderSizePixel =
					0,

				ZIndex =
					52
			},
			track
		)

	Corner(
		knob,
		7
	)

	local hitbox =
		New(
			"TextButton",
			{
				Size =
					UDim2.new(
						1,
						-122,
						0,
						30
					),

				Position =
					UDim2.fromOffset(
						5,
						y - 15
					),

				BackgroundTransparency =
					1,

				BorderSizePixel =
					0,

				Text =
					"",

				AutoButtonColor =
					false,

				Active =
					true,

				ZIndex =
					53
			},
			row
		)

	local function ParseValue(text)
		local cleaned =
			tostring(text):
			gsub(",", ".")

		local numberText =
			cleaned:
			match(
				"%-?%d+%.?%d*"
			)

		return
			tonumber(numberText)
	end

	local function SetValue(value)
		local numeric =
			tonumber(value)
			or current

		numeric =
			math.clamp(
				numeric,
				minimum,
				maximum
			)

		numeric =
			math.floor(
				numeric + 0.5
			)

		current =
			numeric

		local alpha =
			(
				numeric - minimum
			)
			/ (
				maximum - minimum
			)

		Tween(
			fill,
			0.10,
			{
				Size =
					UDim2.fromScale(
						alpha,
						1
					)
			},
			Enum.EasingStyle.Quart
		)

		Tween(
			knob,
			0.10,
			{
				Position =
					UDim2.new(
						alpha,
						0,
						0.5,
						0
					)
			},
			Enum.EasingStyle.Quart
		)

		valueBox.Text =
			tostring(numeric)
			.. (
				percent
					and "%"
					or ""
			)

		callback(numeric)

		if Extra.SaveSettings then
			Extra.SaveSettings()
		end
	end

	local function SetFromX(x)
		if
			track.AbsoluteSize.X
				<= 0
		then
			return
		end

		local alpha =
			math.clamp(
				(
					x
					- track.AbsolutePosition.X
				)
					/ track.AbsoluteSize.X,
				0,
				1
			)

		SetValue(
			minimum
				+ (
					(
						maximum - minimum
					)
					* alpha
				)
		)
	end

	Bind(
		hitbox.InputBegan,
		function(input)
			if
				input.UserInputType
					== Enum.UserInputType.MouseButton1
				or input.UserInputType
					== Enum.UserInputType.Touch
			then
				dragging =
					true

				SetFromX(
					input.Position.X
				)
			end
		end
	)

	Bind(
		UserInputService.InputChanged,
		function(input)
			if
				dragging
				and (
					input.UserInputType
						== Enum.UserInputType.MouseMovement
					or input.UserInputType
						== Enum.UserInputType.Touch
				)
			then
				SetFromX(
					input.Position.X
				)
			end
		end
	)

	Bind(
		UserInputService.InputEnded,
		function(input)
			if
				input.UserInputType
					== Enum.UserInputType.MouseButton1
				or input.UserInputType
					== Enum.UserInputType.Touch
			then
				dragging =
					false
			end
		end
	)

	Bind(
		valueBox.Focused,
		function()
			valueBox.Text =
				tostring(current)

			valueBox.CursorPosition =
				#valueBox.Text + 1
		end
	)

	Bind(
		valueBox.FocusLost,
		function()
			SetValue(
				ParseValue(
					valueBox.Text
				)
				or current
			)
		end
	)

	SetValue(initial)

	return {
		Set = SetValue,
		Box = valueBox
	}
end

local function CreateHotkeyRow(
	parent,
	id,
	titleKey,
	subtitleKey,
	order
)
	local row =
		New(
			"Frame",
			{
				Size =
					UDim2.new(
						1,
						0,
						0,
						64
					),

				BackgroundColor3 =
					Theme.Surface,

				BackgroundTransparency =
					0.04,

				BorderSizePixel =
					0,

				LayoutOrder =
					order,

				ZIndex =
					46
			},
			parent
		)

	Corner(
		row,
		7
	)

	Stroke(
		row,
		0.82,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		row,
		0.04
	)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-185,
						0,
						20
					),

				Position =
					UDim2.fromOffset(
						14,
						10
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.White,

				TextSize =
					14,

				Font =
					Enum.Font.GothamSemibold,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				ZIndex =
					47
			},
			row
		),
		titleKey
	)

	RegisterText(
		New(
			"TextLabel",
			{
				Size =
					UDim2.new(
						1,
						-185,
						0,
						18
					),

				Position =
					UDim2.fromOffset(
						14,
						34
					),

				BackgroundTransparency =
					1,

				TextColor3 =
					Theme.Muted,

				TextSize =
					10,

				Font =
					Enum.Font.Gotham,

				TextXAlignment =
					Enum.TextXAlignment.Left,

				ZIndex =
					47
			},
			row
		),
		subtitleKey
	)

	local button =
		New(
			"TextButton",
			{
				Size =
					UDim2.fromOffset(
						72,
						28
					),

				Position =
					UDim2.new(
						1,
						-174,
						0.5,
						-14
					),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				Text =
					FormatBinding(
						Bindings[id]
					),

				TextColor3 =
					Theme.White,

				TextSize =
					10,

				Font =
					Enum.Font.GothamBold,

				AutoButtonColor =
					false,

				ZIndex =
					48
			},
			row
		)

	Corner(
		button,
		6
	)

	Stroke(
		button,
		0.68,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		button,
		0
	)

	local reset =
		New(
			"TextButton",
			{
				Size =
					UDim2.fromOffset(
						28,
						28
					),

				Position =
					UDim2.new(
						1,
						-96,
						0.5,
						-14
					),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				Text =
					"×",

				TextColor3 =
					Theme.Muted,

				TextSize =
					14,

				Font =
					Enum.Font.GothamBold,

				AutoButtonColor =
					false,

				ZIndex =
					48
			},
			row
		)

	Corner(
		reset,
		6
	)

	Stroke(
		reset,
		0.68,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		reset,
		0
	)

	HotkeyButtons[id] =
		button

	Bind(
		button.MouseEnter,
		function()
			Tween(
				button,
				0.12,
				{
					BackgroundColor3 =
						Theme.Surface3
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		button.MouseLeave,
		function()
			Tween(
				button,
				0.12,
				{
					BackgroundColor3 =
						Theme.Surface2
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		reset.MouseEnter,
		function()
			Tween(
				reset,
				0.12,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							45,
							20,
							25
						),

					TextColor3 =
						Theme.Red
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		reset.MouseLeave,
		function()
			Tween(
				reset,
				0.12,
				{
					BackgroundColor3 =
						Theme.Surface2,

					TextColor3 =
						Theme.Muted
				},
				Enum.EasingStyle.Quad
			)
		end
	)

	Bind(
		button.MouseButton1Click,
		function()
			BeginHotkeyCapture(
				id,
				button
			)
		end
	)

	Bind(
		reset.MouseButton1Click,
		function()
			if
				Capture
				and Capture.id == id
			then
				Capture =
					nil
			end

			if id == "menu" then
				AssignBinding(
					id,
					{
						kind = "Control"
					}
				)
			else
				AssignBinding(
					id,
					nil
				)
			end
		end
	)
end

local function RestoreLocalCollision()
	for part, value
		in pairs(
			SavedLocalCollision
		)
	do
		if
			part
			and part.Parent
		then
			part.CanCollide =
				value
		end
	end

	table.clear(
		SavedLocalCollision
	)
end

local function RestoreOtherCollision()
	for part, value
		in pairs(
			SavedOtherCollision
		)
	do
		if
			part
			and part.Parent
		then
			part.CanCollide =
				value
		end
	end

	table.clear(
		SavedOtherCollision
	)
end

local function StopSpeedManipulation()
	if not State.speedManipulation then
		return
	end

	State.speedManipulation =
		false

	local character =
		LocalPlayer.Character

	local humanoid =
		character
		and character:
			FindFirstChildOfClass(
				"Humanoid"
			)

	if humanoid then
		if State.walkSpeed then
			humanoid.WalkSpeed =
				State.walkSpeedValue
		elseif
			SpeedManipSavedSpeed
				~= nil
		then
			humanoid.WalkSpeed =
				SpeedManipSavedSpeed
		end
	end

	SpeedManipSavedSpeed =
		nil

	if RefreshStatusPage then
		RefreshStatusPage()
	end
end

local function StartSpeedManipulation()
	if State.speedManipulation then
		return
	end

	local character =
		LocalPlayer.Character

	local humanoid =
		character
		and character:
			FindFirstChildOfClass(
				"Humanoid"
			)

	if
		not character
		or not humanoid
	then
		return
	end

	State.speedManipulation =
		true

	SpeedManipSavedSpeed =
		humanoid.WalkSpeed

	humanoid.WalkSpeed =
		2

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

	local character =
		LocalPlayer.Character

	local root =
		character
		and character:
			FindFirstChild(
				"HumanoidRootPart"
			)

	if not root then
		return
	end

	FlyGyro =
		New(
			"Attachment",
			{
				Name =
					"KHubFlyAttachment"
			},
			root
		)

	FlyVelocity =
		New(
			"LinearVelocity",
			{
				Name =
					"KHubFlyVelocity",

				Attachment0 =
					FlyGyro,

				RelativeTo =
					Enum.ActuatorRelativeTo.World,

				MaxForce =
					math.huge,

				VectorVelocity =
					Vector3.zero
			},
			root
		)

	New(
		"AlignOrientation",
		{
			Name =
				"KHubFlyAlign",

			Attachment0 =
				FlyGyro,

			Mode =
				Enum.OrientationAlignmentMode.OneAttachment,

			Responsiveness =
				12,

			MaxTorque =
				math.huge,

			CFrame =
				root.CFrame
		},
		FlyGyro
	)
end

local function DestroyPlayerEsp(player)
	local data =
		PlayerEspObjects[player]

	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	PlayerEspObjects[player] =
		nil
end

local function EnsurePlayerEsp(player)
	local isFriend =
		State.friendEsp
		and Extra.IsFriend
		and Extra.IsFriend(player)
		or false

	local shouldShow =
		State.playerEsp
		or (
			State.friendEsp
			and isFriend
		)

	if not shouldShow then
		DestroyPlayerEsp(player)
		return
	end

	local character =
		player.Character

	if not character then
		DestroyPlayerEsp(player)
		return
	end

	local head =
		character:
			FindFirstChild(
				"Head"
			)

	local root =
		character:
			FindFirstChild(
				"HumanoidRootPart"
			)

	if not head or not root then
		return
	end

	local data =
		PlayerEspObjects[player]

	if
		data
		and data.character
			~= character
	then
		DestroyPlayerEsp(player)
		data = nil
	end

	local markedFriend =
		State.friendEsp
		and isFriend

	local tint =
		markedFriend
			and Theme.Green
			or Theme.PurpleBright

	if not data then
		local highlight =
			New(
				"Highlight",
				{
					Name =
						"KHubPlayerESP",

					Adornee =
						character,

					FillColor =
						tint,

					FillTransparency =
						0.76,

					OutlineColor =
						tint,

					OutlineTransparency =
						0.03,

					DepthMode =
						Enum.HighlightDepthMode.AlwaysOnTop
				},
				ScreenGui
			)

		local billboard =
			New(
				"BillboardGui",
				{
					Name =
						"KHubPlayerESPLabel",

					Adornee =
						head,

					Size =
						UDim2.fromOffset(
							220,
							28
						),

					StudsOffset =
						Vector3.new(
							0,
							2.72,
							0
						),

					AlwaysOnTop =
						true,

					ZIndexBehavior =
						Enum.ZIndexBehavior.Global
				},
				ScreenGui
			)

		local label =
			New(
				"TextLabel",
				{
					Size =
						UDim2.fromScale(
							1,
							1
						),

					BackgroundTransparency =
						1,

					TextColor3 =
						Theme.White,

					TextStrokeColor3 =
						tint,

					TextStrokeTransparency =
						0.25,

					TextSize =
						12,

					Font =
						Enum.Font.GothamSemibold,

					ZIndex =
						60
				},
				billboard
			)

		data = {
			character =
				character,

			root =
				root,

			highlight =
				highlight,

			billboard =
				billboard,

			label =
				label
		}

		PlayerEspObjects[player] =
			data
	end

	data.root =
		root

	if data.highlight then
		data.highlight.FillColor =
			tint

		data.highlight.OutlineColor =
			tint

		data.highlight.Enabled =
			State.espHighlight
	end

	if data.label then
		data.label.TextStrokeColor3 =
			tint
	end

	local localRoot =
		LocalPlayer.Character
		and LocalPlayer.Character:
			FindFirstChild(
				"HumanoidRootPart"
			)

	local distance =
		localRoot
		and math.floor(
			(
				localRoot.Position
				- root.Position
			).Magnitude
			+ 0.5
		)
		or 0

	local pieces = {}

	if State.espShowNames then
		table.insert(
			pieces,
			(
				markedFriend
				and "★ "
				or ""
			)
			.. player.DisplayName
		)
	end

	if State.espShowDistance then
		table.insert(
			pieces,
			tostring(distance)
				.. "m"
		)
	end

	data.billboard.Enabled =
		#pieces > 0

	data.label.Text =
		table.concat(
			pieces,
			"  ·  "
		)
end

local function ClearPlayerEsp()
	for player
		in pairs(
			PlayerEspObjects
		)
	do
		DestroyPlayerEsp(player)
	end
end

Extra.RefreshFriendStatus =
	function(player)
		if
			not player
			or player == LocalPlayer
		then
			return false
		end

		Extra.FriendPending[
			player.UserId
		] = true

		local ok, isFriend =
			pcall(function()
				return
					LocalPlayer:
					IsFriendsWith(
						player.UserId
					)
			end)

		Extra.FriendPending[
			player.UserId
		] = nil

		Extra.FriendCache[
			player.UserId
		] =
			ok
			and isFriend == true
			or false

		return
			Extra.FriendCache[
				player.UserId
			]
	end

Extra.IsFriend =
	function(player)
		if
			not player
			or player == LocalPlayer
		then
			return false
		end

		local cached =
			Extra.FriendCache[
				player.UserId
			]

		if cached ~= nil then
			return
				cached == true
		end

		if
			not Extra.FriendPending[
				player.UserId
			]
		then
			Extra.FriendPending[
				player.UserId
			] = true

			task.spawn(function()
				Extra.RefreshFriendStatus(
					player
				)
			end)
		end

		return false
	end

Extra.DestroyFriendEsp =
	function(player)
		local data =
			Extra.FriendEspObjects[
				player
			]

		if data then
			if data.highlight then
				data.highlight:
					Destroy()
			end

			if data.billboard then
				data.billboard:
					Destroy()
			end

			Extra.FriendEspObjects[
				player
			] = nil
		end
	end

Extra.EnsureFriendEsp =
	function(player)
		if
			player
			and player ~= LocalPlayer
		then
			EnsurePlayerEsp(player)
		end
	end

Extra.RefreshFriendEsp =
	function()
		Extra.ClearFriendEsp()

		for _, player
			in ipairs(
				Players:GetPlayers()
			)
		do
			if player ~= LocalPlayer then
				task.spawn(function()
					Extra.RefreshFriendStatus(
						player
					)

					if
						State.friendEsp
						or State.playerEsp
					then
						EnsurePlayerEsp(
							player
						)
					end
				end)
			end
		end
	end

Extra.ClearFriendEsp =
	function()
		for player
			in pairs(
				Extra.FriendEspObjects
			)
		do
			Extra.DestroyFriendEsp(
				player
			)
		end
	end

local HostileKeywords = {
	"enemy",
	"monster",
	"hostile",
	"killer",
	"boss",
	"zombie",
	"demon",
	"creature",
	"rush",
	"ambush",
	"seek",
	"figure"
}

local HostileTags = {
	"Enemy",
	"Monster",
	"Hostile",
	"Killer",
	"Boss"
}

local HostileAttributes = {
	"Hostile",
	"IsHostile",
	"Enemy",
	"IsEnemy",
	"CanKill",
	"KillsPlayer",
	"Damage",
	"AttackDamage"
}

local function IsPlayerCharacterModel(
	model
)
	for _, player
		in ipairs(
			Players:GetPlayers()
		)
	do
		if player.Character == model then
			return true
		end
	end

	return false
end

local function IsPotentiallyHostile(
	model
)
	if
		not model
		or not model:IsA(
			"Model"
		)
		or not model.Parent
	then
		return false
	end

	if
		IsPlayerCharacterModel(
			model
		)
	then
		return false
	end

	for _, attribute
		in ipairs(
			HostileAttributes
		)
	do
		local value =
			model:GetAttribute(
				attribute
			)

		if
			value == true
			or (
				typeof(value)
					== "number"
				and value > 0
			)
		then
			return true
		end
	end

	for _, tag
		in ipairs(
			HostileTags
		)
	do
		if
			CollectionService:
			HasTag(
				model,
				tag
			)
		then
			return true
		end
	end

	local lowerName =
		string.lower(
			model.Name
		)

	for _, keyword
		in ipairs(
			HostileKeywords
		)
	do
		if
			string.find(
				lowerName,
				keyword,
				1,
				true
			)
		then
			return true
		end
	end

	if
		not State.entityOnlyHostile
	then
		if
			CollectionService:
				HasTag(
					model,
					"Entity"
				)
			or CollectionService:
				HasTag(
					model,
					"NPC"
				)
			or model:GetAttribute(
				"Entity"
			) == true
			or model:GetAttribute(
				"IsEntity"
			) == true
			or string.find(
				string.lower(
					model.Name
				),
				"entity",
				1,
				true
			)
		then
			return true
		end

		local humanoid =
			model:
			FindFirstChildOfClass(
				"Humanoid"
			)

		if
			humanoid
			and humanoid.Health > 0
		then
			return true
		end
	end

	return false
end

local function DestroyEntityEsp(
	model
)
	local data =
		EntityEspObjects[
			model
		]

	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	EntityEspObjects[model] =
		nil
end

local function GetEntityAnchor(
	model
)
	return
		model:
			FindFirstChild(
				"Head"
			)
		or model.PrimaryPart
		or model:
			FindFirstChild(
				"HumanoidRootPart"
			)
		or model:
			FindFirstChildWhichIsA(
				"BasePart",
				true
			)
end

local function EnsureEntityEsp(
	model
)
	if
		not IsPotentiallyHostile(
			model
		)
	then
		DestroyEntityEsp(
			model
		)

		return
	end

	local anchor =
		GetEntityAnchor(
			model
		)

	if not anchor then
		return
	end

	local data =
		EntityEspObjects[
			model
		]

	if not data then
		local highlight =
			New(
				"Highlight",
				{
					Name =
						"KHubEntityESP",

					Adornee =
						model,

					FillColor =
						Theme.Red,

					FillTransparency =
						0.78,

					OutlineColor =
						Theme.Red,

					OutlineTransparency =
						0.06,

					DepthMode =
						Enum.HighlightDepthMode.AlwaysOnTop
				},
				ScreenGui
			)

		local billboard =
			New(
				"BillboardGui",
				{
					Name =
						"KHubEntityESPLabel",

					Adornee =
						anchor,

					Size =
						UDim2.fromOffset(
							220,
							28
						),

					StudsOffset =
						Vector3.new(
							0,
							2.8,
							0
						),

					AlwaysOnTop =
						true,

					ZIndexBehavior =
						Enum.ZIndexBehavior.Global
				},
				ScreenGui
			)

		local label =
			New(
				"TextLabel",
				{
					Size =
						UDim2.fromScale(
							1,
							1
						),

					BackgroundTransparency =
						1,

					TextColor3 =
						Theme.White,

					TextStrokeColor3 =
						Theme.Red,

					TextStrokeTransparency =
						0.32,

					TextSize =
						12,

					Font =
						Enum.Font.GothamSemibold,

					ZIndex =
						60
				},
				billboard
			)

		data = {
			anchor = anchor,
			highlight = highlight,
			billboard = billboard,
			label = label
		}

		EntityEspObjects[
			model
		] = data
	end
-- K HUB V6 — PARTE 2/2

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local distance = 0

	if localRoot and data.anchor and data.anchor.Parent then
		distance = math.floor(
			(localRoot.Position - data.anchor.Position).Magnitude + 0.5
		)
	end

	if data.highlight then
		data.highlight.Enabled = State.espHighlight
	end

	local pieces = {}

	if State.espShowNames then
		table.insert(pieces, model.Name)
	end

	if State.espShowDistance then
		table.insert(pieces, tostring(distance) .. "m")
	end

	data.billboard.Enabled = #pieces > 0
	data.label.Text = table.concat(pieces, "  ·  ")
end

local function RefreshEntityEsp()
	local seen = {}

	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("Model") and IsPotentiallyHostile(object) then
			seen[object] = true
			EnsureEntityEsp(object)
		end
	end

	for model in pairs(EntityEspObjects) do
		if not seen[model] or not model.Parent then
			DestroyEntityEsp(model)
		end
	end
end

local function ClearEntityEsp()
	for model in pairs(EntityEspObjects) do
		DestroyEntityEsp(model)
	end
end

Extra.GetAnchor = function(object)
	if not object or not object.Parent then
		return nil
	end

	if object:IsA("Tool") then
		return object:FindFirstChild("Handle")
			or object:FindFirstChildWhichIsA("BasePart", true)
	end

	if object:IsA("BasePart") then
		return object
	end

	if object:IsA("Model") then
		return object.PrimaryPart
			or object:FindFirstChild("HumanoidRootPart")
			or object:FindFirstChild("Head")
			or object:FindFirstChildWhichIsA("BasePart", true)
	end

	return object:FindFirstAncestorWhichIsA("BasePart")
end

Extra.IsItem = function(object)
	if not object or not object.Parent then
		return false
	end

	local tool = object:IsA("Tool")
		and object
		or object:FindFirstAncestorOfClass("Tool")

	if not tool or not tool:IsDescendantOf(Workspace) then
		return false
	end

	if LocalPlayer.Character and tool:IsDescendantOf(LocalPlayer.Character) then
		return false
	end

	local handle = tool:FindFirstChild("Handle")
		or tool:FindFirstChildWhichIsA("BasePart", true)

	return handle ~= nil
end

Extra.IsObjective = function(object)
	if not object or not object.Parent then
		return false
	end

	local candidate = object:IsA("Model")
		and object
		or object:FindFirstAncestorOfClass("Model")
		or object

	for _, tag in ipairs({
		"Objective",
		"Quest",
		"Goal",
		"Target",
		"Generator",
		"Checkpoint"
	}) do
		if CollectionService:HasTag(candidate, tag)
			or CollectionService:HasTag(object, tag) then
			return true
		end
	end

	for _, attr in ipairs({
		"Objective",
		"IsObjective",
		"QuestTarget",
		"ProgressTarget"
	}) do
		if candidate:GetAttribute(attr) == true
			or object:GetAttribute(attr) == true then
			return true
		end
	end

	local name = string.lower(candidate.Name or object.Name)

	for _, word in ipairs({
		"objective",
		"generator",
		"checkpoint",
		"quest",
		"goal",
		"exit",
		"lever",
		"switch"
	}) do
		if string.find(name, word, 1, true) then
			return true
		end
	end

	return false
end

Extra.DestroyGenericEsp = function(store, object)
	local data = store[object]

	if not data then
		return
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	store[object] = nil
end

Extra.EnsureGenericEsp = function(store, object, kind)
	local predicate = kind == "item"
		and Extra.IsItem
		or Extra.IsObjective

	if not predicate(object) then
		Extra.DestroyGenericEsp(store, object)
		return
	end

	if kind == "item" then
		object = object:IsA("Tool")
			and object
			or object:FindFirstAncestorOfClass("Tool")
			or object
	end

	local anchor = Extra.GetAnchor(object)

	if not anchor then
		return
	end

	local adornee = object
	local data = store[adornee]

	if not data then
		local tint = kind == "item"
			and Color3.fromRGB(130, 190, 164)
			or Color3.fromRGB(185, 174, 125)

		local highlight = New("Highlight", {
			Name = kind == "item"
				and "KHubItemESP"
				or "KHubObjectiveESP",

			Adornee = kind == "item"
				and anchor
				or adornee,

			FillColor = tint,
			FillTransparency = 0.82,
			OutlineColor = tint,
			OutlineTransparency = 0.10,

			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		}, ScreenGui)

		local billboard = New("BillboardGui", {
			Name = kind == "item"
				and "KHubItemLabel"
				or "KHubObjectiveLabel",

			Adornee = anchor,

			Size = UDim2.fromOffset(210, 26),

			StudsOffset = Vector3.new(
				0,
				2.3,
				0
			),

			AlwaysOnTop = true,

			ZIndexBehavior = Enum.ZIndexBehavior.Global
		}, ScreenGui)

		local label = New("TextLabel", {
			Size = UDim2.fromScale(1, 1),

			BackgroundTransparency = 1,

			TextColor3 = Theme.White,
			TextStrokeColor3 = tint,
			TextStrokeTransparency = 0.35,

			TextSize = 12,

			Font = Enum.Font.GothamSemibold,

			ZIndex = 60
		}, billboard)

		data = {
			highlight = highlight,
			billboard = billboard,
			label = label,
			anchor = anchor,
			object = adornee
		}

		store[adornee] = data
	end

	if data.highlight then
		data.highlight.Enabled = State.espHighlight
	end

	local root = LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	local distance = root
		and data.anchor
		and math.floor(
			(root.Position - data.anchor.Position).Magnitude + 0.5
		)
		or 0

	local pieces = {}

	if State.espShowNames then
		table.insert(
			pieces,
			data.object.Name
		)
	end

	if State.espShowDistance then
		table.insert(
			pieces,
			tostring(distance) .. "m"
		)
	end

	data.billboard.Enabled = #pieces > 0
	data.label.Text = table.concat(
		pieces,
		"  ·  "
	)
end

Extra.RefreshGenericEsp = function(kind)
	local store = kind == "item"
		and Extra.ItemEspObjects
		or Extra.ObjectiveEspObjects

	local predicate = kind == "item"
		and Extra.IsItem
		or Extra.IsObjective

	local seen = {}

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do
		local eligible =
			kind == "item"
				and object:IsA("Tool")
			or (
				kind ~= "item"
				and (
					object:IsA("Model")
					or object:IsA("BasePart")
				)
			)

		if eligible and predicate(object) then
			local target = object

			if not seen[target] then
				seen[target] = true

				Extra.EnsureGenericEsp(
					store,
					target,
					kind
				)
			end
		end
	end

	for object in pairs(store) do
		if not seen[object] or not object.Parent then
			Extra.DestroyGenericEsp(
				store,
				object
			)
		end
	end
end

Extra.ClearGenericEsp = function(kind)
	local store = kind == "item"
		and Extra.ItemEspObjects
		or Extra.ObjectiveEspObjects

	for object in pairs(store) do
		Extra.DestroyGenericEsp(
			store,
			object
		)
	end
end

Extra.Toast = function(message, danger)
	Extra.ToastSerial = (Extra.ToastSerial or 0) + 1

	local holder = New("CanvasGroup", {
		Size = UDim2.fromOffset(300, 54),

		AnchorPoint = Vector2.new(1, 0),

		Position = UDim2.new(
			1,
			-18,
			0,
			18
		),

		BackgroundColor3 = Theme.Surface2,

		BackgroundTransparency = 0.04,

		BorderSizePixel = 0,

		GroupTransparency = 1,

		ZIndex = 1200
	}, ScreenGui)

	Corner(holder, 11)

	Stroke(
		holder,
		0.72,
		1,
		danger
			and Theme.Red
			or Theme.Stroke
	)

	New("TextLabel", {
		Size = UDim2.new(
			1,
			-30,
			1,
			0
		),

		Position = UDim2.fromOffset(
			15,
			0
		),

		BackgroundTransparency = 1,

		Text = message,

		TextColor3 = danger
			and Theme.Red
			or Theme.White,

		TextSize = 12,

		Font = Enum.Font.GothamSemibold,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextTruncate = Enum.TextTruncate.AtEnd,

		ZIndex = 1201
	}, holder)

	Tween(
		holder,
		0.28,
		{
			GroupTransparency = 0,

			Position = UDim2.new(
				1,
				-18,
				0,
				28
			)
		},
		Enum.EasingStyle.Quint
	)

	task.delay(3.2, function()
		if holder and holder.Parent then
			local fade = Tween(
				holder,
				0.24,
				{
					GroupTransparency = 1,

					Position = UDim2.new(
						1,
						10,
						0,
						28
					)
				},
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.In
			)

			fade.Completed:Once(function()
				if holder and holder.Parent then
					holder:Destroy()
				end
			end)
		end
	end)
end

Extra.EnableNoFog = function()
	if not Extra.VisualSaved.fog then
		Extra.VisualSaved.fog = {
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd
		}
	end

	Lighting.FogStart = 0
	Lighting.FogEnd = 1000000

	local atmosphere =
		Lighting:FindFirstChildOfClass(
			"Atmosphere"
		)

	if atmosphere then
		if not Extra.VisualSaved.atmosphere then
			Extra.VisualSaved.atmosphere = {
				object = atmosphere,
				Density = atmosphere.Density,
				Haze = atmosphere.Haze
			}
		end

		atmosphere.Density = 0
		atmosphere.Haze = 0
	end
end

Extra.DisableNoFog = function()
	if Extra.VisualSaved.fog then
		Lighting.FogStart =
			Extra.VisualSaved.fog.FogStart

		Lighting.FogEnd =
			Extra.VisualSaved.fog.FogEnd
	end

	local saved =
		Extra.VisualSaved.atmosphere

	if saved
		and saved.object
		and saved.object.Parent then
		saved.object.Density =
			saved.Density

		saved.object.Haze =
			saved.Haze
	end

	Extra.VisualSaved.fog = nil
	Extra.VisualSaved.atmosphere = nil
end

Extra.SetParticlesHidden = function(hidden)
	if hidden then
		for _, object in ipairs(
			Workspace:GetDescendants()
		) do
			if object:IsA("ParticleEmitter")
				or object:IsA("Trail")
				or object:IsA("Beam")
				or object:IsA("Smoke")
				or object:IsA("Fire")
				or object:IsA("Sparkles") then

				if Extra.ParticleSaved[object] == nil then
					Extra.ParticleSaved[object] =
						object.Enabled
				end

				object.Enabled = false
			end
		end
	else
		for object, enabled in pairs(
			Extra.ParticleSaved
		) do
			if object and object.Parent then
				object.Enabled = enabled
			end
		end

		table.clear(
			Extra.ParticleSaved
		)
	end
end

Extra.StartFreecam = function()
	if Extra.Freecam.active then
		return
	end

	Extra.Freecam.active = true

	Extra.Freecam.cameraType =
		Camera.CameraType

	Extra.Freecam.subject =
		Camera.CameraSubject

	Extra.Freecam.cframe =
		Camera.CFrame

	Extra.Freecam.position =
		Camera.CFrame.Position

	local x, y =
		Camera.CFrame:ToOrientation()

	Extra.Freecam.pitch = x
	Extra.Freecam.yaw = y

	Extra.Freecam.mouseBehavior =
		UserInputService.MouseBehavior

	Extra.Freecam.mouseIcon =
		UserInputService.MouseIconEnabled

	local character =
		LocalPlayer.Character

	local root =
		character
		and character:FindFirstChild(
			"HumanoidRootPart"
		)

	local humanoid =
		character
		and character:FindFirstChildOfClass(
			"Humanoid"
		)

	Extra.Freecam.root = root
	Extra.Freecam.humanoid = humanoid

	if root then
		Extra.Freecam.rootAnchored =
			root.Anchored

		root.AssemblyLinearVelocity =
			Vector3.zero

		root.AssemblyAngularVelocity =
			Vector3.zero

		root.Anchored = true
	end

	if humanoid then
		Extra.Freecam.autoRotate =
			humanoid.AutoRotate

		humanoid.AutoRotate =
			false
	end

	Camera.CameraType =
		Enum.CameraType.Scriptable

	if not State.menuVisible then
		UserInputService.MouseBehavior =
			Enum.MouseBehavior.LockCenter

		UserInputService.MouseIconEnabled =
			false
	end
end

Extra.StopFreecam = function()
	if not Extra.Freecam.active then
		return
	end

	Extra.Freecam.active = false

	if Extra.Freecam.root
		and Extra.Freecam.root.Parent then
		Extra.Freecam.root.Anchored =
			Extra.Freecam.rootAnchored == true
	end

	if Extra.Freecam.humanoid
		and Extra.Freecam.humanoid.Parent then
		Extra.Freecam.humanoid.AutoRotate =
			Extra.Freecam.autoRotate ~= false
	end

	Camera.CameraType =
		Extra.Freecam.cameraType
		or Enum.CameraType.Custom

	Camera.CameraSubject =
		Extra.Freecam.subject

	if Extra.Freecam.cframe then
		Camera.CFrame =
			Extra.Freecam.cframe
	end

	PreviousMouseBehavior =
		Extra.Freecam.mouseBehavior
		or Enum.MouseBehavior.Default

	PreviousMouseIconEnabled =
		Extra.Freecam.mouseIcon ~= false

	if not State.menuVisible then
		UserInputService.MouseBehavior =
			PreviousMouseBehavior

		UserInputService.MouseIconEnabled =
			PreviousMouseIconEnabled
	end

	Extra.Freecam.root = nil
	Extra.Freecam.humanoid = nil
end

Extra.UpdateSpectate = function()
	local available = {}

	for _, player in ipairs(
		Players:GetPlayers()
	) do
		if player ~= LocalPlayer then
			table.insert(
				available,
				player
			)
		end
	end

	if #available == 0 then
		Extra.SelectedSpectate = nil
	else
		Extra.SpectateIndex =
			math.clamp(
				Extra.SpectateIndex or 1,
				1,
				#available
			)

		Extra.SelectedSpectate =
			available[
				Extra.SpectateIndex
			]
	end

	if Extra.SpectateUI
		and Extra.SpectateUI.Name then
		Extra.SpectateUI.Name.Text =
			Extra.SelectedSpectate
				and Extra.SelectedSpectate.DisplayName
				or "—"
	end

	if State.spectate then
		local character =
			Extra.SelectedSpectate
			and Extra.SelectedSpectate.Character

		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)

		if humanoid then
			Camera.CameraType =
				Enum.CameraType.Custom

			Camera.CameraSubject =
				humanoid
		end
	end
end

Extra.StopSpectate = function()
	local humanoid =
		LocalPlayer.Character
		and LocalPlayer.Character:
			FindFirstChildOfClass(
				"Humanoid"
			)

	if humanoid and not State.freecam then
		Camera.CameraType =
			Enum.CameraType.Custom

		Camera.CameraSubject =
			humanoid
	end
end

Extra.GetAimTarget = function()
	if not Camera then
		return nil
	end

	local center = Vector2.new(
		Camera.ViewportSize.X * 0.5,
		Camera.ViewportSize.Y * 0.5
	)

	local bestPart = nil
	local bestDistance =
		State.aimFov or 160

	for _, player in ipairs(
		Players:GetPlayers()
	) do
		if player ~= LocalPlayer then
			local skip = false

			if State.aimTeamCheck
				and LocalPlayer.Team ~= nil
				and player.Team == LocalPlayer.Team then
				skip = true
			end

			if not skip
				and State.aimIgnoreFriends
				and Extra.IsFriend
				and Extra.IsFriend(player) then
				skip = true
			end

			local character =
				not skip
				and player.Character
				or nil

			local humanoid =
				character
				and character:FindFirstChildOfClass(
					"Humanoid"
				)

			local part =
				character
				and (
					character:FindFirstChild("Head")
					or character:FindFirstChild(
						"HumanoidRootPart"
					)
				)

			if humanoid
				and humanoid.Health > 0
				and part then

				local point, visible =
					Camera:WorldToViewportPoint(
						part.Position
					)

				if visible and point.Z > 0 then
					local screenDistance =
						(
							Vector2.new(
								point.X,
								point.Y
							)
							- center
						).Magnitude

					if screenDistance <= bestDistance then
						local clear = true

						if State.aimWallCheck then
							local params =
								RaycastParams.new()

							params.FilterType =
								Enum.RaycastFilterType.Exclude

							params.FilterDescendantsInstances = {
								LocalPlayer.Character
							}

							params.IgnoreWater = true

							local direction =
								part.Position
								- Camera.CFrame.Position

							local hit =
								Workspace:Raycast(
									Camera.CFrame.Position,
									direction,
									params
								)

							clear =
								hit == nil
								or (
									hit.Instance
									and hit.Instance:
										IsDescendantOf(
											character
										)
								)
						end

						if clear then
							bestPart =
								part

							bestDistance =
								screenDistance
						end
					end
				end
			end
		end
	end

	return bestPart
end

Extra.GetOrderedObjectives = function()
	local root =
		LocalPlayer.Character
		and LocalPlayer.Character:
			FindFirstChild(
				"HumanoidRootPart"
			)

	local list = {}
	local seen = {}

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do
		if (
			object:IsA("Model")
			or object:IsA("BasePart")
		)
			and Extra.IsObjective(object) then

			local candidate =
				object:IsA("Model")
					and object
				or object:FindFirstAncestorOfClass(
					"Model"
				)
				or object

			if not seen[candidate]
				and not Extra.AutoWalkVisited[
					candidate
				] then

				local anchorPart =
					Extra.GetAnchor(
						candidate
					)

				if anchorPart then
					seen[candidate] = true

					local order = tonumber(
						candidate:GetAttribute(
							"ObjectiveOrder"
						)
						or candidate:GetAttribute(
							"Order"
						)
						or candidate:GetAttribute(
							"Sequence"
						)
					)

					if not order then
						order = tonumber(
							string.match(
								candidate.Name,
								"^%s*(%d+)"
							)
						)
					end

					local distance =
						root
							and (
								root.Position
								- anchorPart.Position
							).Magnitude
							or math.huge

					table.insert(
						list,
						{
							object = candidate,
							anchor = anchorPart,
							order = order,
							distance = distance
						}
					)
				end
			end
		end
	end

	table.sort(
		list,
		function(a, b)
			if a.order
				and b.order
				and a.order ~= b.order then
				return a.order < b.order
			end

			if a.order
				and not b.order then
				return true
			end

			if b.order
				and not a.order then
				return false
			end

			return a.distance < b.distance
		end
	)

	return list
end

Extra.StopAutoWalk = function()
	Extra.AutoWalkToken += 1

	local humanoid =
		LocalPlayer.Character
		and LocalPlayer.Character:
			FindFirstChildOfClass(
				"Humanoid"
			)

	if humanoid then
		humanoid:Move(
			Vector3.zero
		)
	end
end

Extra.StartAutoWalk = function()
	Extra.StopAutoWalk()

	Extra.AutoWalkVisited = {}

	Extra.AutoWalkToken += 1

	local token =
		Extra.AutoWalkToken

	task.spawn(function()
		while State.autoWalk
			and token == Extra.AutoWalkToken do

			local character =
				LocalPlayer.Character

			local humanoid =
				character
				and character:
					FindFirstChildOfClass(
						"Humanoid"
					)

			local root =
				character
				and character:
					FindFirstChild(
						"HumanoidRootPart"
					)

			if not humanoid or not root then
				task.wait(0.5)
				continue
			end

			local objectives =
				Extra.GetOrderedObjectives()

			local target =
				objectives[1]

			if not target then
				task.wait(0.8)
				continue
			end

			local path =
				PathfindingService:CreatePath({
					AgentCanJump = true,
					WaypointSpacing = 4
				})

			local ok =
				pcall(function()
					path:ComputeAsync(
						root.Position,
						target.anchor.Position
					)
				end)

			local waypoints =
				ok
				and path.Status
					== Enum.PathStatus.Success
				and path:GetWaypoints()
				or nil

			if waypoints
				and #waypoints > 0 then

				for _, waypoint in ipairs(
					waypoints
				) do
					if not State.autoWalk
						or token
							~= Extra.AutoWalkToken then
						return
					end

					if waypoint.Action
						== Enum.PathWaypointAction.Jump then
						humanoid.Jump = true
					end

					humanoid:MoveTo(
						waypoint.Position
					)

					local reached =
						humanoid.MoveToFinished:
							Wait()

					if not reached then
						break
					end
				end
			else
				humanoid:MoveTo(
					target.anchor.Position
				)

				humanoid.MoveToFinished:
					Wait()
			end

			Extra.AutoWalkVisited[
				target.object
			] = true

			task.wait(0.15)
		end
	end)
end

Extra.VirtualInput = nil

pcall(function()
	Extra.VirtualInput =
		game:GetService(
			"VirtualInputManager"
		)
end)

Extra.SendMacroEvent = function(event)
	local vim =
		Extra.VirtualInput

	if not vim or not event then
		return false
	end

	if event.kind == "key" then
		local key =
			Enum.KeyCode[
				event.value
			]

		if key then
			return pcall(function()
				vim:SendKeyEvent(
					event.down,
					key,
					false,
					game
				)
			end)
		end
	elseif event.kind == "mouse" then
		local button =
			event.value
				== "MouseButton2"
				and 1
				or 0

		local pos =
			UserInputService:
				GetMouseLocation()

		return pcall(function()
			vim:SendMouseButtonEvent(
				pos.X,
				pos.Y,
				button,
				event.down,
				game,
				0
			)
		end)
	end

	return false
end

Extra.RecordMacroInput = function(
	input,
	down
)
	if not Extra.Macro.recording
		or State.menuVisible then
		return
	end

	if BindingMatches(
		Bindings.menu,
		input
	) then
		return
	end

	if input.UserInputType
		== Enum.UserInputType.Keyboard
		and input.KeyCode
			~= Enum.KeyCode.Unknown then

		table.insert(
			Extra.Macro.events,
			{
				t =
					os.clock()
					- Extra.Macro.started,

				kind =
					"key",

				value =
					input.KeyCode.Name,

				down =
					down
			}
		)

	elseif input.UserInputType
		== Enum.UserInputType.MouseButton1
		or input.UserInputType
			== Enum.UserInputType.MouseButton2 then

		table.insert(
			Extra.Macro.events,
			{
				t =
					os.clock()
					- Extra.Macro.started,

				kind =
					"mouse",

				value =
					input.UserInputType.Name,

				down =
					down
			}
		)
	end

	if Extra.RefreshMacroStatus then
		Extra.RefreshMacroStatus()
	end
end

Extra.StartMacroRecording = function()
	Extra.Macro.events = {}

	Extra.Macro.recording = true
	Extra.Macro.playing = false

	Extra.Macro.started =
		os.clock()

	if Extra.RefreshMacroStatus then
		Extra.RefreshMacroStatus()
	end
end

Extra.StopMacro = function()
	Extra.Macro.recording = false
	Extra.Macro.playing = false

	if Extra.RefreshMacroStatus then
		Extra.RefreshMacroStatus()
	end
end

Extra.PlayMacro = function()
	if Extra.Macro.recording
		or Extra.Macro.playing
		or #Extra.Macro.events == 0 then
		return
	end

	Extra.Macro.playing = true

	if Extra.RefreshMacroStatus then
		Extra.RefreshMacroStatus()
	end

	task.spawn(function()
		local started =
			os.clock()

		for _, event in ipairs(
			Extra.Macro.events
		) do
			if not Extra.Macro.playing then
				break
			end

			local waitFor =
				event.t
				- (
					os.clock()
					- started
				)

			if waitFor > 0 then
				task.wait(waitFor)
			end

			if not Extra.Macro.playing then
				break
			end

			Extra.SendMacroEvent(
				event
			)
		end

		Extra.Macro.playing = false

		if Extra.RefreshMacroStatus then
			Extra.RefreshMacroStatus()
		end
	end)
end

Extra.StartAutoClicker = function()
	Extra.AutoClickToken += 1

	local token =
		Extra.AutoClickToken

	task.spawn(function()
		while token
			== Extra.AutoClickToken
			and Extra.AutoClickHeld
			and State.autoClickerEnabled do

			if not State.menuVisible
				and Extra.VirtualInput then

				local pos =
					UserInputService:
						GetMouseLocation()

				pcall(function()
					Extra.VirtualInput:
						SendMouseButtonEvent(
							pos.X,
							pos.Y,
							0,
							true,
							game,
							0
						)

					Extra.VirtualInput:
						SendMouseButtonEvent(
							pos.X,
							pos.Y,
							0,
							false,
							game,
							0
						)
				end)
			end

			task.wait(
				1
				/ math.max(
					1,
					State.autoClickCps
						or 10
				)
			)
		end
	end)
end

local function ApplyLowToObject(
	object
)
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

		object.Material =
			Enum.Material.SmoothPlastic
	end
end

local function EnableLowGraphics()
	if LowSaved.lighting.GlobalShadows ~= nil then
		return
	end

	LowSaved.lighting.GlobalShadows =
		Lighting.GlobalShadows

	LowSaved.lighting.EnvironmentDiffuseScale =
		Lighting.EnvironmentDiffuseScale

	LowSaved.lighting.EnvironmentSpecularScale =
		Lighting.EnvironmentSpecularScale

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do
		ApplyLowToObject(object)
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

	for object, saved in pairs(
		LowSaved.objects
	) do
		if object and object.Parent then
			pcall(function()
				object[saved.property] =
					saved.value
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
			FullBrightSaved[property] =
				Lighting[property]
		end
	end

	Lighting.Ambient =
		Color3.fromRGB(
			255,
			255,
			255
		)

	Lighting.OutdoorAmbient =
		Color3.fromRGB(
			255,
			255,
			255
		)

	Lighting.Brightness =
		math.max(
			Lighting.Brightness,
			2.6
		)

	Lighting.ExposureCompensation =
		0.15

	Lighting.FogEnd =
		100000
end

local function DisableFullBright()
	for property, value in pairs(
		FullBrightSaved
	) do
		pcall(function()
			Lighting[property] =
				value
		end)
	end

	table.clear(
		FullBrightSaved
	)
end

local function EnableInstantInteract()
	for _, object in ipairs(
		Workspace:GetDescendants()
	) do
		if object:IsA("ProximityPrompt") then
			if InstantSaved[object] == nil then
				InstantSaved[object] =
					object.HoldDuration
			end

			object.HoldDuration = 0
		end
	end
end

local function DisableInstantInteract()
	for prompt, duration in pairs(
		InstantSaved
	) do
		if prompt and prompt.Parent then
			prompt.HoldDuration =
				duration
		end
	end

	table.clear(
		InstantSaved
	)
end

local function ApplyPanelBackground()
	State.panelBlur = 90

	local brightness =
		math.clamp(
			State.backgroundBrightness / 100,
			0,
			1
		)

	local blur = 0.90

	local level =
		0.22
		+ (
			brightness * 0.58
		)

	local color =
		Color3.new(
			level,
			level,
			math.min(
				1,
				level + 0.02
			)
		)

	Background.ImageColor3 =
		color

	Background.ImageTransparency =
		math.clamp(
			0.78
				- (
					brightness * 0.34
				)
				+ (
					blur * 0.10
				),
			0.38,
			0.86
		)

	for _, data in ipairs(
		BlurLayers
	) do
		local layer =
			data.image

		layer.ImageColor3 =
			color

		layer.ImageTransparency =
			1
			- (
				0.11 * blur
			)

		layer.Position =
			UDim2.fromOffset(
				data.offset.X
					* (
						0.5
						+ 1.4 * blur
					),

				data.offset.Y
					* (
						0.5
						+ 1.4 * blur
					)
			)
	end

	BackgroundShade.BackgroundTransparency =
		ResolveUITransparency(
			0.08
				+ (
					0.30
					* brightness
				)
		)
end

local function GetPlaceId(kind)
	local names =
		kind == "Game"
			and {
				"GamePlaceId",
				"GameplayPlaceId",
				"MapPlaceId"
			}
			or {
				"LobbyPlaceId",
				"HubPlaceId"
			}

	for _, source in ipairs({
		game,
		Workspace,
		ReplicatedStorage
	}) do
		for _, name in ipairs(names) do
			local value =
				source:GetAttribute(
					name
				)

			if typeof(value)
				== "number"
				and value > 0 then
				return math.floor(
					value
				)
			end

			if typeof(value)
				== "string" then

				local parsed =
					tonumber(value)

				if parsed
					and parsed > 0 then
					return math.floor(
						parsed
					)
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

	if object:IsA("BasePart")
		or object:IsA("SpawnLocation") then
		return object.CFrame
	end

	if object:IsA("Attachment") then
		return object.WorldCFrame
	end

	return nil
end

local function FindSpawnInside(
	container,
	kind
)
	if not container then
		return nil
	end

	local names =
		kind == "Game"
			and {
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
			or {
				"LobbySpawn",
				"HubSpawn",
				"WaitingSpawn",
				"SpawnLocation",
				"Spawn",
				"StartPoint",
				"Start",
				"Entrance"
			}

	for _, name in ipairs(names) do
		local object =
			container:FindFirstChild(
				name,
				true
			)

		local cf =
			SpawnCFrame(
				object
			)

		if cf then
			return cf
		end
	end

	local spawn =
		container:
			FindFirstChildWhichIsA(
				"SpawnLocation",
				true
			)

	return
		spawn
		and spawn.CFrame
		or nil
end

local function ContainsAny(
	textValue,
	words
)
	local lower =
		string.lower(
			textValue or ""
		)

	for _, word in ipairs(words) do
		if string.find(
			lower,
			word,
			1,
			true
		) then
			return true
		end
	end

	return false
end

local function DestinationScore(
	object,
	kind
)
	local gameWords = {
		"game",
		"gameplay",
		"map",
		"arena",
		"match",
		"round",
		"start"
	}

	local lobbyWords = {
		"lobby",
		"hub",
		"waiting",
		"spawn"
	}

	local wanted =
		kind == "Game"
			and gameWords
			or lobbyWords

	local unwanted =
		kind == "Game"
			and {
				"lobby",
				"hub",
				"waiting"
			}
			or {
				"game",
				"gameplay",
				"map",
				"arena",
				"match",
				"round"
			}

	local score = 0

	if object:IsA("SpawnLocation") then
		score += 4
	end

	if ContainsAny(
		object.Name,
		wanted
	) then
		score += 8
	end

	if ContainsAny(
		object.Name,
		unwanted
	) then
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
		local value =
			object:GetAttribute(
				attributeName
			)

		if value then
			local asText =
				tostring(value)

			if string.lower(asText)
				== string.lower(kind) then
				score += 20

			elseif ContainsAny(
				asText,
				wanted
			) then
				score += 12

			elseif ContainsAny(
				asText,
				unwanted
			) then
				score -= 12
			end
		end
	end

	for _, tag in ipairs(
		CollectionService:GetTags(
			object
		)
	) do
		if ContainsAny(
			tag,
			wanted
		) then
			score += 12

		elseif ContainsAny(
			tag,
			unwanted
		) then
			score -= 12
		end
	end

	local parent =
		object.Parent

	local depth =
		0

	while parent
		and parent ~= Workspace
		and depth < 6 do

		if ContainsAny(
			parent.Name,
			wanted
		) then
			score += 5
		end

		if ContainsAny(
			parent.Name,
			unwanted
		) then
			score -= 6
		end

		parent =
			parent.Parent

		depth += 1
	end

	return score
end

local function FindDestinationSpawn(kind)
	local bestObject = nil
	local bestScore = -math.huge

	for _, object in ipairs(
		Workspace:GetDescendants()
	) do
		if object:IsA("SpawnLocation")
			or object:IsA("BasePart")
			or object:IsA("Attachment") then

			local score =
				DestinationScore(
					object,
					kind
				)

			if score > bestScore then
				bestScore =
					score

				bestObject =
					object
			end
		end
	end

	if bestObject
		and bestScore > 0 then
		return SpawnCFrame(
			bestObject
		)
	end

	local containers =
		kind == "Game"
			and {
				"Game",
				"Gameplay",
				"Map",
				"Arena",
				"Match",
				"Round"
			}
			or {
				"Lobby",
				"Hub",
				"WaitingRoom",
				"Waiting"
			}

	for _, containerName in ipairs(
		containers
	) do
		local container =
			Workspace:FindFirstChild(
				containerName,
				true
			)

		if container then
			local cf =
				FindSpawnInside(
					container,
					kind
				)

			if cf then
				return cf
			end
		end
	end

	local firstSpawn =
		Workspace:
			FindFirstChildWhichIsA(
				"SpawnLocation",
				true
			)

	return
		firstSpawn
		and firstSpawn.CFrame
		or nil
end

local function TeleportCharacterTo(cf)
	local character =
		LocalPlayer.Character

	if not character or not cf then
		return false
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return false
	end

	local target =
		cf + Vector3.new(
			0,
			4,
			0
		)

	for _ = 1, 3 do
		character:PivotTo(
			target
		)

		root.AssemblyLinearVelocity =
			Vector3.zero

		root.AssemblyAngularVelocity =
			Vector3.zero

		task.wait()
	end

	return true
end

local function TeleportTo(
	kind,
	card
)
	local placeId =
		GetPlaceId(kind)

	if placeId
		and placeId ~= game.PlaceId then

		card.title.Text =
			T("teleporting")

		local ok =
			pcall(function()
				TeleportService:
					Teleport(
						placeId,
						LocalPlayer
					)
			end)

		if not ok then
			card.title.Text =
				T("teleport_failed")

			task.delay(
				1.2,
				function()
					if card.title
						and card.title.Parent then

						card.title.Text =
							T(
								kind == "Game"
									and "game_tp"
									or "lobby_tp"
							)
					end
				end
			)
		end

		return
	end

	local destination =
		FindDestinationSpawn(
			kind
		)

	if TeleportCharacterTo(
		destination
	) then
		return
	end

	card.title.Text =
		T("spawn_not_found")

	task.delay(
		1.2,
		function()
			if card.title
				and card.title.Parent then

				card.title.Text =
					T(
						kind == "Game"
							and "game_tp"
							or "lobby_tp"
					)
			end
		end
	)
end

Section(
	InfoPage,
	"info_subtitle",
	nil,
	1
)

local InfoCard = New("Frame", {
	Size = UDim2.new(
		1,
		0,
		0,
		94
	),

	BackgroundColor3 =
		Theme.Surface,

	BackgroundTransparency =
		0.08,

	BorderSizePixel =
		0,

	LayoutOrder =
		2,

	ZIndex =
		46
}, InfoPage)

Corner(
	InfoCard,
	9
)

RegisterUITransparency(
	InfoCard,
	0.08
)

New("TextLabel", {
	Size = UDim2.new(
		1,
		-28,
		0,
		28
	),

	Position = UDim2.fromOffset(
		14,
		14
	),

	BackgroundTransparency = 1,

	Text = "K hub",

	TextColor3 = Theme.White,

	TextSize = 18,

	Font = Enum.Font.GothamBlack,

	TextXAlignment =
		Enum.TextXAlignment.Left,

	ZIndex = 47
}, InfoCard)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				46
			),

		BackgroundTransparency = 1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			11,

		Font =
			Enum.Font.GothamMedium,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, InfoCard),

	"info_version"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			16
		),

		Position =
			UDim2.fromOffset(
				14,
				67
			),

		BackgroundTransparency = 1,

		TextColor3 =
			Theme.Muted2,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, InfoCard),

	"info_runtime"
)

NoteCard(
	InfoPage,
	"note_development_title",
	"note_development_body",
	3,
	false
)

NoteCard(
	InfoPage,
	"note_performance_title",
	"note_performance_body",
	4,
	true
)

NoteCard(
	InfoPage,
	"note_menu_title",
	"note_menu_body",
	5,
	false
)

Section(
	MainPage,
	"main_title",
	"main_subtitle",
	1
)

local RejoinCard

RejoinCard =
	ActionButton(
		MainPage,
		"rejoin",
		"rejoin_sub",
		2,
		function()
			RejoinCard.title.Text =
				T("rejoining")

			local ok =
				pcall(function()
					TeleportService:
						TeleportToPlaceInstance(
							game.PlaceId,
							game.JobId,
							LocalPlayer
						)
				end)

			if not ok then
				RejoinCard.title.Text =
					T("rejoin_failed")

				task.delay(
					1.2,
					function()
						if RejoinCard.title
							and RejoinCard.title.Parent then

							RejoinCard.title.Text =
								T("rejoin")
						end
					end
				)
			end
		end
	)

local GameCard

GameCard =
	ActionButton(
		MainPage,
		"game_tp",
		"game_tp_sub",
		3,
		function()
			TeleportTo(
				"Game",
				GameCard
			)
		end
	)

local LobbyCard

LobbyCard =
	ActionButton(
		MainPage,
		"lobby_tp",
		"lobby_tp_sub",
		4,
		function()
			TeleportTo(
				"Lobby",
				LobbyCard
			)
		end
	)

ActionButton(
	MainPage,
	"respawn",
	"respawn_sub",
	5,
	function()
		local character =
			LocalPlayer.Character

		local humanoid =
			character
			and character:
				FindFirstChildOfClass(
					"Humanoid"
				)

		if humanoid then
			humanoid.Health = 0
		end
	end
)

Section(
	PlayerPage,
	"player_title",
	"player_subtitle",
	1
)

CreateToggle(
	PlayerPage,
	{
		id = "antiFling",
		titleKey = "anti_fling",
		subtitleKey = "anti_fling_sub",
		order = 2,
		warning = true
	}
)

CreateToggle(
	PlayerPage,
	{
		id = "noclip",
		titleKey = "noclip",
		subtitleKey = "noclip_sub",
		order = 3,

		changed = function(enabled)
			if not enabled
				and not State.speedManipulation then
				RestoreLocalCollision()
			end
		end
	}
)

local WalkRow =
	CreateToggle(
		PlayerPage,
		{
			id = "walkSpeed",

			titleKey =
				"walk_speed",

			subtitleKey =
				"walk_speed_sub",

			order =
				4,

			height =
				102,

			changed =
				function(enabled)
					local character =
						LocalPlayer.Character

					local humanoid =
						character
						and character:
							FindFirstChildOfClass(
								"Humanoid"
							)

					if humanoid then
						if enabled then
							if SavedWalkSpeed == nil then
								SavedWalkSpeed =
									humanoid.WalkSpeed
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

							SavedWalkSpeed =
								nil
						end
					end
				end
		}
	)

CreateSlider(
	WalkRow,
	77,
	1,
	25,
	State.walkSpeedValue,

	function(value)
		State.walkSpeedValue =
			value

		if State.walkSpeed
			and not State.speedManipulation then

			local character =
				LocalPlayer.Character

			local humanoid =
				character
				and character:
					FindFirstChildOfClass(
						"Humanoid"
					)

			if humanoid then
				humanoid.WalkSpeed =
					value
			end
		end
	end,

	false
)

local FlyRow =
	CreateToggle(
		PlayerPage,
		{
			id =
				"fly",

			titleKey =
				"fly",

			subtitleKey =
				"fly_sub",

			order =
				5,

			height =
				102,

			changed =
				function(enabled)
					if enabled then
						CreateFly()

						if ShowFlyNotice then
							ShowFlyNotice()
						end
					else
						DestroyFly()
					end
				end
		}
	)

CreateSlider(
	FlyRow,
	77,
	5,
	100,
	State.flySpeed,

	function(value)
		State.flySpeed =
			value
	end,

	false
)

Extra.FovRow =
	CreateToggle(
		PlayerPage,
		{
			id =
				"fov",

			titleKey =
				"fov",

			subtitleKey =
				"fov_sub",

			order =
				6,

			height =
				102,

			changed =
				function(enabled)
					if enabled then
						if Extra.OriginalFov == nil then
							Extra.OriginalFov =
								Camera.FieldOfView
						end

						Camera.FieldOfView =
							State.fovValue
					elseif Extra.OriginalFov then
						Camera.FieldOfView =
							Extra.OriginalFov
					end
				end
		}
	)

CreateSlider(
	Extra.FovRow,
	77,
	50,
	120,
	State.fovValue,

	function(value)
		State.fovValue =
			value

		if State.fov then
			Camera.FieldOfView =
				value
		end
	end,

	false
)

Extra.FreecamRow =
	CreateToggle(
		PlayerPage,
		{
			id =
				"freecam",

			titleKey =
				"freecam",

			subtitleKey =
				"freecam_sub",

			order =
				7,

			height =
				102,

			changed =
				function(enabled)
					if enabled then
						if State.spectate
							and ToggleSetters.spectate then
							ToggleSetters.spectate(false)
						end

						if State.autoWalk
							and ToggleSetters.autoWalk then
							ToggleSetters.autoWalk(false)
						end

						Extra.StartFreecam()
					else
						Extra.StopFreecam()
					end
				end
		}
	)

CreateSlider(
	Extra.FreecamRow,
	77,
	8,
	120,
	State.freecamSpeed,

	function(value)
		State.freecamSpeed =
			value
	end,

	false
)

Extra.SpectateRow =
	CreateToggle(
		PlayerPage,
		{
			id =
				"spectate",

			titleKey =
				"spectate",

			subtitleKey =
				"spectate_sub",

			order =
				8,

			height =
				72,

			rightReserve =
				330,

			changed =
				function(enabled)
					if enabled then
						if State.freecam
							and ToggleSetters.freecam then
							ToggleSetters.freecam(false)
						end

						Extra.UpdateSpectate()
					else
						Extra.StopSpectate()
					end
				end
		}
	)

Extra.SpectateUI = {}

Extra.SpectateUI.Left =
	New("TextButton", {
		Size = UDim2.fromOffset(
			30,
			28
		),

		Position = UDim2.new(
			1,
			-312,
			0.5,
			-14
		),

		BackgroundColor3 =
			Theme.Surface2,

		BorderSizePixel =
			0,

		Text =
			"‹",

		TextColor3 =
			Theme.Light,

		TextSize =
			18,

		Font =
			Enum.Font.GothamBold,

		ZIndex =
			55
	}, Extra.SpectateRow)

Extra.SpectateUI.Name =
	New("TextLabel", {
		Size = UDim2.fromOffset(
			154,
			28
		),

		Position = UDim2.new(
			1,
			-278,
			0.5,
			-14
		),

		BackgroundColor3 =
			Theme.Surface2,

		BorderSizePixel =
			0,

		Text =
			"—",

		TextColor3 =
			Theme.Light,

		TextSize =
			11,

		Font =
			Enum.Font.GothamSemibold,

		TextTruncate =
			Enum.TextTruncate.AtEnd,

		ZIndex =
			55
	}, Extra.SpectateRow)

Extra.SpectateUI.Right =
	New("TextButton", {
		Size = UDim2.fromOffset(
			30,
			28
		),

		Position = UDim2.new(
			1,
			-120,
			0.5,
			-14
		),

		BackgroundColor3 =
			Theme.Surface2,

		BorderSizePixel =
			0,

		Text =
			"›",

		TextColor3 =
			Theme.Light,

		TextSize =
			18,

		Font =
			Enum.Font.GothamBold,

		ZIndex =
			55
	}, Extra.SpectateRow)

for _, object in pairs(
	Extra.SpectateUI
) do
	if object:IsA("GuiObject") then
		Corner(
			object,
			6
		)

		RegisterUITransparency(
			object,
			0
		)
	end
end

Bind(
	Extra.SpectateUI.Left.MouseButton1Click,
	function()
		local count =
			math.max(
				1,
				#Players:GetPlayers() - 1
			)

		Extra.SpectateIndex =
			(
				(
					(Extra.SpectateIndex or 1)
					- 2
				)
				% count
			)
			+ 1

		Extra.UpdateSpectate()
	end
)

Bind(
	Extra.SpectateUI.Right.MouseButton1Click,
	function()
		local count =
			math.max(
				1,
				#Players:GetPlayers() - 1
			)

		Extra.SpectateIndex =
			(
				(Extra.SpectateIndex or 1)
				% count
			)
			+ 1

		Extra.UpdateSpectate()
	end
)

Extra.UpdateSpectate()

CreateToggle(
	PlayerPage,
	{
		id =
			"autoWalk",

		titleKey =
			"auto_walk",

		subtitleKey =
			"auto_walk_sub",

		order =
			9,

		changed =
			function(enabled)
				if enabled then
					if State.freecam
						and ToggleSetters.freecam then
						ToggleSetters.freecam(false)
					end

					Extra.StartAutoWalk()
				else
					Extra.StopAutoWalk()
				end
			end
	}
)

CreateHotkeyRow(
	PlayerPage,
	"speedManipulation",
	"speed_manip",
	"speed_manip_sub",
	10
)

Section(
	EspPage,
	"esp_title",
	"esp_subtitle",
	1
)

CreateToggle(
	EspPage,
	{
		id = "playerEsp",
		titleKey = "player_esp",
		subtitleKey = "player_esp_sub",
		order = 2,

		changed = function(enabled)
			if not enabled then
				ClearPlayerEsp()
			end
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "friendEsp",
		titleKey = "friend_esp",
		subtitleKey = "friend_esp_sub",
		order = 3,

		changed = function()
			Extra.ClearFriendEsp()
			Extra.RefreshFriendEsp()
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "entityEsp",
		titleKey = "entity_esp",
		subtitleKey = "entity_esp_sub",
		order = 4,
		warning = true,

		changed = function(enabled)
			if enabled then
				task.spawn(
					RefreshEntityEsp
				)
			else
				ClearEntityEsp()
			end
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "itemEsp",
		titleKey = "item_esp",
		subtitleKey = "item_esp_sub",
		order = 5,

		changed = function(enabled)
			if enabled then
				task.spawn(function()
					Extra.RefreshGenericEsp(
						"item"
					)
				end)
			else
				Extra.ClearGenericEsp(
					"item"
				)
			end
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "objectiveEsp",
		titleKey = "objective_esp",
		subtitleKey = "objective_esp_sub",
		order = 6,

		changed = function(enabled)
			if enabled then
				task.spawn(function()
					Extra.RefreshGenericEsp(
						"objective"
					)
				end)
			else
				Extra.ClearGenericEsp(
					"objective"
				)
			end
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "entityOnlyHostile",
		titleKey = "entity_hostile_only",
		subtitleKey = "entity_hostile_only_sub",
		order = 7,

		changed = function()
			if State.entityEsp then
				task.spawn(
					RefreshEntityEsp
				)
			end
		end
	}
)

CreateToggle(
	EspPage,
	{
		id = "entitySpawnWarning",
		titleKey = "entity_spawn_warning",
		subtitleKey = "entity_spawn_warning_sub",
		order = 8
	}
)

Section(
	EspPage,
	"esp_filters",
	"esp_filters_sub",
	9
)

CreateToggle(
	EspPage,
	{
		id = "espShowNames",
		titleKey = "esp_names",
		subtitleKey = "esp_names_sub",
		order = 10
	}
)

CreateToggle(
	EspPage,
	{
		id = "espShowDistance",
		titleKey = "esp_distance",
		subtitleKey = "esp_distance_sub",
		order = 11
	}
)

CreateToggle(
	EspPage,
	{
		id = "espHighlight",
		titleKey = "esp_highlight",
		subtitleKey = "esp_highlight_sub",
		order = 12
	}
)

Section(
	Extra.FpsPage,
	"fps_title",
	"fps_subtitle",
	1
)

CreateToggle(
	Extra.FpsPage,
	{
		id = "aimbot",
		titleKey = "aimbot",
		subtitleKey = "aimbot_sub",
		order = 2,

		changed = function(enabled)
			if not enabled then
				Extra.AimHeld = false
			end
		end
	}
)

CreateHotkeyRow(
	Extra.FpsPage,
	"aimHold",
	"aim_key",
	"aim_key_sub",
	3
)

CreateToggle(
	Extra.FpsPage,
	{
		id = "aimWallCheck",
		titleKey = "aim_wall_check",
		subtitleKey = "aim_wall_check_sub",
		order = 4
	}
)

CreateToggle(
	Extra.FpsPage,
	{
		id = "aimIgnoreFriends",
		titleKey = "aim_ignore_friends",
		subtitleKey = "aim_ignore_friends_sub",
		order = 5
	}
)

CreateToggle(
	Extra.FpsPage,
	{
		id = "aimTeamCheck",
		titleKey = "aim_team_check",
		subtitleKey = "aim_team_check_sub",
		order = 6
	}
)

Extra.AimFovRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			7,

		ZIndex =
			46
	}, Extra.FpsPage)

Corner(
	Extra.AimFovRow,
	7
)

Stroke(
	Extra.AimFovRow,
	0.86,
	1,
	Theme.Stroke
)

RegisterUITransparency(
	Extra.AimFovRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, Extra.AimFovRow),

	"aim_fov"
)

CreateSlider(
	Extra.AimFovRow,
	58,
	40,
	500,
	State.aimFov,

	function(value)
		State.aimFov =
			value
	end,

	false
)

Extra.AimSmoothRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			8,

		ZIndex =
			46
	}, Extra.FpsPage)

Corner(
	Extra.AimSmoothRow,
	7
)

Stroke(
	Extra.AimSmoothRow,
	0.86,
	1,
	Theme.Stroke
)

RegisterUITransparency(
	Extra.AimSmoothRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, Extra.AimSmoothRow),

	"aim_smooth"
)

CreateSlider(
	Extra.AimSmoothRow,
	58,
	1,
	30,
	State.aimSmooth,

	function(value)
		State.aimSmooth =
			value
	end,

	false
)

Section(
	GraphicsPage,
	"graphics_title",
	"graphics_subtitle",
	1
)

CreateToggle(
	GraphicsPage,
	{
		id = "performanceMode",

		titleKey =
			"performance_mode",

		subtitleKey =
			"performance_mode_sub",

		order =
			2,

		changed =
			function(enabled)
				if enabled then
					EnableLowGraphics()
				else
					DisableLowGraphics()

					Extra.SetParticlesHidden(
						State.hideParticles
					)
				end
			end
	}
)

CreateToggle(
	GraphicsPage,
	{
		id = "hideParticles",

		titleKey =
			"hide_particles",

		subtitleKey =
			"hide_particles_sub",

		order =
			3,

		changed =
			function(enabled)
				if not State.performanceMode then
					Extra.SetParticlesHidden(
						enabled
					)
				end
			end
	}
)

CreateToggle(
	GraphicsPage,
	{
		id = "noFog",

		titleKey =
			"no_fog",

		subtitleKey =
			"no_fog_sub",

		order =
			4,

		changed =
			function(enabled)
				if enabled then
					Extra.EnableNoFog()
				else
					Extra.DisableNoFog()
				end
			end
	}
)

Extra.BrightnessRow =
	CreateToggle(
		GraphicsPage,
		{
			id =
				"brightness",

			titleKey =
				"brightness",

			subtitleKey =
				"brightness_sub",

			order =
				5,

			height =
				102,

			changed =
				function(enabled)
					if enabled then
						if Extra.VisualSaved.brightness == nil then
							Extra.VisualSaved.brightness =
								Lighting.Brightness
						end

						Lighting.Brightness =
							State.brightnessValue

					elseif Extra.VisualSaved.brightness ~= nil then
						Lighting.Brightness =
							Extra.VisualSaved.brightness

						Extra.VisualSaved.brightness =
							nil
					end
				end
		}
	)

CreateSlider(
	Extra.BrightnessRow,
	77,
	0,
	5,
	State.brightnessValue,

	function(value)
		State.brightnessValue =
			value

		if State.brightness then
			Lighting.Brightness =
				value
		end
	end,

	false
)

CreateToggle(
	GraphicsPage,
	{
		id = "fullBright",

		titleKey =
			"full_bright",

		subtitleKey =
			"full_bright_sub",

		order =
			6,

		changed =
			function(enabled)
				if enabled then
					EnableFullBright()
				else
					DisableFullBright()
				end
			end
	}
)

CreateToggle(
	GraphicsPage,
	{
		id =
			"fpsVisible",

		titleKey =
			"fps_display",

		subtitleKey =
			"fps_display_sub",

		order =
			7,

		changed =
			function(enabled)
				if SetFpsVisible then
					SetFpsVisible(
						enabled
					)
				end
			end
	}
)

CreateToggle(
	GraphicsPage,
	{
		id =
			"clockVisible",

		titleKey =
			"clock_display",

		subtitleKey =
			"clock_display_sub",

		order =
			8,

		changed =
			function(enabled)
				if SetClockVisible then
					SetClockVisible(
						enabled
					)
				end
			end
	}
)

CreateToggle(
	GraphicsPage,
	{
		id =
			"dateVisible",

		titleKey =
			"date_display",

		subtitleKey =
			"date_display_sub",

		order =
			9,

		changed =
			function(enabled)
				if Extra.SetDateVisible then
					Extra.SetDateVisible(
						enabled
					)
				end
			end
	}
)

Section(
	Extra.MacroPage,
	"macros_title",
	"macros_subtitle",
	1
)

Extra.MacroRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			112
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			2,

		ZIndex =
			46
	}, Extra.MacroPage)

Corner(
	Extra.MacroRow,
	7
)

Stroke(
	Extra.MacroRow,
	0.86,
	1,
	Theme.Stroke
)

RegisterUITransparency(
	Extra.MacroRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, Extra.MacroRow),

	"macro_recorder"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			16
		),

		Position =
			UDim2.fromOffset(
				14,
				31
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, Extra.MacroRow),

	"macro_recorder_sub"
)

Extra.MacroStatus =
	New("TextLabel", {
		Size =
			UDim2.fromOffset(
				170,
				22
			),

		Position =
			UDim2.new(
				1,
				-184,
				0,
				8
			),

		BackgroundTransparency =
			1,

		Text =
			"0 events",

		TextColor3 =
			Theme.Muted2,

		TextSize =
			10,

		Font =
			Enum.Font.GothamMedium,

		TextXAlignment =
			Enum.TextXAlignment.Right,

		ZIndex =
			48
	}, Extra.MacroRow)

Extra.MacroButtons = {}

Extra.MacroKeys = {
	{"record", "macro_record"},
	{"stop", "macro_stop"},
	{"play", "macro_play"},
	{"clear", "macro_clear"}
}

for i, entry in ipairs(
	Extra.MacroKeys
) do
	local button =
		RegisterText(
			New("TextButton", {
				Size = UDim2.new(
					0.25,
					-8,
					0,
					34
				),

				Position = UDim2.new(
					(i - 1) * 0.25,
					i == 1
						and 14
						or 8,
					1,
					-48
				),

				BackgroundColor3 =
					Theme.Surface2,

				BorderSizePixel =
					0,

				TextColor3 =
					Theme.Light,

				TextSize =
					10,

				Font =
					Enum.Font.GothamBold,

				AutoButtonColor =
					false,

				ZIndex =
					50
			}, Extra.MacroRow),

			entry[2]
		)

	Corner(
		button,
		7
	)

	Stroke(
		button,
		0.72,
		1,
		Theme.Stroke
	)

	RegisterUITransparency(
		button,
		0
	)

	Extra.MacroButtons[
		entry[1]
	] = button
end

Extra.RefreshMacroStatus = function()
	if not Extra.MacroStatus then
		return
	end

	local duration =
		(
			#Extra.Macro.events > 0
			and Extra.Macro.events[
				#Extra.Macro.events
			].t
		)
		or 0

	local prefix =
		Extra.Macro.recording
			and "REC  ·  "
		or (
			Extra.Macro.playing
				and "PLAY  ·  "
				or ""
		)

	local word =
		Language == "ptbr"
			and "eventos"
			or "events"

	Extra.MacroStatus.Text =
		prefix
		.. tostring(
			#Extra.Macro.events
		)
		.. " "
		.. word
		.. "  ·  "
		.. string.format(
			"%.1fs",
			duration
		)
end

Bind(
	Extra.MacroButtons.record.MouseButton1Click,
	Extra.StartMacroRecording
)

Bind(
	Extra.MacroButtons.stop.MouseButton1Click,
	Extra.StopMacro
)

Bind(
	Extra.MacroButtons.play.MouseButton1Click,
	Extra.PlayMacro
)

Bind(
	Extra.MacroButtons.clear.MouseButton1Click,
	function()
		Extra.StopMacro()

		Extra.Macro.events = {}

		Extra.RefreshMacroStatus()
	end
)

Extra.RefreshMacroStatus()

Extra.AutoClickRow =
	CreateToggle(
		Extra.MacroPage,
		{
			id =
				"autoClickerEnabled",

			titleKey =
				"auto_clicker",

			subtitleKey =
				"auto_clicker_sub",

			order =
				3,

			changed =
				function(enabled)
					if not enabled then
						Extra.AutoClickHeld =
							false

						Extra.AutoClickToken +=
							1
					end
				end
		}
	)

CreateHotkeyRow(
	Extra.MacroPage,
	"autoClickerHold",
	"auto_click_key",
	"auto_click_key_sub",
	4
)

Extra.CpsRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			5,

		ZIndex =
			46
	}, Extra.MacroPage)

Corner(
	Extra.CpsRow,
	7
)

Stroke(
	Extra.CpsRow,
	0.86,
	1,
	Theme.Stroke
)

RegisterUITransparency(
	Extra.CpsRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, Extra.CpsRow),

	"clicks_per_second"
)

CreateSlider(
	Extra.CpsRow,
	58,
	1,
	30,
	State.autoClickCps,

	function(value)
		State.autoClickCps =
			value
	end,

	false
)

Section(
	StatusPage,
	"status_title",
	"status_subtitle",
	1
)

local StatusUI = {}

StatusUI.Summary =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			78
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			2,

		ZIndex =
			46
	}, StatusPage)

Corner(
	StatusUI.Summary,
	9
)

RegisterUITransparency(
	StatusUI.Summary,
	0.08
)

StatusUI.ExecutionsLabel =
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			22
		),

		Position =
			UDim2.fromOffset(
				14,
				13
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			13,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, StatusUI.Summary)

StatusUI.ActiveCountLabel =
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				42
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.PurpleBright,

		TextSize =
			10,

		Font =
			Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, StatusUI.Summary)

StatusUI.ActiveCard =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			110
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			3,

		ZIndex =
			46
	}, StatusPage)

Corner(
	StatusUI.ActiveCard,
	9
)

RegisterUITransparency(
	StatusUI.ActiveCard,
	0.08
)

StatusUI.ActiveList =
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			84
		),

		Position =
			UDim2.fromOffset(
				14,
				13
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Light,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextWrapped =
			true,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		TextYAlignment =
			Enum.TextYAlignment.Top,

		ZIndex =
			47
	}, StatusUI.ActiveCard)

StatusUI.DisabledCard =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			180
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			4,

		ZIndex =
			46
	}, StatusPage)

Corner(
	StatusUI.DisabledCard,
	9
)

RegisterUITransparency(
	StatusUI.DisabledCard,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				12
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, StatusUI.DisabledCard),

	"disabled"
)

StatusUI.DisabledList =
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-28,
			0,
			140
		),

		Position =
			UDim2.fromOffset(
				14,
				34
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted2,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextWrapped =
			true,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		TextYAlignment =
			Enum.TextYAlignment.Top,

		ZIndex =
			47
	}, StatusUI.DisabledCard)

local FeatureNameKeys = {
	{"antiFling", "anti_fling"},
	{"noclip", "noclip"},
	{"walkSpeed", "walk_speed"},
	{"speedManipulation", "speed_manip"},
	{"fly", "fly"},
	{"fov", "fov"},
	{"freecam", "freecam"},
	{"spectate", "spectate"},
	{"autoWalk", "auto_walk"},
	{"aimbot", "aimbot"},
	{"autoClickerEnabled", "auto_clicker"},
	{"playerEsp", "player_esp"},
	{"friendEsp", "friend_esp"},
	{"entityEsp", "entity_esp"},
	{"itemEsp", "item_esp"},
	{"objectiveEsp", "objective_esp"},
	{"entitySpawnWarning", "entity_spawn_warning"},
	{"noFog", "no_fog"},
	{"brightness", "brightness"},
	{"hideParticles", "hide_particles"},
	{"performanceMode", "performance_mode"},
	{"fullBright", "full_bright"},
	{"fpsVisible", "fps_display"},
	{"clockVisible", "clock_display"},
	{"dateVisible", "date_display"},
	{"instantInteract", "instant_interact"}
}

RefreshStatusPage = function()
	local active = {}
	local disabled = {}

	for _, entry in ipairs(
		FeatureNameKeys
	) do
		local name =
			T(entry[2])

		if State[entry[1]] then
			table.insert(
				active,
				name
			)
		else
			table.insert(
				disabled,
				name
			)
		end
	end

	StatusUI.ExecutionsLabel.Text =
		T("executions")
		.. ": "
		.. tostring(
			_G.KHubExecutionCount
			or 1
		)

	StatusUI.ActiveCountLabel.Text =
		T("active")
		.. ": "
		.. tostring(
			#active
		)

	StatusUI.ActiveList.Text =
		#active > 0
			and table.concat(
				active,
				"  ·  "
			)
			or T("none")

	StatusUI.DisabledList.Text =
		#disabled > 0
			and table.concat(
				disabled,
				"  ·  "
			)
			or T("none")
end

Section(
	SettingsPage,
	"settings_title",
	"settings_subtitle",
	1
)

CreateToggle(
	SettingsPage,
	{
		id =
			"instantInteract",

		titleKey =
			"instant_interact",

		subtitleKey =
			"instant_interact_sub",

		order =
			2,

		changed =
			function(enabled)
				if enabled then
					EnableInstantInteract()
				else
					DisableInstantInteract()
				end
			end
	}
)

CreateHotkeyRow(
	SettingsPage,
	"menu",
	"menu_hotkey",
	"menu_hotkey_sub",
	3
)

local SettingsUI = {}

SettingsUI.BrightnessRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			4,

		ZIndex =
			46
	}, SettingsPage)

Corner(
	SettingsUI.BrightnessRow,
	9
)

RegisterUITransparency(
	SettingsUI.BrightnessRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.BrightnessRow),

	"background_brightness"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			15
		),

		Position =
			UDim2.fromOffset(
				14,
				29
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.BrightnessRow),

	"background_brightness_sub"
)

CreateSlider(
	SettingsUI.BrightnessRow,
	63,
	0,
	100,
	State.backgroundBrightness,

	function(value)
		State.backgroundBrightness =
			value

		ApplyPanelBackground()
	end,

	true
)

SettingsUI.TransparencyRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			5,

		ZIndex =
			46
	}, SettingsPage)

Corner(
	SettingsUI.TransparencyRow,
	9
)

RegisterUITransparency(
	SettingsUI.TransparencyRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.TransparencyRow),

	"ui_transparency"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			15
		),

		Position =
			UDim2.fromOffset(
				14,
				29
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.TransparencyRow),

	"ui_transparency_sub"
)

CreateSlider(
	SettingsUI.TransparencyRow,
	63,
	0,
	90,
	State.uiTransparency,

	function(value)
		State.uiTransparency =
			value

		ApplyUITransparency()
		ApplyPanelBackground()
	end,

	true
)

SettingsUI.ScaleRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			84
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			6,

		ZIndex =
			46
	}, SettingsPage)

Corner(
	SettingsUI.ScaleRow,
	9
)

RegisterUITransparency(
	SettingsUI.ScaleRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				10
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.ScaleRow),

	"ui_scale"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-125,
			0,
			15
		),

		Position =
			UDim2.fromOffset(
				14,
				29
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.ScaleRow),

	"ui_scale_sub"
)

CreateSlider(
	SettingsUI.ScaleRow,
	63,
	80,
	120,
	State.uiScale,

	function(value)
		State.uiScale =
			value

		if Main.Visible then
			MainScale.Scale =
				value / 100
		end
	end,

	true
)

CreateToggle(
	SettingsPage,
	{
		id =
			"rememberSettings",

		titleKey =
			"remember_settings",

		subtitleKey =
			"remember_settings_sub",

		order =
			7,

		changed =
			function(enabled)
				if enabled then
					Extra.SaveSettings()
				else
					Extra.ClearSavedSettings()
				end
			end
	}
)

SettingsUI.LanguageRow =
	New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			64
		),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.08,

		BorderSizePixel =
			0,

		LayoutOrder =
			8,

		ZIndex =
			46
	}, SettingsPage)

Corner(
	SettingsUI.LanguageRow,
	9
)

RegisterUITransparency(
	SettingsUI.LanguageRow,
	0.08
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-160,
			0,
			18
		),

		Position =
			UDim2.fromOffset(
				14,
				11
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.White,

		TextSize =
			14,

		Font =
			Enum.Font.GothamSemibold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.LanguageRow),

	"language"
)

RegisterText(
	New("TextLabel", {
		Size = UDim2.new(
			1,
			-160,
			0,
			16
		),

		Position =
			UDim2.fromOffset(
				14,
				32
			),

		BackgroundTransparency =
			1,

		TextColor3 =
			Theme.Muted,

		TextSize =
			10,

		Font =
			Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex =
			47
	}, SettingsUI.LanguageRow),

	"language_sub"
)

SettingsUI.LanguageButton =
	New("TextButton", {
		Size =
			UDim2.fromOffset(
				128,
				30
			),

		Position =
			UDim2.new(
				1,
				-142,
				0.5,
				-15
			),

		BackgroundColor3 =
			Theme.Surface2,

		BorderSizePixel =
			0,

		Text =
			"ENG",

		TextColor3 =
			Theme.White,

		TextSize =
			11,

		Font =
			Enum.Font.GothamBold,

		AutoButtonColor =
			false,

		ZIndex =
			48
	}, SettingsUI.LanguageRow)

Corner(
	SettingsUI.LanguageButton,
	7
)

Stroke(
	SettingsUI.LanguageButton,
	0.55,
	1,
	Theme.Stroke
)

RegisterUITransparency(
	SettingsUI.LanguageButton,
	0
)

local function ApplyLanguage()
	RefreshLanguage()

	SettingsUI.LanguageButton.Text =
		Language == "en"
			and Strings.en.english
			or Strings.ptbr.portuguese

	for id, button in pairs(
		HotkeyButtons
	) do
		if button and button.Parent then
			button.Text =
				FormatBinding(
					Bindings[id]
				)
		end
	end

	RefreshStatusPage()

	if Extra.RefreshMacroStatus then
		Extra.RefreshMacroStatus()
	end

	if Extra.SaveSettings then
		Extra.SaveSettings()
	end
end

Bind(
	SettingsUI.LanguageButton.MouseButton1Click,
	function()
		Language =
			Language == "en"
				and "ptbr"
				or "en"

		ApplyLanguage()
	end
)

Bind(
	Profile.MouseButton1Click,
	function()
		SelectPage(
			"Status"
		)
	end
)

local HudUI = {}

HudUI.StatusHud =
	New("CanvasGroup", {
		Name =
			"StatusHud",

		Size =
			UDim2.fromOffset(
				68,
				34
			),

		AnchorPoint =
			Vector2.new(
				0.5,
				0
			),

		Position =
			UDim2.new(
				0.5,
				0,
				0,
				12
			),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.04,

		BorderSizePixel =
			0,

		Active =
			true,

		GroupTransparency =
			1,

		Visible =
			false,

		ZIndex =
			700
	}, ScreenGui)

Corner(
	HudUI.StatusHud,
	9
)

RegisterUITransparency(
	HudUI.StatusHud,
	0.04
)

HudUI.Scale =
	New(
		"UIScale",
		{
			Scale =
				0.96
		},
		HudUI.StatusHud
	)

HudUI.FpsLabel =
	New("TextLabel", {
		Size =
			UDim2.fromScale(
				1,
				1
			),

		BackgroundTransparency =
			1,

		Text =
			"0",

		TextColor3 =
			Theme.White,

		TextSize =
			13,

		Font =
			Enum.Font.GothamBold,

		ZIndex =
			701
	}, HudUI.StatusHud)

local ClockUI = {}

ClockUI.Hud =
	New("CanvasGroup", {
		Name =
			"ClockHud",

		Size =
			UDim2.fromOffset(
				92,
				34
			),

		AnchorPoint =
			Vector2.new(
				0.5,
				0
			),

		Position =
			UDim2.new(
				0.5,
				86,
				0,
				12
			),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.04,

		BorderSizePixel =
			0,

		Active =
			true,

		GroupTransparency =
			1,

		Visible =
			false,

		ZIndex =
			700
	}, ScreenGui)

Corner(
	ClockUI.Hud,
	9
)

RegisterUITransparency(
	ClockUI.Hud,
	0.04
)

ClockUI.Scale =
	New(
		"UIScale",
		{
			Scale =
				0.96
		},
		ClockUI.Hud
	)

ClockUI.Label =
	New("TextLabel", {
		Size =
			UDim2.fromScale(
				1,
				1
			),

		BackgroundTransparency =
			1,

		Text =
			"--:--",

		TextColor3 =
			Theme.White,

		TextSize =
			13,

		Font =
			Enum.Font.GothamSemibold,

		ZIndex =
			701
	}, ClockUI.Hud)

Extra.DateUI = {}

Extra.DateUI.Hud =
	New("CanvasGroup", {
		Name =
			"DateHud",

		Size =
			UDim2.fromOffset(
				112,
				34
			),

		AnchorPoint =
			Vector2.new(
				0.5,
				0
			),

		Position =
			UDim2.new(
				0.5,
				-102,
				0,
				12
			),

		BackgroundColor3 =
			Theme.Surface,

		BackgroundTransparency =
			0.04,

		BorderSizePixel =
			0,

		Active =
			true,

		GroupTransparency =
			1,

		Visible =
			false,

		ZIndex =
			700
	}, ScreenGui)

Corner(
	Extra.DateUI.Hud,
	9
)

RegisterUITransparency(
	Extra.DateUI.Hud,
	0.04
)

Extra.DateUI.Scale =
	New(
		"UIScale",
		{
			Scale =
				0.96
		},
		Extra.DateUI.Hud
	)

Extra.DateUI.Label =
	New("TextLabel", {
		Size =
			UDim2.fromScale(
				1,
				1
			),

		BackgroundTransparency =
			1,

		Text =
			"--/--/----",

		TextColor3 =
			Theme.White,

		TextSize =
			12,

		Font =
			Enum.Font.GothamSemibold,

		ZIndex =
			701
	}, Extra.DateUI.Hud)

Extra.SetDateVisible = function(visible)
	State.dateVisible =
		visible

	if visible then
		Extra.DateUI.Hud.Visible =
			true

		Extra.DateUI.Hud.GroupTransparency =
			1

		Extra.DateUI.Scale.Scale =
			0.96

		Tween(
			Extra.DateUI.Scale,
			0.24,
			{
				Scale = 1
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			Extra.DateUI.Hud,
			0.18,
			{
				GroupTransparency = 0
			},
			Enum.EasingStyle.Sine
		)
	else
		local fade =
			Tween(
				Extra.DateUI.Hud,
				0.16,
				{
					GroupTransparency = 1
				},
				Enum.EasingStyle.Sine
			)

		Tween(
			Extra.DateUI.Scale,
			0.16,
			{
				Scale = 0.97
			},
			Enum.EasingStyle.Quart
		)

		fade.Completed:Once(function()
			if not State.dateVisible then
				Extra.DateUI.Hud.Visible =
					false
			end
		end)
	end
end

HudUI.FlyNotice =
	RegisterText(
		New("TextLabel", {
			Size =
				UDim2.fromOffset(
					260,
					34
				),

			AnchorPoint =
				Vector2.new(
					0.5,
					0
				),

			Position =
				UDim2.new(
					0.5,
					0,
					0,
					54
				),

			BackgroundColor3 =
				Theme.Surface,

			BorderSizePixel =
				0,

			TextColor3 =
				Theme.White,

			TextSize =
				11,

			Font =
				Enum.Font.GothamSemibold,

			Visible =
				false,

			TextTransparency =
				1,

			BackgroundTransparency =
				1,

			ZIndex =
				702
		}, ScreenGui),

		"fly_notice"
	)

Corner(
	HudUI.FlyNotice,
	9
)

ShowFlyNotice = function()
	FlyNoticeToken += 1

	local token =
		FlyNoticeToken

	HudUI.FlyNotice.Visible =
		true

	HudUI.FlyNotice.TextTransparency =
		1

	HudUI.FlyNotice.BackgroundTransparency =
		1

	Tween(
		HudUI.FlyNotice,
		0.18,
		{
			TextTransparency =
				0,

			BackgroundTransparency =
				0.05
		},
		Enum.EasingStyle.Sine
	)

	task.delay(
		2.2,
		function()
			if token ~= FlyNoticeToken then
				return
			end

			local fade =
				Tween(
					HudUI.FlyNotice,
					0.18,
					{
						TextTransparency =
							1,

						BackgroundTransparency =
							1
					},
					Enum.EasingStyle.Sine
				)

			fade.Completed:Once(
				function()
					if token == FlyNoticeToken then
						HudUI.FlyNotice.Visible =
							false
					end
				end
			)
		end
	)
end

local function MakeDraggable(
	handle,
	target
)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil

	Bind(
		handle.InputBegan,
		function(input)
			if input.UserInputType
				== Enum.UserInputType.MouseButton1
				or input.UserInputType
					== Enum.UserInputType.Touch then

				dragging =
					true

				dragStart =
					input.Position

				startPosition =
					target.Position

				Bind(
					input.Changed,
					function()
						if input.UserInputState
							== Enum.UserInputState.End then
							dragging =
								false
						end
					end
				)
			end
		end
	)

	Bind(
		handle.InputChanged,
		function(input)
			if input.UserInputType
				== Enum.UserInputType.MouseMovement
				or input.UserInputType
					== Enum.UserInputType.Touch then

				dragInput =
					input
			end
		end
	)

	Bind(
		UserInputService.InputChanged,
		function(input)
			if dragging
				and input == dragInput then

				local delta =
					input.Position
					- dragStart

				target.Position =
					UDim2.new(
						startPosition.X.Scale,
						startPosition.X.Offset + delta.X,
						startPosition.Y.Scale,
						startPosition.Y.Offset + delta.Y
					)
			end
		end
	)
end

MakeDraggable(
	TopBar,
	Main
)

MakeDraggable(
	HudUI.StatusHud,
	HudUI.StatusHud
)

MakeDraggable(
	ClockUI.Hud,
	ClockUI.Hud
)

MakeDraggable(
	Extra.DateUI.Hud,
	Extra.DateUI.Hud
)

local MenuAnimationId = 0
local FpsAnimationId = 0

local function SetMenuVisible(visible)
	MenuAnimationId += 1

	local id =
		MenuAnimationId

	State.menuVisible =
		visible

	if visible then
		if not (
			State.freecam
			and Extra.Freecam.active
		) then
			local currentBehavior =
				UserInputService.MouseBehavior

			PreviousMouseBehavior =
				currentBehavior

			PreviousMouseIconEnabled =
				UserInputService.MouseIconEnabled
		end

		UserInputService.MouseBehavior =
			Enum.MouseBehavior.Default

		UserInputService.MouseIconEnabled =
			true

		Main.Visible =
			true

		ApplyPanelBackground()
		ApplyUITransparency()

		Main.GroupTransparency =
			1

		MainScale.Scale =
			(State.uiScale / 100)
			* 0.985

		Tween(
			Main,
			0.18,
			{
				GroupTransparency =
					0
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			MainScale,
			0.24,
			{
				Scale =
					State.uiScale / 100
			},
			Enum.EasingStyle.Quint
		)
	else
		StopSpeedManipulation()

		Capture =
			nil

		local focused =
			UserInputService:
				GetFocusedTextBox()

		if focused then
			focused:ReleaseFocus(
				false
			)
		end

		local fade =
			Tween(
				Main,
				0.14,
				{
					GroupTransparency =
						1
				},
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.In
			)

		Tween(
			MainScale,
			0.16,
			{
				Scale =
					(State.uiScale / 100)
					* 0.99
			},
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In
		)

		fade.Completed:Once(function()
			if id ~= MenuAnimationId
				or State.menuVisible then
				return
			end

			Main.Visible =
				false

			if State.freecam
				and Extra.Freecam.active then

				UserInputService.MouseBehavior =
					Enum.MouseBehavior.LockCenter

				UserInputService.MouseIconEnabled =
					false
			else
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

	local id =
		FpsAnimationId

	State.fpsVisible =
		visible

	if visible then
		HudUI.StatusHud.Visible =
			true

		HudUI.StatusHud.GroupTransparency =
			1

		HudUI.Scale.Scale =
			0.96

		Tween(
			HudUI.Scale,
			0.25,
			{
				Scale = 1
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			HudUI.StatusHud,
			0.18,
			{
				GroupTransparency =
					0
			},
			Enum.EasingStyle.Sine
		)
	else
		local fade =
			Tween(
				HudUI.StatusHud,
				0.16,
				{
					GroupTransparency =
						1
				},
				Enum.EasingStyle.Sine
			)

		Tween(
			HudUI.Scale,
			0.16,
			{
				Scale = 0.97
			},
			Enum.EasingStyle.Quart
		)

		fade.Completed:Once(function()
			if id == FpsAnimationId
				and not State.fpsVisible then
				HudUI.StatusHud.Visible =
					false
			end
		end)
	end
end

SetClockVisible = function(visible)
	State.clockVisible =
		visible

	if visible then
		ClockUI.Hud.Visible =
			true

		ClockUI.Hud.GroupTransparency =
			1

		ClockUI.Scale.Scale =
			0.96

		Tween(
			ClockUI.Scale,
			0.24,
			{
				Scale = 1
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			ClockUI.Hud,
			0.18,
			{
				GroupTransparency = 0
			},
			Enum.EasingStyle.Sine
		)
	else
		local fade =
			Tween(
				ClockUI.Hud,
				0.16,
				{
					GroupTransparency = 1
				},
				Enum.EasingStyle.Sine
			)

		Tween(
			ClockUI.Scale,
			0.16,
			{
				Scale = 0.97
			},
			Enum.EasingStyle.Quart
		)

		fade.Completed:Once(function()
			if not State.clockVisible then
				ClockUI.Hud.Visible =
					false
			end
		end)
	end
end

Bind(
	UserInputService.InputBegan,
	function(input, gameProcessed)
		Extra.RecordMacroInput(
			input,
			true
		)

		if Capture then
			if input.UserInputType
				== Enum.UserInputType.Keyboard
				and input.KeyCode
					== Enum.KeyCode.Escape then

				Capture.button.Text =
					FormatBinding(
						Bindings[
							Capture.id
						]
					)

				Capture.button.TextColor3 =
					Theme.White

				Capture =
					nil

				return
			end

			local capturedId =
				Capture.id

			local newBinding =
				nil

			if input.UserInputType
				== Enum.UserInputType.Keyboard then

				if IsForbiddenHotkey(
					input.KeyCode
				) then
					Tween(
						Capture.button,
						0.10,
						{
							TextColor3 =
								Theme.Red
						},
						Enum.EasingStyle.Quad
					)

					task.delay(
						0.25,
						function()
							if Capture
								and Capture.button
								and Capture.button.Parent then

								Capture.button.TextColor3 =
									Theme.PurpleBright
							end
						end
					)

					return
				end

				if input.KeyCode
					== Enum.KeyCode.LeftControl
					or input.KeyCode
						== Enum.KeyCode.RightControl then

					newBinding = {
						kind = "Control"
					}
				else
					newBinding = {
						kind = "KeyCode",
						value = input.KeyCode
					}
				end

			elseif input.UserInputType
				== Enum.UserInputType.MouseButton1
				or input.UserInputType
					== Enum.UserInputType.MouseButton2
				or input.UserInputType
					== Enum.UserInputType.MouseButton3 then

				newBinding = {
					kind = "InputType",
					value = input.UserInputType
				}
			else
				return
			end

			AssignBinding(
				capturedId,
				newBinding
			)

			Capture = nil

			return
		end

		if UserInputService:
			GetFocusedTextBox() then
			return
		end

		if BindingMatches(
			Bindings.aimHold,
			input
		) then
			Extra.AimHeld =
				State.aimbot == true

			return
		end

		if BindingMatches(
			Bindings.autoClickerHold,
			input
		) then
			Extra.AutoClickHeld =
				State.autoClickerEnabled == true

			if Extra.AutoClickHeld then
				Extra.StartAutoClicker()
			end

			return
		end

		if BindingMatches(
			Bindings.menu,
			input
		) then
			SetMenuVisible(
				not State.menuVisible
			)

			return
		end

		if BindingMatches(
			Bindings.speedManipulation,
			input
		) then
			StartSpeedManipulation()

			return
		end

		if gameProcessed then
			return
		end

		for id, binding in pairs(
			Bindings
		) do
			if id ~= "speedManipulation"
				and id ~= "menu"
				and id ~= "aimHold"
				and id ~= "autoClickerHold"
				and BindingMatches(
					binding,
					input
				) then

				local setter =
					ToggleSetters[id]

				if setter then
					setter(
						not State[id]
					)
				end

				return
			end
		end
	end
)

Bind(
	UserInputService.InputEnded,
	function(input)
		Extra.RecordMacroInput(
			input,
			false
		)

		if BindingMatches(
			Bindings.speedManipulation,
			input
		) then
			StopSpeedManipulation()
		end

		if BindingMatches(
			Bindings.aimHold,
			input
		) then
			Extra.AimHeld =
				false
		end

		if BindingMatches(
			Bindings.autoClickerHold,
			input
		) then
			Extra.AutoClickHeld =
				false

			Extra.AutoClickToken +=
				1
		end
	end
)

Bind(
	RunService.Stepped,
	function()
		local character =
			LocalPlayer.Character

		if (
			State.noclip
			or State.speedManipulation
		)
			and character then

			for _, object in ipairs(
				character:GetDescendants()
			) do
				if object:IsA("BasePart") then
					if SavedLocalCollision[
						object
					] == nil then
						SavedLocalCollision[
							object
						] =
							object.CanCollide
					end

					object.CanCollide =
						false
				end
			end

		elseif not State.speedManipulation
			and next(
				SavedLocalCollision
			) then

			RestoreLocalCollision()
		end
	end
)

Bind(
	RunService.Heartbeat,
	function()
		local character =
			LocalPlayer.Character

		local humanoid =
			character
			and character:
				FindFirstChildOfClass(
					"Humanoid"
				)

		local root =
			character
			and character:
				FindFirstChild(
					"HumanoidRootPart"
				)

		if State.walkSpeed
			and humanoid
			and not State.speedManipulation then

			humanoid.WalkSpeed =
				State.walkSpeedValue
		end

		if State.antiFling
			and root then

			local linear =
				root.AssemblyLinearVelocity.Magnitude

			local angular =
				root.AssemblyAngularVelocity.Magnitude

			if linear < 90
				and angular < 45 then

				LastSafeCFrame =
					root.CFrame
			end

			if linear > 150
				or angular > 75 then

				root.AssemblyLinearVelocity =
					Vector3.zero

				root.AssemblyAngularVelocity =
					Vector3.zero

				if LastSafeCFrame then
					root.CFrame =
						LastSafeCFrame
				end
			end

			for _, player in ipairs(
				Players:GetPlayers()
			) do
				if player ~= LocalPlayer
					and player.Character then

					for _, object in ipairs(
						player.Character:
							GetDescendants()
					) do
						if object:IsA("BasePart") then
							if SavedOtherCollision[
								object
							] == nil then

								SavedOtherCollision[
									object
								] =
									object.CanCollide
							end

							object.CanCollide =
								false
						end
					end
				end
			end

		elseif next(
			SavedOtherCollision
		) then

			RestoreOtherCollision()
		end

		if State.playerEsp
			or State.friendEsp then

			for _, player in ipairs(
				Players:GetPlayers()
			) do
				if player ~= LocalPlayer then
					EnsurePlayerEsp(
						player
					)
				end
			end

		elseif next(
			PlayerEspObjects
		) then

			ClearPlayerEsp()
		end

		if next(
			Extra.FriendEspObjects
		) then
			Extra.ClearFriendEsp()
		end

		if State.entityEsp then
			for model in pairs(
				EntityEspObjects
			) do
				if model
					and model.Parent then

					EnsureEntityEsp(
						model
					)
				else
					DestroyEntityEsp(
						model
					)
				end
			end

		elseif next(
			EntityEspObjects
		) then
			ClearEntityEsp()
		end

		if State.itemEsp then
			for object in pairs(
				Extra.ItemEspObjects
			) do
				if object
					and object.Parent then

					Extra.EnsureGenericEsp(
						Extra.ItemEspObjects,
						object,
						"item"
					)
				else
					Extra.DestroyGenericEsp(
						Extra.ItemEspObjects,
						object
					)
				end
			end

		elseif next(
			Extra.ItemEspObjects
		) then
			Extra.ClearGenericEsp(
				"item"
			)
		end

		if State.objectiveEsp then
			for object in pairs(
				Extra.ObjectiveEspObjects
			) do
				if object
					and object.Parent then

					Extra.EnsureGenericEsp(
						Extra.ObjectiveEspObjects,
						object,
						"objective"
					)
				else
					Extra.DestroyGenericEsp(
						Extra.ObjectiveEspObjects,
						object
					)
				end
			end

		elseif next(
			Extra.ObjectiveEspObjects
		) then
			Extra.ClearGenericEsp(
				"objective"
			)
		end
	end
)

Bind(
	Workspace.DescendantAdded,
	function(object)
		task.defer(function()
			local model =
				object:IsA("Model")
					and object
					or object:
						FindFirstAncestorOfClass(
							"Model"
						)

			if model and model.Parent then
				if State.entityEsp then
					EnsureEntityEsp(
						model
					)
				end

				if State.entitySpawnWarning
					and IsPotentiallyHostile(
						model
					)
					and not Extra.WarnedEntities[
						model
					] then

					Extra.WarnedEntities[
						model
					] = true

					Extra.Toast(
						(
							Language == "ptbr"
								and "Entidade detectada: "
								or "Entity detected: "
						)
						.. model.Name,
						true
					)
				end
			end

			if State.itemEsp
				and Extra.IsItem(object) then

				Extra.EnsureGenericEsp(
					Extra.ItemEspObjects,

					object:IsA("Tool")
						and object
						or object:
							FindFirstAncestorOfClass(
								"Tool"
							)
						or object,

					"item"
				)
			end

			if State.objectiveEsp
				and Extra.IsObjective(object) then

				Extra.EnsureGenericEsp(
					Extra.ObjectiveEspObjects,
					object,
					"objective"
				)
			end

			if (
				State.hideParticles
				or State.performanceMode
			)
				and (
					object:IsA("ParticleEmitter")
					or object:IsA("Trail")
					or object:IsA("Beam")
					or object:IsA("Smoke")
					or object:IsA("Fire")
					or object:IsA("Sparkles")
				) then

				if Extra.ParticleSaved[
					object
				] == nil then
					Extra.ParticleSaved[
						object
					] =
						object.Enabled
				end

				object.Enabled =
					false
			end
		end)

		if State.lowGraphics
			or State.performanceMode then

			task.defer(function()
				if object.Parent then
					ApplyLowToObject(
						object
					)
				end
			end)
		end

		if State.instantInteract
			and object:IsA(
				"ProximityPrompt"
			) then

			task.defer(function()
				if object.Parent then
					if InstantSaved[
						object
					] == nil then

						InstantSaved[
							object
						] =
							object.HoldDuration
					end

					object.HoldDuration =
						0
				end
			end)
		end
	end
)

local RuntimeCounters = {
	frameCount = 0,
	frameElapsed = 0,
	fpsAccumulator = 0,
	statusAccumulator = 0,
	clockAccumulator = 0,
	currentFps = 0
}

Bind(
	RunService.RenderStepped,
	function(deltaTime)
		RuntimeCounters.frameCount += 1
		RuntimeCounters.frameElapsed += deltaTime
		RuntimeCounters.fpsAccumulator += deltaTime
		RuntimeCounters.statusAccumulator += deltaTime
		RuntimeCounters.clockAccumulator += deltaTime

		if State.fly
			and FlyVelocity
			and FlyGyro then

			local character =
				LocalPlayer.Character

			local root =
				character
				and character:
					FindFirstChild(
						"HumanoidRootPart"
					)

			if root and Camera then
				local targetPosition =
					Mouse.Hit.Position

				local forward =
					targetPosition
					- root.Position

				if forward.Magnitude > 0.001 then
					forward =
						forward.Unit
				else
					forward =
						Camera.CFrame.LookVector
				end

				local right =
					forward:
						Cross(
							Vector3.yAxis
						)

				if right.Magnitude > 0.001 then
					right =
						right.Unit
				else
					right =
						Camera.CFrame.RightVector
				end

				local movement =
					Vector3.zero

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.W
					) then

					movement +=
						forward
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.S
					) then

					movement -=
						forward
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.D
					) then

					movement +=
						right
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.A
					) then

					movement -=
						right
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.E
					) then

					movement +=
						Vector3.yAxis
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.Q
					) then

					movement -=
						Vector3.yAxis
				end

				if movement.Magnitude > 0 then
					movement =
						movement.Unit
						* State.flySpeed
				end

				FlyVelocity.VectorVelocity =
					movement

				local align =
					FlyGyro:
						FindFirstChild(
							"KHubFlyAlign"
						)

				if align then
					align.CFrame =
						CFrame.lookAt(
							root.Position,
							root.Position
								+ forward
						)
				end
			end
		end

		if State.aimbot
			and Extra.AimHeld
			and not State.menuVisible
			and not State.freecam
			and Camera then

			local target =
				Extra.GetAimTarget()

			if target then
				local desired =
					CFrame.lookAt(
						Camera.CFrame.Position,
						target.Position
					)

				local alpha =
					math.clamp(
						(
							State.aimSmooth
							or 10
						)
						* deltaTime,
						0.03,
						1
					)

				Camera.CFrame =
					Camera.CFrame:
						Lerp(
							desired,
							alpha
						)
			end
		end

		if State.freecam
			and Extra.Freecam.active
			and Camera then

			Camera.CameraType =
				Enum.CameraType.Scriptable

			if not State.menuVisible then
				local delta =
					UserInputService:
						GetMouseDelta()

				Extra.Freecam.yaw -=
					delta.X
					* 0.0024

				Extra.Freecam.pitch =
					math.clamp(
						(Extra.Freecam.pitch or 0)
							- delta.Y
								* 0.0024,
						-1.45,
						1.45
					)

				local rotation =
					CFrame.fromOrientation(
						Extra.Freecam.pitch or 0,
						Extra.Freecam.yaw or 0,
						0
					)

				local move =
					Vector3.zero

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.W
					) then

					move +=
						rotation.LookVector
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.S
					) then

					move -=
						rotation.LookVector
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.D
					) then

					move +=
						rotation.RightVector
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.A
					) then

					move -=
						rotation.RightVector
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.E
					) then

					move +=
						Vector3.yAxis
				end

				if UserInputService:
					IsKeyDown(
						Enum.KeyCode.Q
					) then

					move -=
						Vector3.yAxis
				end

				if move.Magnitude > 0 then
					Extra.Freecam.position +=
						move.Unit
						* State.freecamSpeed
						* deltaTime
				end

				Camera.CFrame =
					CFrame.new(
						Extra.Freecam.position
					)
					* rotation
			end
		end

		if State.fov
			and Camera then
			Camera.FieldOfView =
				State.fovValue
		end

		if State.brightness then
			Lighting.Brightness =
				State.brightnessValue
		end

		if State.noFog then
			Extra.EnableNoFog()
		end

		if RuntimeCounters.frameElapsed >= 0.5 then
			RuntimeCounters.currentFps =
				math.floor(
					(
						RuntimeCounters.frameCount
						/ RuntimeCounters.frameElapsed
					)
					+ 0.5
				)

			RuntimeCounters.frameCount =
				0

			RuntimeCounters.frameElapsed =
				0
		end

		if RuntimeCounters.fpsAccumulator
			>= (1 / 30) then

			HudUI.FpsLabel.Text =
				tostring(
					RuntimeCounters.currentFps
				)

			RuntimeCounters.fpsAccumulator =
				0
		end

		if RuntimeCounters.statusAccumulator
			>= 0.4 then

			RefreshStatusPage()

			RuntimeCounters.statusAccumulator =
				0
		end

		if RuntimeCounters.clockAccumulator
			>= 0.5 then

			RuntimeCounters.clockAccumulator =
				0

			if State.clockVisible then
				local ok, value =
					pcall(function()
						return
							DateTime.now():
								FormatLocalTime(
									"HH:mm",
									"en-us"
								)
					end)

				ClockUI.Label.Text =
					ok
					and value
					or os.date(
						"%H:%M"
					)
			end

			if State.dateVisible
				and Extra.DateUI
				and Extra.DateUI.Label then

				local d =
					DateTime.now():
						ToLocalTime()

				Extra.DateUI.Label.Text =
					Language == "ptbr"
						and string.format(
							"%02d/%02d/%04d",
							d.Day,
							d.Month,
							d.Year
						)
						or string.format(
							"%02d/%02d/%04d",
							d.Month,
							d.Day,
							d.Year
						)
			end
		end
	end
)

Bind(
	Players.PlayerRemoving,
	function(player)
		DestroyPlayerEsp(
			player
		)

		Extra.DestroyFriendEsp(
			player
		)

		Extra.FriendCache[
			player.UserId
		] = nil

		Extra.FriendPending[
			player.UserId
		] = nil

		if Extra.SelectedSpectate
			== player then

			task.defer(
				Extra.UpdateSpectate
			)
		end
	end
)

Bind(
	Players.PlayerAdded,
	function(player)
		task.defer(
			Extra.UpdateSpectate
		)

		if State.friendEsp then
			task.spawn(function()
				Extra.RefreshFriendStatus(
					player
				)

				if State.friendEsp then
					Extra.EnsureFriendEsp(
						player
					)
				end
			end)
		end
	end
)

Bind(
	LocalPlayer.CharacterAdded,
	function(character)
		LastSafeCFrame =
			nil

		SavedWalkSpeed =
			nil

		RestoreLocalCollision()
		StopSpeedManipulation()
		DestroyFly()

		task.spawn(function()
			local humanoid =
				character:
					WaitForChild(
						"Humanoid",
						10
					)

			if humanoid
				and State.walkSpeed then

				SavedWalkSpeed =
					humanoid.WalkSpeed

				humanoid.WalkSpeed =
					State.walkSpeedValue
			end

			if State.fly then
				task.wait(0.3)
				CreateFly()
			end

			if State.spectate then
				Extra.UpdateSpectate()
			end

			if State.freecam then
				task.wait(0.2)

				Extra.Freecam.active =
					false

				Extra.StartFreecam()
			end
		end)
	end
)

task.spawn(function()
	local ok, content =
		pcall(function()
			return
				Players:
					GetUserThumbnailAsync(
						LocalPlayer.UserId,

						Enum.ThumbnailType.HeadShot,

						Enum.ThumbnailSize.Size150x150
					)
		end)

	if ok and content then
		Avatar.Image =
			content
	else
		Avatar.Image =
			"rbxthumb://type=AvatarHeadShot&id="
			.. tostring(
				LocalPlayer.UserId
			)
			.. "&w=150&h=150"
	end
end)

task.spawn(function()
	local preload = {
		Background,
		HubIcon,
		IntroParts.Icon,
		Avatar
	}

	for _, data in ipairs(
		BlurLayers
	) do
		table.insert(
			preload,
			data.image
		)
	end

	pcall(function()
		ContentProvider:
			PreloadAsync(
				preload
			)
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
	State.friendEsp = false
	State.entityEsp = false

	State.itemEsp = false
	State.objectiveEsp = false

	State.fov = false
	State.freecam = false
	State.spectate = false

	State.noFog = false
	State.brightness = false

	State.hideParticles = false
	State.performanceMode = false

	State.lowGraphics = false
	State.fullBright = false

	State.fpsVisible = false
	State.clockVisible = false
	State.dateVisible = false

	State.aimbot = false

	State.autoWalk = false
	State.autoClickerEnabled = false

	State.instantInteract = false

	local character =
		LocalPlayer.Character

	local humanoid =
		character
		and character:
			FindFirstChildOfClass(
				"Humanoid"
			)

	if humanoid
		and SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed =
			SavedWalkSpeed
	end

	SavedWalkSpeed = nil

	RestoreLocalCollision()
	RestoreOtherCollision()

	ClearPlayerEsp()
	Extra.ClearFriendEsp()

	ClearEntityEsp()

	Extra.ClearGenericEsp(
		"item"
	)

	Extra.ClearGenericEsp(
		"objective"
	)

	Extra.StopFreecam()
	Extra.StopSpectate()
	Extra.StopAutoWalk()
	Extra.StopMacro()

	Extra.AutoClickHeld = false
	Extra.AutoClickToken += 1

	Extra.DisableNoFog()

	if Extra.OriginalFov then
		Camera.FieldOfView =
			Extra.OriginalFov
	end

	if Extra.VisualSaved.brightness
		~= nil then

		Lighting.Brightness =
			Extra.VisualSaved.brightness

		Extra.VisualSaved.brightness =
			nil
	end

	Extra.SetParticlesHidden(
		false
	)

	DisableLowGraphics()
	DisableFullBright()
	DisableInstantInteract()

	for _, connection in ipairs(
		Connections
	) do
		pcall(function()
			connection:
				Disconnect()
		end)
	end

	table.clear(
		Connections
	)

	UserInputService.MouseBehavior =
		PreviousMouseBehavior

	UserInputService.MouseIconEnabled =
		PreviousMouseIconEnabled

	if ScreenGui
		and ScreenGui.Parent then
		ScreenGui:Destroy()
	end

	if _G.KHubCleanup
		== Cleanup then
		_G.KHubCleanup =
			nil
	end
end

_G.KHubCleanup =
	Cleanup

SelectPage(
	"Info"
)

ApplyPanelBackground()
ApplyUITransparency()

for id, setter in pairs(
	ToggleSetters
) do
	if State[id] == true
		and id ~= "rememberSettings" then

		pcall(
			setter,
			true
		)
	end
end

if State.rememberSettings
	and ToggleSetters.rememberSettings then

	pcall(
		ToggleSetters.rememberSettings,
		true
	)
end

SetFpsVisible(
	State.fpsVisible
)

SetClockVisible(
	State.clockVisible
)

if Extra.SetDateVisible then
	Extra.SetDateVisible(
		State.dateVisible
	)
end

RefreshStatusPage()
ApplyLanguage()

task.spawn(function()
	for _, player in ipairs(
		Players:GetPlayers()
	) do
		if player ~= LocalPlayer then
			task.spawn(function()
				Extra.RefreshFriendStatus(
					player
				)
			end)
		end
	end
end)

task.spawn(function()
	local ok, err =
		pcall(function()
			IntroParts.IconBox.BackgroundTransparency =
				1

			IntroParts.IconStroke.Transparency =
				1

			IntroParts.Icon.ImageTransparency =
				1

			IntroParts.K.TextTransparency =
				1

			IntroParts.Hub.TextTransparency =
				1

			IntroParts.Tagline.TextTransparency =
				1

			IntroParts.Status.TextTransparency =
				1

			IntroParts.Progress.BackgroundTransparency =
				1

			IntroParts.ProgressFill.BackgroundTransparency =
				1

			IntroParts.ProgressFill.Size =
				UDim2.fromScale(
					0,
					1
				)

			IntroParts.RingStroke.Transparency =
				1

			IntroParts.RingInnerStroke.Transparency =
				1

			IntroParts.IconScale.Scale =
				0.78

			Tween(
				IntroParts.Gradient,
				5.4,
				{
					Rotation = 26
				},
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			)

			Tween(
				IntroParts.Glow,
				1.0,
				{
					Size =
						UDim2.fromOffset(
							220,
							220
						),

					BackgroundTransparency =
						0.965
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.RingStroke,
				0.75,
				{
					Transparency =
						0.58
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.RingInnerStroke,
				0.9,
				{
					Transparency =
						0.78
				},
				Enum.EasingStyle.Quint
			)

			task.wait(0.30)

			Tween(
				IntroParts.IconBox,
				0.55,
				{
					BackgroundTransparency =
						0.02
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.IconStroke,
				0.55,
				{
					Transparency =
						0.60
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.Icon,
				0.45,
				{
					ImageTransparency =
						0
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.IconScale,
				0.70,
				{
					Scale = 1
				},
				Enum.EasingStyle.Back
			)

			task.wait(0.70)

			Tween(
				IntroParts.K,
				0.28,
				{
					TextTransparency =
						0
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.Hub,
				0.42,
				{
					TextTransparency =
						0
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				IntroParts.Tagline,
				0.48,
				{
					TextTransparency =
						0
				},
				Enum.EasingStyle.Sine
			)

			task.wait(0.45)

			IntroParts.Status.Text =
				Language == "ptbr"
					and "carregando interface"
					or "loading interface"

			Tween(
				IntroParts.Status,
				0.25,
				{
					TextTransparency =
						0
				},
				Enum.EasingStyle.Sine
			)

			Tween(
				IntroParts.Progress,
				0.25,
				{
					BackgroundTransparency =
						0.28
				},
				Enum.EasingStyle.Sine
			)

			Tween(
				IntroParts.ProgressFill,
				0.25,
				{
					BackgroundTransparency =
						0.05
				},
				Enum.EasingStyle.Sine
			)

			Tween(
				IntroParts.ProgressFill,
				3.0,
				{
					Size =
						UDim2.fromScale(
							1,
							1
						)
				},
				Enum.EasingStyle.Quint
			)

			task.spawn(function()
				for _ = 1, 3 do
					if Destroyed then
						return
					end

					Tween(
						IntroParts.IconScale,
						0.42,
						{
							Scale =
								1.025
						},
						Enum.EasingStyle.Sine
					)

					Tween(
						IntroParts.Glow,
						0.42,
						{
							BackgroundTransparency =
								0.95
						},
						Enum.EasingStyle.Sine
					)

					task.wait(0.42)

					Tween(
						IntroParts.IconScale,
						0.42,
						{
							Scale =
								1
						},
						Enum.EasingStyle.Sine
					)

					Tween(
						IntroParts.Glow,
						0.42,
						{
							BackgroundTransparency =
								0.968
						},
						Enum.EasingStyle.Sine
					)

					task.wait(0.42)
				end
			end)

			task.wait(1.15)

			IntroParts.Status.Text =
				Language == "ptbr"
					and "preparando recursos"
					or "preparing features"

			task.wait(1.15)

			IntroParts.Status.Text =
				Language == "ptbr"
					and "pronto"
					or "ready"

			IntroParts.Status.TextColor3 =
				Theme.Light

			task.wait(0.65)

			local fade =
				Tween(
					Intro,
					0.55,
					{
						GroupTransparency =
							1
					},
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.In
				)

			fade.Completed:Wait()

			if Destroyed then
				return
			end

			Intro.Visible =
				false

			SetMenuVisible(
				true
			)
		end)

	if not ok
		and not Destroyed then

		warn(
			"[K hub] Intro failed: "
			.. tostring(err)
		)

		Intro.Visible =
			false

		SetMenuVisible(
			true
		)
	end
end)
