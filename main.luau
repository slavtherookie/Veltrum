--[[
    Library: Veltrum
    Creator: siv
    Description: Modular, highly advanced UI library with depth rendering, FOV/Blur toggles, and Anti-UI-Steal obfuscation.
]]

local Veltrum = {
	Version = "1.0.0",
	Creator = "siv"
}

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// Theme Configuration
local Theme = {
	Background = Color3.fromRGB(15, 15, 18),
	TabContainer = Color3.fromRGB(22, 22, 26),
	ElementFrame = Color3.fromRGB(28, 28, 33),
	Stroke = Color3.fromRGB(45, 45, 55),
	Accent = Color3.fromRGB(220, 220, 225),
	Text = Color3.fromRGB(240, 240, 245),
	TextDark = Color3.fromRGB(150, 150, 155),
	DepthTop = Color3.fromRGB(255, 255, 255),
	DepthBottom = Color3.fromRGB(0, 0, 0)
}

--// Asset IDs
local Icons = {
	Close = "rbxassetid://4458805218",
	CheckboxOff = "rbxassetid://4458801920",
	CheckboxOn = "rbxassetid://4458804273"
}

--// Utilities
local function GenerateObfuscatedName()
	-- Scrambles element names to prevent UI stealing/rebuilding
	return HttpService:GenerateGUID(false):gsub("-", "")
end

local function Tween(instance, properties, duration)
	duration = duration or 0.2
	local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

local function ApplyDepth(instance, strokeColor, thickness)
	-- Creates a unique physical depth effect without images
	local stroke = Instance.new("UIStroke")
	stroke.Name = GenerateObfuscatedName()
	stroke.Color = strokeColor or Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance

	local gradient = Instance.new("UIGradient")
	gradient.Name = GenerateObfuscatedName()
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.6, 0.6, 0.6))
	})
	gradient.Parent = stroke
end

local function MakeDraggable(topbar, mainFrame)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

--// Auto-Update & Cleanup (Destroys old UI if script is re-run)
if getgenv().Veltrum_Instance then getgenv().Veltrum_Instance:Destroy() end
if getgenv().Veltrum_Blur then getgenv().Veltrum_Blur:Destroy() end

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = GenerateObfuscatedName()
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
getgenv().Veltrum_Blur = BlurEffect

--// Main Window Creation
function Veltrum:CreateWindow(config)
	config = config or {}
	local Title = config.Title or "Veltrum Library"
	local ToggleKey = config.ToggleKey or Enum.KeyCode.LeftShift

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = GenerateObfuscatedName()
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.Parent = CoreGui
	getgenv().Veltrum_Instance = ScreenGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = GenerateObfuscatedName()
	MainFrame.Size = UDim2.new(0, 600, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui

	local UICorner = Instance.new("UICorner")
	UICorner.Name = GenerateObfuscatedName()
	UICorner.CornerRadius = UDim.new(0, 6)
	UICorner.Parent = MainFrame
	ApplyDepth(MainFrame, Theme.Stroke, 1.5)

	local Topbar = Instance.new("Frame")
	Topbar.Name = GenerateObfuscatedName()
	Topbar.Size = UDim2.new(1, 0, 0, 40)
	Topbar.BackgroundTransparency = 1
	Topbar.Parent = MainFrame
	MakeDraggable(Topbar, MainFrame)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = GenerateObfuscatedName()
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Topbar

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Name = GenerateObfuscatedName()
	CloseBtn.Size = UDim2.new(0, 16, 0, 16)
	CloseBtn.Position = UDim2.new(1, -28, 0.5, -8)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = Icons.Close
	CloseBtn.ImageColor3 = Theme.TextDark
	CloseBtn.Parent = Topbar

	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
		BlurEffect:Destroy()
	end)

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = GenerateObfuscatedName()
	ContentContainer.Size = UDim2.new(1, -20, 1, -50)
	ContentContainer.Position = UDim2.new(0, 10, 0, 40)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = GenerateObfuscatedName()
	TabContainer.Size = UDim2.new(0, 140, 1, -10)
	TabContainer.Position = UDim2.new(0, 0, 0, 0)
	TabContainer.BackgroundColor3 = Theme.TabContainer
	TabContainer.BorderSizePixel = 0
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = ContentContainer
	Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 4)
	ApplyDepth(TabContainer)

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Name = GenerateObfuscatedName()
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.Parent = TabContainer

	local TabPadding = Instance.new("UIPadding")
	TabPadding.Name = GenerateObfuscatedName()
	TabPadding.PaddingTop = UDim.new(0, 5)
	TabPadding.PaddingLeft = UDim.new(0, 5)
	TabPadding.PaddingRight = UDim.new(0, 5)
	TabPadding.Parent = TabContainer

	local PagesContainer = Instance.new("Frame")
	PagesContainer.Name = GenerateObfuscatedName()
	PagesContainer.Size = UDim2.new(1, -150, 1, -10)
	PagesContainer.Position = UDim2.new(0, 150, 0, 0)
	PagesContainer.BackgroundTransparency = 1
	PagesContainer.Parent = ContentContainer

	--// Visual FX & Toggling
	local Toggled = true
	local DefaultFOV = Camera.FieldOfView

	local function ToggleUI()
		Toggled = not Toggled
		ScreenGui.Enabled = Toggled
		if Toggled then
			Tween(BlurEffect, {Size = 24}, 0.4)
			Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.4)
		else
			Tween(BlurEffect, {Size = 0}, 0.4)
			Tween(Camera, {FieldOfView = DefaultFOV}, 0.4)
		end
	end

	-- Initialize Effects
	Tween(BlurEffect, {Size = 24}, 0.4)
	Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.4)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == ToggleKey then ToggleUI() end
	end)

	local WindowObj = {}
	local FirstTab = true

	function WindowObj:CreateTab(tabName)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = GenerateObfuscatedName()
		TabBtn.Size = UDim2.new(1, 0, 0, 30)
		TabBtn.BackgroundColor3 = Theme.Background
		TabBtn.BackgroundTransparency = FirstTab and 0 or 1
		TabBtn.Text = tabName
		TabBtn.TextColor3 = FirstTab and Theme.Accent or Theme.TextDark
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 14
		TabBtn.Parent = TabContainer
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

		local Page = Instance.new("ScrollingFrame")
		Page.Name = GenerateObfuscatedName()
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.Visible = FirstTab
		Page.Parent = PagesContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Name = GenerateObfuscatedName()
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _, child in pairs(PagesContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			for _, child in pairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					Tween(child, {BackgroundTransparency = 1}, 0.2)
					Tween(child, {TextColor3 = Theme.TextDark}, 0.2)
				end
			end
			Page.Visible = true
			Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
			Tween(TabBtn, {TextColor3 = Theme.Accent}, 0.2)
		end)

		FirstTab = false
		local TabElements = {}

		--// ELEMENT: BUTTON
		function TabElements:CreateButton(config)
			local btnText = config.Name or "Button"
			local callback = config.Callback or function() end

			local BtnFrame = Instance.new("TextButton")
			BtnFrame.Name = GenerateObfuscatedName()
			BtnFrame.Size = UDim2.new(1, -10, 0, 35)
			BtnFrame.BackgroundColor3 = Theme.ElementFrame
			BtnFrame.Text = btnText
			BtnFrame.TextColor3 = Theme.Text
			BtnFrame.Font = Enum.Font.Gotham
			BtnFrame.TextSize = 14
			BtnFrame.Parent = Page
			Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 4)
			ApplyDepth(BtnFrame, Theme.Stroke, 1)

			BtnFrame.MouseButton1Click:Connect(function()
				local clickTween = Tween(BtnFrame, {BackgroundColor3 = Theme.TabContainer}, 0.1)
				clickTween.Completed:Wait()
				Tween(BtnFrame, {BackgroundColor3 = Theme.ElementFrame}, 0.1)
				callback()
			end)
		end

		--// ELEMENT: TOGGLE (SWITCH / CHECKBOX)
		function TabElements:CreateToggle(config)
			local togText = config.Name or "Toggle"
			local togType = config.Type or "Switch" -- "Switch" or "Checkbox"
			local callback = config.Callback or function() end
			local state = config.Default or false

			local TogFrame = Instance.new("TextButton")
			TogFrame.Name = GenerateObfuscatedName()
			TogFrame.Size = UDim2.new(1, -10, 0, 35)
			TogFrame.BackgroundColor3 = Theme.ElementFrame
			TogFrame.Text = "  " .. togText
			TogFrame.TextColor3 = Theme.Text
			TogFrame.TextXAlignment = Enum.TextXAlignment.Left
			TogFrame.Font = Enum.Font.Gotham
			TogFrame.TextSize = 14
			TogFrame.Parent = Page
			Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 4)
			ApplyDepth(TogFrame)

			if togType == "Switch" then
				local SwitchBg = Instance.new("Frame")
				SwitchBg.Name = GenerateObfuscatedName()
				SwitchBg.Size = UDim2.new(0, 40, 0, 20)
				SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
				SwitchBg.BackgroundColor3 = state and Theme.Accent or Theme.Background
				SwitchBg.Parent = TogFrame
				Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
				ApplyDepth(SwitchBg)

				local SwitchCircle = Instance.new("Frame")
				SwitchCircle.Name = GenerateObfuscatedName()
				SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
				SwitchCircle.Position = UDim2.new(0, state and 22 or 2, 0.5, -8)
				SwitchCircle.BackgroundColor3 = Theme.Text
				SwitchCircle.Parent = SwitchBg
				Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)

				TogFrame.MouseButton1Click:Connect(function()
					state = not state
					Tween(SwitchBg, {BackgroundColor3 = state and Theme.Accent or Theme.Background}, 0.2)
					Tween(SwitchCircle, {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}, 0.2)
					callback(state)
				end)

			elseif togType == "Checkbox" then
				local CheckBox = Instance.new("ImageLabel")
				CheckBox.Name = GenerateObfuscatedName()
				CheckBox.Size = UDim2.new(0, 20, 0, 20)
				CheckBox.Position = UDim2.new(1, -35, 0.5, -10)
				CheckBox.BackgroundTransparency = 1
				CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
				CheckBox.ImageColor3 = state and Theme.Accent or Theme.TextDark
				CheckBox.Parent = TogFrame

				TogFrame.MouseButton1Click:Connect(function()
					state = not state
					CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
					Tween(CheckBox, {ImageColor3 = state and Theme.Accent or Theme.TextDark}, 0.2)
					callback(state)
				end)
			end
		end

		--// ELEMENT: SLIDER
		function TabElements:CreateSlider(config)
			local sName = config.Name or "Slider"
			local min = config.Min or 0
			local max = config.Max or 100
			local default = config.Default or min
			local callback = config.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Name = GenerateObfuscatedName()
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)
			SliderFrame.BackgroundColor3 = Theme.ElementFrame
			SliderFrame.Parent = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)
			ApplyDepth(SliderFrame)

			local Label = Instance.new("TextLabel")
			Label.Name = GenerateObfuscatedName()
			Label.Size = UDim2.new(1, -20, 0, 25)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = sName
			Label.TextColor3 = Theme.Text
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.Parent = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Name = GenerateObfuscatedName()
			ValueLabel.Size = UDim2.new(0, 50, 0, 25)
			ValueLabel.Position = UDim2.new(1, -60, 0, 0)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(default)
			ValueLabel.TextColor3 = Theme.TextDark
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.TextSize = 14
			ValueLabel.Parent = SliderFrame

			local BarBg = Instance.new("TextButton")
			BarBg.Name = GenerateObfuscatedName()
			BarBg.Size = UDim2.new(1, -20, 0, 6)
			BarBg.Position = UDim2.new(0, 10, 0, 32)
			BarBg.BackgroundColor3 = Theme.Background
			BarBg.Text = ""
			BarBg.Parent = SliderFrame
			Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

			local BarFill = Instance.new("Frame")
			BarFill.Name = GenerateObfuscatedName()
			local percent = (default - min) / (max - min)
			BarFill.Size = UDim2.new(percent, 0, 1, 0)
			BarFill.BackgroundColor3 = Theme.Accent
			BarFill.Parent = BarBg
			Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
			ApplyDepth(BarFill, Color3.new(1,1,1), 0.5)

			local dragging = false
			local function updateSlider(input)
				local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
				local val = math.floor(min + ((max - min) * pos))
				Tween(BarFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
				ValueLabel.Text = tostring(val)
				callback(val)
			end

			BarBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
			end)
		end

		--// ELEMENT: DROPDOWN
		function TabElements:CreateDropdown(config)
			local dName = config.Name or "Dropdown"
			local options = config.Options or {}
			local callback = config.Callback or function() end

			local DropFrame = Instance.new("Frame")
			DropFrame.Name = GenerateObfuscatedName()
			DropFrame.Size = UDim2.new(1, -10, 0, 35)
			DropFrame.BackgroundColor3 = Theme.ElementFrame
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = Page
			Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 4)
			ApplyDepth(DropFrame)

			local DropBtn = Instance.new("TextButton")
			DropBtn.Name = GenerateObfuscatedName()
			DropBtn.Size = UDim2.new(1, 0, 0, 35)
			DropBtn.BackgroundTransparency = 1
			DropBtn.Text = "  " .. dName
			DropBtn.TextColor3 = Theme.Text
			DropBtn.TextXAlignment = Enum.TextXAlignment.Left
			DropBtn.Font = Enum.Font.Gotham
			DropBtn.TextSize = 14
			DropBtn.Parent = DropFrame

			local Arrow = Instance.new("TextLabel")
			Arrow.Name = GenerateObfuscatedName()
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Position = UDim2.new(1, -30, 0.5, -10)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "+"
			Arrow.TextColor3 = Theme.TextDark
			Arrow.Font = Enum.Font.GothamBold
			Arrow.TextSize = 18
			Arrow.Parent = DropBtn

			local OptionsLayout = Instance.new("UIListLayout")
			OptionsLayout.Name = GenerateObfuscatedName()
			OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			OptionsLayout.Parent = DropFrame

			-- Dummy padding to push options down
			local Padding = Instance.new("UIPadding")
			Padding.PaddingTop = UDim.new(0, 35)
			Padding.Parent = DropFrame

			local open = false
			DropBtn.MouseButton1Click:Connect(function()
				open = not open
				Tween(Arrow, {Rotation = open and 45 or 0}, 0.2)
				local goalSize = open and 35 + (#options * 30) or 35
				Tween(DropFrame, {Size = UDim2.new(1, -10, 0, goalSize)}, 0.2)
			end)

			for _, opt in ipairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Name = GenerateObfuscatedName()
				OptBtn.Size = UDim2.new(1, 0, 0, 30)
				OptBtn.BackgroundColor3 = Theme.TabContainer
				OptBtn.Text = opt
				OptBtn.TextColor3 = Theme.TextDark
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 13
				OptBtn.Parent = DropFrame

				OptBtn.MouseButton1Click:Connect(function()
					DropBtn.Text = "  " .. dName .. " : " .. opt
					open = false
					Tween(Arrow, {Rotation = 0}, 0.2)
					Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 35)}, 0.2)
					callback(opt)
				end)
			end
		end

		return TabElements
	end

	return WindowObj
end

--------------------------------------------------------------------------------
-- // HOW TO USE THE VELTRUM UI LIBRARY //
--------------------------------------------------------------------------------

local Window = Veltrum:CreateWindow({
	Title = "Veltrum UI | siv",
	ToggleKey = Enum.KeyCode.LeftShift
})

-- Creating Tabs
local MainTab = Window:CreateTab("General")
local SettingsTab = Window:CreateTab("Visuals")
local ConfigTab = Window:CreateTab("Config")

-- Creating Buttons
MainTab:CreateButton({
	Name = "Kill Player",
	Callback = function()
		print("Kill Player clicked!")
	end
})

-- Creating Toggle (Switch Version)
MainTab:CreateToggle({
	Name = "Aimbot [Switch]",
	Type = "Switch",
	Default = false,
	Callback = function(state)
		print("Aimbot toggled:", state)
	end
})

-- Creating Toggle (Checkbox Version)
MainTab:CreateToggle({
	Name = "ESP [Checkbox]",
	Type = "Checkbox",
	Default = true,
	Callback = function(state)
		print("ESP toggled:", state)
	end
})

-- Creating Sliders
SettingsTab:CreateSlider({
	Name = "FOV Adjust",
	Min = 70,
	Max = 120,
	Default = 90,
	Callback = function(value)
		print("FOV changed to", value)
	end
})

-- Creating Dropdowns
SettingsTab:CreateDropdown({
	Name = "Hitbox Target",
	Options = {"Head", "Torso", "HumanoidRootPart"},
	Callback = function(selected)
		print("Hitbox changed to:", selected)
	end
})

ConfigTab:CreateButton({
	Name = "Unload UI",
	Callback = function()
		if getgenv().Veltrum_Instance then getgenv().Veltrum_Instance:Destroy() end
		if getgenv().Veltrum_Blur then getgenv().Veltrum_Blur:Destroy() end
	end
})
