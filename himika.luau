--!strict
--[[
    Optimizer.client.luau
    Coloque este LocalScript em:
    StarterPlayer > StarterPlayerScripts

    Objetivo:
    - Reduzir custo visual no CLIENTE.
    - Preservar gameplay e áudio por padrão.
    - Aplicar otimizações continuamente conforme objetos entram no Workspace.
    - Permitir restauração em runtime.
    - Evitar loops por frame desnecessários.
    - Nunca depender de APIs de exploit/executor.

    IMPORTANTE:
    Este script foi feito para um projeto Roblox legítimo onde você controla
    o código da experiência. Ele NÃO intercepta remotes e NÃO altera
    propriedades que o Roblox restringe ao servidor/Studio.
]]

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Terrain = Workspace.Terrain

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------

local CONFIG = {
    -----------------------------------------------------------------
    -- MASTER
    -----------------------------------------------------------------

    Enabled = true,

    -- Quantidade de objetos processados antes de ceder tempo ao scheduler.
    YieldEvery = 100,

    -- Intervalo da verificação de distância.
    DistanceScanInterval = 2.0,

    -- Intervalo do log automático.
    StatsInterval = 5.0,

    -- Intervalo para limpeza de referências internas mortas.
    CleanupInterval = 30.0,

    LogEnabled = true,
    LogStats = true,

    -----------------------------------------------------------------
    -- EFEITOS VISUAIS
    -----------------------------------------------------------------

    KillParticles = true,
    KillBeams = true,
    KillTrails = true,
    KillSmoke = true,
    KillFire = true,
    KillSparkles = true,
    KillExplosions = true,

    KillDecals = true,
    KillTextures = true,

    KillBillboardGui = true,
    KillSurfaceGui = true,
    KillViewportFrame = true,

    -----------------------------------------------------------------
    -- LIGHTING
    -----------------------------------------------------------------

    KillSkybox = true,
    KillAtmosphere = true,

    KillBloom = true,
    KillBlur = true,
    KillDOF = true,
    KillSunRays = true,
    KillColorCorrection = true,

    -- Se true, todos os PostEffects compatíveis são desligados
    -- independentemente das flags individuais acima.
    KillPostFX = true,

    KillShadows = true,
    KillFog = true,

    LightingBrightness = 1.5,

    -----------------------------------------------------------------
    -- TERRAIN
    -----------------------------------------------------------------

    KillTerrainDetails = true,
    KillGrass = true,

    KillWaterWaves = true,

    -----------------------------------------------------------------
    -- DISTÂNCIA / CULLING VISUAL
    -----------------------------------------------------------------

    -- Roblox não possui um "FarClipPlane" configurável via LocalScript.
    -- Esta flag usa culling manual dos elementos suportados.
    LowerRenderDistance = true,

    VisualCullDistance = 250,
    GuiCullDistance = 200,

    -- Se false, Decal/Texture/SurfaceAppearance elegíveis são ocultados
    -- globalmente em vez de apenas quando distantes.
    DistantOnlyTextures = true,

    -- Se false, BillboardGui/SurfaceGui/ViewportFrame elegíveis são
    -- desligados globalmente.
    DistantOnly3DGui = true,

    -----------------------------------------------------------------
    -- CAMERA
    -----------------------------------------------------------------

    OptimizeCamera = true,
    CameraFieldOfView = 70,

    -----------------------------------------------------------------
    -- CORE GUI
    -----------------------------------------------------------------

    DisableCoreChat = false,
    DisableCorePlayerList = true,
    DisableCoreEmotes = true,
    DisableCoreBackpack = false,

    -----------------------------------------------------------------
    -- CHARACTER
    -----------------------------------------------------------------

    -- Desabilitar estados pode mudar mecânicas.
    -- Por isso fica OFF por padrão.
    OptimizeHumanoid = false,

    DisableHumanoidClimbing = false,
    DisableHumanoidSwimming = false,
    DisableHumanoidSeated = false,
    DisableHumanoidFallingDown = true,
    DisableHumanoidRagdoll = true,

    -- Muito agressivo.
    -- Remove temporariamente Animator de OUTROS jogadores.
    DisableOtherPlayerAnimators = false,

    -----------------------------------------------------------------
    -- AUDIO
    -----------------------------------------------------------------

    -- OBRIGATORIAMENTE true por padrão.
    --
    -- Enquanto estiver true, nenhum Sound/SoundGroup é alterado.
    PreserveSFX = true,

    -- Música/UI também ficam preservados por padrão.
    --
    -- Pela regra rígida de proteção sonora, esta opção só terá efeito
    -- se PreserveSFX = false.
    KillMusicAndUISounds = false,

    -----------------------------------------------------------------
    -- INPUT
    -----------------------------------------------------------------

    ToggleKey = Enum.KeyCode.F8,
    StatsKey = Enum.KeyCode.F9,
}

---------------------------------------------------------------------
-- STATS
---------------------------------------------------------------------

local STATS = {
    Scanned = 0,
    Optimized = 0,
    Restored = 0,
    Errors = 0,

    Particles = 0,
    Beams = 0,
    Trails = 0,
    Smoke = 0,
    Fire = 0,
    Sparkles = 0,
    Explosions = 0,

    Decals = 0,
    Textures = 0,
    SurfaceAppearances = 0,

    BillboardGuis = 0,
    SurfaceGuis = 0,
    ViewportFrames = 0,

    PostFX = 0,
    Atmospheres = 0,
    Skies = 0,

    CoreGui = 0,
    HumanoidStates = 0,
    Animators = 0,

    AudioMuted = 0,

    DistancePasses = 0,
    DynamicObjects = 0,
}

---------------------------------------------------------------------
-- RUNTIME STATE
---------------------------------------------------------------------

local RUNTIME = {
    enabled = CONFIG.Enabled,

    -- Usado para cancelar scans antigos quando F8 é pressionado.
    scanGeneration = 0,

    initialized = false,
}

---------------------------------------------------------------------
-- SAVED STATE
--
-- Todas as propriedades modificadas ficam armazenadas para restore().
---------------------------------------------------------------------

local SAVED = {}

local SAVED_HUMANOID_STATES = {}

local SAVED_CORE_GUI = {}

-- Objetos que dependem de distância.
local DISTANCE_TRACKED = {}

-- Evita incrementar contador repetidamente para o mesmo objeto.
local COUNTED = {}

-- Evita warnings repetidos.
local WARNED = {}

---------------------------------------------------------------------
-- LOGGING
---------------------------------------------------------------------

local PREFIX = "[CLIENT OPTIMIZER]"

local function log(...)
    if not CONFIG.LogEnabled then
        return
    end

    print(PREFIX, ...)
end

local function warnOnce(key, ...)
    if WARNED[key] then
        return
    end

    WARNED[key] = true
    warn(PREFIX, ...)
end

local function incrementError()
    STATS.Errors += 1
end

---------------------------------------------------------------------
-- PCALL HELPERS
---------------------------------------------------------------------

local function safeCall(label, callback)
    local ok, result = pcall(callback)

    if not ok then
        incrementError()
        warnOnce(
            "ERROR_" .. tostring(label),
            label,
            "falhou:",
            tostring(result)
        )
    end

    return ok, result
end

local function safeFullName(instance)
    local ok, result = pcall(function()
        return instance:GetFullName()
    end)

    if ok then
        return result
    end

    return instance.Name
end

local function safeRead(instance, property)
    local ok, value = pcall(function()
        return instance[property]
    end)

    if not ok then
        return false, nil
    end

    return true, value
end

---------------------------------------------------------------------
-- CONTADORES
---------------------------------------------------------------------

local function countObject(instance, counterName)
    if not counterName then
        return
    end

    COUNTED[instance] = COUNTED[instance] or {}

    if COUNTED[instance][counterName] then
        return
    end

    COUNTED[instance][counterName] = true

    STATS[counterName] = (STATS[counterName] or 0) + 1
    STATS.Optimized += 1
end

---------------------------------------------------------------------
-- SAVE / SET
---------------------------------------------------------------------

local function saveOriginalProperty(instance, property)
    SAVED[instance] = SAVED[instance] or {}

    if SAVED[instance][property] ~= nil then
        return true
    end

    local ok, currentValue = safeRead(instance, property)

    if not ok then
        return false
    end

    -- Usamos uma pequena tabela para representar inclusive valores nil.
    SAVED[instance][property] = {
        value = currentValue,
    }

    return true
end

local function getSavedValue(instance, property)
    local state = SAVED[instance]

    if not state then
        return nil, false
    end

    local entry = state[property]

    if not entry then
        return nil, false
    end

    return entry.value, true
end

local function saveAndSet(instance, property, newValue, counterName)
    if not instance then
        return false
    end

    local saved = saveOriginalProperty(instance, property)

    if not saved then
        return false
    end

    local readOk, currentValue = safeRead(instance, property)

    if not readOk then
        return false
    end

    if currentValue == newValue then
        return false
    end

    local ok = pcall(function()
        instance[property] = newValue
    end)

    if not ok then
        incrementError()
        return false
    end

    countObject(instance, counterName)

    return true
end

local function restoreSavedProperty(instance, property)
    local state = SAVED[instance]

    if not state then
        return
    end

    local entry = state[property]

    if not entry then
        return
    end

    local ok = pcall(function()
        instance[property] = entry.value
    end)

    if ok then
        state[property] = nil
        STATS.Restored += 1

        if next(state) == nil then
            SAVED[instance] = nil
        end
    end
end

---------------------------------------------------------------------
-- AUDIO PROTECTION
---------------------------------------------------------------------

local function isAudioRelated(instance)
    if not instance then
        return false
    end

    if instance == SoundService then
        return true
    end

    if instance:IsA("Sound") or instance:IsA("SoundGroup") then
        return true
    end

    local okSoundService, underSoundService = pcall(function()
        return instance:IsDescendantOf(SoundService)
    end)

    if okSoundService and underSoundService then
        return true
    end

    -- ReplicatedStorage é somente consultado aqui.
    local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")

    if soundsFolder then
        local okReplicated, underReplicatedSounds = pcall(function()
            return instance == soundsFolder
                or instance:IsDescendantOf(soundsFolder)
        end)

        if okReplicated and underReplicatedSounds then
            return true
        end
    end

    -- Também protege coisas que estejam dentro de um Sound/SoundGroup.
    local current = instance.Parent

    while current do
        if current:IsA("Sound") or current:IsA("SoundGroup") then
            return true
        end

        current = current.Parent
    end

    return false
end

-- Função obrigatória de proteção.
local function isProtected(instance)
    if not instance then
        return true
    end

    if isAudioRelated(instance) then
        return CONFIG.PreserveSFX
    end

    return false
end

---------------------------------------------------------------------
-- PROTEÇÕES ESTRUTURAIS
---------------------------------------------------------------------

local function isEssentialInstance(instance)
    if not instance then
        return true
    end

    if instance == Workspace.CurrentCamera then
        return true
    end

    if instance == SoundService then
        return true
    end

    local character = LocalPlayer.Character

    if character then
        if instance == character then
            return true
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if instance == humanoid or instance == root or instance == head then
            return true
        end
    end

    return false
end

local function isForbiddenContainer(instance)
    if not instance then
        return true
    end

    -- Nunca alteramos ReplicatedStorage.
    local ok, result = pcall(function()
        return instance == ReplicatedStorage
            or instance:IsDescendantOf(ReplicatedStorage)
    end)

    return ok and result
end

---------------------------------------------------------------------
-- LOCAL CHARACTER HELPERS
---------------------------------------------------------------------

local function getLocalCharacter()
    return LocalPlayer.Character
end

local function getLocalRoot()
    local character = getLocalCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------------------------
-- POSITION / DISTANCE HELPERS
---------------------------------------------------------------------

local function positionFromObject(instance)
    if not instance then
        return nil
    end

    if instance:IsA("BasePart") then
        return instance.Position
    end

    if instance:IsA("Attachment") then
        return instance.WorldPosition
    end

    if instance:IsA("Model") then
        local ok, pivot = pcall(function()
            return instance:GetPivot()
        end)

        if ok then
            return pivot.Position
        end
    end

    return nil
end

local function getOriginalParentIfDetached(instance)
    if instance.Parent then
        return instance.Parent
    end

    local savedParent, exists = getSavedValue(instance, "Parent")

    if exists then
        return savedParent
    end

    return nil
end

local function findWorldPosition(instance)
    if not instance then
        return nil
    end

    -----------------------------------------------------------------
    -- GUI com Adornee
    -----------------------------------------------------------------

    if instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
        local ok, adornee = safeRead(instance, "Adornee")

        if ok and adornee then
            local position = positionFromObject(adornee)

            if position then
                return position
            end
        end
    end

    -----------------------------------------------------------------
    -- Busca por ancestry.
    -----------------------------------------------------------------

    local current = instance.Parent

    if not current then
        current = getOriginalParentIfDetached(instance)
    end

    while current do
        local position = positionFromObject(current)

        if position then
            return position
        end

        current = current.Parent
    end

    return nil
end

local function getDistanceFromPlayer(instance)
    local root = getLocalRoot()

    if not root then
        return nil
    end

    local objectPosition = findWorldPosition(instance)

    if not objectPosition then
        return nil
    end

    return (root.Position - objectPosition).Magnitude
end

---------------------------------------------------------------------
-- DISTANCE TRACKING
---------------------------------------------------------------------

local function trackDistanceObject(instance)
    DISTANCE_TRACKED[instance] = true
end

local function shouldHideByDistance(instance, distanceLimit, distantOnly)
    if not distantOnly then
        return true
    end

    if not CONFIG.LowerRenderDistance then
        return false
    end

    local distance = getDistanceFromPlayer(instance)

    -- Se ainda não temos personagem/posição, não escondemos.
    if distance == nil then
        return false
    end

    return distance > distanceLimit
end

---------------------------------------------------------------------
-- PARTICLES / TRANSIENT VISUAL EFFECTS
---------------------------------------------------------------------

local function optimizeParticle(instance)
    if CONFIG.KillParticles and instance:IsA("ParticleEmitter") then
        saveAndSet(instance, "Enabled", false, "Particles")
        return true
    end

    if CONFIG.KillBeams and instance:IsA("Beam") then
        saveAndSet(instance, "Enabled", false, "Beams")
        return true
    end

    if CONFIG.KillTrails and instance:IsA("Trail") then
        saveAndSet(instance, "Enabled", false, "Trails")
        return true
    end

    if CONFIG.KillSmoke and instance:IsA("Smoke") then
        saveAndSet(instance, "Enabled", false, "Smoke")
        return true
    end

    if CONFIG.KillFire and instance:IsA("Fire") then
        saveAndSet(instance, "Enabled", false, "Fire")
        return true
    end

    if CONFIG.KillSparkles and instance:IsA("Sparkles") then
        saveAndSet(instance, "Enabled", false, "Sparkles")
        return true
    end

    if CONFIG.KillExplosions and instance:IsA("Explosion") then
        -- Visible=false remove somente o visual.
        -- BlastRadius/BlastPressure NÃO são alterados para não mudar gameplay.
        saveAndSet(instance, "Visible", false, "Explosions")
        return true
    end

    return false
end

---------------------------------------------------------------------
-- TEXTURE / DECAL OPTIMIZATION
---------------------------------------------------------------------

local function optimizeDistanceTexture(instance)
    local eligible = false

    if CONFIG.KillDecals and instance:IsA("Decal") then
        eligible = true
    elseif CONFIG.KillTextures and instance:IsA("Texture") then
        eligible = true
    elseif CONFIG.KillTextures and instance:IsA("SurfaceAppearance") then
        eligible = true
    end

    if not eligible then
        return false
    end

    trackDistanceObject(instance)

    return true
end

local function updateDistanceTexture(instance)
    if instance:IsA("Decal") then
        if not CONFIG.KillDecals then
            restoreSavedProperty(instance, "Transparency")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.VisualCullDistance,
            CONFIG.DistantOnlyTextures
        )

        if hide then
            saveAndSet(instance, "Transparency", 1, "Decals")
        else
            restoreSavedProperty(instance, "Transparency")
        end

        return
    end

    if instance:IsA("Texture") then
        if not CONFIG.KillTextures then
            restoreSavedProperty(instance, "Transparency")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.VisualCullDistance,
            CONFIG.DistantOnlyTextures
        )

        if hide then
            saveAndSet(instance, "Transparency", 1, "Textures")
        else
            restoreSavedProperty(instance, "Transparency")
        end

        return
    end

    if instance:IsA("SurfaceAppearance") then
        if not CONFIG.KillTextures then
            restoreSavedProperty(instance, "Parent")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.VisualCullDistance,
            CONFIG.DistantOnlyTextures
        )

        if hide then
            -- A maioria dos mapas de SurfaceAppearance não pode ser alterada
            -- em runtime por scripts normais.
            --
            -- Em vez disso, removemos LOCALMENTE a SurfaceAppearance da
            -- hierarquia sem destruí-la, permitindo restore().
            if instance.Parent ~= nil then
                saveAndSet(
                    instance,
                    "Parent",
                    nil,
                    "SurfaceAppearances"
                )
            end
        else
            restoreSavedProperty(instance, "Parent")
        end

        return
    end
end

---------------------------------------------------------------------
-- 3D GUI / VIEWPORT OPTIMIZATION
---------------------------------------------------------------------

local function optimizeDistanceGui(instance)
    if CONFIG.KillBillboardGui and instance:IsA("BillboardGui") then
        trackDistanceObject(instance)
        return true
    end

    if CONFIG.KillSurfaceGui and instance:IsA("SurfaceGui") then
        trackDistanceObject(instance)
        return true
    end

    if CONFIG.KillViewportFrame and instance:IsA("ViewportFrame") then
        trackDistanceObject(instance)
        return true
    end

    return false
end

local function updateDistanceGui(instance)
    if instance:IsA("BillboardGui") then
        if not CONFIG.KillBillboardGui then
            restoreSavedProperty(instance, "Enabled")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.GuiCullDistance,
            CONFIG.DistantOnly3DGui
        )

        if hide then
            saveAndSet(instance, "Enabled", false, "BillboardGuis")
        else
            restoreSavedProperty(instance, "Enabled")
        end

        return
    end

    if instance:IsA("SurfaceGui") then
        if not CONFIG.KillSurfaceGui then
            restoreSavedProperty(instance, "Enabled")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.GuiCullDistance,
            CONFIG.DistantOnly3DGui
        )

        if hide then
            saveAndSet(instance, "Enabled", false, "SurfaceGuis")
        else
            restoreSavedProperty(instance, "Enabled")
        end

        return
    end

    if instance:IsA("ViewportFrame") then
        if not CONFIG.KillViewportFrame then
            restoreSavedProperty(instance, "Visible")
            return
        end

        local hide = shouldHideByDistance(
            instance,
            CONFIG.GuiCullDistance,
            CONFIG.DistantOnly3DGui
        )

        if hide then
            saveAndSet(instance, "Visible", false, "ViewportFrames")
        else
            restoreSavedProperty(instance, "Visible")
        end
    end
end

---------------------------------------------------------------------
-- LIGHTING / POST PROCESSING
---------------------------------------------------------------------

local function shouldDisablePostEffect(instance)
    if instance:IsA("BloomEffect") then
        return CONFIG.KillPostFX or CONFIG.KillBloom
    end

    if instance:IsA("BlurEffect") then
        return CONFIG.KillPostFX or CONFIG.KillBlur
    end

    if instance:IsA("DepthOfFieldEffect") then
        return CONFIG.KillPostFX or CONFIG.KillDOF
    end

    if instance:IsA("SunRaysEffect") then
        return CONFIG.KillPostFX or CONFIG.KillSunRays
    end

    if instance:IsA("ColorCorrectionEffect") then
        return CONFIG.KillPostFX or CONFIG.KillColorCorrection
    end

    return false
end

local function optimizePostEffect(instance)
    if not shouldDisablePostEffect(instance) then
        return false
    end

    saveAndSet(instance, "Enabled", false, "PostFX")

    return true
end

local function optimizeSky(instance)
    if not CONFIG.KillSkybox then
        return false
    end

    if not instance:IsA("Sky") then
        return false
    end

    -- Sky não possui Enabled.
    -- Desanexamos de Lighting sem Destroy().
    saveAndSet(instance, "Parent", nil, "Skies")

    return true
end

local function optimizeAtmosphere(instance)
    if not CONFIG.KillAtmosphere then
        return false
    end

    if not instance:IsA("Atmosphere") then
        return false
    end

    -- Atmosphere também não possui Enabled.
    saveAndSet(instance, "Parent", nil, "Atmospheres")

    return true
end

local function optimizeLightingProperties()
    if not RUNTIME.enabled then
        return
    end

    if CONFIG.KillShadows then
        saveAndSet(Lighting, "GlobalShadows", false)
        saveAndSet(Lighting, "ShadowSoftness", 0)
    end

    if CONFIG.KillFog then
        saveAndSet(Lighting, "FogStart", 1e6)
        saveAndSet(Lighting, "FogEnd", 1e6)
    end

    saveAndSet(
        Lighting,
        "Brightness",
        CONFIG.LightingBrightness
    )
end

---------------------------------------------------------------------
-- TERRAIN
---------------------------------------------------------------------

local function tryDisableTerrainDecoration()
    -- Terrain.Decoration atualmente não é Scriptable.
    -- Mantemos a tentativa em pcall apenas para compatibilidade futura
    -- e registramos o comportamento sem deixar o script quebrar.

    local ok = pcall(function()
        Terrain.Decoration = false
    end)

    if not ok then
        warnOnce(
            "TERRAIN_DECORATION",
            "Terrain.Decoration não pode ser alterado por LocalScript; configure-o no Studio."
        )
    end
end

local function optimizeTerrain()
    if not RUNTIME.enabled then
        return
    end

    if CONFIG.KillGrass or CONFIG.KillTerrainDetails then
        tryDisableTerrainDecoration()
    end

    if CONFIG.KillWaterWaves then
        saveAndSet(Terrain, "WaterWaveSize", 0)
        saveAndSet(Terrain, "WaterWaveSpeed", 0)
        saveAndSet(Terrain, "WaterReflectance", 0)
        saveAndSet(Terrain, "WaterTransparency", 1)
    end
end

---------------------------------------------------------------------
-- CAMERA
---------------------------------------------------------------------

local function optimizeCamera()
    if not RUNTIME.enabled then
        return
    end

    if not CONFIG.OptimizeCamera then
        return
    end

    local camera = Workspace.CurrentCamera

    if not camera then
        return
    end

    -- Não modificamos CameraSubject/CameraType.
    -- Isso poderia quebrar controle, espectador, veículos etc.
    saveAndSet(
        camera,
        "FieldOfView",
        CONFIG.CameraFieldOfView
    )

    -- PostEffects podem ser parented na Camera.
    for _, descendant in camera:GetDescendants() do
        safeCall("CameraPostFX", function()
            optimizePostEffect(descendant)
        end)
    end
end

---------------------------------------------------------------------
-- CORE GUI
---------------------------------------------------------------------

local CORE_GUI_CONFIG = {
    {
        Type = Enum.CoreGuiType.Chat,
        Disabled = function()
            return CONFIG.DisableCoreChat
        end,
    },

    {
        Type = Enum.CoreGuiType.PlayerList,
        Disabled = function()
            return CONFIG.DisableCorePlayerList
        end,
    },

    {
        Type = Enum.CoreGuiType.EmotesMenu,
        Disabled = function()
            return CONFIG.DisableCoreEmotes
        end,
    },

    {
        Type = Enum.CoreGuiType.Backpack,
        Disabled = function()
            return CONFIG.DisableCoreBackpack
        end,
    },
}

local function optimizeCoreGui()
    if not RUNTIME.enabled then
        return
    end

    for _, info in CORE_GUI_CONFIG do
        if info.Disabled() then
            local guiType = info.Type

            if SAVED_CORE_GUI[guiType] == nil then
                local ok, original = pcall(function()
                    return StarterGui:GetCoreGuiEnabled(guiType)
                end)

                if ok then
                    SAVED_CORE_GUI[guiType] = original
                end
            end

            local ok = pcall(function()
                StarterGui:SetCoreGuiEnabled(guiType, false)
            end)

            if ok then
                STATS.CoreGui += 1
            end
        end
    end
end

local function restoreCoreGui()
    for guiType, enabled in pairs(SAVED_CORE_GUI) do
        pcall(function()
            StarterGui:SetCoreGuiEnabled(guiType, enabled)
        end)
    end

    table.clear(SAVED_CORE_GUI)
end

---------------------------------------------------------------------
-- HUMANOID OPTIMIZATION
---------------------------------------------------------------------

local function setHumanoidStateOptimized(
    humanoid,
    stateType,
    disableState
)
    if not disableState then
        return
    end

    SAVED_HUMANOID_STATES[humanoid] =
        SAVED_HUMANOID_STATES[humanoid] or {}

    local stateMap = SAVED_HUMANOID_STATES[humanoid]

    if stateMap[stateType] == nil then
        local ok, current = pcall(function()
            return humanoid:GetStateEnabled(stateType)
        end)

        if ok then
            stateMap[stateType] = current
        end
    end

    local ok = pcall(function()
        humanoid:SetStateEnabled(stateType, false)
    end)

    if ok then
        STATS.HumanoidStates += 1
    end
end

local function optimizeLocalHumanoid()
    if not CONFIG.OptimizeHumanoid then
        return
    end

    local character = LocalPlayer.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    setHumanoidStateOptimized(
        humanoid,
        Enum.HumanoidStateType.Climbing,
        CONFIG.DisableHumanoidClimbing
    )

    setHumanoidStateOptimized(
        humanoid,
        Enum.HumanoidStateType.Swimming,
        CONFIG.DisableHumanoidSwimming
    )

    setHumanoidStateOptimized(
        humanoid,
        Enum.HumanoidStateType.Seated,
        CONFIG.DisableHumanoidSeated
    )

    setHumanoidStateOptimized(
        humanoid,
        Enum.HumanoidStateType.FallingDown,
        CONFIG.DisableHumanoidFallingDown
    )

    setHumanoidStateOptimized(
        humanoid,
        Enum.HumanoidStateType.Ragdoll,
        CONFIG.DisableHumanoidRagdoll
    )
end

local function restoreHumanoidStates()
    for humanoid, states in pairs(SAVED_HUMANOID_STATES) do
        for stateType, originalEnabled in pairs(states) do
            pcall(function()
                humanoid:SetStateEnabled(
                    stateType,
                    originalEnabled
                )
            end)
        end
    end

    table.clear(SAVED_HUMANOID_STATES)
end

---------------------------------------------------------------------
-- OTHER PLAYER ANIMATORS
---------------------------------------------------------------------

local function optimizeOtherPlayerAnimator(instance)
    if not CONFIG.DisableOtherPlayerAnimators then
        return
    end

    if not instance:IsA("Animator") then
        return
    end

    local character = instance:FindFirstAncestorOfClass("Model")

    if not character then
        return
    end

    if character == LocalPlayer.Character then
        return
    end

    local player = Players:GetPlayerFromCharacter(character)

    if not player or player == LocalPlayer then
        return
    end

    -- Animator não possui propriedade Enabled.
    -- Removemos LOCALMENTE da hierarquia e guardamos o Parent.
    saveAndSet(instance, "Parent", nil, "Animators")
end

---------------------------------------------------------------------
-- AUDIO OPTIONAL MUTING
---------------------------------------------------------------------

local AUDIO_KEYWORDS = {
    "music",
    "bgm",
    "ambient",
    "ambience",
    "menu",
    "interface",
    "ui",
}

local function nameLooksLikeMusicOrUI(instance)
    local lowerName = string.lower(instance.Name)

    for _, keyword in AUDIO_KEYWORDS do
        if string.find(lowerName, keyword, 1, true) then
            return true
        end
    end

    if instance:IsA("Sound") and instance.SoundGroup then
        local groupName = string.lower(instance.SoundGroup.Name)

        for _, keyword in AUDIO_KEYWORDS do
            if string.find(groupName, keyword, 1, true) then
                return true
            end
        end
    end

    return false
end

local function optimizeAudioInstance(instance)
    -- Regra máxima:
    -- PreserveSFX=true => áudio intocável.
    if CONFIG.PreserveSFX then
        return
    end

    if not CONFIG.KillMusicAndUISounds then
        return
    end

    if not isAudioRelated(instance) then
        return
    end

    if not nameLooksLikeMusicOrUI(instance) then
        return
    end

    if instance:IsA("SoundGroup") then
        saveAndSet(instance, "Volume", 0, "AudioMuted")
        return
    end

    if instance:IsA("Sound") then
        -- Volume=0 é muito mais fácil de restaurar corretamente
        -- do que pausar/despausar TimePosition arbitrariamente.
        saveAndSet(instance, "Volume", 0, "AudioMuted")
    end
end

local function scanAudio()
    if CONFIG.PreserveSFX then
        return
    end

    if not CONFIG.KillMusicAndUISounds then
        return
    end

    local roots = {
        SoundService,
        Workspace,
    }

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    if playerGui then
        table.insert(roots, playerGui)
    end

    for _, root in roots do
        for _, descendant in root:GetDescendants() do
            optimizeAudioInstance(descendant)
        end
    end
end

---------------------------------------------------------------------
-- MAIN INSTANCE OPTIMIZER
---------------------------------------------------------------------

local function optimizeInstance(instance)
    if not RUNTIME.enabled then
        return
    end

    if not instance then
        return
    end

    STATS.Scanned += 1

    if isForbiddenContainer(instance) then
        return
    end

    if isEssentialInstance(instance) then
        return
    end

    if isProtected(instance) then
        return
    end

    -----------------------------------------------------------------
    -- Partículas
    -----------------------------------------------------------------

    if optimizeParticle(instance) then
        return
    end

    -----------------------------------------------------------------
    -- Lighting / camera effects
    -----------------------------------------------------------------

    if optimizePostEffect(instance) then
        return
    end

    if optimizeSky(instance) then
        return
    end

    if optimizeAtmosphere(instance) then
        return
    end

    -----------------------------------------------------------------
    -- Texturas
    -----------------------------------------------------------------

    if optimizeDistanceTexture(instance) then
        return
    end

    -----------------------------------------------------------------
    -- GUI 3D
    -----------------------------------------------------------------

    if optimizeDistanceGui(instance) then
        return
    end

    -----------------------------------------------------------------
    -- Animator de outro player
    -----------------------------------------------------------------

    optimizeOtherPlayerAnimator(instance)

    -----------------------------------------------------------------
    -- Som opcional
    -----------------------------------------------------------------

    optimizeAudioInstance(instance)
end

---------------------------------------------------------------------
-- DISTANCE PASS
---------------------------------------------------------------------

local function updateDistanceObjects()
    if not RUNTIME.enabled then
        return
    end

    STATS.DistancePasses += 1

    local processed = 0

    for instance in pairs(DISTANCE_TRACKED) do
        processed += 1

        local ok = pcall(function()
            if instance:IsA("Decal")
                or instance:IsA("Texture")
                or instance:IsA("SurfaceAppearance")
            then
                updateDistanceTexture(instance)
            elseif instance:IsA("BillboardGui")
                or instance:IsA("SurfaceGui")
                or instance:IsA("ViewportFrame")
            then
                updateDistanceGui(instance)
            end
        end)

        if not ok then
            DISTANCE_TRACKED[instance] = nil
        end

        if processed % CONFIG.YieldEvery == 0 then
            task.wait()
        end
    end
end

---------------------------------------------------------------------
-- THROTTLE
--
-- Reutilizável para callbacks próprios.
--
-- Exemplo:
--
-- local sendPosition = throttle(function(position)
--     SomeRemote:FireServer(position)
-- end, 100)
--
-- Isso limita a função a 1 execução a cada 100ms.
--
-- Não intercepta RemoteEvents de scripts de terceiros.
---------------------------------------------------------------------

local function throttle(fn, milliseconds)
    local minimumInterval = milliseconds / 1000
    local previousTime = -math.huge

    return function(...)
        local currentTime = os.clock()

        if currentTime - previousTime < minimumInterval then
            return nil
        end

        previousTime = currentTime

        return fn(...)
    end
end

-- Evita warning de variável local não usada caso strict/linter reclame.
local _exampleThrottleReference = throttle

---------------------------------------------------------------------
-- NETWORK LIMITATIONS / LOG
---------------------------------------------------------------------

local function logNetworkCapabilities()
    local streamingEnabled = false

    pcall(function()
        streamingEnabled = Workspace.StreamingEnabled
    end)

    log(
        "Workspace.StreamingEnabled:",
        streamingEnabled
    )

    if streamingEnabled then
        log(
            "Streaming já está habilitado. O cliente não altera StreamingTargetRadius/StreamingEnabled."
        )
    else
        log(
            "Streaming está desabilitado. Ative no Studio se quiser reduzir conteúdo replicado/renderizado por distância."
        )
    end

    -- CharacterAutoLoads é somente observado.
    pcall(function()
        log(
            "Players.CharacterAutoLoads:",
            Players.CharacterAutoLoads,
            "(não alterado)"
        )
    end)

    log(
        "NetworkOwnership não é forçado pelo LocalScript. BasePart:SetNetworkOwner() deve ser decidido no servidor."
    )
end

---------------------------------------------------------------------
-- STAT READING
---------------------------------------------------------------------

local function getPingString()
    local result = "N/A"

    pcall(function()
        local network = StatsService:FindFirstChild("Network")

        if not network then
            return
        end

        local serverStats =
            network:FindFirstChild("ServerStatsItem")

        if not serverStats then
            return
        end

        local ping =
            serverStats:FindFirstChild("Data Ping")

        if ping then
            result = ping:GetValueString()
        end
    end)

    return result
end

local function getPerformanceStats()
    local fps = 0
    local receiveKbps = 0
    local sendKbps = 0
    local memoryMb = 0

    pcall(function()
        local frameTime = StatsService.FrameTime

        if frameTime > 0 then
            fps = 1 / frameTime
        end
    end)

    pcall(function()
        receiveKbps = StatsService.DataReceiveKbps
    end)

    pcall(function()
        sendKbps = StatsService.DataSendKbps
    end)

    pcall(function()
        memoryMb = StatsService:GetTotalMemoryUsageMb()
    end)

    return {
        FPS = fps,
        Ping = getPingString(),
        ReceiveKbps = receiveKbps,
        SendKbps = sendKbps,
        MemoryMb = memoryMb,
    }
end

local function printStats()
    local performance = getPerformanceStats()

    print(
        "\n"
            .. PREFIX
            .. " ==============================="
    )

    print(
        PREFIX,
        "Optimizer:",
        RUNTIME.enabled and "ON" or "OFF"
    )

    print(
        PREFIX,
        string.format(
            "FPS: %.1f | Ping: %s",
            performance.FPS,
            performance.Ping
        )
    )

    print(
        PREFIX,
        string.format(
            "Network RX: %.2f KB/s | TX: %.2f KB/s",
            performance.ReceiveKbps,
            performance.SendKbps
        )
    )

    print(
        PREFIX,
        string.format(
            "Memória total: %.1f MB",
            performance.MemoryMb
        )
    )

    print(
        PREFIX,
        "Scanned:",
        STATS.Scanned,
        "| Optimized:",
        STATS.Optimized,
        "| Restored:",
        STATS.Restored,
        "| Errors:",
        STATS.Errors
    )

    print(
        PREFIX,
        "Particles:",
        STATS.Particles,
        "| Beams:",
        STATS.Beams,
        "| Trails:",
        STATS.Trails,
        "| Explosions:",
        STATS.Explosions
    )

    print(
        PREFIX,
        "Decals:",
        STATS.Decals,
        "| Textures:",
        STATS.Textures,
        "| SurfaceAppearance:",
        STATS.SurfaceAppearances
    )

    print(
        PREFIX,
        "BillboardGui:",
        STATS.BillboardGuis,
        "| SurfaceGui:",
        STATS.SurfaceGuis,
        "| ViewportFrame:",
        STATS.ViewportFrames
    )

    print(
        PREFIX,
        "PostFX:",
        STATS.PostFX,
        "| Atmosphere:",
        STATS.Atmospheres,
        "| Sky:",
        STATS.Skies
    )

    print(
        PREFIX,
        "Distance passes:",
        STATS.DistancePasses,
        "| Dynamic objects:",
        STATS.DynamicObjects
    )

    print(
        PREFIX
            .. " ===============================\n"
    )
end

---------------------------------------------------------------------
-- RESTORE
---------------------------------------------------------------------

local function restore()
    RUNTIME.scanGeneration += 1

    -----------------------------------------------------------------
    -- Propriedades / parents.
    -----------------------------------------------------------------

    local instances = {}

    for instance in pairs(SAVED) do
        table.insert(instances, instance)
    end

    for index, instance in ipairs(instances) do
        local properties = SAVED[instance]

        if properties then
            -- Parent primeiro ajuda objetos SurfaceAppearance/Sky/Atmosphere
            -- que foram desanexados da hierarquia.
            if properties.Parent then
                restoreSavedProperty(instance, "Parent")
            end

            properties = SAVED[instance]

            if properties then
                local propertyNames = {}

                for property in pairs(properties) do
                    table.insert(propertyNames, property)
                end

                for _, property in ipairs(propertyNames) do
                    restoreSavedProperty(instance, property)
                end
            end
        end

        if index % CONFIG.YieldEvery == 0 then
            task.wait()
        end
    end

    -----------------------------------------------------------------
    -- CoreGui
    -----------------------------------------------------------------

    restoreCoreGui()

    -----------------------------------------------------------------
    -- Humanoid states
    -----------------------------------------------------------------

    restoreHumanoidStates()

    log("restore() concluído.")
end

---------------------------------------------------------------------
-- GLOBAL SETTINGS
---------------------------------------------------------------------

local function applyGlobalSettings()
    optimizeLightingProperties()
    optimizeTerrain()
    optimizeCamera()
    optimizeCoreGui()
    optimizeLocalHumanoid()

    -- Algumas chamadas de CoreGui podem falhar muito cedo no loading.
    task.delay(1, function()
        if RUNTIME.enabled then
            optimizeCoreGui()
        end
    end)
end

---------------------------------------------------------------------
-- INITIAL SCAN
---------------------------------------------------------------------

local function scanRoot(root, generation)
    local descendants = root:GetDescendants()

    for index, instance in ipairs(descendants) do
        if generation ~= RUNTIME.scanGeneration then
            return
        end

        if not RUNTIME.enabled then
            return
        end

        safeCall(
            "Optimize " .. instance.ClassName,
            function()
                optimizeInstance(instance)
            end
        )

        if index % CONFIG.YieldEvery == 0 then
            task.wait()
        end
    end
end

local function applyAll()
    if not RUNTIME.enabled then
        return
    end

    RUNTIME.scanGeneration += 1

    local generation = RUNTIME.scanGeneration

    applyGlobalSettings()

    -- coroutine.wrap foi utilizado intencionalmente para que o scan inicial
    -- não bloqueie o início do jogo.
    coroutine.wrap(function()
        log("Iniciando scan incremental...")

        scanRoot(Workspace, generation)

        if generation ~= RUNTIME.scanGeneration then
            return
        end

        scanRoot(Lighting, generation)

        if generation ~= RUNTIME.scanGeneration then
            return
        end

        local playerGui =
            LocalPlayer:FindFirstChildOfClass("PlayerGui")

        if playerGui then
            scanRoot(playerGui, generation)
        end

        if generation ~= RUNTIME.scanGeneration then
            return
        end

        scanAudio()

        updateDistanceObjects()

        log(
            "Scan inicial concluído.",
            "Scanned:",
            STATS.Scanned,
            "Optimized:",
            STATS.Optimized
        )

        if CONFIG.LogStats then
            printStats()
        end
    end)()
end

---------------------------------------------------------------------
-- DYNAMIC OBJECTS
--
-- Essencial para StreamingEnabled e jogos que instanciam efeitos
-- durante a partida.
---------------------------------------------------------------------

Workspace.DescendantAdded:Connect(function(instance)
    if not RUNTIME.enabled then
        return
    end

    STATS.DynamicObjects += 1

    task.defer(function()
        safeCall("Workspace.DescendantAdded", function()
            optimizeInstance(instance)
        end)
    end)
end)

Lighting.DescendantAdded:Connect(function(instance)
    if not RUNTIME.enabled then
        return
    end

    task.defer(function()
        safeCall("Lighting.DescendantAdded", function()
            optimizeInstance(instance)
        end)
    end)
end)

---------------------------------------------------------------------
-- CAMERA CHANGES
---------------------------------------------------------------------

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if not RUNTIME.enabled then
        return
    end

    task.defer(function()
        optimizeCamera()
    end)
end)

---------------------------------------------------------------------
-- CHARACTER RESPAWN
---------------------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function(_character)
    if not RUNTIME.enabled then
        return
    end

    task.delay(0.5, function()
        if not RUNTIME.enabled then
            return
        end

        optimizeLocalHumanoid()
        updateDistanceObjects()
    end)
end)

---------------------------------------------------------------------
-- PLAYER GUI DYNAMIC CONTENT
---------------------------------------------------------------------

local function hookPlayerGui()
    local playerGui =
        LocalPlayer:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return
    end

    playerGui.DescendantAdded:Connect(function(instance)
        if not RUNTIME.enabled then
            return
        end

        task.defer(function()
            safeCall("PlayerGui.DescendantAdded", function()
                optimizeInstance(instance)
            end)
        end)
    end)
end

task.defer(hookPlayerGui)

---------------------------------------------------------------------
-- PERIODIC DISTANCE LOOP
--
-- Não usa RenderStepped/Heartbeat.
-- Isso evita criar processamento a cada frame.
---------------------------------------------------------------------

task.spawn(function()
    while true do
        task.wait(CONFIG.DistanceScanInterval)

        if RUNTIME.enabled then
            safeCall("DistanceScan", function()
                updateDistanceObjects()
            end)
        end
    end
end)

---------------------------------------------------------------------
-- PERIODIC STATS
---------------------------------------------------------------------

task.spawn(function()
    while true do
        task.wait(CONFIG.StatsInterval)

        if CONFIG.LogStats then
            safeCall("StatsLog", function()
                printStats()
            end)
        end
    end
end)

---------------------------------------------------------------------
-- INTERNAL CLEANUP
--
-- Roblox Debris NÃO possui uma API pública tipo Debris:Clear().
--
-- Portanto não apagamos objetos arbitrários criados por outros sistemas.
-- Fazemos apenas limpeza periódica das referências internas do optimizer.
---------------------------------------------------------------------

local function cleanupOptimizerState()
    local removeTracked = {}

    for instance in pairs(DISTANCE_TRACKED) do
        local valid = pcall(function()
            local _ = instance.ClassName
        end)

        if not valid then
            table.insert(removeTracked, instance)
        end
    end

    for _, instance in ipairs(removeTracked) do
        DISTANCE_TRACKED[instance] = nil
        COUNTED[instance] = nil
        SAVED[instance] = nil
    end
end

task.spawn(function()
    while true do
        task.wait(CONFIG.CleanupInterval)

        safeCall("OptimizerCleanup", function()
            cleanupOptimizerState()
        end)
    end
end)

---------------------------------------------------------------------
-- HOTKEYS
---------------------------------------------------------------------

local function enableOptimizer()
    if RUNTIME.enabled then
        return
    end

    RUNTIME.enabled = true

    log("Optimizer ENABLED.")

    applyAll()
end

local function disableOptimizer()
    if not RUNTIME.enabled then
        return
    end

    RUNTIME.enabled = false

    log("Optimizer DISABLED. Restaurando alterações...")

    restore()
end

local function toggleOptimizer()
    if RUNTIME.enabled then
        disableOptimizer()
    else
        enableOptimizer()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == CONFIG.ToggleKey then
        toggleOptimizer()
        return
    end

    if input.KeyCode == CONFIG.StatsKey then
        printStats()
    end
end)

---------------------------------------------------------------------
-- STARTUP INFORMATION
---------------------------------------------------------------------

log("===========================================")
log("Optimizer.client.luau iniciado.")
log("F8 = Toggle optimizer")
log("F9 = Performance stats")
log("PreserveSFX:", CONFIG.PreserveSFX)
log("===========================================")

logNetworkCapabilities()

---------------------------------------------------------------------
-- INITIAL APPLICATION
---------------------------------------------------------------------

if CONFIG.Enabled then
    applyAll()
end
