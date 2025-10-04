-- AutoFarm Hub — fixed full version
-- Paste this as a LocalScript into StarterPlayerScripts (recommended)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player refs
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Respawn-safe HRP
local Character = player.Character or player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(char)
	task.wait(0.6)
	Character = char
	HRP = Character:WaitForChild("HumanoidRootPart")
	print("[AutoFarmHub] Reconnected HRP after respawn.")
end)

-- Helper tween
local function safeTween(obj, props, time, style, dir)
	local ok, err = pcall(function()
		local tw = TweenService:Create(obj, TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
		tw:Play()
		tw.Completed:Wait()
	end)
	if not ok then warn("[AutoFarmHub] Tween error:", err) end
end

-- Find a sensible BasePart inside a model or return the BasePart itself
local function getTargetPart(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		-- prefer common part names
		local names = {"Small","Main","Flower","Big","Toucher","Handle","Base","Part"}
		for _,n in ipairs(names) do
			local v = obj:FindFirstChild(n, true)
			if v and v:IsA("BasePart") then return v end
		end
		-- fallback: first BasePart descendant
		for _,d in ipairs(obj:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
	end
	return nil
end

-- Build UI
local function buildUI()
	-- remove old UI
	local old = playerGui:FindFirstChild("AutoFarmHub_vFinal")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoFarmHub_vFinal"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame (fixed size, centered)
	local Main = Instance.new("Frame", screenGui)
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 400, 0, 320)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.BackgroundColor3 = Color3.fromRGB(24, 10, 10)
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	local mainCorner = Instance.new("UICorner", Main); mainCorner.CornerRadius = UDim.new(0, 10)

	-- TitleBar
	local TitleBar = Instance.new("Frame", Main)
	TitleBar.Size = UDim2.new(1, 0, 0, 36)
	TitleBar.Position = UDim2.new(0, 0, 0, 0)
	TitleBar.BackgroundColor3 = Color3.fromRGB(18, 6, 6)
	local tbCorner = Instance.new("UICorner", TitleBar); tbCorner.CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel", TitleBar)
	Title.Size = UDim2.new(0.7, -8, 1, 0)
	Title.Position = UDim2.new(0, 8, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "Auto Farm Hub"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Color3.fromRGB(240,240,240)
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local MinBtn = Instance.new("TextButton", TitleBar)
	MinBtn.Size = UDim2.new(0, 28, 0, 24)
	MinBtn.Position = UDim2.new(1, -64, 0, 6)
	MinBtn.BackgroundColor3 = Color3.fromRGB(70, 18, 18)
	MinBtn.Text = "━"
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 18
	MinBtn.TextColor3 = Color3.fromRGB(240,240,240)
	local MinCorner = Instance.new("UICorner", MinBtn); MinCorner.CornerRadius = UDim.new(0,6)

	local CloseBtn = Instance.new("TextButton", TitleBar)
	CloseBtn.Size = UDim2.new(0, 28, 0, 24)
	CloseBtn.Position = UDim2.new(1, -32, 0, 6)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 18, 18)
	CloseBtn.Text = "✕"
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
	local CloseCorner = Instance.new("UICorner", CloseBtn); CloseCorner.CornerRadius = UDim.new(0,6)

	-- Tabs row
	local Tabs = Instance.new("Frame", Main)
	Tabs.Size = UDim2.new(1, -16, 0, 34)
	Tabs.Position = UDim2.new(0, 8, 0, 44)
	Tabs.BackgroundTransparency = 1

	local function tabButton(text, x)
		local btn = Instance.new("TextButton", Tabs)
		btn.Size = UDim2.new(0, 120, 1, 0)
		btn.Position = UDim2.new(0, x, 0, 0)
		btn.Text = text
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 14
		btn.BackgroundColor3 = Color3.fromRGB(50, 12, 12)
		btn.TextColor3 = Color3.fromRGB(240,240,240)
		local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
		return btn
	end

	local TabOrbs = tabButton("🔮 Orbs", 0)
	local TabFlowers = tabButton("🌸 Flowers", 124)
	local TabChests = tabButton("💰 Chests", 248)

	-- Content area
	local Content = Instance.new("Frame", Main)
	Content.Size = UDim2.new(1, -16, 1, -92)
	Content.Position = UDim2.new(0, 8, 0, 84)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true

	-- panels
	local function makePanel(x)
		local p = Instance.new("Frame", Content)
		p.Size = UDim2.new(1, 0, 1, 0)
		p.Position = UDim2.new(x, 0, 0, 0)
		p.BackgroundTransparency = 1
		return p
	end
	local PanelOrbs = makePanel(0)
	local PanelFlowers = makePanel(1)
	local PanelChests = makePanel(2)

	-- Top controls for Orbs/Flowers
	local function topControls(panel)
		local top = Instance.new("Frame", panel)
		top.Size = UDim2.new(1, 0, 0, 36)
		top.Position = UDim2.new(0, 0, 0, 0)
		top.BackgroundTransparency = 1

		local FarmToggle = Instance.new("TextButton", top)
		FarmToggle.Size = UDim2.new(0, 140, 0, 28)
		FarmToggle.Position = UDim2.new(0, 0, 0, 4)
		FarmToggle.Text = "Farm: OFF"
		FarmToggle.Font = Enum.Font.GothamBold
		FarmToggle.TextSize = 14
		FarmToggle.BackgroundColor3 = Color3.fromRGB(85,12,12)
		FarmToggle.TextColor3 = Color3.fromRGB(240,240,240)
		local fc = Instance.new("UICorner", FarmToggle); fc.CornerRadius = UDim.new(0,6)

		local ModeBtn = Instance.new("TextButton", top)
		ModeBtn.Size = UDim2.new(0, 120, 0, 28)
		ModeBtn.Position = UDim2.new(0, 150, 0, 4)
		ModeBtn.Text = "Mode: All"
		ModeBtn.Font = Enum.Font.GothamBold
		ModeBtn.TextSize = 14
		ModeBtn.BackgroundColor3 = Color3.fromRGB(85,12,12)
		ModeBtn.TextColor3 = Color3.fromRGB(240,240,240)
		local mc = Instance.new("UICorner", ModeBtn); mc.CornerRadius = UDim.new(0,6)

		local OnlyOnMapBtn = Instance.new("TextButton", top)
		OnlyOnMapBtn.Size = UDim2.new(0, 110, 0, 28)
		OnlyOnMapBtn.Position = UDim2.new(0, 283, 0, 4)
		OnlyOnMapBtn.Text = "Only On Map: OFF"
		OnlyOnMapBtn.Font = Enum.Font.Gotham
		OnlyOnMapBtn.TextSize = 12
		OnlyOnMapBtn.BackgroundColor3 = Color3.fromRGB(85,12,12)
		OnlyOnMapBtn.TextColor3 = Color3.fromRGB(240,240,240)
		local oc = Instance.new("UICorner", OnlyOnMapBtn); oc.CornerRadius = UDim.new(0,6)

		return {
			Root = top,
			FarmToggle = FarmToggle,
			ModeBtn = ModeBtn,
			OnlyOnMapBtn = OnlyOnMapBtn
		}
	end

	local OrbsTop = topControls(PanelOrbs)
	local FlowersTop = topControls(PanelFlowers)

	-- Scroll areas: All items & OnMap items (stacked)
	local function makeScrollArea(parent, topOffset)
		local scr = Instance.new("ScrollingFrame", parent)
		scr.Size = UDim2.new(1, -12, 1, -topOffset - 8)
		scr.Position = UDim2.new(0, 6, 0, topOffset + 6)
		scr.BackgroundTransparency = 1
		scr.ScrollBarThickness = 8
		local layout = Instance.new("UIListLayout", scr)
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		return scr
	end

	local OrbsAllScroll = makeScrollArea(PanelOrbs, 38)
	local OrbsOnMapScroll = makeScrollArea(PanelOrbs, 200) -- smaller; we'll place label for OnMap
	local FlowersAllScroll = makeScrollArea(PanelFlowers, 38)
	local FlowersOnMapScroll = makeScrollArea(PanelFlowers, 200)

	-- label for OnMap sections
	local OrbsOnMapLabel = Instance.new("TextLabel", PanelOrbs)
	OrbsOnMapLabel.Size = UDim2.new(1, -12, 0, 20)
	OrbsOnMapLabel.Position = UDim2.new(0, 6, 0, 180)
	OrbsOnMapLabel.Text = "On Map / Spawned"
	OrbsOnMapLabel.BackgroundTransparency = 1
	OrbsOnMapLabel.TextColor3 = Color3.fromRGB(235,235,235)
	OrbsOnMapLabel.Font = Enum.Font.Gotham
	OrbsOnMapLabel.TextSize = 12

	local FlowersOnMapLabel = Instance.new("TextLabel", PanelFlowers)
	FlowersOnMapLabel.Size = UDim2.new(1, -12, 0, 20)
	FlowersOnMapLabel.Position = UDim2.new(0, 6, 0, 180)
	FlowersOnMapLabel.Text = "On Map / Spawned"
	FlowersOnMapLabel.BackgroundTransparency = 1
	FlowersOnMapLabel.TextColor3 = Color3.fromRGB(235,235,235)
	FlowersOnMapLabel.Font = Enum.Font.Gotham
	FlowersOnMapLabel.TextSize = 12

	-- Toggles storage
	local Toggles = {
		Orbs = {}, -- [name] = boolean
		Flowers = {}
	}
	-- Farm states and modes
	local FarmState = {
		Orbs = {Active = false, Mode = "All", OnlyOnMap = false},
		Flowers = {Active = false, Mode = "All", OnlyOnMap = false}
	}

	-- populate helpers
	local function clearChildrenExceptLayout(scr)
		for _,c in ipairs(scr:GetChildren()) do
			if not c:IsA("UIListLayout") then
				c:Destroy()
			end
		end
	end

	local function makeListEntry(scroll, folderName, model)
		-- avoid duplicates
		for _,child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") and child.Name == ("entry_" .. folderName .. "_" .. tostring(model:GetDebugId())) then
				return child
			end
		end

		local btn = Instance.new("TextButton")
		btn.Name = ("entry_" .. folderName .. "_" .. tostring(model:GetDebugId()))
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = Toggles[folderName][model.Name] and Color3.fromRGB(0,170,90) or Color3.fromRGB(44,44,44)
		btn.TextColor3 = Color3.fromRGB(235,235,235)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 14
		btn.AutoButtonColor = true
		btn.Text = tostring(model.Name)
		local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)
		btn.Parent = scroll

		-- preserve state record when clicking
		if Toggles[folderName][model.Name] == nil then Toggles[folderName][model.Name] = false end
		if Toggles[folderName][model.Name] then
			btn.BackgroundColor3 = Color3.fromRGB(0,170,90)
		end

		btn.MouseButton1Click:Connect(function()
			Toggles[folderName][model.Name] = not Toggles[folderName][model.Name]
			local c = Toggles[folderName][model.Name] and Color3.fromRGB(0,170,90) or Color3.fromRGB(44,44,44)
			safeTween(btn, {BackgroundColor3 = c}, 0.12)
		end)

		return btn
	end

	-- populate a folder into two scrolls (all and onmap)
	local function populateFolder(folderName, allScroll, onMapScroll)
		clearChildrenExceptLayout(allScroll)
		clearChildrenExceptLayout(onMapScroll)

		local folder = workspace:FindFirstChild(folderName)
		if not folder then return end

		for _,child in ipairs(folder:GetChildren()) do
			-- show every model/part in "All" list
			local okModel = child
			makeListEntry(allScroll, folderName, okModel)
			-- if it has a part on-map, add to onMap
			local target = getTargetPart(okModel)
			if target and target:IsDescendantOf(workspace) then
				makeListEntry(onMapScroll, folderName, okModel)
			end
		end

		-- adjust CanvasSize
		task.spawn(function()
			task.wait(0.05)
			local total = 0
			for _,c in ipairs(allScroll:GetChildren()) do
				if c:IsA("GuiObject") and not c:IsA("UIListLayout") then
					total = total + c.AbsoluteSize.Y + 6
				end
			end
			allScroll.CanvasSize = UDim2.new(0,0,0, math.max(1, total))
			-- onmap
			local tot2 = 0
			for _,c in ipairs(onMapScroll:GetChildren()) do
				if c:IsA("GuiObject") and not c:IsA("UIListLayout") then
					tot2 = tot2 + c.AbsoluteSize.Y + 6
				end
			end
			onMapScroll.CanvasSize = UDim2.new(0,0,0, math.max(1, tot2))
		end)
	end

	-- initial populate
	populateFolder("CollectableOrbs", OrbsAllScroll, OrbsOnMapScroll)
	populateFolder("Flowers", FlowersAllScroll, FlowersOnMapScroll)

	-- ChildAdded/Removed handlers for instant refresh
	local orbsFolder = workspace:FindFirstChild("CollectableOrbs")
	local flowersFolder = workspace:FindFirstChild("Flowers")
	if orbsFolder then
		orbsFolder.ChildAdded:Connect(function() populateFolder("CollectableOrbs", OrbsAllScroll, OrbsOnMapScroll) end)
		orbsFolder.ChildRemoved:Connect(function() populateFolder("CollectableOrbs", OrbsAllScroll, OrbsOnMapScroll) end)
	end
	if flowersFolder then
		flowersFolder.ChildAdded:Connect(function() populateFolder("Flowers", FlowersAllScroll, FlowersOnMapScroll) end)
		flowersFolder.ChildRemoved:Connect(function() populateFolder("Flowers", FlowersAllScroll, FlowersOnMapScroll) end)
	end

	-- Farm workers
	local function collectTargetsFromToggles(folderName, onlyOnMap)
		local out = {}
		local folder = workspace:FindFirstChild(folderName)
		if not folder then return out end
		for name,enabled in pairs(Toggles[folderName]) do
			if enabled then
				local m = folder:FindFirstChild(name)
				if m then
					local p = getTargetPart(m)
					if p and (not onlyOnMap or p:IsDescendantOf(workspace)) then
						table.insert(out, p)
					end
				end
			end
		end
		return out
	end

	local function collectAllVisible(folderName, onlyOnMap)
		local out = {}
		local folder = workspace:FindFirstChild(folderName)
		if not folder then return out end
		for _,m in ipairs(folder:GetChildren()) do
			local p = getTargetPart(m)
			if p and (not onlyOnMap or p:IsDescendantOf(workspace)) then
				table.insert(out, p)
			end
		end
		return out
	end

	-- Moves HRP smoothly to target part
	local function tweenToPart(part)
		if not part or not HRP then return end
		local ok, err = pcall(function()
			local dist = (HRP.Position - part.Position).Magnitude
			local speed = 280
			local t = math.clamp(dist / speed, 0.14, 1.6)
			local tw = TweenService:Create(HRP, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, 3, 0)})
			tw:Play()
			tw.Completed:Wait()
		end)
		if not ok then warn("[AutoFarmHub] tween error:", err) end
	end

	-- Orbs worker
	local orbsWorkerRunning = false
	task.spawn(function()
		while true do
			task.wait(0.18)
			if FarmState.Orbs.Active and not orbsWorkerRunning then
				orbsWorkerRunning = true
				task.spawn(function()
					while FarmState.Orbs.Active do
						-- determine targets
						local targets = {}
						if FarmState.Orbs.Mode == "All" then
							-- prefer toggled items if any selected, otherwise all visible
							local toggTargets = collectTargetsFromToggles("Orbs", FarmState.Orbs.OnlyOnMap)
							if #togTargets > 0 then
								targets = toggTargets
							else
								targets = collectAllVisible("CollectableOrbs", FarmState.Orbs.OnlyOnMap)
							end
						else -- Nearest mode
							-- get either toggled or all visible then pick nearest each cycle
							local toggTargets = collectTargetsFromToggles("Orbs", FarmState.Orbs.OnlyOnMap)
							local pool = #togTargets > 0 and toggTargets or collectAllVisible("CollectableOrbs", FarmState.Orbs.OnlyOnMap)
							-- find nearest
							local nearest, nd = nil, nil
							for _,p in ipairs(pool) do
								local d = (HRP.Position - p.Position).Magnitude
								if not nd or d < nd then nd = d; nearest = p end
							end
							if nearest then table.insert(targets, nearest) end
						end

						if #targets > 0 then
							table.sort(targets, function(a,b) return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude end)
							-- visit up to N per pass to avoid long freezes
							local N = 6
							for i = 1, math.min(N, #targets) do
								if not FarmState.Orbs.Active then break end
								local part = targets[i]
								pcall(function()
									tweenToPart(part)
									task.wait(0.12 + math.random() * 0.24)
								end)
							end
						else
							task.wait(0.35)
						end
					end
					orbsWorkerRunning = false
				end)
			end
		end
	end)

	-- Flowers worker (same pattern)
	local flowersWorkerRunning = false
	task.spawn(function()
		while true do
			task.wait(0.18)
			if FarmState.Flowers.Active and not flowersWorkerRunning then
				flowersWorkerRunning = true
				task.spawn(function()
					while FarmState.Flowers.Active do
						local targets = {}
						if FarmState.Flowers.Mode == "All" then
							local toggTargets = collectTargetsFromToggles("Flowers", FarmState.Flowers.OnlyOnMap)
							if #togTargets > 0 then targets = toggTargets else targets = collectAllVisible("Flowers", FarmState.Flowers.OnlyOnMap) end
						else
							local toggTargets = collectTargetsFromToggles("Flowers", FarmState.Flowers.OnlyOnMap)
							local pool = #togTargets > 0 and toggTargets or collectAllVisible("Flowers", FarmState.Flowers.OnlyOnMap)
							local nearest, nd = nil, nil
							for _,p in ipairs(pool) do
								local d = (HRP.Position - p.Position).Magnitude
								if not nd or d < nd then nd = d; nearest = p end
							end
							if nearest then table.insert(targets, nearest) end
						end

						if #targets > 0 then
							table.sort(targets, function(a,b) return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude end)
							local N = 6
							for i = 1, math.min(N, #targets) do
								if not FarmState.Flowers.Active then break end
								local part = targets[i]
								pcall(function()
									tweenToPart(part)
									task.wait(0.12 + math.random() * 0.26)
								end)
							end
						else
							task.wait(0.35)
						end
					end
					flowersWorkerRunning = false
				end)
			end
		end
	end)

	-- Wire up top controls for Orbs
	do
		local state = FarmState.Orbs
		local farmBtn = OrbsTop.FarmToggle
		local modeBtn = OrbsTop.ModeBtn
		local onlyBtn = OrbsTop.OnlyOnMapBtn
		farmBtn.MouseButton1Click:Connect(function()
			state.Active = not state.Active
			farmBtn.Text = "Farm: " .. (state.Active and "ON" or "OFF")
			farmBtn.BackgroundColor3 = state.Active and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
		end)
		modeBtn.MouseButton1Click:Connect(function()
			if state.Mode == "All" then state.Mode = "Nearest" else state.Mode = "All" end
			modeBtn.Text = "Mode: " .. state.Mode
		end)
		onlyBtn.MouseButton1Click:Connect(function()
			state.OnlyOnMap = not state.OnlyOnMap
			onlyBtn.Text = "Only On Map: " .. (state.OnlyOnMap and "ON" or "OFF")
			onlyBtn.BackgroundColor3 = state.OnlyOnMap and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
		end)
	end

	-- Wire up top controls for Flowers
	do
		local state = FarmState.Flowers
		local farmBtn = FlowersTop.FarmToggle
		local modeBtn = FlowersTop.ModeBtn
		local onlyBtn = FlowersTop.OnlyOnMapBtn
		farmBtn.MouseButton1Click:Connect(function()
			state.Active = not state.Active
			farmBtn.Text = "Farm: " .. (state.Active and "ON" or "OFF")
			farmBtn.BackgroundColor3 = state.Active and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
		end)
		modeBtn.MouseButton1Click:Connect(function()
			if state.Mode == "All" then state.Mode = "Nearest" else state.Mode = "All" end
			modeBtn.Text = "Mode: " .. state.Mode
		end)
		onlyBtn.MouseButton1Click:Connect(function()
			state.OnlyOnMap = not state.OnlyOnMap
			onlyBtn.Text = "Only On Map: " .. (state.OnlyOnMap and "ON" or "OFF")
			onlyBtn.BackgroundColor3 = state.OnlyOnMap and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
		end)
	end

	-- Minimize behavior: show MiniBox bottom-left
	local MiniBox = Instance.new("TextButton", screenGui)
	MiniBox.Name = "MiniBox"
	MiniBox.Size = UDim2.new(0, 44, 0, 44)
	MiniBox.Position = UDim2.new(0, 8, 1, -60) -- bottom-left
	MiniBox.BackgroundColor3 = Color3.fromRGB(70,18,18)
	MiniBox.Text = "☘"
	MiniBox.Font = Enum.Font.GothamBold
	MiniBox.TextSize = 22
	MiniBox.TextColor3 = Color3.fromRGB(255,255,255)
	MiniBox.Visible = false
	local miniCorner = Instance.new("UICorner", MiniBox); miniCorner.CornerRadius = UDim.new(0,8)

	MinBtn.MouseButton1Click:Connect(function()
		Main.Visible = false
		MiniBox.Visible = true
	end)
	MiniBox.MouseButton1Click:Connect(function()
		Main.Visible = true
		MiniBox.Visible = false
	end)
	CloseBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

	-- Draggable TitleBar
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

	-- slide panels function
	local panels = {PanelOrbs, PanelFlowers, PanelChests}
	local function slideTo(index)
		for i,p in ipairs(panels) do
			local targetX = (i-1) - index
			safeTween(p, {Position = UDim2.new(targetX, 0, 0, 0)}, 0.26, Enum.EasingStyle.Quart)
		end
	end

	TabOrbs.MouseButton1Click:Connect(function()
		TabOrbs.BackgroundColor3 = Color3.fromRGB(85,12,12)
		TabFlowers.BackgroundColor3 = Color3.fromRGB(50,12,12)
		TabChests.BackgroundColor3 = Color3.fromRGB(50,12,12)
		slideTo(0)
	end)
	TabFlowers.MouseButton1Click:Connect(function()
		TabFlowers.BackgroundColor3 = Color3.fromRGB(85,12,12)
		TabOrbs.BackgroundColor3 = Color3.fromRGB(50,12,12)
		TabChests.BackgroundColor3 = Color3.fromRGB(50,12,12)
		slideTo(1)
	end)
	TabChests.MouseButton1Click:Connect(function()
		TabChests.BackgroundColor3 = Color3.fromRGB(85,12,12)
		TabOrbs.BackgroundColor3 = Color3.fromRGB(50,12,12)
		TabFlowers.BackgroundColor3 = Color3.fromRGB(50,12,12)
		slideTo(2)
	end)

	-- === CHESTS TAB ===
	-- chest definitions & positions (from your values)
	local ChestDefs = {
		Desert = {
			Name = "Desert Chest",
			Pos = Vector3.new(-7867.74951171875, 5.127607822418213, 39.38441467285156),
			Cooldown = 3600,
			Next = 0,
			Auto = false
		},
		Golden = {
			Name = "Golden Chest",
			Pos = Vector3.new(473.45928955078125, 16.08856773376465, -20.129392623901367),
			Cooldown = 900,
			Next = 0,
			Auto = false
		}
	}

	-- build chest UI (vertical)
	local yBase = 6
	for key,info in pairs(ChestDefs) do
		local row = Instance.new("Frame", PanelChests)
		row.Size = UDim2.new(1, -12, 0, 44)
		row.Position = UDim2.new(0, 6, 0, yBase)
		row.BackgroundTransparency = 1

		local nameLabel = Instance.new("TextLabel", row)
		nameLabel.Size = UDim2.new(0.46, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = info.Name
		nameLabel.TextColor3 = Color3.fromRGB(235,235,235)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14

		local timerLabel = Instance.new("TextLabel", row)
		timerLabel.Size = UDim2.new(0.32, 0, 1, 0)
		timerLabel.Position = UDim2.new(0.46, 6, 0, 0)
		timerLabel.BackgroundTransparency = 1
		timerLabel.TextColor3 = Color3.fromRGB(235,235,235)
		timerLabel.Font = Enum.Font.Gotham
		timerLabel.TextSize = 14
		timerLabel.Text = "Ready"

		local autoBtn = Instance.new("TextButton", row)
		autoBtn.Size = UDim2.new(0, 64, 0, 28)
		autoBtn.Position = UDim2.new(0.80, 0, 0, 8)
		autoBtn.Text = "Auto"
		autoBtn.Font = Enum.Font.Gotham
		autoBtn.TextSize = 12
		autoBtn.BackgroundColor3 = Color3.fromRGB(85,12,12)
		autoBtn.TextColor3 = Color3.fromRGB(240,240,240)
		local ac = Instance.new("UICorner", autoBtn); ac.CornerRadius = UDim.new(0,6)

		local tpBtn = Instance.new("TextButton", row)
		tpBtn.Size = UDim2.new(0, 64, 0, 28)
		tpBtn.Position = UDim2.new(0.92, -64, 0, 8)
		tpBtn.Text = "Teleport"
		tpBtn.Font = Enum.Font.Gotham
		tpBtn.TextSize = 12
		tpBtn.BackgroundColor3 = Color3.fromRGB(155,12,12)
		tpBtn.TextColor3 = Color3.fromRGB(240,240,240)
		local tc = Instance.new("UICorner", tpBtn); tc.CornerRadius = UDim.new(0,6)

		-- attach to info for runtime
		info.TimerLabel = timerLabel
		info.AutoBtn = autoBtn

		-- toggle auto
		autoBtn.MouseButton1Click:Connect(function()
			info.Auto = not info.Auto
			autoBtn.BackgroundColor3 = info.Auto and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
		end)

		-- manual teleport
		tpBtn.MouseButton1Click:Connect(function()
			pcall(function()
				HRP.CFrame = CFrame.new(info.Pos + Vector3.new(0,5,0))
				-- start cooldown
				info.Next = os.time() + info.Cooldown
			end)
		end)

		-- inc yBase
		yBase = yBase + 52
	end

	-- chest timer updater & auto-teleport
	task.spawn(function()
		while true do
			for key,info in pairs(ChestDefs) do
				local remain = math.max(0, info.Next - os.time())
				if remain <= 0 then
					info.TimerLabel.Text = "✅ Ready!"
					info.TimerLabel.TextColor3 = Color3.fromRGB(6,180,80)
					-- auto teleport if toggled
					if info.Auto and info.Next > 0 then
						-- teleport when ready
						pcall(function() HRP.CFrame = CFrame.new(info.Pos + Vector3.new(0,5,0)) end)
						-- reset next to cooldown again
						info.Next = os.time() + info.Cooldown
					end
				else
					local m = math.floor(remain / 60)
					local s = remain % 60
					info.TimerLabel.Text = string.format("⏱ %dm %02ds", m, s)
					info.TimerLabel.TextColor3 = Color3.fromRGB(235,235,235)
				end
			end
			task.wait(1)
		end
	end)

	-- expose a manual refresh function
	local function refreshAllLists()
		populateFolder("CollectableOrbs", OrbsAllScroll, OrbsOnMapScroll)
		populateFolder("Flowers", FlowersAllScroll, FlowersOnMapScroll)
	end

	-- initial set active tab
	TabOrbs.BackgroundColor3 = Color3.fromRGB(85,12,12)
	slideTo(0)

	return {
		Refresh = refreshAllLists
	}
end

-- Build UI and get refresh handle
local uiHandle = buildUI()

-- Fallback: periodic refresh (in case ChildAdded didn't connect due to folder creation later)
task.spawn(function()
	while true do
		task.wait(5)
		uiHandle.Refresh()
	end
end)

print("[AutoFarmHub_vFinal] Loaded.")
