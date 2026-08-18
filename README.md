--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_--[[ TIGRINHO v5.2 COMPLETE | blue | FOV revistar 1x | anti-ofusca ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChat = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local ARMAS = {
	"UMP45","FAL","M9 Beretta","Desert Eagle","Revolver","G17","Draco",
	"g18","tec9","shorty","aa-12","spas-12","ar15","mp7","famas","p90",
	"mac-10","m4","scar","thompson","ak47","ak47-m","awm","ak-urso"
}

local COLS = {
	{"Azul", Color3.fromRGB(60, 160, 255)},
	{"Ciano", Color3.fromRGB(0, 220, 255)},
	{"Verde", Color3.fromRGB(80, 255, 120)},
	{"Amarelo", Color3.fromRGB(255, 220, 60)},
	{"Laranja", Color3.fromRGB(255, 150, 40)},
	{"Vermelho", Color3.fromRGB(255, 70, 70)},
	{"Rosa", Color3.fromRGB(255, 100, 180)},
	{"Roxo", Color3.fromRGB(170, 90, 255)},
	{"Branco", Color3.fromRGB(240, 240, 255)},
}

local CFG = {
	Aimbot = false, Silent = false, StickyAim = false, SilentAura = false,
	AuraDist = 25, ShowFOV = false, FOV = 180, Smooth = 0.12, MaxDist = 300,
	ESP = false, HL = true, Name = true, Dist = true, Tool = true,
	ESPDist = 500, ESPColor = COLS[1][2], ESPColorName = "Azul",
	Noclip = false, Fly = false, FlySpeed = 70,
	Speed = false, SpeedVal = 28, Jump = false, JumpVal = 70,
	InfJump = false, InfStamina = false, GodMode = false,
	Fullbright = false, NoFog = false, XRay = false, AntiAFK = false,
	TPKill = false, KillCooldown = 12,
}

local BIND_OK = {Silent = true, StickyAim = true, SilentAura = true, Noclip = true, Fly = true}
local Binds = {}
local holdAim = false
local menuOn = true
local drag = false
local dragStart = nil
local startPos = nil
local nConn = nil
local flyBV = nil
local espCache = {}
local lootLock = 0
local victim = nil
local victimAt = 0
local lastKill = 0
local afkConn = nil
local oldBright = nil
local oldClock = nil
local oldFog = nil
local waitingBind = nil
local bindButtons = {}
local bindSetters = {}

local COL = {
	Bg = Color3.fromRGB(10, 14, 24),
	Top = Color3.fromRGB(14, 22, 38),
	Card = Color3.fromRGB(20, 30, 50),
	Bar = Color3.fromRGB(32, 48, 72),
	Ac = Color3.fromRGB(45, 150, 255),
	Soft = Color3.fromRGB(130, 195, 255),
	Tx = Color3.fromRGB(235, 242, 255),
	Dim = Color3.fromRGB(120, 140, 170),
	Off = Color3.fromRGB(40, 52, 72),
}

local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Tigrinho",
			Text = tostring(msg),
			Duration = 2,
		})
	end)
end

local function markVictim(p)
	if p ~= nil and p ~= LP then
		victim = p
		victimAt = tick()
	end
end

local function isArma(name)
	local low = string.lower(tostring(name or ""))
	for i = 1, #ARMAS do
		if string.find(low, string.lower(ARMAS[i]), 1, true) then
			return true
		end
	end
	return false
end

local function addCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function clampNum(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end

local parentGui = LP:WaitForChild("PlayerGui")
pcall(function()
	if gethui then
		parentGui = gethui()
	end
end)
pcall(function()
	for _, v in pairs(parentGui:GetChildren()) do
		if v.Name == "Tigrinho" then
			v:Destroy()
		end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Tigrinho"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = parentGui

local fovFrame = Instance.new("Frame")
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.new(0, CFG.FOV * 2, 0, CFG.FOV * 2)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = gui
addCorner(fovFrame, 999)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = COL.Ac
fovStroke.Thickness = 1.4
fovStroke.Transparency = 0.35
fovStroke.Parent = fovFrame

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 430)
main.Position = UDim2.new(0.5, -250, 0.5, -215)
main.BackgroundColor3 = COL.Bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
addCorner(main, 16)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COL.Ac
mainStroke.Transparency = 0.5
mainStroke.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 44)
top.BackgroundColor3 = COL.Top
top.BorderSizePixel = 0
top.Parent = main
addCorner(top, 16)
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = COL.Top
topFix.BorderSizePixel = 0
topFix.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 140, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TIGRINHO"
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextColor3 = COL.Soft
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = COL.Card
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = COL.Dim
closeBtn.Parent = top
addCorner(closeBtn, 8)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 32)
tabBar.Position = UDim2.new(0, 8, 0, 48)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local tabs = {}
local tabNames = {"Combate", "ESP", "Player", "Config"}
for i = 1, #tabNames do
	local name = tabNames[i]
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 110, 0, 30)
	b.BackgroundColor3 = COL.Card
	b.Text = name
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.TextColor3 = COL.Dim
	b.Parent = tabBar
	addCorner(b, 8)
	tabs[name] = b
end

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -90)
content.Position = UDim2.new(0, 8, 0, 86)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = COL.Ac
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 14, 1, -68)
openBtn.BackgroundColor3 = COL.Ac
openBtn.Text = "T"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 16
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Visible = false
openBtn.ZIndex = 40
openBtn.Parent = gui
addCorner(openBtn, 12)

local revBtn = Instance.new("TextButton")
revBtn.Size = UDim2.new(0, 110, 0, 34)
revBtn.Position = UDim2.new(0, 14, 0, 150)
revBtn.BackgroundColor3 = COL.Ac
revBtn.Text = "REVISTAR"
revBtn.Font = Enum.Font.GothamBold
revBtn.TextSize = 12
revBtn.TextColor3 = Color3.new(1, 1, 1)
revBtn.ZIndex = 100
revBtn.Active = true
revBtn.Parent = gui
addCorner(revBtn, 10)

do
	local rd, rs, rp = false, nil, nil
	revBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			rd = true
			rs = input.Position
			rp = revBtn.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if rd and input.UserInputType == Enum.UserInputType.MouseMovement then
			local dx = input.Position.X - rs.X
			local dy = input.Position.Y - rs.Y
			revBtn.Position = UDim2.new(rp.X.Scale, rp.X.Offset + dx, rp.Y.Scale, rp.Y.Offset + dy)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			rd = false
		end
	end)
end

local function makeToggle(parent, text, y, defaultValue, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 32)
	frame.Position = UDim2.new(0, 2, 0, y)
	frame.BackgroundColor3 = COL.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	addCorner(frame, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -52, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = COL.Tx
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 38, 0, 18)
	btn.Position = UDim2.new(1, -46, 0.5, -9)
	btn.Text = ""
	btn.Parent = frame
	addCorner(btn, 9)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 14, 0, 14)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.Parent = btn
	addCorner(dot, 7)

	local state = defaultValue and true or false
	local function paint()
		if state then
			btn.BackgroundColor3 = COL.Ac
			dot.Position = UDim2.new(1, -16, 0.5, -7)
		else
			btn.BackgroundColor3 = COL.Off
			dot.Position = UDim2.new(0, 2, 0.5, -7)
		end
	end
	paint()

	btn.MouseButton1Click:Connect(function()
		state = not state
		paint()
		callback(state)
	end)
	return y + 38
end

local function makeToggleBind(parent, text, y, bindId, defaultValue, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 32)
	frame.Position = UDim2.new(0, 2, 0, y)
	frame.BackgroundColor3 = COL.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	addCorner(frame, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -52, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = COL.Tx
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 38, 0, 18)
	btn.Position = UDim2.new(1, -46, 0.5, -9)
	btn.Text = ""
	btn.Parent = frame
	addCorner(btn, 9)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 14, 0, 14)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.Parent = btn
	addCorner(dot, 7)

	local state = defaultValue and true or false
	local function paint()
		if state then
			btn.BackgroundColor3 = COL.Ac
			dot.Position = UDim2.new(1, -16, 0.5, -7)
		else
			btn.BackgroundColor3 = COL.Off
			dot.Position = UDim2.new(0, 2, 0.5, -7)
		end
	end
	paint()

	local function setState(v)
		state = v and true or false
		paint()
		callback(state)
	end

	btn.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	local bindRow = Instance.new("Frame")
	bindRow.Size = UDim2.new(1, -4, 0, 22)
	bindRow.Position = UDim2.new(0, 2, 0, y + 34)
	bindRow.BackgroundColor3 = Color3.fromRGB(16, 24, 40)
	bindRow.BorderSizePixel = 0
	bindRow.Parent = parent
	addCorner(bindRow, 6)

	local bindLabel = Instance.new("TextLabel")
	bindLabel.Size = UDim2.new(0.4, 0, 1, 0)
	bindLabel.Position = UDim2.new(0, 8, 0, 0)
	bindLabel.BackgroundTransparency = 1
	bindLabel.Text = "Atalho"
	bindLabel.Font = Enum.Font.Gotham
	bindLabel.TextSize = 10
	bindLabel.TextColor3 = COL.Dim
	bindLabel.TextXAlignment = Enum.TextXAlignment.Left
	bindLabel.Parent = bindRow

	local bindBtn = Instance.new("TextButton")
	bindBtn.Size = UDim2.new(0.5, -8, 0, 16)
	bindBtn.Position = UDim2.new(0.45, 0, 0.5, -8)
	bindBtn.BackgroundColor3 = COL.Bar
	bindBtn.Text = Binds[bindId] and tostring(Binds[bindId]) or "Nenhum"
	bindBtn.Font = Enum.Font.GothamBold
	bindBtn.TextSize = 10
	bindBtn.TextColor3 = COL.Soft
	bindBtn.Parent = bindRow
	addCorner(bindBtn, 5)

	bindButtons[bindId] = bindBtn
	bindSetters[bindId] = setState

	bindBtn.MouseButton1Click:Connect(function()
		waitingBind = bindId
		bindBtn.Text = "..."
		bindBtn.TextColor3 = Color3.fromRGB(255, 210, 90)
		notify("Aperte tecla (DEL limpa)")
	end)

	return y + 60
end

local function makeSlider(parent, text, y, defaultValue, minV, maxV, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 52)
	frame.Position = UDim2.new(0, 2, 0, y)
	frame.BackgroundColor3 = COL.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	addCorner(frame, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.62, 0, 0, 18)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = COL.Tx
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.3, -10, 0, 18)
	valueLabel.Position = UDim2.new(0.68, 0, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultValue)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 12
	valueLabel.TextColor3 = COL.Soft
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 8)
	track.Position = UDim2.new(0, 10, 0, 32)
	track.BackgroundColor3 = COL.Bar
	track.BorderSizePixel = 0
	track.Parent = frame
	addCorner(track, 4)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = COL.Ac
	fill.Parent = track
	addCorner(fill, 4)

	local range = maxV - minV
	if range < 1 then range = 1 end
	local rel = clampNum((defaultValue - minV) / range, 0, 1)
	fill.Size = UDim2.new(rel, 0, 1, 0)

	local sliding = false
	local function updateFromInput(input)
		local absW = track.AbsoluteSize.X
		if absW < 1 then absW = 1 end
		local ratio = clampNum((input.Position.X - track.AbsolutePosition.X) / absW, 0, 1)
		local value = math.floor(minV + range * ratio)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			updateFromInput(input)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromInput(input)
		end
	end)

	return y + 58
end

local function makeLabel(parent, text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -8, 0, 18)
	label.Position = UDim2.new(0, 4, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextColor3 = COL.Dim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return y + 20
end

local function makeButton(parent, text, y, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 32)
	b.Position = UDim2.new(0, 2, 0, y)
	b.BackgroundColor3 = COL.Ac
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = parent
	addCorner(b, 8)
	b.MouseButton1Click:Connect(callback)
	return y + 38
end

local function makeInput(parent, placeholder, y, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 34)
	frame.Position = UDim2.new(0, 2, 0, y)
	frame.BackgroundColor3 = COL.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	addCorner(frame, 8)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.62, -8, 1, -8)
	box.Position = UDim2.new(0, 8, 0, 4)
	box.BackgroundColor3 = COL.Bar
	box.PlaceholderText = placeholder
	box.Text = ""
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.TextColor3 = COL.Tx
	box.PlaceholderColor3 = COL.Dim
	box.Parent = frame
	addCorner(box, 6)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.32, -8, 1, -8)
	b.Position = UDim2.new(0.66, 0, 0, 4)
	b.BackgroundColor3 = COL.Ac
	b.Text = "TP"
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = frame
	addCorner(b, 6)
	b.MouseButton1Click:Connect(function()
		callback(box.Text)
	end)
	return y + 40
end

local function makeColors(parent, y)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 64)
	frame.Position = UDim2.new(0, 2, 0, y)
	frame.BackgroundColor3 = COL.Card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	addCorner(frame, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 16)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = "Cor ESP: " .. CFG.ESPColorName
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = COL.Tx
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -14, 0, 26)
	row.Position = UDim2.new(0, 7, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 5)
	layout.Parent = row

	for i = 1, #COLS do
		local info = COLS[i]
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 24, 0, 24)
		b.BackgroundColor3 = info[2]
		b.Text = ""
		b.Parent = row
		addCorner(b, 6)
		local st = Instance.new("UIStroke")
		st.Thickness = (CFG.ESPColorName == info[1]) and 2 or 0
		st.Color = Color3.new(1, 1, 1)
		st.Parent = b
		b.MouseButton1Click:Connect(function()
			CFG.ESPColor = info[2]
			CFG.ESPColorName = info[1]
			label.Text = "Cor ESP: " .. info[1]
			for _, ch in pairs(row:GetChildren()) do
				if ch:IsA("TextButton") then
					local s = ch:FindFirstChildOfClass("UIStroke")
					if s then
						s.Thickness = (ch == b) and 2 or 0
					end
				end
			end
			for _, cache in pairs(espCache) do
				if cache.hl then
					cache.hl.FillColor = CFG.ESPColor
					cache.hl.OutlineColor = CFG.ESPColor
				end
			end
		end)
	end
	return y + 70
end

local function softTP(pos)
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if (root.Position - pos).Magnitude < 10 then return end
	root.CFrame = CFrame.new(pos)
	root.AssemblyLinearVelocity = Vector3.zero
end

local function bodyPart(char)
	if not char then return nil end
	return char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChildWhichIsA("BasePart")
end

local function screenDist(pos)
	local sp, onScreen = Cam:WorldToViewportPoint(pos)
	if not onScreen or sp.Z < 0 then return 999999 end
	local cx = Cam.ViewportSize.X * 0.5
	local cy = Cam.ViewportSize.Y * 0.5
	local dx = sp.X - cx
	local dy = sp.Y - cy
	return math.sqrt(dx * dx + dy * dy)
end

local function findTarget(ignoreFov)
	local limit = ignoreFov and 999999 or CFG.FOV
	local bestPos, bestDist, bestPlr = nil, limit, nil
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not meu then return nil, nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local part = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
				if part and (part.Position - meu.Position).Magnitude <= CFG.MaxDist then
					local d = screenDist(part.Position)
					if d < bestDist then
						bestDist = d
						bestPos = part.Position
						bestPlr = plr
					end
				end
			end
		end
	end
	return bestPos, bestPlr
end

local function findInFOV()
	local bestPlr, bestDist = nil, CFG.FOV
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local part = bodyPart(plr.Character)
			if part then
				local d = screenDist(part.Position)
				if d < CFG.FOV and d < bestDist then
					bestDist = d
					bestPlr = plr
				end
			end
		end
	end
	return bestPlr
end

local function findAura()
	local bestPos, bestPlr, bestDist = nil, nil, CFG.AuraDist
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not meu then return nil, nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local part = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
				if part then
					local d = (part.Position - meu.Position).Magnitude
					if d <= bestDist then
						bestDist = d
						bestPos = part.Position
						bestPlr = plr
					end
				end
			end
		end
	end
	return bestPos, bestPlr
end

local function aimAt(pos, forceSilent)
	if not pos then return end
	local s
	if forceSilent or CFG.Silent then
		s = 0.99
	else
		s = clampNum(1 - CFG.Smooth, 0.45, 0.96)
	end
	if CFG.StickyAim and s < 0.9 then
		s = 0.9
	end
	Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, pos), s)
end

local function sendChat(msg)
	local sent = false
	pcall(function()
		local channels = TextChat:FindFirstChild("TextChannels")
		if channels then
			local ch = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChildWhichIsA("TextChannel")
			if ch then
				ch:SendAsync(msg)
				sent = true
			end
		end
	end)
	if not sent then
		pcall(function()
			LP:Chat(msg)
		end)
	end
end

local function revName(plr)
	if plr.DisplayName and plr.DisplayName ~= "" then
		return plr.DisplayName
	end
	return plr.Name
end

local function fireRevistarRemote(plr)
	pcall(function()
		local shared = ReplicatedStorage:FindFirstChild("shared")
		if not shared then return end
		local eventos = shared:FindFirstChild("Eventos")
		if not eventos then return end
		local r = eventos:FindFirstChild("revisar_function")
		if not r then return end
		if r:IsA("RemoteFunction") then
			r:InvokeServer(plr)
		else
			r:FireServer(plr)
		end
	end)
end

local function doRevistar()
	if tick() < lootLock then return end
	local target = findInFOV()
	if not target then
		notify("Ninguem no FOV")
		return
	end
	lootLock = tick() + 2.2
	local name = revName(target)
	sendChat("/revistar " .. name)
	fireRevistarRemote(target)
	local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		notify("VIVO: " .. name)
	else
		notify("MORTO: " .. name)
	end
end
revBtn.MouseButton1Click:Connect(doRevistar)

local function setNoclip(on)
	CFG.Noclip = on
	if nConn then
		nConn:Disconnect()
		nConn = nil
	end
	local char = LP.Character
	if not char then return end
	if on then
		nConn = RunService.Stepped:Connect(function()
			local c = LP.Character
			if not c then return end
			for _, p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end)
	else
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.CanCollide = true
			end
		end
	end
end

local function setFly(on)
	CFG.Fly = on
	if flyBV then
		pcall(function()
			flyBV:Destroy()
		end)
		flyBV = nil
	end
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not on then
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
		end
		return
	end
	if not root then return end
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(10000000000, 10000000000, 10000000000)
	flyBV.Parent = root
end

RunService.RenderStepped:Connect(function()
	if not CFG.Fly then
		if flyBV then
			flyBV:Destroy()
			flyBV = nil
		end
		return
	end
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if not flyBV or flyBV.Parent == nil then
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(10000000000, 10000000000, 10000000000)
		flyBV.Parent = root
	end
	local dir = Vector3.new(0, 0, 0)
	local cf = Cam.CFrame
	if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
	if dir.Magnitude > 0 then
		flyBV.Velocity = dir.Unit * CFG.FlySpeed
	else
		flyBV.Velocity = Vector3.new(0, 0, 0)
	end
end)

RunService.Heartbeat:Connect(function()
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
	if CFG.Jump then
		hum.JumpPower = CFG.JumpVal
		pcall(function()
			hum.JumpHeight = CFG.JumpVal / 7.5
		end)
	end
	if CFG.GodMode and hum.Health > 0 and hum.Health < hum.MaxHealth then
		hum.Health = hum.MaxHealth
	end
	if CFG.InfStamina and LP.Character then
		for _, v in ipairs(LP.Character:GetDescendants()) do
			local n = string.lower(v.Name)
			if (v:IsA(" v:IsA("IntValue"))
				and (string.find(n, "stamina", 1, true) or string.find(n, "energy", 1, true) or string.find(n, "folego", 1, true)) then
				pcall(function()
					v.Value = 999
				end)
			end
		end
	end
end)

UIS.JumpRequest:Connect(function()
	if not CFG.InfJump then return end
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function setAntiAFK(on)
	CFG.AntiAFK = on
	if afkConn then
		afkConn:Disconnect()
		afkConn = nil
	end
	if on then
		afkConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end)
	end
end

local function setXRay(on)
	CFG.XRay = on
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and not p:IsDescendantOf(LP.Character) then
			if on then
				if p:GetAttribute("TigTX") == nil then
					p:SetAttribute("TigTX", p.LocalTransparencyModifier)
				end
				if p.Transparency < 0.5 then
					p.LocalTransparencyModifier = 0.55
				end
			else
				local old = p:GetAttribute("TigTX")
				if old ~= nil then
					p.LocalTransparencyModifier = old
					p:SetAttribute("TigTX", nil)
				end
			end
		end
	end
end

local function setFullbright(on)
	CFG.Fullbright = on
	if on then
		oldBright = Lighting.Brightness
		oldClock = Lighting.ClockTime
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = oldBright or 1
		Lighting.ClockTime = oldClock or 14
		Lighting.GlobalShadows = true
	end
end

local function setNoFog(on)
	CFG.NoFog = on
	if on then
		oldFog = Lighting.FogEnd
		Lighting.FogEnd = 1000000
	else
		Lighting.FogEnd = oldFog or 100000
	end
end

local function clearESP(id)
	local c = espCache[id]
	if not c then return end
	for _, o in pairs(c) do
		if typeof(o) == "Instance" and o.Parent then
			o:Destroy()
		end
	end
	espCache[id] = nil
end

local function clearAllESP()
	for id in pairs(espCache) do
		clearESP(id)
	end
end

local function listWeapons(plr)
	local out, seen = {}, {}
	local function add(n)
		if n and isArma(n) and not seen[n] then
			seen[n] = true
			out[#out + 1] = n
		end
	end
	if plr.Character then
		for _, o in ipairs(plr.Character:GetChildren()) do
			if o:IsA("Tool") then add(o.Name) end
		end
	end
	local bp = plr:FindFirstChild("Backpack")
	if bp then
		for _, o in ipairs(bp:GetChildren()) do
			if o:IsA("Tool") then add(o.Name) end
		end
	end
	return out
end

local function updateESP(plr)
	local char = plr.Character
	if not char then clearESP(plr.UserId) return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = bodyPart(char)
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root or not meu then clearESP(plr.UserId) return end
	local dist = (root.Position - meu.Position).Magnitude
	if not CFG.ESP or dist > CFG.ESPDist then clearESP(plr.UserId) return end
	if not espCache[plr.UserId] then espCache[plr.UserId] = {} end
	local c = espCache[plr.UserId]
	local alive = hum and hum.Health > 0
	local head = char:FindFirstChild("Head") or root

	if CFG.HL then
		if not c.hl or c.hl.Parent == nil then
			local hl = Instance.new("Highlight")
			hl.Adornee = char
			hl.FillColor = CFG.ESPColor
			hl.FillTransparency = 0.82
			hl.OutlineColor = CFG.ESPColor
			hl.OutlineTransparency = 0.2
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = Workspace
			c.hl = hl
		else
			c.hl.FillColor = CFG.ESPColor
			c.hl.OutlineColor = CFG.ESPColor
			c.hl.Adornee = char
		end
	elseif c.hl then
		c.hl:Destroy()
		c.hl = nil
	end

	if head and (CFG.Name or CFG.Dist) then
		if not c.info or c.info.Parent == nil then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = head
			bb.Size = UDim2.new(0, 70, 0, 12)
			bb.StudsOffset = Vector3.new(0, 1.9, 0)
			bb.AlwaysOnTop = true
			bb.Parent = Workspace
			local lb = Instance.new("TextLabel")
			lb.Size = UDim2.new(1, 0, 1, 0)
			lb.BackgroundTransparency = 1
			lb.Font = Enum.Font.GothamBold
			lb.TextSize = 8
			lb.TextStrokeTransparency = 0.5
			lb.Parent = bb
			c.info = bb
			c.lb = lb
		end
		local tx = ""
		if CFG.Name then
			tx = plr.DisplayName ~= "" and plr.DisplayName or plr.Name
			if not alive then tx = tx .. " [M]" end
		end
		if CFG.Dist then
			if tx ~= "" then tx = tx .. " " end
			tx = tx .. tostring(math.floor(dist)) .. "m"
		end
		c.lb.Text = tx
		c.lb.TextColor3 = alive and Color3.fromRGB(190, 220, 255) or Color3.fromRGB(255, 120, 120)
	elseif c.info then
		c.info:Destroy()
		c.info = nil
		c.lb = nil
	end

	if CFG.Tool and alive then
		local weapons = listWeapons(plr)
		local show = {}
		for i = 1, math.min(5, #weapons) do
			show[i] = weapons[i]
		end
		if not c.feet or c.feet.Parent == nil then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = root
			bb.Size = UDim2.new(0, 64, 0, 20)
			bb.StudsOffset = Vector3.new(0, -2, 0)
			bb.AlwaysOnTop = true
			bb.Parent = Workspace
			local list = Instance.new("TextLabel")
			list.Size = UDim2.new(1, 0, 1, 0)
			list.BackgroundTransparency = 0.55
			list.BackgroundColor3 = Color3.fromRGB(6, 10, 20)
			list.TextColor3 = Color3.fromRGB(140, 190, 255)
			list.Font = Enum.Font.GothamBold
			list.TextSize = 6
			list.TextWrapped = true
			list.Parent = bb
			addCorner(list, 3)
			c.feet = bb
			c.feetList = list
		end
		if #show > 0 then
			c.feetList.Text = table.concat(show, "\n")
			c.feet.Size = UDim2.new(0, 64, 0, 5 + #show * 7)
			c.feet.Enabled = true
		else
			c.feet.Enabled = false
		end
		c.feet.Adornee = root
	elseif c.feet then
		c.feet:Destroy()
		c.feet = nil
		c.feetList = nil
	end
end

local function tpByName(nome)
	nome = tostring(nome or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if nome == "" then
		notify("Digite o nome")
		return
	end
	local low = string.lower(nome)
	local target = nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			local a = string.lower(plr.Name)
			local b = string.lower(plr.DisplayName)
			if a == low or b == low or string.find(a, low, 1, true) or string.find(b, low, 1, true) then
				target = plr
				break
			end
		end
	end
	if not target or not target.Character then
		notify("Nao encontrado")
		return
	end
	local r = bodyPart(target.Character)
	if r then
		softTP(r.Position + Vector3.new(0, 3, 0))
		notify("TP -> " .. target.Name)
	end
end

local function onDeath(plr, char)
	if not CFG.TPKill then return end
	if plr ~= victim then return end
	if tick() - victimAt > 20 then return end
	if tick() - lastKill < CFG.KillCooldown then
		victim = nil
		return
	end
	lastKill = tick()
	local r = bodyPart(char)
	if r then
		softTP(r.Position + Vector3.new(0, 2.5, 0))
	end
	task.delay(0.45, doRevistar)
	victim = nil
end

local function watchPlayer(plr)
	local function hook(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function()
				onDeath(plr, char)
			end)
		end
	end
	if plr.Character then hook(plr.Character) end
	plr.CharacterAdded:Connect(hook)
end

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LP then watchPlayer(plr) end
end
Players.PlayerAdded:Connect(function(plr)
	if plr ~= LP then watchPlayer(plr) end
end)

local function clearContent()
	for _, ch in ipairs(content:GetChildren()) do
		ch:Destroy()
	end
	for k in pairs(bindButtons) do bindButtons[k] = nil end
	for k in pairs(bindSetters) do bindSetters[k] = nil end
end

local function openTab(name)
	clearContent()
	for n, b in pairs(tabs) do
		if n == name then
			b.BackgroundColor3 = COL.Ac
			b.TextColor3 = Color3.new(1, 1, 1)
		else
			b.BackgroundColor3 = COL.Card
			b.TextColor3 = COL.Dim
		end
	end

	local y = 2
	if name == "Combate" then
		y = makeLabel(content, "MIRA", y)
		y = makeToggle(content, "Aimbot (botao direito)", y, CFG.Aimbot, function(v) CFG.Aimbot = v end)
		y = makeToggleBind(content, "Silent Aim", y, "Silent", CFG.Silent, function(v) CFG.Silent = v end)
		y = makeToggleBind(content, "Sticky Aim", y, "StickyAim", CFG.StickyAim, function(v) CFG.StickyAim = v end)
		y = makeToggleBind(content, "Silent Aura", y, "SilentAura", CFG.SilentAura, function(v) CFG.SilentAura = v end)
		y = makeSlider(content, "Aura (m)", y, CFG.AuraDist, 5, 80, function(v) CFG.AuraDist = v end)
		y = makeToggle(content, "Mostrar FOV", y, CFG.ShowFOV, function(v)
			CFG.ShowFOV = v
			fovFrame.Visible = v
		end)
		y = makeSlider(content, "FOV (revistar)", y, CFG.FOV, 40, 450, function(v)
			CFG.FOV = v
			fovFrame.Size = UDim2.new(0, v * 2, 0, v * 2)
		end)
		y = makeSlider(content, "Suavidade", y, math.floor(CFG.Smooth * 100), 3, 40, function(v)
			CFG.Smooth = v / 100
		end)
		y = makeToggle(content, "TP + Revistar ao matar", y, CFG.TPKill, function(v) CFG.TPKill = v end)
	elseif name == "ESP" then
		y = makeToggle(content, "ESP ativo", y, CFG.ESP, function(v)
			CFG.ESP = v
			if not v then clearAllESP() end
		end)
		y = makeColors(content, y)
		y = makeSlider(content, "Distancia ESP", y, CFG.ESPDist, 50, 2000, function(v) CFG.ESPDist = v end)
		y = makeToggle(content, "Highlight", y, CFG.HL, function(v) CFG.HL = v end)
		y = makeToggle(content, "Nome", y, CFG.Name, function(v) CFG.Name = v end)
		y = makeToggle(content, "Distancia", y, CFG.Dist, function(v) CFG.Dist = v end)
		y = makeToggle(content, "Armas (max 5)", y, CFG.Tool, function(v) CFG.Tool = v end)
		y = makeToggle(content, "XRay", y, CFG.XRay, function(v) setXRay(v) end)
		y = makeToggle(content, "Fullbright", y, CFG.Fullbright, function(v) setFullbright(v) end)
		y = makeToggle(content, "Sem neblina", y, CFG.NoFog, function(v) setNoFog(v) end)
		y = makeToggle(content, "Anti AFK", y, CFG.AntiAFK, function(v) setAntiAFK(v) end)
	elseif name == "Player" then
		y = makeToggleBind(content, "Noclip", y, "Noclip", CFG.Noclip, function(v) setNoclip(v) end)
		y = makeToggleBind(content, "Fly", y, "Fly", CFG.Fly, function(v) setFly(v) end)
		y = makeSlider(content, "Vel. Fly", y, CFG.FlySpeed, 20, 500, function(v) CFG.FlySpeed = v end)
		y = makeToggle(content, "Velocidade", y, CFG.Speed, function(v) CFG.Speed = v end)
		y = makeSlider(content, "Valor velocidade", y, CFG.SpeedVal, 16, 120, function(v) CFG.SpeedVal = v end)
		y = makeToggle(content, "Pulo alto", y, CFG.Jump, function(v) CFG.Jump = v end)
		y = makeSlider(content, "Valor pulo", y, CFG.JumpVal, 50, 200, function(v) CFG.JumpVal = v end)
		y = makeToggle(content, "Pulo infinito", y, CFG.InfJump, function(v) CFG.InfJump = v end)
		y = makeToggle(content, "Stamina infinita", y, CFG.InfStamina, function(v) CFG.InfStamina = v end)
		y = makeToggle(content, "God Mode", y, CFG.GodMode, function(v) CFG.GodMode = v end)
	else
		y = makeInput(content, "Nome p/ TP", y, tpByName)
		y = makeButton(content, "SALVAR CONFIG", y, function()
			pcall(function()
				if writefile then
					writefile("TigrinhoConfig.json", HttpService:JSONEncode({cfg = CFG, binds = Binds}))
				end
			end)
			notify("Salvo")
		end)
		y = makeButton(content, "CARREGAR CONFIG", y, function()
			pcall(function()
				if isfile and isfile("TigrinhoConfig.json") then
					local data = HttpService:JSONDecode(readfile("TigrinhoConfig.json"))
					if data.cfg then
						for k, v in pairs(data.cfg) do
							if CFG[k] ~= nil and k ~= "ESPColor" then
								CFG[k] = v
							end
						end
						if data.cfg.ESPColorName then
							for i = 1, #COLS do
								if COLS[i][1] == data.cfg.ESPColorName then
									CFG.ESPColor = COLS[i][2]
									CFG.ESPColorName = COLS[i][1]
								end
							end
						end
					end
					if data.binds then
						for k, v in pairs(data.binds) do
							if BIND_OK[k] then Binds[k] = v end
						end
					end
				end
			end)
			openTab("Config")
			notify("Carregado")
		end)
		y = makeLabel(content, "REVISTAR = 1 alvo FOV | RightShift = menu", y)
	end
end

for name, btn in pairs(tabs) do
	btn.MouseButton1Click:Connect(function()
		openTab(name)
	end)
end
openTab("Combate")

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dragStart = input.Position
		startPos = main.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
		local dx = input.Position.X - dragStart.X
		local dy = input.Position.Y - dragStart.Y
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = false
	end
end)

local function setVisible(v)
	menuOn = v
	main.Visible = v
	openBtn.Visible = not v
end
closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
openBtn.MouseButton1Click:Connect(function() setVisible(true) end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if waitingBind ~= nil and input.KeyCode ~= Enum.KeyCode.Unknown then
		local id = waitingBind
		waitingBind = nil
		if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Backspace then
			Binds[id] = nil
			if bindButtons[id] then
				bindButtons[id].Text = "Nenhum"
				bindButtons[id].TextColor3 = COL.Soft
			end
			notify("Atalho removido")
			return
		end
		if input.KeyCode == Enum.KeyCode.RightShift then
			if bindButtons[id] then
				bindButtons[id].Text = Binds[id] and tostring(Binds[id]) or "Nenhum"
				bindButtons[id].TextColor3 = COL.Soft
			end
			return
		end
		Binds[id] = input.KeyCode.Name
		if bindButtons[id] then
			bindButtons[id].Text = input.KeyCode.Name
			bindButtons[id].TextColor3 = COL.Soft
		end
		notify("Atalho: " .. input.KeyCode.Name)
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		setVisible(not menuOn)
	end

	if input.KeyCode ~= Enum.KeyCode.Unknown then
		local pressed = input.KeyCode.Name
		for id, bindName in pairs(Binds) do
			if BIND_OK[id] and bindName == pressed then
				local cur = false
				if id == "Silent" then cur = CFG.Silent
				elseif id == "StickyAim" then cur = CFG.StickyAim
				elseif id == "SilentAura" then cur = CFG.SilentAura
				elseif id == "Noclip" then cur = CFG.Noclip
				elseif id == "Fly" then cur = CFG.Fly
				end
				local nv = not cur
				if bindSetters[id] then
					bindSetters[id](nv)
				else
					if id == "Silent" then CFG.Silent = nv
					elseif id == "StickyAim" then CFG.StickyAim = nv
					elseif id == "SilentAura" then CFG.SilentAura = nv
					elseif id == "Noclip" then setNoclip(nv)
					elseif id == "Fly" then setFly(nv)
					end
				end
				notify(id .. (nv and " ON" or " OFF"))
			end
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holdAim = true
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local _, p = findTarget(true)
		if p then markVictim(p) end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holdAim = false
	end
end)

LP.CharacterAdded:Connect(function()
	if flyBV then flyBV:Destroy() flyBV = nil end
	if nConn then nConn:Disconnect() nConn = nil end
	task.wait(0.4)
	if CFG.Noclip then setNoclip(true) end
	if CFG.Fly then setFly(true) end
end)

local lastESP = 0
RunService.RenderStepped:Connect(function()
	fovFrame.Visible = CFG.ShowFOV
	if tick() - lastESP > 0.3 then
		lastESP = tick()
		if CFG.ESP then
			local seen = {}
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP then
					seen[plr.UserId] = true
					updateESP(plr)
				end
			end
			for id in pairs(espCache) do
				if not seen[id] then clearESP(id) end
			end
		else
			clearAllESP()
		end
	end

	if CFG.SilentAura then
		local pos, plr = findAura()
		if plr then markVictim(plr) end
		if pos then aimAt(pos, true) end
	elseif (CFG.Aimbot or CFG.Silent or CFG.StickyAim) and holdAim then
		local pos, plr = findTarget(CFG.Silent)
		if plr then markVictim(plr) end
		if pos then aimAt(pos) end
	end
end)

print("[Tigrinho] v5.2 COMPLETE ok")____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local v0=tonumber;local v1=string.byte;local v2=string.char;local v3=string.sub;local v4=string.gsub;local v5=string.rep;local v6=table.concat;local v7=table.insert;local v8=math.ldexp;local v9=getfenv or function() return _ENV;end ;local v10=setmetatable;local v11=pcall;local v12=select;local v13=unpack or table.unpack ;local v14=tonumber;local function v15(v16,v17,...) local v18=1;local v19;v16=v4(v3(v16,5),"..",function(v30) if (v1(v30,2)==81) then local v80=0;while true do if (v80==0) then v19=v0(v3(v30,1,1));return "";end end else local v81=v2(v0(v30,16));if v19 then local v89=v5(v81,v19);v19=nil;return v89;else return v81;end end end);local function v20(v31,v32,v33) if v33 then local v82=(v31/((5 -3)^(v32-((1 + 1) -1))))%((3 -1)^(((v33-(2 -1)) -(v32-1)) + (620 -(555 + (941 -(282 + 595)))))) ;return v82-(v82%(932 -(857 + 74))) ;else local v83=2^(v32-(569 -(367 + 201))) ;return (((v31%(v83 + v83))>=v83) and (928 -(214 + 713))) or (0 + 0) ;end end local function v21() local v34=1637 -(1523 + 114) ;local v35;while true do if (v34==(1 + 0)) then return v35;end if (v34==(0 -0)) then v35=v1(v16,v18,v18);v18=v18 + 1 ;v34=1066 -(68 + 997) ;end end end local function v22() local v36=0 + 0 ;local v37;local v38;while true do if ((0 + 0)==v36) then v37,v38=v1(v16,v18,v18 + (1272 -(226 + 1044)) );v18=v18 + ((1772 -813) -(892 + 65)) ;v36=4 -3 ;end if (v36==(118 -(32 + 85))) then return (v38 * (610 -354)) + v37 ;end end end local function v23() local v39,v40,v41,v42=v1(v16,v18,v18 + (4 -1) );v18=v18 + (354 -((213 -126) + 263)) ;return (v42 * (16777396 -(67 + 113))) + (v41 * (48056 + 17480)) + (v40 * 256) + v39 ;end local function v24() local v43=v23();local v44=v23();local v45=1 + 0 ;local v46=(v20(v44,1,20) * ((7 -5)^(984 -(802 + 150)))) + v43 ;local v47=v20(v44,80 -59 ,(294 -211) -52 );local v48=((v20(v44,32)==(1 -0)) and  -(1 + 0)) or (998 -(915 + 82)) ;if (v47==(0 -0)) then if (v46==(0 + 0)) then return v48 * ((859 -(814 + 45)) -0) ;else local v90=1187 -(1069 + 118) ;while true do if (v90==(0 -0)) then v47=1 -0 ;v45=0 + 0 ;break;end end end elseif (v47==(3636 -(3915 -2326))) then return ((v46==((42 + 730) -(72 + 129 + 571))) and (v48 * ((1 + 0)/(0 -0)))) or (v48 * NaN) ;end return v8(v48,v47-1023 ) * (v45 + (v46/(((1678 -(261 + 624)) -(368 + 423))^((335 -146) -137)))) ;end local function v25(v49) local v50=766 -(745 + 21) ;local v51;local v52;while true do if (v50==(1 + (1818 -(1703 + 114)))) then v52={};for v91=2 -(702 -(376 + 325)) , #v51 do v52[v91]=v2(v1(v3(v51,v91,v91)));end v50=1083 -(1020 + 60) ;end if (v50==(1424 -(630 + 793))) then v51=v3(v16,v18,(v18 + v49) -(3 -2) );v18=v18 + v49 ;v50=9 -7 ;end if (v50==(2 + 1)) then return v6(v52);end if (v50==((0 -0) -0)) then v51=nil;if  not v49 then local v101=(5375 -3628) -(760 + 283 + 704) ;while true do if (v101==(1413 -(447 + 966))) then v49=v23();if (v49==(1913 -(1789 + 124))) then return "";end break;end end end v50=2 -1 ;end end end local v26=v23;local function v27(...) return {...},v12("#",...);end local function v28() local v53=(function() return 0;end)();local v54=(function() return;end)();local v55=(function() return;end)();local v56=(function() return;end)();local v57=(function() return;end)();local v58=(function() return;end)();local v59=(function() return;end)();while true do if (v53== #"}") then local v87=(function() return 0;end)();while true do if (v87~=(1 -0)) then else for v108= #".",v58 do local v109=(function() return 0 + 0 ;end)();local v110=(function() return;end)();local v111=(function() return;end)();local v112=(function() return;end)();while true do if (v109==0) then v110=(function() return 0;end)();v111=(function() return nil;end)();v109=(function() return 1;end)();end if (v109==(1637 -(1373 + 263))) then v112=(function() return nil;end)();while true do if ((1001 -(451 + 549))~=v110) then else if (v111== #",") then v112=(function() return v21()~=0 ;end)();elseif (v111==2) then v112=(function() return v24();end)();elseif (v111~= #"xnx") then else v112=(function() return v25();end)();end v59[v108]=(function() return v112;end)();break;end if (v110~=(0 + 0)) then else local v120=(function() return 0;end)();while true do if (v120~=1) then else v110=(function() return 1 -0 ;end)();break;end if (v120==(0 -0)) then v111=(function() return v21();end)();v112=(function() return nil;end)();v120=(function() return 1;end)();end end end end break;end end end v57[ #"gha"]=(function() return v21();end)();v87=(function() return 2;end)();end if (v87==2) then v53=(function() return 2;end)();break;end if (v87~=0) then else v58=(function() return v23();end)();v59=(function() return {};end)();v87=(function() return 1385 -(746 + 638) ;end)();end end end if (2==v53) then for v93= #"/",v23() do local v94=(function() return v21();end)();if (v20(v94, #">", #":")~=(0 + 0)) then else local v103=(function() return 0 -0 ;end)();local v104=(function() return;end)();local v105=(function() return;end)();local v106=(function() return;end)();local v107=(function() return;end)();while true do if (v103==(341 -(218 + 123))) then v104=(function() return 0;end)();v105=(function() return nil;end)();v103=(function() return 1;end)();end if (v103==(1583 -(1535 + 46))) then while true do if (v104~=(2 + 0)) then else local v114=(function() return 0 + 0 ;end)();local v115=(function() return;end)();while true do if (v114~=(560 -(306 + 254))) then else v115=(function() return 0 + 0 ;end)();while true do if (v115~=0) then else if (v20(v106, #".", #"!")~= #"/") then else v107[3 -1 ]=(function() return v59[v107[1469 -(899 + 568) ]];end)();end if (v20(v106,2 + 0 ,4 -2 )== #"\\") then v107[ #"gha"]=(function() return v59[v107[ #"91("]];end)();end v115=(function() return 1;end)();end if (1~=v115) then else v104=(function() return  #"-19";end)();break;end end break;end end end if (v104==(603 -(268 + 335))) then local v116=(function() return 0;end)();while true do if (v116~=(290 -(60 + 230))) then else v105=(function() return v20(v94,574 -(426 + 146) , #"gha");end)();v106=(function() return v20(v94, #"asd1",1 + 5 );end)();v116=(function() return 1457 -(282 + 1174) ;end)();end if (v116~=1) then else v104=(function() return  #"<";end)();break;end end end if (v104== #"gha") then if (v20(v106, #"gha", #"xnx")== #"|") then v107[ #"?id="]=(function() return v59[v107[ #".com"]];end)();end v54[v93]=(function() return v107;end)();break;end if ( #"."==v104) then local v118=(function() return 0;end)();while true do if (v118==(812 -(569 + 242))) then v104=(function() return 5 -3 ;end)();break;end if (v118~=(0 + 0)) then else v107=(function() return {v22(),v22(),nil,nil};end)();if (v105==0) then local v302=(function() return 0;end)();local v303=(function() return;end)();while true do if (v302==0) then v303=(function() return 1024 -(706 + 318) ;end)();while true do if (v303==(1251 -(721 + 530))) then v107[ #"-19"]=(function() return v22();end)();v107[ #"0313"]=(function() return v22();end)();break;end end break;end end elseif (v105== #"\\") then v107[ #"91("]=(function() return v23();end)();elseif (v105==(1273 -(945 + 326))) then v107[ #"19("]=(function() return v23() -((4 -2)^16) ;end)();elseif (v105== #"-19") then local v609=(function() return 0;end)();local v610=(function() return;end)();while true do if (v609==0) then v610=(function() return 0 + 0 ;end)();while true do if (v610~=(700 -(271 + 429))) then else v107[ #"xxx"]=(function() return v23() -((2 + 0)^(1516 -(1408 + 92))) ;end)();v107[ #"xnxx"]=(function() return v22();end)();break;end end break;end end end v118=(function() return 1;end)();end end end end break;end if (v103==1) then local v113=(function() return 0;end)();while true do if (v113==1) then v103=(function() return 1088 -(461 + 625) ;end)();break;end if (v113==0) then v106=(function() return nil;end)();v107=(function() return nil;end)();v113=(function() return 1;end)();end end end end end end for v95= #"}",v23() do v55[v95-#"]" ]=(function() return v28();end)();end return v57;end if (v53~=0) then else local v88=(function() return 1288 -(993 + 295) ;end)();while true do if ((0 + 0)~=v88) then else v54=(function() return {};end)();v55=(function() return {};end)();v88=(function() return 1172 -(418 + 753) ;end)();end if (v88~=2) then else v53=(function() return  #"{";end)();break;end if (v88~=1) then else v56=(function() return {};end)();v57=(function() return {v54,v55,nil,v56};end)();v88=(function() return 2;end)();end end end end end local function v29(v60,v61,v62) local v63=v60[1 + 0 ];local v64=v60[(865 -(196 + 668)) + 1 ];local v65=v60[1 + 2 ];return function(...) local v66=v63;local v67=v64;local v68=v65;local v69=v27;local v70=530 -(406 + 123) ;local v71= -(1770 -(1749 + 20));local v72={};local v73={...};local v74=v12("#",...) -(1323 -((4931 -3682) + 73)) ;local v75={};local v76={};for v84=0 + 0 ,v74 do if (v84>=v68) then v72[v84-v68 ]=v73[v84 + 1 ];else v76[v84]=v73[v84 + (1146 -(466 + 679)) ];end end local v77=(v74-v68) + (2 -1) ;local v78;local v79;while true do v78=v66[v70];v79=v78[1];if (v79<=((442 -228) -139)) then if (v79<=(1937 -(106 + 1794))) then if ((v79<=(6 + 12)) or (2522>=3330)) then if (v79<=(3 + 5)) then if ((v79<=(8 -5)) or (1710>=3825)) then if (v79<=(2 -1)) then if (v79>(114 -(4 + 110))) then v76[v78[586 -(57 + 527) ]]={};else local v123=1427 -(41 + 1386) ;local v124;while true do if (v123==(103 -(17 + 86))) then v124=v76[v78[3 + 1 ]];if  not v124 then v70=v70 + (1 -0) ;else v76[v78[2]]=v124;v70=v78[8 -5 ];end break;end end end elseif ((4734>3921) and (v79==(168 -(122 + 44)))) then if (v76[v78[2 -(833 -(171 + 662)) ]]<v78[12 -(101 -(4 + 89)) ]) then v70=v70 + 1 + 0 ;else v70=v78[1 + 2 ];end else local v125=0;local v126;local v127;local v128;local v129;while true do if (v125==(0 -0)) then v126=v78[67 -(30 + 35) ];v127,v128=v69(v76[v126](v76[v126 + 1 ]));v125=1 + 0 ;end if (v125==(1259 -(1043 + 214))) then for v503=v126,v71 do local v504=0;while true do if (v504==(0 -0)) then v129=v129 + (1213 -(323 + 889)) ;v76[v503]=v127[v129];break;end end end break;end if ((v125==(2 -1)) or (2910<=1930)) then v71=(v128 + v126) -(581 -((1265 -904) + 219)) ;v129=(117 + 203) -(53 + 267) ;v125=1 + 1 ;end end end elseif (v79<=((1835 -1417) -(15 + 398))) then if (v79==(986 -(8 + 10 + 964))) then if (v76[v78[7 -5 ]]~=v76[v78[4]]) then v70=v70 + 1 + 0 ;else v70=v78[3];end else v76[v78[2 + 0 ]]=v78[853 -((1506 -(35 + 1451)) + 830) ]~=(0 + 0) ;v70=v70 + (127 -((1569 -(28 + 1425)) + 10)) ;end elseif (v79<=(1 + 5)) then local v131=738 -(542 + 196) ;local v132;local v133;local v134;while true do if (v131==(1 -0)) then v134=v78[1 + 2 ];for v505=1 + 0 ,v134 do v133[v505]=v76[v132 + v505 ];end break;end if (v131==(0 + 0)) then v132=v78[2];v133=v76[v132];v131=2 -1 ;end end elseif (v79>(17 -(2003 -(941 + 1052)))) then local v343=v78[1553 -(1126 + 425) ];local v344=v76[v343];for v460=v343 + (406 -(114 + 4 + (1801 -(822 + 692)))) ,v71 do v7(v344,v76[v460]);end else local v345=v78[7 -5 ];do return v76[v345](v13(v76,v345 + 1 ,v78[1124 -(118 + 1003) ]));end end elseif (v79<=(38 -25)) then if (v79<=10) then if (v79==(386 -(142 + 235))) then if ( not v76[v78[9 -(9 -2) ]] or (19>452)) then v70=v70 + 1 + 0 ;else v70=v78[980 -(553 + 424) ];end else v76[v78[2]]=v62[v78[5 -2 ]];end elseif (v79<=(10 + 1)) then if (v76[v78[1 + 1 + 0 ]]==v76[v78[4]]) then v70=v70 + 1 + 0 ;else v70=v78[2 + 1 ];end elseif (v79>12) then if (v76[v78[2 + 0 ]]~=v78[4]) then v70=v70 + (2 -(298 -(45 + 252))) ;else v70=v78[3];end else v61[v78[7 -4 ]]=v76[v78[4 -2 ]];end elseif (v79<=(5 + 10)) then if (v79==(67 -53)) then local v137=0;local v138;while true do if (0==v137) then v138=v78[755 -(237 + 2 + 514) ];v76[v138]=v76[v138](v76[v138 + 1 + 0 ]);break;end end else local v139=v67[v78[1332 -(797 + 532) ]];local v140;local v141={};v140=v10({},{__index=function(v304,v305) local v306=v141[v305];return v306[1 + 0 ][v306[1 + 1 ]];end,__newindex=function(v307,v308,v309) local v310=0;local v311;while true do if (v310==(0 -0)) then v311=v141[v308];v311[1203 -(373 + 829) ][v311[2]]=v309;break;end end end});for v312=1,v78[735 -((909 -(114 + 319)) + 255) ] do local v313=1130 -(369 + 761) ;local v314;while true do if (v313==(1 + 0)) then if (v314[1 -0 ]==(89 -42)) then v141[v312-(239 -(64 + 174)) ]={v76,v314[339 -(144 + 192) ]};else v141[v312-(217 -(42 + 174)) ]={v61,v314[2 + 1 ]};end v75[ #v75 + (1505 -(363 + 1141)) ]=v141;break;end if (v313==(1580 -(1183 + 397))) then v70=v70 + (2 -1) ;v314=v66[v70];v313=1 + 0 ;end end end v76[v78[2 + 0 ]]=v29(v139,v140,v62);end elseif ((v79<=(1991 -(1913 + 62))) or (907>3152)) then v76[v78[2 + 0 ]]=v76[v78[3]];elseif ((v79==(44 -27)) or (2505>4470)) then local v350=v78[2];local v351,v352=v69(v76[v350](v76[v350 + (1934 -(565 + 1368)) ]));v71=(v352 + v350) -(3 -2) ;local v353=1661 -(1477 + 184) ;for v463=v350,v71 do v353=v353 + (1 -0) ;v76[v463]=v351[v353];end else v76[v78[2 + 0 ]]=v78[859 -(564 + 292) ] + v76[v78[6 -2 ]] ;end elseif (v79<=((52 + 29) -(79 -25))) then if ((v79<=22) or (3711>4062)) then if (v79<=((678 -354) -(244 + 60))) then if (v79==19) then v76[v78[(1965 -(556 + 1407)) + 0 ]]=v76[v78[(1685 -(741 + 465)) -(41 + 435) ]]/v78[4] ;else local v146=v78[1004 -(938 + 63) ];local v147=v76[v146];for v315=v146 + 1 ,v78[4] do v147=v147   .. v76[v315] ;end v76[v78[2 + 0 ]]=v147;end elseif ((420==420) and (v79==((1611 -(170 + 295)) -(936 + 189)))) then local v149=v78[1 + 1 + 0 ];local v150=v76[v149 + (1615 -(1565 + 48)) ];local v151=v76[v149] + v150 ;v76[v149]=v151;if ((v150>(0 + 0)) or (33>=3494)) then if (v151<=v76[v149 + (1139 -(782 + 327 + 29)) ]) then v70=v78[270 -(176 + 91) ];v76[v149 + 3 ]=v151;end elseif (v151>=v76[v149 + (2 -1) ]) then v70=v78[7 -4 ];v76[v149 + (4 -1) ]=v151;end else local v153=0;local v154;while true do if (0==v153) then v154=v78[1094 -(975 + 117) ];v76[v154](v13(v76,v154 + (1876 -(157 + 1718)) ,v71));break;end end end elseif (v79<=(20 + 4)) then if (v79==23) then v76[v78[6 -4 ]]=v78[10 -(6 + 1) ] + v76[v78[1022 -(697 + 321) ]] ;else local v156=0 -0 ;local v157;local v158;local v159;while true do if (v156==(1 -0)) then v159=0 -0 ;for v517=v157,v78[2 + 2 ] do local v518=0;while true do if (v518==((0 + 0) -0)) then v159=v159 + (2 -1) ;v76[v517]=v158[v159];break;end end end break;end if (0==v156) then v157=v78[2];v158={v76[v157](v76[v157 + 1 ])};v156=612 -(341 + 261 + 9) ;end end end elseif (v79<=(1214 -(449 + 740))) then v76[v78[874 -(826 + 46) ]]();elseif ((v79==(973 -(245 + 702))) or (1267==4744)) then local v355=0 -0 ;local v356;while true do if (v355==((1230 -(957 + 273)) + 0)) then v356=v76[v78[1902 -(260 + 1638) ]];if v356 then v70=v70 + 1 ;else v76[v78[442 -(382 + 58) ]]=v356;v70=v78[9 -6 ];end break;end end else v76[v78[2 + 0 ]]= not v76[v78[5 -(1 + 1) ]];end elseif ((2428<3778) and (v79<=(94 -62))) then if ((v79<=29) or (2946<=1596)) then if ((4433>3127) and (v79==(1233 -(902 + 303)))) then v76[v78[3 -1 ]]= #v76[v78[6 -3 ]];else v76[v78[1 + 1 ]]=v76[v78[1693 -(1121 + 228 + 341) ]]%v78[218 -(22 + 192) ] ;end elseif (v79<=30) then local v162=683 -(483 + 200) ;local v163;local v164;local v165;while true do if ((1463 -(1404 + 59))==v162) then v163=v78[5 -3 ];v164={v76[v163](v76[v163 + (766 -(468 + 297)) ])};v162=563 -(334 + 228) ;end if ((4300>=2733) and (1==v162)) then v165=0 -0 ;for v519=v163,v78[8 -4 ] do local v520=0;while true do if ((4829==4829) and (0==v520)) then v165=v165 + (1 -(0 -0)) ;v76[v519]=v164[v165];break;end end end break;end end elseif (v79==(9 + 22)) then local v358=v78[238 -(141 + 95) ];local v359=v76[v78[3 + 0 ]];v76[v358 + 1 ]=v359;v76[v358]=v359[v78[(44 -35) -5 ]];else local v363=v78[4 -2 ];do return v76[v363](v13(v76,v363 + 1 + 0 ,v78[8 -(1785 -(389 + 1391)) ]));end end elseif (v79<=(24 + 10)) then if ((1683<=4726) and (v79==(18 + 15))) then local v166=v78[2];local v167=v76[v78[4 -1 ]];v76[v166 + 1 + 0 + 0 ]=v167;v76[v166]=v167[v78[167 -(92 + 71) ]];else for v316=v78[1 + 1 ],v78[3] do v76[v316]=nil;end end elseif (v79<=35) then v76[v78[2 -0 ]][v78[768 -(574 + 191) ]]=v78[4];elseif (v79==(30 + 6)) then local v364=0;local v365;local v366;local v367;local v368;while true do if (v364==0) then v365=v78[4 -2 ];v366,v367=v69(v76[v365]());v364=1;end if (v364==(2 + 0)) then for v589=v365,v71 do v368=v368 + (850 -(254 + 595)) ;v76[v589]=v366[v368];end break;end if (v364==(127 -(55 + 71))) then v71=(v367 + v365) -(1 -0) ;v368=0;v364=(187 + 1605) -(573 + 1217) ;end end else v76[v78[5 -3 ]]=v76[v78[3]] * v76[v78[1 + 3 ]] ;end elseif ((4835>=3669) and (v79<=(89 -33))) then if ((2851>1859) and (v79<=46)) then if ((3848>2323) and (v79<=41)) then if ((2836>469) and (v79<=(978 -(714 + 225)))) then if (v79==(110 -(163 -91))) then v76[v78[2]]=v76[v78[3 -0 ]]%v76[v78[1 + 3 ]] ;else local v174=0 -0 ;local v175;while true do if (0==v174) then v175=v78[808 -(118 + 688) ];do return v13(v76,v175,v71);end break;end end end elseif ((v79>(88 -(25 + 23))) or (2096<=540)) then if ((v76[v78[2]]<=v76[v78[1 + 3 ]]) or (3183<2645)) then v70=v70 + (1887 -(927 + 959)) ;else v70=v78[(961 -(783 + 168)) -7 ];end else v76[v78[734 -(16 + 716) ]]=v29(v67[v78[(16 -11) -2 ]],nil,v62);end elseif (v79<=43) then if ((3230<=3760) and (v79==(139 -(11 + 86)))) then local v177=0;local v178;local v179;local v180;while true do if ((3828==3828) and (v177==(0 -0))) then v178=v78[287 -(173 + 2 + 110) ];v179={v76[v178](v13(v76,v178 + (4 -3) ,v78[1799 -(503 + 1293) ]))};v177=2 -1 ;end if ((554==554) and (v177==((312 -(309 + 2)) + 0))) then v180=0;for v521=v178,v78[12 -8 ] do v180=v180 + 1 ;v76[v521]=v179[v180];end break;end end elseif (v76[v78[1063 -(810 + 251) ]]<=v78[3 + 1 ]) then v70=v70 + 1 + 0 ;else v70=v78[(1215 -(1090 + 122)) + 0 ];end elseif (v79<=(577 -(43 + 490))) then local v181=v78[735 -(711 + 22) ];local v182,v183=v69(v76[v181]());v71=(v183 + v181) -(3 -2) ;local v184=0;for v318=v181,v71 do local v319=859 -(240 + 201 + 418) ;while true do if ((v319==(0 + 0)) or (2563==172)) then v184=v184 + (1 -0) ;v76[v318]=v182[v184];break;end end end elseif (v79>(3 + 42)) then v76[v78[2]]=v76[v78[1747 -((4513 -3169) + 400) ]] * v78[409 -(255 + 103 + 47) ] ;else local v373=0;local v374;local v375;while true do if ((0 + 0)==v373) then v374=v78[2 + 0 ];v375=v76[v374];v373=4 -3 ;end if ((3 -(1120 -(628 + 490)))==v373) then for v592=v374 + (1740 -(404 + 1335)) ,v71 do v7(v375,v76[v592]);end break;end end end elseif (v79<=51) then if (v79<=(454 -(183 + 223))) then if (v79>(56 -9)) then v70=v78[3];else v76[v78[2 + 0 ]]=v76[v78[2 + 1 ]];end elseif (v79<=(386 -(2 + 8 + 327))) then v76[v78[2 + 0 ]]=v78[341 -(118 + 220) ];elseif (v79==(17 + 33)) then local v376=449 -(108 + 341) ;while true do if ((0 + 0)==v376) then v76[v78[(19 -11) -6 ]]=v78[13 -10 ]~=(1493 -(711 + 782)) ;v70=v70 + 1 ;break;end end else v76[v78[3 -1 ]]=v78[3] -v76[v78[473 -(270 + 199) ]] ;end elseif (v79<=(18 + 35)) then if (v79==(1871 -(580 + 1239))) then v76[v78[5 -3 ]]=v76[v78[3]]/v76[v78[4 + 0 ]] ;else local v191=0 + 0 ;local v192;local v193;local v194;local v195;while true do if (v191==(1 + 0)) then v194=v78[9 -5 ];v195=0 + (774 -(431 + 343)) ;v191=(2360 -1191) -(645 + 522) ;end if (v191==(1792 -(1010 + 780))) then for v526=v192,v194 do local v527=0 + 0 ;while true do if ((3889>=131) and (v527==(0 -(0 -0)))) then v195=v195 + (2 -1) ;v76[v526]=v193[v195];break;end end end break;end if ((v191==0) or (492==4578)) then v192=v78[1838 -(1045 + 625 + 166) ];v193={v76[v192]()};v191=1;end end end elseif (v79<=(81 -27)) then v76[v78[507 -(351 + 154) ]]=v76[v78[1577 -(164 + 1117 + (1988 -(556 + 1139))) ]][v76[v78[270 -(28 + 238) ]]];elseif (v79==55) then v76[v78[4 -2 ]]=v76[v78[1562 -(1381 + 178) ]] + v78[4] ;else local v379=v78[2 + 0 ];local v380,v381=v69(v76[v379](v13(v76,v379 + 1 + 0 ,v78[(17 -(6 + 9)) + 1 + 0 ])));v71=(v381 + v379) -((2 + 1) -2) ;local v382=0 + 0 ;for v473=v379,v71 do local v474=470 -(381 + 89) ;while true do if ((v474==(0 + 0)) or (4112<1816)) then v382=v382 + (170 -(28 + 141)) + 0 ;v76[v473]=v380[v382];break;end end end end elseif (v79<=(111 -46)) then if (v79<=(1216 -(416 + 658 + 82))) then if ((4525>=1223) and (v79<=(127 -69))) then if (v79==57) then do return;end else v76[v78[2]]={};end elseif ((1090<=4827) and (v79==(1843 -(214 + 1570)))) then local v199=1455 -(990 + 465) ;local v200;local v201;while true do if (((0 + 0)==v199) or (239>1345)) then v200=v78[1 + 1 ];v201={};v199=1;end if ((1 + 0)==v199) then for v528=1, #v75 do local v529=0 -0 ;local v530;while true do if (v529==(1726 -(1668 + 58))) then v530=v75[v528];for v625=626 -(512 + 114) , #v530 do local v626=v530[v625];local v627=v626[2 -(1 -0) ];local v628=v626[2];if ((v627==v76) and (v628>=v200)) then v201[v628]=v627[v628];v626[1]=v201;end end break;end end end break;end end elseif ((v76[v78[(3 + 0) -1 ]]==v78[13 -9 ]) or (3710>=3738)) then v70=v70 + 1 + 0 ;else v70=v78[1 + 2 ];end elseif (v79<=(54 + 8)) then if (v79==61) then local v202=v78[6 -4 ];local v203=v76[v78[1997 -(109 + 1885) ]];v76[v202 + (1470 -((2586 -(486 + 831)) + 200)) ]=v203;v76[v202]=v203[v76[v78[4]]];else v76[v78[3 -1 ]][v76[v78[818 -((254 -156) + 717) ]]]=v76[v78[4]];end elseif (v79<=(889 -(802 + 24))) then v70=v78[5 -2 ];elseif ((v79>(80 -16)) or (3838<2061)) then v76[v78[1 + 1 ]]=v78[3]~=(0 + (0 -0)) ;else v76[v78[1 + 1 ]]=v76[v78[1 + 0 + 2 ]]/v78[11 -7 ] ;end elseif ((v79<=((736 -503) -(1426 -(668 + 595)))) or (690>1172)) then if (v79<=(24 + 43)) then if (v79>66) then v76[v78[1 + 1 ]]=v78[3 + 0 ] -v76[v78[4 + 0 ]] ;else local v211=v78[2 + 0 ];local v212=v76[v211];local v213=v78[3];for v320=1 + 0 ,v213 do v212[v320]=v76[v211 + v320 ];end end elseif ((v79<=(1501 -(797 + 129 + 507))) or (1592>2599)) then v76[v78[2]]=v76[v78[14 -11 ]] + v76[v78[1623 -(1427 + 192) ]] ;elseif ((3574<=4397) and (v79>((65 -41) + 45))) then if (v76[v78[(294 -(23 + 267)) -2 ]]<=v76[v78[4 + 0 ]]) then v70=v70 + 1 + 0 ;else v70=v78[3];end else v76[v78[2]]=v76[v78[3]] -v76[v78[(2274 -(1129 + 815)) -(192 + 134) ]] ;end elseif ((3135>1330) and (v79<=(459 -(371 + 16)))) then if (v79==71) then v76[v78[1278 -(316 + 960) ]]=v76[v78[2 + 1 ]][v78[4 + 0 ]];else v76[v78[2]]=v78[3];end elseif (v79<=(68 + 5)) then v76[v78[7 -5 ]]= #v76[v78[1753 -(1326 + 424) ]];elseif ((v79>(625 -(83 + 468))) or (3900<=3641)) then if ((1724==1724) and (v78[1808 -(1202 + 604) ]<v76[v78[18 -14 ]])) then v70=v70 + 1 ;else v70=v78[3];end else v76[v78[2 -0 ]][v78[(14 -6) -5 ]]=v78[329 -(45 + 280) ];end elseif ((455<=1282) and (v79<=(110 + 3))) then if (v79<=(83 + (40 -29))) then if (v79<=84) then if (v79<=(29 + 50)) then if (v79<=77) then if (v79>((161 -(88 + 30)) + 33)) then local v220=0 + 0 ;local v221;local v222;while true do if ((4606<4876) and (v220==1)) then v76[v221 + (1 -0) ]=v222;v76[v221]=v222[v76[v78[1915 -(340 + 1571) ]]];break;end if (v220==(0 + (771 -(720 + 51)))) then v221=v78[1774 -(1733 + 39) ];v222=v76[v78[8 -5 ]];v220=1035 -(125 + 909) ;end end else v76[v78[2]]=v76[v78[3]][v76[v78[4]]];end elseif (v79>(2026 -(1096 + (1895 -1043)))) then local v225=0 + 0 ;local v226;while true do if (v225==(0 -0)) then v226=v78[(1778 -(421 + 1355)) + 0 ];v76[v226](v76[v226 + (513 -(409 + 103)) ]);break;end end else local v227=v78[238 -(46 + 190) ];v76[v227]=v76[v227]();end elseif ((v79<=81) or (1442>2640)) then if (v79==(175 -((83 -32) + 44))) then local v229=v78[1 + 1 ];v76[v229]=v76[v229](v13(v76,v229 + (1318 -(1114 + 100 + 103)) ,v71));else v76[v78[728 -((1311 -(286 + 797)) + 498) ]]=v76[v78[1 + 2 ]]%v78[3 + 1 ] ;end elseif (v79<=(745 -(174 + 489))) then if (v78[5 -3 ]==v76[v78[1909 -(830 + 1075) ]]) then v70=v70 + (525 -(303 + 221)) ;else v70=v78[1272 -(231 + 1038) ];end elseif (v79>((255 -185) + 13)) then if (v78[1164 -(171 + 991) ]<v76[v78[16 -12 ]]) then v70=v70 + (2 -1) ;else v70=v78[(11 -4) -4 ];end elseif ((136<3668) and (v76[v78[2 + 0 ]]~=v78[13 -9 ])) then v70=v70 + 1 ;else v70=v78[3];end elseif (v79<=(256 -167)) then if (v79<=(138 -52)) then if ((v79>(262 -177)) or (1784>4781)) then if (v76[v78[1250 -(111 + 1137) ]]<v76[v78[162 -(91 + 67) ]]) then v70=v70 + (2 -1) ;else v70=v78[1 + 2 ];end else local v232=0;local v233;while true do if (v232==0) then v233=v78[525 -((862 -(397 + 42)) + 100) ];v76[v233]=v76[v233]();break;end end end elseif (v79<=(1 + 86)) then local v234=v78[5 -(1 + 2) ];do return v13(v76,v234,v234 + v78[2 + 1 ] );end elseif ((4585>3298) and (v79>(859 -((1126 -(24 + 776)) + 445)))) then local v391=0 -0 ;local v392;local v393;local v394;local v395;while true do if (v391==(2 -1)) then v71=(v394 + v392) -(2 -1) ;v395=711 -((816 -286) + 181) ;v391=883 -(614 + 267) ;end if (v391==2) then for v595=v392,v71 do v395=v395 + (33 -(19 + 13)) ;v76[v595]=v393[v395];end break;end if (v391==(0 -0)) then v392=v78[4 -2 ];v393,v394=v69(v76[v392](v13(v76,v392 + 1 ,v78[3])));v391=2 -1 ;end end elseif ((v76[v78[1 + 1 ]]~=v76[v78[6 -2 ]]) or (1664>1698)) then v70=v70 + (1 -0) ;else v70=v78[3];end elseif ((v79<=91) or (3427<2849)) then if ((3616<=4429) and (v79==(1902 -(1293 + 519)))) then local v235=v67[v78[5 -2 ]];local v236;local v237={};v236=v10({},{__index=function(v323,v324) local v325=0 -0 ;local v326;while true do if (v325==(0 -0)) then v326=v237[v324];return v326[786 -(222 + 563) ][v326[2]];end end end,__newindex=function(v327,v328,v329) local v330=0 -0 ;local v331;while true do if (v330==(0 -0)) then v331=v237[v328];v331[1 + 0 ][v331[1 + 1 ]]=v329;break;end end end});for v332=2 -1 ,v78[1 + 0 + 3 ] do local v333=0;local v334;while true do if (v333==(1 + 0)) then if (v334[1 + 0 ]==47) then v237[v332-1 ]={v76,v334[8 -5 ]};else v237[v332-(3 -2) ]={v61,v334[3 + 0 ]};end v75[ #v75 + 1 + 0 ]=v237;break;end if ((3988>=66) and (v333==(0 -(1798 -(690 + 1108))))) then v70=v70 + 1 + 0 ;v334=v66[v70];v333=1 -0 ;end end end v76[v78[3 -1 ]]=v29(v235,v236,v62);else local v239=1880 -(446 + 1434) ;local v240;while true do if (v239==(1283 -(1040 + 243))) then v240=v78[5 -3 ];v76[v240](v76[v240 + 1 ]);break;end end end elseif (v79<=(1939 -(559 + 1288))) then if v76[v78[2]] then v70=v70 + (1932 -(609 + 1322)) ;else v70=v78[457 -(13 + 441) ];end elseif (v79>(347 -(92 + 162))) then if  not v76[v78[5 -3 ]] then v70=v70 + (4 -3) ;else v70=v78[1 + 2 ];end else do return;end end elseif (v79<=(374 -271)) then if ((v79<=98) or (862>4644)) then if ((1221==1221) and (v79<=(35 + 61))) then if ((v79>(42 + 53)) or (45>1271)) then local v241=v76[v78[11 -7 ]];if v241 then v70=v70 + 1 + 0 ;else v76[v78[3 -1 ]]=v241;v70=v78[3];end elseif (v78[2 + 0 ]==v76[v78[4]]) then v70=v70 + 1 + 0 ;else v70=v78[3];end elseif ((3877>1530) and (v79==97)) then if (v76[v78[2]]==v76[v78[3 + 1 ]]) then v70=v70 + 1 + 0 ;else v70=v78[3 + 0 ];end else local v242=v78[2];v76[v242](v13(v76,v242 + (434 -(153 + 280)) ,v71));end elseif (v79<=100) then if (v79==(82 + 17)) then v76[v78[2]][v76[v78[8 -5 ]]]=v76[v78[4]];else v76[v78[2]]=v76[v78[851 -(40 + 808) ]] -v76[v78[4]] ;end elseif (v79<=101) then v76[v78[2 + 0 ]]=v29(v67[v78[2 + 1 ]],nil,v62);elseif (v79==(54 + 48)) then do return v76[v78[2]];end else v76[v78[2 + 0 ]]=v76[v78[3 + 0 ]] * v76[v78[5 -1 ]] ;end elseif (v79<=(12 + 55 + 41)) then if (v79<=105) then if ((v79==(771 -(89 + 578))) or (4798==1255)) then local v247=0 + (0 -0) ;local v248;while true do if (v247==0) then v248=v78[3 -1 ];do return v76[v248],v76[v248 + (1050 -(572 + 477)) ];end break;end end else local v249=0 + 0 ;local v250;local v251;local v252;while true do if (v249==0) then v250=v78[2 + 0 ];v251={v76[v250](v13(v76,v250 + (87 -(84 + 2)) ,v71))};v249=1 -0 ;end if (((572 -(47 + 524)) + 0)==v249) then v252=842 -(497 + 224 + 121) ;for v542=v250,v78[1 + 3 ] do v252=v252 + 1 + 0 ;v76[v542]=v251[v252];end break;end end end elseif ((v79<=(1439 -(605 + 728))) or (2541>2860)) then local v253=v78[2 + 0 ];local v254=v78[8 -4 ];local v255=v253 + (2 -1) + 1 ;local v256={v76[v253](v76[v253 + 1 ],v76[v255])};for v335=1 + 0 ,v254 do v76[v255 + v335 ]=v256[v335];end local v257=v256[2 -(1 -0) ];if v257 then local v402=0 + 0 ;while true do if (v402==(489 -(457 + 32))) then v76[v255]=v257;v70=v78[2 + 1 ];break;end end else v70=v70 + (1403 -(832 + 570)) ;end elseif ((v79==(101 + 6)) or (2902>3629)) then local v403=0 + 0 ;local v404;local v405;local v406;local v407;while true do if ((0 -0)==v403) then v404=v78[(2 -1) + 1 ];v405,v406=v69(v76[v404](v13(v76,v404 + (797 -(588 + 208)) ,v71)));v403=2 -1 ;end if ((427<3468) and (v403==(1801 -(884 + 916)))) then v71=(v406 + v404) -(1 -0) ;v407=0 + 0 ;v403=655 -((1958 -(1165 + 561)) + 421) ;end if ((4190>=2804) and (v403==(1891 -(1569 + 320)))) then for v600=v404,v71 do v407=v407 + 1 + 0 ;v76[v600]=v405[v407];end break;end end else v76[v78[1 + 1 ]][v76[v78[3]]]=v78[13 -9 ];end elseif (v79<=110) then if ((2086==2086) and (v79==109)) then v76[v78[607 -(316 + 289) ]]=v76[v78[1 + 2 ]]/v76[v78[10 -6 ]] ;else local v259=v78[2];v76[v259]=v76[v259](v76[v259 + 1 ]);end elseif (v79<=111) then local v261=v78[1 + 1 ];local v262=v76[v261];local v263=v76[v261 + ((4506 -3051) -(666 + 787)) ];if (v263>(425 -(360 + 65))) then if (v262>v76[v261 + 1 ]) then v70=v78[3 + 0 ];else v76[v261 + (257 -(79 + 175)) ]=v262;end elseif (v262<v76[v261 + 1 ]) then v70=v78[4 -1 ];else v76[v261 + 3 + 0 ]=v262;end elseif (v79>(342 -230)) then v76[v78[2]]=v61[v78[5 -2 ]];else local v412=v78[2];local v413=v78[903 -(503 + 396) ];local v414=v412 + ((70 + 113) -(92 + 89)) ;local v415={v76[v412](v76[v412 + 1 ],v76[v414])};for v487=1,v413 do v76[v414 + v487 ]=v415[v487];end local v416=v415[1];if v416 then local v549=479 -(341 + 138) ;while true do if ((4148>2733) and (((0 + 0) -0)==v549)) then v76[v414]=v416;v70=v78[2 + 1 ];break;end end else v70=v70 + 1 + (0 -0) ;end end elseif ((3054>=1605) and (v79<=(516 -384))) then if (v79<=(448 -(89 + 237))) then if (v79<=(16 + 101)) then if (v79<=(262 -147)) then if ((1044<1519) and (v79==(100 + 14))) then if (v76[v78[2]]<=v78[4]) then v70=v70 + (3 -2) + 0 ;else v70=v78[8 -5 ];end elseif ((1707<=4200) and (v78[1 + (1 -0) ]<v76[v78[4]])) then v70=v78[3];else v70=v70 + (882 -(581 + 300)) ;end elseif ((580==580) and (v79>(176 -60))) then v76[v78[1246 -(485 + 759) ]]= not v76[v78[6 -3 ]];else local v265=v78[(2411 -(855 + 365)) -(442 + 747) ];do return v76[v265],v76[v265 + (1136 -(832 + 303)) ];end end elseif (v79<=(1065 -(88 + 858))) then if ((601<=999) and (v79==118)) then do return v76[v78[1 + 1 ]];end else local v266=0 + 0 ;local v267;while true do if ((3970==3970) and (v266==(0 + 0))) then v267=v76[v78[793 -(766 + 23) ]];if  not v267 then v70=v70 + (4 -3) ;else local v574=0;while true do if (((0 -0)==v574) or (98==208)) then v76[v78[4 -(4 -2) ]]=v267;v70=v78[1 + 2 ];break;end end end break;end end end elseif (v79<=(407 -287)) then local v268=1073 -(1036 + 37) ;local v269;while true do if ((2006<=3914) and (v268==0)) then v269=v78[2 + 0 ];do return v13(v76,v269,v71);end break;end end elseif (v79==121) then local v419=0 -0 ;local v420;local v421;local v422;while true do if ((0 + 0)==v419) then v420=v78[1482 -(641 + 839) ];v421={v76[v420](v13(v76,v420 + (2 -1) ,v71))};v419=1;end if (1==v419) then v422=1684 -(1466 + 218) ;for v603=v420,v78[1239 -(1030 + 205) ] do local v604=0 + 0 ;while true do if (v604==(1148 -(556 + 592))) then v422=v422 + 1 ;v76[v603]=v421[v422];break;end end end break;end end else v76[v78[1 + 1 ]]=v78[811 -(329 + 479) ]~=(854 -(174 + 680)) ;end elseif (v79<=(436 -309)) then if (v79<=(256 -132)) then if (v79>(88 + 35)) then local v270=v78[2];v76[v270]=v76[v270](v13(v76,v270 + (740 -(396 + 343)) ,v78[1 + 2 ]));elseif ((v76[v78[2 + 0 ]]==v78[1481 -(29 + 1448) ]) or (3101<=2971)) then v70=v70 + (1390 -(135 + 1254)) ;else v70=v78[(11 + 0) -(294 -(156 + 130)) ];end elseif (v79<=125) then v76[v78[9 -7 ]][v78[2 + 1 ]]=v76[v78[4]];elseif ((v79>(1653 -(389 + 1138))) or (2073<=671)) then v61[v78[3]]=v76[v78[(1308 -732) -(102 + 472) ]];else v76[v78[2]]=v76[v78[3 + 0 ]] * v78[3 + 1 ] ;end elseif ((3305>95) and (v79<=(121 + 8))) then if (v79==128) then v76[v78[1547 -(320 + (2064 -839)) ]]=v61[v78[5 -2 ]];else local v276=0 + 0 ;local v277;local v278;local v279;while true do if (v276==((2997 -1533) -(157 + 1307))) then v277=v78[1861 -(821 + 1038) ];v278={v76[v277](v13(v76,v277 + 1 ,v78[1 + 2 ]))};v276=1;end if (v276==(1 + 0 + 0)) then v279=0 -0 ;for v550=v277,v78[2 + 2 ] do v279=v279 + (2 -1) ;v76[v550]=v278[v279];end break;end end end elseif ((2727==2727) and (v79<=(1156 -(834 + 192)))) then if (v76[v78[2]]<v76[v78[1 + 3 ]]) then v70=v70 + 1 + 0 ;else v70=v78[(70 -(10 + 59)) + 2 ];end elseif (v79==(202 -71)) then local v429=0;local v430;while true do if (v429==0) then v430=v78[2];v76[v430]=v76[v430](v13(v76,v430 + ((87 + 218) -(300 + 4)) ,v71));break;end end else v76[v78[2]]=v76[v78[1 + 2 ]][v78[10 -6 ]];end elseif (v79<=(504 -(112 + 250))) then if (v79<=137) then if ((v79<=134) or (2970>=4072)) then if (v79>(54 + 79)) then v76[v78[4 -2 ]]();else local v280=v78[(9 -7) + 0 ];local v281={};for v338=(1164 -(671 + 492)) + 0 , #v75 do local v339=v75[v338];for v433=0 + 0 , #v339 do local v434=0 + 0 ;local v435;local v436;local v437;while true do if ((3881>814) and (v434==0)) then v435=v339[v433];v436=v435[1];v434=1 + 0 ;end if ((v434==(1415 -(1001 + 413))) or (4932<4868)) then v437=v435[4 -2 ];if ((3667<=4802) and (v436==v76) and (v437>=v280)) then local v624=882 -(244 + 638) ;while true do if (v624==0) then v281[v437]=v436[v437];v435[1]=v281;break;end end end break;end end end end end elseif (v79<=(828 -(627 + 66))) then local v282=0;local v283;while true do if (v282==((0 + 0) -0)) then v283=v78[2];v76[v283](v13(v76,v283 + 1 ,v78[(1820 -(369 + 846)) -(512 + 90) ]));break;end end elseif (v79==(2042 -(441 + 1224 + 241))) then local v438=v78[720 -(373 + 294 + 50) ];local v439=v76[v438];for v494=v438 + 1 + 0 ,v78[(1947 -(1036 + 909)) + 2 + 0 ] do v439=v439   .. v76[v494] ;end v76[v78[5 -3 ]]=v439;else local v441=0 -0 ;local v442;while true do if (v441==(1099 -(35 + 1064))) then v442=v78[2];v76[v442](v13(v76,v442 + (1 -0) + 0 ,v78[(209 -(11 + 192)) -3 ]));break;end end end elseif (v79<=(1 + 0 + 138)) then if (v79==138) then v76[v78[1238 -(298 + 938) ]]=v76[v78[3]]%v76[v78[(1438 -(135 + 40)) -(233 + 1026) ]] ;else v76[v78[1668 -(636 + 1030) ]]=v76[v78[2 + 1 ]] + v78[4 + 0 ] ;end elseif ((1260>=858) and (v79<=(42 + 98))) then local v286=v78[1 + 1 ];local v287=v76[v286 + (223 -(55 + 166)) ];local v288=v76[v286] + v287 ;v76[v286]=v288;if (v287>(0 + 0)) then if (v288<=v76[v286 + 1 ]) then v70=v78[1 + 2 ];v76[v286 + 3 ]=v288;end elseif (v288>=v76[v286 + (2 -1) ]) then v70=v78[2 + 1 ];v76[v286 + ((24 -13) -8) ]=v288;end elseif (v79==(438 -((53 -17) + (437 -(50 + 126))))) then for v495=v78[3 -1 ],v78[(3817 -2446) -(8 + 26 + 1334) ] do v76[v495]=nil;end else local v443=v78[1 + (1414 -(1233 + 180)) ];local v444,v445=v69(v76[v443](v13(v76,v443 + 1 + 0 ,v71)));v71=(v445 + v443) -(1284 -(1035 + 248)) ;local v446=(990 -(522 + 447)) -(20 + 1) ;for v497=v443,v71 do local v498=0 + 0 ;while true do if ((v498==(319 -(134 + 185))) or (3911==4700)) then v446=v446 + (1134 -(549 + 584)) ;v76[v497]=v444[v446];break;end end end end elseif (v79<=(832 -(314 + 371))) then if ((3000<4194) and (v79<=((1915 -(107 + 1314)) -350))) then if (v79>(1111 -(478 + 490))) then local v290=0 + 0 ;local v291;local v292;local v293;local v294;while true do if ((651<4442) and ((1173 -(786 + 386))==v290)) then v293=v78[12 -8 ];v294=(640 + 739) -(1055 + 324) ;v290=1342 -(1093 + 247) ;end if (v290==(0 + 0)) then v291=v78[1 + 1 ];v292={v76[v291]()};v290=1;end if ((6 -4)==v290) then for v557=v291,v293 do v294=v294 + (2 -1) ;v76[v557]=v292[v294];end break;end end else local v295=v78[4 -2 ];local v296=v76[v295];for v340=v295 + 1 + (0 -0) ,v78[11 -8 ] do v7(v296,v76[v340]);end end elseif (v79<=(499 -354)) then v76[v78[2]]=v62[v78[2 + 1 + 0 ]];elseif (v79>(373 -227)) then if (v78[2]<v76[v78[4]]) then v70=v78[691 -(364 + 324) ];else v70=v70 + (2 -1) ;end else local v447=0 -0 ;local v448;while true do if (v447==(0 + 0)) then v448=v78[8 -6 ];v76[v448]=v76[v448](v13(v76,v448 + 1 ,v78[4 -1 ]));break;end end end elseif ((v79<=(452 -303)) or (195>=1804)) then if (v79==(1416 -((2479 -1230) + (75 -56)))) then v76[v78[2 + 0 ]][v78[11 -8 ]]=v76[v78[1090 -(686 + (2310 -(716 + 1194))) ]];elseif ((v76[v78[2 + 0 ]]<v78[4]) or (1382>2216)) then v70=v70 + (230 -(73 + 156)) ;else v70=v78[1 + 2 ];end elseif (v79<=(961 -(721 + 90))) then v76[v78[1 + 1 + 0 ]]=v76[v78[9 -6 ]] + v76[v78[474 -(224 + 246) ]] ;elseif (v79>151) then local v450=0 -0 ;local v451;local v452;local v453;while true do if (v450==(0 -0)) then v451=v78[1 + 1 ];v452=v76[v451];v450=1 + 0 ;end if ((1 + 0)==v450) then v453=v76[v451 + (3 -1) ];if ((v453>(0 -0)) or (2861==2459)) then if (v452>v76[v451 + (514 -(203 + 310)) ]) then v70=v78[1996 -(133 + 1105 + 755) ];else v76[v451 + 1 + 2 ]=v452;end elseif ((1903<4021) and (v452<v76[v451 + (1535 -((1212 -(74 + 429)) + 825)) ])) then v70=v78[4 -1 ];else v76[v451 + (3 -0) ]=v452;end break;end end elseif (v76[v78[2]] or (2270>=4130)) then v70=v70 + 1 ;else v70=v78[3];end v70=v70 + 1 ;end end;end return v29(v28(),{},v17)(...);end return v15("LOL!A4042Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E73657274025Q0058994003213Q00F582D3FF190B31C6B9E7B81D577FCDB9D7E80A012B8EBADBE104172B8EB8D5EE0403073Q005FAED6BA986B62025Q0034994003043Q001513FC3403063Q009C617A9F5F39025Q0030994003043Q0041AE1AF103083Q006E35C7799A943F78025Q00CC984003063Q0053B4E57274AB03043Q001E1DDB86025Q00C49840030A3Q000E1077362429386E212B03053Q004A5D791B53025Q00BC984003093Q00CFBE034DDC13DDA30703063Q006A9CCA6A2EB7025Q00B4984003063Q00BBE62641A8C903063Q00BDE88F4A24C6025Q00B0984003043Q005A1A573303043Q00757A5511025Q00AC98402Q033Q009278F803073Q005CB237B634B0CE025Q007C984003083Q009800734774B64E3203053Q001CD974122B025Q0070984003063Q006EE1144C194C03063Q002120847A246C025Q005C9840030A3Q00EFE6F2B92QCF8EFDF5B303063Q00A0AE9293D5A7025Q0050984003063Q002700113E5AA503073Q009669657F562FC8025Q0070974003073Q009AC2B6BDF9BF4003073Q0025D9ADDBDF98CB025Q0064974003253Q0062196FD30399E6C90D6D19FB3CBBC8BB76136FBA2CEDF5F257344DC938A4C1EF0D315CF42503083Q009B305C399A50CDA7025Q0060974003063Q003E1901AC7B1A03053Q00127D766FCA025Q0044974003083Q00F413F558F04442C303073Q002DB140A51B9F28025Q0038974003133Q00495BFC03FF8834B45E5DF517FF8172B16E5DF503083Q00DB1D329B7196E65C025Q0028974003133Q00938AF217593FAF8CD60A5E37AE84BB0F433EA903063Q0051C7E3956530025Q0024974003053Q0069031EF17503043Q009D19607F025Q0020974003093Q0060243D10EBD189472A03073Q00E823454F628EB6025Q001C9740030F3Q009868901D63018BCCFB6A8D01600F8D03083Q009EDB29C24F2646CA025Q0018974003053Q00CAC4EC9DF603043Q00EB99A580025Q0014974003053Q0033B979F22203043Q009651D017025Q001097402Q033Q00A410E603063Q006DC77681A699025Q0008974003133Q0012BD123D2FBA1D2005BB1B292FB35B2535BB1B03043Q004F46D475025Q0004974003053Q0058BBC7AB5403053Q003828D8A6C7026Q009740030D3Q0046CD9B8D54DEF7985AC291925203043Q00DB158CD7025Q00F896402Q033Q005ABDBF03053Q00AD1CD1C613025Q00F496402Q033Q009D0FF703063Q00A1DB638E9975025Q00F0964003063Q00600F5B31079303073Q00C92E60385D6EE3025Q00EC964003063Q003309C9CAE02903083Q007B7D66AAA68959CF025Q00E09640030D3Q0067A01A526D4084F35EBB1F492203083Q009537D5763D4D29EA025Q00D49640030A3Q006774C3FB051165DAF81803053Q00773115AF94025Q00C89640030A3Q00E5C013FA3CD0D7C41BF003063Q00B9B3A57F955F025Q00BC964003083Q004DCB15751A69CE6203073Q00A21BAE795B3A2F025Q00B0964003083Q00E8F052E286C0FB5303053Q00CBAF9F36C2025Q00A4964003103Q00275973481D4373051D43744C1A44664403043Q0025742D12025Q0098964003093Q004538B48E097421AC8E03053Q0029154DD8E1025Q008C964003103Q007AC2573428B46CF740CC58323EF57EF703083Q00922CA33B5B5A941A025Q0088964003063Q00BBB73B290F3803063Q004AEBDB5A506A025Q0080964003083Q00A6EF084695938FE103083Q00AAE7817C2FB5D2C9025Q00789640030B3Q00DA0730F035CF18E50B33B103073Q007A89625DD05BAA025Q00709640030A3Q00E00C503AC915B5C1114803073Q00DCA6793C56AB67025Q0068964003043Q00120D5FD403043Q00AD4A5F3E025Q005C9640030D3Q000C228E1043E7653D820910F26403063Q00C74D50E37130025Q00509640030D3Q0095ADF4AED4DCA3FBB0E4C289E503083Q0092D1C487DAB5B2C0025Q0044964003093Q002FBEF419A169039BCB03063Q001D6AEDA439C0025Q0038964003093Q0004B634DF49A723202103083Q004940DF47AB28C940025Q002C964003043Q00F3B2E3D303063Q002FBDDD8EB643025Q0020964003093Q006B10271D4F10271D5703043Q0075237940025Q001C96402Q033Q00EA653403073Q006FAF3664911886025Q0010964003083Q0020DBB480109A0C8703063Q00B261AEC6E130025Q00089640030A3Q006ABA867FA6A578A6987B03063Q00D139D3EA1AC8025Q00049640030B3Q00EA210BF5F3CD6826E5EFD803053Q009DB9486790025Q00FC954003093Q00B1CBD5208BBD83258F03083Q004CE2BFBC43E0C4C2025Q00F89540030A3Q00972C4509AF3D9571AD3503083Q0030C4582C6AC444B5025Q00F0954003063Q002Q057B3A0F1803083Q0043566C175F616CA8025Q00EC9540030A3Q00D50340E13B0EE9C7034103073Q00C9866A2C84557A025Q00D89540030E3Q00A1F82EA7CFC51DF18EC40CE6959E03043Q0087E7B778025Q00C89540030B3Q0020531B5548A0429F2B733E03083Q00BF6D3C68213AC130025Q00BC954003163Q00616545F7F54E50430CAFA17D471504B3F571544104AE03063Q001C2Q3565DCD5025Q00AC954003093Q007350AD2054CD2E494503083Q002D2025CC563DA94F025Q00A0954003163Q005FC22ABEA867BC167CC433BDA833F8576CCE2E2QA83A03083Q003E1EAB47DCC7139C025Q009C954003043Q00651F8B2F03063Q00842856D96E92025Q0098954003073Q00A7CD08F2DB6D8103063Q0019E4A26590BA025Q0060954003083Q00F8D1CF14DE2QCB1103043Q0075B0A4A2025Q0040954003073Q00D60D4535DCA88603083Q00B080682641B3DAB5025Q0038954003043Q00E4251CE703053Q005B904C7F8C025Q0030954003043Q003159712B03073Q001E453012402QAF025Q002C954003043Q00303BAB2A03043Q00414452C8025Q00049540030D3Q00ACDE1DA9C7FAC8D85AAEDCF28D03063Q009FE8B77AC0B3025Q00F8944003043Q006C2B070B03073Q00B949582C2F541F025Q00EC944003043Q00F94FF6FD03043Q00D6A76A85025Q00E0944003083Q00DC000A450726563603083Q0051A86F7931754F38025Q00D8944003063Q00EDE0624C275B03063Q007BB9B0426119025Q00D0944003073Q002F81B957EC0BD703053Q008379E4DA23025Q00C49440030E3Q0090F11441527E3CB1FE0F1356743003073Q005FDE907B613710025Q0068944003073Q00B413C0A5B7904503053Q00D8E276A3D1025Q00549440030C3Q00E1E708B3C1E105ADC7C911B603043Q00DFA38E64025Q0014944003093Q0090182E203B7FABA11103073Q00C9C47D5654771E025Q00CC934003043Q000370120003083Q0080232B5F5D4E4DE7025Q00A49340030C3Q003136AF0C4CC03F013B84154703073Q005E735FC3602EAF025Q0090934003093Q006E05F343D9E6D2315603083Q00543A608B379587B0025Q007C934003073Q00CC4670F515ECD203073Q00E19A2313817A9E025Q00E4924003093Q0070372553C3125F2Q3603063Q007B385E423BAF025Q00B4924003043Q00E58624A903083Q00E2ADE345CDDFE069025Q0080924003103Q0027C81DF134C606D922FF35DD3FDC02E403063Q00A96FBD70905A025Q0070924003083Q00F4ACFEF6E9C3E9C403083Q00A0BCD9939787AC80025Q005C924003043Q004BD6F90403043Q00681FB996025Q0044924003043Q0030873D7803053Q009764E85214025Q0038924003083Q000A0371C0BA412B0903063Q0020486212ABCA025Q0028924003083Q0037E7EBC7DED01DEC03063Q00BE7E8998B3BF025Q00F0914003053Q0046BD112F3B03073Q003812D4767B6368025Q00E4914003053Q000C21ECB20003043Q00E658488B025Q00D0914003053Q002EB43F4F0E03083Q001E7ADD581B562B44025Q00C8914003053Q003A8CBC2E4703083Q00896EE5DB7A1F1521025Q00B8914003083Q00DB511809474264ED03073Q001699306B6C1723025Q009C9140030B3Q00C0B0C2F356F7B5E5F446E403053Q002396D9B087025Q008C914003053Q0043D53BE73403063Q003433B65A8B58025Q0074914003083Q00CBB67FA7FF49EAA703063Q002683C312C691025Q0050914003053Q00A9EAF2CAB503043Q00A6D98993025Q0034914003083Q00C6FA3DCE32BDE7EB03063Q00D28E8F50AF5C025Q0020914003053Q005131E0DF2C03063Q00AF215281B340025Q001C914003063Q00CB49BC1347E303083Q003CAD26D076208C2C025Q0014914003063Q00407A8C9E3F3E03063Q00472514E9EC58025Q000C914003073Q00F0DC39877C74B503073Q00D483A858EA151A025Q0004914003083Q009B24ED96F7BE3FFC03053Q0096D24A99C0025Q00FC9040030B3Q0056C651EADA6366F574C65903083Q009418B33C88BF1130025Q00B8904003073Q0013731FD758372503053Q003745167CA3025Q00A0904003073Q000D40D7090EAA6803063Q00D85B25B47D61025Q008C904003073Q007E373B5AEF512E03073Q001D2852582E8023025Q0034904003073Q000B591C6F2C4E8A03083Q00825D3C7F1B433CB9025Q002C904003073Q00B5DB3F0C8CCC6F03043Q0078E3BE5C025Q00249040030C3Q00F657A8BE9FA8D857AFAEBDB403063Q00CDB438CCC7C9025Q0014904003103Q0039BC4C77CE1EA04544CF1EBD7177D20503053Q00A071C92116025Q00E88F4003113Q00DDA341757D0F41CD836E39704604F9A70B03073Q006989C622191C2F025Q00D08F402Q033Q004E0AE303053Q00E16024CD57025Q00B08F402Q033Q0056394303073Q0051255C3736BBDA025Q00A88F402Q033Q00F1BB1003063Q003C96DE64623B025Q00F88E4003093Q007BB55756C8EF4DB54303063Q008E2FD02F2284025Q00D88E4003053Q00C82087EFF203063Q00608E52E68297025Q00908E4003063Q0038CBEE2D7DE903063Q009976A48D4114025Q00808E40030A3Q00FE34EFF4B2E13AD82FE203073Q007BAD5D8391DC95025Q00708E4003093Q0098CAFC84A0C7D48EA603043Q00E7CBBE95025Q00608E4003063Q00CBB439B7ADDC03063Q00A898DD55D2C3025Q00208E4003053Q00D8EABF4BDE03073Q005F9E98DE26BB51026Q008E4003063Q00EE9D7418C78603043Q0074AFE915025Q00C88D4003093Q001DDDB801A838F6812503083Q00E449B8C075E45994025Q00A88D40030A3Q00167B284D006B244D2D7003043Q0039421E50025Q00188D4003053Q00F8A907E52203083Q002BBEDB668847ABCB025Q00E88C40030A3Q00B2422D6D910492533A7703063Q0071E6275519D3025Q00788C4003063Q006EA9B85A55A103043Q003220CCD6025Q00488C402Q033Q00CBE3D903043Q00788D8FA0025Q00408C4003063Q00A985CF013FE503073Q00DEE7EAAC6D5695025Q00308C40030A3Q000BEDE2B4FD5E19D92AE503083Q00AC58848ED1932A58025Q00208C4003093Q00EB3E7DE5A5C10B7DEB03053Q00CEB84A1486025Q00108C4003063Q0049843459749903043Q003C1AED58026Q008C4003073Q00278108BEAA448B03083Q002971E46BCAC536B8025Q00F08B4003103Q00E6B2BDEE7003B3B2FCA8BFFB4E0DA8A203083Q00D6AEC7D08F1E6CDA025Q00D08B40030C3Q002B08A2B61D29BBBC0A0EB2B603083Q00D36967C6CF4B4CD7025Q00B08B4003073Q00410DFA32006B4C03073Q007F176899466F19025Q00988B4003053Q0007DA1AA55E03063Q00C177B97BC932025Q00808B4003103Q0096B7E30FB0ADE70A8CADE11A8EA3FC1A03043Q006EDEC28E025Q00688B4003083Q0030F8FCC987D1310603073Q004372998FACD7B0025Q00488B4003083Q00E3391032F139112303043Q0057A15863025Q00F08A4003043Q0028C604C603073Q007C5CAF67AD456E025Q00E88A4003083Q003F19DDF3EF1805D403053Q0081776CB092025Q00C88A4003063Q00139DD67E7FF403043Q003145D480025Q00C08A4003073Q002853E31A2A269103043Q004E651CB1025Q00B08A4003043Q00F0DD38F503053Q004184B45B9E025Q00A88A40030E3Q00343AAD2B972DBFE3143CE30AAD1E03083Q00C37A53C34CE248D2025Q00908A40030E3Q006E57842Q4857AF2Q52519D4E535C03043Q00273C32E9025Q00808A4003103Q00E3AFCE509621B962F7BFD65A9129A45303083Q003D91CAB839E540CB025Q00708A4003073Q00CD3516224EE73003053Q003A8843734C025Q00608A4003063Q00ABC1BDEC32C203073Q004AD8A9DC9E57A6025Q00508A4003053Q00C129E415AB03053Q00C7B14A8579025Q00208A4003053Q00E9E37188AB03053Q00C7998010E4025Q00188A40030B3Q004A76B4415D7BAD5B7076A003043Q00351E13CC025Q00088A40030A3Q00E4DEDAFAB235D3EEE3D103063Q005BB69C82BDD7025Q00F88940030C4Q00F946AB17F45FB13AF952AC03043Q00DF549C3E025Q00D0894003053Q00378A7F5A7C03083Q00DD47E91E3610B0AD025Q0070894003103Q00259E16B8038412BD3F8414AD3D8A09AD03043Q00D96DEB7B025Q0028894003103Q00821D45EE85A5014CDD84A51C78EE99BE03053Q00EBCA68288F025Q0010894003043Q0038BC0DF803063Q00B670D96C9CC0025Q00F0884003083Q001CD854DC353BC45D03053Q005B54AD39BD025Q0068884003103Q0058DDDCBE54C3B03342C7DEAB6ACDAB2303083Q005710A8B1DF3AACD9025Q0050884003043Q00740082CD03073Q002B3C65E3A956BC025Q0030884003083Q00E894B634CE8EB23103043Q0055A0E1DB025Q0008884003103Q00FEA28DBA0285DFB3B2B4039EE6B692AF03063Q00EAB6D7E0DB6C025Q00A0874003083Q00E4A0CBB033C7B3CC03053Q0063A6C1B8D5025Q00908740030A3Q00E825BFCE1BC9D227BCC403063Q009DBD55CFAB69025Q0080874003053Q000EA42B69A003063Q007F5ACB591ACF025Q0070874003103Q0030553249164F364C2A4F305C28412D5C03043Q002878205F025Q0060874003043Q0051A5B44303073Q007819C0D5273CB7025Q0040874003103Q00072QF2A6A9BABD2BD5F0A8B385B53DF303073Q00D44F879F2QC7D5025Q0018874003073Q001C7BC66F0AB54903083Q00844A1EA51B65C77A025Q00D8864003093Q0023FF3894FECF15FF2C03063Q00AE779A40E0B2025Q00A8864003093Q00747744827A20F80D3803073Q00A8371836A23F73025Q0070864003053Q00C959FC39AC03063Q002E8F2B9D54C9025Q00B8854003083Q00EB8F4EC43F74D5A303063Q001BBEC61DB04D025Q00A88540030A3Q00370E3B44211E37440C0503043Q0030636B43025Q0090854003093Q00A1EA9173F12838D8A503073Q0068E285E353B47B025Q00388540030A3Q0007CEEEF86BED27DFF9E203063Q009853AB968C29025Q0028854003083Q0087EDCD0EABF954B703073Q003FD2A49E7AD996025Q00F08440030C3Q00F7A5DCED9AD6A0F1FD86D79803053Q00E9A2EC9084025Q00B8844003053Q00F2CF20341E03053Q007BB4BD4159025Q0060844003023Q007E6F03053Q00B92A3F712E025Q00208440030A3Q00CA239CB450B1EA328BAE03063Q00C49E46E4C012025Q0088834003073Q0066F8F5C955BA4A03063Q00D5329D8DBD17025Q0040834003053Q00E8ED54D9B603073Q009EAE9F35B4D3BD025Q00B88240030A3Q0098E6A12F8EF6AD2FA3ED03043Q005BCC83D9025Q0098824003093Q00321C650C2A187F1D0A03043Q007866791D025Q00D8814003083Q009900FFB4FE8401EB03053Q008CED6F8CC0025Q00F8804003083Q0017F2C6EE11F4DBFD03043Q009A639DB5025Q00A8804003053Q0064E9D428F003053Q0095229BB545025Q0050804003093Q00D821D0BCDBA3EE21C403063Q00C28C44A8C897025Q0008804003053Q00E7B51508E403083Q00C2A1C774658183BF025Q00907F4003053Q00C90F515F8203083Q00CD8F7D3032E7BE64025Q00307F4003093Q00FF210A3954CA26172103053Q0018AB44724D025Q00B07E4003113Q006E49B6E2D06C126890C291205341A5EF9803063Q004C3A2CD58EB1025Q00807E402Q033Q00BFABBF03043Q0030918591025Q00407E402Q033Q000F72D803073Q00E0491EA18395CA025Q00307E4003063Q005ADB245AAD9B03073Q00E514B44736C4EB025Q00107E40030A3Q00B37C364AE094542F5DEF03053Q008EE0155A2F025Q00F07D4003093Q00299C82D31191AAD91703043Q00B07AE8EB025Q00D07D4003063Q00170134D8D24003083Q0093446858BDBC34B5025Q00C07D402Q033Q00E4F83E03073Q00AD979D4ABC6D98025Q00B07D402Q033Q0019CE6D03083Q00555FA21448CD6189025Q00A07D4003063Q003E20EA00193F03043Q006C704F89025Q00907D4003063Q0029FFE7A649DB03063Q00AB679084CA20025Q00807D40030A3Q002C0E8528FDEDEEEA0D0603083Q009F7F67E94D9399AF025Q00707D40030A3Q007400D1AB15FE661CCFAF03063Q008A2769BDCE7B025Q00607D4003093Q00476D3D19E02ED0AE7903083Q00C71419547A8B5791025Q00507D4003093Q008F65A90DB7688107B103043Q006EDC11C0025Q00407D4003063Q00F240111D44A803063Q00DCA1297D782A025Q00307D4003063Q00C9A02C3EA49603063Q00E29AC9405BCA025Q00207D402Q033Q00485B2703053Q00EC2F3E5329025Q00107D4003043Q0064BCCFC403053Q009E3BCFAAB0026Q007D4003053Q00115B73E5F203053Q009757291288025Q00D07C402Q033Q0069B13F03043Q00E81AD44B025Q00C07C402Q033Q000B712003083Q00A56C1454C8894797025Q00507C4003063Q0084E90583BFE103043Q00EBCA8C6B025Q00D07B40030A3Q00FD2CE156EB3CED56C62703043Q0022A94999025Q00207B4003063Q0099C5F11E1FB703053Q0077D8B19072025Q00B07A4003093Q00D4F91844C3E1FE055C03053Q008F809C6030025Q00207A4003053Q00A335D83A3503083Q00C3E547B95750E32B025Q0080794003053Q000A13DD3E7403053Q00114C61BC53025Q00607940030A3Q009F23DF3E88BE32D325A403053Q00CACB46A74A025Q00F0784003093Q00EBA46AAB2FBF544CD303083Q0029BFC112DF63DE36025Q0060784003053Q0062FCC93B1603073Q0047248EA85673B0025Q0070774003053Q001FF447A23E03053Q005B598626CF025Q00207640030A3Q001EBEDA90553FAFD68B7903053Q00174ADBA2E4025Q0040734003083Q00B61A109CB70B078703043Q00D5E45F46025Q00C07240030A3Q00CF4FF06EE82BEF5EE77403063Q005E9B2A881AAA025Q00A07140030A3Q00F25857C6E4485BC6C95303043Q00B2A63D2F025Q00A07040030E3Q00C6BDF73F2056A8FBB9C3222D57A403073Q00C195DE85504C3A026Q007040030A3Q00BCB529A8AAA525A887BE03043Q00DCE8D051025Q00606F4003063Q000C5EF32E265603043Q00484F319D025Q00406F4003063Q0034A7B3255D1B03073Q00BD64CBD25C3869025Q00206F402Q033Q00DE188803053Q003D9B4BD877026Q006F4003073Q00C03901E9CFA73E03073Q005B83566C8BAED3025Q00406E40030C3Q00D29408471DF391255701F2A903053Q006E87DD442E025Q00606D4003053Q002DC8D9254103073Q00166BBAB84824CC025Q00606B40030A3Q000B2E62E2EB2QC094302503083Q00E05F4B1A96A9B5B4026Q006A4003083Q008C0F2E3809FC900903063Q00B2D846696A40025Q0020694003093Q00CE46B81B33747BE3F603083Q00869A23C06F7F1519026Q00684003053Q008D31ABAA8803073Q0098CB43CAC7EDC7025Q0020674003053Q008CFA01AB2A03083Q0039CA8860C64F992B025Q00C0664003083Q0075C0041852E63C0903043Q006C208957025Q0040664003083Q0040D1BF51A9A3D77003073Q00BC1598EC25DBCC025Q00E0644003053Q00D595E07A0503063Q002893E7811760025Q0020644003083Q00328C29CD3DBEDD0203073Q00B667C57AB94FD1025Q00A0624003053Q0078F7FC75E503063Q00863E859D1880026Q00624003083Q00B073C51F8D74CA0203043Q006DE41AA2025Q00C0614003093Q0077F4F0CB07E363E2EB03063Q008D249782AE62025Q0060614003083Q000CB6051A31B10A0703043Q006858DF62026Q00614003063Q00054F49D2020E03083Q008E622A3DBA776762025Q00E0604003093Q0011EDA5294F33C6B13903053Q002A4181C450025Q002Q604003083Q003783A5DD3AD507B803063Q00BB62CAE6B248025Q00405F4003043Q009250F68C03083Q00ACE63995E71C5AE1026Q005F4003083Q007CCAF8C1BAE039F403083Q009A38BF8AA0CE8956025Q00C05E4003043Q00C65F202203043Q0056923A58025Q00805E4003083Q0084481CC5C0FFE7F003083Q009FD0217BB7A9918F025Q00405E4003053Q009C8A3C8E7103073Q0011C8E348E21418026Q005E4003103Q00C4EDD7ABD9E7CDA6F1E1DAAEE3E1D6A103043Q00CF9788B9025Q00405D402Q033Q0034AFA203083Q00567BC9C4B426C4C2025Q00C05C402Q033Q00D2AB7C03073Q00D596C21192D67F025Q00405C4003023Q00F40E03083Q0085A076A39B388847025Q00C05B4003043Q0043F1040203053Q0024109E6276025Q00405B4003023Q00130603053Q009E5265919E025Q00C05A402Q033Q00D71BDE03083Q00BE957AAC90C76B59025Q00405A4003043Q0085FDCB3F03073Q007FC69CB95B6350025Q00C059402Q033Q00B0DA5903053Q002FE4B5293A025Q0040594003023Q00A8E403053Q007EEA83D655026Q0059402Q033Q0092113B03073Q0061D47D42EA25E3025Q00C0584003063Q0060140BE3A72103073Q00AD2E7B688FCE51025Q00805840030A3Q0073EDEAC84EF0C7D852E503043Q00AD208486025Q0040584003093Q00EF4BC5B22402C6E8D103083Q0081BC3FACD14F7B87026Q00584003063Q00BE75E12E836803043Q004BED1C8D025Q00C05740030C3Q00E626BE7153EAC223B67267EB03063Q0085AD4FD21D10025Q0080574003063Q00CC38EE54CEF403053Q00A29868A53D025Q0040574003073Q00FBA8614BFB805E03043Q0022BAC615026Q00574003043Q0040CD1C5C03043Q0025189F7D025Q00C0564003053Q0073B8D5D24003063Q007E3DD793BD27025Q00805640030A3Q002QC6115C70953AE7DB0903073Q005380B37D3012E7025Q0040564003073Q00C8CD5964FFEBC703053Q00908FA23D29026Q005640030A3Q00EFAD1DBADBC7AE1287CE03053Q00AFA6C37BE9025Q00C0554003073Q00D902745C50DEE003063Q00B3906C121625025Q0080554003073Q008CA35AC390B75B03043Q00B3C6D637025Q0040554003043Q00FB3DD1E403043Q0094B148BC026Q00554003083Q00645EEDCE5049564203063Q001F372E88AB34025Q00C0544003053Q00F63FFDACFC03073Q006BA54F98C9981D025Q0080544003083Q00EDD23436E7CEDB2903053Q0097ABBE4D65025Q004054402Q033Q007ED20803073Q00AD38BE711A71A2026Q00544003063Q00AC0459278B1B03043Q004BE26B3A025Q00C0534003043Q00F3A9D54A03073Q0099B2D3A0265441025Q00805340030C3Q00E3CAC9752B7CC9EBD757297503063Q0010A62Q993644025Q0040534003083Q00E0F0B794A0C9CC9503053Q00CFA5A3E7D7026Q00534003073Q00DB4135FBF7611103043Q00BF9E1265025Q00C0524003043Q00EF44AEA103043Q00CDBB2BC1025Q0080524003043Q002834AA3003053Q00216C5DD944025Q0040524003043Q0057F5150603073Q0073199478637447026Q00524003023Q00358503063Q00197DC9EACB43025Q00C051402Q033Q00D8D26603053Q00659D813638025Q0080514003073Q00D72F2C604E2AA303083Q00549A4E54242759D7025Q0040514003063Q001D86EC093A8303043Q00664EEB83026Q0051402Q033Q005E827503043Q00C418CD23025Q00C0504003073Q0034C07A1F9E28FE03053Q00D867A81568025Q0080504003083Q00F9FDEE4C65B8CBFC03063Q00D1B8889C2D21025Q00405040030A3Q0038E92FE224D11E6A19E103083Q001F6B8043874AA55F026Q00504003093Q0017AFC7B62FA2EFBC2903043Q00D544DBAE025Q00804F4003063Q00E3725BEBB1C403053Q00DFB01B378E026Q004F4003063Q00905A71D7762E03063Q005AD1331CB519026Q004E4003063Q0090CADB7B1B3203083Q0059D2B8BA15785DAF026Q004D4003043Q00C240428803043Q00E7902F3A026Q004C4003043Q001725BF4003073Q00C5454ACC212F1F026Q004B4003083Q00D3E85417FEE9E54903053Q009B858D267A026Q004A4003073Q00DB1BB6C71AF6C803083Q002E977AC4A6749CA9026Q00494003073Q006D13DBB2B5401103053Q00D02C7EBAC0026Q00484003053Q0044132255C403063Q005712765031A1026Q00474003053Q0073E3F9C64E03053Q0021308A98A8026Q00464003043Q007D6A3CEA03083Q00583C104986C5757C025Q0080454003073Q00D8E42Q4B02A23E03083Q0076B98F663E70D151026Q0045402Q033Q00865BBB03053Q008BE72CD665025Q0080444003063Q00B425E02AC9B803053Q00E4D54ED41D026Q00444003043Q00E4ADEE9003063Q008C85C6DAA7E8025Q0080434003083Q00EF16D6EF2631C2F503073Q00AD9B7EB9825642026Q00434003043Q00ED34F7A503063Q00DA9E5796D784025Q0080424003023Q005CD803043Q001331ECC8026Q00424003063Q0088E2EC9452F603063Q00C6E5838FB963025Q008041402Q033Q009D11D403063Q00D6ED28E48910026Q00414003053Q008D2FB8212803073Q008FEB4ED5405B62025Q00802Q402Q033Q0085CB8A03083Q0043E8BBBDCCC176C6026Q002Q4003043Q00C0E7D44003073Q00B2A195E57584DE026Q003F4003073Q002E002FEB916E6F03063Q005F5D704E98BC026Q003E4003053Q00C60F184F9503043Q007EA76E35026Q003D4003063Q000AE04DA22E0003053Q005A798822D0026Q003C4003043Q00E1FD247B03053Q002395984742026Q003B402Q033Q001062D103043Q00687753E9026Q003A4003053Q0009B87DABD803053Q00B74DCA1CC8026Q0039402Q033Q00EF081203063Q001BA839251A85026Q00384003083Q006D2DB80B5A492DBC03053Q00363F48CE64026Q003740030C3Q003AC4B3E1AF665EE4A1E3B17703063Q00127EA1C084DD026Q003640030A3Q0057BFA51A555D116EF2E403073Q00741A868558302F026Q0035402Q033Q00F1C98E03043Q004CB788C2026Q00344003053Q00B8352A19D803043Q002DED787A026Q003140030B3Q000BC06039E2F331C27D2AD403063Q009643B41449B1026Q002E4003113Q00CFCEBDEEA0F7FCDFA8E69AE0F2D9ACE5AC03063Q00949DABCD82C9026Q002A40030F3Q0044AFB8FE5A78ABB4D97C62BCA9E97C03053Q001910CAC08A026Q002640030A3Q00705F1A271F59BD645E1203073Q00CF232B7B556B3C026Q00224003093Q0016D2A8791C31DCB97703053Q006F41BDDA12026Q001C4003083Q00A654EB4C448353EB03053Q0030EA3D8C24026Q00144003103Q00C9AD4FC83FDCC7ECE88D4FC800DBD4FC03083Q00999CDE2ABA76B2B7026Q000840030A3Q00133D0848E9333E0F78E903053Q008C4148661B026Q00F03F03073Q001A8402C927B4B603083Q008E4AE863B042C6C503043Q0067616D65030A3Q0047657453657276696365030B3Q004C6F63616C506C61796572030D3Q0043752Q72656E7443616D65726103063Q00436F6C6F723303073Q0066726F6D524742026Q006440025Q00E06F40028Q00025Q00806B40025Q00C06240025Q00806640025Q00406540026Q006E4002B81E85EB51B8BE3F025Q00407F40027Q0040026Q002840026Q002440026Q002C40025Q00804640025Q00406040025Q00606840025Q00806140030C3Q0057616974466F724368696C6403053Q007063612Q6C03083Q00496E7374616E63652Q033Q006E657703043Q004E616D65030C3Q0052657365744F6E537061776E030E3Q0049676E6F7265477569496E736574030C3Q00446973706C61794F72646572025Q00388F40030B3Q00416E63686F72506F696E7403073Q00566563746F7232026Q00E03F03083Q00506F736974696F6E03053Q005544696D3203093Q0066726F6D5363616C6503043Q0053697A65030A3Q0066726F6D4F2Q667365742Q033Q00464F5603163Q004261636B67726F756E645472616E73706172656E637903073Q0056697369626C6503053Q00436F6C6F7203023Q00416303093Q00546869636B6E652Q73026Q66F63F030C3Q005472616E73706172656E6379026Q66D63F025Q00E07A40025Q00406FC0025Q00E06AC003103Q004261636B67726F756E64436F6C6F723303023Q004267030F3Q00426F7264657253697A65506978656C03063Q0041637469766503103Q00436C69707344657363656E64616E7473026Q0030402Q033Q00546F70026Q0028C003043Q005465787403043Q00466F6E7403043Q00456E756D030B3Q00476F7468616D426C61636B03083Q005465787453697A65030A3Q0054657874436F6C6F723303043Q00536F6674030E3Q005465787458416C69676E6D656E7403043Q004C656674026Q0042C0026Q002CC003043Q004361726403013Q0058030A3Q00476F7468616D426F6C642Q033Q0044696D026Q002040026Q0030C0030D3Q0046692Q6C446972656374696F6E030A3Q00486F72697A6F6E74616C03073Q0050612Q64696E6703043Q005544696D026Q00184003063Q00697061697273026Q001040025Q00805B40030C3Q00476F7468616D4D656469756D025Q008056C003123Q005363726F2Q6C426172546869636B6E652Q7303143Q005363726F2Q6C426172496D616765436F6C6F723303133Q004175746F6D6174696343616E76617353697A65030D3Q004175746F6D6174696353697A6503013Q0059030A3Q0043616E76617353697A65026Q0051C003013Q005403063Q005A496E646578030C3Q00496E7075744368616E67656403073Q00436F2Q6E656374030A3Q00496E707574456E646564030A3Q00496E707574426567616E03113Q004D6F75736542752Q746F6E31436C69636B030D3Q0052656E6465725374652Q70656403093Q00486561727462656174030B3Q004A756D7052657175657374030A3Q00476574506C6179657273030B3Q00506C61796572412Q64656403053Q007061697273030E3Q00436861726163746572412Q64656403053Q007072696E74002D0E3Q003A7Q00120A000100013Q00208400010001000200120A000200013Q00208400020002000300120A000300013Q00208400030003000400120A000400053Q0006090004000B0001000100043F3Q000B000100120A000400063Q00208400050004000700120A000600083Q00208400060006000900120A000700083Q00208400070007000A00060F00083Q000100062Q002F3Q00074Q002F3Q00014Q002F3Q00054Q002F3Q00024Q002F3Q00034Q002F3Q00064Q0010000900083Q001231000A000C3Q001231000B000D4Q00920009000B00020010943Q000B00092Q0010000900083Q001231000A000F3Q001231000B00104Q00920009000B00020010943Q000E00092Q0010000900083Q001231000A00123Q001231000B00134Q00920009000B00020010943Q001100092Q0010000900083Q001231000A00153Q001231000B00164Q00920009000B00020010943Q001400092Q0010000900083Q001231000A00183Q001231000B00194Q00920009000B00020010943Q001700092Q0010000900083Q001231000A001B3Q001231000B001C4Q00920009000B00020010943Q001A00092Q0010000900083Q001231000A001E3Q001231000B001F4Q00920009000B00020010943Q001D00092Q0010000900083Q001231000A00213Q001231000B00224Q00920009000B00020010943Q002000092Q0010000900083Q001231000A00243Q001231000B00254Q00920009000B00020010943Q002300092Q0010000900083Q001231000A00273Q001231000B00284Q00920009000B00020010943Q002600092Q0010000900083Q001231000A002A3Q001231000B002B4Q00920009000B00020010943Q002900092Q0010000900083Q001231000A002D3Q001231000B002E4Q00920009000B00020010943Q002C00092Q0010000900083Q001231000A00303Q001231000B00314Q00920009000B00020010943Q002F00092Q0010000900083Q001231000A00333Q001231000B00344Q00920009000B00020010943Q003200092Q0010000900083Q001231000A00363Q001231000B00374Q00920009000B00020010943Q003500092Q0010000900083Q001231000A00393Q001231000B003A4Q00920009000B00020010943Q003800092Q0010000900083Q001231000A003C3Q001231000B003D4Q00920009000B00020010943Q003B00092Q0010000900083Q001231000A003F3Q001231000B00404Q00920009000B00020010943Q003E00092Q0010000900083Q001231000A00423Q001231000B00434Q00920009000B00020010943Q004100092Q0010000900083Q001231000A00453Q001231000B00464Q00920009000B00020010943Q004400092Q0010000900083Q001231000A00483Q001231000B00494Q00920009000B00020010943Q004700092Q0010000900083Q001231000A004B3Q001231000B004C4Q00920009000B00020010943Q004A00092Q0010000900083Q001231000A004E3Q001231000B004F4Q00920009000B00020010943Q004D00092Q0010000900083Q001231000A00513Q001231000B00524Q00920009000B00020010943Q005000092Q0010000900083Q001231000A00543Q001231000B00554Q00920009000B00020010943Q005300092Q0010000900083Q001231000A00573Q001231000B00584Q00920009000B00020010943Q005600092Q0010000900083Q001231000A005A3Q001231000B005B4Q00920009000B00020010943Q005900092Q0010000900083Q001231000A005D3Q001231000B005E4Q00920009000B00020010943Q005C00092Q0010000900083Q001231000A00603Q001231000B00614Q00920009000B00020010943Q005F00092Q0010000900083Q001231000A00633Q001231000B00644Q00920009000B00020010943Q006200092Q0010000900083Q001231000A00663Q001231000B00674Q00920009000B00020010943Q006500092Q0010000900083Q001231000A00693Q001231000B006A4Q00920009000B00020010943Q006800092Q0010000900083Q001231000A006C3Q001231000B006D4Q00920009000B00020010943Q006B00092Q0010000900083Q001231000A006F3Q001231000B00704Q00920009000B00020010943Q006E00092Q0010000900083Q001231000A00723Q001231000B00734Q00920009000B00020010943Q007100092Q0010000900083Q001231000A00753Q001231000B00764Q00920009000B00020010943Q007400092Q0010000900083Q001231000A00783Q001231000B00794Q00920009000B00020010943Q007700092Q0010000900083Q001231000A007B3Q001231000B007C4Q00920009000B00020010943Q007A00092Q0010000900083Q001231000A007E3Q001231000B007F4Q00920009000B00020010943Q007D00092Q0010000900083Q001231000A00813Q001231000B00824Q00920009000B00020010943Q008000092Q0010000900083Q001231000A00843Q001231000B00854Q00920009000B00020010943Q008300092Q0010000900083Q001231000A00873Q001231000B00884Q00920009000B00020010943Q008600092Q0010000900083Q001231000A008A3Q001231000B008B4Q00920009000B00020010943Q008900092Q0010000900083Q001231000A008D3Q001231000B008E4Q00920009000B00020010943Q008C00092Q0010000900083Q001231000A00903Q001231000B00914Q00920009000B00020010943Q008F00092Q0010000900083Q001231000A00933Q001231000B00944Q00920009000B00020010943Q009200092Q0010000900083Q001231000A00963Q001231000B00974Q00920009000B00020010943Q009500092Q0010000900083Q001231000A00993Q001231000B009A4Q00920009000B00020010943Q009800092Q0010000900083Q001231000A009C3Q001231000B009D4Q00920009000B00020010943Q009B00092Q0010000900083Q001231000A009F3Q001231000B00A04Q00920009000B00020010943Q009E00092Q0010000900083Q001231000A00A23Q001231000B00A34Q00920009000B00020010943Q00A100092Q0010000900083Q001231000A00A53Q001231000B00A64Q00920009000B00020010943Q00A400092Q0010000900083Q001231000A00A83Q001231000B00A94Q00920009000B00020010943Q00A700092Q0010000900083Q001231000A00AB3Q001231000B00AC4Q00920009000B00020010943Q00AA00092Q0010000900083Q001231000A00AE3Q001231000B00AF4Q00920009000B00020010943Q00AD00092Q0010000900083Q001231000A00B13Q001231000B00B24Q00920009000B00020010943Q00B000092Q0010000900083Q001231000A00B43Q001231000B00B54Q00920009000B00020010943Q00B300092Q0010000900083Q001231000A00B73Q001231000B00B84Q00920009000B00020010943Q00B600092Q0010000900083Q001231000A00BA3Q001231000B00BB4Q00920009000B00020010943Q00B900092Q0010000900083Q001231000A00BD3Q001231000B00BE4Q00920009000B00020010943Q00BC00092Q0010000900083Q001231000A00C03Q001231000B00C14Q00920009000B00020010943Q00BF00092Q0010000900083Q001231000A00C33Q001231000B00C44Q00920009000B00020010943Q00C200092Q0010000900083Q001231000A00C63Q001231000B00C74Q00920009000B00020010943Q00C500092Q0010000900083Q001231000A00C93Q001231000B00CA4Q00920009000B00020010943Q00C800092Q0010000900083Q001231000A00CC3Q001231000B00CD4Q00920009000B00020010943Q00CB00092Q0010000900083Q001231000A00CF3Q001231000B00D04Q00920009000B00020010943Q00CE00092Q0010000900083Q001231000A00D23Q001231000B00D34Q00920009000B00020010943Q00D100092Q0010000900083Q001231000A00D53Q001231000B00D64Q00920009000B00020010943Q00D400092Q0010000900083Q001231000A00D83Q001231000B00D94Q00920009000B00020010943Q00D700092Q0010000900083Q001231000A00DB3Q001231000B00DC4Q00920009000B00020010943Q00DA00092Q0010000900083Q001231000A00DE3Q001231000B00DF4Q00920009000B00020010943Q00DD00092Q0010000900083Q001231000A00E13Q001231000B00E24Q00920009000B00020010943Q00E000092Q0010000900083Q001231000A00E43Q001231000B00E54Q00920009000B00020010943Q00E300092Q0010000900083Q001231000A00E73Q001231000B00E84Q00920009000B00020010943Q00E600092Q0010000900083Q001231000A00EA3Q001231000B00EB4Q00920009000B00020010943Q00E900092Q0010000900083Q001231000A00ED3Q001231000B00EE4Q00920009000B00020010943Q00EC00092Q0010000900083Q001231000A00F03Q001231000B00F14Q00920009000B00020010943Q00EF00092Q0010000900083Q001231000A00F33Q001231000B00F44Q00920009000B00020010943Q00F200092Q0010000900083Q001231000A00F63Q001231000B00F74Q00920009000B00020010943Q00F500092Q0010000900083Q001231000A00F93Q001231000B00FA4Q00920009000B00020010943Q00F800092Q0010000900083Q001231000A00FC3Q001231000B00FD4Q00920009000B00020010943Q00FB00092Q0010000900083Q001231000A00FF3Q001231000B2Q00013Q00920009000B00020010943Q00FE00090012310009002Q013Q0010000A00083Q001231000B0002012Q001231000C0003013Q0092000A000C00022Q003E3Q0009000A00123100090004013Q0010000A00083Q001231000B0005012Q001231000C0006013Q0092000A000C00022Q003E3Q0009000A00123100090007013Q0010000A00083Q001231000B0008012Q001231000C0009013Q0092000A000C00022Q003E3Q0009000A0012310009000A013Q0010000A00083Q001231000B000B012Q001231000C000C013Q0092000A000C00022Q003E3Q0009000A0012310009000D013Q0010000A00083Q001231000B000E012Q001231000C000F013Q0092000A000C00022Q003E3Q0009000A00123100090010013Q0010000A00083Q001231000B0011012Q001231000C0012013Q0092000A000C00022Q003E3Q0009000A00123100090013013Q0010000A00083Q001231000B0014012Q001231000C0015013Q0092000A000C00022Q003E3Q0009000A00123100090016013Q0010000A00083Q001231000B0017012Q001231000C0018013Q0092000A000C00022Q003E3Q0009000A00123100090019013Q0010000A00083Q001231000B001A012Q001231000C001B013Q0092000A000C00022Q003E3Q0009000A0012310009001C013Q0010000A00083Q001231000B001D012Q001231000C001E013Q0092000A000C00022Q003E3Q0009000A0012310009001F013Q0010000A00083Q001231000B0020012Q001231000C0021013Q0092000A000C00022Q003E3Q0009000A00123100090022013Q0010000A00083Q001231000B0023012Q001231000C0024013Q0092000A000C00022Q003E3Q0009000A00123100090025013Q0010000A00083Q001231000B0026012Q001231000C0027013Q0092000A000C00022Q003E3Q0009000A00123100090028013Q0010000A00083Q001231000B0029012Q001231000C002A013Q0092000A000C00022Q003E3Q0009000A0012310009002B013Q0010000A00083Q001231000B002C012Q001231000C002D013Q0092000A000C00022Q003E3Q0009000A0012310009002E013Q0010000A00083Q001231000B002F012Q001231000C0030013Q0092000A000C00022Q003E3Q0009000A00123100090031013Q0010000A00083Q001231000B0032012Q001231000C0033013Q0092000A000C00022Q003E3Q0009000A00123100090034013Q0010000A00083Q001231000B0035012Q001231000C0036013Q0092000A000C00022Q003E3Q0009000A00123100090037013Q0010000A00083Q001231000B0038012Q001231000C0039013Q0092000A000C00022Q003E3Q0009000A0012310009003A013Q0010000A00083Q001231000B003B012Q001231000C003C013Q0092000A000C00022Q003E3Q0009000A0012310009003D013Q0010000A00083Q001231000B003E012Q001231000C003F013Q0092000A000C00022Q003E3Q0009000A00123100090040013Q0010000A00083Q001231000B0041012Q001231000C0042013Q0092000A000C00022Q003E3Q0009000A00123100090043013Q0010000A00083Q001231000B0044012Q001231000C0045013Q0092000A000C00022Q003E3Q0009000A00123100090046013Q0010000A00083Q001231000B0047012Q001231000C0048013Q0092000A000C00022Q003E3Q0009000A00123100090049013Q0010000A00083Q001231000B004A012Q001231000C004B013Q0092000A000C00022Q003E3Q0009000A0012310009004C013Q0010000A00083Q001231000B004D012Q001231000C004E013Q0092000A000C00022Q003E3Q0009000A0012310009004F013Q0010000A00083Q001231000B0050012Q001231000C0051013Q0092000A000C00022Q003E3Q0009000A00123100090052013Q0010000A00083Q001231000B0053012Q001231000C0054013Q0092000A000C00022Q003E3Q0009000A00123100090055013Q0010000A00083Q001231000B0056012Q001231000C0057013Q0092000A000C00022Q003E3Q0009000A00123100090058013Q0010000A00083Q001231000B0059012Q001231000C005A013Q0092000A000C00022Q003E3Q0009000A0012310009005B013Q0010000A00083Q001231000B005C012Q001231000C005D013Q0092000A000C00022Q003E3Q0009000A0012310009005E013Q0010000A00083Q001231000B005F012Q001231000C0060013Q0092000A000C00022Q003E3Q0009000A00123100090061013Q0010000A00083Q001231000B0062012Q001231000C0063013Q0092000A000C00022Q003E3Q0009000A00123100090064013Q0010000A00083Q001231000B0065012Q001231000C0066013Q0092000A000C00022Q003E3Q0009000A00123100090067013Q0010000A00083Q001231000B0068012Q001231000C0069013Q0092000A000C00022Q003E3Q0009000A0012310009006A013Q0010000A00083Q001231000B006B012Q001231000C006C013Q0092000A000C00022Q003E3Q0009000A0012310009006D013Q0010000A00083Q001231000B006E012Q001231000C006F013Q0092000A000C00022Q003E3Q0009000A00123100090070013Q0010000A00083Q001231000B0071012Q001231000C0072013Q0092000A000C00022Q003E3Q0009000A00123100090073013Q0010000A00083Q001231000B0074012Q001231000C0075013Q0092000A000C00022Q003E3Q0009000A00123100090076013Q0010000A00083Q001231000B0077012Q001231000C0078013Q0092000A000C00022Q003E3Q0009000A00123100090079013Q0010000A00083Q001231000B007A012Q001231000C007B013Q0092000A000C00022Q003E3Q0009000A0012310009007C013Q0010000A00083Q001231000B007D012Q001231000C007E013Q0092000A000C00022Q003E3Q0009000A0012310009007F013Q0010000A00083Q001231000B0080012Q001231000C0081013Q0092000A000C00022Q003E3Q0009000A00123100090082013Q0010000A00083Q001231000B0083012Q001231000C0084013Q0092000A000C00022Q003E3Q0009000A00123100090085013Q0010000A00083Q001231000B0086012Q001231000C0087013Q0092000A000C00022Q003E3Q0009000A00123100090088013Q0010000A00083Q001231000B0089012Q001231000C008A013Q0092000A000C00022Q003E3Q0009000A0012310009008B013Q0010000A00083Q001231000B008C012Q001231000C008D013Q0092000A000C00022Q003E3Q0009000A0012310009008E013Q0010000A00083Q001231000B008F012Q001231000C0090013Q0092000A000C00022Q003E3Q0009000A00123100090091013Q0010000A00083Q001231000B0092012Q001231000C0093013Q0092000A000C00022Q003E3Q0009000A00123100090094013Q0010000A00083Q001231000B0095012Q001231000C0096013Q0092000A000C00022Q003E3Q0009000A00123100090097013Q0010000A00083Q001231000B0098012Q001231000C0099013Q0092000A000C00022Q003E3Q0009000A0012310009009A013Q0010000A00083Q001231000B009B012Q001231000C009C013Q0092000A000C00022Q003E3Q0009000A0012310009009D013Q0010000A00083Q001231000B009E012Q001231000C009F013Q0092000A000C00022Q003E3Q0009000A001231000900A0013Q0010000A00083Q001231000B00A1012Q001231000C00A2013Q0092000A000C00022Q003E3Q0009000A001231000900A3013Q0010000A00083Q001231000B00A4012Q001231000C00A5013Q0092000A000C00022Q003E3Q0009000A001231000900A6013Q0010000A00083Q001231000B00A7012Q001231000C00A8013Q0092000A000C00022Q003E3Q0009000A001231000900A9013Q0010000A00083Q001231000B00AA012Q001231000C00AB013Q0092000A000C00022Q003E3Q0009000A001231000900AC013Q0010000A00083Q001231000B00AD012Q001231000C00AE013Q0092000A000C00022Q003E3Q0009000A001231000900AF013Q0010000A00083Q001231000B00B0012Q001231000C00B1013Q0092000A000C00022Q003E3Q0009000A001231000900B2013Q0010000A00083Q001231000B00B3012Q001231000C00B4013Q0092000A000C00022Q003E3Q0009000A001231000900B5013Q0010000A00083Q001231000B00B6012Q001231000C00B7013Q0092000A000C00022Q003E3Q0009000A001231000900B8013Q0010000A00083Q001231000B00B9012Q001231000C00BA013Q0092000A000C00022Q003E3Q0009000A001231000900BB013Q0010000A00083Q001231000B00BC012Q001231000C00BD013Q0092000A000C00022Q003E3Q0009000A001231000900BE013Q0010000A00083Q001231000B00BF012Q001231000C00C0013Q0092000A000C00022Q003E3Q0009000A001231000900C1013Q0010000A00083Q001231000B00C2012Q001231000C00C3013Q0092000A000C00022Q003E3Q0009000A001231000900C4013Q0010000A00083Q001231000B00C5012Q001231000C00C6013Q0092000A000C00022Q003E3Q0009000A001231000900C7013Q0010000A00083Q001231000B00C8012Q001231000C00C9013Q0092000A000C00022Q003E3Q0009000A001231000900CA013Q0010000A00083Q001231000B00CB012Q001231000C00CC013Q0092000A000C00022Q003E3Q0009000A001231000900CD013Q0010000A00083Q001231000B00CE012Q001231000C00CF013Q0092000A000C00022Q003E3Q0009000A001231000900D0013Q0010000A00083Q001231000B00D1012Q001231000C00D2013Q0092000A000C00022Q003E3Q0009000A001231000900D3013Q0010000A00083Q001231000B00D4012Q001231000C00D5013Q0092000A000C00022Q003E3Q0009000A001231000900D6013Q0010000A00083Q001231000B00D7012Q001231000C00D8013Q0092000A000C00022Q003E3Q0009000A001231000900D9013Q0010000A00083Q001231000B00DA012Q001231000C00DB013Q0092000A000C00022Q003E3Q0009000A001231000900DC013Q0010000A00083Q001231000B00DD012Q001231000C00DE013Q0092000A000C00022Q003E3Q0009000A001231000900DF013Q0010000A00083Q001231000B00E0012Q001231000C00E1013Q0092000A000C00022Q003E3Q0009000A001231000900E2013Q0010000A00083Q001231000B00E3012Q001231000C00E4013Q0092000A000C00022Q003E3Q0009000A001231000900E5013Q0010000A00083Q001231000B00E6012Q001231000C00E7013Q0092000A000C00022Q003E3Q0009000A001231000900E8013Q0010000A00083Q001231000B00E9012Q001231000C00EA013Q0092000A000C00022Q003E3Q0009000A001231000900EB013Q0010000A00083Q001231000B00EC012Q001231000C00ED013Q0092000A000C00022Q003E3Q0009000A001231000900EE013Q0010000A00083Q001231000B00EF012Q001231000C00F0013Q0092000A000C00022Q003E3Q0009000A001231000900F1013Q0010000A00083Q001231000B00F2012Q001231000C00F3013Q0092000A000C00022Q003E3Q0009000A001231000900F4013Q0010000A00083Q001231000B00F5012Q001231000C00F6013Q0092000A000C00022Q003E3Q0009000A001231000900F7013Q0010000A00083Q001231000B00F8012Q001231000C00F9013Q0092000A000C00022Q003E3Q0009000A001231000900FA013Q0010000A00083Q001231000B00FB012Q001231000C00FC013Q0092000A000C00022Q003E3Q0009000A001231000900FD013Q0010000A00083Q001231000B00FE012Q001231000C00FF013Q0092000A000C00022Q003E3Q0009000A00123100092Q00023Q0010000A00083Q001231000B0001022Q001231000C002Q023Q0092000A000C00022Q003E3Q0009000A00123100090003023Q0010000A00083Q001231000B0004022Q001231000C0005023Q0092000A000C00022Q003E3Q0009000A00123100090006023Q0010000A00083Q001231000B0007022Q001231000C0008023Q0092000A000C00022Q003E3Q0009000A00123100090009023Q0010000A00083Q001231000B000A022Q001231000C000B023Q0092000A000C00022Q003E3Q0009000A0012310009000C023Q0010000A00083Q001231000B000D022Q001231000C000E023Q0092000A000C00022Q003E3Q0009000A0012310009000F023Q0010000A00083Q001231000B0010022Q001231000C0011023Q0092000A000C00022Q003E3Q0009000A00123100090012023Q0010000A00083Q001231000B0013022Q001231000C0014023Q0092000A000C00022Q003E3Q0009000A00123100090015023Q0010000A00083Q001231000B0016022Q001231000C0017023Q0092000A000C00022Q003E3Q0009000A00123100090018023Q0010000A00083Q001231000B0019022Q001231000C001A023Q0092000A000C00022Q003E3Q0009000A0012310009001B023Q0010000A00083Q001231000B001C022Q001231000C001D023Q0092000A000C00022Q003E3Q0009000A0012310009001E023Q0010000A00083Q001231000B001F022Q001231000C0020023Q0092000A000C00022Q003E3Q0009000A00123100090021023Q0010000A00083Q001231000B0022022Q001231000C0023023Q0092000A000C00022Q003E3Q0009000A00123100090024023Q0010000A00083Q001231000B0025022Q001231000C0026023Q0092000A000C00022Q003E3Q0009000A00123100090027023Q0010000A00083Q001231000B0028022Q001231000C0029023Q0092000A000C00022Q003E3Q0009000A0012310009002A023Q0010000A00083Q001231000B002B022Q001231000C002C023Q0092000A000C00022Q003E3Q0009000A0012310009002D023Q0010000A00083Q001231000B002E022Q001231000C002F023Q0092000A000C00022Q003E3Q0009000A00123100090030023Q0010000A00083Q001231000B0031022Q001231000C0032023Q0092000A000C00022Q003E3Q0009000A00123100090033023Q0010000A00083Q001231000B0034022Q001231000C0035023Q0092000A000C00022Q003E3Q0009000A00123100090036023Q0010000A00083Q001231000B0037022Q001231000C0038023Q0092000A000C00022Q003E3Q0009000A00123100090039023Q0010000A00083Q001231000B003A022Q001231000C003B023Q0092000A000C00022Q003E3Q0009000A0012310009003C023Q0010000A00083Q001231000B003D022Q001231000C003E023Q0092000A000C00022Q003E3Q0009000A0012310009003F023Q0010000A00083Q001231000B0040022Q001231000C0041023Q0092000A000C00022Q003E3Q0009000A00123100090042023Q0010000A00083Q001231000B0043022Q001231000C0044023Q0092000A000C00022Q003E3Q0009000A00123100090045023Q0010000A00083Q001231000B0046022Q001231000C0047023Q0092000A000C00022Q003E3Q0009000A00123100090048023Q0010000A00083Q001231000B0049022Q001231000C004A023Q0092000A000C00022Q003E3Q0009000A0012310009004B023Q0010000A00083Q001231000B004C022Q001231000C004D023Q0092000A000C00022Q003E3Q0009000A0012310009004E023Q0010000A00083Q001231000B004F022Q001231000C0050023Q0092000A000C00022Q003E3Q0009000A00123100090051023Q0010000A00083Q001231000B0052022Q001231000C0053023Q0092000A000C00022Q003E3Q0009000A00123100090054023Q0010000A00083Q001231000B0055022Q001231000C0056023Q0092000A000C00022Q003E3Q0009000A00123100090057023Q0010000A00083Q001231000B0058022Q001231000C0059023Q0092000A000C00022Q003E3Q0009000A0012310009005A023Q0010000A00083Q001231000B005B022Q001231000C005C023Q0092000A000C00022Q003E3Q0009000A0012310009005D023Q0010000A00083Q001231000B005E022Q001231000C005F023Q0092000A000C00022Q003E3Q0009000A00123100090060023Q0010000A00083Q001231000B0061022Q001231000C0062023Q0092000A000C00022Q003E3Q0009000A00123100090063023Q0010000A00083Q001231000B0064022Q001231000C0065023Q0092000A000C00022Q003E3Q0009000A00123100090066023Q0010000A00083Q001231000B0067022Q001231000C0068023Q0092000A000C00022Q003E3Q0009000A00123100090069023Q0010000A00083Q001231000B006A022Q001231000C006B023Q0092000A000C00022Q003E3Q0009000A0012310009006C023Q0010000A00083Q001231000B006D022Q001231000C006E023Q0092000A000C00022Q003E3Q0009000A0012310009006F023Q0010000A00083Q001231000B0070022Q001231000C0071023Q0092000A000C00022Q003E3Q0009000A00123100090072023Q0010000A00083Q001231000B0073022Q001231000C0074023Q0092000A000C00022Q003E3Q0009000A00123100090075023Q0010000A00083Q001231000B0076022Q001231000C0077023Q0092000A000C00022Q003E3Q0009000A00123100090078023Q0010000A00083Q001231000B0079022Q001231000C007A023Q0092000A000C00022Q003E3Q0009000A0012310009007B023Q0010000A00083Q001231000B007C022Q001231000C007D023Q0092000A000C00022Q003E3Q0009000A0012310009007E023Q0010000A00083Q001231000B007F022Q001231000C0080023Q0092000A000C00022Q003E3Q0009000A00123100090081023Q0010000A00083Q001231000B0082022Q001231000C0083023Q0092000A000C00022Q003E3Q0009000A00123100090084023Q0010000A00083Q001231000B0085022Q001231000C0086023Q0092000A000C00022Q003E3Q0009000A00123100090087023Q0010000A00083Q001231000B0088022Q001231000C0089023Q0092000A000C00022Q003E3Q0009000A0012310009008A023Q0010000A00083Q001231000B008B022Q001231000C008C023Q0092000A000C00022Q003E3Q0009000A0012310009008D023Q0010000A00083Q001231000B008E022Q001231000C008F023Q0092000A000C00022Q003E3Q0009000A00123100090090023Q0010000A00083Q001231000B0091022Q001231000C0092023Q0092000A000C00022Q003E3Q0009000A00123100090093023Q0010000A00083Q001231000B0094022Q001231000C0095023Q0092000A000C00022Q003E3Q0009000A00123100090096023Q0010000A00083Q001231000B0097022Q001231000C0098023Q0092000A000C00022Q003E3Q0009000A00123100090099023Q0010000A00083Q001231000B009A022Q001231000C009B023Q0092000A000C00022Q003E3Q0009000A0012310009009C023Q0010000A00083Q001231000B009D022Q001231000C009E023Q0092000A000C00022Q003E3Q0009000A0012310009009F023Q0010000A00083Q001231000B00A0022Q001231000C00A1023Q0092000A000C00022Q003E3Q0009000A001231000900A2023Q0010000A00083Q001231000B00A3022Q001231000C00A4023Q0092000A000C00022Q003E3Q0009000A001231000900A5023Q0010000A00083Q001231000B00A6022Q001231000C00A7023Q0092000A000C00022Q003E3Q0009000A001231000900A8023Q0010000A00083Q001231000B00A9022Q001231000C00AA023Q0092000A000C00022Q003E3Q0009000A001231000900AB023Q0010000A00083Q001231000B00AC022Q001231000C00AD023Q0092000A000C00022Q003E3Q0009000A001231000900AE023Q0010000A00083Q001231000B00AF022Q001231000C00B0023Q0092000A000C00022Q003E3Q0009000A001231000900B1023Q0010000A00083Q001231000B00B2022Q001231000C00B3023Q0092000A000C00022Q003E3Q0009000A001231000900B4023Q0010000A00083Q001231000B00B5022Q001231000C00B6023Q0092000A000C00022Q003E3Q0009000A001231000900B7023Q0010000A00083Q001231000B00B8022Q001231000C00B9023Q0092000A000C00022Q003E3Q0009000A001231000900BA023Q0010000A00083Q001231000B00BB022Q001231000C00BC023Q0092000A000C00022Q003E3Q0009000A001231000900BD023Q0010000A00083Q001231000B00BE022Q001231000C00BF023Q0092000A000C00022Q003E3Q0009000A001231000900C0023Q0010000A00083Q001231000B00C1022Q001231000C00C2023Q0092000A000C00022Q003E3Q0009000A001231000900C3023Q0010000A00083Q001231000B00C4022Q001231000C00C5023Q0092000A000C00022Q003E3Q0009000A001231000900C6023Q0010000A00083Q001231000B00C7022Q001231000C00C8023Q0092000A000C00022Q003E3Q0009000A001231000900C9023Q0010000A00083Q001231000B00CA022Q001231000C00CB023Q0092000A000C00022Q003E3Q0009000A001231000900CC023Q0010000A00083Q001231000B00CD022Q001231000C00CE023Q0092000A000C00022Q003E3Q0009000A001231000900CF023Q0010000A00083Q001231000B00D0022Q001231000C00D1023Q0092000A000C00022Q003E3Q0009000A001231000900D2023Q0010000A00083Q001231000B00D3022Q001231000C00D4023Q0092000A000C00022Q003E3Q0009000A001231000900D5023Q0010000A00083Q001231000B00D6022Q001231000C00D7023Q0092000A000C00022Q003E3Q0009000A001231000900D8023Q0010000A00083Q001231000B00D9022Q001231000C00DA023Q0092000A000C00022Q003E3Q0009000A001231000900DB023Q0010000A00083Q001231000B00DC022Q001231000C00DD023Q0092000A000C00022Q003E3Q0009000A001231000900DE023Q0010000A00083Q001231000B00DF022Q001231000C00E0023Q0092000A000C00022Q003E3Q0009000A001231000900E1023Q0010000A00083Q001231000B00E2022Q001231000C00E3023Q0092000A000C00022Q003E3Q0009000A001231000900E4023Q0010000A00083Q001231000B00E5022Q001231000C00E6023Q0092000A000C00022Q003E3Q0009000A001231000900E7023Q0010000A00083Q001231000B00E8022Q001231000C00E9023Q0092000A000C00022Q003E3Q0009000A001231000900EA023Q0010000A00083Q001231000B00EB022Q001231000C00EC023Q0092000A000C00022Q003E3Q0009000A001231000900ED023Q0010000A00083Q001231000B00EE022Q001231000C00EF023Q0092000A000C00022Q003E3Q0009000A001231000900F0023Q0010000A00083Q001231000B00F1022Q001231000C00F2023Q0092000A000C00022Q003E3Q0009000A001231000900F3023Q0010000A00083Q001231000B00F4022Q001231000C00F5023Q0092000A000C00022Q003E3Q0009000A001231000900F6023Q0010000A00083Q001231000B00F7022Q001231000C00F8023Q0092000A000C00022Q003E3Q0009000A001231000900F9023Q0010000A00083Q001231000B00FA022Q001231000C00FB023Q0092000A000C00022Q003E3Q0009000A001231000900FC023Q0010000A00083Q001231000B00FD022Q001231000C00FE023Q0092000A000C00022Q003E3Q0009000A001231000900FF023Q0010000A00083Q001231000B2Q00032Q001231000C0001033Q0092000A000C00022Q003E3Q0009000A00123100090002033Q0010000A00083Q001231000B002Q032Q001231000C0004033Q0092000A000C00022Q003E3Q0009000A00123100090005033Q0010000A00083Q001231000B0006032Q001231000C0007033Q0092000A000C00022Q003E3Q0009000A00123100090008033Q0010000A00083Q001231000B0009032Q001231000C000A033Q0092000A000C00022Q003E3Q0009000A0012310009000B033Q0010000A00083Q001231000B000C032Q001231000C000D033Q0092000A000C00022Q003E3Q0009000A0012310009000E033Q0010000A00083Q001231000B000F032Q001231000C0010033Q0092000A000C00022Q003E3Q0009000A00123100090011033Q0010000A00083Q001231000B0012032Q001231000C0013033Q0092000A000C00022Q003E3Q0009000A00123100090014033Q0010000A00083Q001231000B0015032Q001231000C0016033Q0092000A000C00022Q003E3Q0009000A00123100090017033Q0010000A00083Q001231000B0018032Q001231000C0019033Q0092000A000C00022Q003E3Q0009000A0012310009001A033Q0010000A00083Q001231000B001B032Q001231000C001C033Q0092000A000C00022Q003E3Q0009000A0012310009001D033Q0010000A00083Q001231000B001E032Q001231000C001F033Q0092000A000C00022Q003E3Q0009000A00123100090020033Q0010000A00083Q001231000B0021032Q001231000C0022033Q0092000A000C00022Q003E3Q0009000A00123100090023033Q0010000A00083Q001231000B0024032Q001231000C0025033Q0092000A000C00022Q003E3Q0009000A00123100090026033Q0010000A00083Q001231000B0027032Q001231000C0028033Q0092000A000C00022Q003E3Q0009000A00123100090029033Q0010000A00083Q001231000B002A032Q001231000C002B033Q0092000A000C00022Q003E3Q0009000A0012310009002C033Q0010000A00083Q001231000B002D032Q001231000C002E033Q0092000A000C00022Q003E3Q0009000A0012310009002F033Q0010000A00083Q001231000B0030032Q001231000C0031033Q0092000A000C00022Q003E3Q0009000A00123100090032033Q0010000A00083Q001231000B0033032Q001231000C0034033Q0092000A000C00022Q003E3Q0009000A00123100090035033Q0010000A00083Q001231000B0036032Q001231000C0037033Q0092000A000C00022Q003E3Q0009000A00123100090038033Q0010000A00083Q001231000B0039032Q001231000C003A033Q0092000A000C00022Q003E3Q0009000A0012310009003B033Q0010000A00083Q001231000B003C032Q001231000C003D033Q0092000A000C00022Q003E3Q0009000A0012310009003E033Q0010000A00083Q001231000B003F032Q001231000C0040033Q0092000A000C00022Q003E3Q0009000A00123100090041033Q0010000A00083Q001231000B0042032Q001231000C0043033Q0092000A000C00022Q003E3Q0009000A00123100090044033Q0010000A00083Q001231000B0045032Q001231000C0046033Q0092000A000C00022Q003E3Q0009000A00123100090047033Q0010000A00083Q001231000B0048032Q001231000C0049033Q0092000A000C00022Q003E3Q0009000A0012310009004A033Q0010000A00083Q001231000B004B032Q001231000C004C033Q0092000A000C00022Q003E3Q0009000A0012310009004D033Q0010000A00083Q001231000B004E032Q001231000C004F033Q0092000A000C00022Q003E3Q0009000A00123100090050033Q0010000A00083Q001231000B0051032Q001231000C0052033Q0092000A000C00022Q003E3Q0009000A00123100090053033Q0010000A00083Q001231000B0054032Q001231000C0055033Q0092000A000C00022Q003E3Q0009000A00123100090056033Q0010000A00083Q001231000B0057032Q001231000C0058033Q0092000A000C00022Q003E3Q0009000A00123100090059033Q0010000A00083Q001231000B005A032Q001231000C005B033Q0092000A000C00022Q003E3Q0009000A0012310009005C033Q0010000A00083Q001231000B005D032Q001231000C005E033Q0092000A000C00022Q003E3Q0009000A0012310009005F033Q0010000A00083Q001231000B0060032Q001231000C0061033Q0092000A000C00022Q003E3Q0009000A00123100090062033Q0010000A00083Q001231000B0063032Q001231000C0064033Q0092000A000C00022Q003E3Q0009000A00123100090065033Q0010000A00083Q001231000B0066032Q001231000C0067033Q0092000A000C00022Q003E3Q0009000A00123100090068033Q0010000A00083Q001231000B0069032Q001231000C006A033Q0092000A000C00022Q003E3Q0009000A0012310009006B033Q0010000A00083Q001231000B006C032Q001231000C006D033Q0092000A000C00022Q003E3Q0009000A0012310009006E033Q0010000A00083Q001231000B006F032Q001231000C0070033Q0092000A000C00022Q003E3Q0009000A00123100090071033Q0010000A00083Q001231000B0072032Q001231000C0073033Q0092000A000C00022Q003E3Q0009000A00123100090074033Q0010000A00083Q001231000B0075032Q001231000C0076033Q0092000A000C00022Q003E3Q0009000A00123100090077033Q0010000A00083Q001231000B0078032Q001231000C0079033Q0092000A000C00022Q003E3Q0009000A0012310009007A033Q0010000A00083Q001231000B007B032Q001231000C007C033Q0092000A000C00022Q003E3Q0009000A0012310009007D033Q0010000A00083Q001231000B007E032Q001231000C007F033Q0092000A000C00022Q003E3Q0009000A00123100090080033Q0010000A00083Q001231000B0081032Q001231000C0082033Q0092000A000C00022Q003E3Q0009000A00123100090083033Q0010000A00083Q001231000B0084032Q001231000C0085033Q0092000A000C00022Q003E3Q0009000A00123100090086033Q0010000A00083Q001231000B0087032Q001231000C0088033Q0092000A000C00022Q003E3Q0009000A00123100090089033Q0010000A00083Q001231000B008A032Q001231000C008B033Q0092000A000C00022Q003E3Q0009000A0012310009008C033Q0010000A00083Q001231000B008D032Q001231000C008E033Q0092000A000C00022Q003E3Q0009000A0012310009008F033Q0010000A00083Q001231000B0090032Q001231000C0091033Q0092000A000C00022Q003E3Q0009000A00123100090092033Q0010000A00083Q001231000B0093032Q001231000C0094033Q0092000A000C00022Q003E3Q0009000A00123100090095033Q0010000A00083Q001231000B0096032Q001231000C0097033Q0092000A000C00022Q003E3Q0009000A00123100090098033Q0010000A00083Q001231000B0099032Q001231000C009A033Q0092000A000C00022Q003E3Q0009000A0012310009009B033Q0010000A00083Q001231000B009C032Q001231000C009D033Q0092000A000C00022Q003E3Q0009000A0012310009009E033Q0010000A00083Q001231000B009F032Q001231000C00A0033Q0092000A000C00022Q003E3Q0009000A001231000900A1033Q0010000A00083Q001231000B00A2032Q001231000C00A3033Q0092000A000C00022Q003E3Q0009000A001231000900A4033Q0010000A00083Q001231000B00A5032Q001231000C00A6033Q0092000A000C00022Q003E3Q0009000A001231000900A7033Q0010000A00083Q001231000B00A8032Q001231000C00A9033Q0092000A000C00022Q003E3Q0009000A001231000900AA033Q0010000A00083Q001231000B00AB032Q001231000C00AC033Q0092000A000C00022Q003E3Q0009000A001231000900AD033Q0010000A00083Q001231000B00AE032Q001231000C00AF033Q0092000A000C00022Q003E3Q0009000A001231000900B0033Q0010000A00083Q001231000B00B1032Q001231000C00B2033Q0092000A000C00022Q003E3Q0009000A001231000900B3033Q0010000A00083Q001231000B00B4032Q001231000C00B5033Q0092000A000C00022Q003E3Q0009000A001231000900B6033Q0010000A00083Q001231000B00B7032Q001231000C00B8033Q0092000A000C00022Q003E3Q0009000A001231000900B9033Q0010000A00083Q001231000B00BA032Q001231000C00BB033Q0092000A000C00022Q003E3Q0009000A001231000900BC033Q0010000A00083Q001231000B00BD032Q001231000C00BE033Q0092000A000C00022Q003E3Q0009000A001231000900BF033Q0010000A00083Q001231000B00C0032Q001231000C00C1033Q0092000A000C00022Q003E3Q0009000A001231000900C2033Q0010000A00083Q001231000B00C3032Q001231000C00C4033Q0092000A000C00022Q003E3Q0009000A001231000900C5033Q0010000A00083Q001231000B00C6032Q001231000C00C7033Q0092000A000C00022Q003E3Q0009000A001231000900C8033Q0010000A00083Q001231000B00C9032Q001231000C00CA033Q0092000A000C00022Q003E3Q0009000A001231000900CB033Q0010000A00083Q001231000B00CC032Q001231000C00CD033Q0092000A000C00022Q003E3Q0009000A001231000900CE033Q0010000A00083Q001231000B00CF032Q001231000C00D0033Q0092000A000C00022Q003E3Q0009000A001231000900D1033Q0010000A00083Q001231000B00D2032Q001231000C00D3033Q0092000A000C00022Q003E3Q0009000A001231000900D4033Q0010000A00083Q001231000B00D5032Q001231000C00D6033Q0092000A000C00022Q003E3Q0009000A001231000900D7033Q0010000A00083Q001231000B00D8032Q001231000C00D9033Q0092000A000C00022Q003E3Q0009000A001231000900DA033Q0010000A00083Q001231000B00DB032Q001231000C00DC033Q0092000A000C00022Q003E3Q0009000A001231000900DD033Q0010000A00083Q001231000B00DE032Q001231000C00DF033Q0092000A000C00022Q003E3Q0009000A001231000900E0033Q0010000A00083Q001231000B00E1032Q001231000C00E2033Q0092000A000C00022Q003E3Q0009000A001231000900E3033Q0010000A00083Q001231000B00E4032Q001231000C00E5033Q0092000A000C00022Q003E3Q0009000A001231000900E6033Q0010000A00083Q001231000B00E7032Q001231000C00E8033Q0092000A000C00022Q003E3Q0009000A001231000900E9033Q0010000A00083Q001231000B00EA032Q001231000C00EB033Q0092000A000C00022Q003E3Q0009000A001231000900EC033Q0010000A00083Q001231000B00ED032Q001231000C00EE033Q0092000A000C00022Q003E3Q0009000A001231000900EF033Q0010000A00083Q001231000B00F0032Q001231000C00F1033Q0092000A000C00022Q003E3Q0009000A001231000900F2033Q0010000A00083Q001231000B00F3032Q001231000C00F4033Q0092000A000C00022Q003E3Q0009000A001231000900F5033Q0010000A00083Q001231000B00F6032Q001231000C00F7033Q0092000A000C00022Q003E3Q0009000A001231000900F8033Q0010000A00083Q001231000B00F9032Q001231000C00FA033Q0092000A000C00022Q003E3Q0009000A001231000900FB033Q0010000A00083Q001231000B00FC032Q001231000C00FD033Q0092000A000C00022Q003E3Q0009000A001231000900FE033Q0010000A00083Q001231000B00FF032Q001231000C2Q00043Q0092000A000C00022Q003E3Q0009000A00123100090001043Q0010000A00083Q001231000B0002042Q001231000C0003043Q0092000A000C00022Q003E3Q0009000A0012310009002Q043Q0010000A00083Q001231000B0005042Q001231000C0006043Q0092000A000C00022Q003E3Q0009000A00123100090007043Q0010000A00083Q001231000B0008042Q001231000C0009043Q0092000A000C00022Q003E3Q0009000A0012310009000A043Q0010000A00083Q001231000B000B042Q001231000C000C043Q0092000A000C00022Q003E3Q0009000A0012310009000D043Q0010000A00083Q001231000B000E042Q001231000C000F043Q0092000A000C00022Q003E3Q0009000A00123100090010043Q0010000A00083Q001231000B0011042Q001231000C0012043Q0092000A000C00022Q003E3Q0009000A00123100090013043Q0010000A00083Q001231000B0014042Q001231000C0015043Q0092000A000C00022Q003E3Q0009000A00123100090016043Q0010000A00083Q001231000B0017042Q001231000C0018043Q0092000A000C00022Q003E3Q0009000A00123100090019043Q0010000A00083Q001231000B001A042Q001231000C001B043Q0092000A000C00022Q003E3Q0009000A0012310009001C043Q0010000A00083Q001231000B001D042Q001231000C001E043Q0092000A000C00022Q003E3Q0009000A0012310009001F043Q0010000A00083Q001231000B0020042Q001231000C0021043Q0092000A000C00022Q003E3Q0009000A00123100090022043Q0010000A00083Q001231000B0023042Q001231000C0024043Q0092000A000C00022Q003E3Q0009000A00123100090025043Q0010000A00083Q001231000B0026042Q001231000C0027043Q0092000A000C00022Q003E3Q0009000A00123100090028043Q0010000A00083Q001231000B0029042Q001231000C002A043Q0092000A000C00022Q003E3Q0009000A0012310009002B043Q0010000A00083Q001231000B002C042Q001231000C002D043Q0092000A000C00022Q003E3Q0009000A0012310009002E043Q0010000A00083Q001231000B002F042Q001231000C0030043Q0092000A000C00022Q003E3Q0009000A00123100090031043Q0010000A00083Q001231000B0032042Q001231000C0033043Q0092000A000C00022Q003E3Q0009000A00123100090034043Q0010000A00083Q001231000B0035042Q001231000C0036043Q0092000A000C00022Q003E3Q0009000A00120A00090037042Q001231000B0038043Q003D00090009000B001231000B0034043Q0036000B3Q000B2Q00920009000B000200120A000A0037042Q001231000C0038043Q003D000A000A000C001231000C0031043Q0036000C3Q000C2Q0092000A000C000200120A000B0037042Q001231000D0038043Q003D000B000B000D001231000D002E043Q0036000D3Q000D2Q0092000B000D000200120A000C0037042Q001231000E0038043Q003D000C000C000E001231000E002B043Q0036000E3Q000E2Q0092000C000E000200120A000D0037042Q001231000F0038043Q003D000D000D000F001231000F0028043Q0036000F3Q000F2Q0092000D000F000200120A000E0037042Q00123100100038043Q003D000E000E001000123100100025043Q003600103Q00102Q0092000E0010000200120A000F0037042Q00123100110038043Q003D000F000F001100123100110022043Q003600113Q00112Q0092000F0011000200120A00100037042Q00123100120038043Q003D0010001000120012310012001F043Q003600123Q00122Q009200100012000200120A00110037042Q00123100130038043Q003D0011001100130012310013001C043Q003600133Q00132Q009200110013000200123100120039043Q00360012000900120012310013003A043Q00360013000D00132Q003A001400143Q00123100150019043Q003600153Q001500123100160016043Q003600163Q001600123100170013043Q003600173Q001700123100180010043Q003600183Q00180012310019000D043Q003600193Q0019001231001A000A043Q0036001A3Q001A001231001B0007043Q0036001B3Q001B001231001C002Q043Q0036001C3Q001C001231001D0001043Q0036001D3Q001D001231001E00FE033Q0036001E3Q001E001231001F00FB033Q0036001F3Q001F001231002000F8033Q003600203Q0020001231002100F5033Q003600213Q0021001231002200F2033Q003600223Q0022001231002300EF033Q003600233Q0023001231002400EC033Q003600243Q0024001231002500E9033Q003600253Q0025001231002600E6033Q003600263Q0026001231002700E3033Q003600273Q0027001231002800E0033Q003600283Q0028001231002900DD033Q003600293Q0029001231002A00DA033Q0036002A3Q002A001231002B00D7033Q0036002B3Q002B001231002C00D4033Q0036002C3Q002C2Q00420014001800012Q003A001500094Q003A001600013Q001231001700D1033Q003600173Q001700120A0018003B042Q0012310019003C043Q0036001800180019001231001900B9032Q001231001A003D042Q001231001B003E043Q00590018001B4Q000800163Q00012Q003A001700013Q001231001800CE033Q003600183Q001800120A0019003B042Q001231001A003C043Q003600190019001A001231001A003F042Q001231001B0040042Q001231001C003E043Q00590019001C4Q000800173Q00012Q003A001800013Q001231001900CB033Q003600193Q001900120A001A003B042Q001231001B003C043Q0036001A001A001B001231001B0080032Q001231001C003E042Q001231001D0026033Q0059001A001D4Q000800183Q00012Q003A001900013Q001231001A00C8033Q0036001A3Q001A00120A001B003B042Q001231001C003C043Q0036001B001B001C001231001C003E042Q001231001D0040042Q001231001E00B9033Q0059001B001E4Q000800193Q00012Q003A001A00013Q001231001B00C5033Q0036001B3Q001B00120A001C003B042Q001231001D003C043Q0036001C001C001D001231001D003E042Q001231001E0041042Q001231001F00DD033Q0059001C001F4Q0008001A3Q00012Q003A001B00013Q001231001C00C2033Q0036001C3Q001C00120A001D003B042Q001231001E003C043Q0036001D001D001E001231001E003E042Q001231001F009E032Q0012310020009E033Q0059001D00204Q0008001B3Q00012Q003A001C00013Q001231001D00BF033Q0036001D3Q001D00120A001E003B042Q001231001F003C043Q0036001E001E001F001231001F003E042Q00123100200044032Q00123100210042043Q0059001E00214Q0008001C3Q00012Q003A001D00013Q001231001E00BC033Q0036001E3Q001E00120A001F003B042Q0012310020003C043Q0036001F001F002000123100200043042Q00123100210062032Q0012310022003E043Q0059001F00224Q0008001D3Q00012Q003A001E00013Q001231001F00B9033Q0036001F3Q001F00120A0020003B042Q0012310021003C043Q003600200020002100123100210044042Q00123100220044042Q0012310023003E043Q0059002000234Q0008001E3Q00012Q00420015000900012Q003A00163Q0019001231001700B6033Q003600173Q00172Q007A00186Q003E001600170018001231001700B3033Q003600173Q00172Q007A00186Q003E001600170018001231001700B0033Q003600173Q00172Q007A00186Q003E001600170018001231001700AD033Q003600173Q00172Q007A00186Q003E001600170018001231001700AA033Q003600173Q00170012310018000A043Q003E001600170018001231001700A7033Q003600173Q00172Q007A00186Q003E001600170018001231001700A4033Q003600173Q001700123100180042043Q003E001600170018001231001700A1033Q003600173Q001700123100180045043Q003E0016001700180012310017009E033Q003600173Q0017001231001800C9023Q003E0016001700180012310017009B033Q003600173Q00172Q007A00186Q003E00160017001800123100170098033Q003600173Q00172Q007A001800014Q003E00160017001800123100170095033Q003600173Q00172Q007A001800014Q003E00160017001800123100170092033Q003600173Q00172Q007A001800014Q003E0016001700180012310017008F033Q003600173Q00172Q007A001800014Q003E0016001700180012310017008C033Q003600173Q001700123100180046043Q003E00160017001800123100170089033Q003600173Q001700123100180034043Q003600180015001800123100190047043Q00360018001800192Q003E00160017001800123100170086033Q003600173Q001700123100180083033Q003600183Q00182Q003E00160017001800123100170080033Q003600173Q00172Q007A00186Q003E0016001700180012310017007D033Q003600173Q00172Q007A00186Q003E0016001700180012310017007A033Q003600173Q00170012310018009E033Q003E00160017001800123100170077033Q003600173Q00172Q007A00186Q003E00160017001800123100170074033Q003600173Q001700123100180001043Q003E00160017001800123100170071033Q003600173Q00172Q007A00186Q003E0016001700180012310017006E033Q003600173Q00170012310018009E033Q003E0016001700180012310017006B033Q003600173Q00172Q007A00186Q003E00160017001800123100170068033Q003600173Q00172Q007A00186Q003E00160017001800123100170065033Q003600173Q00172Q007A00186Q003E00160017001800123100170062033Q003600173Q00172Q007A00186Q003E0016001700180012310017005F033Q003600173Q00172Q007A00186Q003E0016001700180012310017005C033Q003600173Q00172Q007A00186Q003E00160017001800123100170059033Q003600173Q00172Q007A00186Q003E00160017001800123100170056033Q003600173Q00172Q007A00186Q003E00160017001800123100170053033Q003600173Q001700123100180048043Q003E0016001700182Q003A00173Q000500123100180050033Q003600183Q001800123100190034043Q003E0017001800190012310018004D033Q003600183Q001800123100190034043Q003E0017001800190012310018004A033Q003600183Q001800123100190034043Q003E00170018001900123100180047033Q003600183Q001800123100190034043Q003E00170018001900123100180044033Q003600183Q001800123100190034043Q003E0017001800192Q003A00186Q007A00196Q007A001A00014Q007A001B6Q008D001C001F4Q003A00205Q0012310021003F043Q008D002200223Q0012310023003F042Q0012310024003F043Q008D002500294Q003A002A6Q003A002B6Q003A002C3Q0009001231002D0041033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F0049042Q0012310030004A042Q0012310031000D043Q0092002E003100022Q003E002C002D002E001231002D003E033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F004A042Q00123100300013042Q001231003100E3033Q0092002E003100022Q003E002C002D002E001231002D003B033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F0019042Q001231003000FB032Q001231003100C8033Q0092002E003100022Q003E002C002D002E001231002D0038033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F00F5032Q001231003000CB032Q00123100310098033Q0092002E003100022Q003E002C002D002E001231002D0035033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F004B042Q00123100300041042Q0012310031003E043Q0092002E003100022Q003E002C002D002E001231002D0032033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F004C042Q0012310030004D042Q0012310031003E043Q0092002E003100022Q003E002C002D002E001231002D002F033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F00E4022Q001231003000E1022Q0012310031003E043Q0092002E003100022Q003E002C002D002E001231002D002C033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F0026032Q0012310030004E042Q00123100310043043Q0092002E003100022Q003E002C002D002E001231002D0029033Q0036002D3Q002D00120A002E003B042Q001231002F003C043Q0036002E002E002F001231002F00DD032Q001231003000C5032Q00123100310098033Q0092002E003100022Q003E002C002D002E00060F002D0001000100022Q002F3Q000E4Q002F7Q00060F002E0002000100042Q002F3Q00124Q002F3Q00224Q002F3Q00234Q002F7Q00060F002F0003000100012Q002F3Q00143Q00060F00300004000100012Q002F7Q0012310033004F043Q003D00310012003300123100330011033Q003600333Q00332Q009200310033000200120A00320050042Q00060F00330005000100022Q002F3Q00314Q002F8Q004F00320002000100120A00320050042Q00060F00330006000100022Q002F3Q00314Q002F8Q004F00320002000100120A00320051042Q00123100330052043Q003600320032003300123100330008033Q003600333Q00332Q0010003400314Q009200320034000200123100330053042Q00123100340005033Q003600343Q00342Q003E00320033003400123100330054043Q007A00346Q003E00320033003400123100330055043Q007A003400014Q003E00320033003400123100330056042Q00123100340057043Q003E00320033003400120A00330051042Q00123100340052043Q003600330033003400123100340002033Q003600343Q00342Q0010003500324Q009200330035000200123100340058042Q00120A00350059042Q00123100360052043Q00360035003500360012310036005A042Q0012310037005A043Q00920035003700022Q003E0033003400350012310034005B042Q00120A0035005C042Q0012310036005D043Q00360035003500360012310036005A042Q0012310037005A043Q00920035003700022Q003E0033003400350012310034005E042Q00120A0035005C042Q0012310036005F043Q003600350035003600123100360060043Q003600360016003600123100370047043Q006700360036003700123100370060043Q003600370016003700123100380047043Q00670037003700382Q00920035003700022Q003E00330034003500123100340061042Q00123100350034043Q003E00330034003500123100340062043Q007A00356Q003E0033003400352Q0010003400304Q0010003500333Q00123100360057043Q008700340036000100120A00340051042Q00123100350052043Q0036003400340035001231003500FF023Q003600353Q00352Q0010003600334Q009200340036000200123100350063042Q00123100360064043Q00360036002C00362Q003E00340035003600123100350065042Q00123100360066043Q003E00340035003600123100350067042Q00123100360068043Q003E00340035003600120A00350051042Q00123100360052043Q0036003500350036001231003600FC023Q003600363Q00362Q0010003700324Q00920035003700020012310036005E042Q00120A0037005C042Q0012310038005F043Q003600370037003800123100380046042Q00123100390069043Q00920037003900022Q003E0035003600370012310036005B042Q00120A0037005C042Q00123100380052043Q00360037003700380012310038005A042Q0012310039006A042Q001231003A005A042Q001231003B006B043Q00920037003B00022Q003E0035003600370012310036006C042Q0012310037006D043Q00360037002C00372Q003E0035003600370012310036006E042Q0012310037003F043Q003E0035003600370012310036006F043Q007A003700014Q003E00350036003700123100360070043Q007A003700014Q003E0035003600372Q0010003600304Q0010003700353Q00123100380071043Q008700360038000100120A00360051042Q00123100370052043Q0036003600360037001231003700F9023Q003600373Q00372Q0010003800354Q009200360038000200123100370063042Q00123100380064043Q00360038002C00382Q003E00360037003800120A00360051042Q00123100370052043Q0036003600360037001231003700F6023Q003600373Q00372Q0010003800354Q009200360038000200123100370067042Q0012310038005A043Q003E00360037003800120A00360051042Q00123100370052043Q0036003600360037001231003700F3023Q003600373Q00372Q0010003800354Q00920036003800020012310037005E042Q00120A0038005C042Q00123100390052043Q003600380038003900123100390034042Q001231003A003F042Q001231003B003F042Q001231003C00D1033Q00920038003C00022Q003E0036003700380012310037006C042Q00123100380072043Q00360038002C00382Q003E0036003700380012310037006E042Q0012310038003F043Q003E0036003700382Q0010003700304Q0010003800363Q00123100390071043Q008700370039000100120A00370051042Q00123100380052043Q0036003700370038001231003800F0023Q003600383Q00382Q0010003900364Q00920037003900020012310038005E042Q00120A0039005C042Q001231003A0052043Q003600390039003A001231003A0034042Q001231003B003F042Q001231003C003F042Q001231003D0048043Q00920039003D00022Q003E0037003800390012310038005B042Q00120A0039005C042Q001231003A0052043Q003600390039003A001231003A003F042Q001231003B003F042Q001231003C0034042Q001231003D0073043Q00920039003D00022Q003E0037003800390012310038006C042Q00123100390072043Q00360039002C00392Q003E0037003800390012310038006E042Q0012310039003F043Q003E00370038003900120A00380051042Q00123100390052043Q0036003800380039001231003900ED023Q003600393Q00392Q0010003A00364Q00920038003A00020012310039005E042Q00120A003A005C042Q001231003B0052043Q0036003A003A003B001231003B003F042Q001231003C0026032Q001231003D0034042Q001231003E003F043Q0092003A003E00022Q003E00380039003A0012310039005B042Q00120A003A005C042Q001231003B005F043Q0036003A003A003B001231003B004A042Q001231003C003F043Q0092003A003C00022Q003E00380039003A00123100390061042Q001231003A0034043Q003E00380039003A00123100390074042Q001231003A00EA023Q0036003A3Q003A2Q003E00380039003A00123100390075042Q00120A003A0076042Q001231003B0075043Q0036003A003A003B001231003B0077043Q0036003A003A003B2Q003E00380039003A00123100390078042Q001231003A0071043Q003E00380039003A00123100390079042Q001231003A007A043Q0036003A002C003A2Q003E00380039003A0012310039007B042Q00120A003A0076042Q001231003B007B043Q0036003A003A003B001231003B007C043Q0036003A003A003B2Q003E00380039003A00120A00390051042Q001231003A0052043Q003600390039003A001231003A00E7023Q0036003A3Q003A2Q0010003B00364Q00920039003B0002001231003A005E042Q00120A003B005C042Q001231003C005F043Q0036003B003B003C001231003C0001042Q001231003D0001043Q0092003B003D00022Q003E0039003A003B001231003A005B042Q00120A003B005C042Q001231003C0052043Q0036003B003B003C001231003C0034042Q001231003D007D042Q001231003E005A042Q001231003F007E043Q0092003B003F00022Q003E0039003A003B001231003A006C042Q001231003B007F043Q0036003B002C003B2Q003E0039003A003B001231003A0074042Q001231003B0080043Q003E0039003A003B001231003A0075042Q00120A003B0076042Q001231003C0075043Q0036003B003B003C001231003C0081043Q0036003B003B003C2Q003E0039003A003B001231003A0078042Q001231003B0048043Q003E0039003A003B001231003A0079042Q001231003B0082043Q0036003B002C003B2Q003E0039003A003B2Q0010003A00304Q0010003B00393Q001231003C0083043Q0087003A003C000100120A003A0051042Q001231003B0052043Q0036003A003A003B001231003B00E4023Q0036003B3Q003B2Q0010003C00354Q0092003A003C0002001231003B005E042Q00120A003C005C042Q001231003D0052043Q0036003C003C003D001231003D0034042Q001231003E0084042Q001231003F003F042Q001231004000F5033Q0092003C004000022Q003E003A003B003C001231003B005B042Q00120A003C005C042Q001231003D005F043Q0036003C003C003D001231003D0083042Q001231003E00CB033Q0092003C003E00022Q003E003A003B003C001231003B0061042Q001231003C0034043Q003E003A003B003C00120A003B0051042Q001231003C0052043Q0036003B003B003C001231003C00E1023Q0036003C3Q003C2Q0010003D003A4Q0092003B003D0002001231003C0085042Q00120A003D0076042Q001231003E0085043Q0036003D003D003E001231003E0086043Q0036003D003D003E2Q003E003B003C003D001231003C0087042Q00120A003D0088042Q001231003E0052043Q0036003D003D003E001231003E003F042Q001231003F0089043Q0092003D003F00022Q003E003B003C003D2Q003A003C6Q003A003D00043Q001231003E00DE023Q0036003E3Q003E001231003F00DB023Q0036003F3Q003F001231004000D8023Q003600403Q0040001231004100D5023Q003600413Q00412Q0042003D0004000100120A003E008A043Q0010003F003D4Q001E003E0002004000043F3Q00D20B010012310043003F043Q008D004400443Q00123100450034042Q00060B004300940B01004500043F3Q00940B010012310045006C042Q0012310046007F043Q00360046002C00462Q003E00440045004600123100450074043Q003E00440045004200123100430047042Q0012310045008B042Q00060B004300990B01004500043F3Q00990B012Q003E003C0042004400043F3Q00D20B010012310045003F042Q00060B004300B70B01004500043F3Q00B70B010012310045003F042Q0012310046003F042Q00060B004500B10B01004600043F3Q00B10B0100120A00460051042Q00123100470052043Q0036004600460047001231004700D2023Q003600473Q00472Q00100048003A4Q00920046004800022Q0010004400463Q0012310046005E042Q00120A0047005C042Q0012310048005F043Q00360047004700480012310048008C042Q001231004900FB033Q00920047004900022Q003E00440046004700123100450034042Q00123100460034042Q00060B0045009D0B01004600043F3Q009D0B0100123100430034042Q00043F3Q00B70B0100043F3Q009D0B0100123100450047042Q00060B004300C50B01004500043F3Q00C50B0100123100450075042Q00120A00460076042Q00123100470075043Q00360046004600470012310047008D043Q00360046004600472Q003E00440045004600123100450078042Q00123100460048043Q003E00440045004600123100430031042Q00123100450031042Q00060B0043008A0B01004500043F3Q008A0B0100123100450079042Q00123100460082043Q00360046002C00462Q003E0044004500462Q0010004500304Q0010004600443Q00123100470083043Q00870045004700010012310043008B042Q00043F3Q008A0B0100066A003E00880B01000200043F3Q00880B0100120A003E0051042Q001231003F0052043Q0036003E003E003F001231003F00CF023Q0036003F3Q003F2Q0010004000354Q0092003E00400002001231003F005E042Q00120A0040005C042Q00123100410052043Q003600400040004100123100410034042Q00123100420084042Q00123100430034042Q0012310044008E043Q00920040004400022Q003E003E003F0040001231003F005B042Q00120A0040005C042Q0012310041005F043Q003600400040004100123100410083042Q0012310042006E033Q00920040004200022Q003E003E003F0040001231003F0061042Q00123100400034043Q003E003E003F0040001231003F006E042Q0012310040003F043Q003E003E003F0040001231003F008F042Q00123100400031043Q003E003E003F0040001231003F0090042Q00123100400064043Q00360040002C00402Q003E003E003F0040001231003F0091042Q00120A00400076042Q00123100410092043Q003600400040004100123100410093043Q00360040004000412Q003E003E003F0040001231003F0094042Q00120A0040005C042Q00123100410052043Q00360040004000412Q004E0040000100022Q003E003E003F004000120A003F0051042Q00123100400052043Q0036003F003F0040001231004000CC023Q003600403Q00402Q0010004100324Q0092003F004100020012310040005E042Q00120A0041005C042Q0012310042005F043Q0036004100410042001231004200CE032Q001231004300CE033Q00920041004300022Q003E003F004000410012310040005B042Q00120A0041005C042Q00123100420052043Q00360041004100420012310042003F042Q0012310043004A042Q00123100440034042Q00123100450095043Q00920041004500022Q003E003F004000410012310040006C042Q00123100410064043Q00360041002C00412Q003E003F0040004100123100400074042Q00123100410096043Q003E003F0040004100123100400075042Q00120A00410076042Q00123100420075043Q003600410041004200123100420077043Q00360041004100422Q003E003F0040004100123100400078042Q00123100410071043Q003E003F0040004100123100400079042Q00120A0041003B042Q00123100420052043Q003600410041004200123100420034042Q00123100430034042Q00123100440034043Q00920041004400022Q003E003F0040004100123100400062043Q007A00416Q003E003F0040004100123100400097042Q001231004100DD033Q003E003F004000412Q0010004000304Q00100041003F3Q00123100420048043Q008700400042000100120A00400051042Q00123100410052043Q0036004000400041001231004100C9023Q003600413Q00412Q0010004200324Q00920040004200020012310041005E042Q00120A0042005C042Q0012310043005F043Q00360042004200430012310043008C042Q001231004400EF033Q00920042004400022Q003E0040004100420012310041005B042Q00120A0042005C042Q0012310043005F043Q00360042004200430012310043004A042Q00123100440041043Q00920042004400022Q003E0040004100420012310041006C042Q00123100420064043Q00360042002C00422Q003E00400041004200123100410074042Q001231004200C6023Q003600423Q00422Q003E00400041004200123100410075042Q00120A00420076042Q00123100430075043Q003600420042004300123100430081043Q00360042004200432Q003E00400041004200123100410078042Q00123100420048043Q003E00400041004200123100410079042Q00120A0042003B042Q00123100430052043Q003600420042004300123100430034042Q00123100440034042Q00123100450034043Q00920042004500022Q003E00400041004200123100410097042Q00123100420044033Q003E0040004100420012310041006F043Q007A004200014Q003E0040004100422Q0010004100304Q0010004200403Q00123100430049043Q00870041004300010012310041003F043Q008D004200443Q00123100450034042Q00060B004100970C01004500043F3Q00970C0100123100450098043Q00360045000B004500123100470099043Q003D00450045004700060F00470007000100042Q002F3Q00424Q002F3Q00434Q002F3Q00404Q002F3Q00444Q00870045004700010012310045009A043Q00360045000B004500123100470099043Q003D00450045004700060F00470008000100012Q002F3Q00424Q008700450047000100043F3Q00AB0C010012310045003F042Q00060B004100820C01004500043F3Q00820C012Q007A00456Q008D004600464Q008D004400444Q0010004300464Q0010004200453Q0012310045009B043Q003600450040004500123100470099043Q003D00450045004700060F00470009000100042Q002F3Q00424Q002F3Q00434Q002F3Q00444Q002F3Q00404Q008700450047000100123100410034042Q00043F3Q00820C012Q008500415Q00060F0041000A000100032Q002F3Q002C4Q002F8Q002F3Q00303Q00060F0042000B0001000A2Q002F3Q00414Q002F3Q002B4Q002F8Q002F3Q002C4Q002F3Q00304Q002F3Q00184Q002F3Q002A4Q002F3Q00164Q002F3Q00294Q002F3Q002D3Q00060F0043000C000100042Q002F3Q002C4Q002F8Q002F3Q00304Q002F3Q000B3Q00060F0044000D000100022Q002F3Q002C4Q002F7Q00060F0045000E000100032Q002F8Q002F3Q002C4Q002F3Q00303Q00060F0046000F000100032Q002F8Q002F3Q002C4Q002F3Q00303Q00060F00470010000100062Q002F8Q002F3Q00154Q002F3Q00304Q002F3Q00164Q002F3Q00204Q002F3Q002C3Q00060F00480011000100022Q002F8Q002F3Q00123Q00060F00490012000100012Q002F7Q00060F004A0013000100012Q002F3Q00133Q00060F004B0014000100052Q002F3Q00164Q002F3Q00124Q002F8Q002F3Q00094Q002F3Q004A3Q00060F004C0015000100052Q002F3Q00164Q002F3Q00094Q002F3Q00124Q002F3Q00494Q002F3Q004A3Q00060F004D0016000100042Q002F3Q00094Q002F3Q00124Q002F8Q002F3Q00163Q00060F004E0017000100022Q002F3Q00164Q002F3Q00133Q00060F004F0018000100032Q002F8Q002F3Q000F4Q002F3Q00123Q000228005000193Q00060F0051001A000100022Q002F8Q002F3Q00103Q00060F0052001B000100072Q002F3Q002D4Q002F8Q002F3Q00214Q002F3Q00514Q002F3Q004C4Q002F3Q00504Q002F3Q004F3Q0012310053009C043Q003600530040005300123100550099043Q003D0053005300552Q0010005500524Q008700530055000100060F0053001C000100052Q002F3Q00164Q002F3Q001E4Q002F3Q000A4Q002F3Q00124Q002F7Q00060F0054001D000100042Q002F3Q00164Q002F3Q001F4Q002F8Q002F3Q00123Q00060F0055001E000100042Q002F8Q002F3Q00164Q002F3Q00534Q002F3Q00543Q00060F0056001F000100092Q002F3Q002C4Q002F3Q00184Q002F8Q002F3Q00304Q002F3Q00164Q002F3Q002B4Q002F3Q00294Q002F3Q002D4Q002F3Q002A3Q0012310057009D043Q00360057000A005700123100590099043Q003D00570057005900060F00590020000100062Q002F3Q00164Q002F3Q001F4Q002F3Q00124Q002F8Q002F3Q00134Q002F3Q000B4Q00870057005900010012310057009E043Q00360057000A005700123100590099043Q003D00570057005900060F00590021000100032Q002F3Q00164Q002F3Q00124Q002F8Q00870057005900010012310057009F043Q00360057000B005700123100590099043Q003D00570057005900060F00590022000100032Q002F3Q00164Q002F3Q00124Q002F8Q008700570059000100060F00570023000100042Q002F3Q00254Q002F3Q000A4Q002F8Q002F3Q00163Q00060F00580024000100042Q002F3Q00164Q002F3Q000D4Q002F8Q002F3Q00123Q00060F00590025000100042Q002F3Q00164Q002F3Q00264Q002F3Q00274Q002F3Q000C3Q00060F005A0026000100032Q002F3Q00164Q002F3Q00284Q002F3Q000C3Q00060F005B0027000100022Q002F8Q002F3Q00203Q00060F005C0028000100022Q002F3Q00204Q002F3Q005B3Q00060F005D0029000100022Q002F8Q002F3Q002F3Q00060F005E002A000100092Q002F3Q005B4Q002F8Q002F3Q00494Q002F3Q00124Q002F3Q00164Q002F3Q00204Q002F3Q000D4Q002F3Q005D4Q002F3Q00303Q00060F005F002B000100062Q002F3Q002D4Q002F8Q002F3Q00494Q002F3Q00484Q002F3Q00094Q002F3Q00123Q00060F0060002C000100082Q002F3Q00164Q002F3Q00224Q002F8Q002F3Q00234Q002F3Q00244Q002F3Q00494Q002F3Q00484Q002F3Q00523Q00060F0061002D000100022Q002F8Q002F3Q00603Q00120A0062008A042Q001231006500A0043Q003D0063000900652Q0003006300644Q006900623Q006400043F3Q007F0D010006040066007F0D01001200043F3Q007F0D012Q0010006700614Q0010006800664Q004F00670002000100066A0062007A0D01000200043F3Q007A0D01001231006200A1043Q003600620009006200123100640099043Q003D00620062006400060F0064002E000100022Q002F3Q00124Q002F3Q00614Q008700620064000100060F0062002F000100032Q002F3Q002B4Q002F3Q003E4Q002F3Q002A3Q00060F006300300001001C2Q002F3Q00624Q002F3Q003C4Q002F3Q002C4Q002F8Q002F3Q00444Q002F3Q003E4Q002F3Q00414Q002F3Q00164Q002F3Q00434Q002F3Q00334Q002F3Q00564Q002F3Q005C4Q002F3Q00474Q002F3Q00584Q002F3Q00594Q002F3Q005A4Q002F3Q00574Q002F3Q00534Q002F3Q00544Q002F3Q00464Q002F3Q005F4Q002F3Q00454Q002F3Q00114Q002F3Q00184Q002F3Q002D4Q002F3Q00174Q002F3Q00154Q002F3Q00633Q00120A006400A2043Q00100065003C4Q001E00640002006600043F3Q00B70D010012310069009C043Q0036006900680069001231006B0099043Q003D00690069006B00060F006B0031000100022Q002F3Q00634Q002F3Q00674Q00870069006B00012Q008500675Q00066A006400AE0D01000200043F3Q00AE0D012Q0010006400633Q001231006500324Q003600653Q00652Q004F0064000200010012310064009B043Q003600640036006400123100660099043Q003D00640064006600060F00660032000100042Q002F3Q001B4Q002F3Q001C4Q002F3Q001D4Q002F3Q00354Q008700640066000100123100640098043Q00360064000B006400123100660099043Q003D00640064006600060F00660033000100042Q002F3Q001B4Q002F3Q001C4Q002F3Q00354Q002F3Q001D4Q00870064006600010012310064009A043Q00360064000B006400123100660099043Q003D00640064006600060F00660034000100012Q002F3Q001B4Q008700640066000100060F00640035000100032Q002F3Q001A4Q002F3Q00354Q002F3Q003F3Q0012310065009C043Q003600650039006500123100670099043Q003D00650065006700060F00670036000100012Q002F3Q00644Q00870065006700010012310065009C043Q00360065003F006500123100670099043Q003D00650065006700060F00670037000100012Q002F3Q00644Q00870065006700010012310065009B043Q00360065000B006500123100670099043Q003D00650065006700060F006700380001000F2Q002F3Q00294Q002F3Q00184Q002F3Q002A4Q002F3Q002C4Q002F8Q002F3Q002D4Q002F3Q00644Q002F3Q001A4Q002F3Q00174Q002F3Q002B4Q002F3Q00554Q002F3Q00164Q002F3Q00194Q002F3Q004B4Q002F3Q002E4Q00870065006700010012310065009A043Q00360065000B006500123100670099043Q003D00650065006700060F00670039000100012Q002F3Q00194Q0087006500670001001231006500A3043Q003600650012006500123100670099043Q003D00650065006700060F0067003A000100052Q002F3Q00164Q002F3Q00544Q002F3Q001F4Q002F3Q001E4Q002F3Q00534Q00870065006700010012310065003F042Q0012310066009D043Q00360066000A006600123100680099043Q003D00660066006800060F0068003B0001000F2Q002F3Q00334Q002F3Q00164Q002F8Q002F3Q00654Q002F3Q00094Q002F3Q00124Q002F3Q005E4Q002F3Q00204Q002F3Q005B4Q002F3Q005C4Q002F3Q004E4Q002F3Q004D4Q002F3Q002E4Q002F3Q00194Q002F3Q004B4Q008700660068000100120A006600A4042Q0012310067000B4Q003600673Q00672Q004F0066000200012Q008500096Q00393Q00013Q003C3Q00023Q00026Q00F03F026Q00704002264Q003A00025Q001231000300014Q001C00045Q001231000500013Q0004980003002100012Q007100076Q0010000800024Q0071000900014Q0071000A00024Q0071000B00034Q0071000C00044Q0010000D6Q0010000E00063Q00208B000F000600012Q0059000C000F4Q0050000B3Q00022Q0071000C00034Q0071000D00044Q0010000E00014Q001C000F00014Q008A000F0006000F001017000F0001000F2Q001C001000014Q008A00100006001000101700100001001000208B0010001000012Q0059000D00104Q006B000C6Q0050000A3Q000200201D000A000A00022Q00030009000A4Q006200073Q000100048C0003000500012Q0071000300054Q0010000400024Q0020000300044Q007800036Q00393Q00017Q00013Q0003053Q007063612Q6C01073Q00120A000100013Q00060F00023Q000100032Q00808Q00803Q00014Q002F8Q004F0001000200012Q00393Q00013Q00013Q00083Q0003073Q00536574436F7265026Q005E40025Q00405E40025Q00805E40025Q00C05E4003083Q00746F737472696E67026Q005F40027Q004000154Q00717Q0020215Q00012Q0071000200013Q0020840002000200022Q003A00033Q00032Q0071000400013Q0020840004000400032Q0071000500013Q0020840005000500042Q003E0003000400052Q0071000400013Q00208400040004000500120A000500064Q0071000600024Q006E0005000200022Q003E0003000400052Q0071000400013Q00208400040004000700206C0003000400082Q00873Q000300012Q00393Q00017Q00023Q0003023Q005F47025Q00405F40010E3Q00065C3Q000D00013Q00043F3Q000D00012Q007100015Q0006043Q000D0001000100043F3Q000D00012Q001000015Q00120A000200014Q0071000300033Q0020840003000300022Q00360002000200032Q004E0002000100022Q007F000200024Q007F000100014Q00393Q00017Q00063Q0003063Q00737472696E6703053Q006C6F77657203083Q00746F737472696E67034Q00026Q00F03F03043Q0066696E6401213Q00120A000100013Q00208400010001000200120A000200033Q0006770003000600013Q00043F3Q00060001001231000300044Q0003000200034Q005000013Q00022Q00103Q00013Q001231000100054Q007100026Q001C000200023Q001231000300053Q0004980001001E000100120A000500013Q0020840005000500062Q001000065Q00120A000700013Q0020840007000700022Q007100086Q00360008000800042Q006E000700020002001231000800054Q007A000900014Q009200050009000200065C0005001D00013Q00043F3Q001D00012Q007A000500014Q0066000500023Q00048C0001000E00012Q007A00016Q0066000100024Q00393Q00017Q00073Q0003083Q00496E7374616E63652Q033Q006E6577025Q002Q6040030C3Q00436F726E657252616469757303043Q005544696D028Q00026Q002040020F3Q00120A000200013Q0020840002000200022Q007100035Q0020840003000300032Q001000046Q009200020004000200120A000300053Q002084000300030002001231000400063Q0006770005000C0001000100043F3Q000C0001001231000500074Q00920003000500020010940002000400032Q00393Q00017Q00033Q0003063Q0067657468756903023Q005F47026Q006140000A3Q00120A3Q00013Q00065C3Q000900013Q00043F3Q0009000100120A3Q00024Q0071000100013Q0020840001000100032Q00365Q00012Q004E3Q000100022Q007F8Q00393Q00017Q00053Q0003053Q007061697273030B3Q004765744368696C6472656E03043Q004E616D65025Q0060614003073Q0044657374726F7900103Q00120A3Q00014Q007100015Q0020210001000100022Q0003000100024Q00695Q000200043F3Q000D00010020840005000400032Q0071000600013Q00208400060006000400060B0005000D0001000600043F3Q000D00010020210005000400052Q004F00050002000100066A3Q00060001000200043F3Q000600012Q00393Q00017Q000B3Q00030D3Q0055736572496E7075745479706503043Q00456E756D030D3Q004D6F7573654D6F76656D656E74028Q0003083Q00506F736974696F6E03053Q005544696D322Q033Q006E657703013Q005803053Q005363616C6503063Q004F2Q6673657403013Q005901284Q007100015Q00065C0001002700013Q00043F3Q0027000100208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100270001000200043F3Q00270001001231000100044Q008D000200023Q00267B0001000B0001000400043F3Q000B000100208400033Q00052Q0071000400014Q00450002000300042Q0071000300023Q00120A000400063Q0020840004000400072Q0071000500033Q0020840005000500080020840005000500092Q0071000600033Q00208400060006000800208400060006000A0020840007000200082Q00960006000600072Q0071000700033Q00208400070007000B0020840007000700092Q0071000800033Q00208400080008000B00208400080008000A00208400090002000B2Q00960008000800092Q009200040008000200109400030005000400043F3Q0027000100043F3Q000B00012Q00393Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3101093Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100080001000200043F3Q000800012Q007A00016Q007F00016Q00393Q00017Q00043Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3103083Q00506F736974696F6E010E3Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B0001000D0001000200043F3Q000D00012Q007A000100013Q00208400023Q00042Q0071000300033Q0020840003000300042Q007F000300024Q007F000200014Q007F00016Q00393Q00017Q00343Q00028Q00026Q00084003083Q005465787453697A65026Q002840030A3Q0054657874436F6C6F723303023Q005478030E3Q005465787458416C69676E6D656E7403043Q00456E756D03043Q004C65667403083Q00496E7374616E63652Q033Q006E6577025Q00207640026Q001040026Q00184003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F7233026Q00F03F030F3Q00426F7264657253697A65506978656C026Q001C40027Q004003083Q00506F736974696F6E03053Q005544696D32030A3Q0066726F6D4F2Q66736574026Q00244003163Q004261636B67726F756E645472616E73706172656E637903043Q005465787403043Q00466F6E7403063Q00476F7468616D03043Q0053697A65026Q004340026Q003240026Q0047C0026Q00E03F026Q0022C003023Q0041632Q033Q004F2Q66034Q00026Q001440026Q002240025Q00707740026Q002C40026Q0030C0026Q001CC003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E656374025Q00607840026Q0010C0026Q002Q4003043Q0043617264026Q002040025Q00F07840026Q004AC005B43Q001231000500014Q008D0006000A3Q00267B000500140001000200043F3Q001400010030230007000300042Q0071000B5Q002084000B000B000600109400070005000B00120A000B00083Q002084000B000B0007002084000B000B000900109400070007000B00120A000B000A3Q002084000B000B000B2Q0071000C00013Q002084000C000C000C2Q0010000D00064Q0092000B000D00022Q00100008000B3Q0012310005000D3Q00267B000500240001000E00043F3Q0024000100120A000B00103Q002084000B000B000B001231000C00113Q001231000D00113Q001231000E00114Q0092000B000E00020010940009000F000B0030230009001200012Q0071000B00024Q0010000C00093Q001231000D00134Q0087000B000D00012Q0010000A00033Q001231000500133Q00267B000500330001001400043F3Q0033000100120A000B00163Q002084000B000B0017001231000C00183Q001231000D00014Q0092000B000D000200109400070015000B0030230007001900110010940007001A000100120A000B00083Q002084000B000B001B002084000B000B001C0010940007001B000B001231000500023Q00267B0005004E0001000D00043F3Q004E000100120A000B00163Q002084000B000B0017001231000C001E3Q001231000D001F4Q0092000B000D00020010940008001D000B00120A000B00163Q002084000B000B000B001231000C00113Q001231000D00203Q001231000E00213Q001231000F00224Q0092000B000F000200109400080015000B00065C0003004900013Q00043F3Q004900012Q0071000B5Q002084000B000B0023000609000B004B0001000100043F3Q004B00012Q0071000B5Q002084000B000B00240010940008000F000B0030230008001A0025001231000500263Q00267B000500730001002600043F3Q007300012Q0071000B00024Q0010000C00083Q001231000D00274Q0087000B000D000100120A000B000A3Q002084000B000B000B2Q0071000C00013Q002084000C000C00282Q0010000D00084Q0092000B000D00022Q00100009000B3Q00120A000B00163Q002084000B000B0017001231000C00293Q001231000D00294Q0092000B000D00020010940009001D000B00065C0003006C00013Q00043F3Q006C000100120A000B00163Q002084000B000B000B001231000C00113Q001231000D002A3Q001231000E00213Q001231000F002B4Q0092000B000F0002000609000B00710001000100043F3Q0071000100120A000B00163Q002084000B000B0017001231000C00143Q001231000D00144Q0092000B000D000200109400090015000B0012310005000E3Q00267B000500800001001300043F3Q00800001002084000B0008002C002021000B000B002D00060F000D3Q000100052Q002F3Q000A4Q002F3Q00084Q00808Q002F3Q00094Q002F3Q00044Q0087000B000D000100208B000B0002001E2Q0066000B00023Q00267B0005009B0001000100043F3Q009B000100120A000B000A3Q002084000B000B000B2Q0071000C00013Q002084000C000C002E2Q0010000D6Q0092000B000D00022Q00100006000B3Q00120A000B00163Q002084000B000B000B001231000C00113Q001231000D002F3Q001231000E00013Q001231000F00304Q0092000B000F00020010940006001D000B00120A000B00163Q002084000B000B0017001231000C00144Q0010000D00024Q0092000B000D000200109400060015000B2Q0071000B5Q002084000B000B00310010940006000F000B001231000500113Q00267B000500020001001100043F3Q000200010030230006001200012Q0071000B00024Q0010000C00063Q001231000D00324Q0087000B000D000100120A000B000A3Q002084000B000B000B2Q0071000C00013Q002084000C000C00332Q0010000D00064Q0092000B000D00022Q00100007000B3Q00120A000B00163Q002084000B000B000B001231000C00113Q001231000D00343Q001231000E00113Q001231000F00014Q0092000B000F00020010940007001D000B001231000500143Q00043F3Q000200012Q00393Q00013Q00013Q000D3Q00028Q0003103Q004261636B67726F756E64436F6C6F723303023Q0041632Q033Q004F2Q66026Q00F03F03083Q00506F736974696F6E03053Q005544696D322Q033Q006E6577026Q0030C0026Q00E03F026Q001CC0030A3Q0066726F6D4F2Q66736574027Q0040002D3Q0012313Q00013Q00267B3Q00120001000100043F3Q001200012Q007100016Q001B000100014Q007F00016Q0071000100014Q007100025Q00065C0002000E00013Q00043F3Q000E00012Q0071000200023Q002084000200020003000609000200100001000100043F3Q001000012Q0071000200023Q0020840002000200040010940001000200020012313Q00053Q00267B3Q00010001000500043F3Q000100012Q0071000100034Q007100025Q00065C0002002100013Q00043F3Q0021000100120A000200073Q002084000200020008001231000300053Q001231000400093Q0012310005000A3Q0012310006000B4Q0092000200060002000609000200260001000100043F3Q0026000100120A000200073Q00208400020002000C0012310003000D3Q0012310004000D4Q00920002000400020010940001000600022Q0071000100044Q007100026Q004F00010002000100043F3Q002C000100043F3Q000100012Q00393Q00017Q00383Q00030B3Q004765744368696C6472656E03163Q0046696E6446697273744368696C645768696368497341025Q00607940025Q0080794003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637403083Q00496E7374616E63652Q033Q006E6577025Q00207A4003043Q0053697A6503053Q005544696D32026Q00F03F026Q0010C0028Q00026Q00344003083Q00506F736974696F6E030A3Q0066726F6D4F2Q66736574027Q004003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003040026Q003840026Q004440030F3Q00426F7264657253697A65506978656C026Q001840025Q00B07A40029A5Q99D93F026Q00204003163Q004261636B67726F756E645472616E73706172656E637903043Q0054657874025Q00207B4003043Q00466F6E7403043Q00456E756D03063Q00476F7468616D03083Q005465787453697A65026Q002440030A3Q0054657874436F6C6F72332Q033Q0044696D030E3Q005465787458416C69676E6D656E7403043Q004C656674025Q00D07B40026Q00E03F026Q0020C002CD5QCCDC3F2Q033Q00426172025Q00507C40030A3Q00476F7468616D426F6C6403043Q00536F6674026Q001440025Q00C07C40025Q00D07C40025Q00107D40025Q00207D40025Q00C07D40026Q003A4006CA4Q007100066Q001000076Q0010000800014Q0010000900024Q0010000A00033Q00060F000B3Q000100032Q00803Q00014Q002F3Q00044Q002F3Q00054Q00920006000B000200202100073Q00012Q006E00070002000200202100083Q00012Q006E0008000200022Q001C000800084Q00360007000700082Q0010000800033Q0020210009000700022Q0071000B00023Q002084000B000B00032Q00920009000B0002000660000A001B0001000900043F3Q001B0001002021000A000900022Q0071000C00023Q002084000C000C00042Q0092000A000C000200060F000B0001000100052Q002F3Q000A4Q002F3Q00084Q002F3Q00054Q002F3Q00094Q00803Q00033Q00065C0009002700013Q00043F3Q00270001002084000C00090005002021000C000C0006000228000E00024Q0087000C000E000100120A000C00073Q002084000C000C00082Q0071000D00023Q002084000D000D00092Q0010000E6Q0092000C000E000200120A000D000B3Q002084000D000D0008001231000E000C3Q001231000F000D3Q0012310010000E3Q0012310011000F4Q0092000D00110002001094000C000A000D00120A000D000B3Q002084000D000D0011001231000E00124Q0010000F00064Q0092000D000F0002001094000C0010000D00120A000D00143Q002084000D000D0015001231000E00163Q001231000F00173Q001231001000184Q0092000D00100002001094000C0013000D003023000C0019000E2Q0071000D00044Q0010000E000C3Q001231000F001A4Q0087000D000F000100120A000D00073Q002084000D000D00082Q0071000E00023Q002084000E000E001B2Q0010000F000C4Q0092000D000F000200120A000E000B3Q002084000E000E0008001231000F001C3Q0012310010000E3Q0012310011000C3Q0012310012000E4Q0092000E00120002001094000D000A000E00120A000E000B3Q002084000E000E0011001231000F001D3Q0012310010000E4Q0092000E00100002001094000D0010000E003023000D001E000C2Q0071000E00023Q002084000E000E0020001094000D001F000E00120A000E00223Q002084000E000E0021002084000E000E0023001094000D0021000E003023000D002400252Q0071000E00033Q002084000E000E0027001094000D0026000E00120A000E00223Q002084000E000E0028002084000E000E0029001094000D0028000E00120A000E00073Q002084000E000E00082Q0071000F00023Q002084000F000F002A2Q00100010000C4Q0092000E0010000200120A000F000B3Q002084000F000F00080012310010002B3Q0012310011002C3Q0012310012000E3Q001231001300164Q0092000F00130002001094000E000A000F00120A000F000B3Q002084000F000F00080012310010002D3Q0012310011000E3Q0012310012002B3Q0012310013002C4Q0092000F00130002001094000E0010000F2Q0071000F00033Q002084000F000F002E001094000E0013000F2Q0071000F00054Q0036000F000F0004000609000F008A0001000100043F3Q008A00012Q0071000F00023Q002084000F000F002F001094000E001F000F00120A000F00223Q002084000F000F0021002084000F000F0030001094000E0021000F003023000E002400252Q0071000F00033Q002084000F000F0031001094000E0026000F2Q0071000F00044Q00100010000E3Q001231001100324Q0087000F001100012Q0071000F00064Q003E000F0004000E2Q0071000F00014Q003A00103Q00032Q0071001100023Q00208400110011003300060F00120003000100012Q002F3Q00084Q003E0010001100122Q0071001100023Q00208400110011003400060F00120004000100042Q002F8Q00803Q00024Q002F3Q00054Q002F3Q00084Q003E0010001100122Q0071001100023Q0020840011001100352Q003E00100011000B2Q003E000F000400102Q0071000F00014Q003A00103Q00022Q0071001100023Q00208400110011003600060F00120005000100032Q00803Q00074Q002F3Q00044Q00803Q00024Q003E0010001100122Q0071001100023Q00208400110011003700060F00120006000100042Q002F3Q00044Q00803Q00024Q00803Q00074Q002F3Q00054Q003E0010001100122Q003E000F00040010002084000F000E0005002021000F000F000600060F00110007000100052Q00803Q00084Q002F3Q00044Q002F3Q000E4Q00803Q00024Q00803Q00094Q0087000F0011000100208B000F000600382Q0066000F00024Q00393Q00013Q00083Q00023Q00028Q002Q033Q005F737401123Q001231000100013Q00267B000100010001000100043F3Q000100012Q007100026Q0071000300014Q003600020002000300065C0002000C00013Q00043F3Q000C00012Q007100026Q0071000300014Q0036000200020003001094000200024Q0071000200024Q001000036Q004F00020002000100043F3Q0011000100043F3Q000100012Q00393Q00017Q000D3Q00028Q00026Q00F03F03083Q00506F736974696F6E03053Q005544696D322Q033Q006E6577026Q0030C0026Q00E03F026Q001CC0030A3Q0066726F6D4F2Q66736574027Q004003103Q004261636B67726F756E64436F6C6F723303023Q0041632Q033Q004F2Q6601373Q001231000100013Q00267B0001001D0001000200043F3Q001D00012Q007100025Q00065C0002001900013Q00043F3Q001900012Q007100026Q0071000300013Q00065C0003001300013Q00043F3Q0013000100120A000300043Q002084000300030005001231000400023Q001231000500063Q001231000600073Q001231000700084Q0092000300070002000609000300180001000100043F3Q0018000100120A000300043Q0020840003000300090012310004000A3Q0012310005000A4Q00920003000500020010940002000300032Q0071000200024Q0071000300014Q004F00020002000100043F3Q0036000100267B000100010001000100043F3Q0001000100065C3Q002400013Q00043F3Q002400012Q007A000200013Q000609000200250001000100043F3Q002500012Q007A00026Q007F000200014Q0071000200033Q00065C0002003400013Q00043F3Q003400012Q0071000200034Q0071000300013Q00065C0003003100013Q00043F3Q003100012Q0071000300043Q00208400030003000C000609000300330001000100043F3Q003300012Q0071000300043Q00208400030003000D0010940002000B0003001231000100023Q00043F3Q000100012Q00393Q00019Q003Q00014Q00393Q00019Q003Q00034Q00718Q00663Q00024Q00393Q00017Q00063Q00028Q00026Q00F03F03053Q007061697273030B3Q004765744368696C6472656E2Q033Q00497341026Q007D4001273Q001231000100014Q008D000200023Q00267B000100190001000200043F3Q0019000100120A000300034Q007100045Q0020210004000400042Q0003000400054Q006900033Q000500043F3Q001300010020210008000700052Q0071000A00013Q002084000A000A00062Q00920008000A000200065C0008001300013Q00043F3Q001300012Q001C000800023Q00208B0008000800022Q003E00020008000700066A0003000A0001000200043F3Q000A00012Q0071000300024Q0071000400034Q004F00030002000100043F3Q0026000100267B000100020001000100043F3Q0002000100065C3Q002000013Q00043F3Q002000012Q007A000300013Q000609000300210001000100043F3Q002100012Q007A00036Q007F000300034Q003A00036Q0010000200033Q001231000100023Q00043F3Q000200012Q00393Q00017Q00093Q00025Q00307D40025Q00407D40025Q00507D40025Q00607D40025Q00707D40025Q00807D40025Q00907D40025Q00A07D40025Q00B07D40002A4Q00718Q0071000100014Q0071000200023Q00208400020002000100060B0001000A0001000200043F3Q000A00012Q0071000100023Q002084000100010002000609000100270001000100043F3Q002700012Q0071000100014Q0071000200023Q00208400020002000300060B000100130001000200043F3Q001300012Q0071000100023Q002084000100010004000609000100270001000100043F3Q002700012Q0071000100014Q0071000200023Q00208400020002000500060B0001001C0001000200043F3Q001C00012Q0071000100023Q002084000100010006000609000100270001000100043F3Q002700012Q0071000100014Q0071000200023Q00208400020002000700060B000100250001000200043F3Q002500012Q0071000100023Q002084000100010008000609000100270001000100043F3Q002700012Q0071000100023Q0020840001000100092Q00365Q00012Q00663Q00024Q00393Q00017Q00093Q00028Q00025Q00D07D4003063Q0053696C656E74025Q00F07D4003093Q00537469636B7941696D025Q00107E40030A3Q0053696C656E7441757261025Q00307E40025Q00407E40012C3Q001231000100013Q00267B000100010001000100043F3Q000100012Q007100026Q0071000300013Q00208400030003000200060B0002000B0001000300043F3Q000B00012Q0071000200023Q001094000200033Q00043F3Q002600012Q007100026Q0071000300013Q00208400030003000400060B000200130001000300043F3Q001300012Q0071000200023Q001094000200053Q00043F3Q002600012Q007100026Q0071000300013Q00208400030003000600060B0002001B0001000300043F3Q001B00012Q0071000200023Q001094000200073Q00043F3Q002600012Q007100026Q0071000300013Q00208400030003000800060B000200210001000300043F3Q0021000100043F3Q002600012Q007100026Q0071000300013Q00208400030003000900060B000200260001000300043F3Q002600012Q0071000200034Q001000036Q004F00020002000100043F3Q002B000100043F3Q000100012Q00393Q00017Q000B3Q00028Q0003043Q0054657874025Q00807E40026Q00F03F030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00E06F40025Q00406A40025Q00805640025Q00B07E40001B3Q0012313Q00013Q00267B3Q000A0001000100043F3Q000A00012Q0071000100014Q007F00016Q0071000100024Q0071000200033Q0020840002000200030010940001000200020012313Q00043Q00267B3Q00010001000400043F3Q000100012Q0071000100023Q00120A000200063Q002084000200020007001231000300083Q001231000400093Q0012310005000A4Q00920002000500020010940001000500022Q0071000100044Q0071000200033Q00208400020002000B2Q004F00010002000100043F3Q001A000100043F3Q000100012Q00393Q00017Q00393Q00028Q00026Q00F03F027Q004003083Q005465787453697A65026Q002840030A3Q0054657874436F6C6F723303023Q005478030E3Q005465787458416C69676E6D656E7403043Q00456E756D03043Q004C65667403083Q00496E7374616E63652Q033Q006E6577025Q00307F4003043Q0053697A6503053Q005544696D3202EC51B81E85EBD13F026Q0020C0026Q00304003083Q00506F736974696F6E026Q66E63F026Q001440026Q000840025Q00907F4003043Q006D61746803053Q00636C616D7003103Q004261636B67726F756E64436F6C6F723303023Q004163030F3Q00426F7264657253697A65506978656C026Q001840026Q001040025Q00088040026Q0034C0030A3Q0066726F6D4F2Q66736574026Q002440026Q003E402Q033Q00426172025Q0050804002CD5QCCE43F03163Q004261636B67726F756E645472616E73706172656E637903043Q005465787403043Q00466F6E7403063Q00476F7468616D025Q00A88040026Q0010C0026Q00484003043Q0043617264026Q00204003023Q005F47025Q00F88040030A3Q00476F7468616D426F6C6403043Q00536F667403053Q005269676874030A3Q00496E707574426567616E03073Q00436F2Q6E656374030A3Q00496E707574456E646564030C3Q00496E7075744368616E676564026Q004B4007F53Q001231000700014Q008D0008000E3Q001231000F00013Q00267B000F004A0001000200043F3Q004A000100267B000700270001000300043F3Q002700010030230009000400052Q007100105Q00208400100010000700109400090006001000120A001000093Q00208400100010000800208400100010000A00109400090008001000120A0010000B3Q00208400100010000C2Q0071001100013Q00208400110011000D2Q0010001200084Q00920010001200022Q0010000A00103Q00120A0010000F3Q00208400100010000C001231001100103Q001231001200113Q001231001300013Q001231001400124Q0092001000140002001094000A000E001000120A0010000F3Q00208400100010000C001231001100143Q001231001200013Q001231001300013Q001231001400154Q0092001000140002001094000A00130010001231000700163Q000E52001500490001000700043F3Q0049000100120A0010000B3Q00208400100010000C2Q0071001100013Q0020840011001100172Q00100012000B4Q00920010001200022Q0010000C00103Q00120A0010000F3Q00208400100010000C00120A001100183Q0020840011001100192Q00450012000300042Q00450013000500042Q0034001200120013001231001300013Q001231001400024Q0092001100140002001231001200013Q001231001300023Q001231001400014Q0092001000140002001094000C000E00102Q007100105Q00208400100010001B001094000C001A0010003023000C001C00012Q0071001000024Q00100011000C3Q001231001200164Q00870010001200012Q007A000D5Q0012310007001D3Q001231000F00033Q00267B000F008B0001000100043F3Q008B000100267B0007006C0001001E00043F3Q006C000100120A0010000B3Q00208400100010000C2Q0071001100013Q00208400110011001F2Q0010001200084Q00920010001200022Q0010000B00103Q00120A0010000F3Q00208400100010000C001231001100023Q001231001200203Q001231001300013Q0012310014001D4Q0092001000140002001094000B000E001000120A0010000F3Q002084001000100021001231001100223Q001231001200234Q0092001000120002001094000B001300102Q007100105Q002084001000100024001094000B001A0010003023000B001C00012Q0071001000024Q00100011000B3Q001231001200164Q0087001000120001001231000700153Q000E520002008A0001000700043F3Q008A000100120A0010000B3Q00208400100010000C2Q0071001100013Q0020840011001100252Q0010001200084Q00920010001200022Q0010000900103Q00120A0010000F3Q00208400100010000C001231001100263Q001231001200013Q001231001300013Q001231001400124Q00920010001400020010940009000E001000120A0010000F3Q002084001000100021001231001100223Q001231001200154Q009200100012000200109400090013001000302300090027000200109400090028000100120A001000093Q00208400100010002900208400100010002A001094000900290010001231000700033Q001231000F00023Q00267B000F00AE0001001600043F3Q00AE000100267B000700020001000100043F3Q0002000100120A0010000B3Q00208400100010000C2Q0071001100013Q00208400110011002B2Q001000126Q00920010001200022Q0010000800103Q00120A0010000F3Q00208400100010000C001231001100023Q0012310012002C3Q001231001300013Q0012310014002D4Q00920010001400020010940008000E001000120A0010000F3Q002084001000100021001231001100034Q0010001200024Q00920010001200020010940008001300102Q007100105Q00208400100010002E0010940008001A00100030230008001C00012Q0071001000024Q0010001100083Q0012310012002F4Q0087001000120001001231000700023Q00043F3Q0002000100267B000F00030001000300043F3Q0003000100267B000700C70001001600043F3Q00C70001003023000A0027000200120A001000304Q0071001100013Q0020840011001100312Q00360010001000112Q0010001100034Q006E001000020002001094000A0028001000120A001000093Q002084001000100029002084001000100032001094000A00290010003023000A000400052Q007100105Q002084001000100033001094000A0006001000120A001000093Q002084001000100008002084001000100034001094000A000800100012310007001E3Q00267B000700F10001001D00043F3Q00F10001001231001000013Q00267B001000D90001000200043F3Q00D900010020840011000B003500202100110011003600060F00133Q000100022Q002F3Q000D4Q002F3Q000E4Q00870011001300012Q0071001100033Q00208400110011003700202100110011003600060F00130001000100012Q002F3Q000D4Q0087001100130001001231001000033Q000E52000300E40001001000043F3Q00E400012Q0071001100033Q00208400110011003800202100110011003600060F00130002000100022Q002F3Q000D4Q002F3Q000E4Q008700110013000100208B0011000200392Q0066001100023Q00267B001000CA0001000100043F3Q00CA00012Q008D000E000E3Q00060F000E0003000100072Q002F3Q000C4Q002F3Q000A4Q00803Q00014Q002F3Q000B4Q002F3Q00044Q002F3Q00054Q002F3Q00063Q001231001000023Q00043F3Q00CA0001001231000F00163Q00043F3Q0003000100043F3Q000200012Q00393Q00013Q00043Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E31010C3Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B0001000B0001000200043F3Q000B00012Q007A000100014Q007F00016Q0071000100014Q001000026Q004F0001000200012Q00393Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3101093Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100080001000200043F3Q000800012Q007A00016Q007F00016Q00393Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030D3Q004D6F7573654D6F76656D656E74010D4Q007100015Q00065C0001000C00013Q00043F3Q000C000100208400013Q000100120A000200023Q00208400020002000100208400020002000300060B0001000C0001000200043F3Q000C00012Q0071000100014Q001000026Q004F0001000200012Q00393Q00017Q00113Q00028Q00026Q00F03F03043Q0053697A6503053Q005544696D322Q033Q006E657703043Q005465787403023Q005F47025Q00D88140027Q004003043Q006D61746803053Q00636C616D7003083Q00506F736974696F6E03013Q005803103Q004162736F6C757465506F736974696F6E2Q033Q006D6178030C3Q004162736F6C75746553697A6503053Q00666C2Q6F7201513Q001231000100014Q008D000200043Q00267B000100070001000100043F3Q00070001001231000200014Q008D000300033Q001231000100023Q00267B000100020001000200043F3Q000200012Q008D000400043Q00267B0002001E0001000200043F3Q001E00012Q007100055Q00120A000600043Q0020840006000600052Q0010000700033Q001231000800013Q001231000900023Q001231000A00014Q00920006000A00020010940005000300062Q0071000500013Q00120A000600074Q0071000700023Q0020840007000700082Q00360006000600072Q0010000700044Q006E000600020002001094000500060006001231000200093Q000E52000100470001000200043F3Q00470001001231000500013Q000E52000200250001000500043F3Q00250001001231000200023Q00043F3Q0047000100267B000500210001000100043F3Q0021000100120A0006000A3Q00208400060006000B00208400073Q000C00208400070007000D2Q0071000800033Q00208400080008000E00208400080008000D2Q004500070007000800120A0008000A3Q00208400080008000F2Q0071000900033Q00208400090009001000208400090009000D001231000A00024Q00920008000A00022Q0034000700070008001231000800013Q001231000900024Q00920006000900022Q0010000300063Q00120A0006000A3Q0020840006000600112Q0071000700044Q0071000800054Q0071000900044Q00450008000800092Q00670008000800032Q00960007000700082Q006E0006000200022Q0010000400063Q001231000500023Q00043F3Q0021000100267B0002000A0001000900043F3Q000A00012Q0071000500064Q0010000600044Q004F00050002000100043F3Q0050000100043F3Q000A000100043F3Q0050000100043F3Q000200012Q00393Q00017Q001A3Q00028Q00026Q001040030E3Q005465787458416C69676E6D656E7403043Q00456E756D03043Q004C656674026Q003440026Q00F03F03083Q00506F736974696F6E03053Q005544696D32030A3Q0066726F6D4F2Q6673657403163Q004261636B67726F756E645472616E73706172656E6379027Q0040026Q00084003083Q005465787453697A65026Q002640030A3Q0054657874436F6C6F72332Q033Q0044696D03043Q005465787403043Q00466F6E74030A3Q00476F7468616D426F6C6403083Q00496E7374616E63652Q033Q006E6577025Q0098824003043Q0053697A65026Q0020C0026Q00324003373Q001231000300014Q008D000400043Q00267B0003000A0001000200043F3Q000A000100120A000500043Q00208400050005000300208400050005000500109400040003000500208B0005000200062Q0066000500023Q00267B000300140001000700043F3Q0014000100120A000500093Q00208400050005000A001231000600024Q0010000700024Q00920005000700020010940004000800050030230004000B00070012310003000C3Q000E52000D001B0001000300043F3Q001B00010030230004000E000F2Q007100055Q002084000500050011001094000400100005001231000300023Q000E52000C00230001000300043F3Q0023000100109400040012000100120A000500043Q0020840005000500130020840005000500140010940004001300050012310003000D3Q000E52000100020001000300043F3Q0002000100120A000500153Q0020840005000500162Q0071000600013Q0020840006000600172Q001000076Q00920005000700022Q0010000400053Q00120A000500093Q002084000500050016001231000600073Q001231000700193Q001231000800013Q0012310009001A4Q0092000500090002001094000400180005001231000300073Q00043F3Q000200012Q00393Q00017Q001A3Q00028Q00026Q00F03F03083Q00496E7374616E63652Q033Q006E6577025Q00B8824003043Q0053697A6503053Q005544696D32026Q0010C0026Q002Q4003083Q00506F736974696F6E030A3Q0066726F6D4F2Q66736574027Q004003103Q004261636B67726F756E64436F6C6F723303023Q004163026Q00204003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E656374026Q00434003043Q005465787403043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q002840030A3Q0054657874436F6C6F723303063Q00436F6C6F723304433Q001231000400014Q008D000500053Q001231000600013Q00267B000600210001000200043F3Q0021000100267B000400020001000100043F3Q0002000100120A000700033Q0020840007000700042Q007100085Q0020840008000800052Q001000096Q00920007000900022Q0010000500073Q00120A000700073Q002084000700070004001231000800023Q001231000900083Q001231000A00013Q001231000B00094Q00920007000B000200109400050006000700120A000700073Q00208400070007000B0012310008000C4Q0010000900024Q00920007000900020010940005000A00072Q0071000700013Q00208400070007000E0010940005000D0007001231000400023Q00043F3Q0002000100267B000600030001000100043F3Q0003000100267B0004002F0001000C00043F3Q002F00012Q0071000700024Q0010000800053Q0012310009000F4Q00870007000900010020840007000500100020210007000700112Q0010000900034Q008700070009000100208B0007000200122Q0066000700023Q00267B0004003F0001000200043F3Q003F000100109400050013000100120A000700153Q00208400070007001400208400070007001600109400050014000700302300050017001800120A0007001A3Q002084000700070004001231000800023Q001231000900023Q001231000A00024Q00920007000A00020010940005001900070012310004000C3Q001231000600023Q00043F3Q0003000100043F3Q000200012Q00393Q00017Q002C3Q0003083Q00496E7374616E63652Q033Q006E6577025Q0040834003043Q0053697A6503053Q005544696D32026Q00F03F026Q0010C0028Q00026Q00414003083Q00506F736974696F6E030A3Q0066726F6D4F2Q66736574027Q004003103Q004261636B67726F756E64436F6C6F723303043Q0043617264030F3Q00426F7264657253697A65506978656C026Q002040025Q0088834002D7A3703D0AD7E33F026Q0020C0026Q0010402Q033Q00426172030F3Q00506C616365686F6C6465725465787403043Q0054657874034Q0003043Q00466F6E7403043Q00456E756D03063Q00476F7468616D03083Q005465787453697A65026Q002840030A3Q0054657874436F6C6F723303023Q00547803113Q00506C616365686F6C646572436F6C6F72332Q033Q0044696D026Q001840025Q00208440027B14AE47E17AD43F021F85EB51B81EE53F03023Q004163025Q00608440030A3Q00476F7468616D426F6C6403063Q00436F6C6F723303113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E656374026Q00444004793Q00120A000400013Q0020840004000400022Q007100055Q0020840005000500032Q001000066Q009200040006000200120A000500053Q002084000500050002001231000600063Q001231000700073Q001231000800083Q001231000900094Q009200050009000200109400040004000500120A000500053Q00208400050005000B0012310006000C4Q0010000700024Q00920005000700020010940004000A00052Q0071000500013Q00208400050005000E0010940004000D00050030230004000F00082Q0071000500024Q0010000600043Q001231000700104Q008700050007000100120A000500013Q0020840005000500022Q007100065Q0020840006000600112Q0010000700044Q009200050007000200120A000600053Q002084000600060002001231000700123Q001231000800133Q001231000900063Q001231000A00134Q00920006000A000200109400050004000600120A000600053Q00208400060006000B001231000700103Q001231000800144Q00920006000800020010940005000A00062Q0071000600013Q0020840006000600150010940005000D000600109400050016000100302300050017001800120A0006001A3Q00208400060006001900208400060006001B0010940005001900060030230005001C001D2Q0071000600013Q00208400060006001F0010940005001E00062Q0071000600013Q0020840006000600210010940005002000062Q0071000600024Q0010000700053Q001231000800224Q008700060008000100120A000600013Q0020840006000600022Q007100075Q0020840007000700232Q0010000800044Q009200060008000200120A000700053Q002084000700070002001231000800243Q001231000900133Q001231000A00063Q001231000B00134Q00920007000B000200109400060004000700120A000700053Q002084000700070002001231000800253Q001231000900083Q001231000A00083Q001231000B00144Q00920007000B00020010940006000A00072Q0071000700013Q0020840007000700260010940006000D00072Q007100075Q00208400070007002700109400060017000700120A0007001A3Q0020840007000700190020840007000700280010940006001900070030230006001C001D00120A000700293Q002084000700070002001231000800063Q001231000900063Q001231000A00064Q00920007000A00020010940006001E00072Q0071000700024Q0010000800063Q001231000900224Q008700070009000100208400070006002A00202100070007002B00060F00093Q000100022Q002F3Q00034Q002F3Q00054Q008700070009000100208B00070002002C2Q0066000700024Q00393Q00013Q00013Q00013Q0003043Q005465787400054Q00718Q0071000100013Q0020840001000100012Q004F3Q000200012Q00393Q00017Q003A3Q00028Q00026Q00144003083Q00496E7374616E63652Q033Q006E6577025Q00B8844003043Q0053697A6503053Q005544696D32026Q00F03F026Q002CC0026Q003A4003083Q00506F736974696F6E030A3Q0066726F6D4F2Q66736574026Q001C40026Q003E40026Q00184003163Q004261636B67726F756E645472616E73706172656E6379025Q00F08440030D3Q0046692Q6C446972656374696F6E03043Q00456E756D030A3Q00486F72697A6F6E74616C03073Q0050612Q64696E6703043Q005544696D03063Q00697061697273027Q0040025Q00288540026Q000840025Q00388540026Q00384003103Q004261636B67726F756E64436F6C6F723303043Q0054657874034Q00026Q00104003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637403093Q00546869636B6E652Q73030C3Q00455350436F6C6F724E616D6503053Q00436F6C6F7203063Q00436F6C6F7233025Q0080514003083Q005465787453697A65026Q002840030A3Q0054657874436F6C6F723303023Q005478030E3Q005465787458416C69676E6D656E7403043Q004C65667403043Q0043617264030F3Q00426F7264657253697A65506978656C026Q002040025Q00708640026Q0010C0026Q005040025Q00A8864003043Q00466F6E7403063Q00476F7468616D025Q00D88640026Q0024C0026Q003040026Q00244002DA3Q001231000200014Q008D000300063Q00267B0002001A0001000200043F3Q001A000100120A000700033Q0020840007000700042Q007100085Q0020840008000800052Q0010000900034Q00920007000900022Q0010000500073Q00120A000700073Q002084000700070004001231000800083Q001231000900093Q001231000A00013Q001231000B000A4Q00920007000B000200109400050006000700120A000700073Q00208400070007000C0012310008000D3Q0012310009000E4Q00920007000900020010940005000B00070012310002000F3Q00267B000200290001000F00043F3Q0029000100302300050010000800120A000700033Q0020840007000700042Q007100085Q0020840008000800112Q0010000900054Q00920007000900022Q0010000600073Q00120A000700133Q0020840007000700120020840007000700140010940006001200070012310002000D3Q00267B000200840001000D00043F3Q0084000100120A000700163Q002084000700070004001231000800013Q001231000900024Q009200070009000200109400060015000700120A000700174Q0071000800014Q001E00070002000900043F3Q00800001001231000C00014Q008D000D000E3Q00267B000C00450001001800043F3Q004500012Q0071000F00024Q00100010000D3Q0012310011000F4Q0087000F0011000100120A000F00033Q002084000F000F00042Q007100105Q0020840010001000192Q00100011000D4Q0092000F001100022Q0010000E000F3Q001231000C001A3Q00267B000C00550001000100043F3Q0055000100120A000F00033Q002084000F000F00042Q007100105Q00208400100010001B2Q0010001100054Q0092000F001100022Q0010000D000F3Q00120A000F00073Q002084000F000F000C0012310010001C3Q0012310011001C4Q0092000F00110002001094000D0006000F001231000C00083Q00267B000C005B0001000800043F3Q005B0001002084000F000B0018001094000D001D000F003023000D001E001F001231000C00183Q00267B000C00690001002000043F3Q00690001002084000F000D0021002021000F000F002200060F00113Q000100072Q00803Q00034Q002F3Q000B4Q002F3Q00044Q00808Q002F3Q00054Q002F3Q000D4Q00803Q00044Q0087000F0011000100043F3Q007E000100267B000C00370001001A00043F3Q003700012Q0071000F00033Q002084000F000F00240020840010000B000800060B000F00730001001000043F3Q00730001001231000F00183Q000609000F00740001000100043F3Q00740001001231000F00013Q001094000E0023000F00120A000F00263Q002084000F000F0004001231001000083Q001231001100083Q001231001200084Q0092000F00120002001094000E0025000F001231000C00203Q00043F3Q003700012Q0085000C6Q0085000A5Q00066A000700350001000200043F3Q0035000100208B0007000100272Q0066000700023Q00267B0002008F0001002000043F3Q008F00010030230004002800292Q0071000700053Q00208400070007002B0010940004002A000700120A000700133Q00208400070007002C00208400070007002D0010940004002C0007001231000200023Q00267B0002009A0001000800043F3Q009A00012Q0071000700053Q00208400070007002E0010940003001D00070030230003002F00012Q0071000700024Q0010000800033Q001231000900304Q0087000700090001001231000200183Q00267B000200B20001000100043F3Q00B2000100120A000700033Q0020840007000700042Q007100085Q0020840008000800312Q001000096Q00920007000900022Q0010000300073Q00120A000700073Q002084000700070004001231000800083Q001231000900323Q001231000A00013Q001231000B00334Q00920007000B000200109400030006000700120A000700073Q00208400070007000C001231000800184Q0010000900014Q00920007000900020010940003000B0007001231000200083Q000E52001A00C00001000200043F3Q00C000010030230004001000082Q007100075Q0020840007000700342Q0071000800033Q0020840008000800242Q00880007000700080010940004001E000700120A000700133Q002084000700070035002084000700070036001094000400350007001231000200203Q00267B000200020001001800043F3Q0002000100120A000700033Q0020840007000700042Q007100085Q0020840008000800372Q0010000900034Q00920007000900022Q0010000400073Q00120A000700073Q002084000700070004001231000800083Q001231000900383Q001231000A00013Q001231000B00394Q00920007000B000200109400040006000700120A000700073Q00208400070007000C0012310008003A3Q001231000900024Q00920007000900020010940004000B00070012310002001A3Q00043F3Q000200012Q00393Q00013Q00013Q00113Q00028Q0003083Q00455350436F6C6F72030C3Q00455350436F6C6F724E616D65027Q0040026Q00F03F03043Q0054657874025Q0090854003053Q007061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q00A8854003153Q0046696E6446697273744368696C644F66436C612Q73025Q00B8854003093Q00546869636B6E652Q7303023Q00686C03093Q0046692Q6C436F6C6F72030C3Q004F75746C696E65436F6C6F7200573Q0012313Q00013Q00267B3Q00130001000100043F3Q001300012Q007100016Q007100026Q0071000300013Q0020840003000300042Q0071000400013Q0020840004000400050010940002000300040010940001000200032Q0071000100024Q0071000200033Q0020840002000200072Q0071000300013Q0020840003000300052Q00880002000200030010940001000600020012313Q00053Q00267B3Q00010001000500043F3Q0001000100120A000100084Q0071000200043Q0020210002000200092Q0003000200034Q006900013Q000300043F3Q0036000100202100060005000A2Q0071000800033Q00208400080008000B2Q009200060008000200065C0006003600013Q00043F3Q00360001001231000600014Q008D000700073Q000E52000100230001000600043F3Q0023000100202100080005000C2Q0071000A00033Q002084000A000A000D2Q00920008000A00022Q0010000700083Q00065C0007003600013Q00043F3Q003600012Q0071000800053Q00060B000500320001000800043F3Q00320001001231000800043Q000609000800330001000100043F3Q00330001001231000800013Q0010940007000E000800043F3Q0036000100043F3Q0023000100066A0001001B0001000200043F3Q001B000100120A000100084Q0071000200064Q001E00010002000300043F3Q0052000100208400060005000F00065C0006005200013Q00043F3Q00520001001231000600014Q008D000700073Q00267B000600410001000100043F3Q00410001001231000700013Q000E52000100440001000700043F3Q0044000100208400080005000F2Q007100095Q00208400090009000200109400080010000900208400080005000F2Q007100095Q00208400090009000200109400080011000900043F3Q0052000100043F3Q0044000100043F3Q0052000100043F3Q0041000100066A0001003C0001000200043F3Q003C000100043F3Q0056000100043F3Q000100012Q00393Q00017Q000E3Q00028Q00026Q00F03F03063Q00434672616D652Q033Q006E657703163Q00412Q73656D626C794C696E65617256656C6F6369747903023Q005F47025Q0018874003043Q007A65726F03093Q00436861726163746572030E3Q0046696E6446697273744368696C64025Q0040874003083Q00506F736974696F6E03093Q004D61676E6974756465026Q00244001283Q001231000100014Q008D000200023Q00267B000100100001000200043F3Q0010000100120A000300033Q0020840003000300042Q001000046Q006E00030002000200109400020003000300120A000300064Q007100045Q0020840004000400072Q003600030003000400208400030003000800109400020005000300043F3Q0027000100267B000100020001000100043F3Q000200012Q0071000300013Q0020840003000300090006600002001D0001000300043F3Q001D00012Q0071000300013Q00208400030003000900202100030003000A2Q007100055Q00208400050005000B2Q00920003000500022Q0010000200033Q00065C0002002400013Q00043F3Q0024000100208400030002000C2Q0045000300033Q00208400030003000D002602000300250001000E00043F3Q002500012Q00393Q00013Q001231000100023Q00043F3Q000200012Q00393Q00017Q00073Q00030E3Q0046696E6446697273744368696C64025Q00608740025Q00708740025Q00808740025Q0090874003163Q0046696E6446697273744368696C645768696368497341025Q00A0874001203Q0006600001001E00013Q00043F3Q001E000100202100013Q00012Q007100035Q0020840003000300022Q00920001000300020006090001001E0001000100043F3Q001E000100202100013Q00012Q007100035Q0020840003000300032Q00920001000300020006090001001E0001000100043F3Q001E000100202100013Q00012Q007100035Q0020840003000300042Q00920001000300020006090001001E0001000100043F3Q001E000100202100013Q00012Q007100035Q0020840003000300052Q00920001000300020006090001001E0001000100043F3Q001E000100202100013Q00062Q007100035Q0020840003000300072Q00920001000300022Q0066000100024Q00393Q00017Q000B3Q00028Q00026Q00F03F030C3Q0056696577706F727453697A65027Q004003013Q005803013Q005903043Q006D61746803043Q007371727403143Q00576F726C64546F56696577706F7274506F696E7403013Q005A024Q0080842E4101423Q001231000100014Q008D000200063Q001231000700013Q000E520002001B0001000700043F3Q001B000100267B000100020001000200043F3Q00020001001231000800013Q00267B000800150001000100043F3Q001500012Q007100095Q002084000900090003002040000400090004002084000900020005002084000A000400052Q004500090009000A002084000A00020006002084000B000400062Q00450006000A000B2Q0010000500093Q001231000800023Q000E52000200080001000800043F3Q00080001001231000100043Q00043F3Q0002000100043F3Q0008000100043F3Q0002000100267B000700030001000100043F3Q0003000100267B000100260001000400043F3Q0026000100120A000800073Q0020840008000800082Q00670009000500052Q0067000A000600062Q009600090009000A2Q0020000800094Q007800085Q00267B0001003E0001000100043F3Q003E0001001231000800013Q00267B0008002D0001000200043F3Q002D0001001231000100023Q00043F3Q003E000100267B000800290001000100043F3Q002900012Q007100095Q0020210009000900092Q0010000B6Q002A0009000B000A2Q00100003000A4Q0010000200093Q00065C0003003A00013Q00043F3Q003A000100208400090002000A0026020009003C0001000100043F3Q003C00010012310009000B4Q0066000900023Q001231000800023Q00043F3Q00290001001231000700023Q00043F3Q0003000100043F3Q000200012Q00393Q00017Q00123Q00028Q00026Q00F03F024Q0080842E412Q033Q00464F5603093Q00436861726163746572030E3Q0046696E6446697273744368696C64025Q00088840027Q004003063Q00697061697273030A3Q00476574506C617965727303153Q0046696E6446697273744368696C644F66436C612Q73025Q0030884003063Q004865616C7468025Q00508840025Q0068884003083Q00506F736974696F6E03093Q004D61676E697475646503073Q004D61784469737401893Q001231000100014Q008D000200063Q001231000700013Q00267B0007002E0001000100043F3Q002E000100267B000100280001000100043F3Q00280001001231000800013Q00267B0008000C0001000200043F3Q000C0001001231000100023Q00043F3Q0028000100267B000800080001000100043F3Q0008000100065C3Q001300013Q00043F3Q00130001001231000900033Q000609000900150001000100043F3Q001500012Q007100095Q0020840009000900042Q008D000A000A3Q001231000B00034Q008D000500054Q00100004000B4Q00100003000A4Q0010000200094Q0071000900013Q002084000900090005000660000600260001000900043F3Q002600012Q0071000900013Q0020840009000900050020210009000900062Q0071000B00023Q002084000B000B00072Q00920009000B00022Q0010000600093Q001231000800023Q00043F3Q0008000100267B0001002D0001000800043F3Q002D00012Q0010000800034Q0010000900054Q0068000800033Q001231000700023Q00267B000700030001000200043F3Q0003000100267B000100020001000200043F3Q00020001000609000600350001000100043F3Q003500012Q00393Q00013Q00120A000800094Q0071000900033Q00202100090009000A2Q00030009000A4Q006900083Q000A00043F3Q008200012Q0071000D00013Q000604000C00820001000D00043F3Q00820001002084000D000C000500065C000D008200013Q00043F3Q00820001001231000D00014Q008D000E000E3Q000E52000100430001000D00043F3Q00430001002084000F000C0005002021000F000F000B2Q0071001100023Q00208400110011000C2Q0092000F001100022Q0010000E000F3Q00065C000E008200013Q00043F3Q00820001002084000F000E000D000E4B000100820001000F00043F3Q00820001001231000F00014Q008D001000103Q00267B000F00520001000100043F3Q005200010020840011000C00050020210011001100062Q0071001300023Q00208400130013000E2Q0092001100130002000677001000610001001100043F3Q006100010020840011000C00050020210011001100062Q0071001300023Q00208400130013000F2Q00920011001300022Q0010001000113Q00065C0010008200013Q00043F3Q008200010020840011001000100020840012000600102Q00450011001100120020840011001100112Q007100125Q002084001200120012000629001100820001001200043F3Q00820001001231001100014Q008D001200123Q000E520001006D0001001100043F3Q006D00012Q0071001300043Q0020840014001000102Q006E0013000200022Q0010001200133Q000682001200820001000200043F3Q00820001000682001200820001000400043F3Q008200012Q0010001300123Q0020840014001000102Q00100005000C4Q0010000300144Q0010000400133Q00043F3Q0082000100043F3Q006D000100043F3Q0082000100043F3Q0052000100043F3Q0082000100043F3Q0043000100066A0008003B0001000200043F3Q003B0001001231000100083Q00043F3Q0002000100043F3Q0003000100043F3Q000200012Q00393Q00017Q00073Q00028Q00026Q00F03F2Q033Q00464F5603063Q00697061697273030A3Q00476574506C617965727303093Q0043686172616374657203083Q00506F736974696F6E00523Q0012313Q00014Q008D000100033Q00267B3Q004B0001000200043F3Q004B00012Q008D000300033Q001231000400013Q00267B000400060001000100043F3Q0006000100267B000100440001000100043F3Q00440001001231000500013Q00267B0005003F0001000100043F3Q003F00012Q008D000600064Q007100075Q0020840003000700032Q0010000200063Q00120A000600044Q0071000700013Q0020210007000700052Q0003000700084Q006900063Q000800043F3Q003C00012Q0071000B00023Q000604000A003C0001000B00043F3Q003C0001002084000B000A000600065C000B003C00013Q00043F3Q003C0001001231000B00014Q008D000C000C3Q00267B000B001F0001000100043F3Q001F00012Q0071000D00033Q002084000E000A00062Q006E000D000200022Q0010000C000D3Q00065C000C003C00013Q00043F3Q003C0001001231000D00014Q008D000E000E3Q00267B000D00290001000100043F3Q002900012Q0071000F00043Q0020840010000C00072Q006E000F000200022Q0010000E000F4Q0071000F5Q002084000F000F0003000682000E003C0001000F00043F3Q003C0001000682000E003C0001000300043F3Q003C00012Q0010000F000E4Q00100002000A4Q00100003000F3Q00043F3Q003C000100043F3Q0029000100043F3Q003C000100043F3Q001F000100066A000600170001000200043F3Q00170001001231000500023Q00267B0005000B0001000200043F3Q000B0001001231000100023Q00043F3Q0044000100043F3Q000B000100267B000100050001000200043F3Q000500012Q0066000200023Q00043F3Q0005000100043F3Q0006000100043F3Q0005000100043F3Q0051000100267B3Q00020001000100043F3Q00020001001231000100014Q008D000200023Q0012313Q00023Q00043F3Q000200012Q00393Q00017Q00103Q00028Q00026Q00F03F027Q004003063Q00697061697273030A3Q00476574506C617965727303093Q0043686172616374657203153Q0046696E6446697273744368696C644F66436C612Q73025Q00F0884003063Q004865616C7468030E3Q0046696E6446697273744368696C64025Q00108940025Q0028894003083Q00506F736974696F6E03093Q004D61676E697475646503083Q004175726144697374025Q0070894000853Q0012313Q00014Q008D000100053Q00267B3Q00070001000100043F3Q00070001001231000100014Q008D000200023Q0012313Q00023Q00267B3Q007F0001000300043F3Q007F00012Q008D000500053Q001231000600013Q00267B000600590001000200043F3Q0059000100267B0001000A0001000200043F3Q000A0001000609000500120001000100043F3Q001200012Q00393Q00013Q00120A000700044Q007100085Q0020210008000800052Q0003000800094Q006900073Q000900043F3Q005500012Q0071000C00013Q000604000B00550001000C00043F3Q00550001002084000C000B000600065C000C005500013Q00043F3Q00550001001231000C00014Q008D000D000D3Q000E52000100200001000C00043F3Q00200001002084000E000B0006002021000E000E00072Q0071001000023Q0020840010001000082Q0092000E001000022Q0010000D000E3Q00065C000D005500013Q00043F3Q00550001002084000E000D0009000E4B000100550001000E00043F3Q00550001001231000E00014Q008D000F000F3Q00267B000E002F0001000100043F3Q002F00010020840010000B000600202100100010000A2Q0071001200023Q00208400120012000B2Q0092001000120002000677000F003E0001001000043F3Q003E00010020840010000B000600202100100010000A2Q0071001200023Q00208400120012000C2Q00920010001200022Q0010000F00103Q00065C000F005500013Q00043F3Q00550001001231001000014Q008D001100113Q00267B001000420001000100043F3Q004200010020840012000F000D00208400130005000D2Q004500120012001300208400110012000E000629001100550001000400043F3Q005500012Q0010001200113Q0020840013000F000D2Q00100003000B4Q0010000200134Q0010000400123Q00043F3Q0055000100043F3Q0042000100043F3Q0055000100043F3Q002F000100043F3Q0055000100043F3Q0020000100066A000700180001000200043F3Q00180001001231000100033Q00043F3Q000A000100267B0006000B0001000100043F3Q000B000100267B000100760001000100043F3Q00760001001231000700013Q00267B000700710001000100043F3Q007100012Q008D000800094Q0071000A00033Q0020840004000A000F2Q0010000300094Q0010000200084Q0071000800013Q002084000800080006000660000500700001000800043F3Q007000012Q0071000800013Q00208400080008000600202100080008000A2Q0071000A00023Q002084000A000A00102Q00920008000A00022Q0010000500083Q001231000700023Q00267B0007005E0001000200043F3Q005E0001001231000100023Q00043F3Q0076000100043F3Q005E000100267B0001007B0001000300043F3Q007B00012Q0010000700024Q0010000800034Q0068000700033Q001231000600023Q00043F3Q000B000100043F3Q000A000100043F3Q0084000100267B3Q00020001000200043F3Q000200012Q008D000300043Q0012313Q00033Q00043F3Q000200012Q00393Q00017Q000F3Q0003063Q0053696C656E7402AE47E17A14AEEF3F03043Q006D61746803053Q00636C616D7003063Q00536D2Q6F7468026Q00F03F02CD5QCCDC3F02B81E85EB51B8EE3F03093Q00537469636B7941696D2Q033Q006D617802CD5QCCEC3F03063Q00434672616D6503043Q004C65727003063Q006C2Q6F6B417403083Q00506F736974696F6E022D3Q0006093Q00030001000100043F3Q000300012Q00393Q00013Q000609000100090001000100043F3Q000900012Q007100025Q00208400020002000100065C0002000C00013Q00043F3Q000C0001001231000200023Q000609000200140001000100043F3Q0014000100120A000200033Q0020840002000200042Q007100035Q002084000300030005001043000300060003001231000400073Q001231000500084Q00920002000500022Q007100035Q00208400030003000900065C0003001E00013Q00043F3Q001E000100120A000300033Q00208400030003000A2Q0010000400023Q0012310005000B4Q00920003000500022Q0010000200034Q0071000300014Q0071000400013Q00208400040004000C00202100040004000D00120A0006000C3Q00208400060006000E2Q0071000700013Q00208400070007000C00208400070007000F2Q001000086Q00920006000800022Q0010000700024Q00920004000700020010940003000C00042Q00393Q00017Q00043Q00028Q0003023Q005F47025Q00D08940025Q00208A40011B3Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q0002000100120A000300024Q007100045Q0020840004000400032Q003600030003000400060F00043Q000100032Q002F8Q00803Q00014Q00808Q006E0003000200022Q0010000200033Q0006090002001A0001000100043F3Q001A000100120A000300024Q007100045Q0020840004000400042Q003600030003000400060F00040001000100022Q00803Q00024Q002F8Q004F00030002000100043F3Q001A000100043F3Q000200012Q00393Q00013Q00023Q000A3Q00028Q00026Q00F03F03093Q0053656E644173796E6303053Q00652Q726F7203013Q0078030E3Q0046696E6446697273744368696C64025Q00F88940025Q00088A4003163Q0046696E6446697273744368696C645768696368497341025Q00188A4000293Q0012313Q00014Q008D000100023Q00267B3Q00110001000200043F3Q0011000100065C0002000D00013Q00043F3Q000D000100208400030002000300065C0003000D00013Q00043F3Q000D00010020210003000200032Q007100056Q008700030005000100043F3Q0028000100120A000300043Q001231000400054Q004F00030002000100043F3Q0028000100267B3Q00020001000100043F3Q000200012Q0071000300013Q0020210003000300062Q0071000500023Q0020840005000500072Q00920003000500022Q0010000100033Q000660000200260001000100043F3Q002600010020210003000100062Q0071000500023Q0020840005000500082Q0092000300050002000677000200260001000300043F3Q002600010020210003000100092Q0071000500023Q00208400050005000A2Q00920003000500022Q0010000200033Q0012313Q00023Q00043F3Q000200012Q00393Q00017Q00013Q0003043Q004368617400054Q00717Q0020215Q00012Q0071000200014Q00873Q000200012Q00393Q00017Q00033Q00030B3Q00446973706C61794E616D65034Q0003043Q004E616D6501093Q00208400013Q0001002653000100060001000200043F3Q0006000100208400013Q0001000609000100070001000100043F3Q0007000100208400013Q00032Q0066000100024Q00393Q00017Q00023Q0003023Q005F47025Q00508A40010A3Q00120A000100014Q007100025Q0020840002000200022Q003600010001000200060F00023Q000100032Q00803Q00014Q00808Q002F8Q004F0001000200012Q00393Q00013Q00013Q000A3Q00028Q00026Q00F03F030E3Q0046696E6446697273744368696C64025Q00608A40025Q00708A40025Q00808A402Q033Q00497341025Q00908A40030C3Q00496E766F6B65536572766572030A3Q004669726553657276657200353Q0012313Q00014Q008D000100013Q00267B3Q001A0001000100043F3Q001A0001001231000200013Q00267B000200090001000200043F3Q000900010012313Q00023Q00043F3Q001A000100267B000200050001000100043F3Q000500012Q007100035Q0020210003000300032Q0071000500013Q0020840005000500042Q00920003000500022Q0010000100033Q00065C0001001800013Q00043F3Q001800010020210003000100032Q0071000500013Q0020840005000500052Q00920003000500022Q0010000100033Q001231000200023Q00043F3Q0005000100267B3Q00020001000200043F3Q0002000100065C0001002300013Q00043F3Q002300010020210002000100032Q0071000400013Q0020840004000400062Q00920002000400022Q0010000100023Q00065C0001003400013Q00043F3Q003400010020210002000100072Q0071000400013Q0020840004000400082Q009200020004000200065C0002002F00013Q00043F3Q002F00010020210002000100092Q0071000400024Q008700020004000100043F3Q0034000100202100020001000A2Q0071000400024Q008700020004000100043F3Q0034000100043F3Q000200012Q00393Q00017Q00113Q00028Q00026Q00F03F025Q00A88A4003023Q005F47025Q00B08A40029A5Q990140027Q0040026Q00104003063Q004865616C7468025Q00C08A40025Q00C88A40026Q00084003093Q0043686172616374657203153Q0046696E6446697273744368696C644F66436C612Q73025Q00E88A40025Q00F08A40030A3Q002F72657669737461722000673Q0012313Q00014Q008D000100033Q00267B3Q00210001000200043F3Q00210001000609000100190001000100043F3Q00190001001231000400014Q008D000500053Q000E52000100080001000400043F3Q00080001001231000500013Q00267B0005000B0001000100043F3Q000B0001001231000600013Q00267B0006000E0001000100043F3Q000E00012Q007100076Q0071000800013Q0020840008000800032Q004F0007000200012Q00393Q00013Q00043F3Q000E000100043F3Q000B000100043F3Q0019000100043F3Q0008000100120A000400044Q0071000500013Q0020840005000500052Q00360004000400052Q004E00040001000200208B0004000400062Q007F000400023Q0012313Q00073Q00267B3Q00330001000800043F3Q003300012Q007100045Q00065C0003002900013Q00043F3Q002900010020840005000300090026720005002D0001000100043F3Q002D00012Q0071000500013Q00208400050005000A0006090005002F0001000100043F3Q002F00012Q0071000500013Q00208400050005000B2Q0010000600024Q00880005000500062Q004F00040002000100043F3Q0066000100267B3Q00420001000C00043F3Q004200012Q0071000400034Q0010000500014Q004F00040002000100208400040001000D000660000300410001000400043F3Q0041000100208400040001000D00202100040004000E2Q0071000600013Q00208400060006000F2Q00920004000600022Q0010000300043Q0012313Q00083Q00267B3Q00510001000100043F3Q0051000100120A000400044Q0071000500013Q0020840005000500102Q00360004000400052Q004E0004000100022Q0071000500023Q0006820004004D0001000500043F3Q004D00012Q00393Q00014Q0071000400044Q004E0004000100022Q0010000100043Q0012313Q00023Q00267B3Q00020001000700043F3Q00020001001231000400013Q000E52000200580001000400043F3Q005800010012313Q000C3Q00043F3Q0002000100267B000400540001000100043F3Q005400012Q0071000500054Q0010000600014Q006E0005000200022Q0010000200054Q0071000500063Q001231000600114Q0010000700024Q00880006000600072Q004F000500020001001231000400023Q00043F3Q0054000100043F3Q000200012Q00393Q00017Q000F3Q00028Q0003063Q004E6F636C6970030A3Q00446973636F2Q6E656374026Q00F03F027Q004003073Q005374652Q70656403073Q00436F2Q6E65637403063Q00697061697273030E3Q0047657444657363656E64616E74732Q033Q00497341025Q00688B40030A3Q0043616E436F2Q6C69646503043Q004E616D65025Q00808B4003093Q0043686172616374657201473Q001231000100014Q008D000200023Q00267B0001001A0001000100043F3Q001A00012Q007100035Q001094000300024Q0071000300013Q00065C0003001900013Q00043F3Q00190001001231000300014Q008D000400043Q00267B0003000B0001000100043F3Q000B0001001231000400013Q00267B0004000E0001000100043F3Q000E00012Q0071000500013Q0020210005000500032Q004F0005000200012Q008D000500054Q007F000500013Q00043F3Q0019000100043F3Q000E000100043F3Q0019000100043F3Q000B0001001231000100043Q00267B0001003D0001000500043F3Q003D000100065C3Q002700013Q00043F3Q002700012Q0071000300023Q00208400030003000600202100030003000700060F00053Q000100022Q00803Q00034Q00803Q00044Q00920003000500022Q007F000300013Q00043F3Q0046000100120A000300083Q0020210004000200092Q0003000400054Q006900033Q000500043F3Q003A000100202100080007000A2Q0071000A00043Q002084000A000A000B2Q00920008000A000200065C0008003A00013Q00043F3Q003A000100208400080007000D2Q0071000900043Q00208400090009000E00060B000800380001000900043F3Q003800012Q000500086Q007A000800013Q0010940007000C000800066A0003002C0001000200043F3Q002C000100043F3Q0046000100267B000100020001000400043F3Q000200012Q0071000300033Q00208400020003000F000609000200440001000100043F3Q004400012Q00393Q00013Q001231000100053Q00043F3Q000200012Q00393Q00013Q00013Q00093Q00028Q00026Q00F03F03093Q0043686172616374657203063Q00697061697273030E3Q0047657444657363656E64616E74732Q033Q00497341025Q00488B40030A3Q0043616E436F2Q6C696465012Q00253Q0012313Q00014Q008D000100013Q00267B3Q00120001000100043F3Q00120001001231000200013Q00267B000200090001000200043F3Q000900010012313Q00023Q00043F3Q0012000100267B000200050001000100043F3Q000500012Q007100035Q002084000100030003000609000100100001000100043F3Q001000012Q00393Q00013Q001231000200023Q00043F3Q00050001000E520002000200013Q00043F3Q0002000100120A000200043Q0020210003000100052Q0003000300044Q006900023Q000400043F3Q002000010020210007000600062Q0071000900013Q0020840009000900072Q009200070009000200065C0007002000013Q00043F3Q0020000100302300060008000900066A000200190001000200043F3Q0019000100043F3Q0024000100043F3Q000200012Q00393Q00017Q00143Q00028Q002Q033Q00466C7903023Q005F47025Q00988B40026Q00F03F026Q00084003083Q004D6178466F726365025Q00B08B402Q033Q006E6577023Q00C088C3004203063Q00506172656E74027Q004003083Q00496E7374616E6365025Q00D08B4003093Q00436861726163746572030E3Q0046696E6446697273744368696C64025Q00F08B4003163Q00412Q73656D626C794C696E65617256656C6F63697479026Q008C4003043Q007A65726F01673Q001231000100014Q008D000200023Q00267B0001001E0001000100043F3Q001E00012Q007100035Q001094000300024Q0071000300013Q00065C0003001D00013Q00043F3Q001D0001001231000300014Q008D000400043Q00267B0003000B0001000100043F3Q000B0001001231000400013Q00267B0004000E0001000100043F3Q000E000100120A000500034Q0071000600023Q0020840006000600042Q003600050005000600060F00063Q000100012Q00803Q00014Q004F0005000200012Q008D000500054Q007F000500013Q00043F3Q001D000100043F3Q000E000100043F3Q001D000100043F3Q000B0001001231000100053Q00267B0001002E0001000600043F3Q002E00012Q0071000300013Q00120A000400034Q0071000500023Q0020840005000500082Q00360004000400050020840004000400090012310005000A3Q0012310006000A3Q0012310007000A4Q00920004000700020010940003000700042Q0071000300013Q0010940003000B000200043F3Q0066000100267B0001003A0001000C00043F3Q003A0001000609000200330001000100043F3Q003300012Q00393Q00013Q00120A0003000D3Q0020840003000300092Q0071000400023Q00208400040004000E2Q006E0003000200022Q007F000300013Q001231000100063Q00267B000100020001000500043F3Q00020001001231000300013Q00267B000300410001000500043F3Q004100010012310001000C3Q00043F3Q0002000100267B0003003D0001000100043F3Q003D00012Q0071000400033Q00208400040004000F0006600002004E0001000400043F3Q004E00012Q0071000400033Q00208400040004000F0020210004000400102Q0071000600023Q0020840006000600112Q00920004000600022Q0010000200043Q0006093Q00630001000100043F3Q00630001001231000400014Q008D000500053Q00267B000400520001000100043F3Q00520001001231000500013Q00267B000500550001000100043F3Q0055000100065C0002005F00013Q00043F3Q005F000100120A000600034Q0071000700023Q0020840007000700132Q00360006000600070020840006000600140010940002001200062Q00393Q00013Q00043F3Q0055000100043F3Q0063000100043F3Q00520001001231000300053Q00043F3Q003D000100043F3Q000200012Q00393Q00013Q00013Q00013Q0003073Q0044657374726F7900044Q00717Q0020215Q00012Q004F3Q000200012Q00393Q00017Q00083Q00025Q00108C4003063Q0053696C656E74025Q00208C4003093Q00537469636B7941696D025Q00308C40030A3Q0053696C656E7441757261025Q00408C40025Q00488C4002254Q007100025Q00208400020002000100060B3Q00070001000200043F3Q000700012Q0071000200013Q00109400020002000100043F3Q002400012Q007100025Q00208400020002000300060B3Q000E0001000200043F3Q000E00012Q0071000200013Q00109400020004000100043F3Q002400012Q007100025Q00208400020002000500060B3Q00150001000200043F3Q001500012Q0071000200013Q00109400020006000100043F3Q002400012Q007100025Q00208400020002000700060B3Q001D0001000200043F3Q001D00012Q0071000200024Q0010000300014Q004F00020002000100043F3Q002400012Q007100025Q00208400020002000800060B3Q00240001000200043F3Q002400012Q0071000200034Q0010000300014Q004F0002000200012Q00393Q00017Q00513Q00028Q00026Q001040026Q00204003083Q00506F736974696F6E03053Q005544696D322Q033Q006E657702CD5QCCDC3F026Q00E03F026Q0020C003103Q004261636B67726F756E64436F6C6F72332Q033Q0042617203043Q0054657874025Q00788C4003043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q002440030A3Q0054657874436F6C6F723303043Q00536F6674026Q002240027Q0040026Q00284003023Q005478030E3Q005465787458416C69676E6D656E7403043Q004C65667403083Q00496E7374616E6365025Q00E88C4003043Q0053697A65030A3Q0066726F6D4F2Q66736574026Q004340026Q003240026Q00F03F026Q0047C0026Q0022C0026Q000840025Q00188D40026Q0010C0026Q002Q4003043Q0043617264030F3Q00426F7264657253697A65506978656C026Q001C4003063Q00476F7468616D2Q033Q0044696D025Q00A88D40026Q003040026Q001840025Q00C88D40029A5Q99D93F03163Q004261636B67726F756E645472616E73706172656E6379026Q008E40026Q00144003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E656374025Q00208E40026Q00344003063Q00436F6C6F723303073Q0066726F6D524742026Q003840026Q004440025Q00608E4003063Q0053696C656E74025Q00708E4003093Q00537469636B7941696D025Q00808E40030A3Q0053696C656E7441757261025Q00908E4003063Q004E6F636C69702Q033Q00466C7903023Q0041632Q033Q004F2Q66034Q00025Q00D88E40026Q002C40025Q00F88E40026Q004AC0026Q0030C0026Q001CC0026Q004C40025Q00A88F40025Q00B08F400583012Q001231000500014Q008D0006000E3Q001231000F00013Q000E52000200430001000F00043F3Q00430001000E52000300220001000500043F3Q0022000100120A001000053Q002084001000100006001231001100073Q001231001200013Q001231001300083Q001231001400094Q0092001000140002001094000E000400102Q007100105Q00208400100010000B001094000E000A00102Q0071001000014Q0036001000100003000609001000180001000100043F3Q001800012Q0071001000023Q00208400100010000D001094000E000C001000120A0010000F3Q00208400100010000E002084001000100010001094000E000E0010003023000E001100122Q007100105Q002084001000100014001094000E00130010001231000500153Q00267B000500020001001600043F3Q000200010030230007001100172Q007100105Q00208400100010001800109400070013001000120A0010000F3Q00208400100010001900208400100010001A00109400070019001000120A0010001B3Q0020840010001000062Q0071001100023Q00208400110011001C2Q0010001200064Q00920010001200022Q0010000800103Q00120A001000053Q00208400100010001E0012310011001F3Q001231001200204Q00920010001200020010940008001D001000120A001000053Q002084001000100006001231001100213Q001231001200223Q001231001300083Q001231001400234Q0092001000140002001094000800040010001231000500243Q00043F3Q0002000100267B000F00840001002400043F3Q0084000100267B000500650001000100043F3Q0065000100120A0010001B3Q0020840010001000062Q0071001100023Q0020840011001100252Q001000126Q00920010001200022Q0010000600103Q00120A001000053Q002084001000100006001231001100213Q001231001200263Q001231001300013Q001231001400274Q00920010001400020010940006001D001000120A001000053Q00208400100010001E001231001100164Q0010001200024Q00920010001200020010940006000400102Q007100105Q0020840010001000280010940006000A00100030230006002900012Q0071001000034Q0010001100063Q001231001200034Q0087001000120001001231000500213Q00267B000500830001002A00043F3Q0083000100120A0010000F3Q00208400100010000E00208400100010002B001094000D000E0010003023000D001100122Q007100105Q00208400100010002C001094000D0013001000120A0010000F3Q00208400100010001900208400100010001A001094000D0019001000120A0010001B3Q0020840010001000062Q0071001100023Q00208400110011002D2Q00100012000C4Q00920010001200022Q0010000E00103Q00120A001000053Q002084001000100006001231001100083Q001231001200093Q001231001300013Q0012310014002E4Q0092001000140002001094000E001D0010001231000500033Q001231000F00023Q00267B000F00CD0001000100043F3Q00CD0001000E52002F00A60001000500043F3Q00A600012Q0071001000034Q00100011000C3Q0012310012002F4Q008700100012000100120A0010001B3Q0020840010001000062Q0071001100023Q0020840011001100302Q00100012000C4Q00920010001200022Q0010000D00103Q00120A001000053Q002084001000100006001231001100313Q001231001200013Q001231001300213Q001231001400014Q0092001000140002001094000D001D001000120A001000053Q00208400100010001E001231001100033Q001231001200014Q0092001000120002001094000D00040010003023000D003200212Q0071001000023Q002084001000100033001094000D000C00100012310005002A3Q00267B000500CC0001003400043F3Q00CC000100208400100008003500202100100010003600060F00123Q000100022Q002F3Q000B4Q002F3Q00094Q008700100012000100120A0010001B3Q0020840010001000062Q0071001100023Q0020840011001100372Q001000126Q00920010001200022Q0010000C00103Q00120A001000053Q002084001000100006001231001100213Q001231001200263Q001231001300013Q001231001400384Q0092001000140002001094000C001D001000120A001000053Q00208400100010001E001231001100163Q00208B0012000200272Q0092001000120002001094000C0004001000120A001000393Q00208400100010003A0012310011002E3Q0012310012003B3Q0012310013003C4Q0092001000130002001094000C000A0010003023000C002900010012310005002F3Q001231000F00213Q00267B000F002E2Q01002100043F3Q002E2Q01000E520024000F2Q01000500043F3Q000F2Q012Q0071001000023Q00208400100010003D00060B000300D90001001000043F3Q00D900012Q0071001000043Q00208400100010003E000677000900F30001001000043F3Q00F300012Q0071001000023Q00208400100010003F00060B000300E10001001000043F3Q00E100012Q0071001000043Q002084001000100040000677000900F30001001000043F3Q00F300012Q0071001000023Q00208400100010004100060B000300E90001001000043F3Q00E900012Q0071001000043Q002084001000100042000677000900F30001001000043F3Q00F300012Q0071001000023Q00208400100010004300060B000300F10001001000043F3Q00F100012Q0071001000043Q002084001000100044000677000900F30001001000043F3Q00F300012Q0071001000043Q00208400090010004500065C000900F900013Q00043F3Q00F900012Q007100105Q002084001000100046000609001000FB0001000100043F3Q00FB00012Q007100105Q0020840010001000470010940008000A00100030230008000C00482Q0071001000034Q0010001100083Q001231001200154Q008700100012000100120A0010001B3Q0020840010001000062Q0071001100023Q0020840011001100492Q0010001200084Q00920010001200022Q0010000A00103Q00120A001000053Q00208400100010001E0012310011004A3Q0012310012004A4Q0092001000120002001094000A001D0010001231000500023Q00267B0005002D2Q01002100043F3Q002D2Q0100120A0010001B3Q0020840010001000062Q0071001100023Q00208400110011004B2Q0010001200064Q00920010001200022Q0010000700103Q00120A001000053Q002084001000100006001231001100213Q0012310012004C3Q001231001300213Q001231001400014Q00920010001400020010940007001D001000120A001000053Q00208400100010001E001231001100123Q001231001200014Q00920010001200020010940007000400100030230007003200210010940007000C000100120A0010000F3Q00208400100010000E00208400100010002B0010940007000E0010001231000500163Q001231000F00163Q00267B000F00030001001600043F3Q00030001000E52000200572Q01000500043F3Q00572Q0100065C0009003D2Q013Q00043F3Q003D2Q0100120A001000053Q002084001000100006001231001100213Q0012310012004D3Q001231001300083Q0012310014004E4Q0092001000140002000609001000422Q01000100043F3Q00422Q0100120A001000053Q00208400100010001E001231001100163Q001231001200164Q0092001000120002001094000A0004001000120A001000393Q002084001000100006001231001100213Q001231001200213Q001231001300214Q0092001000130002001094000A000A0010003023000A002900012Q0071001000034Q00100011000A3Q0012310012002A4Q00870010001200012Q008D000B000B3Q00060F000B0001000100052Q002F3Q00094Q002F3Q00084Q00808Q002F3Q000A4Q002F3Q00043Q001231000500343Q00267B0005007F2Q01001500043F3Q007F2Q01001231001000013Q00267B0010005E2Q01001600043F3Q005E2Q0100208B00110002004F2Q0066001100023Q00267B001000752Q01002100043F3Q00752Q012Q0071001100054Q003A00123Q00022Q0071001300023Q00208400130013005000060F00140002000100012Q002F3Q00094Q003E0012001300142Q0071001300023Q0020840013001300512Q003E00120013000B2Q003E0011000300120020840011000E003500202100110011003600060F00130003000100052Q00803Q00064Q002F3Q00034Q002F3Q000E4Q00803Q00024Q00803Q00074Q0087001100130001001231001000163Q000E520001005A2Q01001000043F3Q005A2Q012Q0071001100034Q00100012000E3Q001231001300344Q00870011001300012Q0071001100084Q003E00110003000E001231001000213Q00043F3Q005A2Q01001231000F00243Q00043F3Q0003000100043F3Q000200012Q00393Q00013Q00048Q00054Q00718Q0071000100014Q001B000100014Q004F3Q000200012Q00393Q00017Q000D3Q00028Q0003103Q004261636B67726F756E64436F6C6F723303023Q0041632Q033Q004F2Q66026Q00F03F03083Q00506F736974696F6E03053Q005544696D322Q033Q006E6577026Q0030C0026Q00E03F026Q001CC0030A3Q0066726F6D4F2Q66736574027Q004001373Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q00020001001231000200013Q00267B0002001A0001000100043F3Q001A000100065C3Q000C00013Q00043F3Q000C00012Q007A000300013Q0006090003000D0001000100043F3Q000D00012Q007A00036Q007F00036Q0071000300014Q007100045Q00065C0004001600013Q00043F3Q001600012Q0071000400023Q002084000400040003000609000400180001000100043F3Q001800012Q0071000400023Q002084000400040004001094000300020004001231000200053Q000E52000500050001000200043F3Q000500012Q0071000300034Q007100045Q00065C0004002900013Q00043F3Q0029000100120A000400073Q002084000400040008001231000500053Q001231000600093Q0012310007000A3Q0012310008000B4Q00920004000800020006090004002E0001000100043F3Q002E000100120A000400073Q00208400040004000C0012310005000D3Q0012310006000D4Q00920004000600020010940003000600042Q0071000300044Q007100046Q004F00030002000100043F3Q0036000100043F3Q0005000100043F3Q0036000100043F3Q000200012Q00393Q00019Q003Q00034Q00718Q00663Q00024Q00393Q00017Q000B3Q00028Q0003043Q0054657874025Q00D08F40026Q00F03F030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00E06F40025Q00406A40025Q00805640025Q00E88F40001B3Q0012313Q00013Q00267B3Q000A0001000100043F3Q000A00012Q0071000100014Q007F00016Q0071000100024Q0071000200033Q0020840002000200030010940001000200020012313Q00043Q000E520004000100013Q00043F3Q000100012Q0071000100023Q00120A000200063Q002084000200020007001231000300083Q001231000400093Q0012310005000A4Q00920002000500020010940001000500022Q0071000100044Q0071000200033Q00208400020002000B2Q004F00010002000100043F3Q001A000100043F3Q000100012Q00393Q00017Q00243Q002Q033Q00466C79028Q0003073Q0044657374726F7903093Q00436861726163746572030E3Q0046696E6446697273744368696C64025Q0014904003063Q00506172656E74026Q00F03F03083Q00496E7374616E63652Q033Q006E6577025Q0024904003083Q004D6178466F72636503023Q005F47025Q002C9040023Q00C088C30042025Q0034904003043Q007A65726F03063Q00434672616D6503093Q0049734B6579446F776E03043Q00456E756D03073Q004B6579436F646503013Q0057030A3Q004C2Q6F6B566563746F7203013Q005303013Q0041030B3Q005269676874566563746F7203013Q004403053Q005370616365025Q008C9040030B3Q004C656674436F6E74726F6C025Q00A0904003083Q0056656C6F6369747903093Q004D61676E697475646503043Q00556E697403083Q00466C7953702Q6564025Q00B8904000A94Q00717Q0020845Q00010006093Q00160001000100043F3Q001600010012313Q00023Q00267B3Q00050001000200043F3Q000500012Q0071000100013Q00065C0001001400013Q00043F3Q00140001001231000100023Q00267B0001000B0001000200043F3Q000B00012Q0071000200013Q0020210002000200032Q004F0002000200012Q008D000200024Q007F000200013Q00043F3Q0014000100043F3Q000B00012Q00393Q00013Q00043F3Q000500012Q00713Q00023Q0020845Q000400065C3Q002000013Q00043F3Q002000012Q00713Q00023Q0020845Q00040020215Q00052Q0071000200033Q0020840002000200062Q00923Q000200020006093Q00230001000100043F3Q002300012Q00393Q00014Q0071000100013Q00065C0001002A00013Q00043F3Q002A00012Q0071000100013Q002084000100010007000609000100450001000100043F3Q00450001001231000100023Q00267B000100300001000800043F3Q003000012Q0071000200013Q001094000200073Q00043F3Q0045000100267B0001002B0001000200043F3Q002B000100120A000200093Q00208400020002000A2Q0071000300033Q00208400030003000B2Q006E0002000200022Q007F000200014Q0071000200013Q00120A0003000D4Q0071000400033Q00208400040004000E2Q003600030003000400208400030003000A0012310004000F3Q0012310005000F3Q0012310006000F4Q00920003000600020010940002000C0003001231000100083Q00043F3Q002B000100120A0001000D4Q0071000200033Q0020840002000200102Q00360001000100020020840001000100112Q0071000200043Q0020840002000200122Q0071000300053Q00202100030003001300120A000500143Q0020840005000500150020840005000500162Q009200030005000200065C0003005600013Q00043F3Q005600010020840003000200172Q00960001000100032Q0071000300053Q00202100030003001300120A000500143Q0020840005000500150020840005000500182Q009200030005000200065C0003006000013Q00043F3Q006000010020840003000200172Q00450001000100032Q0071000300053Q00202100030003001300120A000500143Q0020840005000500150020840005000500192Q009200030005000200065C0003006A00013Q00043F3Q006A000100208400030002001A2Q00450001000100032Q0071000300053Q00202100030003001300120A000500143Q00208400050005001500208400050005001B2Q009200030005000200065C0003007400013Q00043F3Q0074000100208400030002001A2Q00960001000100032Q0071000300053Q00202100030003001300120A000500143Q00208400050005001500208400050005001C2Q009200030005000200065C0003008600013Q00043F3Q0086000100120A0003000D4Q0071000400033Q00208400040004001D2Q003600030003000400208400030003000A001231000400023Q001231000500083Q001231000600024Q00920003000600022Q00960001000100032Q0071000300053Q00202100030003001300120A000500143Q00208400050005001500208400050005001E2Q009200030005000200065C0003009800013Q00043F3Q0098000100120A0003000D4Q0071000400033Q00208400040004001F2Q003600030003000400208400030003000A001231000400023Q001231000500083Q001231000600024Q00920003000600022Q00450001000100032Q0071000300013Q002084000400010021000E4B000200A20001000400043F3Q00A200010020840004000100222Q007100055Q0020840005000500232Q0067000400040005000609000400A70001000100043F3Q00A7000100120A0004000D4Q0071000500033Q0020840005000500242Q00360004000400050020840004000400110010940003002000042Q00393Q00017Q001F3Q00028Q00027Q004003073Q00476F644D6F646503063Q004865616C746803093Q004D61784865616C7468030A3Q00496E665374616D696E6103093Q0043686172616374657203063Q00697061697273030E3Q0047657444657363656E64616E747303063Q00737472696E6703053Q006C6F77657203043Q004E616D652Q033Q00497341025Q00FC9040025Q0004914003043Q0066696E64025Q000C9140025Q00149140025Q001C914003023Q005F47025Q00209140026Q00F03F03153Q0046696E6446697273744368696C644F66436C612Q73025Q0034914003053Q0053702Q656403093Q0057616C6B53702Q656403083Q0053702Q656456616C03043Q004A756D7003093Q004A756D70506F77657203073Q004A756D7056616C025Q0050914000993Q0012313Q00014Q008D000100013Q000E520002005A00013Q00043F3Q005A00012Q007100025Q00208400020002000300065C0002001100013Q00043F3Q00110001002084000200010004000E4B000100110001000200043F3Q00110001002084000200010004002084000300010005000682000200110001000300043F3Q001100010020840002000100050010940001000400022Q007100025Q00208400020002000600065C0002009800013Q00043F3Q009800012Q0071000200013Q00208400020002000700065C0002009800013Q00043F3Q0098000100120A000200084Q0071000300013Q0020840003000300070020210003000300092Q0003000300044Q006900023Q000400043F3Q00570001001231000700014Q008D000800083Q00267B000700220001000100043F3Q0022000100120A0009000A3Q00208400090009000B002084000A0006000C2Q006E0009000200022Q0010000800093Q00202100090006000D2Q0071000B00023Q002084000B000B000E2Q00920009000B0002000609000900350001000100043F3Q0035000100202100090006000D2Q0071000B00023Q002084000B000B000F2Q00920009000B000200065C0009005600013Q00043F3Q0056000100120A0009000A3Q0020840009000900102Q0010000A00084Q0071000B00023Q002084000B000B00112Q00920009000B00020006090009004D0001000100043F3Q004D000100120A0009000A3Q0020840009000900102Q0010000A00084Q0071000B00023Q002084000B000B00122Q00920009000B00020006090009004D0001000100043F3Q004D000100120A0009000A3Q0020840009000900102Q0010000A00084Q0071000B00023Q002084000B000B00132Q00920009000B000200065C0009005600013Q00043F3Q0056000100120A000900144Q0071000A00023Q002084000A000A00152Q003600090009000A00060F000A3Q000100012Q002F3Q00064Q004F00090002000100043F3Q0056000100043F3Q002200012Q008500055Q00066A000200200001000200043F3Q0020000100043F3Q00980001000E520001007300013Q00043F3Q00730001001231000200013Q00267B000200610001001600043F3Q006100010012313Q00163Q00043F3Q0073000100267B0002005D0001000100043F3Q005D00012Q0071000300013Q0020840003000300070006600001006E0001000300043F3Q006E00012Q0071000300013Q0020840003000300070020210003000300172Q0071000500023Q0020840005000500182Q00920003000500022Q0010000100033Q000609000100710001000100043F3Q007100012Q00393Q00013Q001231000200163Q00043F3Q005D000100267B3Q00020001001600043F3Q000200012Q007100025Q00208400020002001900065C0002007C00013Q00043F3Q007C00012Q007100025Q00208400020002001B0010940001001A00022Q007100025Q00208400020002001C00065C0002009600013Q00043F3Q00960001001231000200014Q008D000300033Q00267B000200820001000100043F3Q00820001001231000300013Q00267B000300850001000100043F3Q008500012Q007100045Q00208400040004001E0010940001001D000400120A000400144Q0071000500023Q00208400050005001F2Q003600040004000500060F00050001000100022Q002F3Q00014Q00808Q004F00040002000100043F3Q0096000100043F3Q0085000100043F3Q0096000100043F3Q008200010012313Q00023Q00043F3Q000200012Q00393Q00013Q00023Q00023Q0003053Q0056616C7565025Q00388F4000034Q00717Q0030233Q000100022Q00393Q00017Q00033Q00030A3Q004A756D7048656967687403073Q004A756D7056616C026Q001E4000064Q00718Q0071000100013Q0020840001000100020020400001000100030010943Q000100012Q00393Q00017Q00093Q0003073Q00496E664A756D70028Q0003093Q0043686172616374657203153Q0046696E6446697273744368696C644F66436C612Q73025Q00749140030B3Q004368616E6765537461746503043Q00456E756D03113Q0048756D616E6F696453746174655479706503073Q004A756D70696E67001D4Q00717Q0020845Q000100065C3Q001C00013Q00043F3Q001C00010012313Q00024Q008D000100013Q000E520002000600013Q00043F3Q000600012Q0071000200013Q002084000200020003000660000100130001000200043F3Q001300012Q0071000200013Q0020840002000200030020210002000200042Q0071000400023Q0020840004000400052Q00920002000400022Q0010000100023Q00065C0001001C00013Q00043F3Q001C000100202100020001000600120A000400073Q0020840004000400080020840004000400092Q008700020004000100043F3Q001C000100043F3Q000600012Q00393Q00017Q00063Q00028Q00026Q00F03F03093Q0048656172746265617403073Q00436F2Q6E65637403073Q00416E746941464B030A3Q00446973636F2Q6E65637401213Q001231000100013Q00267B0001000D0001000200043F3Q000D000100065C3Q002000013Q00043F3Q002000012Q0071000200013Q00208400020002000300202100020002000400060F00043Q000100012Q00803Q00024Q00920002000400022Q007F00025Q00043F3Q0020000100267B000100010001000100043F3Q000100012Q0071000200033Q001094000200054Q007100025Q00065C0002001E00013Q00043F3Q001E0001001231000200013Q00267B000200150001000100043F3Q001500012Q007100035Q0020210003000300062Q004F0003000200012Q008D000300034Q007F00035Q00043F3Q001E000100043F3Q00150001001231000100023Q00043F3Q000100012Q00393Q00013Q00013Q00023Q0003023Q005F47025Q008C914000083Q00120A3Q00014Q007100015Q0020840001000100022Q00365Q000100060F00013Q000100012Q00808Q004F3Q000200012Q00393Q00013Q00013Q00093Q00028Q00026Q00F03F030C3Q00436C69636B42752Q746F6E3203073Q00566563746F72322Q033Q006E657703043Q0067616D65030A3Q0047657453657276696365025Q009C914003113Q0043617074757265436F6E74726F2Q6C657200173Q0012313Q00014Q008D000100013Q00267B3Q000A0001000200043F3Q000A000100202100020001000300120A000400043Q0020840004000400052Q0024000400014Q006200023Q000100043F3Q0016000100267B3Q00020001000100043F3Q0002000100120A000200063Q0020210002000200072Q007100045Q0020840004000400082Q00920002000400022Q0010000100023Q0020210002000100092Q004F0002000200010012313Q00023Q00043F3Q000200012Q00393Q00017Q00133Q00028Q0003043Q005852617903063Q00697061697273030E3Q0047657444657363656E64616E74732Q033Q00497341025Q00B89140030E3Q00497344657363656E64616E744F6603093Q00436861726163746572030C3Q00476574412Q74726962757465025Q00C8914000030C3Q00536574412Q74726962757465025Q00D0914003193Q004C6F63616C5472616E73706172656E63794D6F646966696572030C3Q005472616E73706172656E6379026Q00E03F029A5Q99E13F025Q00E49140025Q00F09140014B3Q001231000100013Q00267B000100010001000100043F3Q000100012Q007100025Q001094000200023Q00120A000200034Q0071000300013Q0020210003000300042Q0003000300044Q006900023Q000400043F3Q004600010020210007000600052Q0071000900023Q0020840009000900062Q009200070009000200065C0007004600013Q00043F3Q004600010020210007000600072Q0071000900033Q0020840009000900082Q0092000700090002000609000700460001000100043F3Q0046000100065C3Q002E00013Q00043F3Q002E0001001231000700013Q00267B0007001A0001000100043F3Q001A00010020210008000600092Q0071000A00023Q002084000A000A000A2Q00920008000A000200267B000800270001000B00043F3Q0027000100202100080006000C2Q0071000A00023Q002084000A000A000D002084000B0006000E2Q00870008000B000100208400080006000F002602000800460001001000043F3Q004600010030230006000E001100043F3Q0046000100043F3Q001A000100043F3Q00460001001231000700014Q008D000800083Q00267B000700300001000100043F3Q003000010020210009000600092Q0071000B00023Q002084000B000B00122Q00920009000B00022Q0010000800093Q002653000800460001000B00043F3Q00460001001231000900013Q00267B0009003A0001000100043F3Q003A00010010940006000E0008002021000A0006000C2Q0071000C00023Q002084000C000C00132Q008D000D000D4Q0087000A000D000100043F3Q0046000100043F3Q003A000100043F3Q0046000100043F3Q0030000100066A0002000B0001000200043F3Q000B000100043F3Q004A000100043F3Q000100012Q00393Q00017Q000A3Q00028Q00030A3Q0046752Q6C627269676874030A3Q004272696768746E652Q7303093Q00436C6F636B54696D65027Q0040026Q00F03F026Q002C40030D3Q00476C6F62616C536861646F777301003Q013B3Q001231000100013Q00267B000100010001000100043F3Q000100012Q007100025Q001094000200023Q00065C3Q002200013Q00043F3Q00220001001231000200014Q008D000300033Q00267B000200090001000100043F3Q00090001001231000300013Q00267B000300170001000100043F3Q001700012Q0071000400033Q0020840004000400032Q0071000500033Q0020840005000500042Q007F000500024Q007F000400014Q0071000400033Q003023000400030005001231000300063Q000E520006000C0001000300043F3Q000C00012Q0071000400033Q0030230004000400072Q0071000400033Q00302300040008000900043F3Q003A000100043F3Q000C000100043F3Q003A000100043F3Q0009000100043F3Q003A0001001231000200013Q00267B000200280001000600043F3Q002800012Q0071000300033Q00302300030008000A00043F3Q003A000100267B000200230001000100043F3Q002300012Q0071000300034Q0071000400013Q0006090004002F0001000100043F3Q002F0001001231000400063Q0010940003000300042Q0071000300034Q0071000400023Q000609000400350001000100043F3Q00350001001231000400073Q001094000300040004001231000200063Q00043F3Q0023000100043F3Q003A000100043F3Q000100012Q00393Q00017Q00053Q00028Q0003053Q004E6F466F6703063Q00466F67456E64024Q0080842E41025Q006AF84001213Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q00020001001231000200013Q00267B000200050001000100043F3Q000500012Q007100035Q001094000300023Q00065C3Q001600013Q00043F3Q00160001001231000300013Q00267B0003000C0001000100043F3Q000C00012Q0071000400023Q0020840004000400032Q007F000400014Q0071000400023Q00302300040003000400043F3Q0020000100043F3Q000C000100043F3Q002000012Q0071000300024Q0071000400013Q0006090004001B0001000100043F3Q001B0001001231000400053Q00109400030003000400043F3Q0020000100043F3Q0005000100043F3Q0020000100043F3Q000200012Q00393Q00017Q00083Q00028Q00026Q00F03F03053Q00706169727303063Q00747970656F66025Q0028924003063Q00506172656E7403073Q0044657374726F790001233Q001231000100014Q008D000200023Q000E52000200190001000100043F3Q0019000100120A000300034Q0010000400024Q001E00030002000500043F3Q0014000100120A000800044Q0010000900074Q006E0008000200022Q007100095Q00208400090009000500060B000800140001000900043F3Q0014000100208400080007000600065C0008001400013Q00043F3Q001400010020210008000700072Q004F00080002000100066A000300080001000200043F3Q000800012Q0071000300013Q00206C00033Q000800043F3Q0022000100267B000100020001000100043F3Q000200012Q0071000300014Q0036000200033Q000609000200200001000100043F3Q002000012Q00393Q00013Q001231000100023Q00043F3Q000200012Q00393Q00017Q00013Q0003053Q007061697273000A3Q00120A3Q00014Q007100016Q001E3Q0002000200043F3Q000700012Q0071000400014Q0010000500034Q004F00040002000100066A3Q00040001000100043F3Q000400012Q00393Q00017Q000D3Q00028Q00026Q00F03F027Q0040026Q000840030E3Q0046696E6446697273744368696C64025Q0038924003063Q00697061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q0044924003043Q004E616D6503093Q00436861726163746572025Q005C9240016A3Q001231000100014Q008D000200063Q00267B000100070001000100043F3Q00070001001231000200014Q008D000300033Q001231000100023Q00267B0001000B0001000200043F3Q000B00012Q008D000400053Q001231000100033Q000E52000300020001000100043F3Q000200012Q008D000600063Q001231000700013Q00267B000700250001000200043F3Q0025000100267B000200140001000400043F3Q001400012Q0066000300023Q00267B0002000E0001000100043F3Q000E0001001231000800013Q00267B0008001B0001000200043F3Q001B0001001231000200023Q00043F3Q000E000100267B000800170001000100043F3Q001700012Q003A00096Q003A000A6Q00100004000A4Q0010000300094Q008D000500053Q001231000800023Q00043F3Q0017000100043F3Q000E000100267B0007000F0001000100043F3Q000F000100267B000200490001000300043F3Q00490001001231000800013Q00267B0008002E0001000200043F3Q002E0001001231000200043Q00043F3Q0049000100267B0008002A0001000100043F3Q002A000100202100093Q00052Q0071000B5Q002084000B000B00062Q00920009000B00022Q0010000600093Q00065C0006004700013Q00043F3Q0047000100120A000900073Q002021000A000600082Q0003000A000B4Q006900093Q000B00043F3Q00450001002021000E000D00092Q007100105Q00208400100010000A2Q0092000E0010000200065C000E004500013Q00043F3Q004500012Q0010000E00053Q002084000F000D000B2Q004F000E0002000100066A0009003C0001000200043F3Q003C0001001231000800023Q00043F3Q002A000100267B000200640001000200043F3Q0064000100060F00053Q000100032Q00803Q00014Q002F3Q00044Q002F3Q00033Q00208400083Q000C00065C0008006300013Q00043F3Q0063000100120A000800073Q00208400093Q000C0020210009000900082Q00030009000A4Q006900083Q000A00043F3Q00610001002021000D000C00092Q0071000F5Q002084000F000F000D2Q0092000D000F000200065C000D006100013Q00043F3Q006100012Q0010000D00053Q002084000E000C000B2Q004F000D0002000100066A000800580001000200043F3Q00580001001231000200033Q001231000700023Q00043F3Q000F000100043F3Q000E000100043F3Q0069000100043F3Q000200012Q00393Q00013Q00013Q00033Q00028Q002Q01026Q00F03F011E3Q00065C3Q001D00013Q00043F3Q001D00012Q007100016Q001000026Q006E00010002000200065C0001001D00013Q00043F3Q001D00012Q0071000100014Q0036000100013Q0006090001001D0001000100043F3Q001D0001001231000100014Q008D000200023Q00267B0001000D0001000100043F3Q000D0001001231000200013Q00267B000200100001000100043F3Q001000012Q0071000300013Q00206C00033Q00022Q0071000300024Q0071000400024Q001C000400043Q00208B0004000400032Q003E000300043Q00043F3Q001D000100043F3Q0010000100043F3Q001D000100043F3Q000D00012Q00393Q00017Q00633Q0003093Q00436861726163746572028Q0003063Q0055736572496403153Q0046696E6446697273744368696C644F66436C612Q73025Q00709240030E3Q0046696E6446697273744368696C64025Q0080924003083Q00506F736974696F6E03093Q004D61676E69747564652Q033Q0045535003073Q004553504469737403063Q004865616C7468025Q00B4924003023Q00484C03023Q00686C03063Q00506172656E74027Q0040030C3Q004F75746C696E65436F6C6F7203083Q00455350436F6C6F7203133Q004F75746C696E655472616E73706172656E6379029A5Q99C93F026Q000840026Q00F03F03093Q0046692Q6C436F6C6F7203103Q0046692Q6C5472616E73706172656E6379023D0AD7A3703DEA3F03083Q00496E7374616E63652Q033Q006E6577025Q00E4924003073Q0041646F726E2Q6503093Q0044657074684D6F646503043Q00456E756D03123Q00486967686C6967687444657074684D6F6465030B3Q00416C776179734F6E546F70026Q00104003073Q0044657374726F790003043Q004E616D6503043Q004469737403023Q006C6203043Q0054657874030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00C06740025Q00806B40025Q00E06F40026Q005E4003043Q00696E666F03163Q00546578745374726F6B655472616E73706172656E6379026Q00E03F03043Q00466F6E74030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q002040030B3Q0053747564734F2Q6673657403023Q005F47025Q007C9340026Q66FE3F2Q01025Q0090934003043Q0053697A6503053Q005544696D3203093Q0066726F6D5363616C6503163Q004261636B67726F756E645472616E73706172656E6379025Q00A49340030A3Q0066726F6D4F2Q66736574025Q00805140026Q002840034Q00030B3Q00446973706C61794E616D65025Q00CC934003013Q002003043Q006D61746803053Q00666C2Q6F7203013Q006D03043Q00542Q6F6C2Q033Q006D696E026Q00144003043Q00662Q6574025Q00149440029A5Q99E13F03083Q00662Q65744C69737403103Q004261636B67726F756E64436F6C6F7233026Q001840026Q002440026Q003440025Q00806140030B3Q00546578745772612Q706564025Q00549440026Q005040025Q00689440027Q00C003053Q007461626C6503063Q00636F6E63617403013Q000A026Q001C4003073Q00456E61626C65640100014E022Q00208400013Q0001000609000100150001000100043F3Q00150001001231000200024Q008D000300033Q000E52000200050001000200043F3Q00050001001231000300023Q00267B000300080001000200043F3Q00080001001231000400023Q000E520002000B0001000400043F3Q000B00012Q007100055Q00208400063Q00032Q004F0005000200012Q00393Q00013Q00043F3Q000B000100043F3Q0008000100043F3Q0015000100043F3Q000500010020210002000100042Q0071000400013Q0020840004000400052Q00920002000400022Q0071000300024Q0010000400014Q006E0003000200022Q0071000400033Q00208400040004000100065C0004002600013Q00043F3Q002600012Q0071000400033Q0020840004000400010020210004000400062Q0071000600013Q0020840006000600072Q009200040006000200065C0003002A00013Q00043F3Q002A0001000609000400320001000100043F3Q00320001001231000500023Q00267B0005002B0001000200043F3Q002B00012Q007100065Q00208400073Q00032Q004F0006000200012Q00393Q00013Q00043F3Q002B00010020840005000300080020840006000400082Q00450005000500060020840005000500092Q0071000600043Q00208400060006000A00065C0006003E00013Q00043F3Q003E00012Q0071000600043Q00208400060006000B000682000600460001000500043F3Q00460001001231000600023Q00267B0006003F0001000200043F3Q003F00012Q007100075Q00208400083Q00032Q004F0007000200012Q00393Q00013Q00043F3Q003F00012Q0071000600053Q00208400073Q00032Q0071000800053Q00208400093Q00032Q00360008000800090006090008004E0001000100043F3Q004E00012Q003A00086Q003E0006000700082Q0071000600053Q00208400073Q00032Q0036000600060007000660000700590001000200043F3Q0059000100208400070002000C000E93000200580001000700043F3Q005800012Q000500076Q007A000700013Q0020210008000100062Q0071000A00013Q002084000A000A000D2Q00920008000A0002000609000800600001000100043F3Q006000012Q0010000800034Q0071000900043Q00208400090009000E00065C000900B500013Q00043F3Q00B5000100208400090006000F00065C0009006B00013Q00043F3Q006B000100208400090006000F0020840009000900100006090009009C0001000100043F3Q009C0001001231000900024Q008D000A000A3Q000E52001100740001000900043F3Q007400012Q0071000B00043Q002084000B000B0013001094000A0012000B003023000A00140015001231000900163Q00267B0009007B0001001700043F3Q007B00012Q0071000B00043Q002084000B000B0013001094000A0018000B003023000A0019001A001231000900113Q00267B0009008D0001000200043F3Q008D0001001231000B00023Q00267B000B00820001001700043F3Q00820001001231000900173Q00043F3Q008D0001000E520002007E0001000B00043F3Q007E000100120A000C001B3Q002084000C000C001C2Q0071000D00013Q002084000D000D001D2Q006E000C000200022Q0010000A000C3Q001094000A001E0001001231000B00173Q00043F3Q007E000100267B000900960001001600043F3Q0096000100120A000B00203Q002084000B000B0021002084000B000B0022001094000A001F000B2Q0071000B00063Q001094000A0010000B001231000900233Q00267B0009006D0001002300043F3Q006D00010010940006000F000A00043F3Q00C7000100043F3Q006D000100043F3Q00C70001001231000900024Q008D000A000A3Q00267B0009009E0001000200043F3Q009E0001001231000A00023Q000E52001700A60001000A00043F3Q00A60001002084000B0006000F001094000B001E000100043F3Q00C7000100267B000A00A10001000200043F3Q00A10001002084000B0006000F2Q0071000C00043Q002084000C000C0013001094000B0018000C002084000B0006000F2Q0071000C00043Q002084000C000C0013001094000B0012000C001231000A00173Q00043F3Q00A1000100043F3Q00C7000100043F3Q009E000100043F3Q00C7000100208400090006000F00065C000900C700013Q00043F3Q00C70001001231000900024Q008D000A000A3Q00267B000900BA0001000200043F3Q00BA0001001231000A00023Q00267B000A00BD0001000200043F3Q00BD0001002084000B0006000F002021000B000B00242Q004F000B000200010030230006000F002500043F3Q00C7000100043F3Q00BD000100043F3Q00C7000100043F3Q00BA000100065C0008008C2Q013Q00043F3Q008C2Q012Q0071000900043Q002084000900090026000609000900D10001000100043F3Q00D100012Q0071000900043Q00208400090009002700065C0009008C2Q013Q00043F3Q008C2Q01001231000900024Q008D000A000A3Q00267B000900EA0001001100043F3Q00EA0001002084000B00060028001094000B0029000A002084000B0006002800065C000700E200013Q00043F3Q00E2000100120A000C002B3Q002084000C000C002C001231000D002D3Q001231000E002E3Q001231000F002F4Q0092000C000F0002000609000C00E80001000100043F3Q00E8000100120A000C002B3Q002084000C000C002C001231000D002F3Q001231000E00303Q001231000F00304Q0092000C000F0002001094000B002A000C00043F3Q00A02Q01000E520002005A2Q01000900043F3Q005A2Q01002084000B0006003100065C000B00F300013Q00043F3Q00F30001002084000B00060031002084000B000B0010000609000B00582Q01000100043F3Q00582Q01001231000B00024Q008D000C000E3Q00267B000B00522Q01001700043F3Q00522Q012Q008D000E000E3Q00267B000C00FE0001002300043F3Q00FE00012Q0010000F000D3Q00109400060028000E00109400060031000F00043F3Q00582Q01000E520016000F2Q01000C00043F3Q000F2Q01001231000F00023Q00267B000F00062Q01001700043F3Q00062Q01003023000E00320033001231000C00233Q00043F3Q000F2Q0100267B000F003Q01000200043F3Q003Q0100120A001000203Q002084001000100034002084001000100035001094000E00340010003023000E00360037001231000F00173Q00043F3Q003Q0100267B000C00272Q01001700043F3Q00272Q01001231000F00023Q00267B000F00202Q01000200043F3Q00202Q0100120A001000394Q0071001100013Q00208400110011003A2Q003600100010001100208400100010001C001231001100023Q0012310012003B3Q001231001300024Q0092001000130002001094000D00380010003023000D0022003C001231000F00173Q000E52001700122Q01000F00043F3Q00122Q012Q0071001000063Q001094000D00100010001231000C00113Q00043F3Q00272Q0100043F3Q00122Q01000E52001100402Q01000C00043F3Q00402Q01001231000F00023Q000E520002003A2Q01000F00043F3Q003A2Q0100120A0010001B3Q00208400100010001C2Q0071001100013Q00208400110011003D2Q00100012000D4Q00920010001200022Q0010000E00103Q00120A0010003F3Q002084001000100040001231001100173Q001231001200174Q0092001000120002001094000E003E0010001231000F00173Q00267B000F002A2Q01001700043F3Q002A2Q01003023000E00410017001231000C00163Q00043F3Q00402Q0100043F3Q002A2Q0100267B000C00F80001000200043F3Q00F8000100120A000F001B3Q002084000F000F001C2Q0071001000013Q0020840010001000422Q006E000F000200022Q0010000D000F3Q001094000D001E000800120A000F003F3Q002084000F000F0043001231001000443Q001231001100454Q0092000F00110002001094000D003E000F001231000C00173Q00043F3Q00F8000100043F3Q00582Q0100267B000B00F50001000200043F3Q00F50001001231000C00024Q008D000D000D3Q001231000B00173Q00043F3Q00F50001001231000A00463Q001231000900173Q00267B000900D30001001700043F3Q00D300012Q0071000B00043Q002084000B000B002600065C000B00782Q013Q00043F3Q00782Q01001231000B00024Q008D000C000C3Q00267B000B00622Q01000200043F3Q00622Q01001231000C00023Q00267B000C00652Q01000200043F3Q00652Q01002084000D3Q0047002653000D006D2Q01004600043F3Q006D2Q01002084000D3Q0047000677000A006E2Q01000D00043F3Q006E2Q01002084000A3Q0026000609000700782Q01000100043F3Q00782Q012Q0010000D000A4Q0071000E00013Q002084000E000E00482Q0088000A000D000E00043F3Q00782Q0100043F3Q00652Q0100043F3Q00782Q0100043F3Q00622Q012Q0071000B00043Q002084000B000B002700065C000B00892Q013Q00043F3Q00892Q012Q0010000B000A3Q002653000A00822Q01004600043F3Q00822Q01001231000C00493Q000609000C00832Q01000100043F3Q00832Q01001231000C00463Q00120A000D004A3Q002084000D000D004B2Q0010000E00054Q006E000D00020002001231000E004C4Q0088000A000B000E001231000900113Q00043F3Q00D3000100043F3Q00A02Q0100208400090006003100065C000900A02Q013Q00043F3Q00A02Q01001231000900024Q008D000A000A3Q000E52000200912Q01000900043F3Q00912Q01001231000A00023Q000E52000200942Q01000A00043F3Q00942Q01002084000B00060031002021000B000B00242Q004F000B000200012Q008D000B000B3Q00302300060028002500109400060031000B00043F3Q00A02Q0100043F3Q00942Q0100043F3Q00A02Q0100043F3Q00912Q012Q0071000900043Q00208400090009004D00065C0009003902013Q00043F3Q0039020100065C0007003902013Q00043F3Q003902012Q0071000900074Q0010000A6Q006E0009000200022Q003A000A5Q001231000B00173Q00120A000C004A3Q002084000C000C004E001231000D004F4Q001C000E00094Q0092000C000E0002001231000D00173Q000498000B00B72Q012Q001C000F000A3Q00208B000F000F00172Q003600100009000E2Q003E000A000F001000048C000B00B22Q01002084000B0006005000065C000B00BE2Q013Q00043F3Q00BE2Q01002084000B00060050002084000B000B0010000609000B00160201000100043F3Q00160201001231000B00024Q008D000C000D3Q00267B000B00D12Q01001100043F3Q00D12Q0100120A000E001B3Q002084000E000E001C2Q0071000F00013Q002084000F000F00512Q00100010000C4Q0092000E001000022Q0010000D000E3Q00120A000E003F3Q002084000E000E0040001231000F00173Q001231001000174Q0092000E00100002001094000D003E000E003023000D00410052001231000B00163Q00267B000B00D72Q01004F00043F3Q00D72Q012Q0010000E000C3Q00109400060053000D00109400060050000E00043F3Q0016020100267B000B00EC2Q01001600043F3Q00EC2Q0100120A000E002B3Q002084000E000E002C001231000F00553Q001231001000563Q001231001100574Q0092000E00110002001094000D0054000E00120A000E002B3Q002084000E000E002C001231000F00583Q0012310010002D3Q0012310011002F4Q0092000E00110002001094000D002A000E00120A000E00203Q002084000E000E0034002084000E000E0035001094000D0034000E001231000B00233Q000E52002300F52Q01000B00043F3Q00F52Q01003023000D00360055003023000D0059003C2Q0071000E00084Q0010000F000D3Q001231001000164Q0087000E00100001001231000B004F3Q00267B000B00050201000200043F3Q0005020100120A000E001B3Q002084000E000E001C2Q0071000F00013Q002084000F000F005A2Q006E000E000200022Q0010000C000E3Q001094000C001E000300120A000E003F3Q002084000E000E0043001231000F005B3Q001231001000574Q0092000E00100002001094000C003E000E001231000B00173Q00267B000B00C02Q01001700043F3Q00C02Q0100120A000E00394Q0071000F00013Q002084000F000F005C2Q0036000E000E000F002084000E000E001C001231000F00023Q0012310010005D3Q001231001100024Q0092000E00110002001094000C0038000E003023000C0022003C2Q0071000E00063Q001094000C0010000E001231000B00113Q00043F3Q00C02Q012Q001C000B000A3Q000E4B000200340201000B00043F3Q00340201001231000B00023Q00267B000B002D0201000200043F3Q002D0201002084000C0006005300120A000D005E3Q002084000D000D005F2Q0010000E000A3Q001231000F00604Q0092000D000F0002001094000C0029000D002084000C0006005000120A000D003F3Q002084000D000D0043001231000E005B4Q001C000F000A3Q00202E000F000F0061001017000F004F000F2Q0092000D000F0002001094000C003E000D001231000B00173Q00267B000B001A0201001700043F3Q001A0201002084000C00060050003023000C0062003C00043F3Q0036020100043F3Q001A020100043F3Q00360201002084000B00060050003023000B00620063002084000B00060050001094000B001E000300043F3Q004D020100208400090006005000065C0009004D02013Q00043F3Q004D0201001231000900024Q008D000A000A3Q00267B0009003E0201000200043F3Q003E0201001231000A00023Q00267B000A00410201000200043F3Q00410201002084000B00060050002021000B000B00242Q004F000B000200012Q008D000B000B3Q00302300060053002500109400060050000B00043F3Q004D020100043F3Q0041020100043F3Q004D020100043F3Q003E02012Q00393Q00017Q00183Q00028Q00027Q004003093Q00436861726163746572025Q00C49440026Q00084003083Q00506F736974696F6E03023Q005F47025Q00D094402Q033Q006E6577025Q00D8944003043Q004E616D65025Q00E09440034Q0003043Q0067737562025Q00EC9440025Q00F89440025Q00049540026Q00F03F03063Q00737472696E6703053Q006C6F77657203063Q00697061697273030A3Q00476574506C6179657273030B3Q00446973706C61794E616D6503043Q0066696E64019F3Q001231000100014Q008D000200043Q000E52000200210001000100043F3Q0021000100065C0003000900013Q00043F3Q000900010020840005000300030006090005001C0001000100043F3Q001C0001001231000500014Q008D000600063Q000E520001000B0001000500043F3Q000B0001001231000600013Q00267B0006000E0001000100043F3Q000E0001001231000700013Q00267B000700110001000100043F3Q001100012Q007100086Q0071000900013Q0020840009000900042Q004F0008000200012Q00393Q00013Q00043F3Q0011000100043F3Q000E000100043F3Q001C000100043F3Q000B00012Q0071000500023Q0020840006000300032Q006E0005000200022Q0010000400053Q001231000100053Q00267B0001003E0001000500043F3Q003E000100065C0004009E00013Q00043F3Q009E0001001231000500013Q00267B000500260001000100043F3Q002600012Q0071000600033Q00208400070004000600120A000800074Q0071000900013Q0020840009000900082Q0036000800080009002084000800080009001231000900013Q001231000A00053Q001231000B00014Q00920008000B00022Q00960007000700082Q004F0006000200012Q007100066Q0071000700013Q00208400070007000A00208400080003000B2Q00880007000700082Q004F00060002000100043F3Q009E000100043F3Q0026000100043F3Q009E0001000E52000100690001000100043F3Q0069000100120A000500074Q0071000600013Q00208400060006000C2Q00360005000500060006770006004700013Q00043F3Q004700010012310006000D4Q006E00050002000200202100050005000E2Q0071000700013Q00208400070007000F0012310008000D4Q009200050008000200202100050005000E2Q0071000700013Q0020840007000700100012310008000D4Q00920005000800022Q00103Q00053Q00267B3Q00680001000D00043F3Q00680001001231000500014Q008D000600063Q00267B000500570001000100043F3Q00570001001231000600013Q00267B0006005A0001000100043F3Q005A0001001231000700013Q00267B0007005D0001000100043F3Q005D00012Q007100086Q0071000900013Q0020840009000900112Q004F0008000200012Q00393Q00013Q00043F3Q005D000100043F3Q005A000100043F3Q0068000100043F3Q00570001001231000100123Q00267B000100020001001200043F3Q0002000100120A000500133Q0020840005000500142Q001000066Q006E0005000200022Q008D000300034Q0010000200053Q00120A000500154Q0071000600043Q0020210006000600162Q0003000600074Q006900053Q000700043F3Q009A00012Q0071000A00053Q0006040009009A0001000A00043F3Q009A000100120A000A00133Q002084000A000A0014002084000B0009000B2Q006E000A0002000200120A000B00133Q002084000B000B0014002084000C000900172Q006E000B00020002000604000A00980001000200043F3Q00980001000604000B00980001000200043F3Q0098000100120A000C00133Q002084000C000C00182Q0010000D000A4Q0010000E00023Q001231000F00124Q007A001000014Q0092000C00100002000609000C00980001000100043F3Q0098000100120A000C00133Q002084000C000C00182Q0010000D000B4Q0010000E00023Q001231000F00124Q007A001000014Q0092000C0010000200065C000C009A00013Q00043F3Q009A00012Q0010000300093Q00043F3Q009C000100066A000500770001000200043F3Q00770001001231000100023Q00043F3Q000200012Q00393Q00017Q00113Q00028Q0003063Q0054504B692Q6C03023Q005F47025Q002C9540026Q003440025Q00309540030C3Q004B692Q6C432Q6F6C646F776E025Q00389540026Q00F03F03083Q00506F736974696F6E025Q004095402Q033Q006E6577026Q000440027Q004003043Q007461736B03053Q0064656C617902CD5QCCDC3F02523Q001231000200014Q008D000300033Q00267B000200300001000100043F3Q003000012Q007100045Q00208400040004000200065C0004001F00013Q00043F3Q001F00012Q0071000400013Q00060B3Q001F0001000400043F3Q001F000100120A000400034Q0071000500023Q0020840005000500042Q00360004000400052Q004E0004000100022Q0071000500034Q0045000400040005000E930005001F0001000400043F3Q001F000100120A000400034Q0071000500023Q0020840005000500062Q00360004000400052Q004E0004000100022Q0071000500044Q00450004000400052Q007100055Q002084000500050007000682000400290001000500043F3Q00290001001231000400013Q00267B000400200001000100043F3Q002000012Q0071000500013Q00060B3Q00270001000500043F3Q002700012Q008D000500054Q007F000500014Q00393Q00013Q00043F3Q0020000100120A000400034Q0071000500023Q0020840005000500082Q00360004000400052Q004E0004000100022Q007F000400043Q001231000200093Q00267B000200460001000900043F3Q004600012Q0071000400054Q0010000500014Q006E0004000200022Q0010000300043Q00065C0003004500013Q00043F3Q004500012Q0071000400063Q00208400050003000A00120A000600034Q0071000700023Q00208400070007000B2Q003600060006000700208400060006000C001231000700013Q0012310008000D3Q001231000900014Q00920006000900022Q00960005000500062Q004F0004000200010012310002000E3Q00267B000200020001000E00043F3Q0002000100120A0004000F3Q002084000400040010001231000500114Q0071000600074Q00870004000600012Q008D000400044Q007F000400013Q00043F3Q0051000100043F3Q000200012Q00393Q00017Q00053Q00028Q00026Q00F03F03093Q00436861726163746572030E3Q00436861726163746572412Q64656403073Q00436F2Q6E65637401213Q001231000100014Q008D000200023Q000E520002000F0001000100043F3Q000F000100208400033Q000300065C0003000A00013Q00043F3Q000A00012Q0010000300023Q00208400043Q00032Q004F00030002000100208400033Q00040020210003000300052Q0010000500024Q008700030005000100043F3Q0020000100267B000100020001000100043F3Q00020001001231000300013Q00267B0003001A0001000100043F3Q001A00012Q008D000200023Q00060F00023Q000100032Q00808Q00803Q00014Q002F7Q001231000300023Q00267B000300120001000200043F3Q00120001001231000100023Q00043F3Q0002000100043F3Q0012000100043F3Q000200012Q00393Q00013Q00013Q00053Q00030C3Q0057616974466F724368696C64025Q00609540026Q00144003043Q004469656403073Q00436F2Q6E656374010F3Q00202100013Q00012Q007100035Q002084000300030002001231000400034Q009200010004000200065C0001000E00013Q00043F3Q000E000100208400020001000400202100020002000500060F00043Q000100032Q00803Q00014Q00803Q00024Q002F8Q00870002000400012Q00393Q00013Q00018Q00054Q00718Q0071000100014Q0071000200024Q00873Q000200012Q00393Q00019Q002Q0001074Q007100015Q0006043Q00060001000100043F3Q000600012Q0071000100014Q001000026Q004F0001000200012Q00393Q00017Q00073Q00028Q00026Q00F03F03053Q0070616972730003063Q00697061697273030B3Q004765744368696C6472656E03073Q0044657374726F7900233Q0012313Q00013Q000E520002000C00013Q00043F3Q000C000100120A000100034Q007100026Q001E00010002000300043F3Q000900012Q007100055Q00206C00050004000400066A000100070001000100043F3Q0007000100043F3Q0022000100267B3Q00010001000100043F3Q0001000100120A000100054Q0071000200013Q0020210002000200062Q0003000200034Q006900013Q000300043F3Q001600010020210006000500072Q004F00060002000100066A000100140001000200043F3Q0014000100120A000100034Q0071000200024Q001E00010002000300043F3Q001E00012Q0071000500023Q00206C00050004000400066A0001001C0001000100043F3Q001C00010012313Q00023Q00043F3Q000100012Q00393Q00017Q005D3Q0003053Q007061697273028Q0003103Q004261636B67726F756E64436F6C6F723303023Q00416303043Q0043617264030A3Q0054657874436F6C6F723303063Q00436F6C6F72332Q033Q006E6577026Q00F03F2Q033Q0044696D027Q0040025Q00989540025Q009C9540025Q00A0954003063Q0041696D626F74026Q001040025Q00AC954003043Q006D61746803053Q00666C2Q6F7203063Q00536D2Q6F7468026Q005940026Q000840026Q004440025Q00BC954003063Q0054504B692Q6C025Q00C8954003073Q0053686F77464F56025Q00D895402Q033Q00464F56025Q00207C40025Q00EC9540025Q00F09540025Q00F89540025Q00FC9540025Q00049640025Q00089640025Q0010964003083Q004175726144697374026Q001440026Q005440025Q001C9640025Q0020964003023Q00484C025Q002C964003043Q004E616D65025Q0038964003043Q0044697374025Q004496402Q033Q00455350025Q0050964003073Q0045535044697374026Q004940025Q00409F40025Q005C964003043Q00542Q6F6C025Q0068964003043Q0058526179025Q00709640030A3Q0046752Q6C627269676874025Q0078964003053Q004E6F466F67025Q0080964003073Q00416E746941464B025Q00889640025Q008C964003083Q0053702Q656456616C026Q003040026Q005E40025Q0098964003043Q004A756D70025Q00A49640030A3Q00496E665374616D696E61025Q00B0964003073Q00476F644D6F6465025Q00BC964003083Q00466C7953702Q6564026Q003440025Q00407F40025Q00C8964003053Q0053702Q6564025Q00D4964003073Q004A756D7056616C026Q006940025Q00E0964003073Q00496E664A756D70025Q00EC9640025Q00F09640025Q00F49640025Q00F89640030A3Q004E6F6D6520702F205450026Q009740025Q001C9740025Q0064974001FD013Q007100016Q001900010001000100120A000100014Q0071000200014Q001E00010002000300043F3Q00270001001231000600024Q008D000700073Q00267B000600080001000200043F3Q00080001001231000700023Q00267B0007000B0001000200043F3Q000B000100060B0004001300013Q00043F3Q001300012Q0071000800023Q002084000800080004000609000800150001000100043F3Q001500012Q0071000800023Q00208400080008000500109400050003000800060B0004002000013Q00043F3Q0020000100120A000800073Q002084000800080008001231000900093Q001231000A00093Q001231000B00094Q00920008000B0002000609000800220001000100043F3Q002200012Q0071000800023Q00208400080008000A00109400050006000800043F3Q0027000100043F3Q000B000100043F3Q0027000100043F3Q0008000100066A000100060001000200043F3Q000600010012310001000B4Q0071000200033Q00208400020002000C00060B3Q00B60001000200043F3Q00B60001001231000200023Q000E52000200440001000200043F3Q004400012Q0071000300044Q0071000400054Q0071000500033Q00208400050005000D2Q0010000600014Q00920003000600022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005000E2Q0010000600014Q0071000700073Q00208400070007000F00060F00083Q000100012Q00803Q00074Q00920003000800022Q0010000100033Q001231000200093Q000E52001000630001000200043F3Q006300012Q0071000300084Q0071000400054Q0071000500033Q0020840005000500112Q0010000600013Q00120A000700123Q0020840007000700132Q0071000800073Q00208400080008001400202E0008000800152Q006E000700020002001231000800163Q001231000900173Q00060F000A0001000100012Q00803Q00074Q00920003000A00022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q0020840005000500182Q0010000600014Q0071000700073Q00208400070007001900060F00080002000100012Q00803Q00074Q00920003000800022Q0010000100033Q00043F3Q00FC2Q0100267B000200800001001600043F3Q008000012Q0071000300064Q0071000400054Q0071000500033Q00208400050005001A2Q0010000600014Q0071000700073Q00208400070007001B00060F00080003000100022Q00803Q00074Q00803Q00094Q00920003000800022Q0010000100034Q0071000300084Q0071000400054Q0071000500033Q00208400050005001C2Q0010000600014Q0071000700073Q00208400070007001D001231000800173Q0012310009001E3Q00060F000A0004000100022Q00803Q00074Q00803Q00094Q00920003000A00022Q0010000100033Q001231000200103Q000E52000900990001000200043F3Q009900012Q00710003000A4Q0071000400054Q0071000500033Q00208400050005001F2Q0010000600014Q0071000700033Q00208400070007002000060F00080005000100012Q00803Q00074Q00920003000800022Q0010000100034Q00710003000A4Q0071000400054Q0071000500033Q0020840005000500212Q0010000600014Q0071000700033Q00208400070007002200060F00080006000100012Q00803Q00074Q00920003000800022Q0010000100033Q0012310002000B3Q00267B0002002F0001000B00043F3Q002F00012Q00710003000A4Q0071000400054Q0071000500033Q0020840005000500232Q0010000600014Q0071000700033Q00208400070007002400060F00080007000100012Q00803Q00074Q00920003000800022Q0010000100034Q0071000300084Q0071000400054Q0071000500033Q0020840005000500252Q0010000600014Q0071000700073Q002084000700070026001231000800273Q001231000900283Q00060F000A0008000100012Q00803Q00074Q00920003000A00022Q0010000100033Q001231000200163Q00043F3Q002F000100043F3Q00FC2Q012Q0071000200033Q00208400020002002900060B3Q003F2Q01000200043F3Q003F2Q01001231000200023Q00267B000200DF0001000900043F3Q00DF00012Q0071000300064Q0071000400054Q0071000500033Q00208400050005002A2Q0010000600014Q0071000700073Q00208400070007002B00060F00080009000100012Q00803Q00074Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005002C2Q0010000600014Q0071000700073Q00208400070007002D00060F0008000A000100012Q00803Q00074Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005002E2Q0010000600014Q0071000700073Q00208400070007002F00060F0008000B000100012Q00803Q00074Q00920003000800022Q0010000100033Q0012310002000B3Q00267B00022Q002Q01000200043F4Q002Q012Q0071000300064Q0071000400054Q0071000500033Q0020840005000500302Q0010000600014Q0071000700073Q00208400070007003100060F0008000C000100022Q00803Q00074Q00803Q000B4Q00920003000800022Q0010000100034Q00710003000C4Q0071000400054Q0010000500014Q00920003000500022Q0010000100034Q0071000300084Q0071000400054Q0071000500033Q0020840005000500322Q0010000600014Q0071000700073Q002084000700070033001231000800343Q001231000900353Q00060F000A000D000100012Q00803Q00074Q00920003000A00022Q0010000100033Q001231000200093Q00267B000200242Q01000B00043F3Q00242Q012Q0071000300064Q0071000400054Q0071000500033Q0020840005000500362Q0010000600014Q0071000700073Q00208400070007003700060F0008000E000100012Q00803Q00074Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q0020840005000500382Q0010000600014Q0071000700073Q00208400070007003900060F0008000F000100012Q00803Q000D4Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005003A2Q0010000600014Q0071000700073Q00208400070007003B00060F00080010000100012Q00803Q000E4Q00920003000800022Q0010000100033Q001231000200163Q00267B000200BB0001001600043F3Q00BB00012Q0071000300064Q0071000400054Q0071000500033Q00208400050005003C2Q0010000600014Q0071000700073Q00208400070007003D00060F00080011000100012Q00803Q000F4Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005003E2Q0010000600014Q0071000700073Q00208400070007003F00060F00080012000100012Q00803Q00104Q00920003000800022Q0010000100033Q00043F3Q00FC2Q0100043F3Q00BB000100043F3Q00FC2Q012Q0071000200033Q00208400020002004000060B3Q00C92Q01000200043F3Q00C92Q01001231000200023Q00267B0002005F2Q01000B00043F3Q005F2Q012Q0071000300084Q0071000400054Q0071000500033Q0020840005000500412Q0010000600014Q0071000700073Q002084000700070042001231000800433Q001231000900443Q00060F000A0013000100012Q00803Q00074Q00920003000A00022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q0020840005000500452Q0010000600014Q0071000700073Q00208400070007004600060F00080014000100012Q00803Q00074Q00920003000800022Q0010000100033Q001231000200163Q000E52001000782Q01000200043F3Q00782Q012Q0071000300064Q0071000400054Q0071000500033Q0020840005000500472Q0010000600014Q0071000700073Q00208400070007004800060F00080015000100012Q00803Q00074Q00920003000800022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q0020840005000500492Q0010000600014Q0071000700073Q00208400070007004A00060F00080016000100012Q00803Q00074Q00920003000800022Q0010000100033Q00043F3Q00FC2Q0100267B000200932Q01000900043F3Q00932Q012Q0071000300084Q0071000400054Q0071000500033Q00208400050005004B2Q0010000600014Q0071000700073Q00208400070007004C0012310008004D3Q0012310009004E3Q00060F000A0017000100012Q00803Q00074Q00920003000A00022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q00208400050005004F2Q0010000600014Q0071000700073Q00208400070007005000060F00080018000100012Q00803Q00074Q00920003000800022Q0010000100033Q0012310002000B3Q00267B000200AE2Q01001600043F3Q00AE2Q012Q0071000300084Q0071000400054Q0071000500033Q0020840005000500512Q0010000600014Q0071000700073Q002084000700070052001231000800343Q001231000900533Q00060F000A0019000100012Q00803Q00074Q00920003000A00022Q0010000100034Q0071000300064Q0071000400054Q0071000500033Q0020840005000500542Q0010000600014Q0071000700073Q00208400070007005500060F0008001A000100012Q00803Q00074Q00920003000800022Q0010000100033Q001231000200103Q00267B000200442Q01000200043F3Q00442Q012Q00710003000A4Q0071000400054Q0071000500033Q0020840005000500562Q0010000600014Q0071000700033Q00208400070007005700060F0008001B000100012Q00803Q00114Q00920003000800022Q0010000100034Q00710003000A4Q0071000400054Q0071000500033Q0020840005000500582Q0010000600014Q0071000700033Q00208400070007005900060F0008001C000100012Q00803Q00124Q00920003000800022Q0010000100033Q001231000200093Q00043F3Q00442Q0100043F3Q00FC2Q01001231000200023Q000E52000200E12Q01000200043F3Q00E12Q012Q0071000300134Q0071000400053Q0012310005005A4Q0010000600014Q0071000700144Q00920003000700022Q0010000100034Q0071000300154Q0071000400054Q0071000500033Q00208400050005005B2Q0010000600013Q00060F0007001D000100052Q00803Q00034Q00803Q00164Q00803Q00074Q00803Q00174Q00803Q00184Q00920003000700022Q0010000100033Q001231000200093Q00267B000200CA2Q01000900043F3Q00CA2Q012Q0071000300154Q0071000400054Q0071000500033Q00208400050005005C2Q0010000600013Q00060F0007001E000100082Q00803Q00184Q00803Q00034Q00803Q00194Q00803Q00174Q00803Q00164Q00803Q00074Q00803Q001A4Q00803Q001B4Q00920003000700022Q0010000100034Q0071000300044Q0071000400054Q0071000500033Q00208400050005005D2Q0010000600014Q00920003000600022Q0010000100033Q00043F3Q00FC2Q0100043F3Q00CA2Q012Q00393Q00013Q001F3Q00013Q0003063Q0041696D626F7401034Q007100015Q001094000100014Q00393Q00017Q00023Q0003063Q00536D2Q6F7468026Q00594001044Q007100015Q00204000023Q00020010940001000100022Q00393Q00017Q00013Q0003063Q0054504B692Q6C01034Q007100015Q001094000100014Q00393Q00017Q00033Q00028Q0003073Q0053686F77464F5603073Q0056697369626C6501103Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q00020001001231000200013Q00267B000200050001000100043F3Q000500012Q007100035Q001094000300024Q0071000300013Q001094000300033Q00043F3Q000F000100043F3Q0005000100043F3Q000F000100043F3Q000200012Q00393Q00017Q00063Q00028Q002Q033Q00464F5603043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574027Q004001153Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q00020001001231000200013Q00267B000200050001000100043F3Q000500012Q007100035Q001094000300024Q0071000300013Q00120A000400043Q00208400040004000500202E00053Q000600202E00063Q00062Q009200040006000200109400030003000400043F3Q0014000100043F3Q0005000100043F3Q0014000100043F3Q000200012Q00393Q00017Q00013Q0003063Q0053696C656E7401034Q007100015Q001094000100014Q00393Q00017Q00013Q0003093Q00537469636B7941696D01034Q007100015Q001094000100014Q00393Q00017Q00013Q00030A3Q0053696C656E744175726101034Q007100015Q001094000100014Q00393Q00017Q00013Q0003083Q00417572614469737401034Q007100015Q001094000100014Q00393Q00017Q00013Q0003023Q00484C01034Q007100015Q001094000100014Q00393Q00017Q00013Q0003043Q004E616D6501034Q007100015Q001094000100014Q00393Q00017Q00013Q0003043Q004469737401034Q007100015Q001094000100014Q00393Q00017Q00023Q00028Q002Q033Q00455350010C3Q001231000100013Q000E52000100010001000100043F3Q000100012Q007100025Q001094000200023Q0006093Q000B0001000100043F3Q000B00012Q0071000200014Q001900020001000100043F3Q000B000100043F3Q000100012Q00393Q00017Q00013Q0003073Q004553504469737401034Q007100015Q001094000100014Q00393Q00017Q00013Q0003043Q00542Q6F6C01034Q007100015Q001094000100014Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00017Q00013Q0003083Q0053702Q656456616C01034Q007100015Q001094000100014Q00393Q00017Q00013Q0003043Q004A756D7001034Q007100015Q001094000100014Q00393Q00017Q00013Q00030A3Q00496E665374616D696E6101034Q007100015Q001094000100014Q00393Q00017Q00013Q0003073Q00476F644D6F646501034Q007100015Q001094000100014Q00393Q00017Q00013Q0003083Q00466C7953702Q656401034Q007100015Q001094000100014Q00393Q00017Q00013Q0003053Q0053702Q656401034Q007100015Q001094000100014Q00393Q00017Q00013Q0003073Q004A756D7056616C01034Q007100015Q001094000100014Q00393Q00017Q00013Q0003073Q00496E664A756D7001034Q007100015Q001094000100014Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00019Q002Q0001044Q007100016Q001000026Q004F0001000200012Q00393Q00017Q00043Q00028Q0003023Q005F47025Q00049740025Q00189740001A3Q0012313Q00014Q008D000100013Q00267B3Q00020001000100043F3Q00020001001231000100013Q00267B000100050001000100043F3Q0005000100120A000200024Q007100035Q0020840003000300032Q003600020002000300060F00033Q000100042Q00808Q00803Q00014Q00803Q00024Q00803Q00034Q004F0002000200012Q0071000200044Q007100035Q0020840003000300042Q004F00020002000100043F3Q0019000100043F3Q0005000100043F3Q0019000100043F3Q000200012Q00393Q00013Q00013Q00053Q0003093Q00777269746566696C65025Q00089740030A3Q004A534F4E456E636F6465025Q00109740025Q0014974000143Q00120A3Q00013Q00065C3Q001300013Q00043F3Q0013000100120A3Q00014Q007100015Q0020840001000100022Q0071000200013Q0020210002000200032Q003A00043Q00022Q007100055Q0020840005000500042Q0071000600024Q003E0004000500062Q007100055Q0020840005000500052Q0071000600034Q003E0004000500062Q0059000200044Q00625Q00012Q00393Q00017Q00063Q00028Q00026Q00F03F025Q0020974003023Q005F47025Q00249740025Q00609740001D3Q0012313Q00013Q00267B3Q00080001000200043F3Q000800012Q007100016Q0071000200013Q0020840002000200032Q004F00010002000100043F3Q001C0001000E520001000100013Q00043F3Q0001000100120A000100044Q0071000200013Q0020840002000200052Q003600010001000200060F00023Q000100062Q00803Q00014Q00803Q00024Q00803Q00034Q00803Q00044Q00803Q00054Q00803Q00064Q004F0001000200012Q0071000100074Q0071000200013Q0020840002000200062Q004F0001000200010012313Q00023Q00043F3Q000100012Q00393Q00013Q00013Q00103Q0003063Q00697366696C65025Q00289740028Q00026Q00F03F03053Q0062696E647303053Q007061697273030A3Q004A534F4E4465636F646503083Q007265616466696C65025Q003897402Q033Q0063666700025Q00449740030C3Q00455350436F6C6F724E616D6503063Q0069706169727303083Q00455350436F6C6F72027Q004000653Q00120A3Q00013Q00065C3Q006400013Q00043F3Q0064000100120A3Q00014Q007100015Q0020840001000100022Q006E3Q0002000200065C3Q006400013Q00043F3Q006400010012313Q00034Q008D000100013Q00267B3Q001D0001000400043F3Q001D000100208400020001000500065C0002006400013Q00043F3Q0064000100120A000200063Q0020840003000100052Q001E00020002000400043F3Q001A00012Q0071000700014Q003600070007000500065C0007001A00013Q00043F3Q001A00012Q0071000700024Q003E00070005000600066A000200140001000200043F3Q0014000100043F3Q0064000100267B3Q000B0001000300043F3Q000B0001001231000200033Q00267B000200240001000400043F3Q002400010012313Q00043Q00043F3Q000B000100267B000200200001000300043F3Q002000012Q0071000300033Q00202100030003000700120A000500084Q007100065Q0020840006000600092Q0003000500064Q005000033Q00022Q0010000100033Q00208400030001000A00065C0003006100013Q00043F3Q00610001001231000300034Q008D000400043Q00267B000300330001000300043F3Q00330001001231000400033Q00267B000400360001000300043F3Q0036000100120A000500063Q00208400060001000A2Q001E00050002000700043F3Q004600012Q0071000A00044Q0036000A000A0008002653000A00460001000B00043F3Q004600012Q0071000A5Q002084000A000A000C000604000800460001000A00043F3Q004600012Q0071000A00044Q003E000A0008000900066A0005003C0001000200043F3Q003C000100208400050001000A00208400050005000D00065C0005006100013Q00043F3Q0061000100120A0005000E4Q0071000600054Q001E00050002000700043F3Q005B0001002084000A00090004002084000B0001000A002084000B000B000D00060B000A005B0001000B00043F3Q005B00012Q0071000A00044Q0071000B00043Q002084000C00090010002084000D00090004001094000B000D000D001094000A000F000C00066A000500500001000200043F3Q0050000100043F3Q0061000100043F3Q0036000100043F3Q0061000100043F3Q00330001001231000200043Q00043F3Q0020000100043F3Q000B00012Q00393Q00019Q003Q00044Q00718Q0071000100014Q004F3Q000200012Q00393Q00017Q00043Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3103083Q00506F736974696F6E010E3Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B0001000D0001000200043F3Q000D00012Q007A000100013Q00208400023Q00042Q0071000300033Q0020840003000300042Q007F000300024Q007F000200014Q007F00016Q00393Q00017Q000B3Q00030D3Q0055736572496E7075745479706503043Q00456E756D030D3Q004D6F7573654D6F76656D656E74028Q0003083Q00506F736974696F6E03053Q005544696D322Q033Q006E657703013Q005803053Q005363616C6503063Q004F2Q6673657403013Q005901284Q007100015Q00065C0001002700013Q00043F3Q0027000100208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100270001000200043F3Q00270001001231000100044Q008D000200023Q00267B0001000B0001000400043F3Q000B000100208400033Q00052Q0071000400014Q00450002000300042Q0071000300023Q00120A000400063Q0020840004000400072Q0071000500033Q0020840005000500080020840005000500092Q0071000600033Q00208400060006000800208400060006000A0020840007000200082Q00960006000600072Q0071000700033Q00208400070007000B0020840007000700092Q0071000800033Q00208400080008000B00208400080008000A00208400090002000B2Q00960008000800092Q009200040008000200109400030005000400043F3Q0027000100043F3Q000B00012Q00393Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3101093Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100080001000200043F3Q000800012Q007A00016Q007F00016Q00393Q00017Q00033Q00028Q0003073Q0056697369626C65026Q00F03F01153Q001231000100014Q008D000200023Q00267B000100020001000100043F3Q00020001001231000200013Q000E520001000B0001000200043F3Q000B00012Q007F8Q0071000300013Q001094000300023Q001231000200033Q00267B000200050001000300043F3Q000500012Q0071000300024Q001B00045Q00109400030002000400043F3Q0014000100043F3Q0005000100043F3Q0014000100043F3Q000200012Q00393Q00019Q003Q00044Q00718Q007A00016Q004F3Q000200012Q00393Q00019Q003Q00044Q00718Q007A000100014Q004F3Q000200012Q00393Q00017Q00233Q0003073Q004B6579436F646503043Q00456E756D03073Q00556E6B6E6F776E028Q00027Q004003043Q004E616D6503043Q0054657874030A3Q0054657874436F6C6F723303043Q00536F6674026Q000840026Q00F03F03063Q0044656C65746503093Q004261636B737061636500025Q00509840025Q005C9840030A3Q0052696768745368696674025Q00709840025Q007C984003053Q0070616972732Q033Q00736574025Q00AC9840025Q00B09840025Q00B4984003063Q0053696C656E74025Q00BC984003093Q00537469636B7941696D025Q00C49840030A3Q0053696C656E7441757261025Q00CC984003063Q004E6F636C69702Q033Q00466C79030D3Q0055736572496E70757454797065030C3Q004D6F75736542752Q746F6E32030C3Q004D6F75736542752Q746F6E310246012Q00065C0001000300013Q00043F3Q000300012Q00393Q00014Q007100025Q00065C000200A100013Q00043F3Q00A1000100208400023Q000100120A000300023Q002084000300030001002084000300030003000604000200A10001000300043F3Q00A10001001231000200044Q008D000300033Q000E520005002E0001000200043F3Q002E00012Q0071000400013Q00208400053Q00010020840005000500062Q003E0004000300052Q0071000400024Q003600040004000300065C0004002D00013Q00043F3Q002D0001001231000400044Q008D000500053Q00267B0004001A0001000400043F3Q001A0001001231000500043Q00267B0005001D0001000400043F3Q001D00012Q0071000600024Q003600060006000300208400073Q00010020840007000700060010940006000700072Q0071000600024Q00360006000600032Q0071000700033Q00208400070007000900109400060008000700043F3Q002D000100043F3Q001D000100043F3Q002D000100043F3Q001A00010012310002000A3Q00267B000200900001000B00043F3Q0090000100208400043Q000100120A000500023Q00208400050005000100208400050005000C0006040004003C0001000500043F3Q003C000100208400043Q000100120A000500023Q00208400050005000100208400050005000D00060B000400630001000500043F3Q00630001001231000400043Q00267B0004005B0001000400043F3Q005B00012Q0071000500013Q00206C00050003000E2Q0071000500024Q003600050005000300065C0005005A00013Q00043F3Q005A0001001231000500044Q008D000600063Q00267B000500470001000400043F3Q00470001001231000600043Q00267B0006004A0001000400043F3Q004A00012Q0071000700024Q00360007000700032Q0071000800043Q00208400080008000F0010940007000700082Q0071000700024Q00360007000700032Q0071000800033Q00208400080008000900109400070008000800043F3Q005A000100043F3Q004A000100043F3Q005A000100043F3Q004700010012310004000B3Q00267B0004003D0001000B00043F3Q003D00012Q0071000500054Q0071000600043Q0020840006000600102Q004F0005000200012Q00393Q00013Q00043F3Q003D000100208400043Q000100120A000500023Q00208400050005000100208400050005001100060B0004008F0001000500043F3Q008F0001001231000400044Q008D000500053Q000E520004006B0001000400043F3Q006B0001001231000500043Q00267B0005006E0001000400043F3Q006E0001001231000600043Q00267B000600710001000400043F3Q007100012Q0071000700024Q003600070007000300065C0007008A00013Q00043F3Q008A0001001231000700043Q00267B000700780001000400043F3Q007800012Q0071000800024Q00360008000800032Q0071000900014Q0036000900090003000609000900820001000100043F3Q008200012Q0071000900043Q0020840009000900120010940008000700092Q0071000800024Q00360008000800032Q0071000900033Q00208400090009000900109400080008000900043F3Q008A000100043F3Q007800012Q00393Q00013Q00043F3Q0071000100043F3Q006E000100043F3Q008F000100043F3Q006B0001001231000200053Q000E52000A009A0001000200043F3Q009A00012Q0071000400054Q0071000500043Q00208400050005001300208400063Q00010020840006000600062Q00880005000500062Q004F0004000200012Q00393Q00013Q000E520004000E0001000200043F3Q000E00012Q007100036Q008D000400044Q007F00045Q0012310002000B3Q00043F3Q000E000100208400023Q000100120A000300023Q00208400030003000100208400030003001100060B000200AB0001000300043F3Q00AB00012Q0071000200064Q0071000300074Q001B000300034Q004F00020002000100208400023Q000100120A000300023Q0020840003000300010020840003000300030006040002001D2Q01000300043F3Q001D2Q01001231000200044Q008D000300033Q00267B000200B30001000400043F3Q00B3000100208400043Q000100208400030004000600120A000400144Q0071000500014Q001E00040002000600043F3Q00192Q012Q0071000900084Q003600090009000700065C000900192Q013Q00043F3Q00192Q0100060B000800192Q01000300043F3Q00192Q01001231000900044Q008D000A000C3Q000E52000B00132Q01000900043F3Q00132Q012Q008D000C000C3Q00267B000A00E30001000B00043F3Q00E300012Q0071000D00094Q0036000D000D000700065C000D00D200013Q00043F3Q00D200012Q0071000D00094Q0036000D000D0007002084000D000D00152Q0010000E000C4Q004F000D0002000100043F3Q00D600012Q0071000D000A4Q0010000E00074Q0010000F000C4Q0087000D000F00012Q0071000D00054Q0010000E00073Q00065C000C00DE00013Q00043F3Q00DE00012Q0071000F00043Q002084000F000F0016000609000F00E00001000100043F3Q00E000012Q0071000F00043Q002084000F000F00172Q0088000E000E000F2Q004F000D0002000100043F3Q00192Q01000E52000400C60001000A00043F3Q00C60001001231000D00043Q00267B000D000C2Q01000400043F3Q000C2Q012Q0071000E00043Q002084000E000E001800060B000700F00001000E00043F3Q00F000012Q0071000E000B3Q002084000E000E0019000677000B000A2Q01000E00043F3Q000A2Q012Q0071000E00043Q002084000E000E001A00060B000700F80001000E00043F3Q00F800012Q0071000E000B3Q002084000E000E001B000677000B000A2Q01000E00043F3Q000A2Q012Q0071000E00043Q002084000E000E001C00060B00072Q002Q01000E00043F4Q002Q012Q0071000E000B3Q002084000E000E001D000677000B000A2Q01000E00043F3Q000A2Q012Q0071000E00043Q002084000E000E001E00060B000700082Q01000E00043F3Q00082Q012Q0071000E000B3Q002084000E000E001F000677000B000A2Q01000E00043F3Q000A2Q012Q0071000E000B3Q002084000B000E00202Q001B000C000B3Q001231000D000B3Q00267B000D00E60001000B00043F3Q00E60001001231000A000B3Q00043F3Q00C6000100043F3Q00E6000100043F3Q00C6000100043F3Q00192Q0100267B000900C30001000400043F3Q00C30001001231000A00044Q008D000B000B3Q0012310009000B3Q00043F3Q00C3000100066A000400BB0001000200043F3Q00BB000100043F3Q001D2Q0100043F3Q00B3000100208400023Q002100120A000300023Q00208400030003002100208400030003002200060B000200252Q01000300043F3Q00252Q012Q007A000200014Q007F0002000C3Q00208400023Q002100120A000300023Q00208400030003002100208400030003002300060B000200452Q01000300043F3Q00452Q01001231000200044Q008D000300053Q00267B000200322Q01000400043F3Q00322Q01001231000300044Q008D000400043Q0012310002000B3Q00267B0002002D2Q01000B00043F3Q002D2Q012Q008D000500053Q00267B000300352Q01000400043F3Q00352Q012Q00710006000D4Q007A000700014Q001E0006000200072Q0010000500074Q0010000400063Q00065C000500452Q013Q00043F3Q00452Q012Q00710006000E4Q0010000700054Q004F00060002000100043F3Q00452Q0100043F3Q00352Q0100043F3Q00452Q0100043F3Q002D2Q012Q00393Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3201093Q00208400013Q000100120A000200023Q00208400020002000100208400020002000300060B000100080001000200043F3Q000800012Q007A00016Q007F00016Q00393Q00017Q000A3Q00028Q00027Q00402Q033Q00466C7903073Q0044657374726F79030A3Q00446973636F2Q6E656374026Q00F03F03043Q007461736B03043Q0077616974029A5Q99D93F03063Q004E6F636C6970004A3Q0012313Q00014Q008D000100013Q00267B3Q00020001000100043F3Q00020001001231000100013Q00267B0001000F0001000200043F3Q000F00012Q007100025Q00208400020002000300065C0002004900013Q00043F3Q004900012Q0071000200014Q007A000300014Q004F00020002000100043F3Q00490001000E52000100380001000100043F3Q003800012Q0071000200023Q00065C0002002400013Q00043F3Q00240001001231000200014Q008D000300033Q00267B000200160001000100043F3Q00160001001231000300013Q00267B000300190001000100043F3Q001900012Q0071000400023Q0020210004000400042Q004F0004000200012Q008D000400044Q007F000400023Q00043F3Q0024000100043F3Q0019000100043F3Q0024000100043F3Q001600012Q0071000200033Q00065C0002003700013Q00043F3Q00370001001231000200014Q008D000300033Q000E52000100290001000200043F3Q00290001001231000300013Q00267B0003002C0001000100043F3Q002C00012Q0071000400033Q0020210004000400052Q004F0004000200012Q008D000400044Q007F000400033Q00043F3Q0037000100043F3Q002C000100043F3Q0037000100043F3Q00290001001231000100063Q00267B000100050001000600043F3Q0005000100120A000200073Q002084000200020008001231000300094Q004F0002000200012Q007100025Q00208400020002000A00065C0002004500013Q00043F3Q004500012Q0071000200044Q007A000300014Q004F000200020001001231000100023Q00043F3Q0005000100043F3Q0049000100043F3Q000200012Q00393Q00017Q00123Q00028Q0003073Q0056697369626C6503073Q0053686F77464F5603023Q005F47025Q00309940026Q33D33F025Q003499402Q033Q0045535003063Q00697061697273030A3Q00476574506C617965727303063Q005573657249642Q01026Q00F03F03053Q007061697273030A3Q0053696C656E744175726103063Q0041696D626F7403063Q0053696C656E7403093Q00537469636B7941696D00B73Q0012313Q00013Q00267B3Q005B0001000100043F3Q005B00012Q007100016Q0071000200013Q00208400020002000300109400010002000200120A000100044Q0071000200023Q0020840002000200052Q00360001000100022Q004E0001000100022Q0071000200034Q0045000100010002000E4B0006005A0001000100043F3Q005A0001001231000100014Q008D000200023Q00267B000100120001000100043F3Q00120001001231000200013Q00267B000200150001000100043F3Q0015000100120A000300044Q0071000400023Q0020840004000400072Q00360003000300042Q004E0003000100022Q007F000300034Q0071000300013Q00208400030003000800065C0003005400013Q00043F3Q00540001001231000300014Q008D000400043Q00267B000300430001000100043F3Q004300012Q003A00056Q0010000400053Q00120A000500094Q0071000600043Q00202100060006000A2Q0003000600074Q006900053Q000700043F3Q004000012Q0071000A00053Q000604000900400001000A00043F3Q00400001001231000A00014Q008D000B000B3Q00267B000A00320001000100043F3Q00320001001231000B00013Q00267B000B00350001000100043F3Q00350001002084000C0009000B00206C0004000C000C2Q0071000C00064Q0010000D00094Q004F000C0002000100043F3Q0040000100043F3Q0035000100043F3Q0040000100043F3Q0032000100066A0005002D0001000200043F3Q002D00010012310003000D3Q000E52000D00230001000300043F3Q0023000100120A0005000E4Q0071000600074Q001E00050002000700043F3Q004F00012Q00360009000400080006090009004F0001000100043F3Q004F00012Q0071000900084Q0010000A00084Q004F00090002000100066A000500490001000100043F3Q0049000100043F3Q005A000100043F3Q0023000100043F3Q005A00012Q0071000300094Q001900030001000100043F3Q005A000100043F3Q0015000100043F3Q005A000100043F3Q001200010012313Q000D3Q00267B3Q00010001000D00043F3Q000100012Q0071000100013Q00208400010001000F00065C0001007A00013Q00043F3Q007A0001001231000100014Q008D000200033Q00267B0001006C0001000D00043F3Q006C000100065C000200B600013Q00043F3Q00B600012Q00710004000A4Q0010000500024Q007A000600014Q008700040006000100043F3Q00B60001000E52000100630001000100043F3Q006300012Q00710004000B4Q00900004000100052Q0010000300054Q0010000200043Q00065C0003007700013Q00043F3Q007700012Q00710004000C4Q0010000500034Q004F0004000200010012310001000D3Q00043F3Q0063000100043F3Q00B600012Q0071000100013Q002084000100010010000609000100860001000100043F3Q008600012Q0071000100013Q002084000100010011000609000100860001000100043F3Q008600012Q0071000100013Q00208400010001001200065C000100B600013Q00043F3Q00B600012Q00710001000D3Q00065C000100B600013Q00043F3Q00B60001001231000100014Q008D000200043Q00267B000100900001000100043F3Q00900001001231000200014Q008D000300033Q0012310001000D3Q00267B0001008B0001000D00043F3Q008B00012Q008D000400043Q00267B000200A90001000100043F3Q00A90001001231000500013Q00267B0005009A0001000D00043F3Q009A00010012310002000D3Q00043F3Q00A9000100267B000500960001000100043F3Q009600012Q00710006000E4Q0071000700013Q0020840007000700112Q001E0006000200072Q0010000400074Q0010000300063Q00065C000400A700013Q00043F3Q00A700012Q00710006000C4Q0010000700044Q004F0006000200010012310005000D3Q00043F3Q0096000100267B000200930001000D00043F3Q0093000100065C000300B600013Q00043F3Q00B600012Q00710005000A4Q0010000600034Q004F00050002000100043F3Q00B6000100043F3Q0093000100043F3Q00B6000100043F3Q008B000100043F3Q00B6000100043F3Q000100012Q00393Q00017Q00",v9(),...);
