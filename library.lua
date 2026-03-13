local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local COLORS = {
    BG_DARK    = Color3.fromRGB(20, 20, 20),
    BG_MID     = Color3.fromRGB(30, 30, 30),
    BG_LIGHT   = Color3.fromRGB(40, 40, 40),
    ACCENT     = Color3.fromRGB(241, 114, 163),
    ACCENT_DIM = Color3.fromRGB(160, 70, 110),
    TEXT       = Color3.fromRGB(235, 235, 235),
    TEXT_DIM   = Color3.fromRGB(140, 140, 140),
}

local TWEEN_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MEDIUM = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function pad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.Parent = parent
    return p
end

local function stroke(parent, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color        = col or COLORS.ACCENT
    s.Thickness    = thick or 1
    s.Transparency = trans or 0.6
    s.Parent = parent
    return s
end

local function lbl(parent, text, size, col, font)
    local l = Instance.new("TextLabel")
    l.Text               = text or ""
    l.TextSize           = size or 13
    l.TextColor3         = col or COLORS.TEXT
    l.Font               = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.Size               = UDim2.new(1, 0, 0, 18)
    l.Parent = parent
    return l
end

local function dragify(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local title  = config.Title or "Executor"
    local width  = config.Width  or (isMobile and 340 or 500)
    local height = config.Height or (isMobile and 320 or 390)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name            = "ExecLib_" .. title
    screenGui.ResetOnSpawn    = false
    screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset  = true
    screenGui.Parent          = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name             = "MainFrame"
    mainFrame.Size             = UDim2.new(0, width, 0, 0)
    mainFrame.Position         = UDim2.new(0.5, -width/2, 0.5, -height/2)
    mainFrame.BackgroundColor3 = COLORS.BG_DARK
    mainFrame.BorderSizePixel  = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent           = screenGui
    corner(mainFrame, 10)
    stroke(mainFrame, COLORS.ACCENT, 1, 0.45)
    tw(mainFrame, TWEEN_MEDIUM, { Size = UDim2.new(0, width, 0, height) })

    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = COLORS.BG_MID
    titleBar.BorderSizePixel  = 0
    titleBar.Parent           = mainFrame

    local titleBarBottomFix = Instance.new("Frame")
    titleBarBottomFix.Size             = UDim2.new(1, 0, 0, 10)
    titleBarBottomFix.Position         = UDim2.new(0, 0, 1, -10)
    titleBarBottomFix.BackgroundColor3 = COLORS.BG_MID
    titleBarBottomFix.BorderSizePixel  = 0
    titleBarBottomFix.Parent           = titleBar

    local accentLine = Instance.new("Frame")
    accentLine.Size             = UDim2.new(1, 0, 0, 2)
    accentLine.Position         = UDim2.new(0, 0, 1, -2)
    accentLine.BackgroundColor3 = COLORS.ACCENT
    accentLine.BorderSizePixel  = 0
    accentLine.Parent           = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text              = title
    titleLabel.TextSize          = 14
    titleLabel.TextColor3        = COLORS.ACCENT
    titleLabel.Font              = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size              = UDim2.new(1, -80, 1, 0)
    titleLabel.Position          = UDim2.new(0, 12, 0, 0)
    titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
    titleLabel.Parent            = titleBar

    dragify(titleBar)

    local function makeTopBtn(xOff, txt)
        local btn = Instance.new("TextButton")
        btn.Text             = txt
        btn.TextSize         = 16
        btn.TextColor3       = COLORS.TEXT_DIM
        btn.Font             = Enum.Font.GothamBold
        btn.Size             = UDim2.new(0, 26, 0, 26)
        btn.Position         = UDim2.new(1, xOff, 0.5, -13)
        btn.BackgroundColor3 = COLORS.BG_LIGHT
        btn.BorderSizePixel  = 0
        btn.Parent           = titleBar
        corner(btn, 5)
        btn.MouseEnter:Connect(function() tw(btn, TWEEN_FAST, { TextColor3 = COLORS.TEXT }) end)
        btn.MouseLeave:Connect(function() tw(btn, TWEEN_FAST, { TextColor3 = COLORS.TEXT_DIM }) end)
        return btn
    end

    local closeBtn    = makeTopBtn(-8,  "×")
    local minimizeBtn = makeTopBtn(-38, "–")

    closeBtn.MouseButton1Click:Connect(function()
        tw(mainFrame, TWEEN_MEDIUM, {
            Size     = UDim2.new(0, width, 0, 0),
            Position = UDim2.new(0.5, -width/2, 0.5, 0)
        })
        task.delay(0.3, function() screenGui:Destroy() end)
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tw(mainFrame, TWEEN_MEDIUM, {
            Size = minimized and UDim2.new(0, width, 0, 38) or UDim2.new(0, width, 0, height)
        })
    end)

    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(0, 105, 1, -38)
    tabBar.Position         = UDim2.new(0, 0, 0, 38)
    tabBar.BackgroundColor3 = COLORS.BG_MID
    tabBar.BorderSizePixel  = 0
    tabBar.Parent           = mainFrame

    local tabBarRightFix = Instance.new("Frame")
    tabBarRightFix.Size             = UDim2.new(0, 10, 1, 0)
    tabBarRightFix.Position         = UDim2.new(1, -10, 0, 0)
    tabBarRightFix.BackgroundColor3 = COLORS.BG_MID
    tabBarRightFix.BorderSizePixel  = 0
    tabBarRightFix.Parent           = tabBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding   = UDim.new(0, 3)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent    = tabBar
    pad(tabBar, 8, 8, 6, 6)

    local contentArea = Instance.new("Frame")
    contentArea.Name             = "ContentArea"
    contentArea.Size             = UDim2.new(1, -105, 1, -38)
    contentArea.Position         = UDim2.new(0, 105, 0, 38)
    contentArea.BackgroundColor3 = COLORS.BG_DARK
    contentArea.BorderSizePixel  = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent           = mainFrame

    local tabs = {}
    local win  = {}

    function win:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"

        local tabBtn = Instance.new("TextButton")
        tabBtn.Text                   = tabName
        tabBtn.TextSize               = 12
        tabBtn.TextColor3             = COLORS.TEXT_DIM
        tabBtn.Font                   = Enum.Font.Gotham
        tabBtn.Size                   = UDim2.new(1, 0, 0, 30)
        tabBtn.BackgroundColor3       = COLORS.ACCENT
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel        = 0
        tabBtn.LayoutOrder            = #tabs + 1
        tabBtn.Parent                 = tabBar
        corner(tabBtn, 6)

        local tabAccent = Instance.new("Frame")
        tabAccent.Size                   = UDim2.new(0, 3, 0.6, 0)
        tabAccent.Position               = UDim2.new(0, 0, 0.2, 0)
        tabAccent.BackgroundColor3       = COLORS.ACCENT
        tabAccent.BorderSizePixel        = 0
        tabAccent.BackgroundTransparency = 1
        tabAccent.Parent                 = tabBtn
        corner(tabAccent, 2)

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name                    = "Tab_" .. tabName
        scrollFrame.Size                    = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency  = 1
        scrollFrame.BorderSizePixel         = 0
        scrollFrame.ScrollBarThickness      = 3
        scrollFrame.ScrollBarImageColor3    = COLORS.ACCENT
        scrollFrame.ScrollBarImageTransparency = 0.4
        scrollFrame.CanvasSize              = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize     = Enum.AutomaticSize.Y
        scrollFrame.Visible                 = false
        scrollFrame.Parent                  = contentArea
        pad(scrollFrame, 8, 8, 10, 10)

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding   = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent    = scrollFrame

        local tab = { Frame = scrollFrame, Button = tabBtn, Elements = {} }
        table.insert(tabs, tab)

        local function activate()
            for _, t in ipairs(tabs) do
                t.Frame.Visible = false
                tw(t.Button, TWEEN_FAST, { TextColor3 = COLORS.TEXT_DIM, BackgroundTransparency = 1 })
                local a = t.Button:FindFirstChildWhichIsA("Frame")
                if a then tw(a, TWEEN_FAST, { BackgroundTransparency = 1 }) end
            end
            scrollFrame.Visible = true
            tw(tabBtn, TWEEN_FAST, { TextColor3 = COLORS.ACCENT, BackgroundTransparency = 0.85 })
            tw(tabAccent, TWEEN_FAST, { BackgroundTransparency = 0 })
            tabBtn.Font = Enum.Font.GothamSemibold
        end

        tabBtn.MouseButton1Click:Connect(activate)
        if #tabs == 1 then activate() end

        local section = {}

        function section:AddButton(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Button"
            local cb   = cfg.Callback or function() end

            local holder = Instance.new("Frame")
            holder.Size             = UDim2.new(1, 0, 0, 32)
            holder.BackgroundColor3 = COLORS.BG_MID
            holder.BorderSizePixel  = 0
            holder.LayoutOrder      = #tab.Elements + 1
            holder.Parent           = scrollFrame
            corner(holder, 6)

            local dot = Instance.new("Frame")
            dot.Size             = UDim2.new(0, 5, 0, 5)
            dot.Position         = UDim2.new(0, 10, 0.5, -2.5)
            dot.BackgroundColor3 = COLORS.ACCENT
            dot.BorderSizePixel  = 0
            dot.Parent           = holder
            corner(dot, 3)

            local btn = Instance.new("TextButton")
            btn.Text                  = name
            btn.TextSize              = 13
            btn.TextColor3            = COLORS.TEXT
            btn.Font                  = Enum.Font.Gotham
            btn.Size                  = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel       = 0
            btn.TextXAlignment        = Enum.TextXAlignment.Left
            btn.Parent                = holder
            pad(btn, 0, 0, 22, 8)

            btn.MouseEnter:Connect(function()    tw(holder, TWEEN_FAST, { BackgroundColor3 = COLORS.BG_LIGHT }) end)
            btn.MouseLeave:Connect(function()    tw(holder, TWEEN_FAST, { BackgroundColor3 = COLORS.BG_MID   }) end)
            btn.MouseButton1Down:Connect(function() tw(holder, TWEEN_FAST, { BackgroundColor3 = COLORS.ACCENT_DIM }) end)
            btn.MouseButton1Up:Connect(function()
                tw(holder, TWEEN_FAST, { BackgroundColor3 = COLORS.BG_LIGHT })
                local ok, err = pcall(cb)
                if not ok then warn("[ExecLib] Button error: " .. tostring(err)) end
            end)

            table.insert(tab.Elements, holder)
            return holder
        end

        function section:AddToggle(cfg)
            cfg = cfg or {}
            local name    = cfg.Name or "Toggle"
            local default = cfg.Default or false
            local cb      = cfg.Callback or function() end
            local state   = default

            local holder = Instance.new("Frame")
            holder.Size             = UDim2.new(1, 0, 0, 32)
            holder.BackgroundColor3 = COLORS.BG_MID
            holder.BorderSizePixel  = 0
            holder.LayoutOrder      = #tab.Elements + 1
            holder.Parent           = scrollFrame
            corner(holder, 6)

            local nameLbl = lbl(holder, name, 13, COLORS.TEXT)
            nameLbl.Size     = UDim2.new(1, -54, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(0, 34, 0, 18)
            track.Position         = UDim2.new(1, -44, 0.5, -9)
            track.BackgroundColor3 = state and COLORS.ACCENT or COLORS.BG_LIGHT
            track.BorderSizePixel  = 0
            track.Parent           = holder
            corner(track, 9)

            local thumb = Instance.new("Frame")
            thumb.Size             = UDim2.new(0, 14, 0, 14)
            thumb.Position         = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            thumb.BackgroundColor3 = COLORS.TEXT
            thumb.BorderSizePixel  = 0
            thumb.Parent           = track
            corner(thumb, 7)

            local clickBtn = Instance.new("TextButton")
            clickBtn.Text                  = ""
            clickBtn.Size                  = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.BorderSizePixel       = 0
            clickBtn.Parent                = holder

            clickBtn.MouseButton1Click:Connect(function()
                state = not state
                tw(track, TWEEN_FAST, { BackgroundColor3 = state and COLORS.ACCENT or COLORS.BG_LIGHT })
                tw(thumb, TWEEN_FAST, { Position = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) })
                local ok, err = pcall(cb, state)
                if not ok then warn("[ExecLib] Toggle error: " .. tostring(err)) end
            end)

            table.insert(tab.Elements, holder)
            return {
                GetValue = function() return state end,
                SetValue = function(v)
                    state = v
                    tw(track, TWEEN_FAST, { BackgroundColor3 = v and COLORS.ACCENT or COLORS.BG_LIGHT })
                    tw(thumb, TWEEN_FAST, { Position = v and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) })
                end
            }
        end

        function section:AddSlider(cfg)
            cfg = cfg or {}
            local name    = cfg.Name or "Slider"
            local min     = cfg.Min or 0
            local max     = cfg.Max or 100
            local default = math.clamp(cfg.Default or min, min, max)
            local cb      = cfg.Callback or function() end
            local value   = default

            local holder = Instance.new("Frame")
            holder.Size             = UDim2.new(1, 0, 0, 46)
            holder.BackgroundColor3 = COLORS.BG_MID
            holder.BorderSizePixel  = 0
            holder.LayoutOrder      = #tab.Elements + 1
            holder.Parent           = scrollFrame
            corner(holder, 6)

            local topRow = Instance.new("Frame")
            topRow.Size                   = UDim2.new(1, -16, 0, 20)
            topRow.Position               = UDim2.new(0, 8, 0, 6)
            topRow.BackgroundTransparency = 1
            topRow.BorderSizePixel        = 0
            topRow.Parent                 = holder

            local nameLbl = lbl(topRow, name, 13, COLORS.TEXT)
            nameLbl.Size = UDim2.new(1, -42, 1, 0)

            local valLbl = Instance.new("TextLabel")
            valLbl.Text                  = tostring(value)
            valLbl.TextSize              = 12
            valLbl.TextColor3            = COLORS.ACCENT
            valLbl.Font                  = Enum.Font.GothamSemibold
            valLbl.BackgroundTransparency = 1
            valLbl.Size                  = UDim2.new(0, 40, 1, 0)
            valLbl.Position              = UDim2.new(1, -40, 0, 0)
            valLbl.TextXAlignment        = Enum.TextXAlignment.Right
            valLbl.Parent                = topRow

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -16, 0, 4)
            track.Position         = UDim2.new(0, 8, 1, -12)
            track.BackgroundColor3 = COLORS.BG_LIGHT
            track.BorderSizePixel  = 0
            track.Parent           = holder
            corner(track, 2)

            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = COLORS.ACCENT
            fill.BorderSizePixel  = 0
            fill.Parent           = track
            corner(fill, 2)

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.AnchorPoint      = Vector2.new(0.5, 0.5)
            knob.Position         = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = COLORS.TEXT
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 2
            knob.Parent           = track
            corner(knob, 6)

            local dragging = false

            local function updateSlider(absPos)
                local tAbsPos  = track.AbsolutePosition
                local tAbsSize = track.AbsoluteSize
                local pct      = math.clamp((absPos.X - tAbsPos.X) / tAbsSize.X, 0, 1)
                local newVal   = math.floor(min + pct * (max - min) + 0.5)
                value          = newVal
                valLbl.Text    = tostring(value)
                tw(fill,  TWEEN_FAST, { Size     = UDim2.new(pct, 0, 1, 0) })
                tw(knob,  TWEEN_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
                local ok, err = pcall(cb, value)
                if not ok then warn("[ExecLib] Slider error: " .. tostring(err)) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            table.insert(tab.Elements, holder)
            return {
                GetValue = function() return value end,
                SetValue = function(v)
                    value = math.clamp(v, min, max)
                    local pct = (value - min) / (max - min)
                    valLbl.Text = tostring(value)
                    tw(fill, TWEEN_FAST, { Size     = UDim2.new(pct, 0, 1, 0) })
                    tw(knob, TWEEN_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
                end
            }
        end

        function section:AddTextbox(cfg)
            cfg = cfg or {}
            local name        = cfg.Name or "Input"
            local placeholder = cfg.Placeholder or "Enter text..."
            local cb          = cfg.Callback or function() end

            local holder = Instance.new("Frame")
            holder.Size             = UDim2.new(1, 0, 0, 50)
            holder.BackgroundColor3 = COLORS.BG_MID
            holder.BorderSizePixel  = 0
            holder.LayoutOrder      = #tab.Elements + 1
            holder.Parent           = scrollFrame
            corner(holder, 6)

            local nameLbl = lbl(holder, name, 12, COLORS.TEXT_DIM)
            nameLbl.Size     = UDim2.new(1, -16, 0, 16)
            nameLbl.Position = UDim2.new(0, 10, 0, 5)

            local inputBox = Instance.new("TextBox")
            inputBox.PlaceholderText       = placeholder
            inputBox.PlaceholderColor3     = COLORS.TEXT_DIM
            inputBox.Text                  = ""
            inputBox.TextSize              = 13
            inputBox.TextColor3            = COLORS.TEXT
            inputBox.Font                  = Enum.Font.Gotham
            inputBox.Size                  = UDim2.new(1, -16, 0, 22)
            inputBox.Position              = UDim2.new(0, 8, 0, 22)
            inputBox.BackgroundColor3      = COLORS.BG_DARK
            inputBox.BorderSizePixel       = 0
            inputBox.TextXAlignment        = Enum.TextXAlignment.Left
            inputBox.ClearTextOnFocus      = false
            inputBox.Parent                = holder
            corner(inputBox, 4)
            pad(inputBox, 0, 0, 6, 6)

            local inputStroke = stroke(inputBox, COLORS.BG_LIGHT, 1, 0)
            inputBox.Focused:Connect(function()
                tw(inputStroke, TWEEN_FAST, { Color = COLORS.ACCENT, Transparency = 0 })
            end)
            inputBox.FocusLost:Connect(function(enter)
                tw(inputStroke, TWEEN_FAST, { Color = COLORS.BG_LIGHT, Transparency = 0 })
                if enter then
                    local ok, err = pcall(cb, inputBox.Text)
                    if not ok then warn("[ExecLib] Textbox error: " .. tostring(err)) end
                end
            end)

            table.insert(tab.Elements, holder)
            return {
                GetValue = function() return inputBox.Text end,
                SetValue = function(v) inputBox.Text = tostring(v) end
            }
        end

        function section:AddDropdown(cfg)
            cfg = cfg or {}
            local name     = cfg.Name or "Dropdown"
            local options  = cfg.Options or {}
            local default  = cfg.Default or options[1] or "Select..."
            local cb       = cfg.Callback or function() end
            local selected = default
            local open     = false

            local holder = Instance.new("Frame")
            holder.Size             = UDim2.new(1, 0, 0, 32)
            holder.BackgroundColor3 = COLORS.BG_MID
            holder.BorderSizePixel  = 0
            holder.LayoutOrder      = #tab.Elements + 1
            holder.ClipsDescendants = false
            holder.ZIndex           = 5
            holder.Parent           = scrollFrame
            corner(holder, 6)

            local nameLbl2 = lbl(holder, name, 12, COLORS.TEXT_DIM)
            nameLbl2.Size     = UDim2.new(0, 80, 1, 0)
            nameLbl2.Position = UDim2.new(0, 10, 0, 0)
            nameLbl2.ZIndex   = 6

            local selLbl = lbl(holder, selected, 13, COLORS.TEXT)
            selLbl.Size     = UDim2.new(1, -110, 1, 0)
            selLbl.Position = UDim2.new(0, 95, 0, 0)
            selLbl.ZIndex   = 6

            local arrow = lbl(holder, "▾", 13, COLORS.ACCENT)
            arrow.Size            = UDim2.new(0, 20, 1, 0)
            arrow.Position        = UDim2.new(1, -24, 0, 0)
            arrow.TextXAlignment  = Enum.TextXAlignment.Center
            arrow.ZIndex          = 6

            local dropList = Instance.new("Frame")
            dropList.Size             = UDim2.new(1, 0, 0, #options * 26 + 6)
            dropList.Position         = UDim2.new(0, 0, 1, 2)
            dropList.BackgroundColor3 = COLORS.BG_MID
            dropList.BorderSizePixel  = 0
            dropList.ClipsDescendants = true
            dropList.ZIndex           = 10
            dropList.Visible          = false
            dropList.Parent           = holder
            corner(dropList, 6)
            stroke(dropList, COLORS.ACCENT, 1, 0.6)

            local dropLayout = Instance.new("UIListLayout")
            dropLayout.Parent = dropList
            pad(dropList, 3, 3, 4, 4)

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Text                   = opt
                optBtn.TextSize               = 13
                optBtn.TextColor3             = COLORS.TEXT
                optBtn.Font                   = Enum.Font.Gotham
                optBtn.Size                   = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3       = COLORS.BG_MID
                optBtn.BackgroundTransparency = 1
                optBtn.BorderSizePixel        = 0
                optBtn.TextXAlignment         = Enum.TextXAlignment.Left
                optBtn.ZIndex                 = 11
                optBtn.Parent                 = dropList
                corner(optBtn, 4)
                pad(optBtn, 0, 0, 8, 4)

                optBtn.MouseEnter:Connect(function()
                    tw(optBtn, TWEEN_FAST, { BackgroundTransparency = 0.7, BackgroundColor3 = COLORS.ACCENT_DIM })
                end)
                optBtn.MouseLeave:Connect(function()
                    tw(optBtn, TWEEN_FAST, { BackgroundTransparency = 1 })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected     = opt
                    selLbl.Text  = opt
                    open         = false
                    dropList.Visible = false
                    tw(holder, TWEEN_FAST, { Size = UDim2.new(1, 0, 0, 32) })
                    local ok, err = pcall(cb, selected)
                    if not ok then warn("[ExecLib] Dropdown error: " .. tostring(err)) end
                end)
            end

            local clickBtn = Instance.new("TextButton")
            clickBtn.Text                  = ""
            clickBtn.Size                  = UDim2.new(1, 0, 0, 32)
            clickBtn.BackgroundTransparency = 1
            clickBtn.BorderSizePixel       = 0
            clickBtn.ZIndex                = 7
            clickBtn.Parent                = holder

            clickBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    dropList.Visible = true
                    tw(holder, TWEEN_MEDIUM, { Size = UDim2.new(1, 0, 0, 32 + #options * 26 + 8) })
                else
                    tw(holder, TWEEN_MEDIUM, { Size = UDim2.new(1, 0, 0, 32) })
                    task.delay(0.28, function() if not open then dropList.Visible = false end end)
                end
            end)

            table.insert(tab.Elements, holder)
            return {
                GetValue = function() return selected end,
                SetValue = function(v) selected = v; selLbl.Text = v end
            }
        end

        function section:AddLabel(text)
            local holder = Instance.new("Frame")
            holder.Size                   = UDim2.new(1, 0, 0, 22)
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel        = 0
            holder.LayoutOrder            = #tab.Elements + 1
            holder.Parent                 = scrollFrame

            local l2 = lbl(holder, text, 12, COLORS.TEXT_DIM)
            l2.Size = UDim2.new(1, 0, 1, 0)

            table.insert(tab.Elements, holder)
            return { SetText = function(t) l2.Text = t end }
        end

        function section:AddSeparator()
            local sep = Instance.new("Frame")
            sep.Size                   = UDim2.new(1, 0, 0, 1)
            sep.BackgroundColor3       = COLORS.ACCENT
            sep.BackgroundTransparency = 0.7
            sep.BorderSizePixel        = 0
            sep.LayoutOrder            = #tab.Elements + 1
            sep.Parent                 = scrollFrame
            table.insert(tab.Elements, sep)
        end

        return section
    end

    if isMobile then
        local toggleSize = 52

        local mobileBtn = Instance.new("TextButton")
        mobileBtn.Text             = "✦"
        mobileBtn.TextSize         = 22
        mobileBtn.TextColor3       = COLORS.TEXT
        mobileBtn.Font             = Enum.Font.GothamBold
        mobileBtn.Size             = UDim2.new(0, toggleSize, 0, toggleSize)
        mobileBtn.Position         = UDim2.new(0, 20, 1, -(toggleSize + 30))
        mobileBtn.BackgroundColor3 = COLORS.BG_MID
        mobileBtn.BorderSizePixel  = 0
        mobileBtn.Parent           = screenGui
        corner(mobileBtn, toggleSize / 2)
        stroke(mobileBtn, COLORS.ACCENT, 2, 0.2)

        local glow = Instance.new("Frame")
        glow.Size             = UDim2.new(0.55, 0, 0.55, 0)
        glow.AnchorPoint      = Vector2.new(0.5, 0.5)
        glow.Position         = UDim2.new(0.5, 0, 0.5, 0)
        glow.BackgroundColor3 = COLORS.ACCENT
        glow.BackgroundTransparency = 0.55
        glow.BorderSizePixel  = 0
        glow.Parent           = mobileBtn
        corner(glow, 16)

        local uiVisible = true
        mobileBtn.MouseButton1Click:Connect(function()
            uiVisible = not uiVisible
            mainFrame.Visible = uiVisible
            tw(glow, TWEEN_FAST, {
                BackgroundColor3 = uiVisible and COLORS.ACCENT or COLORS.BG_LIGHT,
                BackgroundTransparency = uiVisible and 0.55 or 0.7
            })
        end)

        dragify(mobileBtn)
    end

    return win
end

return Library
