--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

--// UI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FarmUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 320)
frame.Position = UDim2.new(0.5, -200, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "⚡ Dashing Hub"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Tabs
local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 35)
tabFrame.BackgroundTransparency = 1

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, -10, 1, -80)
content.Position = UDim2.new(0, 5, 0, 70)
content.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
content.BorderSizePixel = 0

local tabs = {"🌪️ Orbs", "🌸 Flowers", "💎 Chests"}
local currentTab
local tabButtons = {}

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", tabFrame)
	btn.Text = name
	btn.Size = UDim2.new(0, 120, 0, 30)
	btn.Position = UDim2.new(0, (i - 1) * 125, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	tabButtons[name] = btn
end

-- Minimize
local mini = Instance.new("TextButton", frame)
mini.Text = "–"
mini.Size = UDim2.new(0, 25, 0, 25)
mini.Position = UDim2.new(1, -30, 0, 5)
mini.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
mini.TextColor3 = Color3.fromRGB(255,255,255)

local minimized = false
mini.MouseButton1Click:Connect(function()
	if minimized then
		frame:TweenSize(UDim2.new(0, 400, 0, 320), "Out", "Sine", 0.3, true)
	else
		frame:TweenSize(UDim2.new(0, 100, 0, 40), "Out", "Sine", 0.3, true)
	end
	minimized = not minimized
end)

--// Core Tween
local function tweenTo(pos)
	local tween = TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
	tween:Play()
	tween.Completed:Wait()
end

--// Utility
local function clearContent()
	for _, c in ipairs(content:GetChildren()) do
		c:Destroy()
	end
end

--// Orbs & Flowers
local function makeFarmTab(folderName)
	clearContent()
	local allBtn = Instance.new("TextButton", content)
	allBtn.Text = "Auto Farm All"
	allBtn.Size = UDim2.new(0, 180, 0, 30)
	allBtn.Position = UDim2.new(0, 10, 0, 5)
	allBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
	allBtn.TextColor3 = Color3.fromRGB(255,255,255)

	local nearBtn = Instance.new("TextButton", content)
	nearBtn.Text = "Auto Farm Nearest"
	nearBtn.Size = UDim2.new(0, 180, 0, 30)
	nearBtn.Position = UDim2.new(0, 205, 0, 5)
	nearBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
	nearBtn.TextColor3 = Color3.fromRGB(255,255,255)

	local scroll = Instance.new("ScrollingFrame", content)
	scroll.Size = UDim2.new(1, -10, 1, -50)
	scroll.Position = UDim2.new(0, 5, 0, 45)
	scroll.CanvasSize = UDim2.new(0,0,2,0)
	scroll.ScrollBarThickness = 4
	scroll.BackgroundTransparency = 1

	local folder = workspace:FindFirstChild(folderName)
	if not folder then return end

	for i, obj in ipairs(folder:GetChildren()) do
		if obj:IsA("BasePart") then
			local button = Instance.new("TextButton", scroll)
			button.Size = UDim2.new(1, -10, 0, 25)
			button.Position = UDim2.new(0, 5, 0, (i-1)*28)
			button.BackgroundColor3 = obj.Transparency < 1 and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
			button.Text = obj.Name .. (obj.Transparency < 1 and " ✅" or " ❌")
			button.TextColor3 = Color3.fromRGB(255,255,255)
			button.MouseButton1Click:Connect(function()
				tweenTo(obj.Position)
			end)
		end
	end

	allBtn.MouseButton1Click:Connect(function()
		task.spawn(function()
			while task.wait(0.3) do
				for _, obj in ipairs(folder:GetChildren()) do
					if obj:IsA("BasePart") and obj.Transparency < 1 then
						tweenTo(obj.Position)
						task.wait(0.2)
					end
				end
			end
		end)
	end)

	nearBtn.MouseButton1Click:Connect(function()
		task.spawn(function()
			while task.wait(0.5) do
				local nearest, dist
				for _, obj in ipairs(folder:GetChildren()) do
					if obj:IsA("BasePart") and obj.Transparency < 1 then
						local d = (root.Position - obj.Position).Magnitude
						if not dist or d < dist then
							dist = d
							nearest = obj
						end
					end
				end
				if nearest then
					tweenTo(nearest.Position)
				end
			end
		end)
	end)
end

--// Chests
local function makeChestTab()
	clearContent()
	local chestInfo = {
		{ name = "Desert Chest", cooldown = 3600 },
		{ name = "Golden Chest", cooldown = 900 }
	}

	for i, data in ipairs(chestInfo) do
		local lbl = Instance.new("TextLabel", content)
		lbl.Text = data.name
		lbl.Size = UDim2.new(0, 180, 0, 25)
		lbl.Position = UDim2.new(0, 10, 0, (i-1)*70)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(255,255,255)

		local tpBtn = Instance.new("TextButton", content)
		tpBtn.Text = "Teleport"
		tpBtn.Size = UDim2.new(0, 100, 0, 25)
		tpBtn.Position = UDim2.new(0, 200, 0, (i-1)*70)
		tpBtn.BackgroundColor3 = Color3.fromRGB(90,0,0)
		tpBtn.TextColor3 = Color3.fromRGB(255,255,255)

		local timer = Instance.new("TextLabel", content)
		timer.Size = UDim2.new(0, 100, 0, 25)
		timer.Position = UDim2.new(0, 310, 0, (i-1)*70)
		timer.BackgroundTransparency = 1
		timer.TextColor3 = Color3.fromRGB(255,255,255)

		local nextTime = os.time()
		local function updateTimer()
			local remaining = math.max(0, nextTime - os.time())
			local mins = math.floor(remaining / 60)
			local secs = remaining % 60
			timer.Text = string.format("%02dm %02ds", mins, secs)
		end

		RunService.Heartbeat:Connect(updateTimer)

		tpBtn.MouseButton1Click:Connect(function()
			local chest = workspace.Chests:FindFirstChild(data.name)
			if chest and chest:FindFirstChildWhichIsA("BasePart") then
				tweenTo(chest:FindFirstChildWhichIsA("BasePart").Position)
				nextTime = os.time() + data.cooldown
			end
		end)
	end
end

-- Tab switching
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		if name == "🌪️ Orbs" then
			makeFarmTab("CollectableOrbs")
		elseif name == "🌸 Flowers" then
			makeFarmTab("Flowers")
		else
			makeChestTab()
		end
	end)
end

makeFarmTab("CollectableOrbs") -- default tab
