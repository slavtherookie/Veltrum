local Veltrum = { Version = "0.1", Creator = "siv" }

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Theme = {
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

local WasUpdated = false
if getgenv().Veltrum_Instance then 
	getgenv().Veltrum_Instance:Destroy() 
	WasUpdated = true
end
if getgenv().Veltrum_Blur then getgenv().Veltrum_Blur:Destroy() end

local function GenId() return HttpService:GenerateGUID(false):gsub("-", "") end

local function Tween(obj, props, time, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Exponential, dir or Enum.EasingDirection.Out), props)
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
		ColorSequenceKeypoint.new(1, Color3.new(0.5, 0.5, 0.5))
	})
	grad.Parent = stroke
end

local function BindFrameButton(frame, callback)
	frame.Active = true
	local scale = Instance.new("UIScale", frame)
	local hovering, pressing = false, false

	frame.MouseEnter:Connect(function()
		hovering = true
		Tween(frame, {BackgroundColor3 = Theme.Hover}, 0.2)
	end)
	frame.MouseLeave:Connect(function()
		hovering = false
		if not pressing then
			Tween(frame, {BackgroundColor3 = Theme.Element}, 0.2)
			Tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
		end
	end)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressing = true
			Tween(frame, {BackgroundColor3 = Theme.Click}, 0.1)
			Tween(scale, {Scale = 0.94}, 0.2, Enum.EasingStyle.Back)
		end
	end)
	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressing = false
			Tween(frame, {BackgroundColor3 = hovering and Theme.Hover or Theme.Element}, 0.2)
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

	local NFrame = Instance.new("Frame")
	NFrame.Size = UDim2.new(1, 400, 0, img and 70 or 60)
	NFrame.BackgroundTransparency = 1
	NFrame.BackgroundColor3 = Theme.Element
	NFrame.BorderSizePixel = 0
	NFrame.Parent = NotifContainer
	ApplyDepth(NFrame)
	
	local stroke = NFrame:FindFirstChildOfClass("UIStroke")
	if stroke then stroke.Transparency = 1 end

	local NScale = Instance.new("UIScale", NFrame)
	NScale.Scale = 0.8

	local NT = Instance.new("TextLabel")
	NT.Size = UDim2.new(1, img and -70 or -20, 0, 20)
	NT.Position = UDim2.new(0, img and 60 or 10, 0, 10)
	NT.BackgroundTransparency = 1
	NT.Text = title
	NT.TextColor3 = Theme.Accent
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
	ND.TextColor3 = Theme.TextDark
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

if WasUpdated then
	Veltrum:Notify({
		Title = "Updating..",
		Content = "Script to latest version",
		Duration = 3
	})
end

function Veltrum:CreateWindow(config)
	local Title = config.Title or "Veltrum"
	
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
	ApplyDepth(Main, Theme.Stroke, 1.5)

	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, 0, 0, 35)
	Topbar.BackgroundColor3 = Theme.Background
	Topbar.BorderSizePixel = 0
	Topbar.Active = true
	Topbar.Parent = Main

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
		SG:Destroy()
		BlurEffect:Destroy()
	end)

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
	ApplyDepth(BottomNav, Theme.Stroke, 1)

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

	local ProfilePanel = Instance.new("Frame")
	ProfilePanel.Size = UDim2.new(0, 220, 0, 110)
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

	local ProfID = Instance.new("TextLabel")
	ProfID.Size = UDim2.new(1, -20, 0, 20)
	ProfID.Position = UDim2.new(0, 10, 0, 65)
	ProfID.BackgroundTransparency = 1
	ProfID.Text = "ID: " .. LocalPlayer.UserId
	ProfID.TextColor3 = Theme.TextDark
	ProfID.Font = Enum.Font.Gotham
	ProfID.TextSize = 12
	ProfID.TextXAlignment = Enum.TextXAlignment.Left
	ProfID.ZIndex = 10
	ProfID.Parent = ProfilePanel

	local ProfileOpen = false
	BindFrameButton(AvatarBtn, function()
		ProfileOpen = not ProfileOpen
		Tween(ProfilePanel, {Position = UDim2.new(0, 10, 1, ProfileOpen and -170 or 10)}, 0.4, Enum.EasingStyle.Exponential)
	end)

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Size = UDim2.new(1, -70, 1, 0)
	TabScroll.Position = UDim2.new(0, 70, 0, 0)
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.ScrollBarThickness = 0
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
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

	TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabScroll.CanvasSize = UDim2.new(0, TabListLayout.AbsoluteContentSize.X, 0, 0)
	end)

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
		ApplyDepth(TabBtn, Theme.Stroke, 1)

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
		Page.Parent = Content

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingBottom = UDim.new(0, 20)
		PagePadding.PaddingRight = UDim.new(0, 10)
		PagePadding.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 40)
		end)

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
		end)

		FirstTab = false
		local TabElements = {}

		function TabElements:CreateButton(config)
			local btnText = config.Name or "Button"
			local cb = config.Callback or function() end

			local BtnFrame = Instance.new("Frame")
			BtnFrame.Size = UDim2.new(1, 0, 0, 42)
			BtnFrame.BackgroundColor3 = Theme.Element
			BtnFrame.BorderSizePixel = 0
			BtnFrame.Parent = Page
			ApplyDepth(BtnFrame)

			local BtnLbl = Instance.new("TextLabel")
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
			TogFrame.Size = UDim2.new(1, 0, 0, 42)
			TogFrame.BackgroundColor3 = Theme.Element
			TogFrame.BorderSizePixel = 0
			TogFrame.Parent = Page
			ApplyDepth(TogFrame)

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
				ApplyDepth(SwitchBg)

				local SwitchBlock = Instance.new("Frame")
				SwitchBlock.Size = UDim2.new(0, 16, 0, 16)
				SwitchBlock.Position = UDim2.new(0, state and 22 or 2, 0.5, -8)
				SwitchBlock.BackgroundColor3 = state and Theme.Background or Theme.TextDark
				SwitchBlock.BorderSizePixel = 0
				SwitchBlock.Parent = SwitchBg

				BindFrameButton(TogFrame, function()
					state = not state
					Tween(SwitchBg, {BackgroundColor3 = state and Theme.Accent or Theme.Background}, 0.25)
					Tween(SwitchBlock, {
						Position = UDim2.new(0, state and 22 or 2, 0.5, -8),
						BackgroundColor3 = state and Theme.Background or Theme.TextDark
					}, 0.4, Enum.EasingStyle.Exponential)
					cb(state)
				end)

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
			SliderFrame.Size = UDim2.new(1, 0, 0, 60)
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.BorderSizePixel = 0
			SliderFrame.Parent = Page
			ApplyDepth(SliderFrame)

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

			local BarFill = Instance.new("Frame")
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
			ApplyDepth(DropFrame)

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
			end)

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
				end)
			end
		end

		function TabElements:CreateColorPicker(config)
			local cpName = config.Name or "Color Picker"
			local cb = config.Callback or function() end
			local default = config.Default or Color3.new(1, 1, 1)

			local CPFrame = Instance.new("Frame")
			CPFrame.Size = UDim2.new(1, 0, 0, 110)
			CPFrame.BackgroundColor3 = Theme.Element
			CPFrame.BorderSizePixel = 0
			CPFrame.Parent = Page
			ApplyDepth(CPFrame)

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
			ApplyDepth(Preview)

			local Wheel = Instance.new("ImageLabel")
			Wheel.Size = UDim2.new(0, 90, 0, 90)
			Wheel.Position = UDim2.new(1, -105, 0, 10)
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
			ApplyDepth(Indicator, Color3.new(0,0,0), 1)
			Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1,0)

			local dragging = false
			local function updateColor(input)
				local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
				local delta = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
				local radius = Wheel.AbsoluteSize.X / 2
				local distance = math.clamp(delta.Magnitude, 0, radius)
				
				local angle = math.atan2(delta.Y, delta.X)
				local hue = (angle / (math.pi * 2)) % 1
				local sat = distance / radius
				local color = Color3.fromHSV(hue, sat, 1)

				local indX = math.cos(angle) * distance
				local indY = math.sin(angle) * distance
				Tween(Indicator, {Position = UDim2.new(0.5, indX - 5, 0.5, indY - 5)}, 0.1, Enum.EasingStyle.Quad)
				
				Preview.BackgroundColor3 = color
				cb(color)
			end

			Wheel.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true updateColor(i)
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateColor(i) end
			end)
		end

		return TabElements
	end

	return WindowObj
end

return Veltrum
