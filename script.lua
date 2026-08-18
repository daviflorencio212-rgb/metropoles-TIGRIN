--[[ TIGRINHO v5.2 COMPLETE | blue | FOV revistar 1x | anti-ofusca ]]
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

print("[Tigrinho] v5.2 COMPLETE ok")
