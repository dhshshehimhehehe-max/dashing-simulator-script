-- AutoFarm Hub (Tabbed UI) - paste as LocalScript in StarterPlayerScripts or run in executor
-- Works with workspace.CollectableOrbs and workspace.Flowers, reconnects after respawn.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old UI if present
local old = playerGui:FindFirstChild("AutoFarmHub")
if old then old:Destroy() end

-- Respawn-safe HRP
local Character = player.Character or player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	Character = char
	HRP = Character:WaitForChild("HumanoidRootPart")
	print("[AutoFarmHub] Reconnected HRP after respawn.")
end)

-- tween helper for GUI/HRP
local function safeTween(obj, props, time, style, dir)
	local ok, err = pcall(function()
		local t = TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
		t:Play()
		t.Completed:Wait()
	end)
	if not ok then warn("Tween error:", err) end
end

-- build UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 360, 0, 480)
Main.Position = UDim2.new(0.5, -180, 0.5, -240) -- centered
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", Main); mainCorner.CornerRadius = UDim.new(0,10)

-- titlebar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,44)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
local tbCorner = Instance.new("UICorner", TitleBar); tbCorner.CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🌿 AutoFarm Hub"
Title.TextColor3 = Color3.fromRGB(235,235,235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- minimize & close
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0,32,0,28)
MinBtn.Position = UDim2.new(1, -88, 0, 8)
MinBtn.Text = "━"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 20
MinBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
MinBtn.TextColor3 = Color3.fromRGB(230,230,230)
local minCorner = Instance.new("UICorner", MinBtn); minCorner.CornerRadius = UDim.new(0,6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,32,0,28)
CloseBtn.Position = UDim2.new(1, -44, 0, 8)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.BackgroundColor3 = Color3.fromRGB(175,40,40)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
local closeCorner = Instance.new("UICorner", CloseBtn); closeCorner.CornerRadius = UDim.new(0,6)

-- tabs row
local TabsFrame = Instance.new("Frame", Main)
TabsFrame.Size = UDim2.new(1, -20, 0, 40)
TabsFrame.Position = UDim2.new(0,10,0,54)
TabsFrame.BackgroundTransparency = 1

local function makeTab(name, x)
	local btn = Instance.new("TextButton", TabsFrame)
	btn.Size = UDim2.new(0, 150, 1, 0)
	btn.Position = UDim2.new(0, x, 0, 0)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 16
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.fromRGB(240,240,240)
	btn.AutoButtonColor = true
	local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
	return btn
end

local TabOrbs = makeTab("🌐 Orbs", 0)
local TabFlowers = makeTab("🌸 Flowers", 160)

-- content container
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -120)
Content.Position = UDim2.new(0,10,0,100)
Content.BackgroundTransparency = 1

-- top controls for active tab (farm all toggle)
local TopControls = Instance.new("Frame", Content)
TopControls.Size = UDim2.new(1,0,0,36)
TopControls.Position = UDim2.new(0,0,0,0)
TopControls.BackgroundTransparency = 1

local FarmAllBtn = Instance.new("TextButton", TopControls)
FarmAllBtn.Size = UDim2.new(0, 150, 0, 32)
FarmAllBtn.Position = UDim2.new(0,0,0,2)
FarmAllBtn.Text = "Farm All: OFF"
FarmAllBtn.Font = Enum.Font.SourceSansSemibold
FarmAllBtn.TextSize = 14
FarmAllBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
FarmAllBtn.TextColor3 = Color3.fromRGB(240,240,240)
local farmAllCorner = Instance.new("UICorner", FarmAllBtn); farmAllCorner.CornerRadius = UDim.new(0,6)

-- Scroll area
local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1,0,1,-40)
Scroll.Position = UDim2.new(0,0,0,40)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 9
Scroll.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,6)

-- footer hint
local Hint = Instance.new("TextLabel", Main)
Hint.Size = UDim2.new(1, -20, 0, 36)
Hint.Position = UDim2.new(0, 10, 1, -46)
Hint.BackgroundTransparency = 1
Hint.Text = "Click items to toggle. Use Farm All to continuously farm entire tab. Drag title to move. Minimize to tiny box."
Hint.TextColor3 = Color3.fromRGB(200,200,200)
Hint.Font = Enum.Font.SourceSans
Hint.TextSize = 12
Hint.TextXAlignment = Enum.TextXAlignment.Left

-- mini box for minimize
local MiniBox = Instance.new("TextButton", ScreenGui)
MiniBox.Size = UDim2.new(0, 52, 0, 52)
MiniBox.Position = UDim2.new(0.02, 0, 0.8, 0)
MiniBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
MiniBox.Text = "☘"
MiniBox.TextColor3 = Color3.fromRGB(255,255,255)
MiniBox.Font = Enum.Font.SourceSansBold
MiniBox.TextSize = 24
MiniBox.Visible = false
local miniCorner = Instance.new("UICorner", MiniBox); miniCorner.CornerRadius = UDim.new(0,10)

-- data structures
local Toggles = { Orbs = {}, Flowers = {} }
local FarmAll = { Orbs = false, Flowers = false }
local ActiveTab = "Orbs"

-- helper to detect part inside model
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

-- create list item UI
local function makeListItem(folderName, model)
	if not model then return end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.96, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.fromRGB(245,245,245)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 14
	btn.AutoButtonColor = true
	btn.Text = string.format("%s • %s", folderName, tostring(model.Name))
	local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)
	btn.Parent = Scroll

	-- initial toggle storage
	Toggles[folderName][model.Name] = false

	btn.MouseButton1Click:Connect(function()
		Toggles[folderName][model.Name] = not Toggles[folderName][model.Name]
		local col = Toggles[folderName][model.Name] and Color3.fromRGB(0,200,100) or Color3.fromRGB(50,50,50)
		safeTween(btn, {BackgroundColor3 = col}, 0.18)
	end)

	return btn
end

-- populate lists
local function populate()
	-- clear children (except layout)
	for _, v in ipairs(Scroll:GetChildren()) do
		if v ~= Layout then pcall(function() v:Destroy() end) end
	end

	-- populate according to active tab (but we create all items and users can switch)
	local orbsFolder = workspace:FindFirstChild("CollectableOrbs")
	if orbsFolder then
		for _, m in ipairs(orbsFolder:GetChildren()) do
			if not Toggles.Orbs[m.Name] then -- avoid recreating if re-populate called
				makeListItem("Orbs", m)
			else
				-- still ensure an entry exists (UI might be destroyed)
				makeListItem("Orbs", m)
			end
		end
	end

	local flowersFolder = workspace:FindFirstChild("Flowers")
	if flowersFolder then
		for _, m in ipairs(flowersFolder:GetChildren()) do
			if not Toggles.Flowers[m.Name] then
				makeListItem("Flowers", m)
			else
				makeListItem("Flowers", m)
			end
		end
	end

	-- update canvas size (UIList auto size not always immediate)
	task.wait(0.05)
	local total = 0
	for _, child in ipairs(Scroll:GetChildren()) do
		if child:IsA("GuiObject") and child ~= Layout then
			total = total + child.AbsoluteSize.Y + Layout.Padding.Offset
		end
	end
	Scroll.CanvasSize = UDim2.new(0,0,0, total)
end

-- initial populate
populate()

-- show only items matching active tab by toggling visibility
local function refreshTabView()
	for _, child in ipairs(Scroll:GetChildren()) do
		if child ~= Layout then
			if child.Text:sub(1,4) == "Orbs" then
				child.Visible = (ActiveTab == "Orbs")
			elseif child.Text:sub(1,7) == "Flowers" then
				child.Visible = (ActiveTab == "Flowers")
			end
		end
	end
end
refreshTabView()

-- switch tab handlers
TabOrbs.MouseButton1Click:Connect(function()
	ActiveTab = "Orbs"
	TabOrbs.BackgroundColor3 = Color3.fromRGB(70,70,70)
	TabFlowers.BackgroundColor3 = Color3.fromRGB(50,50,50)
	refreshTabView()
end)
TabFlowers.MouseButton1Click:Connect(function()
	ActiveTab = "Flowers"
	TabFlowers.BackgroundColor3 = Color3.fromRGB(70,70,70)
	TabOrbs.BackgroundColor3 = Color3.fromRGB(50,50,50)
	refreshTabView()
end)

-- farm-all toggle: toggles continuous farming for current tab type
FarmAllBtn.MouseButton1Click:Connect(function()
	FarmAll[ActiveTab] = not FarmAll[ActiveTab]
	FarmAllBtn.Text = "Farm All: " .. (FarmAll[ActiveTab] and "ON" or "OFF")
	FarmAllBtn.BackgroundColor3 = FarmAll[ActiveTab] and Color3.fromRGB(0,160,80) or Color3.fromRGB(70,70,70)
end)

-- minimize behavior
local storedPos, storedSize = Main.Position, Main.Size
MinBtn.MouseButton1Click:Connect(function()
	if not MiniBox.Visible then
		storedPos, storedSize = Main.Position, Main.Size
		MiniBox.Position = UDim2.new(0, Main.AbsolutePosition.X, 0, Main.AbsolutePosition.Y)
		MiniBox.Visible = true
		Main.Visible = false
	else
		 -- restore
		Main.Position = storedPos
		Main.Size = storedSize
		Main.Visible = true
		MiniBox.Visible = false
	end
end)

MiniBox.MouseButton1Click:Connect(function()
	if MiniBox.Visible then
		Main.Position = storedPos
		Main.Size = storedSize
		Main.Visible = true
		MiniBox.Visible = false
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- allow dragging by TitleBar
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

-- core movement function
local function moveToPart(part)
	if not part or not HRP then return end
	local ok, err = pcall(function()
		local distance = (HRP.Position - part.Position).Magnitude
		local speed = 300
		local t = math.clamp(distance / speed, 0.12, 2)
		local tween = TweenService:Create(HRP, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0,3,0)})
		tween:Play()
		tween.Completed:Wait()
	end)
	if not ok then warn("moveToPart error:", err) end
end

-- main farming worker (respects FarmAll and manual selections)
task.spawn(function()
	while true do
		task.wait(0.18)
		-- gather targets
		local work = {}

		-- if FarmAll.Orbs is on, add all orbs
		if FarmAll.Orbs then
			local f = workspace:FindFirstChild("CollectableOrbs")
			if f then
				for _, m in ipairs(f:GetChildren()) do
					local part = getTargetPart(m)
					if part and HRP then table.insert(work, {part = part, dist = (part.Position - HRP.Position).Magnitude}) end
				end
			end
		else
			for name, on in pairs(Toggles.Orbs) do
				if on then
					local f = workspace:FindFirstChild("CollectableOrbs")
					if f then
						local m = f:FindFirstChild(name)
						if m then
							local part = getTargetPart(m)
							if part and HRP then table.insert(work, {part = part, dist = (part.Position - HRP.Position).Magnitude}) end
						end
					end
				end
			end
		end

		-- Flowers
		if FarmAll.Flowers then
			local f = workspace:FindFirstChild("Flowers")
			if f then
				for _, m in ipairs(f:GetChildren()) do
					local part = getTargetPart(m)
					if part and HRP then table.insert(work, {part = part, dist = (part.Position - HRP.Position).Magnitude}) end
				end
			end
		else
			for name, on in pairs(Toggles.Flowers) do
				if on then
					local f = workspace:FindFirstChild("Flowers")
					if f then
						local m = f:FindFirstChild(name)
						if m then
							local part = getTargetPart(m)
							if part and HRP then table.insert(work, {part = part, dist = (part.Position - HRP.Position).Magnitude}) end
						end
					end
				end
			end
		end

		-- sort by distance, visit nearest few
		if #work > 0 then
			table.sort(work, function(a,b) return a.dist < b.dist end)
			for i = 1, math.min(#work, 6) do
				local item = work[i]
				if item and item.part then
					pcall(function()
						moveToPart(item.part)
						task.wait(0.12 + math.random() * 0.25)
					end)
				end
			end
		end
	end
end)

print("[AutoFarmHub] Ready. Centered, draggable titlebar, tabbed UI, minimize->tiny box enabled.")
