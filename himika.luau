local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local CONFIG = {
	REMOVE_TEXTURES = true,
	REMOVE_PBR = true,
	REMOVE_PARTICLES = true,
	REMOVE_BEAMS = true,
	REMOVE_TRAILS = true,
	REMOVE_FIRE_SMOKE = true,
	REDUCE_LIGHTS = true,
	REMOVE_POST_EFFECTS = true,
	REMOVE_ATMOSPHERE = true,
	REMOVE_SKY = false,
	REMOVE_CLOUDS = true,
	REMOVE_HIGHLIGHTS = true,
	LOW_MATERIALS = true,
	LIGHT_BRIGHTNESS = 0.55,
	LIGHT_RANGE = 0.75,
	MAIN_LIGHT_BRIGHTNESS = 0.85,
	MAIN_LIGHT_RANGE = 0.9,
	BATCH_SIZE = 100,
}

pcall(function()
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.15
end)

local Terrain = Workspace:FindFirstChildOfClass("Terrain")

if Terrain then
	pcall(function()
		Terrain.WaterReflectance = 0
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
	end)
end

local function destroyObject(object)
	if object and object.Parent then
		pcall(function()
			object:Destroy()
		end)
	end
end

local function isCharacterObject(object)
	local current = object

	while current do
		if current:IsA("Accessory") then
			return true
		end

		if current:IsA("Tool") then
			return true
		end

		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return true
		end

		current = current.Parent
	end

	return false
end

local function isPlayerUI(object)
	local current = object

	while current do
		if current:IsA("PlayerGui") then
			return true
		end

		if current:IsA("ScreenGui") then
			return true
		end

		current = current.Parent
	end

	return false
end

local function isProtectedObject(object)
	if isPlayerUI(object) then
		return true
	end

	if isCharacterObject(object) then
		return true
	end

	if object:IsA("Tool") then
		return true
	end

	if object:IsA("Sound") then
		return true
	end

	if object:IsA("SoundGroup") then
		return true
	end

	if object:IsA("ProximityPrompt") then
		return true
	end

	if object:IsA("ClickDetector") then
		return true
	end

	if object:IsA("BillboardGui") then
		return true
	end

	if object:IsA("SurfaceGui") then
		return true
	end

	if object:IsA("ViewportFrame") then
		return true
	end

	if object:IsA("VideoFrame") then
		return true
	end

	return false
end

local function optimize(object)
	if not object then
		return false
	end

	if isProtectedObject(object) then
		return false
	end

	if CONFIG.REMOVE_PARTICLES and object:IsA("ParticleEmitter") then
		pcall(function()
			object.Enabled = false
			object:Clear()
		end)

		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_BEAMS and object:IsA("Beam") then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_TRAILS and object:IsA("Trail") then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_FIRE_SMOKE and (
		object:IsA("Fire")
		or object:IsA("Smoke")
		or object:IsA("Sparkles")
	) then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_TEXTURES and (
		object:IsA("Decal")
		or object:IsA("Texture")
	) then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_PBR and object:IsA("SurfaceAppearance") then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_POST_EFFECTS and object:IsA("PostEffect") then
		pcall(function()
			object.Enabled = false
		end)

		destroyObject(object)
		return true
	end

	if CONFIG.REDUCE_LIGHTS and object:IsA("Light") then
		pcall(function()
			object.Enabled = true
			object.Shadows = false

			if object:GetAttribute("OriginalBrightness") == nil then
				object:SetAttribute("OriginalBrightness", object.Brightness)
			end

			if object:GetAttribute("OriginalRange") == nil then
				object:SetAttribute("OriginalRange", object.Range)
			end

			local brightness = object:GetAttribute("OriginalBrightness")
			local range = object:GetAttribute("OriginalRange")

			if object:GetAttribute("MainLight") == true then
				object.Brightness = brightness * CONFIG.MAIN_LIGHT_BRIGHTNESS
				object.Range = range * CONFIG.MAIN_LIGHT_RANGE
			else
				object.Brightness = brightness * CONFIG.LIGHT_BRIGHTNESS
				object.Range = range * CONFIG.LIGHT_RANGE
			end
		end)

		return false
	end

	if CONFIG.REMOVE_ATMOSPHERE and object:IsA("Atmosphere") then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_SKY and object:IsA("Sky") then
		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_CLOUDS and object:IsA("Clouds") then
		pcall(function()
			object.Enabled = false
		end)

		destroyObject(object)
		return true
	end

	if CONFIG.REMOVE_HIGHLIGHTS and object:IsA("Highlight") then
		destroyObject(object)
		return true
	end

	if object:IsA("Explosion") then
		pcall(function()
			object.Visible = false
		end)

		return false
	end

	if object:IsA("MeshPart") then
		pcall(function()
			if CONFIG.REMOVE_TEXTURES then
				object.TextureID = ""
			end

			object.CastShadow = false
			object.Reflectance = 0

			if CONFIG.LOW_MATERIALS then
				object.MaterialVariant = ""
				object.Material = Enum.Material.SmoothPlastic
			end
		end)

		return false
	end

	if object:IsA("SpecialMesh") then
		if CONFIG.REMOVE_TEXTURES then
			pcall(function()
				object.TextureId = ""
			end)
		end

		return false
	end

	if object:IsA("BasePart") and not object:IsA("Terrain") then
		pcall(function()
			object.CastShadow = false
			object.Reflectance = 0

			if CONFIG.LOW_MATERIALS then
				object.MaterialVariant = ""
				object.Material = Enum.Material.SmoothPlastic
			end
		end)
	end

	if object:IsA("LocalScript")
		and object:GetAttribute("CosmeticOnly") == true then

		pcall(function()
			object.Enabled = false
		end)
	end

	return false
end

local queue = {}
local head = 1
local tail = 0

local queued = setmetatable({}, {
	__mode = "k"
})

local function addToQueue(object)
	if not object then
		return
	end

	if queued[object] then
		return
	end

	queued[object] = true

	tail += 1
	queue[tail] = object
end

task.spawn(function()
	while true do
		local processed = 0

		while head <= tail and processed < CONFIG.BATCH_SIZE do
			local object = queue[head]

			queue[head] = nil

			head += 1
			processed += 1

			if object then
				queued[object] = nil

				local alive =
					object.Parent ~= nil
					or object == Workspace
					or object == Lighting

				if alive then
					local destroyed = optimize(object)

					if not destroyed then
						local success, children = pcall(function()
							return object:GetChildren()
						end)

						if success then
							for _, child in ipairs(children) do
								addToQueue(child)
							end
						end
					end
				end
			end
		end

		if head > tail then
			head = 1
			tail = 0
			task.wait(0.05)
		else
			task.wait()
		end
	end
end)

addToQueue(Workspace)
addToQueue(Lighting)

Workspace.DescendantAdded:Connect(function(object)
	addToQueue(object)
end)

Lighting.DescendantAdded:Connect(function(object)
	addToQueue(object)
end)
