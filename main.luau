local Veltrum = {
	Version = "1.0.0",
	Creator = "siv"
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(12, 12, 12),
	Nav = Color3.fromRGB(16, 16, 16),
	Element = Color3.fromRGB(22, 22, 22),
	Hover = Color3.fromRGB(28, 28, 28),
	Click = Color3.fromRGB(35, 35, 35),
	Stroke = Color3.fromRGB(40, 40, 40),
	Accent = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(230, 230, 230),
	TextDark = Color3.fromRGB(140, 140, 140)
}

local Icons = {
	Close = "rbxassetid://4458805218",
	CheckboxOff = "rbxassetid://4458801920",
	CheckboxOn = "rbxassetid://4458804273"
}

local function GenId()
	return HttpService:GenerateGUID(false):gsub("-", "")
end

local function Tween(obj, props, time, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function ApplyDepth(inst, color, thick)
	local stroke = Instance.new("UIStroke")
	stroke.Name = GenId()
	stroke.Color = color or Theme.Stroke
	stroke.Thickness = thick or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = inst

	local grad = Instance.new("UIGradient")
	grad.Name = GenId()
	grad.Rotation = 90
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.6, 0.6, 0.6))
	})
	grad.Parent = stroke
end

local function MakeDraggable(top, main)
	local drag, inp, start, pos
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			start = i.Position
			pos = main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
			end)
		end
	end)
	top.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then inp = i end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i == inp and drag then
			local delta = i.Position - start
			main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
		end
	end)
end

local function BindFrameButton(frame, callback)
	frame.Active = true
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	local hovering = false

	frame.MouseEnter:Connect(function()
		hovering = true
		Tween(frame, {BackgroundColor3 = Theme.Hover}, 0.15)
	end)
	frame.MouseLeave:Connect(function()
		hovering = false
		Tween(frame, {BackgroundColor3 = Theme.Element}, 0.15)
		Tween(scale, {Scale = 1}, 0.15, Enum.EasingStyle.Back)
	end)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Tween(frame, {BackgroundColor3 = Theme.Click}, 0.1)
			Tween(scale, {Scale = 0.95}, 0.1)
		end
	end)
	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Tween(frame, {BackgroundColor3 = hovering and Theme.Hover or Theme.Element}, 0.1)
			Tween(scale, {Scale = 1}, 0.15, Enum.EasingStyle.Back)
			if hovering and callback then callback() end
		end
	end)
end

if getgenv().Veltrum_Instance then getgenv().Veltrum_Instance:Destroy() end
if getgenv().Veltrum_Blur then getgenv().Veltrum_Blur:Destroy() end

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = GenId()
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
getgenv().Veltrum_Blur = BlurEffect

function Veltrum:CreateWindow(config)
	local Title = config.Title or "Veltrum"
	local ToggleKey = config.ToggleKey or Enum.KeyCode.LeftShift

	local SG = Instance.new("ScreenGui")
	SG.Name = GenId()
	SG.ResetOnSpawn = false
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
	SG.Parent = CoreGui
	getgenv().Veltrum_Instance = SG

	local Main = Instance.new("Frame")
	Main.Name = GenId()
	Main.Size = UDim2.new(0, 600, 0, 420)
	Main.Position = UDim2.new(0.5, -300, 0.5, -210)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = SG
	
	ApplyDepth(Main, Theme.Stroke, 1.5)

	local Topbar = Instance.new("Frame")
	Topbar.Name = GenId()
	Topbar.Size = UDim2.new(1, 0, 0, 30)
	Topbar.BackgroundColor3 = Theme.Background
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main
	MakeDraggable(Topbar, Main)

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Name = GenId()
	TitleLbl.Size = UDim2.new(1, -40, 1, 0)
	TitleLbl.Position = UDim2.new(0, 10, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Text = Title
	TitleLbl.TextColor3 = Theme.Text
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 14
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Topbar

	local CloseBtn = Instance.new("Frame")
	CloseBtn.Name = GenId()
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -30, 0, 0)
	CloseBtn.BackgroundColor3 = Theme.Background
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Parent = Topbar

	local CloseImg = Instance.new("ImageLabel")
	CloseImg.Name = GenId()
	CloseImg.Size = UDim2.new(0, 14, 0, 14)
	CloseImg.Position = UDim2.new(0.5, -7, 0.5, -7)
	CloseImg.BackgroundTransparency = 1
	CloseImg.Image = Icons.Close
	CloseImg.ImageColor3 = Theme.TextDark
	CloseImg.Parent = CloseBtn

	BindFrameButton(CloseBtn, function()
		SG:Destroy()
		BlurEffect:Destroy()
	end)

	local Content = Instance.new("Frame")
	Content.Name = GenId()
	Content.Size = UDim2.new(1, -20, 1, -100)
	Content.Position = UDim2.new(0, 10, 0, 40)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local BottomNav = Instance.new("Frame")
	BottomNav.Name = GenId()
	BottomNav.Size = UDim2.new(1, 0, 0, 50)
	BottomNav.Position = UDim2.new(0, 0, 1, -50)
	BottomNav.BackgroundColor3 = Theme.Nav
	BottomNav.BorderSizePixel = 0
	BottomNav.Parent = Main
	ApplyDepth(BottomNav, Theme.Stroke, 1)

	local AvatarBtn = Instance.new("Frame")
	AvatarBtn.Name = GenId()
	AvatarBtn.Size = UDim2.new(0, 50, 0, 50)
	AvatarBtn.Position = UDim2.new(0, 0, 0, 0)
	AvatarBtn.BackgroundColor3 = Theme.Nav
	AvatarBtn.BorderSizePixel = 0
	AvatarBtn.Parent = BottomNav

	local AvatarImg = Instance.new("ImageLabel")
	AvatarImg.Name = GenId()
	AvatarImg.Size = UDim2.new(0, 34, 0, 34)
	AvatarImg.Position = UDim2.new(0.5, -17, 0.5, -17)
	AvatarImg.BackgroundTransparency = 1
	AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	AvatarImg.Parent = AvatarBtn

	local ProfilePanel = Instance.new("Frame")
	ProfilePanel.Name = GenId()
	ProfilePanel.Size = UDim2.new(0, 220, 0, 120)
	ProfilePanel.Position = UDim2.new(0, 10, 1, 10)
	ProfilePanel.BackgroundColor3 = Theme.Nav
	ProfilePanel.BorderSizePixel = 0
	ProfilePanel.ZIndex = 10
	ProfilePanel.Parent = Main
	ApplyDepth(ProfilePanel, Theme.Stroke, 1)

	local ProfName = Instance.new("TextLabel")
	ProfName.Size = UDim2.new(1, -20, 0, 30)
	ProfName.Position = UDim2.new(0, 10, 0, 10)
	ProfName.BackgroundTransparency = 1
	ProfName.Text = LocalPlayer.DisplayName
	ProfName.TextColor3 = Theme.Accent
	ProfName.Font = Enum.Font.GothamBold
	ProfName.TextSize = 18
	ProfName.TextXAlignment = Enum.TextXAlignment.Left
	ProfName.ZIndex = 10
	ProfName.Parent = ProfilePanel

	local ProfUser = Instance.new("TextLabel")
	ProfUser.Size = UDim2.new(1, -20, 0, 20)
	ProfUser.Position = UDim2.new(0, 10, 0, 40)
	ProfUser.BackgroundTransparency = 1
	ProfUser.Text = "@" .. LocalPlayer.Name
	ProfUser.TextColor3 = Theme.TextDark
	ProfUser.Font = Enum.Font.Gotham
	ProfUser.TextSize = 13
	ProfUser.TextXAlignment = Enum.TextXAlignment.Left
	ProfUser.ZIndex = 10
	ProfUser.Parent = ProfilePanel

	local ProfID = Instance.new("TextLabel")
	ProfID.Size = UDim2.new(1, -20, 0, 20)
	ProfID.Position = UDim2.new(0, 10, 0, 65)
	ProfID.BackgroundTransparency = 1
	ProfID.Text = "ID: " .. LocalPlayer.UserId
	ProfID.TextColor3 = Theme.TextDark
	ProfID.Font = Enum.Font.Gotham
	ProfID.TextSize = 13
	ProfID.TextXAlignment = Enum.TextXAlignment.Left
	ProfID.ZIndex = 10
	ProfID.Parent = ProfilePanel

	local ProfileOpen = false
	BindFrameButton(AvatarBtn, function()
		ProfileOpen = not ProfileOpen
		if ProfileOpen then
			Tween(ProfilePanel, {Position = UDim2.new(0, 10, 1, -180)}, 0.4, Enum.EasingStyle.Exponential)
		else
			Tween(ProfilePanel, {Position = UDim2.new(0, 10, 1, 10)}, 0.4, Enum.EasingStyle.Exponential)
		end
	end)

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Name = GenId()
	TabScroll.Size = UDim2.new(1, -60, 1, 0)
	TabScroll.Position = UDim2.new(0, 60, 0, 0)
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.ScrollBarThickness = 0
	TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	TabScroll.Parent = BottomNav

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Name = GenId()
	TabListLayout.FillDirection = Enum.FillDirection.Horizontal
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 10)
	TabListLayout.Parent = TabScroll

	local TabPad = Instance.new("UIPadding")
	TabPad.PaddingTop = UDim.new(0, 10)
	TabPad.PaddingBottom = UDim.new(0, 10)
	TabPad.Parent = TabScroll

	TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabScroll.CanvasSize = UDim2.new(0, TabListLayout.AbsoluteContentSize.X, 0, 0)
	end)

	local Toggled = true
	local DefaultFOV = Camera.FieldOfView

	local function ToggleUI()
		Toggled = not Toggled
		SG.Enabled = Toggled
		if Toggled then
			Tween(BlurEffect, {Size = 24}, 0.5, Enum.EasingStyle.Exponential)
			Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.5, Enum.EasingStyle.Exponential)
			Main.Size = UDim2.new(0, 550, 0, 380)
			Tween(Main, {Size = UDim2.new(0, 600, 0, 420)}, 0.6, Enum.EasingStyle.Elastic)
		else
			Tween(BlurEffect, {Size = 0}, 0.5, Enum.EasingStyle.Exponential)
			Tween(Camera, {FieldOfView = DefaultFOV}, 0.5, Enum.EasingStyle.Exponential)
		end
	end

	Tween(BlurEffect, {Size = 24}, 0.5, Enum.EasingStyle.Exponential)
	Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.5, Enum.EasingStyle.Exponential)
	Main.Size = UDim2.new(0, 550, 0, 380)
	Tween(Main, {Size = UDim2.new(0, 600, 0, 420)}, 0.6, Enum.EasingStyle.Elastic)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == ToggleKey then ToggleUI() end
	end)

	local WindowObj = {}
	local FirstTab = true

	function WindowObj:CreateTab(tabName)
		local TabBtn = Instance.new("Frame")
		TabBtn.Name = GenId()
		TabBtn.Size = UDim2.new(0, 100, 1, 0)
		TabBtn.BackgroundColor3 = FirstTab and Theme.Element or Theme.Nav
		TabBtn.BorderSizePixel = 0
		TabBtn.Parent = TabScroll
		ApplyDepth(TabBtn, Theme.Stroke, 1)
		
		local TabScale = Instance.new("UIScale", TabBtn)

		local TabLbl = Instance.new("TextLabel")
		TabLbl.Name = GenId()
		TabLbl.Size = UDim2.new(1, 0, 1, 0)
		TabLbl.BackgroundTransparency = 1
		TabLbl.Text = tabName
		TabLbl.TextColor3 = FirstTab and Theme.Accent or Theme.TextDark
		TabLbl.Font = Enum.Font.GothamMedium
		TabLbl.TextSize = 13
		TabLbl.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Name = GenId()
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = FirstTab
		Page.Parent = Content

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Name = GenId()
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 5)
		end)

		local hovering = false
		TabBtn.Active = true
		TabBtn.MouseEnter:Connect(function() hovering = true Tween(TabBtn, {BackgroundColor3 = Theme.Hover}, 0.15) end)
		TabBtn.MouseLeave:Connect(function() hovering = false Tween(TabBtn, {BackgroundColor3 = Page.Visible and Theme.Element or Theme.Nav}, 0.15) Tween(TabScale, {Scale=1},0.15) end)
		TabBtn.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				Tween(TabScale, {Scale = 0.92}, 0.15)
			end
		end)
		TabBtn.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				Tween(TabScale, {Scale = 1}, 0.2, Enum.EasingStyle.Back)
				if hovering then
					for _, child in pairs(Content:GetChildren()) do
						if child:IsA("ScrollingFrame") then child.Visible = false end
					end
					for _, child in pairs(TabScroll:GetChildren()) do
						if child:IsA("Frame") then
							Tween(child, {BackgroundColor3 = Theme.Nav}, 0.2)
							Tween(child:FindFirstChildOfClass("TextLabel"), {TextColor3 = Theme.TextDark}, 0.2)
						end
					end
					Page.Visible = true
					Page.Position = UDim2.new(0, 0, 0, 20)
					Tween(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Exponential)
					Tween(TabBtn, {BackgroundColor3 = Theme.Element}, 0.2)
					Tween(TabLbl, {TextColor3 = Theme.Accent}, 0.2)
				end
			end
		end)

		FirstTab = false
		local TabElements = {}

		function TabElements:CreateButton(config)
			local btnText = config.Name or "Button"
			local cb = config.Callback or function() end

			local BtnFrame = Instance.new("Frame")
			BtnFrame.Name = GenId()
			BtnFrame.Size = UDim2.new(1, -10, 0, 38)
			BtnFrame.BackgroundColor3 = Theme.Element
			BtnFrame.BorderSizePixel = 0
			BtnFrame.Parent = Page
			ApplyDepth(BtnFrame)

			local BtnLbl = Instance.new("TextLabel")
			BtnLbl.Name = GenId()
			BtnLbl.Size = UDim2.new(1, 0, 1, 0)
			BtnLbl.BackgroundTransparency = 1
			BtnLbl.Text = btnText
			BtnLbl.TextColor3 = Theme.Text
			BtnLbl.Font = Enum.Font.Gotham
			BtnLbl.TextSize = 13
			BtnLbl.Parent = BtnFrame

			BindFrameButton(BtnFrame, cb)
		end

		function TabElements:CreateToggle(config)
			local togText = config.Name or "Toggle"
			local togType = config.Type or "Switch"
			local cb = config.Callback or function() end
			local state = config.Default or false

			local TogFrame = Instance.new("Frame")
			TogFrame.Name = GenId()
			TogFrame.Size = UDim2.new(1, -10, 0, 38)
			TogFrame.BackgroundColor3 = Theme.Element
			TogFrame.BorderSizePixel = 0
			TogFrame.Parent = Page
			ApplyDepth(TogFrame)

			local TogLbl = Instance.new("TextLabel")
			TogLbl.Name = GenId()
			TogLbl.Size = UDim2.new(1, -60, 1, 0)
			TogLbl.Position = UDim2.new(0, 10, 0, 0)
			TogLbl.BackgroundTransparency = 1
			TogLbl.Text = togText
			TogLbl.TextColor3 = Theme.Text
			TogLbl.TextXAlignment = Enum.TextXAlignment.Left
			TogLbl.Font = Enum.Font.Gotham
			TogLbl.TextSize = 13
			TogLbl.Parent = TogFrame

			if togType == "Switch" then
				local SwitchBg = Instance.new("Frame")
				SwitchBg.Name = GenId()
				SwitchBg.Size = UDim2.new(0, 36, 0, 18)
				SwitchBg.Position = UDim2.new(1, -46, 0.5, -9)
				SwitchBg.BackgroundColor3 = state and Theme.Accent or Theme.Background
				SwitchBg.BorderSizePixel = 0
				SwitchBg.Parent = TogFrame
				ApplyDepth(SwitchBg)

				local SwitchBlock = Instance.new("Frame")
				SwitchBlock.Name = GenId()
				SwitchBlock.Size = UDim2.new(0, 14, 0, 14)
				SwitchBlock.Position = UDim2.new(0, state and 20 or 2, 0.5, -7)
				SwitchBlock.BackgroundColor3 = state and Theme.Background or Theme.TextDark
				SwitchBlock.BorderSizePixel = 0
				SwitchBlock.Parent = SwitchBg

				BindFrameButton(TogFrame, function()
					state = not state
					Tween(SwitchBg, {BackgroundColor3 = state and Theme.Accent or Theme.Background}, 0.25)
					Tween(SwitchBlock, {
						Position = UDim2.new(0, state and 20 or 2, 0.5, -7),
						BackgroundColor3 = state and Theme.Background or Theme.TextDark
					}, 0.4, Enum.EasingStyle.Exponential)
					cb(state)
				end)

			elseif togType == "Checkbox" then
				local CheckBox = Instance.new("ImageLabel")
				CheckBox.Name = GenId()
				CheckBox.Size = UDim2.new(0, 18, 0, 18)
				CheckBox.Position = UDim2.new(1, -30, 0.5, -9)
				CheckBox.BackgroundTransparency = 1
				CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
				CheckBox.ImageColor3 = state and Theme.Accent or Theme.TextDark
				CheckBox.Parent = TogFrame

				BindFrameButton(TogFrame, function()
					state = not state
					CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
					Tween(CheckBox, {ImageColor3 = state and Theme.Accent or Theme.TextDark}, 0.2)
					local scale = CheckBox:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", CheckBox)
					scale.Scale = 0.7
					Tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
					cb(state)
				end)
			end
		end

		function TabElements:CreateSlider(config)
			local sName = config.Name or "Slider"
			local min = config.Min or 0
			local max = config.Max or 100
			local default = config.Default or min
			local cb = config.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Name = GenId()
			SliderFrame.Size = UDim2.new(1, -10, 0, 55)
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.BorderSizePixel = 0
			SliderFrame.Parent = Page
			ApplyDepth(SliderFrame)

			local Lbl = Instance.new("TextLabel")
			Lbl.Name = GenId()
			Lbl.Size = UDim2.new(1, -20, 0, 25)
			Lbl.Position = UDim2.new(0, 10, 0, 5)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = sName
			Lbl.TextColor3 = Theme.Text
			Lbl.TextXAlignment = Enum.TextXAlignment.Left
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextSize = 13
			Lbl.Parent = SliderFrame

			local ValLbl = Instance.new("TextLabel")
			ValLbl.Name = GenId()
			ValLbl.Size = UDim2.new(0, 50, 0, 25)
			ValLbl.Position = UDim2.new(1, -60, 0, 5)
			ValLbl.BackgroundTransparency = 1
			ValLbl.Text = tostring(default)
			ValLbl.TextColor3 = Theme.TextDark
			ValLbl.TextXAlignment = Enum.TextXAlignment.Right
			ValLbl.Font = Enum.Font.Gotham
			ValLbl.TextSize = 13
			ValLbl.Parent = SliderFrame

			local BarBg = Instance.new("Frame")
			BarBg.Name = GenId()
			BarBg.Size = UDim2.new(1, -20, 0, 6)
			BarBg.Position = UDim2.new(0, 10, 0, 38)
			BarBg.BackgroundColor3 = Theme.Background
			BarBg.BorderSizePixel = 0
			BarBg.Active = true
			BarBg.Parent = SliderFrame

			local BarFill = Instance.new("Frame")
			BarFill.Name = GenId()
			local pct = (default - min) / (max - min)
			BarFill.Size = UDim2.new(pct, 0, 1, 0)
			BarFill.BackgroundColor3 = Theme.Accent
			BarFill.BorderSizePixel = 0
			BarFill.Parent = BarBg
			ApplyDepth(BarFill, Color3.new(1,1,1), 0)

			local dragging = false
			local function update(input)
				local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
				local val = math.floor(min + ((max - min) * pos))
				Tween(BarFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.15, Enum.EasingStyle.Quad)
				ValLbl.Text = tostring(val)
				cb(val)
			end

			BarBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
					dragging = true 
					update(i) 
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
					dragging = false 
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
					update(i) 
				end
			end)
		end

		function TabElements:CreateDropdown(config)
			local dName = config.Name or "Dropdown"
			local opts = config.Options or {}
			local cb = config.Callback or function() end

			local DropFrame = Instance.new("Frame")
			DropFrame.Name = GenId()
			DropFrame.Size = UDim2.new(1, -10, 0, 38)
			DropFrame.BackgroundColor3 = Theme.Element
			DropFrame.BorderSizePixel = 0
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = Page
			ApplyDepth(DropFrame)

			local DropBtn = Instance.new("Frame")
			DropBtn.Name = GenId()
			DropBtn.Size = UDim2.new(1, 0, 0, 38)
			DropBtn.BackgroundTransparency = 1
			DropBtn.Parent = DropFrame

			local DropLbl = Instance.new("TextLabel")
			DropLbl.Name = GenId()
			DropLbl.Size = UDim2.new(1, -40, 1, 0)
			DropLbl.Position = UDim2.new(0, 10, 0, 0)
			DropLbl.BackgroundTransparency = 1
			DropLbl.Text = dName
			DropLbl.TextColor3 = Theme.Text
			DropLbl.TextXAlignment = Enum.TextXAlignment.Left
			DropLbl.Font = Enum.Font.Gotham
			DropLbl.TextSize = 13
			DropLbl.Parent = DropBtn

			local Arrow = Instance.new("TextLabel")
			Arrow.Name = GenId()
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Position = UDim2.new(1, -30, 0.5, -10)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "+"
			Arrow.TextColor3 = Theme.TextDark
			Arrow.Font = Enum.Font.GothamBold
			Arrow.TextSize = 16
			Arrow.Parent = DropBtn

			local OptLayout = Instance.new("UIListLayout")
			OptLayout.Name = GenId()
			OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
			OptLayout.Parent = DropFrame

			local Pad = Instance.new("UIPadding")
			Pad.PaddingTop = UDim.new(0, 38)
			Pad.Parent = DropFrame

			local open = false
			BindFrameButton(DropBtn, function()
				open = not open
				Tween(Arrow, {Rotation = open and 45 or 0}, 0.3, Enum.EasingStyle.Back)
				local goalSize = open and 38 + (#opts * 32) or 38
				Tween(DropFrame, {Size = UDim2.new(1, -10, 0, goalSize)}, 0.4, Enum.EasingStyle.Exponential)
			end)

			for _, opt in ipairs(opts) do
				local OptBtn = Instance.new("Frame")
				OptBtn.Name = GenId()
				OptBtn.Size = UDim2.new(1, 0, 0, 32)
				OptBtn.BackgroundColor3 = Theme.Element
				OptBtn.BorderSizePixel = 0
				OptBtn.Parent = DropFrame

				local OptLbl = Instance.new("TextLabel")
				OptLbl.Size = UDim2.new(1, -20, 1, 0)
				OptLbl.Position = UDim2.new(0, 20, 0, 0)
				OptLbl.BackgroundTransparency = 1
				OptLbl.Text = opt
				OptLbl.TextColor3 = Theme.TextDark
				OptLbl.TextXAlignment = Enum.TextXAlignment.Left
				OptLbl.Font = Enum.Font.Gotham
				OptLbl.TextSize = 12
				OptLbl.Parent = OptBtn

				BindFrameButton(OptBtn, function()
					DropLbl.Text = dName .. " : " .. opt
					open = false
					Tween(Arrow, {Rotation = 0}, 0.3, Enum.EasingStyle.Back)
					Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 38)}, 0.4, Enum.EasingStyle.Exponential)
					cb(opt)
				end)
			end
		end

		return TabElements
	end

	return WindowObj
end

local Window = Veltrum:CreateWindow({
	Title = "Veltrum UI",
	ToggleKey = Enum.KeyCode.LeftShift
})

local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

CombatTab:CreateButton({
	Name = "Insta-Kill",
	Callback = function()
		print("Killed")
	end
})

CombatTab:CreateToggle({
	Name = "Aimbot",
	Type = "Switch",
	Default = false,
	Callback = function(v)
		print("Aimbot", v)
	end
})

CombatTab:CreateToggle({
	Name = "Silent Aim",
	Type = "Checkbox",
	Default = true,
	Callback = function(v)
		print("Silent Aim", v)
	end
})

VisualsTab:CreateSlider({
	Name = "Field of View",
	Min = 70,
	Max = 120,
	Default = 90,
	Callback = function(v)
		workspace.CurrentCamera.FieldOfView = v
	end
})

VisualsTab:CreateDropdown({
	Name = "ESP Color",
	Options = {"Red", "Blue", "Green", "White"},
	Callback = function(v)
		print("Color", v)
	end
})

SettingsTab:CreateButton({
	Name = "Unload UI",
	Callback = function()
		if getgenv().Veltrum_Instance then getgenv().Veltrum_Instance:Destroy() end
		if getgenv().Veltrum_Blur then getgenv().Veltrum_Blur:Destroy() end
	end
})
