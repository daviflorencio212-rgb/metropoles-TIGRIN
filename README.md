--[[
	TIGRINHO - VERSÃO FINAL
	- ESP sem piscar
	- Menu moderno
	- Revistar com Username + revisar_function
	- Silent Aim, Noclip, Speed, Jump, Fullbright
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====================== CONFIG ======================
local CONFIG = {
	Enabled = false,
	Aimbot = false,
	SilentAim = false,
	ShowFOV = false,
	FOV = 180,
	MaxDistance = 10000000,
	ESPMaxDistance = 500,
	Smoothness = 0.12,
	Wallbang = false,
	Revistar = false,
	ShowESP = false,
	ShowBox2D = false,
	ShowHighlight = true,
	ShowName = true,
	ShowDistance = true,
	ShowTool = true,
	ShowInventory = true,
	ESPColor = Color3.fromRGB(255, 140, 30),
	Noclip = false,
	Speed = false,
	SpeedValue = 24,
	Jump = false,
	JumpValue = 60,
	Fullbright = false,
	QuitOnDeath = false,
	PriorityParts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
}

local isHoldingAim = false
local menuOpen = true
local dragging = false
local dragStart, startPos
local noclipConnection = nil
local espCache = {} -- evita piscar

local espFolder = Instance.new("Folder")
espFolder.Name = "TigrinhoESP"
espFolder.Parent = Workspace

local box2DFolder = Instance.new("Folder")
box2DFolder.Name = "TigrinhoBox2D"
box2DFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== TEMA MODERNO ======================
local Theme = {
	Background = Color3.fromRGB(18, 16, 14),
	Sidebar = Color3.fromRGB(28, 22, 16),
	Panel = Color3.fromRGB(32, 26, 20),
	Card = Color3.fromRGB(42, 34, 26),
	Accent = Color3.fromRGB(255, 145, 40),
	AccentDark = Color3.fromRGB(220, 110, 20),
	Text = Color3.fromRGB(250, 245, 235),
	TextDim = Color3.fromRGB(170, 155, 135),
	Success = Color3.fromRGB(50, 200, 120),
	Danger = Color3.fromRGB(220, 70, 70),
}

-- ====================== UI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Tigrinho"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FOV
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, CONFIG.FOV * 2, 0, CONFIG.FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Theme.Accent
fovStroke.Thickness = 1.4
fovStroke.Transparency = 0.4

-- Menu
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 520)
main.Position = UDim2.new(0.5, -270, 0.5, -260)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(60, 45, 30)
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.3

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, 0)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 18)

local sideFix = Instance.new("Frame")
sideFix.Size = UDim2.new(0, 24, 1, 0)
sideFix.Position = UDim2.new(1, -24, 0, 0)
sideFix.BackgroundColor3 = Theme.Sidebar
sideFix.BorderSizePixel = 0
sideFix.Parent = sidebar

local dragArea = Instance.new("Frame")
dragArea.Size = UDim2.new(1, 0, 0, 58)
dragArea.BackgroundTransparency = 1
dragArea.Parent = sidebar

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 1, 0)
logo.BackgroundTransparency = 1
logo.Text = "🐯 TIGRINHO"
logo.TextColor3 = Theme.Accent
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 17
logo.Parent = dragArea

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -150, 1, -24)
content.Position = UDim2.new(0, 148, 0, 12)
content.BackgroundColor3 = Theme.Panel
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Theme.Accent
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 14)

local contentPad = Instance.new("UIPadding", content)
contentPad.PaddingTop = UDim.new(0, 8)
contentPad.PaddingBottom = UDim.new(0, 12)
contentPad.PaddingLeft = UDim.new(0, 4)
contentPad.PaddingRight = UDim.new(0, 4)

local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 30, 0, 30)
miniBtn.Position = UDim2.new(1, -40, 0, 10)
miniBtn.BackgroundColor3 = Theme.AccentDark
miniBtn.Text = "–"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.Parent = main
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 10)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 18, 0.5, -25)
openBtn.BackgroundColor3 = Theme.Accent
openBtn.Text = "🐯"
openBtn.TextSize = 24
openBtn.Visible = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- ====================== BOTÃO FLUTUANTE REVISTAR ======================
local revistarBtn = Instance.new("TextButton")
revistarBtn.Name = "RevistarFloat"
revistarBtn.Size = UDim2.new(0, 120, 0, 36)
revistarBtn.Position = UDim2.new(0, 14, 0, 14)
revistarBtn.BackgroundColor3 = Theme.Accent
revistarBtn.Text = "🐯 REVISTAR"
revistarBtn.TextColor3 = Color3.new(1,1,1)
revistarBtn.Font = Enum.Font.GothamBold
revistarBtn.TextSize = 13
revistarBtn.Parent = screenGui
Instance.new("UICorner", revistarBtn).CornerRadius = UDim.new(0, 12)

local revStroke = Instance.new("UIStroke", revistarBtn)
revStroke.Color = Color3.fromRGB(255, 200, 120)
revStroke.Thickness = 1.3

local draggingRev = false
local dragStartRev, startPosRev

revistarBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingRev = true
		dragStartRev = input.Position
		startPosRev = revistarBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingRev and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartRev
		revistarBtn.Position = UDim2.new(startPosRev.X.Scale, startPosRev.X.Offset + delta.X, startPosRev.Y.Scale, startPosRev.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingRev = false
	end
end)

-- ====================== ABAS ======================
local tabButtons = {}
local function createTabButton(name, icon, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -18, 0, 38)
	btn.Position = UDim2.new(0, 9, 0, 70 + (order-1)*48)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = sidebar

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -8, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = icon .. "  " .. name
	label.TextColor3 = Theme.TextDim
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local ind = Instance.new("Frame")
	ind.Size = UDim2.new(0, 3, 0, 20)
	ind.Position = UDim2.new(0, 0, 0.5, -10)
	ind.BackgroundColor3 = Theme.Accent
	ind.Visible = false
	ind.Parent = btn
	Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

	tabButtons[name] = {Button = btn, Label = label, Indicator = ind}
end

createTabButton("Combate", "⚔", 1)
createTabButton("Visual", "👁", 2)
createTabButton("Player", "🏃", 3)
createTabButton("Configs", "⚙", 4)

-- ====================== HELPERS UI ======================
local function createSection(parent, text, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -24, 0, 20)
	l.Position = UDim2.new(0, 12, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Theme.Accent
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return y + 22
end

local function createToggle(parent, text, y, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -24, 0, 34)
	frame.Position = UDim2.new(0, 12, 0, y)
	frame.BackgroundColor3 = Theme.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 20)
	btn.Position = UDim2.new(1, -50, 0.5, -10)
	btn.BackgroundColor3 = default and Theme.Success or Theme.Danger
	btn.Text = ""
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 14, 0, 14)
	circle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	circle.BackgroundColor3 = Color3.new(1,1,1)
	circle.BorderSizePixel = 0
	circle.Parent = btn
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Success or Theme.Danger}):Play()
		TweenService:Create(circle, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
		callback(state)
	end)
	return y + 40
end

local function createSlider(parent, text, y, default, min, max, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -24, 0, 48)
	frame.Position = UDim2.new(0, 12, 0, y)
	frame.BackgroundColor3 = Theme.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 16)
	label.Position = UDim2.new(0, 12, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.35, -12, 0, 16)
	valueLabel.Position = UDim2.new(0.65, 0, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -24, 0, 6)
	barBg.Position = UDim2.new(0, 12, 0, 30)
	barBg.BackgroundColor3 = Color3.fromRGB(55, 45, 35)
	barBg.BorderSizePixel = 0
	barBg.Parent = frame
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(math.clamp((default-min)/(max-min), 0, 1), 0, 1, 0)
	bar.BackgroundColor3 = Theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = barBg
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local sliding = false
	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
			local value = math.floor(min + (max - min) * rel)
			bar.Size = UDim2.new(rel, 0, 1, 0)
			valueLabel.Text = tostring(value)
			callback(value)
		end
	end)
	return y + 54
end

local function createButton(parent, text, y, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -24, 0, 34)
	btn.Position = UDim2.new(0, 12, 0, y)
	btn.BackgroundColor3 = Theme.AccentDark
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	btn.MouseButton1Click:Connect(callback)
	return y + 42
end

-- ====================== FUNÇÕES ======================
local function isValid(char)
	if not char or char == LocalPlayer.Character then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return Players:GetPlayerFromCharacter(char) ~= nil
end

local function getPart(char)
	for _, n in ipairs(CONFIG.PriorityParts) do
		local p = char:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	return char:FindFirstChild("HumanoidRootPart")
end

local function getScreenDist(pos)
	local sp, onScreen = Camera:WorldToViewportPoint(pos)
	if not onScreen or sp.Z < 0 then return math.huge end
	local c = Camera.ViewportSize / 2
	return (Vector2.new(sp.X, sp.Y) - c).Magnitude
end

local function getPlayerDentroDoFOV(aceitarMorto)
	local melhor, menor = nil, CONFIG.FOV
	local centro = Camera.ViewportSize / 2

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local char = plr.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
			if head and hum then
				if not aceitarMorto and hum.Health <= 0 then continue end
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen and pos.Z > 0 then
					local dist = (Vector2.new(pos.X, pos.Y) - centro).Magnitude
					if dist < menor then
						menor = dist
						melhor = plr
					end
				end
			end
		end
	end
	return melhor
end

local function fazerRevistar()
	if not CONFIG.Revistar then
		StarterGui:SetCore("SendNotification", {Title = "Tigrinho", Text = "Revistar desativado", Duration = 2})
		return
	end

	local target = getPlayerDentroDoFOV(true)
	if not target then
		StarterGui:SetCore("SendNotification", {Title = "Tigrinho", Text = "Ninguém no FOV", Duration = 2})
		return
	end

	local nome = target.Name -- Username

	local cmd = "/revistar " .. nome
	pcall(function()
		local channels = TextChatService:FindFirstChild("TextChannels")
		if channels then
			local general = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General")
			if general then general:SendAsync(cmd) end
		end
	end)
	pcall(function() LocalPlayer:Chat(cmd) end)

	local remote
	pcall(function()
		remote = ReplicatedStorage.shared.Eventos.revisar_function
	end)

	if remote and remote:IsA("RemoteFunction") then
		pcall(function() remote:InvokeServer(target) end)
		pcall(function() remote:InvokeServer(target.Name) end)
		pcall(function() remote:InvokeServer(target.Character) end)
		pcall(function() remote:InvokeServer() end)
	end

	StarterGui:SetCore("SendNotification", {Title = "Tigrinho", Text = "Revistando: " .. nome, Duration = 3})
end

revistarBtn.MouseButton1Click:Connect(fazerRevistar)

local function setNoclip(state)
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	local char = LocalPlayer.Character
	if not char then return end
	if state then
		noclipConnection = RunService.Stepped:Connect(function()
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
		end
	end
end

local function applySpeedJump()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if CONFIG.Speed then hum.WalkSpeed = CONFIG.SpeedValue else hum.WalkSpeed = 16 end
	if CONFIG.Jump then hum.JumpPower = CONFIG.JumpValue else hum.JumpPower = 50 end
end

local function setFullbright(state)
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end

-- ====================== ESP SEM PISCAR ======================
local function clearESPForPlayer(userId)
	if espCache[userId] then
		for _, obj in pairs(espCache[userId]) do
			if obj and obj.Parent then obj:Destroy() end
		end
		espCache[userId] = nil
	end
end

local function clearAllESP()
	for userId in pairs(espCache) do
		clearESPForPlayer(userId)
	end
	box2DFolder:ClearAllChildren()
end

local function updatePlayerESP(plr)
	local char = plr.Character
	if not char then
		clearESPForPlayer(plr.UserId)
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local meuRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root or not hum or not meuRoot then
		clearESPForPlayer(plr.UserId)
		return
	end

	local dist = (root.Position - meuRoot.Position).Magnitude
	if dist > CONFIG.ESPMaxDistance or not CONFIG.ShowESP or not CONFIG.Enabled then
		clearESPForPlayer(plr.UserId)
		return
	end

	if not espCache[plr.UserId] then
		espCache[plr.UserId] = {}
	end
	local cache = espCache[plr.UserId]

	-- Highlight
	if CONFIG.ShowHighlight and hum.Health > 0 then
		if not cache.highlight or not cache.highlight.Parent then
			local hl = Instance.new("Highlight")
			hl.Adornee = char
			hl.FillColor = CONFIG.ESPColor
			hl.OutlineColor = Color3.new(1,1,1)
			hl.FillTransparency = 0.7
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = espFolder
			cache.highlight = hl
		else
			cache.highlight.FillColor = CONFIG.ESPColor
			cache.highlight.Adornee = char
		end
	elseif cache.highlight then
		cache.highlight:Destroy()
		cache.highlight = nil
	end

	-- Info (Nome / Distância / Tool)
	if (CONFIG.ShowName or CONFIG.ShowDistance or CONFIG.ShowTool) and hum.Health > 0 and head then
		if not cache.info or not cache.info.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = head
			bb.Size = UDim2.new(0, 160, 0, 48)
			bb.StudsOffset = Vector3.new(0, 2.5, 0)
			bb.AlwaysOnTop = true
			bb.Parent = espFolder

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = CONFIG.ESPColor
			label.Font = Enum.Font.GothamBold
			label.TextSize = 11
			label.TextStrokeTransparency = 0.4
			label.Parent = bb

			cache.info = bb
			cache.infoLabel = label
		end

		local text = ""
		if CONFIG.ShowName then text = text .. (plr.DisplayName ~= "" and plr.DisplayName or plr.Name) .. "\n" end
		if CONFIG.ShowDistance then text = text .. math.floor(dist) .. "m\n" end
		if CONFIG.ShowTool then
			local tool = char:FindFirstChildOfClass("Tool")
			text = text .. (tool and ("[" .. tool.Name .. "]") or "[Nada]")
		end
		cache.infoLabel.Text = text
		cache.infoLabel.TextColor3 = CONFIG.ESPColor
		cache.info.Adornee = head
	elseif cache.info then
		cache.info:Destroy()
		cache.info = nil
		cache.infoLabel = nil
	end

	-- Inventário nos pés
	if CONFIG.ShowInventory then
		if not cache.inv or not cache.inv.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = root
			bb.Size = UDim2.new(0, 140, 0, 60)
			bb.StudsOffset = Vector3.new(0, -3.2, 0)
			bb.AlwaysOnTop = true
			bb.Parent = espFolder

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.fromRGB(15, 12, 10)
			frame.BackgroundTransparency = 0.3
			frame.BorderSizePixel = 0
			frame.Parent = bb
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, 0, 0, 14)
			title.BackgroundTransparency = 1
			title.Text = "Inventário"
			title.TextColor3 = Theme.Accent
			title.Font = Enum.Font.GothamBold
			title.TextSize = 10
			title.Parent = frame

			local list = Instance.new("TextLabel")
			list.Size = UDim2.new(1, -6, 1, -16)
			list.Position = UDim2.new(0, 3, 0, 14)
			list.BackgroundTransparency = 1
			list.TextColor3 = Color3.fromRGB(230, 230, 230)
			list.Font = Enum.Font.Gotham
			list.TextSize = 10
			list.TextXAlignment = Enum.TextXAlignment.Left
			list.TextYAlignment = Enum.TextYAlignment.Top
			list.Parent = frame

			cache.inv = bb
			cache.invList = list
		end

		local items = {}
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then table.insert(items, "• " .. tool.Name) end
		for _, obj in ipairs(char:GetChildren()) do
			if obj:IsA("Tool") and obj ~= tool then table.insert(items, "• " .. obj.Name) end
		end
		local bp = plr:FindFirstChild("Backpack")
		if bp then
			for _, obj in ipairs(bp:GetChildren()) do
				if obj:IsA("Tool") then table.insert(items, "• " .. obj.Name) end
			end
		end
		if #items == 0 then table.insert(items, "• Vazio") end
		cache.invList.Text = table.concat(items, "\n")
		cache.inv.Adornee = root
	elseif cache.inv then
		cache.inv:Destroy()
		cache.inv = nil
		cache.invList = nil
	end
end

-- ====================== ABAS ======================
local function clearContent()
	for _, c in ipairs(content:GetChildren()) do
		if not c:IsA("UICorner") and not c:IsA("UIPadding") then c:Destroy() end
	end
end

local function openTab(name)
	clearContent()
	for n, d in pairs(tabButtons) do
		d.Label.TextColor3 = (n == name) and Theme.Text or Theme.TextDim
		d.Indicator.Visible = (n == name)
	end

	local y = 6

	if name == "Combate" then
		y = createSection(content, "AIMBOT", y)
		y = createToggle(content, "Aimbot Ativo", y, CONFIG.Aimbot, function(v) CONFIG.Aimbot = v end)
		y = createToggle(content, "Silent Aim (cabeça)", y, CONFIG.SilentAim, function(v) CONFIG.SilentAim = v end)
		y = createToggle(content, "Mostrar FOV", y, CONFIG.ShowFOV, function(v) CONFIG.ShowFOV = v fovCircle.Visible = v end)
		y = createSlider(content, "Tamanho FOV", y, CONFIG.FOV, 50, 600, function(v) CONFIG.FOV = v fovCircle.Size = UDim2.new(0, v*2, 0, v*2) end)
		y = createSlider(content, "Suavidade", y, math.floor(CONFIG.Smoothness*100), 1, 40, function(v) CONFIG.Smoothness = v/100 end)
		y = createToggle(content, "Atrás das paredes", y, CONFIG.Wallbang, function(v) CONFIG.Wallbang = v end)

		y = createSection(content, "REVISTAR", y + 4)
		y = createToggle(content, "Revistar Ativo", y, CONFIG.Revistar, function(v) CONFIG.Revistar = v end)
		y = createButton(content, "REVISTAR AGORA", y, fazerRevistar)

	elseif name == "Visual" then
		y = createSection(content, "ESP", y)
		y = createToggle(content, "ESP Ativo", y, CONFIG.ShowESP, function(v) CONFIG.ShowESP = v if not v then clearAllESP() end end)
		y = createSlider(content, "Distância ESP", y, CONFIG.ESPMaxDistance, 50, 2000, function(v) CONFIG.ESPMaxDistance = v end)
		y = createToggle(content, "Highlight", y, CONFIG.ShowHighlight, function(v) CONFIG.ShowHighlight = v end)
		y = createToggle(content, "Nome", y, CONFIG.ShowName, function(v) CONFIG.ShowName = v end)
		y = createToggle(content, "Distância", y, CONFIG.ShowDistance, function(v) CONFIG.ShowDistance = v end)
		y = createToggle(content, "Item na mão", y, CONFIG.ShowTool, function(v) CONFIG.ShowTool = v end)
		y = createToggle(content, "Inventário nos pés", y, CONFIG.ShowInventory, function(v) CONFIG.ShowInventory = v end)

		y = createSection(content, "COR", y + 4)
		local colorFrame = Instance.new("Frame")
		colorFrame.Size = UDim2.new(1, -24, 0, 32)
		colorFrame.Position = UDim2.new(0, 12, 0, y)
		colorFrame.BackgroundTransparency = 1
		colorFrame.Parent = content
		local list = Instance.new("UIListLayout")
		list.FillDirection = Enum.FillDirection.Horizontal
		list.Padding = UDim.new(0, 5)
		list.Parent = colorFrame
		for _, cor in ipairs({
			Color3.fromRGB(255,140,30), Color3.fromRGB(0,170,255), Color3.fromRGB(0,255,140),
			Color3.fromRGB(255,55,55), Color3.fromRGB(170,70,255), Color3.fromRGB(255,220,40),
			Color3.fromRGB(255,255,255), Color3.fromRGB(255,70,180)
		}) do
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 24, 0, 24)
			b.BackgroundColor3 = cor
			b.Text = ""
			b.Parent = colorFrame
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function() CONFIG.ESPColor = cor end)
		end

	elseif name == "Player" then
		y = createSection(content, "MOVIMENTO", y)
		y = createToggle(content, "Noclip", y, CONFIG.Noclip, function(v) CONFIG.Noclip = v setNoclip(v) end)
		y = createToggle(content, "Speed", y, CONFIG.Speed, function(v) CONFIG.Speed = v applySpeedJump() end)
		y = createSlider(content, "Valor Speed", y, CONFIG.SpeedValue, 16, 100, function(v) CONFIG.SpeedValue = v applySpeedJump() end)
		y = createToggle(content, "Jump Boost", y, CONFIG.Jump, function(v) CONFIG.Jump = v applySpeedJump() end)
		y = createSlider(content, "Valor Jump", y, CONFIG.JumpValue, 50, 200, function(v) CONFIG.JumpValue = v applySpeedJump() end)

		y = createSection(content, "MUNDO", y + 4)
		y = createToggle(content, "Fullbright", y, CONFIG.Fullbright, function(v) CONFIG.Fullbright = v setFullbright(v) end)

	elseif name == "Configs" then
		y = createSection(content, "GERAL", y)
		y = createToggle(content, "Sistema Ativo", y, CONFIG.Enabled, function(v)
			CONFIG.Enabled = v
			if not v then clearAllESP() setNoclip(false) end
		end)
		y = createToggle(content, "Quit on Death", y, CONFIG.QuitOnDeath, function(v) CONFIG.QuitOnDeath = v end)

		local info = Instance.new("TextLabel")
		info.Size = UDim2.new(1, -24, 0, 70)
		info.Position = UDim2.new(0, 12, 0, y + 8)
		info.BackgroundTransparency = 1
		info.Text = "Right Shift = Abrir/Fechar\n– = Minimizar | 🐯 = Reabrir\nRevistar usa Username"
		info.TextColor3 = Theme.TextDim
		info.Font = Enum.Font.Gotham
		info.TextSize = 11
		info.TextXAlignment = Enum.TextXAlignment.Left
		info.Parent = content
	end
end

for n, d in pairs(tabButtons) do
	d.Button.MouseButton1Click:Connect(function() openTab(n) end)
end
openTab("Combate")

-- ====================== ARRASTAR / MINIMIZAR ======================
dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function setMenuVisible(v)
	menuOpen = v
	main.Visible = v
	openBtn.Visible = not v
end
miniBtn.MouseButton1Click:Connect(function() setMenuVisible(false) end)
openBtn.MouseButton1Click:Connect(function() setMenuVisible(true) end)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then setMenuVisible(not menuOpen) end
end)

-- ====================== LÓGICA ======================
local function canSee(part)
	if CONFIG.Wallbang then return true end
	local origin = Camera.CFrame.Position
	local ray = Workspace:Raycast(origin, part.Position - origin)
	if ray and ray.Instance then
		local model = ray.Instance:FindFirstAncestorOfClass("Model")
		return model and model:FindFirstChildOfClass("Humanoid") ~= nil
	end
	return true
end

local function findTarget()
	local best, bestDist = nil, CONFIG.FOV
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isValid(plr.Character) then
			local part = CONFIG.SilentAim and plr.Character:FindFirstChild("Head") or getPart(plr.Character)
			if part and canSee(part) then
				local d3 = (part.Position - root.Position).Magnitude
				if d3 <= CONFIG.MaxDistance then
					local sd = getScreenDist(part.Position)
					if sd < bestDist then
						bestDist = sd
						best = part
					end
				end
			end
		end
	end
	return best
end

local function aim(part)
	if not part then return end
	local targetCF = CFrame.lookAt(Camera.CFrame.Position, part.Position)
	if CONFIG.SilentAim then
		Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.9)
	else
		Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - CONFIG.Smoothness)
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Died:Connect(function()
			if CONFIG.QuitOnDeath then LocalPlayer:Kick("Tigrinho") end
		end)
	end
	task.wait(0.3)
	if CONFIG.Noclip then setNoclip(true) end
	applySpeedJump()
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then isHoldingAim = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then isHoldingAim = false end
end)

local lastESP = 0
RunService.RenderStepped:Connect(function()
	if not CONFIG.Enabled then
		clearAllESP()
		fovCircle.Visible = false
		return
	end

	fovCircle.Visible = CONFIG.ShowFOV

	-- ESP a cada 0.25s (não pisca)
	if tick() - lastESP > 0.25 then
		lastESP = tick()
		local seen = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				seen[plr.UserId] = true
				updatePlayerESP(plr)
			end
		end
		for userId in pairs(espCache) do
			if not seen[userId] then clearESPForPlayer(userId) end
		end
	end

	if (CONFIG.Aimbot or CONFIG.SilentAim) and isHoldingAim then
		local t = findTarget()
		if t then aim(t) end
	end
end)

print("[Tigrinho] 🐯 VERSÃO FINAL | ESP estável | Menu moderno")
