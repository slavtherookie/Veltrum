local Veltrum = { Version = "0.2", Creator = "siv" }

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Built-in Unload Event for external scripts to bind their cleanup logic
local UnloadEvent = Instance.new("BindableEvent")
Veltrum.UnloadEvent = UnloadEvent.Event

local DefaultTheme = {
	Background = Color3.fromRGB(10, 10, 10),
	Nav = Color3.fromRGB(15, 15, 15),
	Element = Color3.fromRGB(20, 20, 20),
	Hover = Color3.fromRGB(26, 26, 26),
	Click = Color3.fromRGB(35, 35, 35),
	Stroke = Color3.fromRGB(38, 38, 38),
	Accent = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(235, 235, 235),
	TextDark = Color3.fromRGB(130, 130, 130)
}

local Icons = {
	Close = "rbxassetid://4458805208",
	CheckboxOff = "rbxassetid://4458801905",
	CheckboxOn = "rbxassetid://4458804262",
	ColorWheel = "rbxassetid://1003599877"
}

-- Cleanup previous instances safely
function Veltrum:Unload()
	UnloadEvent:Fire()
	if getgenv().Veltrum_Instance then 
		getgenv().Veltrum_Instance:Destroy() 
		getgenv().Veltrum_Instance = nil
	end
	if getgenv().Veltrum_Blur then 
		getgenv().Veltrum_Blur:Destroy() 
		getgenv().Veltrum_Blur = nil
	end
end

if getgenv().Veltrum_Instance then 
	Veltrum:Unload() 
end

local function GenId() return HttpService:GenerateGUID(false):gsub("-", "") end

local function Tween(obj, props, time, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Exponential, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function ApplyDepth(inst, strokeColor, thick, cornerRadius, gradientColors)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = cornerRadius or UDim.new(0, 4)
	corner.Parent = inst

	local stroke = Instance.new("UIStroke")
	stroke.Name = GenId()
	stroke.Color = strokeColor or DefaultTheme.Stroke
	stroke.Thickness = thick or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = inst

	local grad = Instance.new("UIGradient")
	grad.Name = GenId()
	grad.Rotation = 90
	grad.Color = gradientColors or ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.6, 0.6, 0.6))
	})
	grad.Parent = stroke
end

local function BindFrameButton(frame, callback, theme)
	frame.Active = true
	local scale = Instance.new("UIScale", frame)
	local hovering, pressing = false, false

	frame.MouseEnter:Connect(function()
		hovering = true
		Tween(frame, {BackgroundColor3 = theme.Hover}, 0.2)
	end)
	frame.MouseLeave:Connect(function()
		hovering = false
		if not pressing then
			Tween(frame, {BackgroundColor3 = theme.Element}, 0.2)
			Tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
		end
	end)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressing = true
			Tween(frame, {BackgroundColor3 = theme.Click}, 0.1)
			Tween(scale, {Scale = 0.94}, 0.2, Enum.EasingStyle.Back)
		end
	end)
	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressing = false
			Tween(frame, {BackgroundColor3 = hovering and theme.Hover or theme.Element}, 0.2)
			Tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
			if hovering and callback then callback() end
		end
	end)
end

local SG = Instance.new("ScreenGui")
SG.Name = GenId()
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
SG.Parent = CoreGui
getgenv().Veltrum_Instance = SG

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = GenId()
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
getgenv().Veltrum_Blur = BlurEffect

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = GenId()
NotifContainer.Size = UDim2.new(0, 300, 1, -20)
NotifContainer.Position = UDim2.new(1, -320, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = SG

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

function Veltrum:Notify(config)
	local title = config.Title or "Notification"
	local text = config.Content or ""
	local duration = config.Duration or 3
	local img = config.Image
	local customTheme = config.Theme or DefaultTheme

	local NFrame = Instance.new("Frame")
	NFrame.Size = UDim2.new(1, 400, 0, img and 70 or 60)
	NFrame.BackgroundTransparency = 1
	NFrame.BackgroundColor3 = customTheme.Element
	NFrame.BorderSizePixel = 0
	NFrame.Parent = NotifContainer
	ApplyDepth(NFrame, customTheme.Stroke, 1, UDim.new(0, 6))
	
	local stroke = NFrame:FindFirstChildOfClass("UIStroke")
	if stroke then stroke.Transparency = 1 end

	local NScale = Instance.new("UIScale", NFrame)
	NScale.Scale = 0.8

	local NT = Instance.new("TextLabel")
	NT.Size = UDim2.new(1, img and -70 or -20, 0, 20)
	NT.Position = UDim2.new(0, img and 60 or 10, 0, 10)
	NT.BackgroundTransparency = 1
	NT.Text = title
	NT.TextColor3 = customTheme.Accent
	NT.TextTransparency = 1
	NT.Font = Enum.Font.GothamBold
	NT.TextSize = 14
	NT.TextXAlignment = Enum.TextXAlignment.Left
	NT.Parent = NFrame

	local ND = Instance.new("TextLabel")
	ND.Size = UDim2.new(1, img and -70 or -20, 0, 20)
	ND.Position = UDim2.new(0, img and 60 or 10, 0, 30)
	ND.BackgroundTransparency = 1
	ND.Text = text
	ND.TextColor3 = customTheme.TextDark
	ND.TextTransparency = 1
	ND.Font = Enum.Font.Gotham
	ND.TextSize = 12
	ND.TextWrapped = true
	ND.TextXAlignment = Enum.TextXAlignment.Left
	ND.TextYAlignment = Enum.TextYAlignment.Top
	ND.Parent = NFrame

	if img then
		local NI = Instance.new("ImageLabel")
		NI.Size = UDim2.new(0, 40, 0, 40)
		NI.Position = UDim2.new(0, 10, 0, 15)
		NI.BackgroundTransparency = 1
		NI.Image = img
		NI.ImageTransparency = 1
		NI.Parent = NFrame
		Tween(NI, {ImageTransparency = 0}, 0.5)
	end

	Tween(NFrame, {Size = UDim2.new(1, 0, 0, img and 70 or 60), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Exponential)
	Tween(NScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back)
	Tween(NT, {TextTransparency = 0}, 0.5)
	Tween(ND, {TextTransparency = 0}, 0.5)
	if stroke then Tween(stroke, {Transparency = 0}, 0.5) end

	task.spawn(function()
		task.wait(duration)
		Tween(NFrame, {Size = UDim2.new(1, 200, 0, img and 70 or 60), BackgroundTransparency = 1}, 0.5)
		Tween(NT, {TextTransparency = 1}, 0.4)
		Tween(ND, {TextTransparency = 1}, 0.4)
		if img then Tween(NFrame:FindFirstChildOfClass("ImageLabel"), {ImageTransparency = 1}, 0.4) end
		if stroke then Tween(stroke, {Transparency = 1}, 0.4) end
		task.wait(0.5)
		NFrame:Destroy()
	end)
end

function Veltrum:CreateWindow(config)
	local Title = config.Title or "Veltrum"
	local Theme = config.Theme or DefaultTheme
	local CornerRadius = config.CornerRadius or UDim.new(0, 6)
	local CustomGradient = config.GradientColors
	
	local WindowObj = {
		ToggleKey = config.ToggleKey or Enum.KeyCode.LeftShift
	}

	local Main = Instance.new("Frame")
	Main.Name = GenId()
	Main.Size = UDim2.new(0, 650, 0, 450)
	Main.Position = UDim2.new(0.5, -325, 0.5, -225)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = SG
	ApplyDepth(Main, Theme.Stroke, 1.5, CornerRadius, CustomGradient)

	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, 0, 0, 35)
	Topbar.BackgroundColor3 = Theme.Background
	Topbar.BorderSizePixel = 0
	Topbar.Active = true
	Topbar.Parent = Main
	Instance.new("UICorner", Topbar).CornerRadius = CornerRadius

	local drag, start, pos
	Topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true start = i.Position pos = Main.Position end
	end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - start
			Main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
		end
	end)

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(1, -40, 1, 0)
	TitleLbl.Position = UDim2.new(0, 15, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Text = Title
	TitleLbl.TextColor3 = Theme.Text
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 14
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Topbar

	local CloseBtn = Instance.new("Frame")
	CloseBtn.Size = UDim2.new(0, 35, 0, 35)
	CloseBtn.Position = UDim2.new(1, -35, 0, 0)
	CloseBtn.BackgroundColor3 = Theme.Background
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Parent = Topbar

	local CloseImg = Instance.new("ImageLabel")
	CloseImg.Size = UDim2.new(0, 14, 0, 14)
	CloseImg.Position = UDim2.new(0.5, -7, 0.5, -7)
	CloseImg.BackgroundTransparency = 1
	CloseImg.Image = Icons.Close
	CloseImg.ImageColor3 = Theme.TextDark
	CloseImg.Parent = CloseBtn

	BindFrameButton(CloseBtn, function()
		Veltrum:Unload()
	end, Theme)

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -30, 1, -110)
	Content.Position = UDim2.new(0, 15, 0, 45)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local BottomNav = Instance.new("Frame")
	BottomNav.Size = UDim2.new(1, 0, 0, 50)
	BottomNav.Position = UDim2.new(0, 0, 1, -50)
	BottomNav.BackgroundColor3 = Theme.Nav
	BottomNav.BorderSizePixel = 0
	BottomNav.Parent = Main
	ApplyDepth(BottomNav, Theme.Stroke, 1, UDim.new(0, 0))

	local AvatarBtn = Instance.new("Frame")
	AvatarBtn.Size = UDim2.new(0, 50, 0, 50)
	AvatarBtn.Position = UDim2.new(0, 10, 0, 0)
	AvatarBtn.BackgroundColor3 = Theme.Nav
	AvatarBtn.BorderSizePixel = 0
	AvatarBtn.Parent = BottomNav

	local AvatarImg = Instance.new("ImageLabel")
	AvatarImg.Size = UDim2.new(0, 30, 0, 30)
	AvatarImg.Position = UDim2.new(0.5, -15, 0.5, -15)
	AvatarImg.BackgroundTransparency = 1
	AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	AvatarImg.Parent = AvatarBtn
	Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

	local ProfilePanel = Instance.new("Frame")
	ProfilePanel.Size = UDim2.new(0, 220, 0, 110)
	ProfilePanel.Position = UDim2.new(0, 10, 1, 10)
	ProfilePanel.BackgroundColor3 = Theme.Nav
	ProfilePanel.BorderSizePixel = 0
	ProfilePanel.ZIndex = 10
	ProfilePanel.Parent = Main
	ApplyDepth(ProfilePanel, Theme.Stroke, 1, CornerRadius)

	local ProfName = Instance.new("TextLabel")
	ProfName.Size = UDim2.new(1, -20, 0, 30)
	ProfName.Position = UDim2.new(0, 10, 0, 10)
	ProfName.BackgroundTransparency = 1
	ProfName.Text = LocalPlayer.DisplayName
	ProfName.TextColor3 = Theme.Accent
	ProfName.Font = Enum.Font.GothamBold
	ProfName.TextSize = 16
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
	ProfUser.TextSize = 12
	ProfUser.TextXAlignment = Enum.TextXAlignment.Left
	ProfUser.ZIndex = 10
	ProfUser.Parent = ProfilePanel

	local ProfileOpen = false
	BindFrameButton(AvatarBtn, function()
		ProfileOpen = not ProfileOpen
		Tween(ProfilePanel, {Position = UDim2.new(0, 10, 1, ProfileOpen and -170 or 10)}, 0.4, Enum.EasingStyle.Exponential)
	end, Theme)

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Size = UDim2.new(1, -70, 1, 0)
	TabScroll.Position = UDim2.new(0, 70, 0, 0)
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.ScrollBarThickness = 0
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	TabScroll.Parent = BottomNav

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.FillDirection = Enum.FillDirection.Horizontal
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 8)
	TabListLayout.Parent = TabScroll

	local TabPad = Instance.new("UIPadding")
	TabPad.PaddingTop = UDim.new(0, 8)
	TabPad.PaddingBottom = UDim.new(0, 8)
	TabPad.Parent = TabScroll

	local Toggled = true
	local DefaultFOV = Camera.FieldOfView

	local function ToggleUI()
		Toggled = not Toggled
		SG.Enabled = Toggled
		if Toggled then
			Tween(BlurEffect, {Size = 24}, 0.5)
			Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.5)
			Main.Size = UDim2.new(0, 600, 0, 400)
			Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.6, Enum.EasingStyle.Elastic)
		else
			Tween(BlurEffect, {Size = 0}, 0.5)
			Tween(Camera, {FieldOfView = DefaultFOV}, 0.5)
		end
	end

	Tween(BlurEffect, {Size = 24}, 0.5)
	Tween(Camera, {FieldOfView = DefaultFOV - 10}, 0.5)
	Main.Size = UDim2.new(0, 600, 0, 400)
	Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.6, Enum.EasingStyle.Elastic)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == WindowObj.ToggleKey then ToggleUI() end
	end)

	local FirstTab = true

	function WindowObj:CreateTab(tabName)
		local TabBtn = Instance.new("Frame")
		TabBtn.Size = UDim2.new(0, 110, 1, 0)
		TabBtn.BackgroundColor3 = FirstTab and Theme.Element or Theme.Nav
		TabBtn.BorderSizePixel = 0
		TabBtn.Parent = TabScroll
		ApplyDepth(TabBtn, Theme.Stroke, 1, CornerRadius)

		local TabLbl = Instance.new("TextLabel")
		TabLbl.Size = UDim2.new(1, 0, 1, 0)
		TabLbl.BackgroundTransparency = 1
		TabLbl.Text = tabName
		TabLbl.TextColor3 = FirstTab and Theme.Accent or Theme.TextDark
		TabLbl.Font = Enum.Font.GothamMedium
		TabLbl.TextSize = 13
		TabLbl.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = FirstTab
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0, 0, 0, 0) -- Handled by AutomaticCanvasSize fixing the clipping completely
		Page.Parent = Content

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingBottom = UDim.new(0, 20)
		PagePadding.PaddingRight = UDim.new(0, 10)
		PagePadding.Parent = Page

		BindFrameButton(TabBtn, function()
			for _, child in pairs(Content:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
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
		end, Theme)

		FirstTab = false
		local TabElements = {}

		function TabElements:CreateSection(config)
			local sText = config.Name or "Section"
			
			local SecFrame = Instance.new("Frame")
			SecFrame.Size = UDim2.new(1, 0, 0, 30)
			SecFrame.BackgroundTransparency = 1
			SecFrame.Parent = Page

			local SecLbl = Instance.new("TextLabel")
			SecLbl.Size = UDim2.new(1, 0, 1, 0)
			SecLbl.BackgroundTransparency = 1
			SecLbl.Text = sText
			SecLbl.TextColor3 = Theme.Accent
			SecLbl.Font = Enum.Font.GothamBold
			SecLbl.TextSize = 14
			SecLbl.TextXAlignment = Enum.TextXAlignment.Left
			SecLbl.Parent = SecFrame

			local Divider = Instance.new("Frame")
			Divider.Size = UDim2.new(1, 0, 0, 2)
			Divider.Position = UDim2.new(0, 0, 1, -2)
			Divider.BackgroundColor3 = Theme.Stroke
			Divider.BorderSizePixel = 0
			Divider.Parent = SecFrame
		end

		function TabElements:CreateLabel(config)
			local lText = config.Name or "Label"
			
			local LblFrame = Instance.new("Frame")
			LblFrame.Size = UDim2.new(1, 0, 0, 25)
			LblFrame.BackgroundTransparency = 1
			LblFrame.Parent = Page

			local LblText = Instance.new("TextLabel")
			LblText.Size = UDim2.new(1, 0, 1, 0)
			LblText.BackgroundTransparency = 1
			LblText.Text = lText
			LblText.TextColor3 = Theme.TextDark
			LblText.Font = Enum.Font.Gotham
			LblText.TextSize = 13
			LblText.TextXAlignment = Enum.TextXAlignment.Left
			LblText.Parent = LblFrame
		end

		function TabElements:CreateButton(config)
			local btnText = config.Name or "Button"
			local cb = config.Callback or function() end

			local BtnFrame = Instance.new("Frame")
			BtnFrame.Size = UDim2.new(1, 0, 0, 42)
			BtnFrame.BackgroundColor3 = Theme.Element
			BtnFrame.BorderSizePixel = 0
			BtnFrame.Parent = Page
			ApplyDepth(BtnFrame, Theme.Stroke, 1, CornerRadius)

			local BtnLbl = Instance.new("TextLabel")
			BtnLbl.Size = UDim2.new(1, 0, 1, 0)
			BtnLbl.BackgroundTransparency = 1
			BtnLbl.Text = btnText
			BtnLbl.TextColor3 = Theme.Text
			BtnLbl.Font = Enum.Font.Gotham
			BtnLbl.TextSize = 13
			BtnLbl.Parent = BtnFrame

			BindFrameButton(BtnFrame, cb, Theme)
		end

		function TabElements:CreateToggle(config)
			local togText = config.Name or "Toggle"
			local togType = config.Type or "Switch"
			local cb = config.Callback or function() end
			local state = config.Default or false

			local TogFrame = Instance.new("Frame")
			TogFrame.Size = UDim2.new(1, 0, 0, 42)
			TogFrame.BackgroundColor3 = Theme.Element
			TogFrame.BorderSizePixel = 0
			TogFrame.Parent = Page
			ApplyDepth(TogFrame, Theme.Stroke, 1, CornerRadius)

			local TogLbl = Instance.new("TextLabel")
			TogLbl.Size = UDim2.new(1, -60, 1, 0)
			TogLbl.Position = UDim2.new(0, 15, 0, 0)
			TogLbl.BackgroundTransparency = 1
			TogLbl.Text = togText
			TogLbl.TextColor3 = Theme.Text
			TogLbl.TextXAlignment = Enum.TextXAlignment.Left
			TogLbl.Font = Enum.Font.Gotham
			TogLbl.TextSize = 13
			TogLbl.Parent = TogFrame

			if togType == "Switch" then
				local SwitchBg = Instance.new("Frame")
				SwitchBg.Size = UDim2.new(0, 40, 0, 20)
				SwitchBg.Position = UDim2.new(1, -55, 0.5, -10)
				SwitchBg.BackgroundColor3 = state and Theme.Accent or Theme.Background
				SwitchBg.BorderSizePixel = 0
				SwitchBg.Parent = TogFrame
				ApplyDepth(SwitchBg, Theme.Stroke, 1, UDim.new(1,0))

				local SwitchBlock = Instance.new("Frame")
				SwitchBlock.Size = UDim2.new(0, 16, 0, 16)
				SwitchBlock.Position = UDim2.new(0, state and 22 or 2, 0.5, -8)
				SwitchBlock.BackgroundColor3 = state and Theme.Background or Theme.TextDark
				SwitchBlock.BorderSizePixel = 0
				SwitchBlock.Parent = SwitchBg
				Instance.new("UICorner", SwitchBlock).CornerRadius = UDim.new(1, 0)

				BindFrameButton(TogFrame, function()
					state = not state
					Tween(SwitchBg, {BackgroundColor3 = state and Theme.Accent or Theme.Background}, 0.25)
					Tween(SwitchBlock, {
						Position = UDim2.new(0, state and 22 or 2, 0.5, -8),
						BackgroundColor3 = state and Theme.Background or Theme.TextDark
					}, 0.4, Enum.EasingStyle.Exponential)
					cb(state)
				end, Theme)

			elseif togType == "Checkbox" then
				local CheckBox = Instance.new("ImageLabel")
				CheckBox.Size = UDim2.new(0, 20, 0, 20)
				CheckBox.Position = UDim2.new(1, -35, 0.5, -10)
				CheckBox.BackgroundTransparency = 1
				CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
				CheckBox.ImageColor3 = state and Theme.Accent or Theme.TextDark
				CheckBox.Parent = TogFrame

				BindFrameButton(TogFrame, function()
					state = not state
					CheckBox.Image = state and Icons.CheckboxOn or Icons.CheckboxOff
					Tween(CheckBox, {ImageColor3 = state and Theme.Accent or Theme.TextDark}, 0.2)
					local scale = CheckBox:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", CheckBox)
					scale.Scale = 0.6
					Tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
					cb(state)
				end, Theme)
			end
		end

		function TabElements:CreateSlider(config)
			local sName = config.Name or "Slider"
			local min = config.Min or 0
			local max = config.Max or 100
			local default = config.Default or min
			local cb = config.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, 0, 0, 60)
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.BorderSizePixel = 0
			SliderFrame.Parent = Page
			ApplyDepth(SliderFrame, Theme.Stroke, 1, CornerRadius)

			local Lbl = Instance.new("TextLabel")
			Lbl.Size = UDim2.new(1, -30, 0, 30)
			Lbl.Position = UDim2.new(0, 15, 0, 5)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = sName
			Lbl.TextColor3 = Theme.Text
			Lbl.TextXAlignment = Enum.TextXAlignment.Left
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextSize = 13
			Lbl.Parent = SliderFrame

			local ValLbl = Instance.new("TextLabel")
			ValLbl.Size = UDim2.new(0, 50, 0, 30)
			ValLbl.Position = UDim2.new(1, -65, 0, 5)
			ValLbl.BackgroundTransparency = 1
			ValLbl.Text = tostring(default)
			ValLbl.TextColor3 = Theme.TextDark
			ValLbl.TextXAlignment = Enum.TextXAlignment.Right
			ValLbl.Font = Enum.Font.Gotham
			ValLbl.TextSize = 13
			ValLbl.Parent = SliderFrame

			local BarBg = Instance.new("Frame")
			BarBg.Size = UDim2.new(1, -30, 0, 6)
			BarBg.Position = UDim2.new(0, 15, 0, 42)
			BarBg.BackgroundColor3 = Theme.Background
			BarBg.BorderSizePixel = 0
			BarBg.Active = true
			BarBg.Parent = SliderFrame
			Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

			local BarFill = Instance.new("Frame")
			local pct = (default - min) / (max - min)
			BarFill.Size = UDim2.new(pct, 0, 1, 0)
			BarFill.BackgroundColor3 = Theme.Accent
			BarFill.BorderSizePixel = 0
			BarFill.Parent = BarBg
			Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
			
			-- Gradient representation for sliders
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.6, 0.6, 0.6))
			})
			gradient.Rotation = 90
			gradient.Parent = BarFill

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
					dragging = true update(i) 
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
			end)
		end
		
		function TabElements:CreateTextBox(config)
			local tbName = config.Name or "TextBox"
			local placeholder = config.Placeholder or "Enter text..."
			local cb = config.Callback or function() end

			local TBFrame = Instance.new("Frame")
			TBFrame.Size = UDim2.new(1, 0, 0, 42)
			TBFrame.BackgroundColor3 = Theme.Element
			TBFrame.BorderSizePixel = 0
			TBFrame.Parent = Page
			ApplyDepth(TBFrame, Theme.Stroke, 1, CornerRadius)

			local TBLbl = Instance.new("TextLabel")
			TBLbl.Size = UDim2.new(1, -120, 1, 0)
			TBLbl.Position = UDim2.new(0, 15, 0, 0)
			TBLbl.BackgroundTransparency = 1
			TBLbl.Text = tbName
			TBLbl.TextColor3 = Theme.Text
			TBLbl.TextXAlignment = Enum.TextXAlignment.Left
			TBLbl.Font = Enum.Font.Gotham
			TBLbl.TextSize = 13
			TBLbl.Parent = TBFrame

			local TextBox = Instance.new("TextBox")
			TextBox.Size = UDim2.new(0, 120, 0, 30)
			TextBox.Position = UDim2.new(1, -130, 0.5, -15)
			TextBox.BackgroundColor3 = Theme.Background
			TextBox.BorderSizePixel = 0
			TextBox.Text = ""
			TextBox.PlaceholderText = placeholder
			TextBox.TextColor3 = Theme.Text
			TextBox.Font = Enum.Font.Gotham
			TextBox.TextSize = 12
			TextBox.Parent = TBFrame
			ApplyDepth(TextBox, Theme.Stroke, 1, UDim.new(0, 4))

			TextBox.FocusLost:Connect(function(enterPressed)
				cb(TextBox.Text)
			end)
		end
		
		function TabElements:CreateKeybind(config)
			local kName = config.Name or "Keybind"
			local defaultKey = config.Default or Enum.KeyCode.E
			local cb = config.Callback or function() end

			local KeyFrame = Instance.new("Frame")
			KeyFrame.Size = UDim2.new(1, 0, 0, 42)
			KeyFrame.BackgroundColor3 = Theme.Element
			KeyFrame.BorderSizePixel = 0
			KeyFrame.Parent = Page
			ApplyDepth(KeyFrame, Theme.Stroke, 1, CornerRadius)

			local KeyLbl = Instance.new("TextLabel")
			KeyLbl.Size = UDim2.new(1, -100, 1, 0)
			KeyLbl.Position = UDim2.new(0, 15, 0, 0)
			KeyLbl.BackgroundTransparency = 1
			KeyLbl.Text = kName
			KeyLbl.TextColor3 = Theme.Text
			KeyLbl.TextXAlignment = Enum.TextXAlignment.Left
			KeyLbl.Font = Enum.Font.Gotham
			KeyLbl.TextSize = 13
			KeyLbl.Parent = KeyFrame

			local KeyBtn = Instance.new("TextLabel")
			KeyBtn.Size = UDim2.new(0, 70, 0, 24)
			KeyBtn.Position = UDim2.new(1, -85, 0.5, -12)
			KeyBtn.BackgroundColor3 = Theme.Background
			KeyBtn.BorderSizePixel = 0
			KeyBtn.Text = defaultKey.Name
			KeyBtn.TextColor3 = Theme.Accent
			KeyBtn.Font = Enum.Font.GothamBold
			KeyBtn.TextSize = 12
			KeyBtn.Parent = KeyFrame
			ApplyDepth(KeyBtn, Theme.Stroke, 1, UDim.new(0, 4))

			local listening = false
			BindFrameButton(KeyFrame, function()
				listening = true
				KeyBtn.Text = "..."
				Tween(KeyBtn, {TextColor3 = Theme.TextDark}, 0.2)
			end, Theme)

			UserInputService.InputBegan:Connect(function(input, gpe)
				if listening then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						defaultKey = input.KeyCode
						KeyBtn.Text = defaultKey.Name
						listening = false
						Tween(KeyBtn, {TextColor3 = Theme.Accent}, 0.2)
					end
				elseif not gpe and input.KeyCode == defaultKey then
					cb()
				end
			end)
		end

		function TabElements:CreateDropdown(config)
			local dName = config.Name or "Dropdown"
			local opts = config.Options or {}
			local cb = config.Callback or function() end

			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, 0, 0, 42)
			DropFrame.BackgroundColor3 = Theme.Element
			DropFrame.BorderSizePixel = 0
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = Page
			ApplyDepth(DropFrame, Theme.Stroke, 1, CornerRadius)

			local DropBtn = Instance.new("Frame")
			DropBtn.Size = UDim2.new(1, 0, 0, 42)
			DropBtn.BackgroundTransparency = 1
			DropBtn.LayoutOrder = 0
			DropBtn.Parent = DropFrame

			local DropLbl = Instance.new("TextLabel")
			DropLbl.Size = UDim2.new(1, -40, 1, 0)
			DropLbl.Position = UDim2.new(0, 15, 0, 0)
			DropLbl.BackgroundTransparency = 1
			DropLbl.Text = dName
			DropLbl.TextColor3 = Theme.Text
			DropLbl.TextXAlignment = Enum.TextXAlignment.Left
			DropLbl.Font = Enum.Font.Gotham
			DropLbl.TextSize = 13
			DropLbl.Parent = DropBtn

			local Arrow = Instance.new("TextLabel")
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Position = UDim2.new(1, -35, 0.5, -10)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "+"
			Arrow.TextColor3 = Theme.TextDark
			Arrow.Font = Enum.Font.GothamBold
			Arrow.TextSize = 16
			Arrow.Parent = DropBtn

			local OptLayout = Instance.new("UIListLayout")
			OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
			OptLayout.Parent = DropFrame

			local open = false
			BindFrameButton(DropBtn, function()
				open = not open
				Tween(Arrow, {Rotation = open and 45 or 0}, 0.3, Enum.EasingStyle.Back)
				local goalSize = open and 42 + (#opts * 34) or 42
				Tween(DropFrame, {Size = UDim2.new(1, 0, 0, goalSize)}, 0.4, Enum.EasingStyle.Exponential)
			end, Theme)

			for i, opt in ipairs(opts) do
				local OptBtn = Instance.new("Frame")
				OptBtn.Size = UDim2.new(1, 0, 0, 34)
				OptBtn.BackgroundColor3 = Theme.Element
				OptBtn.BorderSizePixel = 0
				OptBtn.LayoutOrder = i
				OptBtn.Parent = DropFrame

				local OptLbl = Instance.new("TextLabel")
				OptLbl.Size = UDim2.new(1, -30, 1, 0)
				OptLbl.Position = UDim2.new(0, 30, 0, 0)
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
					Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.4, Enum.EasingStyle.Exponential)
					cb(opt)
				end, Theme)
			end
		end

		function TabElements:CreateColorPicker(config)
			local cpName = config.Name or "Color Picker"
			local cb = config.Callback or function() end
			local default = config.Default or Color3.new(1, 1, 1)

			local CPFrame = Instance.new("Frame")
			CPFrame.Size = UDim2.new(1, 0, 0, 150)
			CPFrame.BackgroundColor3 = Theme.Element
			CPFrame.BorderSizePixel = 0
			CPFrame.Parent = Page
			ApplyDepth(CPFrame, Theme.Stroke, 1, CornerRadius)

			local CPLbl = Instance.new("TextLabel")
			CPLbl.Size = UDim2.new(1, -120, 0, 30)
			CPLbl.Position = UDim2.new(0, 15, 0, 15)
			CPLbl.BackgroundTransparency = 1
			CPLbl.Text = cpName
			CPLbl.TextColor3 = Theme.Text
			CPLbl.TextXAlignment = Enum.TextXAlignment.Left
			CPLbl.Font = Enum.Font.Gotham
			CPLbl.TextSize = 13
			CPLbl.Parent = CPFrame

			local Preview = Instance.new("Frame")
			Preview.Size = UDim2.new(0, 40, 0, 40)
			Preview.Position = UDim2.new(0, 15, 0, 50)
			Preview.BackgroundColor3 = default
			Preview.BorderSizePixel = 0
			Preview.Parent = CPFrame
			ApplyDepth(Preview, Theme.Stroke, 1, UDim.new(0,4))
			
			local RGBLbl = Instance.new("TextLabel")
			RGBLbl.Size = UDim2.new(0, 100, 0, 20)
			RGBLbl.Position = UDim2.new(0, 15, 0, 100)
			RGBLbl.BackgroundTransparency = 1
			RGBLbl.Text = math.floor(default.R*255)..", "..math.floor(default.G*255)..", "..math.floor(default.B*255)
			RGBLbl.TextColor3 = Theme.TextDark
			RGBLbl.TextXAlignment = Enum.TextXAlignment.Left
			RGBLbl.Font = Enum.Font.Gotham
			RGBLbl.TextSize = 11
			RGBLbl.Parent = CPFrame

			local Wheel = Instance.new("ImageLabel")
			Wheel.Size = UDim2.new(0, 90, 0, 90)
			Wheel.Position = UDim2.new(1, -115, 0, 10)
			Wheel.BackgroundTransparency = 1
			Wheel.Image = Icons.ColorWheel
			Wheel.Active = true
			Wheel.Parent = CPFrame

			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 10, 0, 10)
			Indicator.Position = UDim2.new(0.5, -5, 0.5, -5)
			Indicator.BackgroundColor3 = Color3.new(1,1,1)
			Indicator.BorderSizePixel = 0
			Indicator.Parent = Wheel
			ApplyDepth(Indicator, Color3.new(0,0,0), 1, UDim.new(1,0))

			local ValSliderBg = Instance.new("Frame")
			ValSliderBg.Size = UDim2.new(0, 90, 0, 12)
			ValSliderBg.Position = UDim2.new(1, -115, 0, 115)
			ValSliderBg.BackgroundColor3 = Theme.Background
			ValSliderBg.BorderSizePixel = 0
			ValSliderBg.Active = true
			ValSliderBg.Parent = CPFrame
			ApplyDepth(ValSliderBg, Theme.Stroke, 1, UDim.new(1,0))
			
			local ValUIGradient = Instance.new("UIGradient")
			ValUIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, default)})
			ValUIGradient.Parent = ValSliderBg

			local ValIndicator = Instance.new("Frame")
			ValIndicator.Size = UDim2.new(0, 14, 0, 14)
			ValIndicator.Position = UDim2.new(1, -7, 0.5, -7)
			ValIndicator.BackgroundColor3 = Theme.Accent
			ValIndicator.BorderSizePixel = 0
			ValIndicator.Parent = ValSliderBg
			ApplyDepth(ValIndicator, Color3.new(0,0,0), 1, UDim.new(1,0))

			local hue, sat, val = default:ToHSV()
			
			local function updateVisuals()
				local color = Color3.fromHSV(hue, sat, val)
				local pureColor = Color3.fromHSV(hue, sat, 1)
				Preview.BackgroundColor3 = color
				RGBLbl.Text = "RGB: " .. math.floor(color.R*255)..", "..math.floor(color.G*255)..", "..math.floor(color.B*255)
				ValUIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, pureColor)})
				cb(color)
			end

			local draggingWheel = false
			local function updateWheel(input)
				local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
				local delta = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
				local radius = Wheel.AbsoluteSize.X / 2
				local distance = math.clamp(delta.Magnitude, 0, radius)
				
				local angle = math.atan2(delta.Y, delta.X)
				hue = (angle / (math.pi * 2)) % 1
				sat = distance / radius

				local indX = math.cos(angle) * distance
				local indY = math.sin(angle) * distance
				Tween(Indicator, {Position = UDim2.new(0.5, indX - 5, 0.5, indY - 5)}, 0.1, Enum.EasingStyle.Quad)
				updateVisuals()
			end

			local draggingVal = false
			local function updateValue(input)
				local pos = math.clamp((input.Position.X - ValSliderBg.AbsolutePosition.X) / ValSliderBg.AbsoluteSize.X, 0, 1)
				val = pos
				Tween(ValIndicator, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1, Enum.EasingStyle.Quad)
				updateVisuals()
			end

			Wheel.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					draggingWheel = true updateWheel(i)
				end
			end)
			ValSliderBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					draggingVal = true updateValue(i)
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
					draggingWheel = false draggingVal = false
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
					if draggingWheel then updateWheel(i) end
					if draggingVal then updateValue(i) end
				end
			end)
		end

		return TabElements
	end

	return WindowObj
end

return Veltrum
