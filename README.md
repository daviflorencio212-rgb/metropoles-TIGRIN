 --[[ TIGRINHO - loot UI real + TP seguro (anti ban) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local WS = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChat = game:GetService("TextChatService")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VIM = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera
local mobile = UIS.TouchEnabled
local SENHA = "tigrinho"
local ARMAS = {
"UMP45","FAL","M9 Beretta","Desert Eagle","Revolver","G17","Draco",
"g18","tec9","shorty","aa-12","spas-12","ar15","mp7","famas","p90",
"mac-10","m4","scar","thompson","ak47","ak47-m","awm","ak-urso",
}
local function isArmaName(name)
local low = string.lower(tostring(name or ""))
for _, a in ipairs(ARMAS) do
if string.find(low, string.lower(a), 1, true) then return true end
end
return false
end
local CFG = {
Aimbot = false, Silent = false, ShowFOV = false,
FOV = 140, Smooth = 0.08, MaxDist = 200,
ESP = false, HL = true, Name = true, Dist = true, Tool = true,
ESPDist = 500, ESPColor = Color3.fromRGB(255, 145, 40),
Noclip = false, Fly = false, FlySpeed = 60,
Speed = false, SpeedVal = 24, Jump = false, JumpVal = 60,
Fullbright = false, TPKill = false,
InfAmmo = false, InfJump = false, InfStamina = false,
AntiAFK = false, XRay = false, TriggerBot = false, StickyAim = false,
-- anti ban
KillCooldown = 12, -- segundos min entre TP+loot automatico
SoftTP = true, -- TP leve (1 vez), sem BodyPosition spam
}
local CONFIG_FILE = "TigrinhoConfig.json"
local function saveConfig()
pcall(function() if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end end)
pcall(function() StarterGui:SetCore("SendNotification",{Title="Tigrinho",Text="Config salva",Duration=2}) end)
end
local function loadConfig()
pcall(function()
if isfile and isfile(CONFIG_FILE) then
local d = HttpService:JSONDecode(readfile(CONFIG_FILE))
for k,v in pairs(d) do if CFG[k] ~= nil then CFG[k] = v end end
end
end)
end
local holdAim, menuOn = false, true
local drag, d0, p0 = false, nil, nil
local nConn, flyBV, espCache = nil, nil, {}
local looting, lootLockUntil = false, 0
local myVictim, myVictimAt = nil, 0
local lastKillLoot = 0
local C = {
Bg = Color3.fromRGB(16,15,14), Side = Color3.fromRGB(22,20,18),
Card = Color3.fromRGB(30,27,24), Bar = Color3.fromRGB(45,40,35),
Accent = Color3.fromRGB(255,145,40), Soft = Color3.fromRGB(255,175,90),
Text = Color3.fromRGB(250,246,240), Dim = Color3.fromRGB(155,145,135), Off = Color3.fromRGB(50,46,42),
}
local function notify(t)
pcall(function() StarterGui:SetCore("SendNotification",{Title="Tigrinho",Text=t,Duration=2.5}) end)
end
local function markVictim(p)
if p and p ~= LP then myVictim = p myVictimAt = tick() end
end
local parent = LP:WaitForChild("PlayerGui")
pcall(function() if gethui then parent = gethui() end end)
pcall(function()
for _,v in pairs(parent:GetChildren()) do
if v.Name=="Tigrinho" or v.Name=="TigrinhoLock" then v:Destroy() end
end
end)
-- SENHA
local lockGui = Instance.new("ScreenGui")
lockGui.Name = "TigrinhoLock"
lockGui.ResetOnSpawn = false
lockGui.IgnoreGuiInset = true
lockGui.DisplayOrder = 2000
lockGui.Parent = parent
local lockBg = Instance.new("Frame")
lockBg.Size = UDim2.new(1,0,1,0)
lockBg.BackgroundColor3 = Color3.fromRGB(8,8,10)
lockBg.BackgroundTransparency = 0.25
lockBg.BorderSizePixel = 0
lockBg.Parent = lockGui
local lockBox = Instance.new("Frame")
lockBox.Size = UDim2.new(0, mobile and 280 or 320, 0, 200)
lockBox.Position = UDim2.new(0.5, mobile and -140 or -160, 0.5, -100)
lockBox.BackgroundColor3 = C.Bg
lockBox.BorderSizePixel = 0
lockBox.Parent = lockGui
Instance.new("UICorner", lockBox).CornerRadius = UDim.new(0,16)
Instance.new("UIStroke", lockBox).Color = C.Accent
local lockTitle = Instance.new("TextLabel")
lockTitle.Size = UDim2.new(1,-20,0,36)
lockTitle.Position = UDim2.new(0,10,0,16)
lockTitle.BackgroundTransparency = 1
lockTitle.Text = "TIGRINHO"
lockTitle.TextColor3 = C.Accent
lockTitle.Font = Enum.Font.GothamBlack
lockTitle.TextSize = 20
lockTitle.Parent = lockBox
local lockSub = Instance.new("TextLabel")
lockSub.Size = UDim2.new(1,-20,0,22)
lockSub.Position = UDim2.new(0,10,0,52)
lockSub.BackgroundTransparency = 1
lockSub.Text = "Digite a senha para abrir"
lockSub.TextColor3 = C.Dim
lockSub.Font = Enum.Font.Gotham
lockSub.TextSize = 13
lockSub.Parent = lockBox
local passBox = Instance.new("TextBox")
passBox.Size = UDim2.new(1,-40,0,36)
passBox.Position = UDim2.new(0,20,0,88)
passBox.BackgroundColor3 = C.Card
passBox.Text = ""
passBox.PlaceholderText = "Senha..."
passBox.TextColor3 = C.Text
passBox.PlaceholderColor3 = C.Dim
passBox.Font = Enum.Font.Gotham
passBox.TextSize = 14
passBox.Parent = lockBox
Instance.new("UICorner", passBox).CornerRadius = UDim.new(0,8)
local unlockBtn = Instance.new("TextButton")
unlockBtn.Size = UDim2.new(1,-40,0,36)
unlockBtn.Position = UDim2.new(0,20,0,136)
unlockBtn.BackgroundColor3 = C.Accent
unlockBtn.Text = "ENTRAR"
unlockBtn.Font = Enum.Font.GothamBold
unlockBtn.TextSize = 14
unlockBtn.TextColor3 = Color3.new(1,1,1)
unlockBtn.Parent = lockBox
Instance.new("UICorner", unlockBtn).CornerRadius = UDim.new(0,8)
local errLabel = Instance.new("TextLabel")
errLabel.Size = UDim2.new(1,-20,0,20)
errLabel.Position = UDim2.new(0,10,1,-28)
errLabel.BackgroundTransparency = 1
errLabel.Text = ""
errLabel.TextColor3 = Color3.fromRGB(255,90,90)
errLabel.Font = Enum.Font.Gotham
errLabel.TextSize = 11
errLabel.Parent = lockBox
local function buildHub() end
local function tryUnlock()
local dig = string.lower(tostring(passBox.Text or ""):gsub("%s+",""))
if dig == SENHA then
lockGui:Destroy()
pcall(loadConfig)
buildHub()
notify("Hub liberado")
else
errLabel.Text = "Senha errada — entre em contato comigo"
passBox.Text = ""
end
end
unlockBtn.MouseButton1Click:Connect(tryUnlock)
passBox.FocusLost:Connect(function(e) if e then tryUnlock() end end)
function buildHub()
local gui = Instance.new("ScreenGui")
gui.Name = "Tigrinho"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = parent
local fovF = Instance.new("Frame")
fovF.AnchorPoint = Vector2.new(0.5,0.5)
fovF.Position = UDim2.new(0.5,0,0.5,0)
fovF.Size = UDim2.new(0,CFG.FOV*2,0,CFG.FOV*2)
fovF.BackgroundTransparency = 1
fovF.Visible = false
fovF.Parent = gui
Instance.new("UICorner", fovF).CornerRadius = UDim.new(1,0)
local fs = Instance.new("UIStroke", fovF)
fs.Color = C.Accent
fs.Thickness = 1.5
fs.Transparency = 0.4
local W,H = mobile and 350 or 500, mobile and 420 or 410
local main = Instance.new("Frame")
main.Size = UDim2.new(0,W,0,H)
main.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
main.BackgroundColor3 = C.Bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,42)
top.BackgroundColor3 = C.Side
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0,18)
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1,0,0,14)
topFix.Position = UDim2.new(0,0,1,-14)
topFix.BackgroundColor3 = C.Side
topFix.BorderSizePixel = 0
topFix.Parent = top
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,16,0,0)
title.BackgroundTransparency = 1
title.Text = "TIGRINHO"
title.TextColor3 = C.Accent
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top
local xBtn = Instance.new("TextButton")
xBtn.Size = UDim2.new(0,30,0,30)
xBtn.Position = UDim2.new(1,-36,0.5,-15)
xBtn.BackgroundColor3 = Color3.fromRGB(40,35,30)
xBtn.Text = "×"
xBtn.TextColor3 = C.Dim
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 18
xBtn.Parent = top
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,8)
local sideW = mobile and 0 or 108
local side = Instance.new("Frame")
side.Size = UDim2.new(0,sideW,1,-42)
side.Position = UDim2.new(0,0,0,42)
side.BackgroundColor3 = C.Side
side.BorderSizePixel = 0
side.Visible = not mobile
side.Parent = main
local mTabs = Instance.new("Frame")
mTabs.Size = UDim2.new(1,-12,0,34)
mTabs.Position = UDim2.new(0,6,0,48)
mTabs.BackgroundTransparency = 1
mTabs.Visible = mobile
mTabs.Parent = main
local ml = Instance.new("UIListLayout", mTabs)
ml.FillDirection = Enum.FillDirection.Horizontal
ml.Padding = UDim.new(0,4)
local contentY = mobile and 88 or 50
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, mobile and -14 or -(sideW+14), 1, -(contentY+10))
content.Position = UDim2.new(0, mobile and 7 or sideW+8, 0, contentY)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = C.Accent
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,46,0,46)
openBtn.Position = UDim2.new(0,14,1,-64)
openBtn.BackgroundColor3 = C.Accent
openBtn.Text = "T"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 18
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Visible = false
openBtn.ZIndex = 20
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
local revBtn = Instance.new("TextButton")
revBtn.Size = UDim2.new(0, mobile and 130 or 120, 0, mobile and 42 or 38)
revBtn.Position = UDim2.new(0,14,0, mobile and 170 or 150)
revBtn.BackgroundColor3 = C.Accent
revBtn.Text = "REVISTAR"
revBtn.Font = Enum.Font.GothamBold
revBtn.TextSize = 13
revBtn.TextColor3 = Color3.new(1,1,1)
revBtn.ZIndex = 100
revBtn.Parent = gui
Instance.new("UICorner", revBtn).CornerRadius = UDim.new(0,10)
local tabs = {}
local function addTab(name, order)
if mobile then
local b = Instance.new("TextButton")
b.Size = UDim2.new(0,70,0,30)
b.BackgroundColor3 = C.Card
b.Text = name
b.Font = Enum.Font.GothamMedium
b.TextSize = 10
b.TextColor3 = C.Dim
b.Parent = mTabs
Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)
tabs[name] = b
else
local b = Instance.new("TextButton")
b.Size = UDim2.new(1,-14,0,34)
b.Position = UDim2.new(0,7,0,10+(order-1)*40)
b.BackgroundColor3 = C.Card
b.Text = " "..name
b.Font = Enum.Font.GothamMedium
b.TextSize = 12
b.TextColor3 = C.Dim
b.TextXAlignment = Enum.TextXAlignment.Left
b.Parent = side
Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
tabs[name] = b
end
end
addTab("⚔ PvP",1) addTab("🔫 Arma",2) addTab("👁 ESP",3) addTab("👤 Player",4) addTab("⚙ Config",5)
local function rowToggle(parent, text, y, def, cb)
local f = Instance.new("Frame")
f.Size = UDim2.new(1,-2,0,34)
f.Position = UDim2.new(0,1,0,y)
f.BackgroundColor3 = C.Card
f.BorderSizePixel = 0
f.Parent = parent
Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
local lb = Instance.new("TextLabel")
lb.Size = UDim2.new(1,-58,1,0)
lb.Position = UDim2.new(0,14,0,0)
lb.BackgroundTransparency = 1
lb.Text = text
lb.TextColor3 = C.Text
lb.Font = Enum.Font.Gotham
lb.TextSize = 12
lb.TextXAlignment = Enum.TextXAlignment.Left
lb.Parent = f
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,42,0,22)
btn.Position = UDim2.new(1,-50,0.5,-11)
btn.BackgroundColor3 = def and C.Accent or C.Off
btn.Text = ""
btn.Parent = f
Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0,16,0,16)
dot.Position = def and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
dot.BackgroundColor3 = Color3.new(1,1,1)
dot.BorderSizePixel = 0
dot.Parent = btn
Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
local st = def
btn.MouseButton1Click:Connect(function()
st = not st
btn.BackgroundColor3 = st and C.Accent or C.Off
dot.Position = st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
cb(st)
end)
return y + 40
end
local function rowSlider(parent, text, y, def, min, max, cb)
local f = Instance.new("Frame")
f.Size = UDim2.new(1,-2,0,48)
f.Position = UDim2.new(0,1,0,y)
f.BackgroundColor3 = C.Card
f.BorderSizePixel = 0
f.Parent = parent
Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
local lb = Instance.new("TextLabel")
lb.Size = UDim2.new(0.7,0,0,18)
lb.Position = UDim2.new(0,14,0,6)
lb.BackgroundTransparency = 1
lb.Text = text
lb.TextColor3 = C.Text
lb.Font = Enum.Font.Gotham
lb.TextSize = 12
lb.TextXAlignment = Enum.TextXAlignment.Left
lb.Parent = f
local vl = Instance.new("TextLabel")
vl.Size = UDim2.new(0.25,-8,0,18)
vl.Position = UDim2.new(0.72,0,0,6)
vl.BackgroundTransparency = 1
vl.Text = tostring(def)
vl.TextColor3 = C.Soft
vl.Font = Enum.Font.GothamBold
vl.TextSize = 12
vl.TextXAlignment = Enum.TextXAlignment.Right
vl.Parent = f
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,-28,0,6)
bg.Position = UDim2.new(0,14,0,32)
bg.BackgroundColor3 = C.Bar
bg.BorderSizePixel = 0
bg.Parent = f
Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
local bar = Instance.new("Frame")
bar.Size = UDim2.new(math.clamp((def-min)/(max-min),0,1),0,1,0)
bar.BackgroundColor3 = C.Accent
bar.BorderSizePixel = 0
bar.Parent = bg
Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
local sliding = false
local function upd(inp)
local rel = math.clamp((inp.Position.X-bg.AbsolutePosition.X)/math.max(bg.AbsoluteSize.X,1),0,1)
local v = math.floor(min+(max-min)*rel)
bar.Size = UDim2.new(rel,0,1,0)
vl.Text = tostring(v)
cb(v)
end
bg.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true upd(i) end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
end)
UIS.InputChanged:Connect(function(i)
if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
end)
return y + 54
end
local function rowInput(parent, placeholder, y, cb)
local f = Instance.new("Frame")
f.Size = UDim2.new(1,-2,0,36)
f.Position = UDim2.new(0,1,0,y)
f.BackgroundColor3 = C.Card
f.BorderSizePixel = 0
f.Parent = parent
Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
local box = Instance.new("TextBox")
box.Size = UDim2.new(0.62,-8,1,-8)
box.Position = UDim2.new(0,8,0,4)
box.BackgroundColor3 = C.Bar
box.PlaceholderText = placeholder
box.Text = ""
box.TextColor3 = C.Text
box.PlaceholderColor3 = C.Dim
box.Font = Enum.Font.Gotham
box.TextSize = 12
box.Parent = f
Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.32,-8,1,-8)
btn.Position = UDim2.new(0.66,0,0,4)
btn.BackgroundColor3 = C.Accent
btn.Text = "TP"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.TextColor3 = Color3.new(1,1,1)
btn.Parent = f
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
btn.MouseButton1Click:Connect(function() cb(box.Text) end)
return y + 42
end
local function rowButton(parent, text, y, cb)
local b = Instance.new("TextButton")
b.Size = UDim2.new(1,-2,0,34)
b.Position = UDim2.new(0,1,0,y)
b.BackgroundColor3 = C.Accent
b.Text = text
b.Font = Enum.Font.GothamBold
b.TextSize = 13
b.TextColor3 = Color3.new(1,1,1)
b.Parent = parent
Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
b.MouseButton1Click:Connect(cb)
return y + 40
end
-- ===== TP LEVE (anti ban) =====
-- 1 CFrame so. SEM BodyPosition, SEM loop Heartbeat, SEM PlatformStand
local function softTP(pos)
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return end
-- se ja esta perto (<12 studs), nao TP (menos flag)
if (root.Position - pos).Magnitude < 12 then
return
end
root.CFrame = CFrame.new(pos)
root.AssemblyLinearVelocity = Vector3.zero
end
local function tpParaNome(nome)
nome = tostring(nome or ""):gsub("^%s+",""):gsub("%s+$","")
if nome == "" then notify("Digite o nome") return end
local low = string.lower(nome)
local alvo
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP then
if string.lower(plr.Name)==low or string.lower(plr.DisplayName)==low
or string.find(string.lower(plr.Name),low,1,true)
or string.find(string.lower(plr.DisplayName),low,1,true) then
alvo = plr break
end
end
end
if not alvo or not alvo.Character then notify("Nao encontrado") return end
local r = alvo.Character:FindFirstChild("HumanoidRootPart") or alvo.Character:FindFirstChild("Head")
if not r then return end
softTP(r.Position + Vector3.new(0,3,0))
notify("TP → "..alvo.Name)
end
local function sDist(pos)
local sp,on = Cam:WorldToViewportPoint(pos)
if not on or sp.Z < 0 then return 999999 end
return (Vector2.new(sp.X,sp.Y)-Cam.ViewportSize/2).Magnitude
end
local function findTarget(noFov)
local lim = noFov and 999999 or CFG.FOV
local bestPos, bd, bestP = nil, lim, nil
local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not meu then return nil,nil end
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and plr.Character then
local hum = plr.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
local p = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
if p and (p.Position-meu.Position).Magnitude <= CFG.MaxDist*8 then
local d = sDist(p.Position)
if d < bd then bd=d bestPos=p.Position bestP=plr end
end
end
end
end
return bestPos, bestP
end
local function getNearestPlayer()
local best, bd = nil, 200
local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not meu then return nil end
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and plr.Character then
local p = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
if p then
local d = (p.Position - meu.Position).Magnitude
if d < bd then bd=d best=plr end
end
end
end
return best
end
local function aimAt(pos)
if not pos then return end
local s = CFG.Silent and 0.99 or math.clamp(1-CFG.Smooth,0.55,0.98)
if CFG.StickyAim then s = math.max(s,0.9) end
Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, pos), s)
end
local function enviarChat(msg)
pcall(function()
local ch = TextChat:FindFirstChild("TextChannels")
if ch then
local g = ch:FindFirstChild("RBXGeneral") or ch:FindFirstChild("General")
if g then g:SendAsync(msg) end
end
end)
pcall(function() LP:Chat(msg) end)
end
local function clickGui(obj)
if not obj then return end
pcall(function()
if getconnections then
for _, n in ipairs({"MouseButton1Click","Activated","MouseButton1Down"}) do
local ok, sig = pcall(function() return obj[n] end)
if ok and sig then
for _, c in pairs(getconnections(sig)) do
pcall(function()
if c.Fire then c:Fire()
elseif c.Function then c.Function() end
end)
end
end
end
end
end)
pcall(function() if obj:IsA("GuiButton") then obj:Activate() end end)
pcall(function()
if VIM and obj:IsA("GuiObject") then
local a,s = obj.AbsolutePosition, obj.AbsoluteSize
if s.X > 2 and s.Y > 2 then
local x,y = a.X+s.X/2, a.Y+s.Y/2
VIM:SendMouseMoveEvent(x,y,game)
task.wait(0.02)
VIM:SendMouseButtonEvent(x,y,0,true,game,1)
task.wait(0.04)
VIM:SendMouseButtonEvent(x,y,0,false,game,1)
end
end
end)
end
local function findFinalizar()
local pg = LP:FindFirstChild("PlayerGui")
if not pg then return nil end
for _, o in ipairs(pg:GetDescendants()) do
if o:IsA("TextButton") and string.find(string.lower(tostring(o.Text or "")),"finalizar") then
return o
end
end
return nil
end
local function getWindow()
local fin = findFinalizar()
if not fin then return nil end
local w = fin
for _=1,12 do
if w.Parent and w.Parent:IsA("GuiObject") then w=w.Parent else break end
end
return w
end
local function listArmas(plr)
local t,s = {},{}
local function add(n)
if n and isArmaName(n) and not s[n] then s[n]=true table.insert(t,n) end
end
if plr and plr.Character then
for _,o in ipairs(plr.Character:GetChildren()) do if o:IsA("Tool") then add(o.Name) end end
end
if plr then
local bp = plr:FindFirstChild("Backpack")
if bp then for _,o in ipairs(bp:GetChildren()) do if o:IsA("Tool") then add(o.Name) end end end
end
return t
end
--[[
  FLUXO PROFISSIONAL:
  1. Garante distancia (TP leve 1x se precisar)
  2. Manda /revistar UMA vez (+ retry se UI nao abrir)
  3. ESPERA a tela Revistamento
  4. Clica cada slot de item
  5. Finalizar
  SEM spam de 50 remotes (isso tambem flag)
]]
local function pegarTudo(target, fromKill)
if looting and tick() < lootLockUntil then
return
end
if not target then return end
-- anti ban: cooldown entre kills
if fromKill then
if tick() - lastKillLoot < (CFG.KillCooldown or 12) then
notify("Cooldown loot ("..math.ceil((CFG.KillCooldown or 12)-(tick()-lastKillLoot)).."s)")
return
end
lastKillLoot = tick()
end
looting = true
lootLockUntil = tick() + 15
task.spawn(function()
pcall(function()
local nome = target.Name
print("[Tigrinho] revistar UI →", nome)
-- distancia: so TP se longe
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local tr = target.Character and (target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Head"))
if root and tr then
local dist = (root.Position - tr.Position).Magnitude
if dist > 14 then
softTP(tr.Position + Vector3.new(0, 2.5, 0))
task.wait(0.35) -- deixa o server aceitar a posicao
end
end
-- chat (principal)
enviarChat("/revistar "..nome)
task.wait(0.5)
-- remote oficial (poucas tentativas, sem spam)
local remote
pcall(function()
remote = RS.shared and RS.shared.Eventos and RS.shared.Eventos.revisar_function
end)
if not remote then
pcall(function() remote = RS:FindFirstChild("revisar_function", true) end)
end
if remote then
pcall(function() remote:InvokeServer(target) end)
pcall(function() remote:InvokeServer(nome) end)
end
-- ESPERA a tela aparecer (ate ~6s)
local window
for i = 1, 50 do
window = getWindow()
if window then break end
-- retry chat 1x no meio
if i == 15 then
enviarChat("/revistar "..nome)
end
task.wait(0.12)
end
if not window then
notify("Tela de revistar nao abriu")
print("[Tigrinho] UI nao abriu")
looting = false
return
end
notify("Tela aberta — pegando itens")
print("[Tigrinho] UI aberta, clicando")
-- clica itens enquanto a tela existir
local t0 = tick()
while tick() - t0 < 8 do
local win = getWindow()
if not win then break end
for _, o in ipairs(win:GetDescendants()) do
if (o:IsA("TextButton") or o:IsA("ImageButton")) and o.Visible then
local t = string.lower(tostring(o.Text or ""))
if not string.find(t,"finalizar")
and not string.find(t,"fechar")
and not string.find(t,"cancel") then
clickGui(o)
task.wait(0.05)
end
elseif o:IsA("TextLabel") and isArmaName(o.Text) then
local host = o:FindFirstAncestorWhichIsA("TextButton")
or o:FindFirstAncestorWhichIsA("ImageButton")
if host then
clickGui(host)
task.wait(0.05)
end
end
end
task.wait(0.1)
end
-- Finalizar
task.wait(0.15)
local fin = findFinalizar()
if fin then
clickGui(fin)
task.wait(0.1)
clickGui(fin)
end
notify("Revistamento concluido")
end)
looting = false
end)
task.delay(16, function() looting = false end)
end
revBtn.MouseButton1Click:Connect(function()
local t = getNearestPlayer()
if not t then notify("Ninguem perto") return end
pegarTudo(t, false)
end)
-- KILL: cooldown + TP leve + UI
local function onDeath(plr, char)
if not CFG.TPKill then return end
if plr ~= myVictim then return end
if tick() - myVictimAt > 20 then return end
-- anti ban cooldown
if tick() - lastKillLoot < (CFG.KillCooldown or 12) then
notify("Kill loot em cooldown")
myVictim = nil
return
end
local r = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
if not r then return end
-- TP leve 1x (sem lock)
softTP(r.Position + Vector3.new(0, 2.5, 0))
task.delay(0.55, function()
pegarTudo(plr, true)
end)
myVictim = nil
end
local function watchDeath(plr)
local function hook(char)
local hum = char:WaitForChild("Humanoid",5)
if not hum then return end
hum.Died:Connect(function() onDeath(plr, char) end)
end
if plr.Character then hook(plr.Character) end
plr.CharacterAdded:Connect(hook)
end
for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then watchDeath(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr~=LP then watchDeath(plr) end end)
local function setNoclip(on)
CFG.Noclip = on
if nConn then nConn:Disconnect() nConn=nil end
local char = LP.Character
if not char then return end
if on then
nConn = RunService.Stepped:Connect(function()
local c = LP.Character
if not c then return end
for _,p in ipairs(c:GetDescendants()) do
if p:IsA("BasePart") then p.CanCollide=false end
end
end)
else
for _,p in ipairs(char:GetDescendants()) do
if p:IsA("BasePart") then p.CanCollide=(p.Name~="HumanoidRootPart") end
end
end
end
local function setFly(on)
CFG.Fly = on
if flyBV then pcall(function() flyBV:Destroy() end) flyBV=nil end
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not on then
if root then root.AssemblyLinearVelocity=Vector3.zero end
return
end
if not root then return end
flyBV = Instance.new("BodyVelocity")
flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
flyBV.Parent = root
end
RunService.RenderStepped:Connect(function()
if not CFG.Fly then
if flyBV then flyBV:Destroy() flyBV=nil end
return
end
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return end
if not flyBV or not flyBV.Parent then
flyBV = Instance.new("BodyVelocity")
flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
flyBV.Parent = root
end
local dir,cf = Vector3.zero, Cam.CFrame
if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
flyBV.Velocity = dir.Magnitude>0 and dir.Unit*CFG.FlySpeed or Vector3.zero
end)
local function applySJ()
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if not hum then return end
hum.WalkSpeed = CFG.Speed and CFG.SpeedVal or 16
hum.JumpPower = CFG.Jump and CFG.JumpVal or 50
end
RunService.Heartbeat:Connect(function()
if not CFG.InfAmmo then return end
local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
if not tool then return end
for _,v in ipairs(tool:GetDescendants()) do
local n = string.lower(v.Name)
if (string.find(n,"ammo") or string.find(n,"clip") or string.find(n,"bullet") or string.find(n,"muni"))
and (v:IsA("IntValue") or v:IsA("NumberValue")) then
pcall(function() v.Value=9999 end)
end
end
end)
RunService.Heartbeat:Connect(function()
if not CFG.InfStamina then return end
local char = LP.Character
if not char then return end
for _,v in ipairs(char:GetDescendants()) do
local n = string.lower(v.Name)
if string.find(n,"stamina") or string.find(n,"energy") then
if v:IsA("NumberValue") or v:IsA("IntValue") then pcall(function() v.Value=100 end) end
end
end
end)
UIS.JumpRequest:Connect(function()
if not CFG.InfJump then return end
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
local afkConn
local function setAntiAFK(on)
CFG.AntiAFK = on
if afkConn then afkConn:Disconnect() afkConn=nil end
if on then
afkConn = RunService.Heartbeat:Connect(function()
pcall(function()
local vu=game:GetService("VirtualUser")
vu:CaptureController()
vu:ClickButton2(Vector2.new())
end)
end)
end
end
local function setXRay(on)
CFG.XRay = on
for _,p in ipairs(WS:GetDescendants()) do
if p:IsA("BasePart") and not p:IsDescendantOf(LP.Character) then
if on then
if not p:GetAttribute("TigTX") then p:SetAttribute("TigTX",p.LocalTransparencyModifier) end
if p.Transparency<0.5 then p.LocalTransparencyModifier=0.55 end
else
local old=p:GetAttribute("TigTX")
if old~=nil then p.LocalTransparencyModifier=old p:SetAttribute("TigTX",nil) end
end
end
end
end
local function clearE(id)
if espCache[id] then
for _,o in pairs(espCache[id]) do if typeof(o)=="Instance" and o.Parent then o:Destroy() end end
espCache[id]=nil
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
local dist = (root.Position-meu.Position).Magnitude
if not CFG.ESP or dist > CFG.ESPDist then clearE(plr.UserId) return end
if not espCache[plr.UserId] then espCache[plr.UserId]={} end
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
else c.hl.FillColor=CFG.ESPColor c.hl.Adornee=char end
elseif c.hl then c.hl:Destroy() c.hl=nil end
if head and (CFG.Name or CFG.Dist) then
if not c.info or not c.info.Parent then
local bb = Instance.new("BillboardGui")
bb.Adornee = head
bb.Size = UDim2.new(0,100,0,22)
bb.StudsOffset = Vector3.new(0,2.2,0)
bb.AlwaysOnTop = true
bb.Parent = WS
local lb = Instance.new("TextLabel")
lb.Size = UDim2.new(1,0,1,0)
lb.BackgroundTransparency = 1
lb.Font = Enum.Font.GothamBold
lb.TextSize = 10
lb.TextStrokeTransparency = 0.45
lb.Parent = bb
c.info, c.lb = bb, lb
end
local txt = ""
if CFG.Name then txt = txt..(plr.DisplayName~="" and plr.DisplayName or plr.Name) end
if CFG.Dist then txt = txt..(txt~="" and " " or "")..math.floor(dist).."m" end
c.lb.Text = txt
c.lb.TextColor3 = CFG.ESPColor
elseif c.info then c.info:Destroy() c.info=nil c.lb=nil end
if CFG.Tool then
local armas = listArmas(plr)
local show = {}
for i=1, math.min(3,#armas) do table.insert(show, armas[i]) end
if not c.feet or not c.feet.Parent then
local bb = Instance.new("BillboardGui")
bb.Adornee = root
bb.Size = UDim2.new(0,90,0,28)
bb.StudsOffset = Vector3.new(0,-2.3,0)
bb.AlwaysOnTop = true
bb.Parent = WS
local list = Instance.new("TextLabel")
list.Size = UDim2.new(1,0,1,0)
list.BackgroundTransparency = 0.5
list.BackgroundColor3 = Color3.fromRGB(0,0,0)
list.TextColor3 = Color3.fromRGB(255,200,120)
list.Font = Enum.Font.GothamBold
list.TextSize = 8
list.TextXAlignment = Enum.TextXAlignment.Center
list.TextWrapped = true
list.Parent = bb
Instance.new("UICorner", list).CornerRadius = UDim.new(0,4)
c.feet, c.feetList = bb, list
end
if #show > 0 then
c.feetList.Text = table.concat(show, "\n")
c.feet.Size = UDim2.new(0,90,0,8+#show*10)
c.feet.Enabled = true
else
c.feet.Enabled = false
end
c.feet.Adornee = root
elseif c.feet then
c.feet:Destroy()
c.feet, c.feetList = nil, nil
end
end
local function clearContent()
for _,ch in ipairs(content:GetChildren()) do ch:Destroy() end
end
local function openTab(name)
clearContent()
for n,b in pairs(tabs) do
b.BackgroundColor3 = (n==name) and C.Accent or C.Card
b.TextColor3 = (n==name) and Color3.new(1,1,1) or C.Dim
end
local y = 2
if name == "⚔ PvP" then
y = rowSlider(content,"FOV",y,CFG.FOV,30,400,function(v) CFG.FOV=v fovF.Size=UDim2.new(0,v*2,0,v*2) end)
y = rowSlider(content,"Suavidade",y,math.floor(CFG.Smooth*100),2,40,function(v) CFG.Smooth=v/100 end)
y = rowToggle(content,"Mostrar FOV",y,CFG.ShowFOV,function(v) CFG.ShowFOV=v fovF.Visible=v end)
y = rowToggle(content,"Aimbot",y,CFG.Aimbot,function(v) CFG.Aimbot=v end)
y = rowToggle(content,"Silent Aim",y,CFG.Silent,function(v) CFG.Silent=v end)
y = rowToggle(content,"Sticky Aim",y,CFG.StickyAim,function(v) CFG.StickyAim=v end)
y = rowToggle(content,"Triggerbot",y,CFG.TriggerBot,function(v) CFG.TriggerBot=v end)
y = rowToggle(content,"TP + Loot kill (seguro)",y,CFG.TPKill,function(v) CFG.TPKill=v end)
y = rowSlider(content,"Cooldown kill loot (s)",y,CFG.KillCooldown,5,30,function(v) CFG.KillCooldown=v end)
y = rowToggle(content,"Fly",y,CFG.Fly,function(v) setFly(v) end)
y = rowSlider(content,"Velocidade Fly",y,CFG.FlySpeed,20,500,function(v) CFG.FlySpeed=v end)
elseif name == "🔫 Arma" then
y = rowToggle(content,"Municao infinita",y,CFG.InfAmmo,function(v) CFG.InfAmmo=v end)
y = rowToggle(content,"Stamina infinita",y,CFG.InfStamina,function(v) CFG.InfStamina=v end)
elseif name == "👁 ESP" then
y = rowToggle(content,"ESP ativo",y,CFG.ESP,function(v) CFG.ESP=v if not v then clearAll() end end)
y = rowSlider(content,"Distancia ESP",y,CFG.ESPDist,50,2000,function(v) CFG.ESPDist=v end)
y = rowToggle(content,"Highlight",y,CFG.HL,function(v) CFG.HL=v end)
y = rowToggle(content,"Nome",y,CFG.Name,function(v) CFG.Name=v end)
y = rowToggle(content,"Distancia",y,CFG.Dist,function(v) CFG.Dist=v end)
y = rowToggle(content,"Armas (max 3)",y,CFG.Tool,function(v) CFG.Tool=v end)
y = rowToggle(content,"XRay",y,CFG.XRay,function(v) setXRay(v) end)
elseif name == "👤 Player" then
y = rowToggle(content,"Noclip",y,CFG.Noclip,function(v) setNoclip(v) end)
y = rowToggle(content,"Velocidade",y,CFG.Speed,function(v) CFG.Speed=v applySJ() end)
y = rowSlider(content,"Valor velocidade",y,CFG.SpeedVal,16,100,function(v) CFG.SpeedVal=v applySJ() end)
y = rowToggle(content,"Pulo alto",y,CFG.Jump,function(v) CFG.Jump=v applySJ() end)
y = rowSlider(content,"Valor pulo",y,CFG.JumpVal,50,200,function(v) CFG.JumpVal=v applySJ() end)
y = rowToggle(content,"Pulo infinito",y,CFG.InfJump,function(v) CFG.InfJump=v end)
y = rowToggle(content,"Claridade total",y,CFG.Fullbright,function(v)
CFG.Fullbright=v
if v then Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=1e5 Lighting.GlobalShadows=false
else Lighting.Brightness=1 Lighting.GlobalShadows=true end
end)
else
y = rowInput(content,"Nome do player p/ TP",y,tpParaNome)
y = rowButton(content,"SALVAR CONFIG",y,saveConfig)
y = rowButton(content,"CARREGAR CONFIG",y,function() loadConfig() openTab("⚙ Config") end)
y = rowToggle(content,"Anti AFK",y,CFG.AntiAFK,function(v) setAntiAFK(v) end)
end
end
for n,b in pairs(tabs) do b.MouseButton1Click:Connect(function() openTab(n) end) end
openTab("⚔ PvP")
top.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
drag=true d0=i.Position p0=main.Position
end
end)
UIS.InputChanged:Connect(function(i)
if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
local d=i.Position-d0
main.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)
local function vis(v) menuOn=v main.Visible=v openBtn.Visible=not v end
xBtn.MouseButton1Click:Connect(function() vis(false) end)
openBtn.MouseButton1Click:Connect(function() vis(true) end)
UIS.InputBegan:Connect(function(i,gp)
if gp then return end
if i.KeyCode==Enum.KeyCode.RightShift then vis(not menuOn) end
if i.UserInputType==Enum.UserInputType.MouseButton2 then holdAim=true end
if i.UserInputType==Enum.UserInputType.MouseButton1 then
local _,p=findTarget(true)
if p then markVictim(p) end
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton2 then holdAim=false end
end)
LP.CharacterAdded:Connect(function()
if flyBV then flyBV:Destroy() flyBV=nil end
if nConn then nConn:Disconnect() nConn=nil end
task.wait(0.4)
if CFG.Noclip then setNoclip(true) end
if CFG.Fly then setFly(true) end
applySJ()
end)
local last=0
RunService.RenderStepped:Connect(function()
fovF.Visible=CFG.ShowFOV
if tick()-last>0.3 then
last=tick()
if CFG.ESP then
local seen={}
for _,plr in ipairs(Players:GetPlayers()) do
if plr~=LP then seen[plr.UserId]=true updESP(plr) end
end
for id in pairs(espCache) do if not seen[id] then clearE(id) end end
else clearAll() end
end
if (CFG.Aimbot or CFG.Silent or CFG.StickyAim) and holdAim then
local pos,plr=findTarget(CFG.Silent)
if plr then markVictim(plr) end
if pos then aimAt(pos) end
end
end)
print("[Tigrinho] UI revistar + TP seguro")
end
print("[Tigrinho] senha: tigrinho") tenta ajeita esse auto revistar POR FAVOR !! E outra bota o noclip também pra mim poder ativar na letra 0
