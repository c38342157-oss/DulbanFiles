--!strict
--[[
	██████╗ ██╗   ██╗██╗     ██████╗  █████╗ ███╗   ██╗
	██╔══██╗██║   ██║██║     ██╔══██╗██╔══██╗████╗  ██║
	██║  ██║██║   ██║██║     ██████╔╝███████║██╔██╗ ██║
	██║  ██║██║   ██║██║     ██╔══██╗██╔══██║██║╚██╗██║
	██████╔╝╚██████╔╝███████╗██████╔╝██║  ██║██║ ╚████║
	╚═════╝  ╚═════╝ ╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
	
	DulbanUI v1.0.1 — « I cant play fair »
	Neo-brutalist + Neon W&B GUI для Roblox.

	FIX в v1.0.1:
		• убрано присваивание полей прямо в Instance (card._stroke = ...),
		  из-за которого падало "_stroke is not a valid member of Frame";
		• все метаданные теперь в WeakTable Store;
		• починен `frame.Destroying = nil` → корректное :Connect();
		• modal._title / _scroll / _close тоже переведены на Store.
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════
-- STORE  (WeakTable для метаданных инстансов)
-- Roblox НЕ разрешает писать произвольные поля в Instance,
-- поэтому храним всё здесь: Store.set(frame, "stroke", s)
-- ═══════════════════════════════════════════════════════════════════════
local Store = setmetatable({}, { __mode = "k" })

function Store.set(inst, key, value)
	local m = Store[inst]
	if not m then
		m = {}
		Store[inst] = m
	end
	m[key] = value
	return value
end

function Store.get(inst, key)
	local m = Store[inst]
	return m and m[key]
end

-- ═══════════════════════════════════════════════════════════════════════
-- EASINGS
-- ═══════════════════════════════════════════════════════════════════════
local PI = math.pi
local c1, c2, c3 = 1.70158, 1.70158 * 1.525, 1.70158 + 1
local c4 = (2 * PI) / 3
local c5 = (2 * PI) / 4.5

local function bounceOut(t)
	local n1, d1 = 7.5625, 2.75
	if t < 1/d1 then return n1 * t * t end
	if t < 2/d1 then t -= 1.5/d1 return n1*t*t + 0.75 end
	if t < 2.5/d1 then t -= 2.25/d1 return n1*t*t + 0.9375 end
	t -= 2.625/d1
	return n1*t*t + 0.984375
end

local Ease = {
	linear      = function(t) return t end,
	inSine      = function(t) return 1 - math.cos((t*PI)/2) end,
	outSine     = function(t) return math.sin((t*PI)/2) end,
	inOutSine   = function(t) return -(math.cos(PI*t) - 1)/2 end,
	inQuad      = function(t) return t*t end,
	outQuad     = function(t) return 1 - (1-t)*(1-t) end,
	inOutQuad   = function(t) return t < 0.5 and 2*t*t or 1 - (-2*t+2)^2/2 end,
	inCubic     = function(t) return t*t*t end,
	outCubic    = function(t) return 1 - (1-t)^3 end,
	inOutCubic  = function(t) return t < 0.5 and 4*t*t*t or 1 - (-2*t+2)^3/2 end,
	inQuart     = function(t) return t*t*t*t end,
	outQuart    = function(t) return 1 - (1-t)^4 end,
	inOutQuart  = function(t) return t < 0.5 and 8*t*t*t*t or 1 - (-2*t+2)^4/2 end,
	inQuint     = function(t) return t^5 end,
	outQuint    = function(t) return 1 - (1-t)^5 end,
	inOutQuint  = function(t) return t < 0.5 and 16*t^5 or 1 - (-2*t+2)^5/2 end,
	inExpo      = function(t) return t == 0 and 0 or 2^(10*t - 10) end,
	outExpo     = function(t) return t == 1 and 1 or 1 - 2^(-10*t) end,
	inOutExpo   = function(t)
		if t == 0 or t == 1 then return t end
		return t < 0.5 and 2^(20*t - 10)/2 or (2 - 2^(-20*t + 10))/2
	end,
	inCirc      = function(t) return 1 - math.sqrt(1 - t*t) end,
	outCirc     = function(t) return math.sqrt(1 - (t-1)^2) end,
	inOutCirc   = function(t)
		return t < 0.5 and (1 - math.sqrt(1 - (2*t)^2))/2 or (math.sqrt(1 - (-2*t+2)^2) + 1)/2
	end,
	inBack      = function(t) return c3*t*t*t - c1*t*t end,
	outBack     = function(t) return 1 + c3*(t-1)^3 + c1*(t-1)^2 end,
	inOutBack   = function(t)
		return t < 0.5
			and ((2*t)^2 * ((c2+1)*2*t - c2))/2
			or  ((2*t-2)^2 * ((c2+1)*(t*2-2) + c2) + 2)/2
	end,
	inElastic   = function(t)
		if t == 0 or t == 1 then return t end
		return -2^(10*t - 10) * math.sin((t*10 - 10.75) * c4)
	end,
	outElastic  = function(t)
		if t == 0 or t == 1 then return t end
		return 2^(-10*t) * math.sin((t*10 - 0.75) * c4) + 1
	end,
	inOutElastic = function(t)
		if t == 0 or t == 1 then return t end
		return t < 0.5
			and -(2^(20*t - 10) * math.sin((20*t - 11.125) * c5))/2
			or  (2^(-20*t + 10) * math.sin((20*t - 11.125) * c5))/2 + 1
	end,
	inBounce    = function(t) return 1 - bounceOut(1-t) end,
	outBounce   = bounceOut,
	inOutBounce = function(t)
		return t < 0.5 and (1 - bounceOut(1 - 2*t))/2 or (1 + bounceOut(2*t - 1))/2
	end,
}

local EaseMap = {
	linear = Enum.EasingStyle.Linear,
	inSine = Enum.EasingStyle.Sine, outSine = Enum.EasingStyle.Sine, inOutSine = Enum.EasingStyle.Sine,
	inQuad = Enum.EasingStyle.Quad, outQuad = Enum.EasingStyle.Quad, inOutQuad = Enum.EasingStyle.Quad,
	inCubic = Enum.EasingStyle.Cubic, outCubic = Enum.EasingStyle.Cubic, inOutCubic = Enum.EasingStyle.Cubic,
	inQuart = Enum.EasingStyle.Quart, outQuart = Enum.EasingStyle.Quart, inOutQuart = Enum.EasingStyle.Quart,
	inQuint = Enum.EasingStyle.Quint, outQuint = Enum.EasingStyle.Quint, inOutQuint = Enum.EasingStyle.Quint,
	inExpo = Enum.EasingStyle.Exponential, outExpo = Enum.EasingStyle.Exponential, inOutExpo = Enum.EasingStyle.Exponential,
	inCirc = Enum.EasingStyle.Circular, outCirc = Enum.EasingStyle.Circular, inOutCirc = Enum.EasingStyle.Circular,
	inBack = Enum.EasingStyle.Back, outBack = Enum.EasingStyle.Back, inOutBack = Enum.EasingStyle.Back,
	inElastic = Enum.EasingStyle.Elastic, outElastic = Enum.EasingStyle.Elastic,
	inBounce = Enum.EasingStyle.Bounce, outBounce = Enum.EasingStyle.Bounce, inOutBounce = Enum.EasingStyle.Bounce,
}
local EaseDir = {
	linear = Enum.EasingDirection.InOut,
	inSine = Enum.EasingDirection.In, outSine = Enum.EasingDirection.Out, inOutSine = Enum.EasingDirection.InOut,
	inQuad = Enum.EasingDirection.In, outQuad = Enum.EasingDirection.Out, inOutQuad = Enum.EasingDirection.InOut,
	inCubic = Enum.EasingDirection.In, outCubic = Enum.EasingDirection.Out, inOutCubic = Enum.EasingDirection.InOut,
	inQuart = Enum.EasingDirection.In, outQuart = Enum.EasingDirection.Out, inOutQuart = Enum.EasingDirection.InOut,
	inQuint = Enum.EasingDirection.In, outQuint = Enum.EasingDirection.Out, inOutQuint = Enum.EasingDirection.InOut,
	inExpo = Enum.EasingDirection.In, outExpo = Enum.EasingDirection.Out, inOutExpo = Enum.EasingDirection.InOut,
	inCirc = Enum.EasingDirection.In, outCirc = Enum.EasingDirection.Out, inOutCirc = Enum.EasingDirection.InOut,
	inBack = Enum.EasingDirection.In, outBack = Enum.EasingDirection.Out, inOutBack = Enum.EasingDirection.InOut,
	inElastic = Enum.EasingDirection.In, outElastic = Enum.EasingDirection.Out,
	inBounce = Enum.EasingDirection.In, outBounce = Enum.EasingDirection.Out, inOutBounce = Enum.EasingDirection.InOut,
}

local function tweenInfo(time, ease, delay)
	time = time or 0.35
	ease = ease or "outCubic"
	return TweenInfo.new(time, EaseMap[ease] or Enum.EasingStyle.Quad, EaseDir[ease] or Enum.EasingDirection.Out, 0, false, delay or 0)
end

local function tw(inst, time, props, ease, delay)
	local t = TweenService:Create(inst, tweenInfo(time, ease, delay), props)
	t:Play()
	return t
end

local function customTween(duration, easeFunc, onUpdate, onComplete)
	local start = tick()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local a = math.clamp((tick() - start) / duration, 0, 1)
		onUpdate(easeFunc(a), a)
		if a >= 1 then
			conn:Disconnect()
			if onComplete then onComplete() end
		end
	end)
	return conn
end

-- ═══════════════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════════════
local Themes = {}

Themes.White = {
	Background    = Color3.fromRGB(255, 255, 255),
	Surface       = Color3.fromRGB(247, 246, 243),
	TextPrimary   = Color3.fromRGB(13, 13, 13),
	TextSecondary = Color3.fromRGB(138, 138, 134),
	Border        = Color3.fromRGB(13, 13, 13),
	Accent        = Color3.fromRGB(13, 13, 13),
	Good          = Color3.fromRGB(31, 163, 86),
	Bad           = Color3.fromRGB(229, 73, 60),
	Gold          = Color3.fromRGB(213, 146, 27),
	Shadow        = Color3.fromRGB(13, 13, 13),
	Neon          = Color3.fromRGB(125, 249, 255),
	NeonAlt       = Color3.fromRGB(255, 94, 207),
	IsDark        = false,
}

Themes.Dark = {
	Background    = Color3.fromRGB(18, 18, 22),
	Surface       = Color3.fromRGB(28, 28, 34),
	TextPrimary   = Color3.fromRGB(240, 240, 245),
	TextSecondary = Color3.fromRGB(140, 140, 150),
	Border        = Color3.fromRGB(70, 70, 80),
	Accent        = Color3.fromRGB(240, 240, 245),
	Good          = Color3.fromRGB(76, 217, 100),
	Bad           = Color3.fromRGB(255, 69, 58),
	Gold          = Color3.fromRGB(255, 214, 10),
	Shadow        = Color3.fromRGB(0, 0, 0),
	Neon          = Color3.fromRGB(125, 249, 255),
	NeonAlt       = Color3.fromRGB(255, 94, 207),
	IsDark        = true,
}

Themes.Cyberpunk = {
	Background    = Color3.fromRGB(10, 5, 20),
	Surface       = Color3.fromRGB(22, 10, 40),
	TextPrimary   = Color3.fromRGB(234, 252, 255),
	TextSecondary = Color3.fromRGB(140, 180, 200),
	Border        = Color3.fromRGB(255, 0, 200),
	Accent        = Color3.fromRGB(125, 249, 255),
	Good          = Color3.fromRGB(157, 255, 87),
	Bad           = Color3.fromRGB(255, 30, 100),
	Gold          = Color3.fromRGB(255, 225, 77),
	Shadow        = Color3.fromRGB(255, 0, 200),
	Neon          = Color3.fromRGB(125, 249, 255),
	NeonAlt       = Color3.fromRGB(255, 94, 207),
	IsDark        = true,
}

Themes.Midnight = {
	Background    = Color3.fromRGB(13, 20, 36),
	Surface       = Color3.fromRGB(20, 30, 52),
	TextPrimary   = Color3.fromRGB(219, 230, 247),
	TextSecondary = Color3.fromRGB(95, 114, 146),
	Border        = Color3.fromRGB(56, 189, 248),
	Accent        = Color3.fromRGB(56, 189, 248),
	Good          = Color3.fromRGB(126, 224, 163),
	Bad           = Color3.fromRGB(242, 143, 173),
	Gold          = Color3.fromRGB(242, 178, 107),
	Shadow        = Color3.fromRGB(0, 0, 0),
	Neon          = Color3.fromRGB(125, 249, 255),
	NeonAlt       = Color3.fromRGB(155, 100, 255),
	IsDark        = true,
}

-- ═══════════════════════════════════════════════════════════════════════
-- UTIL
-- ═══════════════════════════════════════════════════════════════════════
local function make(className, props, children)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				inst[k] = v
			end
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = inst
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(radius, parent)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 12), Parent = parent })
end

local function stroke(color, thickness, parent, transparency)
	return make("UIStroke", {
		Color = color,
		Thickness = thickness or 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = transparency or 0,
		Parent = parent,
	})
end

local function pad(top, bottom, left, right, parent)
	return make("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom or top),
		PaddingLeft = UDim.new(0, left or top),
		PaddingRight = UDim.new(0, right or left or top),
		Parent = parent,
	})
end

local function gradient(parent, colorA, colorB, rotation)
	local g = make("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA),
			ColorSequenceKeypoint.new(1, colorB),
		}),
		Rotation = rotation or 90,
		Parent = parent,
	})
	return g
end

-- ═══════════════════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════════════════
local UI = {}
UI.__index = UI
UI.Ease = Ease
UI.Themes = Themes
UI.Tween = tw
UI.CustomTween = customTween
UI.Store = Store

function UI.new(props)
	props = props or {}
	local self = setmetatable({}, UI)

	self.ThemeName = props.Theme or "White"
	self.Theme = Themes[self.ThemeName] or Themes.White
	self.CustomTheme = props.CustomTheme
	self.Title = props.Title or "DULBAN UI"
	self.Subtitle = props.Subtitle or "« I cant play fair »"
	self.WindowSize = props.Size or UDim2.fromOffset(580, 440)
	self.WindowPosition = props.Position or UDim2.fromScale(0.5, 0.5)
	self.AnimSpeed = props.AnimationSpeed or 1.0
	self.Tabs = {}
	self.TabButtons = {}
	self.ActiveTab = nil
	self.IsOpen = false
	self.IsMinimized = false

	self:_build()
	return self
end

function UI:theme(key)
	if self.CustomTheme and self.CustomTheme[key] ~= nil then
		return self.CustomTheme[key]
	end
	return self.Theme[key]
end

-- ─────────────────────────────────────────────────────────────
function UI:_build()
	local th = self.Theme

	self.ScreenGui = make("ScreenGui", {
		Name = "DulbanUI_" .. HttpService:GenerateGUID(false),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 99999,
		Parent = PlayerGui,
	})

	self.Container = make("Frame", {
		Name = "Container",
		Size = self.WindowSize,
		Position = self.WindowPosition,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = self.ScreenGui,
	})

	self.Shadow = make("Frame", {
		Name = "Shadow",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = th.Shadow,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = self.Container,
	})
	corner(18, self.Shadow)

	self.Frame = make("Frame", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = th.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.Container,
	})
	corner(18, self.Frame)
	self.MainStroke = stroke(th.Border, 2, self.Frame)
	self.MainGradient = gradient(self.Frame, th.Background, th.Surface, 90)

	self.NeonStroke = stroke(th.Neon, 1.5, self.Frame, 1)
	self.NeonStroke.LineJoinMode = Enum.LineJoinMode.Round

	self:_buildHeader()
	self:_buildBody()
	self:_buildFooter()

	self.Frame.Visible = false
	self.Shadow.Visible = false
	self:MakeDraggable(self.Header)
end

function UI:_buildHeader()
	local th = self.Theme
	self.Header = make("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = th.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	corner(18, self.Header)

	local stripe = make("Frame", {
		Name = "Stripes",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = th.Border,
		BackgroundTransparency = 0.96,
		BorderSizePixel = 0,
		Parent = self.Header,
	})
	corner(18, stripe)

	make("Frame", {
		Name = "BottomBorder",
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = th.Border,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = self.Header,
	})

	self.Logo = make("Frame", {
		Name = "Logo",
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.new(0, 16, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = th.Accent,
		BorderSizePixel = 0,
		Parent = self.Header,
	})
	corner(13, self.Logo)
	stroke(th.Border, 2, self.Logo, 0)

	self.LogoIcon = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "⚡",
		TextColor3 = th.Background,
		TextScaled = true,
		Font = Enum.Font.GothamBlack,
		Parent = self.Logo,
	})
	pad(10, 10, 10, 10, self.LogoIcon)

	self.LogoRing = make("Frame", {
		Name = "Ring",
		Size = UDim2.fromOffset(56, 56),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = self.Logo,
	})
	self.LogoRingStroke = stroke(th.Border, 1.5, self.LogoRing, 0.55)
	self.LogoRingStroke.LineJoinMode = Enum.LineJoinMode.Round

	local titleBox = make("Frame", {
		Name = "TitleBox",
		Size = UDim2.new(1, -220, 1, 0),
		Position = UDim2.fromOffset(76, 0),
		BackgroundTransparency = 1,
		Parent = self.Header,
	})

	self.TitleLabel = make("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, 12),
		BackgroundTransparency = 1,
		Text = self.Title,
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBlack,
		TextSize = 18,
		Parent = titleBox,
	})

	self.SubtitleLabel = make("TextLabel", {
		Name = "Subtitle",
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = self.Subtitle,
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Parent = titleBox,
	})

	local btns = make("Frame", {
		Name = "HeaderButtons",
		Size = UDim2.fromOffset(90, 30),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = self.Header,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 7),
		Parent = btns,
	})

	self.MinimizeBtn = self:_makeHeaderButton(btns, "—")
	self.CloseBtn = self:_makeHeaderButton(btns, "✕")

	self.MinimizeBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
	self.CloseBtn.MouseButton1Click:Connect(function() self:Hide() end)
end

function UI:_makeHeaderButton(parent, glyph)
	local th = self.Theme
	local btn = make("TextButton", {
		Name = "HeaderBtn",
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = th.Background,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(9, btn)
	stroke(th.Border, 2, btn)

	local label = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = glyph,
		TextColor3 = th.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = btn,
	})

	btn.MouseEnter:Connect(function()
		tw(btn, 0.18, { BackgroundColor3 = th.Border }, "outBack")
		tw(label, 0.18, { TextColor3 = th.Background }, "outQuad")
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, 0.18, { BackgroundColor3 = th.Background }, "outBack")
		tw(label, 0.18, { TextColor3 = th.TextPrimary }, "outQuad")
	end)
	btn.MouseButton1Down:Connect(function()
		tw(btn, 0.08, { Size = UDim2.fromOffset(25, 25) }, "outQuad")
	end)
	btn.MouseButton1Up:Connect(function()
		tw(btn, 0.15, { Size = UDim2.fromOffset(28, 28) }, "outBack")
	end)

	return btn
end

function UI:_buildBody()
	local th = self.Theme
	self.Body = make("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -66 - 26),
		Position = UDim2.fromOffset(0, 66),
		BackgroundTransparency = 1,
		Parent = self.Frame,
	})

	self.Rail = make("Frame", {
		Name = "Rail",
		Size = UDim2.new(0, 58, 1, 0),
		BackgroundColor3 = th.Surface,
		BorderSizePixel = 0,
		Parent = self.Body,
	})
	make("Frame", {
		Name = "RailBorder",
		Size = UDim2.new(0, 2, 1, 0),
		Position = UDim2.new(1, -2, 0, 0),
		BackgroundColor3 = th.Border,
		BorderSizePixel = 0,
		Parent = self.Rail,
	})
	make("UIListLayout", {
		Name = "RailLayout",
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 8),
		Parent = self.Rail,
	})
	make("UIPadding", { PaddingTop = UDim.new(0, 12), Parent = self.Rail })

	self.Content = make("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -58, 1, 0),
		Position = UDim2.fromOffset(58, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = self.Body,
	})

	self.ContentScroll = make("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = th.Border,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self.Content,
	})
	make("UIListLayout", {
		Name = "ContentLayout",
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.ContentScroll,
	})
	pad(15, 18, 16, 16, self.ContentScroll)
end

function UI:_buildFooter()
	local th = self.Theme
	self.Footer = make("Frame", {
		Name = "Footer",
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 1, -26),
		BackgroundColor3 = th.Surface,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	corner(18, self.Footer)
	make("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = th.Border,
		BorderSizePixel = 0,
		Parent = self.Footer,
	})

	self.FooterLeft = make("TextLabel", {
		Size = UDim2.new(0.5, -14, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = "DULBAN · v1.0.1",
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Parent = self.Footer,
	})

	self.FooterRight = make("TextLabel", {
		Size = UDim2.new(0.5, -14, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "Insert — меню · Esc — закрыть",
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Parent = self.Footer,
	})
end

-- ─────────────────────────────────────────────────────────────
function UI:MakeDraggable(dragBar)
	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		local newX = startPos.X.Offset + delta.X
		local newY = startPos.Y.Offset + delta.Y
		tw(self.Container, 0.14, {
			Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
		}, "outQuad")
	end

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Container.Position
			tw(self.Container, 0.15, { Rotation = 0.6 }, "outBack")
			tw(self.Shadow, 0.2, { Position = UDim2.fromOffset(14, 14) }, "outQuad")
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					tw(self.Container, 0.35, { Rotation = 0 }, "outBack")
					tw(self.Shadow, 0.35, { Position = UDim2.fromOffset(10, 10) }, "outBack")
				end
			end)
		end
	end)
	dragBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

-- ─────────────────────────────────────────────────────────────
-- TABS
-- ─────────────────────────────────────────────────────────────
function UI:CreateTab(name, icon)
	local tab = {
		Name = name,
		Icon = icon or "●",
		Sections = {},
		_ui = self,
		_active = false,
	}

	local th = self.Theme
	local btn = make("TextButton", {
		Name = "Tab_" .. name,
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = th.Surface,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.Rail,
	})
	corner(12, btn)
	local btnStroke = stroke(th.Border, 2, btn, 1)

	local iconLabel = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = tab.Icon,
		TextColor3 = th.TextSecondary,
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		Parent = btn,
	})
	pad(10, 10, 10, 10, iconLabel)

	local indicator = make("Frame", {
		Size = UDim2.new(0, 5, 0, 0),
		Position = UDim2.new(-0.35, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = th.Border,
		BorderSizePixel = 0,
		Parent = btn,
	})
	corner(3, indicator)

	-- tooltip
	local tip = make("TextLabel", {
		Name = "Tooltip",
		Size = UDim2.fromOffset(0, 22),
		Position = UDim2.new(1, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = th.Accent,
		Text = name,
		TextColor3 = th.Background,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextTransparency = 1,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		ZIndex = 20,
		Parent = btn,
	})
	corner(7, tip)
	pad(0, 0, 8, 8, tip)

	tab._btn = btn
	tab._icon = iconLabel
	tab._indicator = indicator
	tab._tooltip = tip
	tab._stroke = btnStroke

	local content = make("Frame", {
		Name = "TabContent_" .. name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content,
	})
	tab._content = content

	make("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = content,
	})

	btn.MouseEnter:Connect(function()
		if tab._active then return end
		tw(btn, 0.22, { BackgroundColor3 = th.Background, Position = UDim2.new(0, 2, 0, 0) }, "outBack")
		tw(btnStroke, 0.2, { Transparency = 0 }, "outQuad")
		tw(iconLabel, 0.2, { TextColor3 = th.TextPrimary }, "outQuad")
		tip.Visible = true
		tw(tip, 0.18, { BackgroundTransparency = 0, TextTransparency = 0 }, "outBack")
	end)
	btn.MouseLeave:Connect(function()
		if tab._active then return end
		tw(btn, 0.22, { BackgroundColor3 = th.Surface, Position = UDim2.new(0, 0, 0, 0) }, "outBack")
		tw(btnStroke, 0.2, { Transparency = 1 }, "outQuad")
		tw(iconLabel, 0.2, { TextColor3 = th.TextSecondary }, "outQuad")
		tw(tip, 0.15, { BackgroundTransparency = 1, TextTransparency = 1 }, "outQuad")
		task.delay(0.16, function() tip.Visible = false end)
	end)

	btn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	table.insert(self.TabButtons, btn)

	if #self.Tabs == 1 then
		task.defer(function() self:SelectTab(tab, true) end)
	end

	function tab:CreateSection(title)
		return self._ui:_createSection(self, title)
	end

	return tab
end

function UI:SelectTab(tab, instant)
	if self.ActiveTab == tab then return end
	local th = self.Theme

	local oldTab = self.ActiveTab
	self.ActiveTab = tab

	for _, t in ipairs(self.Tabs) do
		t._active = (t == tab)
		local isActive = t._active
		local b = t._btn
		local ic = t._icon
		local ind = t._indicator
		local st = t._stroke

		if isActive then
			tw(b, 0.3, { BackgroundColor3 = th.Accent, Position = UDim2.new(0, 3, 0, 0) }, "outBack")
			tw(st, 0.2, { Transparency = 0 }, "outQuad")
			tw(ic, 0.25, { TextColor3 = th.Background }, "outQuad")
			ind.Size = UDim2.new(0, 5, 0, 0)
			tw(ind, 0.35, { Size = UDim2.new(0, 5, 0, 22) }, "outBack")
		else
			tw(b, 0.25, { BackgroundColor3 = th.Surface, Position = UDim2.new(0, 0, 0, 0) }, "outBack")
			tw(st, 0.2, { Transparency = 1 }, "outQuad")
			tw(ic, 0.25, { TextColor3 = th.TextSecondary }, "outQuad")
			tw(ind, 0.15, { Size = UDim2.new(0, 5, 0, 0) }, "outQuad")
		end
	end

	if oldTab and not instant then
		local oc = oldTab._content
		tw(oc, 0.18, { Position = UDim2.fromOffset(-20, 0) }, "inQuad")
		task.delay(0.2, function()
			oc.Visible = false
			oc.Position = UDim2.fromOffset(0, 0)
		end)
	end

	if not instant then task.wait(0.08) end

	local nc = tab._content
	nc.Visible = true
	nc.Position = UDim2.fromOffset(24, 0)
	tw(nc, 0.42, { Position = UDim2.fromOffset(0, 0) }, "outExpo")

	local i = 0
	for _, child in ipairs(nc:GetChildren()) do
		if child:IsA("GuiObject") then
			i += 1
			local targetPos = child.Position
			local targetTr = child.BackgroundTransparency
			child.Position = targetPos + UDim2.fromOffset(0, 14)
			child.BackgroundTransparency = math.min(1, targetTr + 0.5)
			tw(child, 0.4, {
				Position = targetPos,
				BackgroundTransparency = targetTr,
			}, "outExpo", 0.02 + i * 0.04)
		end
	end
end

-- ─────────────────────────────────────────────────────────────
function UI:_createSection(tab, title)
	local th = self.Theme
	local section = {
		_ui = self,
		_tab = tab,
		Title = title,
		Items = {},
	}

	local holder = make("Frame", {
		Name = "Section_" .. title,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = tab._content,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})
	section._holder = holder

	local header = make("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = holder,
	})
	section._header = header

	local titleLabel = make("TextLabel", {
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = string.upper(title),
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBlack,
		TextSize = 11,
		Parent = header,
	})
	section._titleLabel = titleLabel

	local dash = make("Frame", {
		Size = UDim2.new(1, -100, 0, 2),
		Position = UDim2.new(0, 100, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = th.TextSecondary,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Parent = header,
	})
	section._dash = dash

	task.defer(function()
		local w = titleLabel.AbsoluteSize.X
		dash.Position = UDim2.new(0, w + 12, 0.5, 0)
		dash.Size = UDim2.new(1, -w - 12, 0, 2)
	end)

	function section:CreateButton(text, callback)
		return self._ui:_createButton(self, text, callback)
	end
	function section:CreateToggle(text, default, callback)
		return self._ui:_createToggle(self, text, default, callback)
	end
	function section:CreateDangerButton(text, holdTime, callback)
		return self._ui:_createDangerButton(self, text, holdTime, callback)
	end
	function section:CreateSlider(text, min, max, default, callback, opts)
		return self._ui:_createSlider(self, text, min, max, default, callback, opts)
	end
	function section:CreateTextBox(text, placeholder, callback)
		return self._ui:_createTextBox(self, text, placeholder, callback)
	end
	function section:CreateLabel(text)
		return self._ui:_createLabel(self, text)
	end
	function section:CreateChangelog(title, entries)
		return self._ui:_createChangelog(self, title, entries)
	end

	return section
end

-- ─────────────────────────────────────────────────────────────
function UI:_createCard(parent, height, layoutOrder)
	local th = self.Theme
	local card = make("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, height or 42),
		BackgroundColor3 = th.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or (#parent._holder:GetChildren() + 1),
		ClipsDescendants = false,
		Parent = parent._holder,
	})
	corner(11, card)
	local s = stroke(th.Border, 2, card, 1)

	local shadow = make("Frame", {
		Name = "CardShadow",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = th.Shadow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = card.ZIndex - 1,
		Parent = card,
	})
	corner(11, shadow)

	-- Store references (Instance нельзя расширять полями)
	Store.set(card, "stroke", s)
	Store.set(card, "shadow", shadow)

	tw(card, 0.4, { BackgroundTransparency = 0 }, "outExpo")
	tw(s, 0.4, { Transparency = 0 }, "outExpo")
	tw(shadow, 0.4, { BackgroundTransparency = 0.06 }, "outExpo")

	return card
end

-- ═══════════════════════════════════════════════════════════════════════
-- TILT
-- ═══════════════════════════════════════════════════════════════════════
function UI:_applyTilt(frame, opts)
	opts = opts or {}
	local strength = opts.strength or 3
	local lift = opts.lift or 2
	local basePos = frame.Position
	local baseRot = frame.Rotation or 0

	local hovered = false
	local conn

	frame.MouseEnter:Connect(function() hovered = true end)
	frame.MouseLeave:Connect(function()
		hovered = false
		tw(frame, 0.4, { Rotation = baseRot, Position = basePos }, "outBack")
	end)

	conn = RunService.RenderStepped:Connect(function()
		if not hovered or not frame.Parent then return end
		local mouse = UserInputService:GetMouseLocation()
		local abs = frame.AbsolutePosition
		local sz = frame.AbsoluteSize
		if sz.X <= 0 or sz.Y <= 0 then return end
		local cx = abs.X + sz.X / 2
		local cy = abs.Y + sz.Y / 2
		local dx = math.clamp((mouse.X - cx) / (sz.X / 2), -1, 1)
		local dy = math.clamp((mouse.Y - cy) / (sz.Y / 2), -1, 1)
		frame.Rotation = -dx * strength
		frame.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset + dx * 1.5, basePos.Y.Scale, basePos.Y.Offset - dy * lift)
	end)

	-- Правильная очистка вместо frame.Destroying = nil
	local cleanupDone = false
	local function cleanup()
		if cleanupDone then return end
		cleanupDone = true
		if conn then conn:Disconnect() conn = nil end
	end
	frame.Destroying:Connect(cleanup)
	frame.AncestryChanged:Connect(function(_, parent)
		if not parent then cleanup() end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BUTTON
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createButton(section, text, callback)
	local th = self.Theme
	local card = self:_createCard(section, 46)
	card.Name = "Button_" .. text
	local shadow = Store.get(card, "shadow")

	local click = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		Parent = card,
	})

	local label = make("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = card,
	})

	local function ink(x, y)
		local ripple = make("Frame", {
			Size = UDim2.fromOffset(6, 6),
			Position = UDim2.fromOffset(x - 3, y - 3),
			BackgroundColor3 = th.TextPrimary,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = card,
		})
		corner(99, ripple)
		tw(ripple, 0.55, {
			Size = UDim2.fromOffset(320, 320),
			Position = UDim2.fromOffset(x - 160, y - 160),
			BackgroundTransparency = 1,
		}, "outQuad")
		task.delay(0.6, function() ripple:Destroy() end)
	end

	click.MouseEnter:Connect(function()
		tw(card, 0.2, {
			Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset - 2, card.Position.Y.Scale, card.Position.Y.Offset - 2),
			BackgroundColor3 = th.Surface,
		}, "outBack")
		if shadow then
			tw(shadow, 0.2, { Position = UDim2.fromOffset(6, 6), BackgroundTransparency = 0 }, "outBack")
		end
	end)
	click.MouseLeave:Connect(function()
		tw(card, 0.28, {
			Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset + 2, card.Position.Y.Scale, card.Position.Y.Offset + 2),
			BackgroundColor3 = th.Background,
		}, "outBack")
		if shadow then
			tw(shadow, 0.28, { Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 0.06 }, "outBack")
		end
	end)
	click.MouseButton1Down:Connect(function()
		tw(card, 0.1, { BackgroundColor3 = th.Surface }, "outQuad")
	end)
	click.MouseButton1Up:Connect(function()
		tw(card, 0.15, { BackgroundColor3 = th.Surface }, "outBack")
	end)

	click.MouseButton1Click:Connect(function()
		local mouse = UserInputService:GetMouseLocation()
		ink(mouse.X - card.AbsolutePosition.X, mouse.Y - card.AbsolutePosition.Y)
		tw(label, 0.08, { TextColor3 = th.TextSecondary }, "outQuad")
		task.delay(0.15, function()
			tw(label, 0.2, { TextColor3 = th.TextPrimary }, "outQuad")
		end)
		if callback then task.spawn(callback) end
	end)

	self:_applyTilt(card, { strength = 2.5, lift = 1 })

	return {
		Frame = card,
		Label = label,
		SetText = function(_, t) label.Text = t end,
		Destroy = function() card:Destroy() end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createToggle(section, text, default, callback)
	local th = self.Theme
	local card = self:_createCard(section, 46)
	card.Name = "Toggle_" .. text
	local shadow = Store.get(card, "shadow")

	local label = make("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = card,
	})

	local switch = make("Frame", {
		Name = "Switch",
		Size = UDim2.fromOffset(48, 26),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = th.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = card,
	})
	corner(999, switch)
	local switchStroke = stroke(th.Border, 2, switch)

	local knob = make("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = th.Border,
		BorderSizePixel = 0,
		Parent = switch,
	})
	corner(999, knob)

	local glow = make("Frame", {
		Name = "Glow",
		Size = UDim2.new(1, 6, 1, 6),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = th.Neon,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = -1,
		Visible = false,
		Parent = switch,
	})
	corner(999, glow)

	local click = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = card,
	})

	local value = default and true or false

	local function applyVisual(v, animate)
		local dur = animate and 0.35 or 0
		if v then
			tw(switch, dur, { BackgroundColor3 = th.Accent }, "outBack")
			tw(knob, dur, {
				Position = UDim2.fromOffset(26, 2),
				BackgroundColor3 = th.Background,
			}, "outBack")
			tw(switchStroke, dur, { Color = th.Accent }, "outQuad")
			glow.Visible = true
		else
			tw(switch, dur, { BackgroundColor3 = th.Background }, "outBack")
			tw(knob, dur, {
				Position = UDim2.fromOffset(2, 2),
				BackgroundColor3 = th.Border,
			}, "outBack")
			tw(switchStroke, dur, { Color = th.Border }, "outQuad")
			glow.Visible = false
		end
	end

	applyVisual(value, false)

	click.MouseButton1Click:Connect(function()
		value = not value
		applyVisual(value, true)
		tw(knob, 0.1, { Size = UDim2.fromOffset(22, 18) }, "outQuad")
		task.delay(0.1, function()
			tw(knob, 0.25, { Size = UDim2.fromOffset(18, 18) }, "outBack")
		end)
		if callback then task.spawn(function() callback(value) end) end
	end)

	click.MouseEnter:Connect(function()
		if shadow then
			tw(shadow, 0.2, { Position = UDim2.fromOffset(5, 5), BackgroundTransparency = 0 }, "outBack")
		end
	end)
	click.MouseLeave:Connect(function()
		if shadow then
			tw(shadow, 0.28, { Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 0.06 }, "outBack")
		end
	end)

	return {
		Frame = card,
		Set = function(_, v)
			value = v and true or false
			applyVisual(value, true)
		end,
		Get = function() return value end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- DANGER BUTTON
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createDangerButton(section, text, holdTime, callback)
	local th = self.Theme
	holdTime = holdTime or 1.0

	local card = self:_createCard(section, 46)
	card.Name = "Danger_" .. text
	local cardStroke = Store.get(card, "stroke")
	local cardShadow = Store.get(card, "shadow")

	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = th.Bad,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = card,
	})
	corner(11, fill)
	gradient(fill, th.Bad, Color3.fromRGB(255, 100, 100), 90)

	local click = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = card,
	})

	local label = make("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.Bad,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		ZIndex = 2,
		Parent = card,
	})

	local hint = make("TextLabel", {
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(1, -14, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Text = "УДЕРЖИВАТЬ",
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamBlack,
		TextSize = 9,
		ZIndex = 2,
		Parent = card,
	})

	local holding = false
	local progress = 0
	local renderConn

	local function stopHold(cancelled)
		holding = false
		if renderConn then renderConn:Disconnect() renderConn = nil end
		if cancelled or progress < 1 then
			tw(fill, 0.4, { Size = UDim2.new(0, 0, 1, 0) }, "outCubic")
			if cardStroke then tw(cardStroke, 0.3, { Color = th.Border, Thickness = 2 }, "outQuad") end
			tw(label, 0.3, { TextColor3 = th.Bad }, "outQuad")
			tw(hint, 0.3, { TextTransparency = 0 }, "outQuad")
			progress = 0
		end
	end

	local function startHold()
		if holding then return end
		holding = true
		progress = 0
		tw(hint, 0.2, { TextTransparency = 1 }, "outQuad")
		if cardStroke then tw(cardStroke, 0.2, { Color = th.Bad, Thickness = 2.5 }, "outQuad") end

		local startTime = tick()
		renderConn = RunService.RenderStepped:Connect(function()
			if not holding then return end
			local elapsed = tick() - startTime
			progress = math.clamp(elapsed / holdTime, 0, 1)
			local w = Ease.outQuad(progress)
			fill.Size = UDim2.new(w, 0, 1, 0)
			local tc = th.Bad:Lerp(th.Background, math.clamp(progress * 1.4, 0, 1))
			label.TextColor3 = tc
			card.Rotation = math.sin(elapsed * 30) * (progress * 0.8)

			if progress >= 1 then
				holding = false
				if renderConn then renderConn:Disconnect() renderConn = nil end
				card.Rotation = 0
				tw(fill, 0.2, { BackgroundColor3 = th.Good }, "outQuad")
				if cardStroke then tw(cardStroke, 0.2, { Color = th.Good, Thickness = 3 }, "outQuad") end
				task.delay(0.35, function()
					if cardStroke then tw(cardStroke, 0.4, { Color = th.Border, Thickness = 2 }, "outQuad") end
					tw(fill, 0.4, { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = th.Bad }, "outCubic")
					tw(label, 0.3, { TextColor3 = th.Bad }, "outQuad")
					tw(hint, 0.3, { TextTransparency = 0 }, "outQuad")
					progress = 0
				end)
				if callback then task.spawn(callback) end
			end
		end)
	end

	click.MouseButton1Down:Connect(startHold)
	click.MouseButton1Up:Connect(function() stopHold(true) end)
	click.MouseLeave:Connect(function()
		if holding then stopHold(true) end
		if cardShadow then
			tw(cardShadow, 0.28, { Position = UDim2.fromOffset(3, 3), BackgroundTransparency = 0.06 }, "outBack")
		end
	end)
	click.MouseEnter:Connect(function()
		if cardShadow then
			tw(cardShadow, 0.2, { Position = UDim2.fromOffset(5, 5), BackgroundTransparency = 0 }, "outBack")
		end
	end)

	self:_applyTilt(card, { strength = 2, lift = 1 })

	return {
		Frame = card,
		SetHoldTime = function(_, t) holdTime = t end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- SLIDER
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createSlider(section, text, min, max, default, callback, opts)
	opts = opts or {}
	local th = self.Theme
	min = min or 0
	max = max or 100
	default = math.clamp(default or min, min, max)
	local colorA = opts.colorStart or th.Accent
	local colorB = opts.colorEnd or th.Bad
	local unitSuffix = opts.suffix or ""

	local card = self:_createCard(section, 62)
	card.Name = "Slider_" .. text
	local cardStroke = Store.get(card, "stroke")

	local label = make("TextLabel", {
		Size = UDim2.new(0.7, 0, 0, 18),
		Position = UDim2.fromOffset(14, 8),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Parent = card,
	})

	local valueBox = make("TextLabel", {
		Size = UDim2.fromOffset(72, 20),
		Position = UDim2.new(1, -14, 0, 7),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = th.Surface,
		Text = tostring(default) .. unitSuffix,
		TextColor3 = th.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		BorderSizePixel = 0,
		Parent = card,
	})
	corner(7, valueBox)
	stroke(th.Border, 1.5, valueBox)

	local track = make("Frame", {
		Name = "Track",
		Size = UDim2.new(1, -28, 0, 6),
		Position = UDim2.new(0, 14, 1, -18),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = th.Surface,
		BorderSizePixel = 0,
		Parent = card,
	})
	corner(3, track)

	local trackFill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = colorA,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(3, trackFill)
	local fillGrad = gradient(trackFill, colorA, colorA, 0)

	local thumb = make("Frame", {
		Name = "Thumb",
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = th.Background,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = track,
	})
	corner(7, thumb)
	local thumbStroke = stroke(th.Border, 2, thumb)

	local clickable = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 1, -34),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = card,
	})

	local value = default
	local dragging = false

	local function updateVisual()
		local p = (value - min) / math.max(0.0001, (max - min))
		tw(trackFill, 0.1, { Size = UDim2.new(p, 0, 1, 0) }, "outQuad")
		tw(thumb, 0.1, { Position = UDim2.new(p, 0, 0.5, 0) }, "outQuad")
		valueBox.Text = tostring(math.floor(value * 100 + 0.5) / 100) .. unitSuffix

		local c = colorA:Lerp(colorB, p)
		tw(trackFill, 0.15, { BackgroundColor3 = c }, "outQuad")
		fillGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA:Lerp(colorB, math.max(0, p - 0.35))),
			ColorSequenceKeypoint.new(1, c),
		})

		if cardStroke then
			tw(cardStroke, 0.15, { Color = th.Border:Lerp(colorB, p * 0.55) }, "outQuad")
		end
	end

	updateVisual()

	local function setFromInput(input)
		local absX = track.AbsolutePosition.X
		local szX = track.AbsoluteSize.X
		if szX <= 0 then return end
		local p = math.clamp((input.Position.X - absX) / szX, 0, 1)
		value = min + (max - min) * p
		updateVisual()
		if callback then task.spawn(function() callback(value) end) end
	end

	clickable.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromInput(input)
			tw(thumb, 0.15, { Size = UDim2.fromOffset(24, 24) }, "outBack")
			tw(thumbStroke, 0.15, { Thickness = 2.5 }, "outBack")
		end
	end)

	local uisConn
	uisConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				tw(thumb, 0.3, { Size = UDim2.fromOffset(20, 20) }, "outBack")
			end
		end
	end)

	return {
		Frame = card,
		Set = function(_, v)
			value = math.clamp(v, min, max)
			updateVisual()
		end,
		Get = function() return value end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- TEXT BOX
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createTextBox(section, text, placeholder, callback)
	local th = self.Theme
	local card = self:_createCard(section, 66)
	card.Name = "TextBox_" .. text

	make("TextLabel", {
		Size = UDim2.new(1, -28, 0, 16),
		Position = UDim2.fromOffset(14, 8),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Parent = card,
	})

	local box = make("TextBox", {
		Size = UDim2.new(1, -28, 0, 30),
		Position = UDim2.new(0, 14, 1, -38),
		BackgroundColor3 = th.Surface,
		Text = "",
		PlaceholderText = placeholder or "Введите…",
		PlaceholderColor3 = th.TextSecondary,
		TextColor3 = th.TextPrimary,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
		Parent = card,
	})
	corner(8, box)
	pad(0, 0, 10, 10, box)
	local boxStroke = stroke(th.Border, 2, box)

	box.Focused:Connect(function()
		tw(boxStroke, 0.2, { Color = th.Accent, Thickness = 2.5 }, "outQuad")
		tw(box, 0.2, { Position = UDim2.new(0, 12, 1, -40) }, "outBack")
	end)
	box.FocusLost:Connect(function(enterPressed)
		tw(boxStroke, 0.25, { Color = th.Border, Thickness = 2 }, "outQuad")
		tw(box, 0.25, { Position = UDim2.new(0, 14, 1, -38) }, "outBack")
		if callback then task.spawn(function() callback(box.Text, enterPressed) end) end
	end)

	return {
		Frame = card,
		Get = function() return box.Text end,
		Set = function(_, v) box.Text = v end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- LABEL
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createLabel(section, text)
	local th = self.Theme
	local card = self:_createCard(section, 30)
	card.Name = "Label"
	card.AutomaticSize = Enum.AutomaticSize.Y

	local label = make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = th.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})

	return {
		Frame = card,
		Set = function(_, t) label.Text = t end,
	}
end

-- ═══════════════════════════════════════════════════════════════════════
-- CHANGELOG
-- ═══════════════════════════════════════════════════════════════════════
function UI:_createChangelog(section, title, entries)
	local th = self.Theme

	local card = self:_createCard(section, 30)
	card.Name = "Changelog"
	card.AutomaticSize = Enum.AutomaticSize.Y

	local header = make("TextLabel", {
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Text = title or "CHANGELOG",
		TextColor3 = th.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBlack,
		TextSize = 13,
		Parent = card,
	})

	local list = make("Frame", {
		Size = UDim2.new(1, -20, 0, 0),
		Position = UDim2.fromOffset(10, 30),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})

	local modal -- создадим при первом клике
	local function ensureModal()
		if modal and modal.Parent then return modal end

		modal = make("Frame", {
			Name = "ChangelogModal",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			BackgroundColor3 = th.Background,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 50,
			Parent = self.Frame,
		})
		corner(18, modal)

		local modalTitle = make("TextLabel", {
			Size = UDim2.new(1, -80, 0, 40),
			Position = UDim2.fromOffset(40, 20),
			BackgroundTransparency = 1,
			Text = title or "CHANGELOG",
			TextColor3 = th.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			ZIndex = 51,
			Parent = modal,
		})

		local closeBtn = make("TextButton", {
			Size = UDim2.fromOffset(30, 30),
			Position = UDim2.new(1, -42, 0, 24),
			BackgroundColor3 = th.Background,
			Text = "✕",
			TextColor3 = th.TextPrimary,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			BorderSizePixel = 0,
			ZIndex = 51,
			Parent = modal,
		})
		corner(9, closeBtn)
		stroke(th.Border, 2, closeBtn)

		local scroll = make("ScrollingFrame", {
			Size = UDim2.new(1, -60, 1, -100),
			Position = UDim2.fromOffset(30, 78),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = th.Border,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 51,
			Parent = modal,
		})
		make("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = scroll,
		})
		pad(0, 20, 4, 20, scroll)

		-- store refs
		Store.set(modal, "title", modalTitle)
		Store.set(modal, "scroll", scroll)
		Store.set(modal, "closeBtn", closeBtn)

		local close = function()
			customTween(0.25, Ease.inQuad, function(a)
				modal.BackgroundTransparency = 1 - (1 - a) * 0.94
			end)
			tw(scroll, 0.25, { Position = UDim2.fromOffset(30, 88) }, "inQuad")
			task.delay(0.26, function() modal.Visible = false end)
		end
		closeBtn.MouseButton1Click:Connect(close)
		Store.set(modal, "close", close)

		return modal
	end

	for i, entry in ipairs(entries) do
		local entryBtn = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = th.Surface,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = i,
			Parent = list,
		})
		corner(8, entryBtn)
		local es = stroke(th.Border, 1.5, entryBtn, 0.35)

		local badge = make("TextLabel", {
			Size = UDim2.fromOffset(40, 18),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = entry.color or th.Accent,
			Text = entry.tag or "NEW",
			TextColor3 = th.Background,
			Font = Enum.Font.GothamBlack,
			TextSize = 9,
			BorderSizePixel = 0,
			Parent = entryBtn,
		})
		corner(5, badge)

		local lbl = make("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0),
			Position = UDim2.fromOffset(56, 0),
			BackgroundTransparency = 1,
			Text = entry.text or "",
			TextColor3 = th.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = entryBtn,
		})

		entryBtn.MouseEnter:Connect(function()
			tw(entryBtn, 0.25, {
				Size = UDim2.new(1, 6, 0, 38),
				Position = UDim2.new(0, -3, 0, entryBtn.Position.Y.Offset - 2),
				BackgroundColor3 = th.IsDark and th.Border or Color3.fromRGB(225, 224, 220),
			}, "outBack")
			tw(es, 0.2, { Transparency = 0, Thickness = 2 }, "outQuad")
			tw(badge, 0.2, { Size = UDim2.fromOffset(44, 20) }, "outBack")
		end)
		entryBtn.MouseLeave:Connect(function()
			tw(entryBtn, 0.28, {
				Size = UDim2.new(1, 0, 0, 34),
				Position = UDim2.new(0, 0, 0, entryBtn.Position.Y.Offset + 2),
				BackgroundColor3 = th.Surface,
			}, "outBack")
			tw(es, 0.2, { Transparency = 0.35, Thickness = 1.5 }, "outQuad")
			tw(badge, 0.2, { Size = UDim2.fromOffset(40, 18) }, "outBack")
		end)

		entryBtn.MouseButton1Click:Connect(function()
			local m = ensureModal()
			local sc = Store.get(m, "scroll")
			for _, c in ipairs(sc:GetChildren()) do
				if c:IsA("GuiObject") then c:Destroy() end
			end
			for j, e in ipairs(entries) do
				local row = make("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = (j == i) and th.Surface or th.Background,
					BorderSizePixel = 0,
					LayoutOrder = j,
					Parent = sc,
				})
				corner(12, row)
				stroke(th.Border, 2, row, 0)
				pad(14, 14, 16, 16, row)

				local bdg = make("TextLabel", {
					Size = UDim2.fromOffset(56, 20),
					BackgroundColor3 = e.color or th.Accent,
					Text = e.tag or "NEW",
					TextColor3 = th.Background,
					Font = Enum.Font.GothamBlack,
					TextSize = 10,
					BorderSizePixel = 0,
					Parent = row,
				})
				corner(6, bdg)

				local txt = make("TextLabel", {
					Size = UDim2.new(1, -70, 0, 0),
					Position = UDim2.fromOffset(66, 0),
					BackgroundTransparency = 1,
					Text = e.text or "",
					TextColor3 = th.TextPrimary,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextWrapped = true,
					AutomaticSize = Enum.AutomaticSize.Y,
					Parent = row,
				})

				row.BackgroundTransparency = 1
				txt.TextTransparency = 1
				tw(row, 0.35, { BackgroundTransparency = 0 }, "outExpo", j * 0.04)
				tw(txt, 0.35, { TextTransparency = 0 }, "outExpo", j * 0.04)
			end

			m.Visible = true
			m.BackgroundTransparency = 1
			sc.Position = UDim2.fromOffset(30, 90)
			customTween(0.35, Ease.outExpo, function(a)
				m.BackgroundTransparency = 1 - a * 0.94
			end)
			tw(sc, 0.45, { Position = UDim2.fromOffset(30, 78) }, "outExpo")
		end)

		entryBtn.BackgroundTransparency = 1
		lbl.TextTransparency = 1
		badge.TextTransparency = 1
		tw(entryBtn, 0.4, { BackgroundTransparency = 0 }, "outExpo", i * 0.05)
		tw(lbl, 0.4, { TextTransparency = 0 }, "outExpo", i * 0.05)
		tw(badge, 0.4, { TextTransparency = 0 }, "outExpo", i * 0.05)
	end

	card.Size = UDim2.new(1, 0, 0, 30 + #entries * 40 + 8)

	return { Frame = card }
end

-- ═══════════════════════════════════════════════════════════════════════
-- THEME SWITCHING
-- ═══════════════════════════════════════════════════════════════════════
function UI:SetTheme(name, custom)
	if custom then
		self.CustomTheme = custom
		self.ThemeName = "Custom"
	elseif Themes[name] then
		self.ThemeName = name
		self.Theme = Themes[name]
		self.CustomTheme = nil
	end
	self:_retheme()
end

function UI:_retheme()
	local th = self.Theme
	tw(self.Frame, 0.35, { BackgroundColor3 = th.Background }, "outQuad")
	tw(self.MainStroke, 0.35, { Color = th.Border }, "outQuad")
	tw(self.Shadow, 0.35, { BackgroundColor3 = th.Shadow }, "outQuad")
	tw(self.Header, 0.35, { BackgroundColor3 = th.Background }, "outQuad")
	tw(self.TitleLabel, 0.35, { TextColor3 = th.TextPrimary }, "outQuad")
	tw(self.SubtitleLabel, 0.35, { TextColor3 = th.TextSecondary }, "outQuad")
	tw(self.Logo, 0.35, { BackgroundColor3 = th.Accent }, "outQuad")
	tw(self.LogoIcon, 0.35, { TextColor3 = th.Background }, "outQuad")
	tw(self.Rail, 0.35, { BackgroundColor3 = th.Surface }, "outQuad")
	tw(self.Footer, 0.35, { BackgroundColor3 = th.Surface }, "outQuad")
	tw(self.FooterLeft, 0.35, { TextColor3 = th.TextSecondary }, "outQuad")
	tw(self.FooterRight, 0.35, { TextColor3 = th.TextSecondary }, "outQuad")

	if th.IsDark then
		tw(self.NeonStroke, 0.5, { Transparency = 0.4, Color = th.Neon }, "outQuad")
	else
		tw(self.NeonStroke, 0.5, { Transparency = 1 }, "outQuad")
	end
end

-- ═══════════════════════════════════════════════════════════════════════
-- SHOW / HIDE
-- ═══════════════════════════════════════════════════════════════════════
function UI:Show()
	if self.IsOpen then return end
	self.IsOpen = true

	self.Frame.Visible = true
	self.Shadow.Visible = true

	self.Frame.Size = UDim2.new(0, 0, 0, 0)
	self.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Frame.BackgroundTransparency = 1
	self.Frame.Rotation = 8
	self.Shadow.BackgroundTransparency = 1
	self.Shadow.Position = UDim2.fromOffset(0, 0)

	customTween(0.45, Ease.outBack, function(a)
		self.Frame.BackgroundTransparency = 1 - a
		self.Frame.Rotation = 8 * (1 - a)
	end)
	tw(self.Shadow, 0.5, { BackgroundTransparency = 0.15, Position = UDim2.fromOffset(10, 10) }, "outBack", 0.05)
	tw(self.Frame, 0.5, {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
	}, "outBack")
	tw(self.MainStroke, 0.4, { Transparency = 0 }, "outExpo")
	tw(self.NeonStroke, 0.5, {
		Transparency = self.Theme.IsDark and 0.4 or 1,
	}, "outExpo")

	local logoSize = self.Logo.Size
	self.Logo.Size = UDim2.fromOffset(0, 0)
	tw(self.Logo, 0.55, { Size = logoSize }, "outBack", 0.15)
end

function UI:Hide()
	if not self.IsOpen then return end
	self.IsOpen = false

	customTween(0.35, Ease.inBack, function(a)
		self.Frame.BackgroundTransparency = a
		self.Frame.Rotation = 6 * a
	end)
	tw(self.Shadow, 0.35, { BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 2) }, "inBack")
	tw(self.Frame, 0.35, { Size = UDim2.fromOffset(40, 40) }, "inBack")
	tw(self.MainStroke, 0.3, { Transparency = 1 }, "inQuad")

	task.delay(0.36, function()
		if not self.IsOpen then
			self.Frame.Visible = false
			self.Shadow.Visible = false
			self.Frame.Size = UDim2.fromScale(1, 1)
			self.Frame.Position = UDim2.fromScale(0.5, 0.5)
			self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		end
	end)
end

function UI:Toggle()
	if self.IsOpen then self:Hide() else self:Show() end
end

function UI:ToggleMinimize()
	self.IsMinimized = not self.IsMinimized
	local target = self.IsMinimized and 66 or self.WindowSize.Y.Offset
	tw(self.Container, 0.45, { Size = UDim2.fromOffset(self.WindowSize.X.Offset, target) }, "outBack")
end

return UI
