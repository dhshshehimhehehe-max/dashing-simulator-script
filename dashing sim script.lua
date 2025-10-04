-- AutoFarm Hub v5 — Final (with instant auto-refresh)
-- Paste as LocalScript in StarterPlayerScripts (recommended)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player refs
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old UI if present
local existing = playerGui:FindFirstChild("AutoFarmHub_v5")
if existing then existing:Destroy() end

-- Respawn-safe HRP
local Character = player.Character or player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(char)
	task.wait(0.6)
	Character = char
	HRP = Character:WaitForChild("HumanoidRootPart")
	print("[AutoFarmHub] Reconnected HRP after respawn.")
end)

-- Helpers
local function safeTween(instance, props, time, style, dir)
	local ok, err = pcall(function()
		local tween = TweenService:Create(instance, TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
		tween:Play()
		tween.Completed:Wait()
	end)
	if not ok then warn("[AutoFarmHub] Tween error:", err) end
end

local function getTargetPart(model)
	if not model then return nil end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			local n = d.Name:lower()
			if n == "small" or n == "main" or n == "flower" or n == "hitbox" then
				return d
			end
		end
	end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
	return nil
end

-- UI root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmHub_v5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container (fixed size, centered)
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 200)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(22,22,22)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", Main); mainCorner.CornerRadius = UDim.new(0,10)

-- Open animation
Main.Size = UDim2.new(0, 10, 0, 10)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundTransparency = 1
safeTween(Main, {Size = UDim2.new(0, 300, 0, 200), BackgroundTransparency = 0}, 0.26, Enum.EasingStyle.Back)

-- Title bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
local tbCorner = Instance.new("UICorner", TitleBar); tbCorner.CornerRadius = UDim.new(0,10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0.6, -8, 1, 0)
TitleLabel.Position = UDim2.new(0,8,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Auto Farm Hub v5"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(235,235,235)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize & Close
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0,28,0,24)
MinBtn.Position = UDim2.new(1, -64, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(70,18,18)
MinBtn.Text = "━"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(240,240,240)
local MinCorner = Instance.new("UICorner", MinBtn); MinCorner.CornerRadius = UDim.new(0,6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,28,0,24)
CloseBtn.Position = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150,20,20)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
local CloseCorner = Instance.new("UICorner", CloseBtn); CloseCorner.CornerRadius = UDim.new(0,6)

-- Tabs row
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1, -16, 0, 34)
Tabs.Position = UDim2.new(0,8,0,44)
Tabs.BackgroundTransparency = 1

local function createTabBtn(text, x)
	local btn = Instance.new("TextButton", Tabs)
	btn.Size = UDim2.new(0,88,1,0)
	btn.Position = UDim2.new(0, x, 0, 0)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(50,12,12)
	btn.TextColor3 = Color3.fromRGB(240,240,240)
	btn.AutoButtonColor = true
	local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
	return btn
end

local TabOrbs = createTabBtn("🔮 Orbs", 0)
local TabFlowers = createTabBtn("🌸 Flowers", 96)
local TabChests = createTabBtn("💰 Chests", 192)

-- Content area (sliding panels)
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -16, 1, -92)
ContentArea.Position = UDim2.new(0,8,0,84)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true

local function makePanel(offsetIndex)
	local p = Instance.new("Frame", ContentArea)
	p.Size = UDim2.new(1, 0, 1, 0)
	p.Position = UDim2.new(offsetIndex, 0, 0, 0)
	p.BackgroundTransparency = 1
	return p
end

local PanelOrbs = makePanel(0)
local PanelFlowers = makePanel(1)
local PanelChests = makePanel(2)

local function makeTopControls(parent)
	local f = Instance.new("Frame", parent)
	f.Size = UDim2.new(1, 0, 0, 34)
	f.Position = UDim2.new(0, 0, 0, 0)
	f.BackgroundTransparency = 1
	return f
end

local TopOrbs = makeTopControls(PanelOrbs)
local TopFlowers = makeTopControls(PanelFlowers)

local function makeFarmAllBtn(parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,140,0,28)
	b.Position = UDim2.new(0,0,0,3)
	b.Text = "Farm All: OFF"
	b.Font = Enum.Font.SourceSansSemibold
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(85,12,12)
	b.TextColor3 = Color3.fromRGB(240,240,240)
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,6)
	return b
end

local FarmAllOrbsBtn = makeFarmAllBtn(TopOrbs)
local FarmAllFlowersBtn = makeFarmAllBtn(TopFlowers)

-- Scrolling lists
local function makeScroll(parent, topOffset)
	local scr = Instance.new("ScrollingFrame", parent)
	scr.Size = UDim2.new(1,0,1,-topOffset)
	scr.Position = UDim2.new(0,0,0,topOffset)
	scr.BackgroundTransparency = 1
	scr.ScrollBarThickness = 8
	local layout = Instance.new("UIListLayout", scr)
	layout.Padding = UDim.new(0,6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	return scr
end

local OrbsScroll = makeScroll(PanelOrbs, 38)
local FlowersScroll = makeScroll(PanelFlowers, 38)
local ChestsScroll = makeScroll(PanelChests, 10)

-- Data storage
local Toggles = { Orbs = {}, Flowers = {} }
local FarmAll = { Orbs = false, Flowers = false }

-- Functions to add/remove list items while preserving toggles
local function updateCanvas(scroll)
	task.wait(0.02)
	local total = 0
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") and child.ClassName ~= "UIListLayout" then
			total = total + child.AbsoluteSize.Y + 6
		end
	end
	scroll.CanvasSize = UDim2.new(0,0,0, math.max(0, total))
end

local function makeListItem(scroll, folderName, model)
	-- avoid duplicate UI for same model
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("• "..tostring(model.Name)) then
			return child
		end
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.96, 0, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(44,44,44)
	btn.TextColor3 = Color3.fromRGB(240,240,240)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 14
	btn.AutoButtonColor = true
	btn.Text = string.format("%s • %s", folderName, tostring(model.Name))
	local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)
	btn.Parent = scroll

	-- preserve previous state if exists
	if Toggles[folderName][model.Name] == nil then
		Toggles[folderName][model.Name] = false
	end

	-- apply color if active
	if Toggles[folderName][model.Name] then
		btn.BackgroundColor3 = Color3.fromRGB(0,190,100)
	end

	btn.MouseButton1Click:Connect(function()
		Toggles[folderName][model.Name] = not Toggles[folderName][model.Name]
		local active = Toggles[folderName][model.Name]
		local color = active and Color3.fromRGB(0,190,100) or Color3.fromRGB(44,44,44)
		safeTween(btn, {BackgroundColor3 = color}, 0.14)
	end)
	return btn
end

local function removeListItem(scroll, folderName, modelName)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") and child.Text:find("• "..tostring(modelName)) then
			child:Destroy()
		end
	end
end

-- Safe get folders
local function safeGetFolder(name)
	local tries = 0
	while tries < 8 do
		local f = workspace:FindFirstChild(name)
		if f then return f end
		tries = tries + 1
		task.wait(0.25)
	end
	return workspace:FindFirstChild(name)
end

local orbsFolder = safeGetFolder("CollectableOrbs")
local flowersFolder = safeGetFolder("Flowers")

-- Populate initial lists
if orbsFolder then
	for _, m in ipairs(orbsFolder:GetChildren()) do
		makeListItem(OrbsScroll, "Orbs", m)
	end
end
if flowersFolder then
	for _, m in ipairs(flowersFolder:GetChildren()) do
		makeListItem(FlowersScroll, "Flowers", m)
	end
end

task.spawn(function()
	task.wait(0.06)
	updateCanvas(OrbsScroll)
	updateCanvas(FlowersScroll)
end)

-- Auto-refresh handlers
local function onOrbAdded(m)
	makeListItem(OrbsScroll, "Orbs", m)
	updateCanvas(OrbsScroll)
end
local function onOrbRemoved(m)
	if m and m.Name then
		removeListItem(OrbsScroll, "Orbs", m.Name)
		Toggles.Orbs[m.Name] = nil
		updateCanvas(OrbsScroll)
	end
end
local function onFlowerAdded(m)
	makeListItem(FlowersScroll, "Flowers", m)
	updateCanvas(FlowersScroll)
end
local function onFlowerRemoved(m)
	if m and m.Name then
		removeListItem(FlowersScroll, "Flowers", m.Name)
		Toggles.Flowers[m.Name] = nil
		updateCanvas(FlowersScroll)
	end
end

-- Connect instant changes
if orbsFolder then
	orbsFolder.ChildAdded:Connect(onOrbAdded)
	orbsFolder.ChildRemoved:Connect(onOrbRemoved)
end
if flowersFolder then
	flowersFolder.ChildAdded:Connect(onFlowerAdded)
	flowersFolder.ChildRemoved:Connect(onFlowerRemoved)
end

-- FarmAll hooks
FarmAllOrbsBtn.MouseButton1Click:Connect(function()
	FarmAll.Orbs = not FarmAll.Orbs
	FarmAllOrbsBtn.Text = "Farm All: " .. (FarmAll.Orbs and "ON" or "OFF")
	FarmAllOrbsBtn.BackgroundColor3 = FarmAll.Orbs and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
end)
FarmAllFlowersBtn.MouseButton1Click:Connect(function()
	FarmAll.Flowers = not FarmAll.Flowers
	FarmAllFlowersBtn.Text = "Farm All: " .. (FarmAll.Flowers and "ON" or "OFF")
	FarmAllFlowersBtn.BackgroundColor3 = FarmAll.Flowers and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
end)

-- Chests tab: teleport buttons (instant)
local function makeChestBtn(parent, label, modelPath)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.96, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(44,44,44)
	btn.TextColor3 = Color3.fromRGB(240,240,240)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 14
	btn.Text = label
	local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)

	btn.MouseButton1Click:Connect(function()
		-- try evaluate path like workspace.Chests["Desert Chest"]
		local model = nil
		local success, res = pcall(function()
			local s = modelPath:gsub("^workspace%.", "")
			local cur = workspace
			for token in s:gmatch("([^.]+)") do
				local name = token
				if name:match('%[".+"]') then
					name = name:match('%["(.+)"]')
				end
				if cur and cur:FindFirstChild(name) then
					cur = cur:FindFirstChild(name)
				else
					cur = nil
					break
				end
			end
			return cur
		end)
		if success and res then model = res end
		if not model then
			warn("[AutoFarmHub] Chest model not found:", modelPath)
			return
		end

		-- resolve cframe
		local targetCFrame = nil
		if model.PrimaryPart then
			targetCFrame = model.PrimaryPart.CFrame
		else
			pcall(function() targetCFrame = model:GetModelCFrame() end)
		end
		if not targetCFrame then
			local p = getTargetPart(model)
			if p then targetCFrame = p.CFrame end
		end
		if not targetCFrame then
			warn("[AutoFarmHub] Could not resolve chest position for:", label)
			return
		end

		-- instant teleport slightly above
		if HRP then
			pcall(function()
				HRP.CFrame = targetCFrame * CFrame.new(0, 5, 0)
			end)
		end
	end)
end

-- Add provided chest buttons
makeChestBtn(ChestsScroll, "Teleport → Desert Chest", 'workspace.Chests["Desert Chest"]')
makeChestBtn(ChestsScroll, "Teleport → Golden Chest", 'workspace.Chests["Golden Chest"]')

-- Sliding panels (animate position)
local panels = {PanelOrbs, PanelFlowers, PanelChests}
local function slideTo(index)
	for i, p in ipairs(panels) do
		local targetX = (i-1) - index
		safeTween(p, {Position = UDim2.new(targetX, 0, 0, 0)}, 0.28, Enum.EasingStyle.Quart)
	end
end

-- Initial tab visuals
local current = 0
TabOrbs.BackgroundColor3 = Color3.fromRGB(85,12,12)
TabFlowers.BackgroundColor3 = Color3.fromRGB(50,12,12)
TabChests.BackgroundColor3 = Color3.fromRGB(50,12,12)
slideTo(0)

TabOrbs.MouseButton1Click:Connect(function()
	current = 0
	TabOrbs.BackgroundColor3 = Color3.fromRGB(85,12,12)
	TabFlowers.BackgroundColor3 = Color3.fromRGB(50,12,12)
	TabChests.BackgroundColor3 = Color3.fromRGB(50,12,12)
	slideTo(0)
end)
TabFlowers.MouseButton1Click:Connect(function()
	current = 1
	TabFlowers.BackgroundColor3 = Color3.fromRGB(85,12,12)
	TabOrbs.BackgroundColor3 = Color3.fromRGB(50,12,12)
	TabChests.BackgroundColor3 = Color3.fromRGB(50,12,12)
	slideTo(1)
end)
TabChests.MouseButton1Click:Connect(function()
	current = 2
	TabChests.BackgroundColor3 = Color3.fromRGB(85,12,12)
	TabOrbs.BackgroundColor3 = Color3.fromRGB(50,12,12)
	TabFlowers.BackgroundColor3 = Color3.fromRGB(50,12,12)
	slideTo(2)
end)

-- Minimize / MiniBox
local storedPos = Main.Position
local storedAnchor = Main.AnchorPoint
local minimized = false
local MiniBox = Instance.new("TextButton", ScreenGui)
MiniBox.Name = "MiniBox"
MiniBox.Size = UDim2.new(0, 40, 0, 40)
MiniBox.Position = UDim2.new(0.02, 0, 0.8, 0)
MiniBox.BackgroundColor3 = Color3.fromRGB(70,18,18)
MiniBox.Text = "☘"
MiniBox.Font = Enum.Font.SourceSansBold
MiniBox.TextSize = 22
MiniBox.TextColor3 = Color3.fromRGB(255,255,255)
MiniBox.Visible = false
local miniCorner = Instance.new("UICorner", MiniBox); miniCorner.CornerRadius = UDim.new(0,8)

MinBtn.MouseButton1Click:Connect(function()
	if not minimized then
		storedPos = Main.Position
		Main.Visible = false
		MiniBox.Visible = true
		minimized = true
	else
		Main.Position = storedPos
		Main.Visible = true
		MiniBox.Visible = false
		minimized = false
	end
end)

MiniBox.MouseButton1Click:Connect(function()
	if minimized then
		Main.Position = storedPos
		Main.Visible = true
		MiniBox.Visible = false
		minimized = false
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Dragging (titlebar moves Main; miniBox draggable)
local function makeDraggable(dragGui, targetGui)
	targetGui = targetGui or dragGui
	local dragging, dragStart, startPos = false, nil, nil
	dragGui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetGui.Position
			local conn
			conn = UserInputService.InputChanged:Connect(function(inp)
				if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = inp.Position - dragStart
					targetGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if conn then conn:Disconnect() end
				end
			end)
		end
	end)
end
makeDraggable(TitleBar, Main)
makeDraggable(MiniBox, MiniBox)

-- Movement helper (tween HRP to part)
local function moveToPart(part)
	if not part or not HRP then return end
	local ok, err = pcall(function()
		local dist = (HRP.Position - part.Position).Magnitude
		local speed = 280
		local t = math.clamp(dist / speed, 0.12, 1.8)
		local tween = TweenService:Create(HRP, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, 3, 0)})
		tween:Play()
		tween.Completed:Wait()
	end)
	if not ok then warn("[AutoFarmHub] moveToPart error:", err) end
end

-- Main farming loop (respects FarmAll and manual Toggles)
task.spawn(function()
	while true do
		task.wait(0.22)
		local work = {}

		-- ORBS
		local orbs = workspace:FindFirstChild("CollectableOrbs")
		if orbs then
			if FarmAll.Orbs then
				for _, m in ipairs(orbs:GetChildren()) do
					local p = getTargetPart(m)
					if p and HRP then table.insert(work, {part = p, dist = (p.Position - HRP.Position).Magnitude}) end
				end
			else
				for name, on in pairs(Toggles.Orbs) do
					if on then
						local m = orbs:FindFirstChild(name)
						if m then
							local p = getTargetPart(m)
							if p and HRP then table.insert(work, {part = p, dist = (p.Position - HRP.Position).Magnitude}) end
						end
					end
				end
			end
		end

		-- FLOWERS
		local fls = workspace:FindFirstChild("Flowers")
		if fls then
			if FarmAll.Flowers then
				for _, m in ipairs(fls:GetChildren()) do
					local p = getTargetPart(m)
					if p and HRP then table.insert(work, {part = p, dist = (p.Position - HRP.Position).Magnitude}) end
				end
			else
				for name, on in pairs(Toggles.Flowers) do
					if on then
						local m = fls:FindFirstChild(name)
						if m then
							local p = getTargetPart(m)
							if p and HRP then table.insert(work, {part = p, dist = (p.Position - HRP.Position).Magnitude}) end
						end
					end
				end
			end
		end

		-- visit nearest few
		if #work > 0 then
			table.sort(work, function(a,b) return a.dist < b.dist end)
			for i = 1, math.min(#work, 6) do
				local item = work[i]
				if item and item.part then
					pcall(function()
						moveToPart(item.part)
						task.wait(0.12 + math.random() * 0.26)
					end)
				end
			end
		end
	end
end)

print("[AutoFarmHub_v5] Ready — instant auto-refresh enabled.")
