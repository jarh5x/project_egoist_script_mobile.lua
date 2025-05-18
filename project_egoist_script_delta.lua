--[[
    Project Egoísta Script - Versão Delta Mobile
    Funcionalidades:
    - Auto Goal
    - Auto Steal
    - Auto Dribble
    - Interface Moderna e Minimalista com Animações
    
    Criado por Manus
]]

-- Configurações
local Settings = {
    AutoGoal = false,
    AutoSteal = false,
    AutoDribble = false,
    Range = 20, -- Alcance para detectar a bola e jogadores
}

-- Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Cores e Design
local Colors = {
    Background = Color3.fromRGB(30, 30, 40),
    BackgroundSecondary = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(90, 120, 240),
    AccentHover = Color3.fromRGB(110, 140, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(70, 200, 120),
    Error = Color3.fromRGB(220, 75, 75),
    Transparent = Color3.fromRGB(255, 255, 255)
}

local Design = {
    CornerRadius = UDim.new(0, 8),
    ButtonHeight = 45,
    Padding = 12,
    FontRegular = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    TextSize = 16,
    IconSize = 24,
    ShadowTransparency = 0.5,
    AnimationTime = 0.3,
    AnimationTimeShort = 0.15
}

-- Funções de utilidade
local function GetBall()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Ball" or v.Name == "SoccerBall" then
            return v
        end
    end
    return nil
end

local function GetNearestPlayer()
    local nearestPlayer = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance and distance <= Settings.Range then
                minDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    return nearestPlayer
end

local function IsNearBall()
    local ball = GetBall()
    if ball and Character:FindFirstChild("HumanoidRootPart") then
        return (ball.Position - Character.HumanoidRootPart.Position).Magnitude <= Settings.Range
    end
    return false
end

local function HasBall()
    -- Verificar se o jogador está com a bola (implementação pode variar dependendo do jogo)
    local ball = GetBall()
    if ball and Character:FindFirstChild("HumanoidRootPart") then
        return (ball.Position - Character.HumanoidRootPart.Position).Magnitude <= 5
    end
    return false
end

-- Funções para simular toques em botões móveis (otimizado para Delta)
local function SimulateMobileButtonPress(buttonName)
    -- Encontrar o botão móvel na interface do jogo
    local mobileButton = nil
    
    -- Procurar na interface do jogador
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if (gui.Name == buttonName or gui.Name:find(buttonName)) and 
           (gui:IsA("ImageButton") or gui:IsA("TextButton")) then
            mobileButton = gui
            break
        end
    end
    
    -- Se encontrou o botão, simular um toque
    if mobileButton then
        -- Método específico para Delta
        if firesignal then
            firesignal(mobileButton.MouseButton1Down)
            wait(0.1)
            firesignal(mobileButton.MouseButton1Up)
            return true
        else
            -- Fallback para outros métodos
            mobileButton.MouseButton1Down:Fire()
            wait(0.1)
            mobileButton.MouseButton1Up:Fire()
            return true
        end
    end
    
    -- Fallback para VirtualInputManager se não encontrar o botão
    return false
end

-- Funções principais adaptadas para mobile
local function AutoGoal()
    local ball = GetBall()
    if ball and Character:FindFirstChild("HumanoidRootPart") then
        -- Encontrar o gol mais próximo
        local goalPosition = Vector3.new(0, 0, 0) -- Posição do gol (ajustar conforme o mapa)
        
        -- Mover em direção à bola
        if not HasBall() and IsNearBall() then
            -- Tentar usar botão móvel para roubar
            if not SimulateMobileButtonPress("StealButton") and not SimulateMobileButtonPress("Steal") then
                -- Método específico para Delta
                if keypress then
                    keypress(0x45) -- Tecla E
                    wait(0.1)
                    keyrelease(0x45)
                else
                    -- Fallback para VirtualInputManager
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end
        end
        
        -- Se tiver a bola, chutar para o gol
        if HasBall() then
            -- Olhar para o gol
            Character.HumanoidRootPart.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, goalPosition)
            
            -- Tentar usar botão móvel para chutar
            if not SimulateMobileButtonPress("ShootButton") and not SimulateMobileButtonPress("Shoot") then
                -- Método específico para Delta
                if mouse1press then
                    mouse1press()
                    wait(0.1)
                    mouse1release()
                else
                    -- Fallback para VirtualInputManager
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    wait(0.1)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end
        end
    end
end

local function AutoSteal()
    if not HasBall() and IsNearBall() then
        -- Tentar usar botão móvel para roubar
        if not SimulateMobileButtonPress("StealButton") and not SimulateMobileButtonPress("Steal") then
            -- Método específico para Delta
            if keypress then
                keypress(0x45) -- Tecla E
                wait(0.1)
                keyrelease(0x45)
            else
                -- Fallback para VirtualInputManager
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
    end
end

local function AutoDribble()
    if HasBall() then
        -- Tentar usar botão móvel para driblar
        if not SimulateMobileButtonPress("DribbleButton") and not SimulateMobileButtonPress("Dribble") then
            -- Método específico para Delta
            if keypress then
                keypress(0x51) -- Tecla Q
                wait(0.1)
                keyrelease(0x51)
            else
                -- Fallback para VirtualInputManager
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end
        end
        
        -- Usar Super Dash ocasionalmente
        if math.random(1, 10) == 1 then
            if not SimulateMobileButtonPress("DashButton") and not SimulateMobileButtonPress("Dash") then
                -- Método específico para Delta
                if keypress then
                    keypress(0x52) -- Tecla R
                    wait(0.1)
                    keyrelease(0x52)
                else
                    -- Fallback para VirtualInputManager
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end
            end
        end
    end
end

-- Funções de UI
local function CreateShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014257812"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or Design.ShadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, -6)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function CreateRippleEffect(parent)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Colors.Transparent
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = parent.ZIndex + 1
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ripple
    
    ripple.Parent = parent
    
    local targetSize = UDim2.new(1.5, 0, 1.5, 0)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(ripple, tweenInfo, {Size = targetSize, BackgroundTransparency = 1})
    tween:Play()
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Criar GUI moderna e minimalista
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectEgoistScriptDelta"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Definir o pai da GUI (otimizado para Delta)
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Criar o frame principal com design moderno
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

-- Adicionar cantos arredondados
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = Design.CornerRadius
UICorner.Parent = MainFrame

-- Adicionar sombra
CreateShadow(MainFrame)

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Colors.Accent
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame

-- Arredondar cantos da barra de título
local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = Design.CornerRadius
UICornerTitle.Parent = TitleBar

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Colors.Text
Title.TextSize = Design.TextSize + 4
Title.Font = Design.FontBold
Title.Text = "Project Egoísta"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = TitleBar

-- Botão de fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Colors.Error
CloseButton.BackgroundTransparency = 0.2
CloseButton.TextColor3 = Colors.Text
CloseButton.TextSize = Design.TextSize + 2
CloseButton.Font = Design.FontBold
CloseButton.Text = "X"
CloseButton.ZIndex = 12
CloseButton.Parent = TitleBar

-- Arredondar cantos do botão de fechar
local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 8)
UICornerClose.Parent = CloseButton

-- Conteúdo
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = MainFrame

-- Função para criar botões de toggle modernos
local function CreateToggle(name, icon, position, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Size = UDim2.new(1, -40, 0, Design.ButtonHeight)
    ToggleFrame.Position = UDim2.new(0, 20, 0, position)
    ToggleFrame.BackgroundColor3 = Colors.BackgroundSecondary
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 12
    ToggleFrame.Parent = Content
    
    -- Arredondar cantos
    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = Design.CornerRadius
    UICornerToggle.Parent = ToggleFrame
    
    -- Ícone (se fornecido)
    if icon then
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, Design.IconSize, 0, Design.IconSize)
        Icon.Position = UDim2.new(0, Design.Padding, 0.5, -Design.IconSize/2)
        Icon.BackgroundTransparency = 1
        Icon.Image = icon
        Icon.ImageColor3 = Colors.Text
        Icon.ZIndex = 13
        Icon.Parent = ToggleFrame
    end
    
    -- Label
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, icon and (Design.IconSize + Design.Padding * 2) or Design.Padding, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.TextColor3 = Colors.Text
    ToggleLabel.TextSize = Design.TextSize
    ToggleLabel.Font = Design.FontRegular
    ToggleLabel.Text = name
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.ZIndex = 13
    ToggleLabel.Parent = ToggleFrame
    
    -- Botão de toggle
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 24)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleButton.BackgroundColor3 = Colors.Error
    ToggleButton.BorderSizePixel = 0
    ToggleButton.ZIndex = 13
    ToggleButton.Parent = ToggleFrame
    
    -- Arredondar cantos do botão
    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(1, 0)
    UICornerButton.Parent = ToggleButton
    
    -- Círculo do toggle
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
    ToggleCircle.BackgroundColor3 = Colors.Text
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.ZIndex = 14
    ToggleCircle.Parent = ToggleButton
    
    -- Arredondar cantos do círculo
    local UICornerCircle = Instance.new("UICorner")
    UICornerCircle.CornerRadius = UDim.new(1, 0)
    UICornerCircle.Parent = ToggleCircle
    
    -- Status
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(0, 40, 0, 20)
    StatusLabel.Position = UDim2.new(1, -110, 0.5, -10)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Colors.Error
    StatusLabel.TextSize = Design.TextSize - 2
    StatusLabel.Font = Design.FontBold
    StatusLabel.Text = "OFF"
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    StatusLabel.ZIndex = 13
    StatusLabel.Parent = ToggleFrame
    
    -- Adicionar sombra
    CreateShadow(ToggleFrame, 0.7)
    
    -- Variáveis de estado
    local isEnabled = false
    local isAnimating = false
    
    -- Função para atualizar o visual
    local function updateVisual()
        local targetColor = isEnabled and Colors.Success or Colors.Error
        local targetPosition = isEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetText = isEnabled and "ON" or "OFF"
        
        -- Animar a transição
        isAnimating = true
        
        -- Animar a cor
        local colorTween = TweenService:Create(
            ToggleButton, 
            TweenInfo.new(Design.AnimationTimeShort, Enum.EasingStyle.Quad), 
            {BackgroundColor3 = targetColor}
        )
        colorTween:Play()
        
        -- Animar a posição do círculo
        local positionTween = TweenService:Create(
            ToggleCircle, 
            TweenInfo.new(Design.AnimationTimeShort, Enum.EasingStyle.Back), 
            {Position = targetPosition}
        )
        positionTween:Play()
        
        -- Atualizar o texto de status
        StatusLabel.Text = targetText
        StatusLabel.TextColor3 = targetColor
        
        -- Esperar a animação terminar
        positionTween.Completed:Connect(function()
            isAnimating = false
        end)
    end
    
    -- Tornar o frame clicável
    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not isAnimating then
                isEnabled = not isEnabled
                updateVisual()
                CreateRippleEffect(ToggleFrame)
                callback(isEnabled)
            end
        end
    end)
    
    -- Retornar o frame e a função de atualização
    return ToggleFrame, function(value)
        if value ~= isEnabled and not isAnimating then
            isEnabled = value
            updateVisual()
        end
    end
end

-- Criar botão flutuante para mostrar/esconder a interface
local FloatingButton = Instance.new("ImageButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0.1, 0, 0.8, 0)
FloatingButton.BackgroundColor3 = Colors.Accent
FloatingButton.BorderSizePixel = 0
FloatingButton.Image = "rbxassetid://3926307971" -- Ícone de menu
FloatingButton.ImageRectOffset = Vector2.new(404, 844)
FloatingButton.ImageRectSize = Vector2.new(36, 36)
FloatingButton.ImageColor3 = Colors.Text
FloatingButton.ZIndex = 20
FloatingButton.Parent = ScreenGui

-- Arredondar cantos do botão flutuante
local UICornerFloating = Instance.new("UICorner")
UICornerFloating.CornerRadius = UDim.new(1, 0)
UICornerFloating.Parent = FloatingButton

-- Adicionar sombra ao botão flutuante
CreateShadow(FloatingButton, 0.4)

-- Animação de entrada
MainFrame.Position = UDim2.new(0.5, -140, 1.2, 0)
MainFrame.Visible = true

local entranceTween = TweenService:Create(
    MainFrame,
    TweenInfo.new(Design.AnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -140, 0.5, -175)}
)
entranceTween:Play()

-- Criar toggles com ícones
local AutoGoalToggle, SetAutoGoal = CreateToggle("Auto Goal", "rbxassetid://3926305904", 20, function(enabled)
    Settings.AutoGoal = enabled
end)

local AutoStealToggle, SetAutoSteal = CreateToggle("Auto Steal", "rbxassetid://3926307971", 20 + Design.ButtonHeight + Design.Padding, function(enabled)
    Settings.AutoSteal = enabled
end)

local AutoDribbleToggle, SetAutoDribble = CreateToggle("Auto Dribble", "rbxassetid://3926305904", 20 + (Design.ButtonHeight + Design.Padding) * 2, function(enabled)
    Settings.AutoDribble = enabled
end)

-- Botão de status
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, -40, 0, Design.ButtonHeight)
StatusFrame.Position = UDim2.new(0, 20, 0, 20 + (Design.ButtonHeight + Design.Padding) * 3)
StatusFrame.BackgroundColor3 = Colors.BackgroundSecondary
StatusFrame.BorderSizePixel = 0
StatusFrame.ZIndex = 12
StatusFrame.Parent = Content

-- Arredondar cantos
local UICornerStatus = Instance.new("UICorner")
UICornerStatus.CornerRadius = Design.CornerRadius
UICornerStatus.Parent = StatusFrame

-- Texto de status
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Colors.Text
StatusText.TextSize = Design.TextSize - 1
StatusText.Font = Design.FontRegular
StatusText.Text = "Status: Aguardando ação..."
StatusText.TextXAlignment = Enum.TextXAlignment.Center
StatusText.TextYAlignment = Enum.TextYAlignment.Center
StatusText.ZIndex = 13
StatusText.Parent = StatusFrame

-- Adicionar sombra
CreateShadow(StatusFrame, 0.7)

-- Botão de créditos
local CreditsButton = Instance.new("TextButton")
CreditsButton.Name = "CreditsButton"
CreditsButton.Size = UDim2.new(1, -40, 0, Design.ButtonHeight)
CreditsButton.Position = UDim2.new(0, 20, 1, -Design.ButtonHeight - 20)
CreditsButton.BackgroundColor3 = Colors.Accent
CreditsButton.BorderSizePixel = 0
CreditsButton.TextColor3 = Colors.Text
CreditsButton.TextSize = Design.TextSize
CreditsButton.Font = Design.FontBold
CreditsButton.Text = "Criado por Manus"
CreditsButton.ZIndex = 12
CreditsButton.Parent = Content

-- Arredondar cantos do botão de créditos
local UICornerCredits = Instance.new("UICorner")
UICornerCredits.CornerRadius = Design.CornerRadius
UICornerCredits.Parent = CreditsButton

-- Adicionar sombra
CreateShadow(CreditsButton, 0.6)

-- Eventos
local isGuiVisible = true

CloseButton.MouseButton1Click:Connect(function()
    -- Animação de saída
    local exitTween = TweenService:Create(
        MainFrame,
        TweenInfo.new(Design.AnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, -140, 1.2, 0)}
    )
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        isGuiVisible = false
    end)
    
    -- Efeito de clique
    CreateRippleEffect(CloseButton)
end)

FloatingButton.MouseButton1Click:Connect(function()
    if isGuiVisible then
        -- Animação de saída
        local exitTween = TweenService:Create(
            MainFrame,
            TweenInfo.new(Design.AnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -140, 1.2, 0)}
        )
        exitTween:Play()
        
        exitTween.Completed:Connect(function()
            isGuiVisible = false
        end)
    else
        -- Animação de entrada
        MainFrame.Position = UDim2.new(0.5, -140, 1.2, 0)
        
        local entranceTween = TweenService:Create(
            MainFrame,
            TweenInfo.new(Design.AnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -140, 0.5, -175)}
        )
        entranceTween:Play()
        
        isGuiVisible = true
    end
    
    -- Efeito de clique
    CreateRippleEffect(FloatingButton)
end)

CreditsButton.MouseButton1Click:Connect(function()
    -- Efeito de clique
    CreateRippleEffect(CreditsButton)
end)

-- Animação do botão flutuante
spawn(function()
    while wait(1) do
        local bounceTween = TweenService:Create(
            FloatingButton,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
            {Position = UDim2.new(0.1, 0, 0.8, -10)}
        )
        bounceTween:Play()
    end
end)

-- Função para atualizar o status
local function UpdateStatus(text, isError)
    StatusText.Text = text
    StatusText.TextColor3 = isError and Colors.Error or Colors.Text
    
    -- Animação de atualização
    StatusFrame.BackgroundColor3 = isError and Colors.Error or Colors.BackgroundSecondary
    StatusText.TextColor3 = isError and Colors.Text or Colors.Text
    
    local colorTween = TweenService:Create(
        StatusFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        {BackgroundColor3 = Colors.BackgroundSecondary}
    )
    
    local textTween = TweenService:Create(
        StatusText,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        {TextColor3 = Colors.Text}
    )
    
    if isError then
        delay(0.5, function()
            colorTween:Play()
            textTween:Play()
        end)
    end
end

-- Loop principal com tratamento de erros
local success, errorMsg = pcall(function()
    RunService.Heartbeat:Connect(function()
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            Character = LocalPlayer.Character
            if Character then
                Humanoid = Character:WaitForChild("Humanoid")
                UpdateStatus("Personagem recarregado", false)
            end
            return
        end
        
        if Settings.AutoGoal then
            local success, errorMsg = pcall(function()
                AutoGoal()
            end)
            
            if not success then
                UpdateStatus("Erro em Auto Goal: " .. errorMsg, true)
                SetAutoGoal(false)
            else
                UpdateStatus("Auto Goal ativo", false)
            end
        end
        
        if Settings.AutoSteal then
            local success, errorMsg = pcall(function()
                AutoSteal()
            end)
            
            if not success then
                UpdateStatus("Erro em Auto Steal: " .. errorMsg, true)
                SetAutoSteal(false)
            else
                UpdateStatus("Auto Steal ativo", false)
            end
        end
        
        if Settings.AutoDribble then
            local success, errorMsg = pcall(function()
                AutoDribble()
            end)
            
            if not success then
                UpdateStatus("Erro em Auto Dribble: " .. errorMsg, true)
                SetAutoDribble(false)
            else
                UpdateStatus("Auto Dribble ativo", false)
            end
        end
        
        if not (Settings.AutoGoal or Settings.AutoSteal or Settings.AutoDribble) then
            UpdateStatus("Aguardando ação...", false)
        end
    end)
end)

if not success then
    UpdateStatus("Erro ao iniciar: " .. errorMsg, true)
end

-- Mensagem de carregamento com animação
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(0, 300, 0, 100)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
LoadingFrame.BackgroundColor3 = Colors.Background
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

-- Arredondar cantos
local UICornerLoading = Instance.new("UICorner")
UICornerLoading.CornerRadius = Design.CornerRadius
UICornerLoading.Parent = LoadingFrame

-- Adicionar sombra
CreateShadow(LoadingFrame)

-- Texto de carregamento
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, -40, 0, 40)
LoadingText.Position = UDim2.new(0, 20, 0, 20)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Colors.Text
LoadingText.TextSize = Design.TextSize + 2
LoadingText.Font = Design.FontBold
LoadingText.Text = "Script carregado com sucesso!"
LoadingText.ZIndex = 101
LoadingText.Parent = LoadingFrame

-- Subtexto
local SubText = Instance.new("TextLabel")
SubText.Name = "SubText"
SubText.Size = UDim2.new(1, -40, 0, 30)
SubText.Position = UDim2.new(0, 20, 0, 60)
SubText.BackgroundTransparency = 1
SubText.TextColor3 = Colors.TextDark
SubText.TextSize = Design.TextSize - 2
SubText.Font = Design.FontRegular
SubText.Text = "Use o botão flutuante para abrir/fechar."
SubText.ZIndex = 101
SubText.Parent = LoadingFrame

-- Animação de entrada e saída
LoadingFrame.Position = UDim2.new(0.5, -150, 0.4, -50)
LoadingFrame.BackgroundTransparency = 1
LoadingText.TextTransparency = 1
SubText.TextTransparency = 1

-- Animar entrada
local loadingTween1 = TweenService:Create(
    LoadingFrame,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -150, 0.5, -50), BackgroundTransparency = 0}
)

local loadingTween2 = TweenService:Create(
    LoadingText,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)

local loadingTween3 = TweenService:Create(
    SubText,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)

loadingTween1:Play()
loadingTween2:Play()
loadingTween3:Play()

-- Animar saída após 3 segundos
delay(3, function()
    local loadingTween4 = TweenService:Create(
        LoadingFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, -150, 0.4, -50), BackgroundTransparency = 1}
    )
    
    local loadingTween5 = TweenService:Create(
        LoadingText,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    
    local loadingTween6 = TweenService:Create(
        SubText,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    
    loadingTween4:Play()
    loadingTween5:Play()
    loadingTween6:Play()
    
    loadingTween6.Completed:Connect(function()
        LoadingFrame:Destroy()
    end)
end)

-- Notificação de carregamento
print("Script do Project Egoísta (Versão Delta) carregado com sucesso!")
