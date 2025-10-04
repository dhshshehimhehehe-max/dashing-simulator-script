-- Dashing Simulator GUI Script (Final Polished Version)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy old GUI if reloaded
if CoreGui:FindFirstChild("DashingHubUI") then
    CoreGui.DashingHubUI:Destroy()
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "DashingHubUI"

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 380, 0, 270)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -135)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "⚡ Dashing Hub"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Text = "—"
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 22

-- Close Button
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 22

-- Tab Buttons
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, 0, 0, 35)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabFrame.BorderSizePixel = 0

local Tabs = {"⚪ Orbs", "🌸 Flowers", "💎 Chests"}
local TabButtons = {}
local ActiveTab = "Chests"

for i, name in ipairs(Tabs) do
	local Button = Instance.new("TextButton", TabFrame)
	Button.Size = UDim2.new(1 / #Tabs, 0, 1, 0)
	Button.Position = UDim2.new((i - 1) / #Tabs, 0, 0, 0)
	Button.Text = name
	Button.BackgroundTransparency = 1
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.TextSize = 18
	TabButtons[name] = Button
end

-- Content Frame
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1

-- === CHEST TAB ===
local ChestFrame = Instance.new("Frame", ContentFrame)
ChestFrame.Size = UDim2.new(1, 0, 1, 0)
ChestFrame.BackgroundTransparency = 1

local function makeChestSection(name, cooldown)
	local ChestSection = Instance.new("Frame", ChestFrame)
	ChestSection.Size = UDim2.new(1, 0, 0, 50)
	ChestSection.BackgroundTransparency = 1
	local Title = Instance.new("TextLabel", ChestSection)
	Title.Text = name .. " — Cooldown: " .. cooldown
	Title.Size = UDim2.new(1, 0, 0.5, 0)
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local TeleportBtn = Instance.new("TextButton", ChestSection)
	TeleportBtn.Text = "Teleport"
	TeleportBtn.Size = UDim2.new(0, 100, 0, 25)
	TeleportBtn.Position = UDim2.new(0, 0, 0.5, 0)
	TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
	TeleportBtn.TextSize = 14
	local UICorner = Instance.new("UICorner", TeleportBtn)
	UICorner.CornerRadius = UDim.new(0, 6)

	local AutoBtn = Instance.new("TextButton", ChestSection)
	AutoBtn.Text = "Auto"
	AutoBtn.Size = UDim2.new(0, 100, 0, 25)
	AutoBtn.Position = UDim2.new(0, 110, 0.5, 0)
	AutoBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	AutoBtn.TextColor3 = Color3.new(1, 1, 1)
	AutoBtn.TextSize = 14
	local UICorner2 = Instance.new("UICorner", AutoBtn)
	UICorner2.CornerRadius = UDim.new(0, 6)

	return ChestSection, TeleportBtn, AutoBtn
end

local DesertSection, DesertTeleport, DesertAuto =
	makeChestSection("🏜️ Desert Chest", "1h Cooldown")
DesertSection.Position = UDim2.new(0, 0, 0, 0)

local GoldenSection, GoldenTeleport, GoldenAuto =
	makeChestSection("💰 Golden Chest", "15m Cooldown")
GoldenSection.Position = UDim2.new(0, 0, 0, 60)

GoldenSection.Parent = ChestFrame
DesertSection.Parent = ChestFrame

-- Simple notification
local function showNotification(text)
	local Note = Instance.new("TextLabel", ScreenGui)
	Note.Text = text
	Note.TextColor3 = Color3.new(1, 1, 1)
	Note.TextSize = 20
	Note.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	Note.Position = UDim2.new(0.5, -150, 0.5, -20)
	Note.Size = UDim2.new(0, 300, 0, 40)
	Note.TextStrokeTransparency = 0.8
	local UICorner = Instance.new("UICorner", Note)
	UICorner.CornerRadius = UDim.new(0, 8)
	Note.AnchorPoint = Vector2.new(0, 0)

	Note.BackgroundTransparency = 1
	Note.TextTransparency = 1
	TweenService:Create(Note, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	task.wait(2)
	TweenService:Create(Note, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
	task.wait(0.4)
	Note:Destroy()
end

-- Teleport to chest
local function teleportToChest(chestName)
	local chest = workspace:FindFirstChild("Chests") and workspace.Chests:FindFirstChild(chestName)
	if chest and chest:FindFirstChild("HumanoidRootPart") then
		humanoidRootPart.CFrame = chest.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
	else
		for _, v in pairs(chest:GetChildren()) do
			if v:IsA("BasePart") then
				humanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 5, 0)
				break
			end
		end
	end
end

-- Chest logic
local function setupChestSystem(button, autoButton, name, cooldownSeconds)
	local autoActive = false
	autoButton.MouseButton1Click:Connect(function()
		autoActive = not autoActive
		autoButton.BackgroundColor3 = autoActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 60, 60)
		if autoActive then
			task.spawn(function()
				while autoActive do
					teleportToChest(name)
					showNotification("⏱️ Auto teleported to " .. name)
					task.wait(cooldownSeconds)
				end
			end)
		end
	end)
	button.MouseButton1Click:Connect(function()
		teleportToChest(name)
	end)
end

setupChestSystem(DesertTeleport, DesertAuto, "Desert Chest", 3600)
setupChestSystem(GoldenTeleport, GoldenAuto, "Golden Chest", 900)

-- Tab Switching
for name, button in pairs(TabButtons) do
	button.MouseButton1Click:Connect(function()
		for _, tab in pairs(ContentFrame:GetChildren()) do
			tab.Visible = false
		end
		if name == "💎 Chests" then
			ChestFrame.Visible = true
		end
		ActiveTab = name
	end)
end

ChestFrame.Visible = true

-- Minimize/Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	MainFrame.Visible = not minimized
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
