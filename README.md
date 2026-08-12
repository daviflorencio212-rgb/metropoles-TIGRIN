--[[
	TIGRINHO - Refeito
	- Silent Aim sem FOV (cabeça)
	- Sem "aimbot sempre"
	- Botão Revistar mais baixo
	- Português + Mobile
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
local isMobile = UserInputService.TouchEnabled

local CONFIG = {
	Aimbot = false,
	SilentAim = false,
	ShowFOV = false,
	FOV = 220,
	MaxDistance = 10000000,
	ESPMaxDistance = 500,
	Smoothness = 0.08,
	ShowESP = false,
	ShowHighlight = true,
	ShowName = true,
	ShowDistance = true,
	ShowTool = true,
	ShowInventory = false,
	ESPColor = Color3.fromRGB(255, 140, 30),
	Noclip = false,
	Speed = false,
	SpeedValue = 24,
	Jump = false,
	JumpValue = 60,
	Fullbright = false,
	QuitOnDeath = false,
}

local isHoldingAim = false
local menuOpen = true
local dragging = false
local dragStart, startPos
local noclipConnection = nil
local espCache = {}

local Theme = {
	Bg = Color3.fromRGB(10, 10, 12),
	Sidebar = Color3.fromRGB(14, 14, 16),
	Panel = Color3.fromRGB(16, 16, 18),
	Card = Color3.fromRGB(24, 24, 28),
	Accent = Color3.fromRGB(255, 140, 30),
	Text = Color3.fromRGB(245, 245, 250),
	TextDim = Color3.fromRGB(150, 150, 160),
	Off = Color3.fromRGB(55, 55, 62),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Tigrinho"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, CONFIG.FOV * 2, 0, CONFIG.FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Theme.Accent
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.35

local menuW = isMobile and 340 or 560
local menuH = isMobile and 420 or 440
local sideW = isMobile and 0 or 120

local main = Instance.new("Frame")
main.Size = UDim2.new(0, menuW, 0, menuH)
main.Position = UDim2.new(0.5, -menuW/2, 0.5, -menuH/2)
main.BackgroundColor3 = Theme.Bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", main).Color = Theme.Accent

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, isMobile and 48 or 50)
header.BackgroundColor3 = Theme.Sidebar
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = Theme.Sidebar
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, -50, 1, 0)
logo.Position = UDim2.new(0, 14, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "🐯 TIGRINHO"
logo.TextColor3 = Theme.Accent
logo.Font = Enum.Font.GothamBlack
logo.TextSize = isMobile and 18 or 20
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -44, 0.5, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.TextDim
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, sideW, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Visible = not isMobile
sidebar.Parent = main

local mobileTabs = Instance.new("Frame")
mobileTabs.Size = UDim2.new(1, -12, 0, 40)
mobileTabs.Position = UDim2.new(0, 6, 0, 52)
mobileTabs.BackgroundTransparency = 1
mobileTabs.Visible = isMobile
mobileTabs.Parent = main
local mobileList = Instance.new("UIListLayout")
mobileList.FillDirection = Enum.FillDirection.Horizontal
mobileList.Padding = UDim.new(0, 6)
mobileList.Parent = mobileTabs

local contentY = isMobile and 96 or 54
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, isMobile and -12 or -(sideW + 10), 1, -(contentY + 8))
content.Position = UDim2.new(0, isMobile and 6 or (sideW + 6), 0, contentY)
content.BackgroundColor3 = Theme.Panel
content.BorderSizePixel = 0
content.ScrollBarThickness = isMobile and 4 or 3
content.ScrollBarImageColor3 = Theme.Accent
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 12)
local cPad = Instance.new("UIPadding", content)
cPad.PaddingTop = UDim.new(0, 6)
cPad.PaddingBottom = UDim.new(0, 16)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, isMobile and 56 or 48, 0, isMobile and 56 or 48)
openBtn.Position = UDim2.new(0, 12, 0.55, 0)
openBtn.BackgroundColor3 = Theme.Accent
openBtn.Text = "🐯"
openBtn.TextSize = isMobile and 26 or 22
openBtn.Visible = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- BOTÃO REVISTAR (mais pra baixo, esquerda)
local revistarBtn = Instance.new("TextButton")
revistarBtn.Size = UDim2.new(0, isMobile and 140 or 125, 0, isMobile and 44 or 38)
revistarBtn.Position = UDim2.new(0, 14, 0, isMobile and 110 or 90)
revistarBtn.BackgroundColor3 = Theme.Accent
revistarBtn.Text = "🐯 REVISTAR"
revistarBtn.TextColor3 = Color3.new(1,1,1)
revistarBtn.Font = Enum.Font.GothamBold
revistarBtn.TextSize = isMobile and 14 or 13
revistarBtn.ZIndex = 10
revistarBtn.Parent = screenGui
Instance.new("UICorner", revistarBtn).CornerRadius = UDim.new(0, 10)
local revStroke = Instance.new("UIStroke", revistarBtn)
revStroke.Color = Color3.fromRGB(255, 200, 100)
revStroke.Thickness = 1.5

-- ====================== UI ======================
local tabButtons = {}

local function createTabButton(name, icon, order)
	if isMobile then
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 78, 0, 36)
		btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		btn.Text = icon .. " " .. name
		btn.TextColor3 = Theme.TextDim
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.Parent = mobileTabs
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
		tabButtons[name] = {Button = btn, Label = btn}
	else
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -14, 0, 42)
		btn.Position = UDim2.new(0, 7, 0, 10 + (order-1)*50)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = sidebar
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -8, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = icon .. "  " .. name
		label.TextColor3 = Theme.TextDim
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = btn
		local ind = Instance.new("Frame")
		ind.Size = UDim2.new(0, 3, 0, 22)
		ind.Position = UDim2.new(0, 0, 0.5, -11)
		ind.BackgroundColor3 = Theme.Accent
		ind.Visible = false
		ind.Parent = btn
		Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
		tabButtons[name] = {Button = btn, Label = label, Indicator = ind}
	end
end

createTabButton("COMBATE", "⚔", 1)
createTabButton("ESP", "👁", 2)
createTabButton("PLAYER", "🏃", 3)
createTabButton("CONFIG", "⚙", 4)

local function createSection(parent, text, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -12, 0, 20)
	l.Position = UDim2.new(0, 6, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Theme.Accent
	l.Font = Enum.Font.GothamBlack
	l.TextSize = isMobile and 13 or 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return y + 22
end

local function createToggle(parent, text, y, default, callback)
	local h = isMobile and 44 or 36
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -12, 0, h)
	frame.Position = UDim2.new(0, 6, 0, y)
	frame.BackgroundColor3 = Theme.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = isMobile and 13 or 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, isMobile and 48 or 44, 0, isMobile and 26 or 22)
	btn.Position = UDim2.new(1, isMobile and -56 or -52, 0.5, isMobile and -13 or -11)
	btn.BackgroundColor3 = default and Theme.Accent or Theme.Off
	btn.Text = ""
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, isMobile and 20 or 16, 0, isMobile and 20 or 16)
	circle.Position = default and UDim2.new(1, isMobile and -23 or -19, 0.5, isMobile and -10 or -8) or UDim2.new(0, 3, 0.5, isMobile and -10 or -8)
	circle.BackgroundColor3 = Color3.new(1,1,1)
	circle.BorderSizePixel = 0
	circle.Parent = btn
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Accent or Theme.Off}):Play()
		TweenService:Create(circle, TweenInfo.new(0.15), {
			Position = state and UDim2.new(1, isMobile and -23 or -19, 0.5, isMobile and -10 or -8)
				or UDim2.new(0, 3, 0.5, isMobile and -10 or -8)
		}):Play()
		callback(state)
	end)
	return y + h + 6
end

local function createSlider(parent, text, y, default, min, max, callback)
	local h = isMobile and 56 or 50
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -12, 0, h)
	frame.Position = UDim2.new(0, 6, 0, y)
	frame.BackgroundColor3 = Theme.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 18)
	label.Position = UDim2.new(0, 12, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = isMobile and 12 or 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.35, -12, 0, 18)
	valueLabel.Position = UDim2.new(0.65, 0, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = isMobile and 12 or 11
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -24, 0, isMobile and 10 or 7)
	barBg.Position = UDim2.new(0, 12, 0, isMobile and 34 or 30)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
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
	local function update(input)
		local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
		local value = math.floor(min + (max - min) * rel)
		bar.Size = UDim2.new(rel, 0, 1, 0)
		valueLabel.Text = tostring(value)
		callback(value)
	end
	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			update(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
	end)
	return y + h + 6
end

-- ====================== LÓGICA ======================
local function isValid(char)
	if not char or char == LocalPlayer.Character then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return Players:GetPlayerFromCharacter(char) ~= nil
end

local function getScreenDist(pos)
	local sp, onScreen = Camera:WorldToViewportPoint(pos)
	if not onScreen or sp.Z < 0 then return math.huge end
	return (Vector2.new(sp.X, sp.Y) - Camera.ViewportSize/2).Magnitude
end

-- Silent: SEM limite de FOV | Aimbot normal: usa FOV
local function findTarget(ignoreFOV)
	local limit = ignoreFOV and math.huge or CONFIG.FOV
	local best, bestDist = nil, limit
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isValid(plr.Character) then
			local head = plr.Character:FindFirstChild("Head")
			local part = head or plr.Character:FindFirstChild("HumanoidRootPart")
			if part then
				local d3 = (part.Position - root.Position).Magnitude
				if d3 <= CONFIG.MaxDistance then
					local sd = getScreenDist(part.Position)
					-- Silent: pega o mais perto do centro mesmo fora do círculo
					-- Aimbot: só dentro do FOV
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
	local cf = CFrame.lookAt(Camera.CFrame.Position, part.Position)
	if CONFIG.SilentAim then
		Camera.CFrame = Camera.CFrame:Lerp(cf, 0.97) -- bem forte na cabeça
	else
		Camera.CFrame = Camera.CFrame:Lerp(cf, math.clamp(1 - CONFIG.Smoothness, 0.55, 0.98))
	end
end

-- Revistar: mais perto / morto / vivo
local function getPlayerParaRevistar()
	local melhor, menor = nil, 99999
	local centro = Camera.ViewportSize / 2
	local meuRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local char = plr.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
			if head and hum then
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen and pos.Z > 0 then
					local distTela = (Vector2.new(pos.X, pos.Y) - centro).Magnitude
					local dist3 = meuRoot and (head.Position - meuRoot.Position).Magnitude or 0
					-- prioriza perto da mira e perto de você (até 80 studs)
					if dist3 <= 80 and distTela < menor then
						menor = distTela
						melhor = plr
					end
				end
			end
		end
	end
	return melhor
end

local function fazerRevistar()
	local target = getPlayerParaRevistar()
	if not target then
		StarterGui:SetCore("SendNotification", {Title = "Tigrinho", Text = "Ninguém perto da mira", Duration = 2})
		return
	end

	local nome = target.Name -- Username

	-- Chat
	pcall(function()
		local channels = TextChatService:FindFirstChild("TextChannels")
		if channels then
			local g = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General")
			if g then g:SendAsync("/revistar " .. nome) end
		end
	end)
	pcall(function() LocalPlayer:Chat("/revistar " .. nome) end)

	-- Remote do jogo (várias tentativas)
	local remote
	pcall(function()
		remote = ReplicatedStorage:FindFirstChild("shared")
			and ReplicatedStorage.shared:FindFirstChild("Eventos")
			and ReplicatedStorage.shared.Eventos:FindFirstChild("revisar_function")
	end)

	if remote and remote:IsA("RemoteFunction") then
		pcall(function() remote:InvokeServer(target) end)
		pcall(function() remote:InvokeServer(target.Name) end)
		pcall(function() remote:InvokeServer(target.UserId) end)
		pcall(function() remote:InvokeServer(target.Character) end)
		pcall(function() remote:InvokeServer() end)
		print("[Tigrinho] revisar_function →", nome)
	else
		warn("[Tigrinho] revisar_function não achado")
	end

	StarterGui:SetCore("SendNotification", {
		Title = "Tigrinho",
		Text = "Revistando: " .. nome,
		Duration = 3
	})
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
	hum.WalkSpeed = CONFIG.Speed and CONFIG.SpeedValue or 16
	hum.JumpPower = CONFIG.Jump and CONFIG.JumpValue or 50
end

local function setFullbright(state)
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end

local function clearESPForPlayer(userId)
	if espCache[userId] then
		for _, obj in pairs(espCache[userId]) do
			if typeof(obj) == "Instance" and obj.Parent then obj:Destroy() end
		end
		espCache[userId] = nil
	end
end

local function clearAllESP()
	for id in pairs(espCache) do clearESPForPlayer(id) end
end

local function updatePlayerESP(plr)
	local char = plr.Character
	if not char then clearESPForPlayer(plr.UserId) return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local meuRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root or not hum or not meuRoot then clearESPForPlayer(plr.UserId) return end
	local dist = (root.Position - meuRoot.Position).Magnitude
	if dist > CONFIG.ESPMaxDistance or not CONFIG.ShowESP then clearESPForPlayer(plr.UserId) return end

	if not espCache[plr.UserId] then espCache[plr.UserId] = {} end
	local cache = espCache[plr.UserId]

	if CONFIG.ShowHighlight and hum.Health > 0 then
		if not cache.hl or not cache.hl.Parent then
			local hl = Instance.new("Highlight")
			hl.Adornee = char
			hl.FillColor = CONFIG.ESPColor
			hl.OutlineColor = Color3.new(1,1,1)
			hl.FillTransparency = 0.7
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = Workspace
			cache.hl = hl
		else
			cache.hl.FillColor = CONFIG.ESPColor
			cache.hl.Adornee = char
		end
	elseif cache.hl then cache.hl:Destroy() cache.hl = nil end

	if (CONFIG.ShowName or CONFIG.ShowDistance or CONFIG.ShowTool) and hum.Health > 0 and head then
		if not cache.info or not cache.info.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = head
			bb.Size = UDim2.new(0, 140, 0, 40)
			bb.StudsOffset = Vector3.new(0, 2.4, 0)
			bb.AlwaysOnTop = true
			bb.Parent = Workspace
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1,0,1,0)
			label.BackgroundTransparency = 1
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
			text = text .. (tool and ("["..tool.Name.."]") or "")
		end
		cache.infoLabel.Text = text
		cache.infoLabel.TextColor3 = CONFIG.ESPColor
		cache.info.Adornee = head
	elseif cache.info then cache.info:Destroy() cache.info = nil cache.infoLabel = nil end

	if CONFIG.ShowInventory then
		if not cache.inv or not cache.inv.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = root
			bb.Size = UDim2.new(0, 100, 0, 28)
			bb.StudsOffset = Vector3.new(0, -2.8, 0)
			bb.AlwaysOnTop = true
			bb.Parent = Workspace
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,1,0)
			frame.BackgroundColor3 = Color3.fromRGB(12,10,8)
			frame.BackgroundTransparency = 0.35
			frame.BorderSizePixel = 0
			frame.Parent = bb
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
			local list = Instance.new("TextLabel")
			list.Size = UDim2.new(1,-4,1,-2)
			list.Position = UDim2.new(0,2,0,1)
			list.BackgroundTransparency = 1
			list.TextColor3 = Color3.fromRGB(220,220,220)
			list.Font = Enum.Font.Gotham
			list.TextSize = 9
			list.TextXAlignment = Enum.TextXAlignment.Left
			list.Parent = frame
			cache.inv = bb
			cache.invList = list
		end
		local items = {}
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then table.insert(items, tool.Name) end
		for _, obj in ipairs(char:GetChildren()) do
			if obj:IsA("Tool") and obj ~= tool then table.insert(items, obj.Name) end
		end
		local bp = plr:FindFirstChild("Backpack")
		if bp then
			for _, obj in ipairs(bp:GetChildren()) do
				if obj:IsA("Tool") then table.insert(items, obj.Name) end
			end
		end
		cache.invList.Text = #items > 0 and table.concat(items, " · ") or "—"
		cache.inv.Adornee = root
	elseif cache.inv then cache.inv:Destroy() cache.inv = nil cache.invList = nil end
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
		if isMobile then
			d.Button.BackgroundColor3 = (n == name) and Theme.Accent or Color3.fromRGB(28, 28, 32)
			d.Button.TextColor3 = (n == name) and Color3.new(1,1,1) or Theme.TextDim
		else
			d.Label.TextColor3 = (n == name) and Theme.Text or Theme.TextDim
			if d.Indicator then d.Indicator.Visible = (n == name) end
		end
	end

	local y = 4
	if name == "COMBATE" then
		y = createSection(content, "MIRA", y)
		y = createToggle(content, "Aimbot (segura botão direito)", y, CONFIG.Aimbot, function(v) CONFIG.Aimbot = v end)
		y = createToggle(content, "Silent Aim (cabeça, sem FOV)", y, CONFIG.SilentAim, function(v) CONFIG.SilentAim = v end)
		y = createToggle(content, "Mostrar FOV", y, CONFIG.ShowFOV, function(v) CONFIG.ShowFOV = v fovCircle.Visible = v end)
		y = createSlider(content, "Tamanho do FOV", y, CONFIG.FOV, 50, 700, function(v)
			CONFIG.FOV = v
			fovCircle.Size = UDim2.new(0, v*2, 0, v*2)
		end)
		y = createSlider(content, "Força da mira (menor = mais forte)", y, math.floor(CONFIG.Smoothness*100), 1, 40, function(v)
			CONFIG.Smoothness = v/100
		end)

	elseif name == "ESP" then
		y = createSection(content, "VISUAL", y)
		y = createToggle(content, "ESP ativo", y, CONFIG.ShowESP, function(v) CONFIG.ShowESP = v if not v then clearAllESP() end end)
		y = createSlider(content, "Distância do ESP", y, CONFIG.ESPMaxDistance, 50, 2000, function(v) CONFIG.ESPMaxDistance = v end)
		y = createToggle(content, "Highlight", y, CONFIG.ShowHighlight, function(v) CONFIG.ShowHighlight = v end)
		y = createToggle(content, "Mostrar nome", y, CONFIG.ShowName, function(v) CONFIG.ShowName = v end)
		y = createToggle(content, "Mostrar distância", y, CONFIG.ShowDistance, function(v) CONFIG.ShowDistance = v end)
		y = createToggle(content, "Item na mão", y, CONFIG.ShowTool, function(v) CONFIG.ShowTool = v end)
		y = createToggle(content, "Ver inventário", y, CONFIG.ShowInventory, function(v) CONFIG.ShowInventory = v end)
		y = createSection(content, "COR", y + 2)
		local colorFrame = Instance.new("Frame")
		colorFrame.Size = UDim2.new(1, -12, 0, 30)
		colorFrame.Position = UDim2.new(0, 6, 0, y)
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
			b.Size = UDim2.new(0, isMobile and 28 or 24, 0, isMobile and 28 or 24)
			b.BackgroundColor3 = cor
			b.Text = ""
			b.Parent = colorFrame
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function() CONFIG.ESPColor = cor end)
		end

	elseif name == "PLAYER" then
		y = createSection(content, "MOVIMENTO", y)
		y = createToggle(content, "Noclip", y, CONFIG.Noclip, function(v) CONFIG.Noclip = v setNoclip(v) end)
		y = createToggle(content, "Velocidade", y, CONFIG.Speed, function(v) CONFIG.Speed = v applySpeedJump() end)
		y = createSlider(content, "Valor da velocidade", y, CONFIG.SpeedValue, 16, 100, function(v) CONFIG.SpeedValue = v applySpeedJump() end)
		y = createToggle(content, "Pulo alto", y, CONFIG.Jump, function(v) CONFIG.Jump = v applySpeedJump() end)
		y = createSlider(content, "Valor do pulo", y, CONFIG.JumpValue, 50, 200, function(v) CONFIG.JumpValue = v applySpeedJump() end)
		y = createSection(content, "MUNDO", y + 2)
		y = createToggle(content, "Claridade total", y, CONFIG.Fullbright, function(v) CONFIG.Fullbright = v setFullbright(v) end)

	elseif name == "CONFIG" then
		y = createSection(content, "OUTROS", y)
		y = createToggle(content, "Sair ao morrer", y, CONFIG.QuitOnDeath, function(v) CONFIG.QuitOnDeath = v end)
		local info = Instance.new("TextLabel")
		info.Size = UDim2.new(1, -12, 0, 80)
		info.Position = UDim2.new(0, 6, 0, y + 4)
		info.BackgroundTransparency = 1
		info.Text = isMobile
			and "Toque no 🐯 para abrir\nRevistar: botão laranja na esquerda\nSilent Aim: cabeça sem FOV"
			or "Right Shift = menu\nRevistar = botão laranja\nSilent Aim = cabeça sem FOV"
		info.TextColor3 = Theme.TextDim
		info.Font = Enum.Font.Gotham
		info.TextSize = isMobile and 12 or 11
		info.TextXAlignment = Enum.TextXAlignment.Left
		info.Parent = content
	end
end

for n, d in pairs(tabButtons) do
	d.Button.MouseButton1Click:Connect(function() openTab(n) end)
end
openTab("COMBATE")

-- Drag
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local draggingRev, dragStartRev, startPosRev = false, nil, nil
revistarBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingRev = true
		dragStartRev = input.Position
		startPosRev = revistarBtn.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingRev and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStartRev
		revistarBtn.Position = UDim2.new(startPosRev.X.Scale, startPosRev.X.Offset + d.X, startPosRev.Y.Scale, startPosRev.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingRev = false end
end)

local function setMenuVisible(v)
	menuOpen = v
	main.Visible = v
	openBtn.Visible = not v
end
closeBtn.MouseButton1Click:Connect(function() setMenuVisible(false) end)
openBtn.MouseButton1Click:Connect(function() setMenuVisible(true) end)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then setMenuVisible(not menuOpen) end
end)

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

UserInputService.TouchStarted:Connect(function()
	if isMobile and (CONFIG.Aimbot or CONFIG.SilentAim) then isHoldingAim = true end
end)
UserInputService.TouchEnded:Connect(function()
	if isMobile then isHoldingAim = false end
end)

local lastESP = 0
RunService.RenderStepped:Connect(function()
	fovCircle.Visible = CONFIG.ShowFOV

	if tick() - lastESP > 0.3 then
		lastESP = tick()
		if CONFIG.ShowESP then
			local seen = {}
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer then
					seen[plr.UserId] = true
					updatePlayerESP(plr)
				end
			end
			for id in pairs(espCache) do
				if not seen[id] then clearESPForPlayer(id) end
			end
		else
			clearAllESP()
		end
	end

	-- Silent: ignora FOV | Aimbot: usa FOV e botão direito
	if CONFIG.SilentAim and isHoldingAim then
		local t = findTarget(true) -- true = sem FOV
		if t then aim(t) end
	elseif CONFIG.Aimbot and isHoldingAim then
		local t = findTarget(false)
		if t then aim(t) end
	end
end)

print("[Tigrinho] Silent sem FOV | Revistar mais baixo | Sem aimbot sempre")
