--[[
	TIGRINHO - Versão Final Corrigida
	- Tudo desativado por padrão
	- Revistar pega a pessoa dentro do FOV
	- FOV visual
	- ESP com distância
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====================== CONFIG (TUDO DESATIVADO) ======================
local CONFIG = {
	Enabled = false,
	Aimbot = false,
	ShowFOV = false,
	FOV = 180,
	MaxDistance = 10000000,
	ESPMaxDistance = 500,
	Smoothness = 0.10,
	Wallbang = false,
	Revistar = false,
	ShowESP = false,
	ShowBox2D = false,
	ShowHighlight = false,
	ESPColor = Color3.fromRGB(255, 140, 30),
	Noclip = false,
	QuitOnDeath = false,
	PriorityParts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
}

local isHoldingAim = false
local menuOpen = true
local dragging = false
local dragStart, startPos

local espFolder = Instance.new("Folder")
espFolder.Name = "TigrinhoESP"
espFolder.Parent = Workspace

local box2DFolder = Instance.new("Folder")
box2DFolder.Name = "TigrinhoBox2D"
box2DFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== TEMA ======================
local Theme = {
	Background = Color3.fromRGB(22, 18, 14),
	Sidebar = Color3.fromRGB(32, 24, 16),
	Panel = Color3.fromRGB(38, 28, 18),
	Accent = Color3.fromRGB(255, 140, 30),
	AccentDark = Color3.fromRGB(220, 110, 20),
	Text = Color3.fromRGB(255, 245, 230),
	TextDim = Color3.fromRGB(180, 150, 120),
	Success = Color3.fromRGB(0, 200, 120),
	Danger = Color3.fromRGB(230, 60, 70),
}

-- ====================== UI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Tigrinho"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FOV Circle
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
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.35

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 560, 0, 510)
main.Position = UDim2.new(0.5, -280, 0.5, -255)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

local sideFix = Instance.new("Frame")
sideFix.Size = UDim2.new(0, 20, 1, 0)
sideFix.Position = UDim2.new(1, -20, 0, 0)
sideFix.BackgroundColor3 = Theme.Sidebar
sideFix.BorderSizePixel = 0
sideFix.Parent = sidebar

local dragArea = Instance.new("Frame")
dragArea.Size = UDim2.new(1, 0, 0, 55)
dragArea.BackgroundTransparency = 1
dragArea.Parent = sidebar

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 1, 0)
logo.BackgroundTransparency = 1
logo.Text = "🐯 TIGRINHO"
logo.TextColor3 = Theme.Accent
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 18
logo.Parent = dragArea

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -20)
content.Position = UDim2.new(0, 160, 0, 10)
content.BackgroundColor3 = Theme.Panel
content.BorderSizePixel = 0
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 12)

local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 32, 0, 32)
miniBtn.Position = UDim2.new(1, -42, 0, 8)
miniBtn.BackgroundColor3 = Theme.AccentDark
miniBtn.Text = "–"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 20
miniBtn.Parent = main
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 54, 0, 54)
openBtn.Position = UDim2.new(0, 20, 0.5, -27)
openBtn.BackgroundColor3 = Theme.Accent
openBtn.Text = "🐯"
openBtn.TextSize = 26
openBtn.Visible = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- ====================== ABAS ======================
local tabButtons = {}
local function createTabButton(name, icon, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -16, 0, 40)
	btn.Position = UDim2.new(0, 8, 0, 70 + (order-1)*50)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = sidebar

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = icon .. "  " .. name
	label.TextColor3 = Theme.TextDim
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
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

createTabButton("Combate", "⚔", 1)
createTabButton("Visual", "👁", 2)
createTabButton("Configs", "⚙", 3)

-- ====================== HELPERS UI ======================
local function createSection(parent, text, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -30, 0, 20)
	l.Position = UDim2.new(0, 15, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Theme.Accent
	l.Font = Enum.Font.GothamBold
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return y + 24
end

local function createToggle(parent, text, y, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -30, 0, 32)
	frame.Position = UDim2.new(0, 15, 0, y)
	frame.BackgroundColor3 = Color3.fromRGB(48, 36, 24)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -65, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 0, 18)
	btn.Position = UDim2.new(1, -50, 0.5, -9)
	btn.BackgroundColor3 = default and Theme.Success or Theme.Danger
	btn.Text = ""
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 12, 0, 12)
	circle.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
	circle.BackgroundColor3 = Color3.new(1,1,1)
	circle.BorderSizePixel = 0
	circle.Parent = btn
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Success or Theme.Danger}):Play()
		TweenService:Create(circle, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
		callback(state)
	end)
	return y + 38
end

local function createSlider(parent, text, y, default, min, max, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -30, 0, 46)
	frame.Position = UDim2.new(0, 15, 0, y)
	frame.BackgroundColor3 = Color3.fromRGB(48, 36, 24)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 16)
	label.Position = UDim2.new(0, 10, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.4, -10, 0, 16)
	valueLabel.Position = UDim2.new(0.6, 0, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -20, 0, 6)
	barBg.Position = UDim2.new(0, 10, 0, 28)
	barBg.BackgroundColor3 = Color3.fromRGB(60, 45, 30)
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
	btn.Size = UDim2.new(1, -30, 0, 34)
	btn.Position = UDim2.new(0, 15, 0, y)
	btn.BackgroundColor3 = Theme.AccentDark
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
	return y + 42
end

-- ====================== FUNÇÕES PRINCIPAIS ======================
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

-- Revistar: pega a pessoa DENTRO do FOV
local function getPlayerDentroDoFOV()
	local melhorPlayer = nil
	local menorDistanciaTela = CONFIG.FOV
	local meuRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not meuRoot then return nil end

	local centroTela = Camera.ViewportSize / 2

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isValid(plr.Character) then
			local char = plr.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local head = char:FindFirstChild("Head")

			if root then
				local parte = head or root
				local posTela, naTela = Camera:WorldToViewportPoint(parte.Position)

				if naTela and posTela.Z > 0 then
					local distTela = (Vector2.new(posTela.X, posTela.Y) - centroTela).Magnitude
					if distTela < menorDistanciaTela then
						menorDistanciaTela = distTela
						melhorPlayer = plr
					end
				end
			end
		end
	end

	return melhorPlayer
end

local function fazerRevistar()
	if not CONFIG.Revistar then
		StarterGui:SetCore("SendNotification", {
			Title = "Tigrinho",
			Text = "Revistar está desativado",
			Duration = 2
		})
		return
	end

	local target = getPlayerDentroDoFOV()

	if target then
		local nome = target.DisplayName
		if not nome or nome == "" then
			nome = target.Name
		end

		local cmd = "/revistar " .. nome

		pcall(function()
			local channels = TextChatService:FindFirstChild("TextChannels")
			if channels then
				local general = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General")
				if general then
					general:SendAsync(cmd)
				end
			end
		end)

		pcall(function()
			LocalPlayer:Chat(cmd)
		end)

		StarterGui:SetCore("SendNotification", {
			Title = "Tigrinho",
			Text = "Revistando: " .. nome,
			Duration = 3
		})

		print("[Tigrinho] /revistar " .. nome)
	else
		StarterGui:SetCore("SendNotification", {
			Title = "Tigrinho",
			Text = "Ninguém dentro do FOV",
			Duration = 2
		})
	end
end

-- ====================== CONTEÚDO DAS ABAS ======================
local function clearContent()
	for _, c in ipairs(content:GetChildren()) do
		if not c:IsA("UICorner") then c:Destroy() end
	end
end

local function openTab(name)
	clearContent()
	for n, d in pairs(tabButtons) do
		d.Label.TextColor3 = (n == name) and Theme.Text or Theme.TextDim
		d.Indicator.Visible = (n == name)
	end

	local y = 8

	if name == "Combate" then
		y = createSection(content, "AIMBOT", y)
		y = createToggle(content, "Aimbot Ativo", y, CONFIG.Aimbot, function(v) CONFIG.Aimbot = v end)
		y = createToggle(content, "Mostrar FOV", y, CONFIG.ShowFOV, function(v)
			CONFIG.ShowFOV = v
			fovCircle.Visible = v
		end)
		y = createSlider(content, "Tamanho FOV", y, CONFIG.FOV, 50, 600, function(v)
			CONFIG.FOV = v
			fovCircle.Size = UDim2.new(0, v*2, 0, v*2)
		end)
		y = createSlider(content, "Suavidade", y, math.floor(CONFIG.Smoothness*100), 2, 40, function(v)
			CONFIG.Smoothness = v/100
		end)
		y = createToggle(content, "Matar atrás das paredes", y, CONFIG.Wallbang, function(v) CONFIG.Wallbang = v end)

		y = createSection(content, "REVISTAR", y + 6)
		y = createToggle(content, "Revistar Ativo", y, CONFIG.Revistar, function(v) CONFIG.Revistar = v end)
		y = createButton(content, "REVISTAR AGORA (manual)", y, function()
			fazerRevistar()
		end)

		local info = Instance.new("TextLabel")
		info.Size = UDim2.new(1, -30, 0, 40)
		info.Position = UDim2.new(0, 15, 0, y + 4)
		info.BackgroundTransparency = 1
		info.Text = "Aperte Ç ou C → pega a pessoa\nque estiver DENTRO do FOV"
		info.TextColor3 = Theme.TextDim
		info.Font = Enum.Font.Gotham
		info.TextSize = 12
		info.TextXAlignment = Enum.TextXAlignment.Left
		info.Parent = content

		y = createSection(content, "MOVIMENTO", y + 55)
		y = createToggle(content, "Noclip", y, CONFIG.Noclip, function(v) CONFIG.Noclip = v end)

	elseif name == "Visual" then
		y = createSection(content, "ESP", y)
		y = createToggle(content, "ESP Ativo", y, CONFIG.ShowESP, function(v)
			CONFIG.ShowESP = v
			if not v then clearAllESP() end
		end)
		y = createSlider(content, "Distância do ESP", y, CONFIG.ESPMaxDistance, 50, 2000, function(v)
			CONFIG.ESPMaxDistance = v
		end)
		y = createToggle(content, "Box 2D", y, CONFIG.ShowBox2D, function(v) CONFIG.ShowBox2D = v end)
		y = createToggle(content, "Highlight", y, CONFIG.ShowHighlight, function(v) CONFIG.ShowHighlight = v end)

		y = createSection(content, "COR DO ESP", y + 4)
		local colorFrame = Instance.new("Frame")
		colorFrame.Size = UDim2.new(1, -30, 0, 34)
		colorFrame.Position = UDim2.new(0, 15, 0, y)
		colorFrame.BackgroundTransparency = 1
		colorFrame.Parent = content
		local list = Instance.new("UIListLayout")
		list.FillDirection = Enum.FillDirection.Horizontal
		list.Padding = UDim.new(0, 5)
		list.Parent = colorFrame

		local cores = {
			Color3.fromRGB(255,140,30), Color3.fromRGB(0,170,255), Color3.fromRGB(0,255,140),
			Color3.fromRGB(255,55,55), Color3.fromRGB(170,70,255), Color3.fromRGB(255,220,40),
			Color3.fromRGB(255,255,255), Color3.fromRGB(255,70,180)
		}
		for _, cor in ipairs(cores) do
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 26, 0, 26)
			b.BackgroundColor3 = cor
			b.Text = ""
			b.Parent = colorFrame
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
			b.MouseButton1Click:Connect(function() CONFIG.ESPColor = cor end)
		end

	elseif name == "Configs" then
		y = createSection(content, "GERAL", y)
		y = createToggle(content, "Sistema Ativo", y, CONFIG.Enabled, function(v)
			CONFIG.Enabled = v
			if not v then clearAllESP() end
		end)
		y = createToggle(content, "Quit on Death", y, CONFIG.QuitOnDeath, function(v) CONFIG.QuitOnDeath = v end)
	end
end

for n, d in pairs(tabButtons) do
	d.Button.MouseButton1Click:Connect(function() openTab(n) end)
end
openTab("Combate")

-- ====================== ARRASTAR + MINIMIZAR ======================
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
	if input.KeyCode == Enum.KeyCode.RightShift then
		setMenuVisible(not menuOpen)
	end
end)

-- ====================== LÓGICA ======================
local function clearAllESP()
	espFolder:ClearAllChildren()
	box2DFolder:ClearAllChildren()
end

local function canSee(part)
	if CONFIG.Wallbang then return true end
	local origin = Camera.CFrame.Position
	local dir = (part.Position - origin)
	local ray = Workspace:Raycast(origin, dir)
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
			local part = getPart(plr.Character)
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

local function create2DBox(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	if not root or not head then return end
	local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.9, 0))
	local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.6, 0))
	if top.Z < 0 and bot.Z < 0 then return end
	local h = math.abs(top.Y - bot.Y)
	local w = h / 1.7
	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, w, 0, h)
	box.Position = UDim2.new(0, top.X - w/2, 0, top.Y)
	box.BackgroundTransparency = 1
	box.Parent = box2DFolder
	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.ESPColor
	stroke.Thickness = 1.6
	stroke.Parent = box
end

local lastESP = 0
local function updateESP()
	if not CONFIG.ShowESP or not CONFIG.Enabled then
		clearAllESP()
		return
	end
	if tick() - lastESP < 0.08 then return end
	lastESP = tick()
	clearAllESP()

	local meuRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isValid(plr.Character) then
			local char = plr.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			if root and meuRoot then
				local dist = (root.Position - meuRoot.Position).Magnitude
				if dist <= CONFIG.ESPMaxDistance then
					if CONFIG.ShowHighlight then
						local hl = Instance.new("Highlight")
						hl.Adornee = char
						hl.FillColor = CONFIG.ESPColor
						hl.OutlineColor = Color3.new(1,1,1)
						hl.FillTransparency = 0.7
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = espFolder
					end
					if CONFIG.ShowBox2D then
						create2DBox(char)
					end
				end
			end
		end
	end
end

local function aim(part)
	if not part then return end
	local cf = CFrame.lookAt(Camera.CFrame.Position, part.Position)
	Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - CONFIG.Smoothness)
end

local noclipConn
local function updateNoclip()
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if CONFIG.Noclip and CONFIG.Enabled then
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Died:Connect(function()
			if CONFIG.QuitOnDeath then
				LocalPlayer:Kick("Tigrinho - Quit on Death")
			end
		end)
	end
end)

-- ====================== INPUT ======================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isHoldingAim = true
	end

	-- Tecla Ç ou C → Revistar
	if input.KeyCode == Enum.KeyCode.Cedilla or input.KeyCode == Enum.KeyCode.C then
		fazerRevistar()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isHoldingAim = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not CONFIG.Enabled then
		clearAllESP()
		updateNoclip()
		fovCircle.Visible = false
		return
	end

	fovCircle.Visible = CONFIG.ShowFOV
	updateESP()
	updateNoclip()

	if CONFIG.Aimbot and isHoldingAim then
		local t = findTarget()
		if t then aim(t) end
	end
end)

print("[Tigrinho] 🐯 Pronto | Tudo desativado | Revistar usa o FOV")
