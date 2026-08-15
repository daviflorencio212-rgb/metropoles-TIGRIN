--[[ TIGRINHO - LOOT PROFISSIONAL ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local WS = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChat = game:GetService("TextChatService")
local RS = game:GetService("ReplicatedStorage")
local VIM = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera
local mobile = UIS.TouchEnabled

local CFG = {
	Aimbot = false, Silent = false, ShowFOV = false,
	FOV = 120, Smooth = 0.12, MaxDist = 150,
	ESP = false, HL = true, Name = true, Dist = true, Tool = true,
	ESPDist = 500, ESPColor = Color3.fromRGB(255, 145, 40),
	Noclip = false, Fly = false, FlySpeed = 60,
	Speed = false, SpeedVal = 24, Jump = false, JumpVal = 60,
	Fullbright = false, TPKill = false, AutoRevistar = true, QuitDeath = false,
}

local holdAim, menuOn = false, true
local drag, d0, p0 = false, nil, nil
local nConn, flyBV, espCache = nil, nil, {}
local looting = false
local myVictim, myVictimAt = nil, 0

local C = {
	Bg = Color3.fromRGB(16, 15, 14), Side = Color3.fromRGB(22, 20, 18),
	Card = Color3.fromRGB(30, 27, 24), Bar = Color3.fromRGB(45, 40, 35),
	Accent = Color3.fromRGB(255, 145, 40), Soft = Color3.fromRGB(255, 175, 90),
	Text = Color3.fromRGB(250, 246, 240), Dim = Color3.fromRGB(155, 145, 135),
	Off = Color3.fromRGB(50, 46, 42),
}

local function notify(t)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "Tigrinho", Text = t, Duration = 3})
	end)
end

local function markVictim(p)
	if p and p ~= LP then myVictim = p myVictimAt = tick() end
end

local parent = LP:WaitForChild("PlayerGui")
pcall(function() if gethui then parent = gethui() end end)
pcall(function()
	for _, v in pairs(parent:GetChildren()) do
		if v.Name == "Tigrinho" then v:Destroy() end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Tigrinho"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

local fovF = Instance.new("Frame")
fovF.AnchorPoint = Vector2.new(0.5, 0.5)
fovF.Position = UDim2.new(0.5, 0, 0.5, 0)
fovF.Size = UDim2.new(0, CFG.FOV * 2, 0, CFG.FOV * 2)
fovF.BackgroundTransparency = 1
fovF.Visible = false
fovF.Parent = gui
Instance.new("UICorner", fovF).CornerRadius = UDim.new(1, 0)
local fovS = Instance.new("UIStroke", fovF)
fovS.Color = C.Accent
fovS.Thickness = 1.5
fovS.Transparency = 0.4

local W, H = mobile and 350 or 500, mobile and 410 or 390
local main = Instance.new("Frame")
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
main.BackgroundColor3 = C.Bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)
Instance.new("UIStroke", main).Color = Color3.fromRGB(60, 45, 30)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = C.Side
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 18)
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 14)
topFix.Position = UDim2.new(0, 0, 1, -14)
topFix.BackgroundColor3 = C.Side
topFix.BorderSizePixel = 0
topFix.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TIGRINHO"
title.TextColor3 = C.Accent
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local xBtn = Instance.new("TextButton")
xBtn.Size = UDim2.new(0, 30, 0, 30)
xBtn.Position = UDim2.new(1, -36, 0.5, -15)
xBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
xBtn.Text = "×"
xBtn.TextColor3 = C.Dim
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 18
xBtn.Parent = top
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0, 8)

local sideW = mobile and 0 or 108
local side = Instance.new("Frame")
side.Size = UDim2.new(0, sideW, 1, -42)
side.Position = UDim2.new(0, 0, 0, 42)
side.BackgroundColor3 = C.Side
side.BorderSizePixel = 0
side.Visible = not mobile
side.Parent = main

local mTabs = Instance.new("Frame")
mTabs.Size = UDim2.new(1, -12, 0, 34)
mTabs.Position = UDim2.new(0, 6, 0, 48)
mTabs.BackgroundTransparency = 1
mTabs.Visible = mobile
mTabs.Parent = main
local ml = Instance.new("UIListLayout", mTabs)
ml.FillDirection = Enum.FillDirection.Horizontal
ml.Padding = UDim.new(0, 5)

local contentY = mobile and 88 or 50
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, mobile and -14 or -(sideW + 14), 1, -(contentY + 10))
content.Position = UDim2.new(0, mobile and 7 or sideW + 8, 0, contentY)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = C.Accent
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 14, 1, -64)
openBtn.BackgroundColor3 = C.Accent
openBtn.Text = "T"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 18
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local revBtn = Instance.new("TextButton")
revBtn.Size = UDim2.new(0, 118, 0, 36)
revBtn.Position = UDim2.new(0, 14, 0, 92)
revBtn.BackgroundColor3 = C.Accent
revBtn.Text = "REVISTAR"
revBtn.Font = Enum.Font.GothamBold
revBtn.TextSize = 12
revBtn.TextColor3 = Color3.new(1,1,1)
revBtn.Parent = gui
Instance.new("UICorner", revBtn).CornerRadius = UDim.new(0, 10)

local tabs = {}
local function addTab(name, order)
	if mobile then
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 72, 0, 30)
		b.BackgroundColor3 = C.Card
		b.Text = name
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 11
		b.TextColor3 = C.Dim
		b.Parent = mTabs
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
		tabs[name] = b
	else
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -14, 0, 34)
		b.Position = UDim2.new(0, 7, 0, 12 + (order-1)*42)
		b.BackgroundColor3 = C.Card
		b.Text = "  " .. name
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 13
		b.TextColor3 = C.Dim
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Parent = side
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
		tabs[name] = b
	end
end
addTab("PvP", 1) addTab("ESP", 2) addTab("Player", 3) addTab("Outros", 4)

local function rowToggle(parent, text, y, def, cb)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -2, 0, 34)
	f.Position = UDim2.new(0, 1, 0, y)
	f.BackgroundColor3 = C.Card
	f.BorderSizePixel = 0
	f.Parent = parent
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1, -58, 1, 0)
	lb.Position = UDim2.new(0, 14, 0, 0)
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = C.Text
	lb.Font = Enum.Font.Gotham
	lb.TextSize = 13
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = f
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 0, 22)
	btn.Position = UDim2.new(1, -50, 0.5, -11)
	btn.BackgroundColor3 = def and C.Accent or C.Off
	btn.Text = ""
	btn.Parent = f
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 16, 0, 16)
	dot.Position = def and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	dot.BackgroundColor3 = Color3.new(1,1,1)
	dot.BorderSizePixel = 0
	dot.Parent = btn
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	local st = def
	btn.MouseButton1Click:Connect(function()
		st = not st
		btn.BackgroundColor3 = st and C.Accent or C.Off
		dot.Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		cb(st)
	end)
	return y + 40
end

local function rowSlider(parent, text, y, def, min, max, cb)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -2, 0, 48)
	f.Position = UDim2.new(0, 1, 0, y)
	f.BackgroundColor3 = C.Card
	f.BorderSizePixel = 0
	f.Parent = parent
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(0.7, 0, 0, 18)
	lb.Position = UDim2.new(0, 14, 0, 6)
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = C.Text
	lb.Font = Enum.Font.Gotham
	lb.TextSize = 12
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = f
	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0.25, -8, 0, 18)
	vl.Position = UDim2.new(0.72, 0, 0, 6)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(def)
	vl.TextColor3 = C.Soft
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 12
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = f
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -28, 0, 6)
	bg.Position = UDim2.new(0, 14, 0, 32)
	bg.BackgroundColor3 = C.Bar
	bg.BorderSizePixel = 0
	bg.Parent = f
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(math.clamp((def-min)/(max-min),0,1), 0, 1, 0)
	bar.BackgroundColor3 = C.Accent
	bar.BorderSizePixel = 0
	bar.Parent = bg
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	local sliding = false
	local function upd(inp)
		local rel = math.clamp((inp.Position.X - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1), 0, 1)
		local v = math.floor(min + (max - min) * rel)
		bar.Size = UDim2.new(rel, 0, 1, 0)
		vl.Text = tostring(v)
		cb(v)
	end
	bg.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true upd(i)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
	end)
	UIS.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
	end)
	return y + 54
end

-- ====================== LOOT PROFISSIONAL ======================

local function listAllItems(plr)
	local items, seen = {}, {}
	local function add(n)
		if n and n ~= "" and not seen[n] then seen[n] = true table.insert(items, n) end
	end
	if plr and plr.Character then
		for _, o in ipairs(plr.Character:GetChildren()) do
			if o:IsA("Tool") then add(o.Name) end
		end
	end
	if plr then
		local bp = plr:FindFirstChild("Backpack")
		if bp then
			for _, o in ipairs(bp:GetChildren()) do
				if o:IsA("Tool") then add(o.Name) end
			end
		end
	end
	return items
end

-- clique real: connections + Activate + mouse virtual no centro
local function clickGui(obj)
	if not obj or not obj.Parent then return end

	-- 1) getconnections
	pcall(function()
		if getconnections then
			for _, sigName in ipairs({"MouseButton1Click", "MouseButton1Down", "MouseButton1Up", "Activated"}) do
				local ok, sig = pcall(function() return obj[sigName] end)
				if ok and sig then
					for _, conn in pairs(getconnections(sig)) do
						pcall(function()
							if conn.Fire then conn:Fire() end
							if conn.Function then conn.Function() end
						end)
					end
				end
			end
		end
	end)

	-- 2) Activate
	pcall(function()
		if obj:IsA("GuiButton") then
			obj:Activate()
		end
	end)

	-- 3) VirtualInput no centro do botao
	pcall(function()
		if VIM and obj:IsA("GuiObject") then
			local a = obj.AbsolutePosition
			local s = obj.AbsoluteSize
			if s.X > 2 and s.Y > 2 then
				local x = a.X + s.X / 2
				local y = a.Y + s.Y / 2
				VIM:SendMouseMoveEvent(x, y, game)
				task.wait(0.02)
				VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
				task.wait(0.04)
				VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
			end
		end
	end)
end

local function findFinalizar()
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return nil end
	for _, o in ipairs(pg:GetDescendants()) do
		if o:IsA("TextButton") then
			local t = string.lower(tostring(o.Text or ""))
			if string.find(t, "finalizar") then return o end
		end
	end
	return nil
end

local function getRevistamentoWindow()
	local fin = findFinalizar()
	if not fin then return nil end
	local w = fin
	for _ = 1, 15 do
		if w.Parent and w.Parent:IsA("GuiObject") then
			w = w.Parent
		else
			break
		end
	end
	return w
end

-- pega todos os slots clicaveis da UI (exceto Finalizar)
local function getItemButtons(window)
	local list = {}
	if not window then return list end
	for _, o in ipairs(window:GetDescendants()) do
		if o:IsA("TextButton") or o:IsA("ImageButton") then
			local t = string.lower(tostring(o.Text or ""))
			if not string.find(t, "finalizar")
				and not string.find(t, "fechar")
				and not string.find(t, "salvar")
				and not string.find(t, "cancel") then
				-- so botoes visiveis com tamanho
				if o.Visible and o.AbsoluteSize.X > 5 and o.AbsoluteSize.Y > 5 then
					table.insert(list, o)
				end
			end
		end
	end
	return list
end

-- tenta remotes de loot com varios argumentos
local function spamLootRemotes(target, itemNames)
	local nomesUteis = {"pegar", "take", "loot", "item", "invent", "roub", "steal", "collect", "revis", "search", "give", "transfer"}
	for _, rem in ipairs(RS:GetDescendants()) do
		if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
			local n = string.lower(rem.Name)
			local util = false
			for _, k in ipairs(nomesUteis) do
				if string.find(n, k) then util = true break end
			end
			if util then
				local argsList = {
					{target},
					{target.Name},
					{target.UserId},
					{target.Character},
					{},
					{true},
					{"all"},
					{"tudo"},
				}
				for _, iname in ipairs(itemNames) do
					table.insert(argsList, {iname})
					table.insert(argsList, {target, iname})
					table.insert(argsList, {iname, true})
					table.insert(argsList, {target.Name, iname})
				end
				for _, args in ipairs(argsList) do
					pcall(function()
						if rem:IsA("RemoteEvent") then
							rem:FireServer(table.unpack(args))
						else
							rem:InvokeServer(table.unpack(args))
						end
					end)
				end
			end
		end
	end
end

--[[
  FLUXO PROFISSIONAL:
  1. Lista itens do alvo
  2. /revistar + remote revisar_function
  3. Espera UI Revistamento
  4. Clica CADA botao de item (3 metodos) varias vezes
  5. Clica Finalizar
  6. Spam remotes com nomes dos itens
]]
local function pegarTudo(target)
	if looting then return end
	if not target then return end
	looting = true

	task.spawn(function()
		local itemNames = listAllItems(target)
		print("[Tigrinho] Analise inventario:", target.Name, "→", table.concat(itemNames, ", "))
		if #itemNames > 0 then
			notify("Itens: " .. table.concat(itemNames, ", "))
		else
			notify("Revistando " .. target.Name)
		end

		-- chat
		pcall(function()
			local ch = TextChat:FindFirstChild("TextChannels")
			if ch then
				local g = ch:FindFirstChild("RBXGeneral") or ch:FindFirstChild("General")
				if g then g:SendAsync("/revistar " .. target.Name) end
			end
		end)
		pcall(function() LP:Chat("/revistar " .. target.Name) end)

		-- remote principal
		local remote
		pcall(function()
			remote = RS.shared and RS.shared.Eventos and RS.shared.Eventos.revisar_function
		end)
		if not remote then
			pcall(function() remote = RS:FindFirstChild("revisar_function", true) end)
		end
		if remote then
			pcall(function() remote:InvokeServer(target) end)
			pcall(function() remote:InvokeServer(target.Name) end)
			pcall(function() remote:InvokeServer(target.Character) end)
			pcall(function() remote:InvokeServer(target.UserId) end)
			pcall(function() remote:InvokeServer() end)
			for _, iname in ipairs(itemNames) do
				pcall(function() remote:InvokeServer(iname) end)
				pcall(function() remote:InvokeServer(target, iname) end)
				pcall(function() remote:InvokeServer(target.Name, iname) end)
			end
		end

		task.wait(0.35)

		-- espera UI abrir
		local window
		for i = 1, 70 do
			window = getRevistamentoWindow()
			if window then break end
			task.wait(0.1)
		end

		if not window then
			warn("[Tigrinho] UI Revistamento nao abriu")
			spamLootRemotes(target, itemNames)
			looting = false
			notify("UI nao abriu - tentou remote")
			return
		end

		print("[Tigrinho] UI aberta, clicando itens...")
		notify("Clicando itens da UI...")

		-- clica itens varias passadas
		for pass = 1, 15 do
			local win = getRevistamentoWindow()
			if not win then break end

			local botoes = getItemButtons(win)
			print("[Tigrinho] Pass", pass, "botoes:", #botoes)

			for _, btn in ipairs(botoes) do
				clickGui(btn)
				task.wait(0.05)
				-- segundo clique (alguns jogos pedem 2x)
				clickGui(btn)
				task.wait(0.04)
			end

			-- tambem labels com nome de item
			for _, o in ipairs(win:GetDescendants()) do
				if o:IsA("TextLabel") then
					local t = tostring(o.Text or "")
					local low = string.lower(t)
					if #t >= 2 and not string.find(low, "revistamento") and not string.find(low, "finalizar") then
						local host = o:FindFirstAncestorWhichIsA("TextButton")
							or o:FindFirstAncestorWhichIsA("ImageButton")
						if host then
							clickGui(host)
							task.wait(0.03)
						end
					end
				end
			end

			task.wait(0.08)
		end

		-- Finalizar
		task.wait(0.15)
		local fin = findFinalizar()
		if fin then
			clickGui(fin)
			task.wait(0.08)
			clickGui(fin)
		end

		-- remotes finais
		spamLootRemotes(target, itemNames)

		notify("Loot finalizado")
		print("[Tigrinho] Loot finalizado em", target.Name)
		looting = false
	end)
end

local function nearest()
	local best, bd = nil, 120
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not meu then return nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
			if r then
				local d = (r.Position - meu.Position).Magnitude
				if d < bd then bd = d best = plr end
			end
		end
	end
	return best
end

revBtn.MouseButton1Click:Connect(function()
	local t = nearest()
	if not t then notify("Ninguem perto") return end
	pegarTudo(t)
end)

-- CORE mira / etc
local function valid(char)
	if not char or char == LP.Character then return false end
	local h = char:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0 and Players:GetPlayerFromCharacter(char) ~= nil
end

local function sDist(pos)
	local sp, on = Cam:WorldToViewportPoint(pos)
	if not on or sp.Z < 0 then return 999999 end
	return (Vector2.new(sp.X, sp.Y) - Cam.ViewportSize/2).Magnitude
end

local function findTarget(noFov)
	local lim = noFov and 999999 or CFG.FOV
	local best, bd, bestP = nil, lim, nil
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil, nil end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and valid(plr.Character) then
			local p = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
			if p and (p.Position - root.Position).Magnitude <= CFG.MaxDist * 8 then
				local d = sDist(p.Position)
				if d < bd then bd = d best = p bestP = plr end
			end
		end
	end
	return best, bestP
end

local function aim(part)
	if not part then return end
	Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, part.Position), CFG.Silent and 0.97 or math.clamp(1 - CFG.Smooth, 0.45, 0.98))
end

local function onDeath(plr, char)
	if not CFG.TPKill then return end
	if plr ~= myVictim then return end
	if tick() - myVictimAt > 25 then return end
	local r = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not r or not meu then return end
	meu.CFrame = CFrame.new(r.Position + Vector3.new(0, 3, 0))
	task.wait(0.15)
	pegarTudo(plr)
	notify("Kill loot: " .. plr.Name)
	myVictim = nil
end

local function watchDeath(plr)
	local function hook(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function() onDeath(plr, char) end)
	end
	if plr.Character then hook(plr.Character) end
	plr.CharacterAdded:Connect(hook)
end
for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP then watchDeath(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr ~= LP then watchDeath(plr) end end)

local function setNoclip(on)
	CFG.Noclip = on
	if nConn then nConn:Disconnect() nConn = nil end
	local char = LP.Character
	if not char then return end
	if on then
		nConn = RunService.Stepped:Connect(function()
			local c = LP.Character
			if not c then return end
			for _, p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = (p.Name ~= "HumanoidRootPart") end
		end
	end
end

local function setFly(on)
	CFG.Fly = on
	if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not on then
		if root then root.AssemblyLinearVelocity = Vector3.zero end
		return
	end
	if not root then return end
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBV.Velocity = Vector3.zero
	flyBV.Parent = root
end

RunService.RenderStepped:Connect(function()
	if not CFG.Fly then
		if flyBV then flyBV:Destroy() flyBV = nil end
		return
	end
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if not flyBV or not flyBV.Parent then
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyBV.Parent = root
	end
	local dir, cf = Vector3.zero, Cam.CFrame
	if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
	if mobile then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.MoveDirection.Magnitude > 0.05 then
			dir = dir + Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z)
		end
	end
	flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * CFG.FlySpeed or Vector3.zero
end)

local function applySJ()
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.WalkSpeed = CFG.Speed and CFG.SpeedVal or 16
	hum.JumpPower = CFG.Jump and CFG.JumpVal or 50
end

local function clearE(id)
	if espCache[id] then
		for _, o in pairs(espCache[id]) do
			if typeof(o) == "Instance" and o.Parent then o:Destroy() end
		end
		espCache[id] = nil
	end
end
local function clearAll() for id in pairs(espCache) do clearE(id) end end

local function updESP(plr)
	local char = plr.Character
	if not char then clearE(plr.UserId) return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root or not hum or not meu then clearE(plr.UserId) return end
	local dist = (root.Position - meu.Position).Magnitude
	if not CFG.ESP or dist > CFG.ESPDist then clearE(plr.UserId) return end
	if not espCache[plr.UserId] then espCache[plr.UserId] = {} end
	local c = espCache[plr.UserId]

	if CFG.HL and hum.Health > 0 then
		if not c.hl or not c.hl.Parent then
			local hl = Instance.new("Highlight")
			hl.Adornee = char
			hl.FillColor = CFG.ESPColor
			hl.FillTransparency = 0.72
			hl.OutlineColor = Color3.new(1,1,1)
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = WS
			c.hl = hl
		else
			c.hl.FillColor = CFG.ESPColor
			c.hl.Adornee = char
		end
	elseif c.hl then c.hl:Destroy() c.hl = nil end

	if head and (CFG.Name or CFG.Dist) and hum.Health > 0 then
		if not c.info or not c.info.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = head
			bb.Size = UDim2.new(0, 120, 0, 28)
			bb.StudsOffset = Vector3.new(0, 2.3, 0)
			bb.AlwaysOnTop = true
			bb.Parent = WS
			local lb = Instance.new("TextLabel")
			lb.Size = UDim2.new(1,0,1,0)
			lb.BackgroundTransparency = 1
			lb.Font = Enum.Font.GothamBold
			lb.TextSize = 11
			lb.TextStrokeTransparency = 0.4
			lb.Parent = bb
			c.info, c.lb = bb, lb
		end
		local txt = ""
		if CFG.Name then txt = txt .. (plr.DisplayName ~= "" and plr.DisplayName or plr.Name) end
		if CFG.Dist then txt = txt .. (txt ~= "" and " · " or "") .. math.floor(dist) .. "m" end
		c.lb.Text = txt
		c.lb.TextColor3 = CFG.ESPColor
		c.info.Adornee = head
	elseif c.info then c.info:Destroy() c.info = nil c.lb = nil end

	if CFG.Tool and hum.Health > 0 then
		local items = listAllItems(plr)
		if not c.feet or not c.feet.Parent then
			local bb = Instance.new("BillboardGui")
			bb.Adornee = root
			bb.Size = UDim2.new(0, 70, 0, 18)
			bb.StudsOffset = Vector3.new(0, -2.5, 0)
			bb.AlwaysOnTop = true
			bb.Parent = WS
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,1,0)
			frame.BackgroundColor3 = Color3.fromRGB(10, 9, 8)
			frame.BackgroundTransparency = 0.4
			frame.BorderSizePixel = 0
			frame.Parent = bb
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
			local list = Instance.new("TextLabel")
			list.Size = UDim2.new(1, -3, 1, -1)
			list.Position = UDim2.new(0, 2, 0, 0)
			list.BackgroundTransparency = 1
			list.TextColor3 = Color3.fromRGB(230, 225, 215)
			list.Font = Enum.Font.Gotham
			list.TextSize = 8
			list.TextXAlignment = Enum.TextXAlignment.Left
			list.TextWrapped = true
			list.Parent = frame
			c.feet, c.feetList = bb, list
		end
		c.feetList.Text = #items > 0 and table.concat(items, " · ") or "-"
		c.feet.Size = UDim2.new(0, 70, 0, math.clamp(14 + math.ceil(#items / 2) * 7, 16, 32))
		c.feet.Adornee = root
	elseif c.feet then
		c.feet:Destroy()
		c.feet, c.feetList = nil, nil
	end
end

local function clearContent()
	for _, ch in ipairs(content:GetChildren()) do ch:Destroy() end
end

local function openTab(name)
	clearContent()
	for n, b in pairs(tabs) do
		b.BackgroundColor3 = (n == name) and C.Accent or C.Card
		b.TextColor3 = (n == name) and Color3.new(1,1,1) or C.Dim
	end
	local y = 2
	if name == "PvP" then
		y = rowSlider(content, "FOV", y, CFG.FOV, 30, 400, function(v)
			CFG.FOV = v fovF.Size = UDim2.new(0, v*2, 0, v*2)
		end)
		y = rowSlider(content, "Distancia players", y, CFG.MaxDist, 20, 500, function(v) CFG.MaxDist = v end)
		y = rowSlider(content, "Suavidade (menor = mais forte)", y, math.floor(CFG.Smooth*100), 2, 40, function(v) CFG.Smooth = v/100 end)
		y = rowToggle(content, "Mostrar FOV", y, CFG.ShowFOV, function(v) CFG.ShowFOV = v fovF.Visible = v end)
		y = rowToggle(content, "Aimbot", y, CFG.Aimbot, function(v) CFG.Aimbot = v end)
		y = rowToggle(content, "Silent Aim", y, CFG.Silent, function(v) CFG.Silent = v end)
		y = rowToggle(content, "Revistar + pegar TUDO", y, CFG.AutoRevistar, function(v) CFG.AutoRevistar = v end)
		y = rowToggle(content, "Teleport + Loot no kill", y, CFG.TPKill, function(v) CFG.TPKill = v end)
		y = rowToggle(content, "Fly", y, CFG.Fly, function(v) setFly(v) end)
		y = rowSlider(content, "Velocidade Fly", y, CFG.FlySpeed, 20, 500, function(v) CFG.FlySpeed = v end)
	elseif name == "ESP" then
		y = rowToggle(content, "ESP ativo", y, CFG.ESP, function(v) CFG.ESP = v if not v then clearAll() end end)
		y = rowSlider(content, "Distancia ESP", y, CFG.ESPDist, 50, 2000, function(v) CFG.ESPDist = v end)
		y = rowToggle(content, "Highlight", y, CFG.HL, function(v) CFG.HL = v end)
		y = rowToggle(content, "Nome", y, CFG.Name, function(v) CFG.Name = v end)
		y = rowToggle(content, "Distancia", y, CFG.Dist, function(v) CFG.Dist = v end)
		y = rowToggle(content, "Itens nos pes (mini)", y, CFG.Tool, function(v) CFG.Tool = v end)
	elseif name == "Player" then
		y = rowToggle(content, "Noclip", y, CFG.Noclip, function(v) setNoclip(v) end)
		y = rowToggle(content, "Velocidade", y, CFG.Speed, function(v) CFG.Speed = v applySJ() end)
		y = rowSlider(content, "Valor velocidade", y, CFG.SpeedVal, 16, 100, function(v) CFG.SpeedVal = v applySJ() end)
		y = rowToggle(content, "Pulo alto", y, CFG.Jump, function(v) CFG.Jump = v applySJ() end)
		y = rowSlider(content, "Valor pulo", y, CFG.JumpVal, 50, 200, function(v) CFG.JumpVal = v applySJ() end)
		y = rowToggle(content, "Claridade total", y, CFG.Fullbright, function(v)
			CFG.Fullbright = v
			if v then
				Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 1e5 Lighting.GlobalShadows = false
			else
				Lighting.Brightness = 1 Lighting.GlobalShadows = true
			end
		end)
	else
		y = rowToggle(content, "Sair ao morrer", y, CFG.QuitDeath, function(v) CFG.QuitDeath = v end)
	end
end

for n, b in pairs(tabs) do
	b.MouseButton1Click:Connect(function() openTab(n) end)
end
openTab("PvP")

top.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag = true d0 = i.Position p0 = main.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - d0
		main.Position = UDim2.new(p0.X.Scale, p0.X.Offset+d.X, p0.Y.Scale, p0.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

local function vis(v) menuOn = v main.Visible = v openBtn.Visible = not v end
xBtn.MouseButton1Click:Connect(function() vis(false) end)
openBtn.MouseButton1Click:Connect(function() vis(true) end)

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightShift then vis(not menuOn) end
	if i.UserInputType == Enum.UserInputType.MouseButton2 then holdAim = true end
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		local _, p = findTarget(true)
		if p then markVictim(p) end
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then holdAim = false end
end)

LP.CharacterAdded:Connect(function()
	if flyBV then flyBV:Destroy() flyBV = nil end
	if nConn then nConn:Disconnect() nConn = nil end
	task.wait(0.4)
	if CFG.Noclip then setNoclip(true) end
	if CFG.Fly then setFly(true) end
	applySJ()
end)

local last = 0
RunService.RenderStepped:Connect(function()
	fovF.Visible = CFG.ShowFOV
	if tick() - last > 0.3 then
		last = tick()
		if CFG.ESP then
			local seen = {}
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP then seen[plr.UserId] = true updESP(plr) end
			end
			for id in pairs(espCache) do if not seen[id] then clearE(id) end end
		else clearAll() end
	end
	if (CFG.Aimbot or CFG.Silent) and holdAim then
		local part, plr = findTarget(CFG.Silent)
		if plr then markVictim(plr) end
		if part then aim(part) end
	end
end)

print("[Tigrinho] loot profissional")
notify("Tigrinho - loot profissional")
