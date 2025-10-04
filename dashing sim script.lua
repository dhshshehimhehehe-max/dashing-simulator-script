-- Simple AutoFarm Hub (Orbs / Flowers / Chests)
-- Paste as LocalScript in StarterPlayerScripts

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Respawn-safe HRP
local Character = player.Character or player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(char)
	task.wait(0.6)
	Character = char
	HRP = Character:WaitForChild("HumanoidRootPart")
end)

-- small helper: find a reasonable BasePart in a Model or return the part itself
local function getTargetPart(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		local prefer = {"Small","Main","Flower","Big","Toucher","Handle","Base","Part"}
		for _,n in ipairs(prefer) do
			local found = obj:FindFirstChild(n, true)
			if found and found:IsA("BasePart") then return found end
		end
		for _,d in ipairs(obj:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
	end
	return nil
end

-- Safe tween movement to part (used for orbs/flowers)
local function tweenToPart(part)
	if not part or not HRP then return end
	pcall(function()
		local dist = (HRP.Position - part.Position).Magnitude
		local speed = 280
		local t = math.clamp(dist / speed, 0.12, 1.6)
		local tw = TweenService:Create(HRP, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, 3, 0)})
		tw:Play()
		tw.Completed:Wait()
	end)
end

-- instant teleport to Vector3 position (used for chests)
local function instantTeleport(pos)
	if HRP then
		pcall(function()
			HRP.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
		end)
	end
end

-- UI build (simple, centered)
local function buildUI()
	-- remove existing UI
	local existing = playerGui:FindFirstChild("SimpleAutoFarmUI")
	if existing then existing:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SimpleAutoFarmUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main
	local Main = Instance.new("Frame", screenGui)
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 400, 0, 320)
	Main.AnchorPoint = Vector2.new(0.5,0.5)
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.BackgroundColor3 = Color3.fromRGB(30,10,10)
	Main.BorderSizePixel = 0
	local mainCorner = Instance.new("UICorner", Main); mainCorner.CornerRadius = UDim.new(0,8)

	-- Title bar
	local TitleBar = Instance.new("Frame", Main)
	TitleBar.Size = UDim2.new(1,0,0,36)
	TitleBar.BackgroundColor3 = Color3.fromRGB(18,6,6)
	TitleBar.Position = UDim2.new(0,0,0,0)
	local title = Instance.new("TextLabel", TitleBar)
	title.Text = "AutoFarm Hub"
	title.TextColor3 = Color3.fromRGB(240,240,240)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 16
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local MinBtn = Instance.new("TextButton", TitleBar)
	MinBtn.Text = "-"
	MinBtn.Size = UDim2.new(0,28,0,24)
	MinBtn.Position = UDim2.new(1, -60, 0, 6)
	MinBtn.BackgroundColor3 = Color3.fromRGB(85,12,12)
	local CloseBtn = Instance.new("TextButton", TitleBar)
	CloseBtn.Text = "X"
	CloseBtn.Size = UDim2.new(0,28,0,24)
	CloseBtn.Position = UDim2.new(1, -32, 0, 6)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(150,18,18)

	-- Tabs
	local tabsFrame = Instance.new("Frame", Main)
	tabsFrame.Size = UDim2.new(1, -16, 0, 34)
	tabsFrame.Position = UDim2.new(0, 8, 0, 44)
	tabsFrame.BackgroundTransparency = 1

	local function newTabBtn(text, x)
		local b = Instance.new("TextButton", tabsFrame)
		b.Size = UDim2.new(0,120,1,0)
		b.Position = UDim2.new(0, x, 0, 0)
		b.Text = text
		b.TextColor3 = Color3.fromRGB(240,240,240)
		b.BackgroundColor3 = Color3.fromRGB(50,12,12)
		return b
	end

	local btnOrbs = newTabBtn("Orbs", 0)
	local btnFlowers = newTabBtn("Flowers", 126)
	local btnChests = newTabBtn("Chests", 252)

	-- Content container (panels will be shifted left-right)
	local content = Instance.new("Frame", Main)
	content.Size = UDim2.new(1, -16, 1, -92)
	content.Position = UDim2.new(0, 8, 0, 84)
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true

	local function makePanel(xOffset)
		local p = Instance.new("Frame", content)
		p.Size = UDim2.new(1, 0, 1, 0)
		p.Position = UDim2.new(xOffset, 0, 0, 0)
		p.BackgroundTransparency = 1
		return p
	end

	local panelOrbs = makePanel(0)
	local panelFlowers = makePanel(1)
	local panelChests = makePanel(2)

	-- PANEL: Orbs & Flowers share very similar layout
	local function makeTopControls(parent)
		local top = Instance.new("Frame", parent)
		top.Size = UDim2.new(1,0,0,36)
		top.Position = UDim2.new(0,0,0,0)
		top.BackgroundTransparency = 1

		local farmAll = Instance.new("TextButton", top)
		farmAll.Size = UDim2.new(0,160,0,28)
		farmAll.Position = UDim2.new(0,0,0,4)
		farmAll.Text = "Auto Farm All: OFF"
		farmAll.BackgroundColor3 = Color3.fromRGB(85,12,12)
		farmAll.TextColor3 = Color3.fromRGB(240,240,240)

		local farmNearest = Instance.new("TextButton", top)
		farmNearest.Size = UDim2.new(0,160,0,28)
		farmNearest.Position = UDim2.new(0,170,0,4)
		farmNearest.Text = "Auto Farm Nearest: OFF"
		farmNearest.BackgroundColor3 = Color3.fromRGB(85,12,12)
		farmNearest.TextColor3 = Color3.fromRGB(240,240,240)

		local onlyOnMap = Instance.new("TextButton", top)
		onlyOnMap.Size = UDim2.new(0,110,0,28)
		onlyOnMap.Position = UDim2.new(0,340,0,4)
		onlyOnMap.Text = "Only On Map: OFF"
		onlyOnMap.BackgroundColor3 = Color3.fromRGB(85,12,12)
		onlyOnMap.TextColor3 = Color3.fromRGB(240,240,240)

		return {
			FarmAll = farmAll,
			FarmNearest = farmNearest,
			OnlyOnMap = onlyOnMap
		}
	end

	-- Scrollers
	local function makeScroll(parent, top)
		local scr = Instance.new("ScrollingFrame", parent)
		scr.Size = UDim2.new(1, -12, 1, -top - 6)
		scr.Position = UDim2.new(0, 6, 0, top + 6)
		scr.BackgroundTransparency = 1
		scr.ScrollBarThickness = 8
		local layout = Instance.new("UIListLayout", scr)
		layout.Padding = UDim.new(0,6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		return scr
	end

	-- Orbs UI
	local orbsTop = makeTopControls(panelOrbs)
	local orbsAllScroll = makeScroll(panelOrbs, 38)

	-- Flowers UI
	local flowersTop = makeTopControls(panelFlowers)
	local flowersAllScroll = makeScroll(panelFlowers, 38)

	-- Helpers to populate lists
	local Toggles = { Orbs = {}, Flowers = {} } -- store user-selected toggles (if needed later)
	local function clearList(scr)
		for _,c in ipairs(scr:GetChildren()) do
			if not c:IsA("UIListLayout") then
				c:Destroy()
			end
		end
	end

	local function isSpawnedModel(model)
		-- treat "spawned" as having a visible basepart (transparency < 1)
		local part = getTargetPart(model)
		if not part then return false end
		-- if part's transparency < 1 treat as on-map (spawned)
		if part.Transparency < 1 then return true end
		-- also check for size or CanCollide as fallback
		if part.CanCollide then return true end
		return false
	end

	local function populateList(folderName, scroll)
		clearList(scroll)
		local folder = workspace:FindFirstChild(folderName)
		if not folder then return end
		for i,child in ipairs(folder:GetChildren()) do
			if child and child.Name then
				local btn = Instance.new("TextButton", scroll)
				btn.Size = UDim2.new(1, -10, 0, 28)
				btn.Position = UDim2.new(0, 5, 0, (i-1) * 32)
				btn.BackgroundColor3 = Color3.fromRGB(44,44,44)
				btn.TextColor3 = Color3.fromRGB(240,240,240)
				btn.Font = Enum.Font.SourceSansSemibold
				btn.Text = child.Name
				btn.AutoButtonColor = true

				-- clicking an item moves you to it (tween)
				btn.MouseButton1Click:Connect(function()
					local tpPart = getTargetPart(child)
					if tpPart then
						tweenToPart(tpPart)
					else
						-- fallback: try using model pivot position
						if child:IsA("Model") then
							local ok, cframe = pcall(function() return child:GetModelCFrame() end)
							if ok and cframe then
								instantTeleport(cframe.Position)
							end
						end
					end
				end)
			end
		end
		-- fix canvas size
		task.spawn(function()
			task.wait(0.05)
			local total = 0
			for _,c in ipairs(scroll:GetChildren()) do
				if c:IsA("GuiObject") and not c:IsA("UIListLayout") then
					total = total + c.AbsoluteSize.Y + 6
				end
			end
			scroll.CanvasSize = UDim2.new(0,0,0, math.max(1, total))
		end)
	end

	-- initial populate
	populateList("CollectableOrbs", orbsAllScroll)
	populateList("Flowers", flowersAllScroll)

	-- auto refresh on changes
	local orbsFolder = workspace:FindFirstChild("CollectableOrbs")
	if orbsFolder then
		orbsFolder.ChildAdded:Connect(function() populateList("CollectableOrbs", orbsAllScroll) end)
		orbsFolder.ChildRemoved:Connect(function() populateList("CollectableOrbs", orbsAllScroll) end)
	end
	local flowersFolder = workspace:FindFirstChild("Flowers")
	if flowersFolder then
		flowersFolder.ChildAdded:Connect(function() populateList("Flowers", flowersAllScroll) end)
		flowersFolder.ChildRemoved:Connect(function() populateList("Flowers", flowersAllScroll) end)
	end

	-- farming flags
	local farmFlags = {
		orbsAll = false,
		orbsNearest = false,
		flowersAll = false,
		flowersNearest = false
	}

	-- farming loops
	spawn(function()
		while true do
			task.wait(0.12)
			-- ORBS All
			if farmFlags.orbsAll then
				local folder = workspace:FindFirstChild("CollectableOrbs")
				if folder then
					for _,m in ipairs(folder:GetChildren()) do
						if not farmFlags.orbsAll then break end
						if orbsTop.OnlyOnMap.Text:find("ON") then
							if not isSpawnedModel(m) then continue end
						end
						local p = getTargetPart(m)
						if p then
							tweenToPart(p)
							task.wait(0.15)
						end
					end
				end
			end

			-- ORBS Nearest
			if farmFlags.orbsNearest then
				local folder = workspace:FindFirstChild("CollectableOrbs")
				if folder then
					local nearest, nd
					for _,m in ipairs(folder:GetChildren()) do
						if orbsTop.OnlyOnMap.Text:find("ON") then
							if not isSpawnedModel(m) then continue end
						end
						local p = getTargetPart(m)
						if p then
							local d = (HRP.Position - p.Position).Magnitude
							if not nd or d < nd then nd = d; nearest = p end
						end
					end
					if nearest then
						tweenToPart(nearest)
						task.wait(0.12)
					end
				end
			end

			-- FLOWERS All
			if farmFlags.flowersAll then
				local folder = workspace:FindFirstChild("Flowers")
				if folder then
					for _,m in ipairs(folder:GetChildren()) do
						if not farmFlags.flowersAll then break end
						if flowersTop.OnlyOnMap.Text:find("ON") then
							if not isSpawnedModel(m) then continue end
						end
						local p = getTargetPart(m)
						if p then
							tweenToPart(p)
							task.wait(0.15)
						end
					end
				end
			end

			-- FLOWERS Nearest
			if farmFlags.flowersNearest then
				local folder = workspace:FindFirstChild("Flowers")
				if folder then
					local nearest, nd
					for _,m in ipairs(folder:GetChildren()) do
						if flowersTop.OnlyOnMap.Text:find("ON") then
							if not isSpawnedModel(m) then continue end
						end
						local p = getTargetPart(m)
						if p then
							local d = (HRP.Position - p.Position).Magnitude
							if not nd or d < nd then nd = d; nearest = p end
						end
					end
					if nearest then
						tweenToPart(nearest)
						task.wait(0.12)
					end
				end
			end
		end
	end)

	-- connect buttons to flags & functions
	orbsTop.FarmAll.MouseButton1Click:Connect(function()
		farmFlags.orbsAll = not farmFlags.orbsAll
		orbsTop.FarmAll.Text = "Auto Farm All: " .. (farmFlags.orbsAll and "ON" or "OFF")
		-- ensure only one mode active
		if farmFlags.orbsAll then
			farmFlags.orbsNearest = false
			orbsTop.FarmNearest.Text = "Auto Farm Nearest: OFF"
		end
	end)
	orbsTop.FarmNearest.MouseButton1Click:Connect(function()
		farmFlags.orbsNearest = not farmFlags.orbsNearest
		orbsTop.FarmNearest.Text = "Auto Farm Nearest: " .. (farmFlags.orbsNearest and "ON" or "OFF")
		if farmFlags.orbsNearest then
			farmFlags.orbsAll = false
			orbsTop.FarmAll.Text = "Auto Farm All: OFF"
		end
	end)
	orbsTop.OnlyOnMap.MouseButton1Click:Connect(function()
		local on = orbsTop.OnlyOnMap.Text:find("ON")
		orbsTop.OnlyOnMap.Text = "Only On Map: " .. (on and "OFF" or "ON")
	end)

	flowersTop.FarmAll.MouseButton1Click:Connect(function()
		farmFlags.flowersAll = not farmFlags.flowersAll
		flowersTop.FarmAll.Text = "Auto Farm All: " .. (farmFlags.flowersAll and "ON" or "OFF")
		if farmFlags.flowersAll then
			farmFlags.flowersNearest = false
			flowersTop.FarmNearest.Text = "Auto Farm Nearest: OFF"
		end
	end)
	flowersTop.FarmNearest.MouseButton1Click:Connect(function()
		farmFlags.flowersNearest = not farmFlags.flowersNearest
		flowersTop.FarmNearest.Text = "Auto Farm Nearest: " .. (farmFlags.flowersNearest and "ON" or "OFF")
		if farmFlags.flowersNearest then
			farmFlags.flowersAll = false
			flowersTop.FarmAll.Text = "Auto Farm All: OFF"
		end
	end)
	flowersTop.OnlyOnMap.MouseButton1Click:Connect(function()
		local on = flowersTop.OnlyOnMap.Text:find("ON")
		flowersTop.OnlyOnMap.Text = "Only On Map: " .. (on and "OFF" or "ON")
	end)

	-- PANEL: Chests (vertical, simple)
	local chestY = 6
	local chestDefs = {
		{label = "Desert Chest", pos = Vector3.new(-7867.7495117,5.1276078,39.38441467), cooldown = 3600, next = 0, auto = false},
		{label = "Golden Chest", pos = Vector3.new(473.4592896,16.0885677,-20.12939262), cooldown = 900, next = 0, auto = false}
	}
	for _,info in ipairs(chestDefs) do
		local row = Instance.new("Frame", panelChests)
		row.Size = UDim2.new(1, -12, 0, 40)
		row.Position = UDim2.new(0, 6, 0, chestY)
		row.BackgroundTransparency = 1

		local nameLabel = Instance.new("TextLabel", row)
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = info.label
		nameLabel.TextColor3 = Color3.fromRGB(240,240,240)
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left

		local timerLabel = Instance.new("TextLabel", row)
		timerLabel.Size = UDim2.new(0.28, 0, 1, 0)
		timerLabel.Position = UDim2.new(0.5, 6, 0, 0)
		timerLabel.BackgroundTransparency = 1
		timerLabel.Text = "Ready"
		timerLabel.TextColor3 = Color3.fromRGB(240,240,240)
		timerLabel.Font = Enum.Font.SourceSans

		local autoBtn = Instance.new("TextButton", row)
		autoBtn.Size = UDim2.new(0, 64, 0, 26)
		autoBtn.Position = UDim2.new(0.8, 0, 0, 6)
		autoBtn.Text = "Auto"
		autoBtn.BackgroundColor3 = Color3.fromRGB(85,12,12)
		autoBtn.TextColor3 = Color3.fromRGB(240,240,240)

		local tpBtn = Instance.new("TextButton", row)
		tpBtn.Size = UDim2.new(0,64,0,26)
		tpBtn.Position = UDim2.new(0.92, -64, 0, 6)
		tpBtn.Text = "Teleport"
		tpBtn.BackgroundColor3 = Color3.fromRGB(155,12,12)
		tpBtn.TextColor3 = Color3.fromRGB(240,240,240)

		-- link UI back to info
		info.timerLabel = timerLabel
		info.autoBtn = autoBtn

		-- tp button action: instant teleport and start cooldown
		tpBtn.MouseButton1Click:Connect(function()
			instantTeleport(info.pos)
			info.next = os.time() + info.cooldown
		end)

		-- auto toggle
		autoBtn.MouseButton1Click:Connect(function()
			info.auto = not info.auto
			autoBtn.BackgroundColor3 = info.auto and Color3.fromRGB(6,120,60) or Color3.fromRGB(85,12,12)
			-- if auto turned on and chest is ready -> teleport immediately and start cooldown
			if info.auto and info.next <= os.time() then
				instantTeleport(info.pos)
				info.next = os.time() + info.cooldown
			end
		end)

		chestY = chestY + 46
	end

	-- chest timer loop
	spawn(function()
		while true do
			for _,info in ipairs(chestDefs) do
				local rem = math.max(0, (info.next or 0) - os.time())
				if rem <= 0 then
					info.timerLabel.Text = "✅ Ready!"
					info.timerLabel.TextColor3 = Color3.fromRGB(6,180,80)
					-- auto teleport if enabled (and previous cooldown had been set)
					if info.auto and (info.next or 0) > 0 then
						instantTeleport(info.pos)
						info.next = os.time() + info.cooldown
					end
				else
					local m = math.floor(rem / 60)
					local s = rem % 60
					info.timerLabel.Text = string.format("⏱ %dm %02ds", m, s)
					info.timerLabel.TextColor3 = Color3.fromRGB(240,240,240)
				end
			end
			task.wait(1)
		end
	end)

	-- panel switching (simple)
	local panels = {panelOrbs, panelFlowers, panelChests}
	local function setActive(index)
		for i,p in ipairs(panels) do
			p.Position = UDim2.new(i-1 - (index-1), 0, 0, 0)
		end
	end
	btnOrbs.MouseButton1Click:Connect(function() setActive(1) end)
	btnFlowers.MouseButton1Click:Connect(function() setActive(2) end)
	btnChests.MouseButton1Click:Connect(function() setActive(3) end)

	-- Minimize to bottom-left icon
	local mini = Instance.new("TextButton", screenGui)
	mini.Text = "☘"
	mini.Size = UDim2.new(0,44,0,44)
	mini.Position = UDim2.new(0, 8, 1, -60)
	mini.BackgroundColor3 = Color3.fromRGB(70,18,18)
	mini.TextColor3 = Color3.fromRGB(255,255,255)
	mini.Visible = false
	local miniCorner = Instance.new("UICorner", mini); miniCorner.CornerRadius = UDim.new(0,8)

	MinBtn.MouseButton1Click:Connect(function()
		Main.Visible = false
		mini.Visible = true
	end)
	mini.MouseButton1Click:Connect(function()
		Main.Visible = true
		mini.Visible = false
	end)
	CloseBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

	-- final refresh function for external use
	local function refreshAll()
		populateList("CollectableOrbs", orbsAllScroll)
		populateList("Flowers", flowersAllScroll)
	end

	return {
		Refresh = refreshAll
	}
end

-- build UI and keep handle
local handle = buildUI()

-- periodic fallback refresh (safety)
spawn(function()
	while true do
		task.wait(5)
		pcall(function() handle.Refresh() end)
	end
end)

print("Simple AutoFarm Hub loaded.")
