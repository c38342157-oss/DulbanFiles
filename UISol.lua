-- DulbanUI v2.0.0
-- Roblox/Luau UI library inspired by DulbanHTML_Libs / DulbanFiles.
-- W&B neo-brutalism + FrostDrop contour glow + optional cyberpunk neon.

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local DulbanUI = {
    Version = "2.0.0",
    Themes = {},
}

local LocalPlayer = Players.LocalPlayer

local function copyTable(source)
    local out = {}
    for k, v in pairs(source or {}) do
        if type(v) == "table" then
            out[k] = copyTable(v)
        else
            out[k] = v
        end
    end
    return out
end

local function merge(base, patch)
    local out = copyTable(base)
    for k, v in pairs(patch or {}) do
        out[k] = v
    end
    return out
end

local function create(className, props)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        if key ~= "Parent" then
            obj[key] = value
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12),
        Parent = parent,
    })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Color3.new(0, 0, 0),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
        Parent = parent,
    })
end

local function pad(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or left or 0),
        PaddingBottom = UDim.new(0, bottom or top or left or 0),
        Parent = parent,
    })
end

local function list(parent, direction, spacing, horizontal, vertical)
    return create("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, spacing or 0),
        HorizontalAlignment = horizontal or Enum.HorizontalAlignment.Left,
        VerticalAlignment = vertical or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function tween(instance, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[DulbanUI] callback error: " .. tostring(err))
    end
end

local function clamp01(x)
    return math.clamp(x, 0, 1)
end

local function lerpColor(a, b, t)
    return a:Lerp(b, clamp01(t))
end

local function shade(c, amount)
    if amount >= 0 then
        return c:Lerp(Color3.new(1, 1, 1), clamp01(amount))
    end
    return c:Lerp(Color3.new(0, 0, 0), clamp01(-amount))
end

local function valueText(value, decimals)
    decimals = decimals or 0
    if decimals <= 0 then
        return tostring(math.round(value))
    end
    return string.format("%." .. tostring(decimals) .. "f", value)
end

local function roundToStep(value, minValue, step)
    if not step or step <= 0 then
        return value
    end
    return minValue + math.round((value - minValue) / step) * step
end

local function mousePosition()
    local p = UserInputService:GetMouseLocation()
    return Vector2.new(p.X, p.Y)
end

local function getPlayerGui()
    if not LocalPlayer then
        return nil
    end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local function makeMaid()
    local maid = { items = {} }
    function maid:Give(item)
        table.insert(self.items, item)
        return item
    end
    function maid:Clean()
        for _, item in ipairs(self.items) do
            if typeof(item) == "RBXScriptConnection" then
                pcall(function() item:Disconnect() end)
            elseif typeof(item) == "Instance" then
                pcall(function() item:Destroy() end)
            elseif type(item) == "function" then
                pcall(item)
            end
        end
        table.clear(self.items)
    end
    return maid
end

DulbanUI.Themes.White = {
    Background = Color3.fromRGB(255, 255, 255),
    Surface = Color3.fromRGB(247, 246, 243),
    Surface2 = Color3.fromRGB(239, 238, 234),
    Text = Color3.fromRGB(13, 13, 13),
    Muted = Color3.fromRGB(108, 108, 104),
    Border = Color3.fromRGB(13, 13, 13),
    Accent = Color3.fromRGB(13, 13, 13),
    AccentText = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(31, 163, 86),
    Danger = Color3.fromRGB(229, 73, 60),
    Warning = Color3.fromRGB(213, 146, 27),
    Shadow = Color3.fromRGB(13, 13, 13),
    Glow = Color3.fromRGB(39, 131, 222),
    Glow2 = Color3.fromRGB(125, 249, 255),
    Track = Color3.fromRGB(13, 13, 13),
    Dim = Color3.fromRGB(0, 0, 0),
    IsDark = false,
    Neon = false,
}

DulbanUI.Themes.Dark = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(28, 28, 34),
    Surface2 = Color3.fromRGB(36, 36, 44),
    Text = Color3.fromRGB(242, 242, 246),
    Muted = Color3.fromRGB(145, 145, 156),
    Border = Color3.fromRGB(82, 82, 94),
    Accent = Color3.fromRGB(242, 242, 246),
    AccentText = Color3.fromRGB(18, 18, 22),
    Success = Color3.fromRGB(76, 217, 100),
    Danger = Color3.fromRGB(255, 69, 58),
    Warning = Color3.fromRGB(255, 214, 10),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(125, 180, 255),
    Glow2 = Color3.fromRGB(125, 249, 255),
    Track = Color3.fromRGB(210, 210, 218),
    Dim = Color3.fromRGB(0, 0, 0),
    IsDark = true,
    Neon = false,
}

DulbanUI.Themes.FrostDrop = {
    Background = Color3.fromRGB(13, 20, 36),
    Surface = Color3.fromRGB(20, 30, 52),
    Surface2 = Color3.fromRGB(28, 40, 66),
    Text = Color3.fromRGB(219, 230, 247),
    Muted = Color3.fromRGB(112, 132, 166),
    Border = Color3.fromRGB(56, 189, 248),
    Accent = Color3.fromRGB(122, 162, 255),
    AccentText = Color3.fromRGB(9, 15, 28),
    Success = Color3.fromRGB(126, 224, 163),
    Danger = Color3.fromRGB(242, 143, 173),
    Warning = Color3.fromRGB(242, 178, 107),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(56, 189, 248),
    Glow2 = Color3.fromRGB(125, 249, 255),
    Track = Color3.fromRGB(154, 176, 208),
    Dim = Color3.fromRGB(2, 7, 18),
    IsDark = true,
    Neon = true,
}

DulbanUI.Themes.Cyberpunk = {
    Background = Color3.fromRGB(10, 5, 20),
    Surface = Color3.fromRGB(23, 10, 40),
    Surface2 = Color3.fromRGB(34, 15, 56),
    Text = Color3.fromRGB(234, 252, 255),
    Muted = Color3.fromRGB(147, 171, 196),
    Border = Color3.fromRGB(255, 94, 207),
    Accent = Color3.fromRGB(125, 249, 255),
    AccentText = Color3.fromRGB(10, 5, 20),
    Success = Color3.fromRGB(157, 255, 87),
    Danger = Color3.fromRGB(255, 48, 112),
    Warning = Color3.fromRGB(255, 225, 77),
    Shadow = Color3.fromRGB(255, 0, 200),
    Glow = Color3.fromRGB(125, 249, 255),
    Glow2 = Color3.fromRGB(255, 94, 207),
    Track = Color3.fromRGB(125, 249, 255),
    Dim = Color3.fromRGB(6, 0, 12),
    IsDark = true,
    Neon = true,
}

function DulbanUI.RegisterTheme(name, theme)
    assert(type(name) == "string" and name ~= "", "theme name must be a string")
    DulbanUI.Themes[name] = merge(DulbanUI.Themes.White, theme)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local function addRipple(button, color)
    if not button or not button.Parent then
        return
    end
    local p = mousePosition()
    local ap = button.AbsolutePosition
    local as = button.AbsoluteSize
    if as.X <= 0 or as.Y <= 0 then
        return
    end
    local localPos = Vector2.new(p.X - ap.X, p.Y - ap.Y)
    local diameter = math.max(as.X, as.Y) * 2.2
    local ripple = create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(localPos.X, localPos.Y),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = color or Color3.new(1, 1, 1),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 10,
        Parent = button,
    })
    corner(ripple, 999)
    button.ClipsDescendants = true
    local t = tween(ripple, 0.42, {
        Size = UDim2.fromOffset(diameter, diameter),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    t.Completed:Connect(function()
        if ripple then
            ripple:Destroy()
        end
    end)
end

local function attachTilt(window, object, options)
    options = options or {}
    local intensity = options.Intensity or 1
    local maxRotation = options.MaxRotation or 2.2
    local scaleAmount = options.Scale or 1.015
    local shadowObject = options.Shadow
    local gradientObject = options.Gradient
    local baseRotation = object.Rotation
    local scale = object:FindFirstChild("DulbanTiltScale")
    if not scale then
        scale = create("UIScale", { Name = "DulbanTiltScale", Scale = 1, Parent = object })
    end

    -- IMPORTANT:
    -- Never animate object.Position here. Some Dulban controls live inside
    -- UIListLayout / AutomaticCanvasSize trees. Fighting layout-owned Position
    -- can make the control or scrolling canvas jump far away on hover.
    -- Tilt is therefore rendered with rotation + scale + parallax shadow/glare.
    local hovering = false
    local currentX, currentY = 0, 0
    local hoverAbsolutePosition = Vector2.new()
    local hoverAbsoluteSize = Vector2.new(1, 1)

    local function restore()
        hovering = false
        currentX, currentY = 0, 0
        tween(object, 0.32, { Rotation = baseRotation }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        tween(scale, 0.32, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if shadowObject then
            tween(shadowObject, 0.32, { Position = UDim2.fromOffset(4, 4) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
        if gradientObject then
            tween(gradientObject, 0.35, { Offset = Vector2.new(0, 0), Rotation = 30 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
    end

    window._maid:Give(object.MouseEnter:Connect(function()
        hovering = true
        -- Snapshot the unchanging hit rectangle once. Using the live
        -- AbsolutePosition of a rotating/scaling object creates feedback/jitter.
        hoverAbsolutePosition = object.AbsolutePosition
        hoverAbsoluteSize = object.AbsoluteSize
        if hoverAbsoluteSize.X <= 0 then hoverAbsoluteSize = Vector2.new(1, hoverAbsoluteSize.Y) end
        if hoverAbsoluteSize.Y <= 0 then hoverAbsoluteSize = Vector2.new(hoverAbsoluteSize.X, 1) end
        tween(scale, 0.22, { Scale = scaleAmount }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end))

    window._maid:Give(object.MouseLeave:Connect(restore))

    window._maid:Give(RunService.RenderStepped:Connect(function(dt)
        if not hovering or not object.Visible or not object.Parent then
            return
        end

        local p = mousePosition()
        local nx = math.clamp(((p.X - hoverAbsolutePosition.X) / hoverAbsoluteSize.X - 0.5) * 2, -1, 1)
        local ny = math.clamp(((p.Y - hoverAbsolutePosition.Y) / hoverAbsoluteSize.Y - 0.5) * 2, -1, 1)
        local speed = 1 - math.exp(-18 * dt)
        currentX = currentX + (nx - currentX) * speed
        currentY = currentY + (ny - currentY) * speed

        -- Safe pseudo-3D: no Position writes, so layouts cannot be corrupted.
        object.Rotation = baseRotation + currentX * maxRotation * intensity

        if shadowObject then
            shadowObject.Position = UDim2.fromOffset(
                4 - currentX * 2.2 * intensity,
                4 - currentY * 2.2 * intensity
            )
        end
        if gradientObject then
            gradientObject.Offset = Vector2.new(currentX * 0.16, currentY * 0.16)
            gradientObject.Rotation = 30 + currentX * 18 - currentY * 5
        end
    end))

    return {
        Reset = restore,
    }
end

function DulbanUI.new(props)
    props = props or {}
    local self = setmetatable({}, Window)
    self._maid = makeMaid()
    self._themeCallbacks = {}
    self._tabs = {}
    self._tabButtons = {}
    self._activeTab = nil
    self._tabSerial = 0
    self._open = false
    self._destroyed = false
    self._overlayOpen = false
    self._themeOrder = props.ThemeOrder or { "White", "Dark", "FrostDrop", "Cyberpunk" }
    self._themeIndex = 1
    self.Title = props.Title or "DULBAN UI"
    self.Subtitle = props.Subtitle or "I CANT PLAY FAIR"
    self.Size = props.Size or UDim2.fromOffset(650, 480)
    self.ToggleKey = props.ToggleKey or Enum.KeyCode.Insert
    self.BlurChangelog = props.BlurChangelog ~= false
    self.DragSmoothness = props.DragSmoothness or 18
    self.Parent = props.Parent or getPlayerGui()
    self.ThemeName = type(props.Theme) == "string" and props.Theme or "White"
    if type(props.Theme) == "table" then
        self.ThemeName = props.ThemeName or "Custom"
        self.Theme = merge(DulbanUI.Themes.White, props.Theme)
    else
        self.Theme = DulbanUI.Themes[self.ThemeName] or DulbanUI.Themes.White
    end
    for i, name in ipairs(self._themeOrder) do
        if name == self.ThemeName then
            self._themeIndex = i
            break
        end
    end
    self:_build(props)
    return self
end

function Window:_onTheme(fn)
    table.insert(self._themeCallbacks, fn)
    fn(self.Theme, false)
end

function Window:_emitTheme(animated)
    for _, fn in ipairs(self._themeCallbacks) do
        safeCall(fn, self.Theme, animated ~= false)
    end
end

function Window:_themed(instance, property, token, animated, transform)
    self:_onTheme(function(theme, doAnimate)
        local value = theme[token]
        if transform then
            value = transform(value, theme)
        end
        if doAnimate and animated ~= false then
            tween(instance, 0.28, { [property] = value }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            instance[property] = value
        end
    end)
    return instance
end

function Window:_build(props)
    assert(self.Parent, "DulbanUI must run on the client with a PlayerGui or explicit Parent")

    self.ScreenGui = create("ScreenGui", {
        Name = "DulbanUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = props.DisplayOrder or 200,
        Parent = self.Parent,
    })

    self._backdropTarget = props.Backdrop == false and 1 or (props.BackdropTransparency or 0.72)

    self.Backdrop = create("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Theme.Dim,
        BackgroundTransparency = self._backdropTarget,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1,
        Parent = self.ScreenGui,
    })
    self:_themed(self.Backdrop, "BackgroundColor3", "Dim")

    self.Container = create("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        Size = self.Size,
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 10,
        Parent = self.ScreenGui,
    })
    self.WindowScale = create("UIScale", { Name = "WindowScale", Scale = 0.9, Parent = self.Container })

    self.GlowBack = create("Frame", {
        Name = "GlowBack",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 9,
        Parent = self.Container,
    })
    corner(self.GlowBack, 25)
    self.GlowStroke = stroke(self.GlowBack, self.Theme.Glow, 3, 1)

    self.Shadow = create("Frame", {
        Name = "Shadow",
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Theme.Shadow,
        BackgroundTransparency = self.Theme.IsDark and 0.42 or 0.04,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = self.Container,
    })
    corner(self.Shadow, 21)

    self.Frame = create("Frame", {
        Name = "Main",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 11,
        Parent = self.Container,
    })
    corner(self.Frame, 21)
    self.MainStroke = stroke(self.Frame, self.Theme.Border, 2, 0)

    self.WindowGradient = create("UIGradient", {
        Rotation = 112,
        Color = ColorSequence.new(self.Theme.Background, self.Theme.Surface),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.55, 0.04),
            NumberSequenceKeypoint.new(1, 0.12),
        }),
        Parent = self.Frame,
    })

    self:_onTheme(function(theme, animated)
        local function setOrTween(obj, props2)
            if animated then
                tween(obj, 0.3, props2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            else
                for k, v in pairs(props2) do obj[k] = v end
            end
        end
        setOrTween(self.Frame, { BackgroundColor3 = theme.Background })
        setOrTween(self.Shadow, {
            BackgroundColor3 = theme.Shadow,
            BackgroundTransparency = theme.IsDark and 0.42 or 0.04,
        })
        self.MainStroke.Color = theme.Border
        self.WindowGradient.Color = ColorSequence.new(theme.Background, theme.Surface)
        self.GlowStroke.Color = theme.Glow
        if theme.Neon then
            setOrTween(self.GlowStroke, { Transparency = 0.42 })
        else
            setOrTween(self.GlowStroke, { Transparency = 1 })
        end
    end)

    self:_buildHeader()
    self:_buildBody()
    self:_buildFooter()
    self:_buildGlobalInput()
    self:_buildDrag()

    if props.AutoShow ~= false then
        task.defer(function()
            self:Show()
        end)
    end
end

function Window:_buildHeader()
    self.Header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20,
        Parent = self.Frame,
    })
    self:_themed(self.Header, "BackgroundColor3", "Background")

    self.HeaderBorder = create("Frame", {
        Name = "HeaderBorder",
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 22,
        Parent = self.Header,
    })
    self:_themed(self.HeaderBorder, "BackgroundColor3", "Border")

    for i = -2, 13 do
        local stripe = create("Frame", {
            Name = "Stripe",
            Position = UDim2.fromOffset(i * 54, -30),
            Size = UDim2.fromOffset(1, 140),
            Rotation = -22,
            BackgroundColor3 = self.Theme.Border,
            BackgroundTransparency = 0.93,
            BorderSizePixel = 0,
            ZIndex = 20,
            Parent = self.Header,
        })
        self:_themed(stripe, "BackgroundColor3", "Border", false)
    end

    self.Logo = create("Frame", {
        Name = "Logo",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 23,
        Parent = self.Header,
    })
    corner(self.Logo, 13)
    self.LogoStroke = stroke(self.Logo, self.Theme.Border, 2, 0)
    self:_onTheme(function(theme, animated)
        if animated then
            tween(self.Logo, 0.28, { BackgroundColor3 = theme.Accent })
        else
            self.Logo.BackgroundColor3 = theme.Accent
        end
        self.LogoStroke.Color = theme.Border
    end)

    self.LogoText = create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "D",
        TextColor3 = self.Theme.AccentText,
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        ZIndex = 24,
        Parent = self.Logo,
    })
    self:_themed(self.LogoText, "TextColor3", "AccentText")

    self.LogoRing = create("Frame", {
        Name = "LogoRing",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(54, 54),
        BackgroundTransparency = 1,
        ZIndex = 22,
        Parent = self.Logo,
    })
    corner(self.LogoRing, 999)
    self.LogoRingStroke = stroke(self.LogoRing, self.Theme.Glow, 1.2, 0.5)
    self:_onTheme(function(theme)
        self.LogoRingStroke.Color = theme.Glow
        self.LogoRingStroke.Transparency = theme.Neon and 0.2 or 0.68
    end)

    self._maid:Give(RunService.RenderStepped:Connect(function(dt)
        if self._destroyed then return end
        if self.Theme.Neon and self.Container.Visible then
            self.LogoRing.Rotation = (self.LogoRing.Rotation + 12 * dt) % 360
            self.GlowStroke.Transparency = 0.36 + math.sin(os.clock() * 2.3) * 0.12
        end
    end))

    local titleBox = create("Frame", {
        Name = "TitleBox",
        Position = UDim2.fromOffset(76, 0),
        Size = UDim2.new(1, -270, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 23,
        Parent = self.Header,
    })

    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(0, 13),
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        ZIndex = 24,
        Parent = titleBox,
    })
    self:_themed(self.TitleLabel, "TextColor3", "Text")

    self.SubtitleLabel = create("TextLabel", {
        Name = "Subtitle",
        Position = UDim2.fromOffset(0, 38),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self.Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 24,
        Parent = titleBox,
    })
    self:_themed(self.SubtitleLabel, "TextColor3", "Muted")

    local actions = create("Frame", {
        Name = "HeaderActions",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(150, 32),
        BackgroundTransparency = 1,
        ZIndex = 25,
        Parent = self.Header,
    })
    list(actions, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local function headerButton(name, text, width)
        local btn = create("TextButton", {
            Name = name,
            Size = UDim2.fromOffset(width or 30, 30),
            BackgroundColor3 = self.Theme.Surface,
            Text = text,
            TextColor3 = self.Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = name == "Theme" and 10 or 14,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 25,
            Parent = actions,
        })
        corner(btn, 9)
        local s = stroke(btn, self.Theme.Border, 1.5, 0.1)
        local sc = create("UIScale", { Scale = 1, Parent = btn })
        self:_onTheme(function(theme, animated)
            local props2 = { BackgroundColor3 = theme.Surface, TextColor3 = theme.Text }
            if animated then tween(btn, 0.25, props2) else for k,v in pairs(props2) do btn[k]=v end end
            s.Color = theme.Border
        end)
        self._maid:Give(btn.MouseEnter:Connect(function()
            tween(sc, 0.18, { Scale = 1.06 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(btn, 0.18, { BackgroundColor3 = shade(self.Theme.Surface, self.Theme.IsDark and 0.08 or -0.06) })
        end))
        self._maid:Give(btn.MouseLeave:Connect(function()
            tween(sc, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(btn, 0.18, { BackgroundColor3 = self.Theme.Surface })
        end))
        self._maid:Give(btn.MouseButton1Down:Connect(function()
            tween(sc, 0.08, { Scale = 0.93 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end))
        self._maid:Give(btn.MouseButton1Up:Connect(function()
            tween(sc, 0.16, { Scale = 1.06 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end))
        return btn
    end

    self.ThemeButton = headerButton("Theme", string.upper(self.ThemeName), 76)
    self.MinButton = headerButton("Min", "-", 30)
    self.CloseButton = headerButton("Close", "x", 30)

    self._maid:Give(self.ThemeButton.MouseButton1Click:Connect(function()
        self:CycleTheme()
    end))
    self._maid:Give(self.MinButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end))
    self._maid:Give(self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end))
end

function Window:_buildBody()
    self.Body = create("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 72),
        Size = UDim2.new(1, 0, 1, -98),
        BackgroundTransparency = 1,
        ZIndex = 15,
        Parent = self.Frame,
    })

    self.Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 68, 1, 0),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 16,
        Parent = self.Body,
    })
    self:_themed(self.Sidebar, "BackgroundColor3", "Surface")

    self.SidebarBorder = create("Frame", {
        Position = UDim2.new(1, -2, 0, 0),
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 17,
        Parent = self.Sidebar,
    })
    self:_themed(self.SidebarBorder, "BackgroundColor3", "Border")

    local rail = create("ScrollingFrame", {
        Name = "Rail",
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.new(1, -2, 1, -16),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 18,
        Parent = self.Sidebar,
    })
    list(rail, Enum.FillDirection.Vertical, 9, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
    pad(rail, 0, 0, 4, 8)
    self.Rail = rail

    self.ContentHost = create("Frame", {
        Name = "ContentHost",
        Position = UDim2.fromOffset(68, 0),
        Size = UDim2.new(1, -68, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 16,
        Parent = self.Body,
    })
end

function Window:_buildFooter()
    self.Footer = create("Frame", {
        Name = "Footer",
        Position = UDim2.new(0, 0, 1, -26),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = self.Frame,
    })
    self:_themed(self.Footer, "BackgroundColor3", "Surface")

    self.FooterTop = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Theme.Border,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = self.Footer,
    })
    self:_themed(self.FooterTop, "BackgroundColor3", "Border")

    self.FooterText = create("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = "DULBAN UI  v" .. DulbanUI.Version .. "   /   INSERT TO TOGGLE",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self.Theme.Muted,
        Font = Enum.Font.Code,
        TextSize = 10,
        ZIndex = 22,
        Parent = self.Footer,
    })
    self:_themed(self.FooterText, "TextColor3", "Muted")
end

function Window:_buildGlobalInput()
    self._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
            return
        end
        if input.KeyCode == Enum.KeyCode.Escape then
            if self._overlayOpen then
                self:CloseChangelog()
            elseif self._open then
                self:Hide()
            end
        end
    end))
end

function Window:_buildDrag()
    local dragging = false
    local dragStart = Vector2.new()
    local startCenter = Vector2.new()
    local goal = nil

    local function clampCenter(center)
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local half = self.Container.AbsoluteSize * 0.5
        local margin = 18
        return Vector2.new(
            math.clamp(center.X, math.min(half.X + margin, viewport.X * 0.5), math.max(viewport.X - half.X - margin, viewport.X * 0.5)),
            math.clamp(center.Y, math.min(half.Y + margin, viewport.Y * 0.5), math.max(viewport.Y - half.Y - margin, viewport.Y * 0.5))
        )
    end

    self._maid:Give(self.Header.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local p = Vector2.new(input.Position.X, input.Position.Y)
        local rightZone = self.Header.AbsolutePosition.X + self.Header.AbsoluteSize.X - 180
        if p.X >= rightZone then
            return
        end
        dragging = true
        dragStart = p
        local ap = self.Container.AbsolutePosition
        local as = self.Container.AbsoluteSize
        startCenter = Vector2.new(ap.X + as.X * 0.5, ap.Y + as.Y * 0.5)
        goal = startCenter
    end))

    self._maid:Give(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local now = Vector2.new(input.Position.X, input.Position.Y)
        goal = clampCenter(startCenter + (now - dragStart))
    end))

    self._maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    self._maid:Give(RunService.RenderStepped:Connect(function(dt)
        if not goal or not self.Container.Visible then return end
        local ap = self.Container.AbsolutePosition
        local as = self.Container.AbsoluteSize
        local current = Vector2.new(ap.X + as.X * 0.5, ap.Y + as.Y * 0.5)
        local alpha = 1 - math.exp(-self.DragSmoothness * dt)
        local nextCenter = current:Lerp(goal, alpha)
        self.Container.Position = UDim2.fromOffset(nextCenter.X, nextCenter.Y)
    end))
end

function Window:SetTheme(themeOrName, customName)
    if type(themeOrName) == "string" then
        local found = DulbanUI.Themes[themeOrName]
        if not found then
            warn("[DulbanUI] unknown theme: " .. themeOrName)
            return false
        end
        self.ThemeName = themeOrName
        self.Theme = found
    elseif type(themeOrName) == "table" then
        self.ThemeName = customName or "Custom"
        self.Theme = merge(DulbanUI.Themes.White, themeOrName)
    else
        return false
    end
    self.ThemeButton.Text = string.upper(self.ThemeName)
    self:_emitTheme(true)
    return true
end

function Window:CycleTheme()
    self._themeIndex += 1
    if self._themeIndex > #self._themeOrder then
        self._themeIndex = 1
    end
    local name = self._themeOrder[self._themeIndex]
    if not DulbanUI.Themes[name] then
        return self:CycleTheme()
    end
    self:SetTheme(name)
end

function Window:Show()
    if self._destroyed or self._open then return end
    self._open = true
    self.Backdrop.Visible = true
    self.Container.Visible = true
    self.Container.GroupTransparency = 1
    self.WindowScale.Scale = 0.88
    self.Container.Rotation = -1.2
    tween(self.Backdrop, 0.28, { BackgroundTransparency = self._backdropTarget }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(self.Container, 0.42, { GroupTransparency = 0, Rotation = 0 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(self.WindowScale, 0.52, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Window:Hide()
    if self._destroyed or not self._open then return end
    self._open = false
    if self._overlayOpen then
        self:CloseChangelog()
    end
    tween(self.Backdrop, 0.22, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(self.Container, 0.22, { GroupTransparency = 1, Rotation = 0.8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local t = tween(self.WindowScale, 0.25, { Scale = 0.91 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    t.Completed:Connect(function()
        if not self._open and self.Container then
            self.Container.Visible = false
            self.Backdrop.Visible = false
        end
    end)
end

function Window:Toggle()
    if self._open then self:Hide() else self:Show() end
end

function Window:ToggleMinimize()
    if self._destroyed then return end
    self._minimized = not self._minimized
    if self._minimized then
        self._storedSize = self.Container.Size
        tween(self.Container, 0.34, { Size = UDim2.new(self.Container.Size.X.Scale, self.Container.Size.X.Offset, 0, 72) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        tween(self.WindowScale, 0.2, { Scale = 0.98 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        self.MinButton.Text = "+"
    else
        tween(self.Container, 0.4, { Size = self._storedSize or self.Size }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(self.WindowScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        self.MinButton.Text = "-"
    end
end

function Window:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self._maid:Clean()
    if self._blur then
        pcall(function() self._blur:Destroy() end)
        self._blur = nil
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

function Window:CreateTab(name, icon)
    self._tabSerial += 1
    local index = self._tabSerial
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = name or ("Tab " .. tostring(index))
    tab.Icon = icon or string.sub(tab.Name, 1, 1)
    tab.Index = index
    tab.Sections = {}

    local button = create("TextButton", {
        Name = "Tab_" .. tab.Name,
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = self.Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = index,
        ZIndex = 19,
        Parent = self.Rail,
    })
    corner(button, 12)
    local buttonStroke = stroke(button, self.Theme.Border, 1.5, 1)
    local buttonScale = create("UIScale", { Scale = 1, Parent = button })

    local indicator = create("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -9, 0.5, 0),
        Size = UDim2.fromOffset(4, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = button,
    })
    corner(indicator, 999)

    local iconLabel = create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = tab.Icon,
        TextColor3 = self.Theme.Muted,
        Font = Enum.Font.GothamBlack,
        TextSize = #tostring(tab.Icon) > 2 and 9 or 16,
        ZIndex = 20,
        Parent = button,
    })

    local tooltip = create("TextLabel", {
        Name = "Tooltip",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 12, 0.5, 0),
        Size = UDim2.fromOffset(math.max(70, #tab.Name * 7 + 22), 28),
        BackgroundColor3 = self.Theme.Text,
        BackgroundTransparency = 0.02,
        Text = tab.Name,
        TextColor3 = self.Theme.Background,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Visible = true,
        ZIndex = 80,
        Parent = button,
    })
    corner(tooltip, 8)
    tooltip.BackgroundTransparency = 1

    self:_onTheme(function(theme, animated)
        buttonStroke.Color = theme.Border
        indicator.BackgroundColor3 = theme.Accent
        tooltip.BackgroundColor3 = theme.Text
        tooltip.TextColor3 = theme.Background
        local active = self._activeTab == tab
        local props2
        if active then
            props2 = { BackgroundColor3 = theme.Accent }
            iconLabel.TextColor3 = theme.AccentText
            buttonStroke.Transparency = 0
        else
            props2 = { BackgroundColor3 = theme.Surface }
            iconLabel.TextColor3 = theme.Muted
            buttonStroke.Transparency = 1
        end
        if animated then tween(button, 0.25, props2) else for k,v in pairs(props2) do button[k]=v end end
    end)

    self._maid:Give(button.MouseEnter:Connect(function()
        tween(buttonScale, 0.22, { Scale = 1.07 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(tooltip, 0.18, { BackgroundTransparency = 0.02, TextTransparency = 0, Position = UDim2.new(1, 8, 0.5, 0) })
        if self._activeTab ~= tab then
            tween(button, 0.18, { BackgroundColor3 = shade(self.Theme.Surface, self.Theme.IsDark and 0.08 or -0.05) })
            buttonStroke.Transparency = 0.2
        end
    end))
    self._maid:Give(button.MouseLeave:Connect(function()
        tween(buttonScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(tooltip, 0.16, { BackgroundTransparency = 1, TextTransparency = 1, Position = UDim2.new(1, 3, 0.5, 0) })
        if self._activeTab ~= tab then
            tween(button, 0.18, { BackgroundColor3 = self.Theme.Surface })
            buttonStroke.Transparency = 1
        end
    end))

    local group = create("CanvasGroup", {
        Name = "PageGroup_" .. tab.Name,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 17,
        Parent = self.ContentHost,
    })

    local page = create("ScrollingFrame", {
        Name = "Page_" .. tab.Name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = self.Theme.Border,
        ScrollBarImageTransparency = 0.35,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 18,
        Parent = group,
    })
    pad(page, 16, 16, 16, 22)
    list(page, Enum.FillDirection.Vertical, 14, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

    self:_onTheme(function(theme)
        page.ScrollBarImageColor3 = theme.Border
    end)

    tab.Button = button
    tab.ButtonStroke = buttonStroke
    tab.ButtonScale = buttonScale
    tab.Indicator = indicator
    tab.IconLabel = iconLabel
    tab.Group = group
    tab.Page = page

    table.insert(self._tabs, tab)
    table.insert(self._tabButtons, button)

    self._maid:Give(button.MouseButton1Click:Connect(function()
        addRipple(button, self.Theme.AccentText)
        self:SelectTab(tab)
    end))

    if not self._activeTab then
        self:SelectTab(tab, true)
    end

    return tab
end

function Window:SelectTab(tabOrName, instant)
    local target = tabOrName
    if type(tabOrName) == "string" then
        target = nil
        for _, tab in ipairs(self._tabs) do
            if tab.Name == tabOrName then
                target = tab
                break
            end
        end
    end
    if not target or target == self._activeTab then
        return
    end

    local previous = self._activeTab
    local direction = previous and (target.Index > previous.Index and 1 or -1) or 1
    self._activeTab = target

    for _, tab in ipairs(self._tabs) do
        local active = tab == target
        local theme = self.Theme
        if active then
            tween(tab.Button, instant and 0 or 0.24, { BackgroundColor3 = theme.Accent }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(tab.ButtonScale, instant and 0 or 0.26, { Scale = 1.04 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(tab.Indicator, instant and 0 or 0.28, { Size = UDim2.fromOffset(4, 24) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tab.IconLabel.TextColor3 = theme.AccentText
            tab.ButtonStroke.Color = theme.Border
            tab.ButtonStroke.Transparency = 0
        else
            tween(tab.Button, instant and 0 or 0.2, { BackgroundColor3 = theme.Surface }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(tab.ButtonScale, instant and 0 or 0.2, { Scale = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(tab.Indicator, instant and 0 or 0.18, { Size = UDim2.fromOffset(4, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tab.IconLabel.TextColor3 = theme.Muted
            tab.ButtonStroke.Transparency = 1
        end
    end

    if previous and previous.Group.Visible then
        if instant then
            previous.Group.Visible = false
            previous.Group.GroupTransparency = 1
        else
            tween(previous.Group, 0.16, {
                GroupTransparency = 1,
                Position = UDim2.fromOffset(-18 * direction, 0),
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.In).Completed:Connect(function()
                if self._activeTab ~= previous then
                    previous.Group.Visible = false
                end
            end)
        end
    end

    target.Group.Visible = true
    target.Group.Position = UDim2.fromOffset(instant and 0 or 24 * direction, 0)
    target.Group.GroupTransparency = instant and 0 or 1
    if not instant then
        tween(target.Group, 0.34, {
            GroupTransparency = 0,
            Position = UDim2.fromOffset(0, 0),
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
end

function Tab:CreateSection(title, subtitle)
    local section = setmetatable({}, Section)
    section.Tab = self
    section.Window = self.Window
    section.Title = title or "SECTION"
    section.Subtitle = subtitle
    section._serial = 0

    local root = create("Frame", {
        Name = "Section_" .. section.Title,
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 18,
        LayoutOrder = #self.Sections + 1,
        Parent = self.Page,
    })
    list(root, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

    local header = create("Frame", {
        Name = "SectionHeader",
        Size = UDim2.new(1, 0, 0, subtitle and 34 or 22),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        ZIndex = 18,
        Parent = root,
    })

    local titleLabel = create("TextLabel", {
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = string.upper(section.Title),
        TextColor3 = self.Window.Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack,
        TextSize = 10,
        ZIndex = 19,
        Parent = header,
    })
    self.Window:_themed(titleLabel, "TextColor3", "Muted")

    local line = create("Frame", {
        Position = UDim2.new(0, math.max(90, #section.Title * 7 + 18), 0, 8),
        Size = UDim2.new(1, -math.max(90, #section.Title * 7 + 18), 0, 1),
        BackgroundColor3 = self.Window.Theme.Border,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        ZIndex = 18,
        Parent = header,
    })
    self.Window:_themed(line, "BackgroundColor3", "Border")

    if subtitle then
        local sub = create("TextLabel", {
            Position = UDim2.fromOffset(0, 19),
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = self.Window.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            ZIndex = 19,
            Parent = header,
        })
        self.Window:_themed(sub, "TextColor3", "Muted")
    end

    local card = create("Frame", {
        Name = "Card",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Window.Theme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        ZIndex = 18,
        Parent = root,
    })
    corner(card, 15)
    local cardStroke = stroke(card, self.Window.Theme.Border, 1.4, self.Window.Theme.IsDark and 0.45 or 0.08)
    pad(card, 10, 10, 10, 10)
    list(card, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

    self.Window:_onTheme(function(theme, animated)
        if animated then tween(card, 0.25, { BackgroundColor3 = theme.Surface }) else card.BackgroundColor3 = theme.Surface end
        cardStroke.Color = theme.Border
        cardStroke.Transparency = theme.IsDark and 0.45 or 0.08
    end)

    section.Root = root
    section.Card = card
    table.insert(self.Sections, section)
    return section
end

function Section:_nextOrder()
    self._serial += 1
    return self._serial
end

function Section:_baseRow(height)
    local row = create("Frame", {
        Name = "Control",
        Size = UDim2.new(1, 0, 0, height or 58),
        BackgroundColor3 = self.Window.Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = self:_nextOrder(),
        ZIndex = 20,
        Parent = self.Card,
    })
    corner(row, 12)
    local s = stroke(row, self.Window.Theme.Border, 1, self.Window.Theme.IsDark and 0.62 or 0.72)
    local sc = create("UIScale", { Scale = 1, Parent = row })

    self.Window:_onTheme(function(theme, animated)
        if animated then tween(row, 0.22, { BackgroundColor3 = theme.Surface2 }) else row.BackgroundColor3 = theme.Surface2 end
        s.Color = theme.Border
        s.Transparency = theme.IsDark and 0.62 or 0.72
    end)

    self.Window._maid:Give(row.MouseEnter:Connect(function()
        tween(sc, 0.18, { Scale = 1.008 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end))
    self.Window._maid:Give(row.MouseLeave:Connect(function()
        tween(sc, 0.18, { Scale = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end))

    return row, s, sc
end

function Section:_labels(row, title, description, rightSpace)
    rightSpace = rightSpace or 74
    local titleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(13, description and 9 or 0),
        Size = UDim2.new(1, -(rightSpace + 20), 0, description and 19 or row.Size.Y.Offset),
        BackgroundTransparency = 1,
        Text = title or "Control",
        TextColor3 = self.Window.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 23,
        Parent = row,
    })
    self.Window:_themed(titleLabel, "TextColor3", "Text")

    local descLabel
    if description then
        descLabel = create("TextLabel", {
            Position = UDim2.fromOffset(13, 29),
            Size = UDim2.new(1, -(rightSpace + 20), 0, 16),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = self.Window.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 23,
            Parent = row,
        })
        self.Window:_themed(descLabel, "TextColor3", "Muted")
    end
    return titleLabel, descLabel
end

function Section:CreateLabel(text, description)
    local row = self:_baseRow(description and 58 or 42)
    local titleLabel, descLabel = self:_labels(row, text, description, 0)
    titleLabel.Size = UDim2.new(1, -26, 0, description and 19 or row.Size.Y.Offset)
    if descLabel then descLabel.Size = UDim2.new(1, -26, 0, 16) end
    return row
end

function Section:CreateSeparator(label)
    local holder = create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, label and 24 or 10),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        ZIndex = 20,
        Parent = self.Card,
    })
    local line = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, label and 90 or 0, 0.5, 0),
        Size = UDim2.new(1, label and -90 or 0, 0, 1),
        BackgroundColor3 = self.Window.Theme.Border,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Parent = holder,
    })
    self.Window:_themed(line, "BackgroundColor3", "Border")
    if label then
        local t = create("TextLabel", {
            Size = UDim2.fromOffset(82, 24),
            BackgroundTransparency = 1,
            Text = string.upper(label),
            TextColor3 = self.Window.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBlack,
            TextSize = 9,
            Parent = holder,
        })
        self.Window:_themed(t, "TextColor3", "Muted")
    end
    return holder
end

function Section:CreateButton(text, callback, options)
    if type(text) == "table" then
        options = text
        callback = options.Callback
        text = options.Text or options.Title or "Button"
    else
        options = options or {}
    end

    local wrapper = create("Frame", {
        Name = "ButtonWrap",
        Size = UDim2.new(1, 0, 0, options.Height or 50),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        ZIndex = 20,
        Parent = self.Card,
    })

    local shadowObj = create("Frame", {
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = self.Window.Theme.Border,
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = wrapper,
    })
    corner(shadowObj, 12)

    local button = create("TextButton", {
        Name = "Button",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = text,
        TextColor3 = self.Window.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = wrapper,
    })
    corner(button, 12)
    local s = stroke(button, self.Window.Theme.Border, 1.5, 0)
    local g = create("UIGradient", {
        Rotation = 30,
        Offset = Vector2.new(0, 0),
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.96),
            NumberSequenceKeypoint.new(0.5, 0.76),
            NumberSequenceKeypoint.new(1, 0.98),
        }),
        Parent = button,
    })

    self.Window:_onTheme(function(theme, animated)
        local props2 = { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }
        if animated then tween(button, 0.25, props2) else for k,v in pairs(props2) do button[k]=v end end
        shadowObj.BackgroundColor3 = theme.Border
        s.Color = theme.Border
    end)

    self.Window._maid:Give(button.MouseEnter:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = shade(self.Window.Theme.Background, self.Window.Theme.IsDark and 0.08 or -0.04) })
        tween(shadowObj, 0.18, { Position = UDim2.fromOffset(6, 6), BackgroundTransparency = 0.25 })
    end))
    self.Window._maid:Give(button.MouseLeave:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = self.Window.Theme.Background })
        tween(shadowObj, 0.18, { Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 0.38 })
    end))
    self.Window._maid:Give(button.MouseButton1Click:Connect(function()
        addRipple(button, self.Window.Theme.Accent)
        safeCall(callback)
    end))

    if options.Tilt ~= false then
        attachTilt(self.Window, button, {
            Intensity = options.TiltIntensity or 1,
            MaxRotation = options.MaxRotation or 1.8,
            Travel = options.Travel or 2.8,
            Scale = options.HoverScale or 1.012,
            Shadow = shadowObj,
            Gradient = g,
        })
    end

    return {
        Instance = button,
        SetText = function(_, value) button.Text = tostring(value) end,
        Fire = function() safeCall(callback) end,
    }
end

function Section:CreateToggle(title, default, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        default = options.Default
        title = options.Text or options.Title or "Toggle"
    else
        options = options or {}
    end
    local state = default == true
    local row = self:_baseRow(options.Description and 60 or 54)
    self:_labels(row, title, options.Description, 74)

    local toggle = create("TextButton", {
        Name = "Toggle",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        Size = UDim2.fromOffset(48, 26),
        BackgroundColor3 = self.Window.Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 25,
        Parent = row,
    })
    corner(toggle, 999)
    local toggleStroke = stroke(toggle, self.Window.Theme.Border, 1.5, 0.18)
    local knob = create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 26,
        Parent = toggle,
    })
    corner(knob, 999)
    local scale = create("UIScale", { Scale = 1, Parent = toggle })

    local function render(animated)
        local theme = self.Window.Theme
        local trackColor = state and theme.Accent or theme.Surface
        local knobColor = state and theme.AccentText or theme.Text
        local position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        if animated then
            tween(toggle, 0.22, { BackgroundColor3 = trackColor }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(knob, 0.28, { Position = position, BackgroundColor3 = knobColor }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            toggle.BackgroundColor3 = trackColor
            knob.Position = position
            knob.BackgroundColor3 = knobColor
        end
        toggleStroke.Color = theme.Border
        toggleStroke.Transparency = state and 0 or 0.18
    end

    local function setState(value, fire)
        local nextState = value == true
        if nextState == state then return end
        state = nextState
        render(true)
        if fire ~= false then safeCall(callback, state) end
    end

    self.Window:_onTheme(function(_, animated)
        render(animated)
    end)
    render(false)

    self.Window._maid:Give(toggle.MouseEnter:Connect(function()
        tween(scale, 0.18, { Scale = 1.07 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end))
    self.Window._maid:Give(toggle.MouseLeave:Connect(function()
        tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end))
    self.Window._maid:Give(toggle.MouseButton1Click:Connect(function()
        addRipple(toggle, self.Window.Theme.AccentText)
        setState(not state, true)
    end))

    return {
        Instance = row,
        Set = function(_, value, fire) setState(value, fire) end,
        Get = function() return state end,
        Toggle = function() setState(not state, true) end,
    }
end

function Section:CreateDangerButton(title, holdDuration, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        holdDuration = options.HoldDuration
        title = options.Text or options.Title or "Danger"
    else
        options = options or {}
    end
    holdDuration = tonumber(holdDuration) or tonumber(options.HoldDuration) or 1
    holdDuration = math.max(0.15, holdDuration)

    local state = options.Default == true
    local holding = false
    local holdStarted = 0
    local completedThisPress = false
    local turnOffArmed = false

    local wrapper = create("Frame", {
        Name = "DangerWrap",
        Size = UDim2.new(1, 0, 0, options.Height or 52),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        ZIndex = 20,
        Parent = self.Card,
    })

    local shadowObj = create("Frame", {
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = options.Color or self.Window.Theme.Danger,
        BackgroundTransparency = 0.34,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = wrapper,
    })
    corner(shadowObj, 12)

    local button = create("TextButton", {
        Name = "Danger",
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 21,
        Parent = wrapper,
    })
    corner(button, 12)
    local border = stroke(button, options.Color or self.Window.Theme.Danger, 1.7, 0)
    local buttonScale = create("UIScale", { Scale = 1, Parent = button })

    local fill = create("Frame", {
        Name = "HoldFill",
        Size = UDim2.new(state and 1 or 0, 0, 1, 0),
        BackgroundColor3 = options.Color or self.Window.Theme.Danger,
        BackgroundTransparency = state and 0.12 or 0.2,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = button,
    })
    corner(fill, 12)

    local sheen = create("Frame", {
        Name = "Sheen",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, -50, 0.5, 0),
        Size = UDim2.fromOffset(24, 90),
        Rotation = 22,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
        ZIndex = 22,
        Parent = fill,
    })

    local titleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Window.Theme.Danger,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 24,
        Parent = button,
    })

    local status = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(92, 24),
        BackgroundTransparency = 1,
        Text = state and "ARMED" or ("HOLD " .. valueText(holdDuration, holdDuration % 1 == 0 and 0 or 1) .. "s"),
        TextColor3 = self.Window.Theme.Danger,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Code,
        TextSize = 10,
        ZIndex = 24,
        Parent = button,
    })

    local function dangerColor()
        return options.Color or self.Window.Theme.Danger
    end

    local function render(animated)
        local theme = self.Window.Theme
        local d = dangerColor()
        border.Color = d
        shadowObj.BackgroundColor3 = d
        local bg = state and d or theme.Background
        local textColor = state and theme.AccentText or d
        local fillSize = state and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 1)
        local fillTransparency = state and 0.08 or 0.2
        if animated then
            tween(button, 0.22, { BackgroundColor3 = bg })
            tween(fill, 0.24, { Size = fillSize, BackgroundColor3 = d, BackgroundTransparency = fillTransparency }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(titleLabel, 0.22, { TextColor3 = textColor })
            tween(status, 0.22, { TextColor3 = textColor })
        else
            button.BackgroundColor3 = bg
            fill.Size = fillSize
            fill.BackgroundColor3 = d
            fill.BackgroundTransparency = fillTransparency
            titleLabel.TextColor3 = textColor
            status.TextColor3 = textColor
        end
        status.Text = state and "ARMED / CLICK OFF" or ("HOLD " .. valueText(holdDuration, holdDuration % 1 == 0 and 0 or 1) .. "s")
    end

    local function setState(value, fire)
        local nextState = value == true
        if nextState == state then return end
        state = nextState
        render(true)
        if fire ~= false then safeCall(callback, state) end
    end

    local function cancelHold(animated)
        if not holding then return end
        holding = false
        if not state then
            if animated ~= false then
                tween(fill, 0.2, { Size = UDim2.fromScale(0, 1), BackgroundTransparency = 0.2 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            else
                fill.Size = UDim2.fromScale(0, 1)
            end
            status.Text = "HOLD " .. valueText(holdDuration, holdDuration % 1 == 0 and 0 or 1) .. "s"
        end
    end

    self.Window:_onTheme(function(_, animated)
        render(animated)
    end)
    render(false)

    self.Window._maid:Give(button.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        completedThisPress = false
        if state then
            turnOffArmed = true
            tween(buttonScale, 0.12, { Scale = 0.985 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            return
        end
        holding = true
        holdStarted = os.clock()
        status.Text = "0%"
        tween(buttonScale, 0.12, { Scale = 0.985 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end))

    self.Window._maid:Give(button.MouseLeave:Connect(function()
        turnOffArmed = false
        if holding then cancelHold(true) end
        tween(buttonScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end))

    self.Window._maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        tween(buttonScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if turnOffArmed and state and not completedThisPress then
            turnOffArmed = false
            setState(false, true)
            return
        end
        turnOffArmed = false
        if holding then cancelHold(true) end
    end))

    self.Window._maid:Give(RunService.RenderStepped:Connect(function()
        if not holding or state or not button.Visible then return end
        local progress = clamp01((os.clock() - holdStarted) / holdDuration)
        fill.Size = UDim2.fromScale(progress, 1)
        local d = dangerColor()
        button.BackgroundColor3 = lerpColor(self.Window.Theme.Background, d, progress * 0.18)
        titleLabel.TextColor3 = lerpColor(d, self.Window.Theme.AccentText, progress * 0.7)
        status.TextColor3 = titleLabel.TextColor3
        status.Text = tostring(math.floor(progress * 100)) .. "%"
        sheen.Position = UDim2.new(progress, -12, 0.5, 0)
        shadowObj.Position = UDim2.fromOffset(4 + progress * 2, 4 + progress * 2)
        if progress >= 1 then
            holding = false
            completedThisPress = true
            state = true
            addRipple(button, self.Window.Theme.AccentText)
            render(true)
            safeCall(callback, true)
        end
    end))

    attachTilt(self.Window, button, {
        Intensity = options.TiltIntensity or 0.9,
        MaxRotation = options.MaxRotation or 1.6,
        Travel = options.Travel or 2.6,
        Scale = 1.01,
        Shadow = shadowObj,
    })

    return {
        Instance = button,
        Set = function(_, value, fire) setState(value, fire) end,
        Get = function() return state end,
        SetHoldDuration = function(_, seconds)
            holdDuration = math.max(0.15, tonumber(seconds) or holdDuration)
            render(false)
        end,
    }
end

function Section:CreateSlider(title, minValue, maxValue, defaultValue, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        minValue = options.Min
        maxValue = options.Max
        defaultValue = options.Default
        title = options.Text or options.Title or "Slider"
    else
        options = options or {}
    end

    minValue = tonumber(minValue) or 0
    maxValue = tonumber(maxValue) or 100
    if maxValue <= minValue then maxValue = minValue + 1 end
    local step = tonumber(options.Step) or 1
    local decimals = tonumber(options.Decimals)
    if decimals == nil then decimals = step < 1 and 2 or 0 end
    local value = math.clamp(tonumber(defaultValue) or minValue, minValue, maxValue)
    value = roundToStep(value, minValue, step)
    local dragging = false

    local row, rowStroke = self:_baseRow(options.Description and 86 or 74)
    local titleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -110, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Window.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 23,
        Parent = row,
    })
    self.Window:_themed(titleLabel, "TextColor3", "Text")

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 7),
        Size = UDim2.fromOffset(82, 20),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = self.Window.Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Code,
        TextSize = 11,
        ZIndex = 24,
        Parent = row,
    })
    self.Window:_themed(valueLabel, "TextColor3", "Muted")

    if options.Description then
        local desc = create("TextLabel", {
            Position = UDim2.fromOffset(13, 27),
            Size = UDim2.new(1, -26, 0, 15),
            BackgroundTransparency = 1,
            Text = options.Description,
            TextColor3 = self.Window.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 23,
            Parent = row,
        })
        self.Window:_themed(desc, "TextColor3", "Muted")
    end

    local trackY = options.Description and 58 or 46
    local track = create("TextButton", {
        Name = "Track",
        Position = UDim2.fromOffset(13, trackY),
        Size = UDim2.new(1, -26, 0, 8),
        BackgroundColor3 = self.Window.Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 24,
        Parent = row,
    })
    corner(track, 999)

    local fill = create("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = self.Window.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 25,
        Parent = track,
    })
    corner(fill, 999)

    local thumb = create("Frame", {
        Name = "Thumb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 26,
        Parent = track,
    })
    corner(thumb, 999)
    local thumbStroke = stroke(thumb, self.Window.Theme.Background, 2, 0)
    local thumbScale = create("UIScale", { Scale = 1, Parent = thumb })

    local function maxColor()
        return options.ColorAtMax or options.Color or self.Window.Theme.Danger
    end

    local function alphaFor(v)
        return clamp01((v - minValue) / (maxValue - minValue))
    end

    local function render(animated)
        local theme = self.Window.Theme
        local alpha = alphaFor(value)
        local targetColor = maxColor()
        local tintStrength = tonumber(options.TintStrength) or 0.34
        local rowColor = lerpColor(theme.Surface2, targetColor, alpha * tintStrength)
        local trackColor = lerpColor(theme.Surface, targetColor, alpha * 0.14)
        local fillColor = lerpColor(theme.Accent, targetColor, alpha)
        local borderColor = lerpColor(theme.Border, targetColor, alpha * 0.72)
        local thumbColor = lerpColor(theme.Text, targetColor, alpha * 0.38)
        local propsRow = { BackgroundColor3 = rowColor }
        local propsTrack = { BackgroundColor3 = trackColor }
        local propsFill = { Size = UDim2.fromScale(alpha, 1), BackgroundColor3 = fillColor }
        local propsThumb = { Position = UDim2.fromScale(alpha, 0.5), BackgroundColor3 = thumbColor }
        if animated then
            tween(row, 0.18, propsRow)
            tween(track, 0.18, propsTrack)
            tween(fill, 0.2, propsFill)
            tween(thumb, 0.2, propsThumb, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            for k,v in pairs(propsRow) do row[k]=v end
            for k,v in pairs(propsTrack) do track[k]=v end
            for k,v in pairs(propsFill) do fill[k]=v end
            for k,v in pairs(propsThumb) do thumb[k]=v end
        end
        rowStroke.Color = borderColor
        rowStroke.Transparency = theme.IsDark and 0.42 or 0.55
        thumbStroke.Color = theme.Background
        local prefix = options.Prefix or ""
        local suffix = options.Suffix or ""
        valueLabel.Text = prefix .. valueText(value, decimals) .. suffix
    end

    local function setValue(nextValue, fire, animated)
        nextValue = math.clamp(tonumber(nextValue) or value, minValue, maxValue)
        nextValue = roundToStep(nextValue, minValue, step)
        nextValue = math.clamp(nextValue, minValue, maxValue)
        local changed = nextValue ~= value
        value = nextValue
        render(animated ~= false)
        if changed and fire ~= false then safeCall(callback, value) end
    end

    local function setFromX(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        local alpha = clamp01((x - track.AbsolutePosition.X) / width)
        setValue(minValue + (maxValue - minValue) * alpha, true, false)
    end

    self.Window:_onTheme(function(_, animated)
        render(animated)
    end)
    render(false)

    self.Window._maid:Give(track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
            tween(thumbScale, 0.14, { Scale = 1.22 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end))
    self.Window._maid:Give(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end))
    self.Window._maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                tween(thumbScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        end
    end))
    self.Window._maid:Give(track.MouseEnter:Connect(function()
        if not dragging then tween(thumbScale, 0.18, { Scale = 1.12 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
    end))
    self.Window._maid:Give(track.MouseLeave:Connect(function()
        if not dragging then tween(thumbScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
    end))

    if options.FireOnInit then safeCall(callback, value) end

    return {
        Instance = row,
        Set = function(_, nextValue, fire) setValue(nextValue, fire, true) end,
        Get = function() return value end,
        SetRange = function(_, newMin, newMax)
            minValue = tonumber(newMin) or minValue
            maxValue = tonumber(newMax) or maxValue
            if maxValue <= minValue then maxValue = minValue + 1 end
            setValue(value, false, true)
        end,
    }
end

function Section:CreateInput(title, defaultText, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        defaultText = options.Default or options.Value
        title = options.Text or options.Title or "Input"
    else
        options = options or {}
    end

    local row = self:_baseRow(options.Description and 64 or 56)
    self:_labels(row, title, options.Description, 190)

    local box = create("TextBox", {
        Name = "Input",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(options.Width or 166, 30),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = tostring(defaultText or ""),
        PlaceholderText = options.Placeholder or "type...",
        PlaceholderColor3 = self.Window.Theme.Muted,
        TextColor3 = self.Window.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Font = Enum.Font.Code,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 25,
        Parent = row,
    })
    corner(box, 9)
    pad(box, 9, 9, 0, 0)
    local s = stroke(box, self.Window.Theme.Border, 1.2, 0.45)

    self.Window:_onTheme(function(theme, animated)
        local props2 = {
            BackgroundColor3 = theme.Background,
            TextColor3 = theme.Text,
            PlaceholderColor3 = theme.Muted,
        }
        if animated then tween(box, 0.22, props2) else for k,v in pairs(props2) do box[k]=v end end
        s.Color = theme.Border
    end)

    self.Window._maid:Give(box.Focused:Connect(function()
        tween(box, 0.18, { BackgroundColor3 = shade(self.Window.Theme.Background, self.Window.Theme.IsDark and 0.08 or -0.03) })
        s.Transparency = 0
    end))
    self.Window._maid:Give(box.FocusLost:Connect(function(enterPressed)
        tween(box, 0.18, { BackgroundColor3 = self.Window.Theme.Background })
        s.Transparency = 0.45
        if options.FireOnFocusLost ~= false or enterPressed then
            safeCall(callback, box.Text, enterPressed)
        end
    end))

    return {
        Instance = row,
        Set = function(_, text, fire)
            box.Text = tostring(text or "")
            if fire then safeCall(callback, box.Text, false) end
        end,
        Get = function() return box.Text end,
        Focus = function() box:CaptureFocus() end,
    }
end

function Section:CreateKeybind(title, defaultKey, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        defaultKey = options.Default or options.Key
        title = options.Text or options.Title or "Keybind"
    else
        options = options or {}
    end
    local key = typeof(defaultKey) == "EnumItem" and defaultKey or Enum.KeyCode.Unknown
    local listening = false
    local row = self:_baseRow(options.Description and 60 or 54)
    self:_labels(row, title, options.Description, 120)

    local bind = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(96, 30),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name,
        TextColor3 = self.Window.Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 10,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 25,
        Parent = row,
    })
    corner(bind, 9)
    local s = stroke(bind, self.Window.Theme.Border, 1.2, 0.35)

    self.Window:_onTheme(function(theme, animated)
        local props2 = { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }
        if animated then tween(bind, 0.22, props2) else for k,v in pairs(props2) do bind[k]=v end end
        s.Color = theme.Border
    end)

    self.Window._maid:Give(bind.MouseButton1Click:Connect(function()
        listening = true
        bind.Text = "PRESS KEY"
        tween(bind, 0.18, { BackgroundColor3 = self.Window.Theme.Accent, TextColor3 = self.Window.Theme.AccentText })
    end))

    self.Window._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    bind.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name
                    tween(bind, 0.18, { BackgroundColor3 = self.Window.Theme.Background, TextColor3 = self.Window.Theme.Text })
                    return
                end
                key = input.KeyCode
                listening = false
                bind.Text = key.Name
                tween(bind, 0.18, { BackgroundColor3 = self.Window.Theme.Background, TextColor3 = self.Window.Theme.Text })
                safeCall(options.Changed, key)
            end
            return
        end
        if processed then return end
        if key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
            safeCall(callback, key)
        end
    end))

    return {
        Instance = row,
        Set = function(_, newKey)
            if typeof(newKey) == "EnumItem" then
                key = newKey
                bind.Text = key.Name
            end
        end,
        Get = function() return key end,
    }
end

function Section:CreateDropdown(title, values, defaultValue, callback, options)
    if type(title) == "table" then
        options = title
        callback = options.Callback
        values = options.Values or options.Options or {}
        defaultValue = options.Default
        title = options.Text or options.Title or "Dropdown"
    else
        options = options or {}
    end
    values = values or {}
    local selected = defaultValue or values[1]
    local open = false
    local baseHeight = options.Description and 62 or 56
    local itemHeight = 32
    local maxVisible = math.min(#values, options.MaxVisible or 5)

    local row = self:_baseRow(baseHeight)
    row.ClipsDescendants = true
    self:_labels(row, title, options.Description, 190)

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(options.Width or 168, 30),
        BackgroundColor3 = self.Window.Theme.Background,
        Text = tostring(selected or "Select") .. "   v",
        TextColor3 = self.Window.Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 10,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 27,
        Parent = row,
    })
    corner(button, 9)
    local bs = stroke(button, self.Window.Theme.Border, 1.2, 0.35)

    local menu = create("ScrollingFrame", {
        Name = "DropdownMenu",
        Position = UDim2.fromOffset(12, baseHeight),
        Size = UDim2.new(1, -24, 0, maxVisible * itemHeight + 8),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Window.Theme.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Window.Theme.Border,
        Visible = true,
        ZIndex = 26,
        Parent = row,
    })
    corner(menu, 10)
    local ms = stroke(menu, self.Window.Theme.Border, 1.2, 0.35)
    pad(menu, 5, 5, 4, 4)
    list(menu, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    menu.Visible = false

    local itemButtons = {}

    local function rebuild()
        for _, child in ipairs(itemButtons) do child:Destroy() end
        table.clear(itemButtons)
        for i, value2 in ipairs(values) do
            local item = create("TextButton", {
                Name = "Item_" .. tostring(i),
                Size = UDim2.new(1, 0, 0, itemHeight - 4),
                BackgroundColor3 = self.Window.Theme.Surface2,
                Text = tostring(value2),
                TextColor3 = self.Window.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                LayoutOrder = i,
                ZIndex = 28,
                Parent = menu,
            })
            corner(item, 8)
            pad(item, 10, 10, 0, 0)
            self.Window._maid:Give(item.MouseEnter:Connect(function()
                tween(item, 0.14, { BackgroundColor3 = shade(self.Window.Theme.Surface2, self.Window.Theme.IsDark and 0.08 or -0.06) })
            end))
            self.Window._maid:Give(item.MouseLeave:Connect(function()
                tween(item, 0.14, { BackgroundColor3 = self.Window.Theme.Surface2 })
            end))
            self.Window._maid:Give(item.MouseButton1Click:Connect(function()
                selected = value2
                button.Text = tostring(selected) .. "   v"
                open = false
                menu.Visible = false
                tween(row, 0.22, { Size = UDim2.new(1, 0, 0, baseHeight) })
                safeCall(callback, selected)
            end))
            table.insert(itemButtons, item)
        end
    end
    rebuild()

    self.Window:_onTheme(function(theme, animated)
        local props2 = { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }
        if animated then tween(button, 0.2, props2); tween(menu, 0.2, { BackgroundColor3 = theme.Background }) else for k,v in pairs(props2) do button[k]=v end; menu.BackgroundColor3 = theme.Background end
        bs.Color = theme.Border
        ms.Color = theme.Border
        menu.ScrollBarImageColor3 = theme.Border
        for _, item in ipairs(itemButtons) do
            item.BackgroundColor3 = theme.Surface2
            item.TextColor3 = theme.Text
        end
    end)

    self.Window._maid:Give(button.MouseButton1Click:Connect(function()
        open = not open
        if open then
            menu.Visible = true
            row.Size = UDim2.new(1, 0, 0, baseHeight)
            tween(row, 0.28, { Size = UDim2.new(1, 0, 0, baseHeight + maxVisible * itemHeight + 14) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            button.Text = tostring(selected or "Select") .. "   ^"
        else
            tween(row, 0.22, { Size = UDim2.new(1, 0, 0, baseHeight) }).Completed:Connect(function()
                if not open then menu.Visible = false end
            end)
            button.Text = tostring(selected or "Select") .. "   v"
        end
    end))

    return {
        Instance = row,
        Set = function(_, value2, fire)
            selected = value2
            button.Text = tostring(selected or "Select") .. "   v"
            if fire then safeCall(callback, selected) end
        end,
        Get = function() return selected end,
        SetValues = function(_, newValues)
            values = newValues or {}
            maxVisible = math.min(#values, options.MaxVisible or 5)
            menu.Size = UDim2.new(1, -24, 0, maxVisible * itemHeight + 8)
            rebuild()
        end,
    }
end

function Section:CreateThemeSelector(title)
    title = title or "Theme"
    return self:CreateDropdown({
        Title = title,
        Values = self.Window._themeOrder,
        Default = self.Window.ThemeName,
        Callback = function(name)
            self.Window:SetTheme(name)
        end,
    })
end

function Window:_ensureChangelogOverlay()
    if self.ChangelogOverlay then return end

    local overlay = create("CanvasGroup", {
        Name = "ChangelogOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.42,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 500,
        Parent = self.ScreenGui,
    })

    local panel = create("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -72, 1, -72),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 501,
        Parent = overlay,
    })
    corner(panel, 22)
    local ps = stroke(panel, self.Theme.Border, 2, 0)
    local pscale = create("UIScale", { Scale = 0.94, Parent = panel })

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 502,
        Parent = panel,
    })
    corner(header, 22)
    local cover = create("Frame", {
        Position = UDim2.new(0,0,1,-22),
        Size = UDim2.new(1,0,0,22),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 502,
        Parent = header,
    })

    local title = create("TextLabel", {
        Position = UDim2.fromOffset(22, 12),
        Size = UDim2.new(1, -90, 0, 26),
        BackgroundTransparency = 1,
        Text = "CHANGELOG",
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        ZIndex = 503,
        Parent = header,
    })

    local meta = create("TextLabel", {
        Position = UDim2.fromOffset(22, 40),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = self.Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code,
        TextSize = 10,
        ZIndex = 503,
        Parent = header,
    })

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = self.Theme.Background,
        Text = "x",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 504,
        Parent = header,
    })
    corner(close, 11)
    local cs = stroke(close, self.Theme.Border, 1.5, 0.15)

    local scroll = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 72),
        Size = UDim2.new(1, 0, 1, -72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = self.Theme.Border,
        ZIndex = 502,
        Parent = panel,
    })
    pad(scroll, 24, 24, 24, 30)

    local body = create("TextLabel", {
        Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        RichText = true,
        Font = Enum.Font.Code,
        TextSize = 14,
        LineHeight = 1.35,
        ZIndex = 503,
        Parent = scroll,
    })

    self:_onTheme(function(theme, animated)
        local propsPanel = { BackgroundColor3 = theme.Background }
        local propsHeader = { BackgroundColor3 = theme.Surface }
        if animated then
            tween(panel, 0.24, propsPanel)
            tween(header, 0.24, propsHeader)
            tween(cover, 0.24, propsHeader)
            tween(close, 0.24, { BackgroundColor3 = theme.Background, TextColor3 = theme.Text })
        else
            panel.BackgroundColor3 = theme.Background
            header.BackgroundColor3 = theme.Surface
            cover.BackgroundColor3 = theme.Surface
            close.BackgroundColor3 = theme.Background
            close.TextColor3 = theme.Text
        end
        ps.Color = theme.Border
        cs.Color = theme.Border
        title.TextColor3 = theme.Text
        meta.TextColor3 = theme.Muted
        body.TextColor3 = theme.Text
        scroll.ScrollBarImageColor3 = theme.Border
    end)

    self._maid:Give(close.MouseButton1Click:Connect(function() self:CloseChangelog() end))
    self._maid:Give(close.MouseEnter:Connect(function()
        tween(close, 0.16, { BackgroundColor3 = self.Theme.Danger, TextColor3 = Color3.new(1,1,1) })
    end))
    self._maid:Give(close.MouseLeave:Connect(function()
        tween(close, 0.16, { BackgroundColor3 = self.Theme.Background, TextColor3 = self.Theme.Text })
    end))

    self.ChangelogOverlay = overlay
    self.ChangelogPanel = panel
    self.ChangelogScale = pscale
    self.ChangelogTitle = title
    self.ChangelogMeta = meta
    self.ChangelogBody = body
end

function Window:OpenChangelog(entry)
    self:_ensureChangelogOverlay()
    entry = entry or {}
    self._overlayOpen = true
    self.ChangelogTitle.Text = entry.Title or entry.Version or "CHANGELOG"
    local metaParts = {}
    if entry.Version then table.insert(metaParts, tostring(entry.Version)) end
    if entry.Date then table.insert(metaParts, tostring(entry.Date)) end
    if entry.Tag then table.insert(metaParts, tostring(entry.Tag)) end
    self.ChangelogMeta.Text = table.concat(metaParts, "   /   ")
    self.ChangelogBody.Text = entry.Body or entry.Text or "No changelog body provided."
    self.ChangelogOverlay.Visible = true
    self.ChangelogOverlay.GroupTransparency = 1
    self.ChangelogScale.Scale = 0.92
    self.ChangelogPanel.Rotation = -0.6
    tween(self.ChangelogOverlay, 0.28, { GroupTransparency = 0 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(self.ChangelogPanel, 0.38, { Rotation = 0 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(self.ChangelogScale, 0.46, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    if self.BlurChangelog then
        if self._blur then self._blur:Destroy() end
        self._blur = create("BlurEffect", {
            Name = "DulbanUI_Blur_" .. HttpService:GenerateGUID(false),
            Size = 0,
            Parent = Lighting,
        })
        tween(self._blur, 0.28, { Size = 16 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
end

function Window:CloseChangelog()
    if not self.ChangelogOverlay or not self._overlayOpen then return end
    self._overlayOpen = false
    tween(self.ChangelogOverlay, 0.2, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local closeTween = tween(self.ChangelogScale, 0.22, { Scale = 0.95 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    if self._blur then
        local blur = self._blur
        self._blur = nil
        tween(blur, 0.18, { Size = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
            if blur then blur:Destroy() end
        end)
    end
    closeTween.Completed:Connect(function()
        if self.ChangelogOverlay and not self._overlayOpen then
            self.ChangelogOverlay.Visible = false
        end
    end)
end

function Window:CreateChangelogTab(entries, options)
    options = options or {}
    entries = entries or {}
    local tab = self:CreateTab(options.Name or "Changelog", options.Icon or "LOG")
    local section = tab:CreateSection(options.SectionTitle or "CHANGELOG", options.Subtitle or "Click an entry to open the full-screen notes")

    for i, entry in ipairs(entries) do
        local titleText = entry.Title or entry.Version or ("Update " .. tostring(i))
        local subText = entry.Summary or entry.Date or "Open release notes"
        local row = create("TextButton", {
            Name = "ChangelogEntry_" .. tostring(i),
            Size = UDim2.new(1, 0, 0, 62),
            BackgroundColor3 = self.Theme.Surface2,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = section:_nextOrder(),
            ZIndex = 22,
            Parent = section.Card,
        })
        corner(row, 12)
        local rs = stroke(row, self.Theme.Border, 1, self.Theme.IsDark and 0.5 or 0.65)
        local rscale = create("UIScale", { Scale = 1, Parent = row })

        local titleLabel = create("TextLabel", {
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -110, 0, 20),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            ZIndex = 23,
            Parent = row,
        })
        local summary = create("TextLabel", {
            Position = UDim2.fromOffset(14, 32),
            Size = UDim2.new(1, -110, 0, 16),
            BackgroundTransparency = 1,
            Text = subText,
            TextColor3 = self.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            ZIndex = 23,
            Parent = row,
        })
        local arrow = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(72, 22),
            BackgroundTransparency = 1,
            Text = "OPEN  >>",
            TextColor3 = self.Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Code,
            TextSize = 10,
            ZIndex = 23,
            Parent = row,
        })

        self:_onTheme(function(theme, animated)
            local props2 = { BackgroundColor3 = theme.Surface2 }
            if animated then tween(row, 0.22, props2) else row.BackgroundColor3 = theme.Surface2 end
            rs.Color = theme.Border
            titleLabel.TextColor3 = theme.Text
            summary.TextColor3 = theme.Muted
            arrow.TextColor3 = theme.Accent
        end)

        self._maid:Give(row.MouseEnter:Connect(function()
            tween(rscale, 0.2, { Scale = 1.025 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(row, 0.18, { BackgroundColor3 = shade(self.Theme.Surface2, self.Theme.IsDark and -0.10 or -0.06) })
            tween(arrow, 0.18, { Position = UDim2.new(1, -10, 0.5, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end))
        self._maid:Give(row.MouseLeave:Connect(function()
            tween(rscale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(row, 0.18, { BackgroundColor3 = self.Theme.Surface2 })
            tween(arrow, 0.18, { Position = UDim2.new(1, -16, 0.5, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end))
        self._maid:Give(row.MouseButton1Click:Connect(function()
            addRipple(row, self.Theme.Accent)
            self:OpenChangelog(entry)
        end))
    end

    return tab
end

function Window:_ensureToastHost()
    if self.ToastHost then return end
    self.ToastHost = create("Frame", {
        Name = "ToastHost",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(330, 520),
        BackgroundTransparency = 1,
        ZIndex = 800,
        Parent = self.ScreenGui,
    })
    list(self.ToastHost, Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
end

function Window:Notify(options)
    if type(options) == "string" then options = { Text = options } end
    options = options or {}
    self:_ensureToastHost()
    local duration = tonumber(options.Duration) or 3.5
    local kind = options.Type or "Info"
    local accent = self.Theme.Accent
    if kind == "Success" then accent = self.Theme.Success end
    if kind == "Danger" or kind == "Error" then accent = self.Theme.Danger end
    if kind == "Warning" then accent = self.Theme.Warning end

    local toast = create("CanvasGroup", {
        Size = UDim2.fromOffset(320, options.Text and 82 or 62),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.02,
        GroupTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 801,
        Parent = self.ToastHost,
    })
    corner(toast, 14)
    local ts = stroke(toast, accent, 1.6, 0.05)
    local scale = create("UIScale", { Scale = 0.94, Parent = toast })

    local bar = create("Frame", {
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 802,
        Parent = toast,
    })
    corner(bar, 999)

    local title = create("TextLabel", {
        Position = UDim2.fromOffset(22, 10),
        Size = UDim2.new(1, -34, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Title or kind,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 802,
        Parent = toast,
    })

    if options.Text then
        create("TextLabel", {
            Position = UDim2.fromOffset(22, 32),
            Size = UDim2.new(1, -34, 0, 36),
            BackgroundTransparency = 1,
            Text = options.Text,
            TextColor3 = self.Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            ZIndex = 802,
            Parent = toast,
        })
    end

    toast.Position = UDim2.fromOffset(24, 0)
    tween(toast, 0.3, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(scale, 0.38, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if not toast or not toast.Parent then return end
        tween(toast, 0.24, { GroupTransparency = 1, Position = UDim2.fromOffset(24, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(scale, 0.24, { Scale = 0.96 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In).Completed:Connect(function()
            if toast then toast:Destroy() end
        end)
    end)

    return toast, ts
end

-- Aliases for a shorter API.
Section.Button = Section.CreateButton
Section.Toggle = Section.CreateToggle
Section.Danger = Section.CreateDangerButton
Section.Slider = Section.CreateSlider
Section.Input = Section.CreateInput
Section.Keybind = Section.CreateKeybind
Section.Dropdown = Section.CreateDropdown
Section.Label = Section.CreateLabel
Section.Separator = Section.CreateSeparator
Section.ThemeSelector = Section.CreateThemeSelector
Tab.Section = Tab.CreateSection
Window.Tab = Window.CreateTab
Window.Changelog = Window.CreateChangelogTab

return DulbanUI
