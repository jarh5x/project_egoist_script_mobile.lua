--[[
    Project Egoísta Script - Versão Mobile
    Funcionalidades:
    - Auto Goal
    - Auto Steal
    - Auto Dribble
    - Interface Gráfica Adaptada para Mobile
    
    Criado por Manus
]]

-- Configurações
local Settings = {
    AutoGoal = false,
    AutoSteal = false,
    AutoDribble = false,
    Range = 20, -- Alcance para detectar a bola e jogadores
    ToggleKey = Enum.KeyCode.RightControl -- Tecla para mostrar/esconder a GUI (para usuários de PC)
}

-- Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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

-- Funções para simular toques em botões móveis
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
        -- Simular eventos de toque
        firesignal(mobileButton.MouseButton1Down)
        wait(0.1)
        firesignal(mobileButton.MouseButton1Up)
        return true
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
                -- Fallback para VirtualInputManager
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
        
        -- Se tiver a bola, chutar para o gol
        if HasBall() then
            -- Olhar para o gol
            Character.HumanoidRootPart.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, goalPosition)
            
            -- Tentar usar botão móvel para chutar
            if not SimulateMobileButtonPress("ShootButton") and not SimulateMobileButtonPress("Shoot") then
                -- Fallback para VirtualInputManager
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    end
end

local function AutoSteal()
    if not HasBall() and IsNearBall() then
        -- Tentar usar botão móvel para roubar
        if not SimulateMobileButtonPress("StealButton") and not SimulateMobileButtonPress("Steal") then
            -- Fallback para VirtualInputManager
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end
end

local function AutoDribble()
    if HasBall() then
        -- Tentar usar botão móvel para driblar
        if not SimulateMobileButtonPress("DribbleButton") and not SimulateMobileButtonPress("Dribble") then
            -- Fallback para VirtualInputManager
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Q, false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        end
        
        -- Usar Super Dash ocasionalmente
        if math.random(1, 10) == 1 then
            if not SimulateMobileButtonPress("DashButton") and not SimulateMobileButtonPress("Dash") then
                -- Fallback para VirtualInputManager
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.R, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end
        end
    end
end

-- Criar GUI adaptada para mobile
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectEgoistScriptMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Verificar se estamos em um dispositivo móvel para ajustar a escala
if isMobile then
    -- Configurar para escala automática em dispositivos móveis
    ScreenGui.IgnoreGuiInset = true
end

-- Definir o pai da GUI
if game:GetService("CoreGui") and pcall(function() return game:GetService("CoreGui").RobloxGui end) then
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Criar o frame principal com tamanho maior para mobile
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = isMobile and UDim2.new(0, 280, 0, 350) or UDim2.new(0, 200, 0, 180)
MainFrame.Position = isMobile and UDim2.new(0.5, -140, 0.7, -175) or UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Adicionar cantos arredondados para melhor aparência em mobile
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, isMobile and 50 or 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Arredondar cantos da barra de título
local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 10)
UICornerTitle.Parent = TitleBar

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = isMobile and 22 or 16
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Project Egoísta Script"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão de fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, isMobile and 50 or 30, 0, isMobile and 50 or 30)
CloseButton.Position = UDim2.new(1, isMobile and -50 or -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = isMobile and 24 or 16
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.Parent = TitleBar

-- Conteúdo
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -(isMobile and 50 or 30))
Content.Position = UDim2.new(0, 0, 0, isMobile and 50 or 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Função para criar botões de toggle adaptados para mobile
local function CreateToggle(name, position, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Size = UDim2.new(1, -40, 0, isMobile and 60 or 30)
    ToggleFrame.Position = UDim2.new(0, 20, 0, position)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Content
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = isMobile and 20 or 14
    ToggleLabel.Font = Enum.Font.SourceSansBold
    ToggleLabel.Text = name
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0.4, 0, 1, isMobile and -20 or -10)
    ToggleButton.Position = UDim2.new(0.6, 0, 0, isMobile and 10 or 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = isMobile and 18 or 12
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "OFF"
    ToggleButton.Parent = ToggleFrame
    
    -- Adicionar cantos arredondados ao botão
    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 8)
    UICornerButton.Parent = ToggleButton
    
    local isEnabled = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ToggleButton.Text = "OFF"
        end
        callback(isEnabled)
    end)
    
    return ToggleButton
end

-- Criar toggles com posições ajustadas para mobile
local positionMultiplier = isMobile and 2 or 1
local AutoGoalToggle = CreateToggle("Auto Goal", 20 * positionMultiplier, function(enabled)
    Settings.AutoGoal = enabled
end)

local AutoStealToggle = CreateToggle("Auto Steal", (20 + 50 * 1) * positionMultiplier, function(enabled)
    Settings.AutoSteal = enabled
end)

local AutoDribbleToggle = CreateToggle("Auto Dribble", (20 + 50 * 2) * positionMultiplier, function(enabled)
    Settings.AutoDribble = enabled
end)

-- Botão de créditos
local CreditsButton = Instance.new("TextButton")
CreditsButton.Name = "CreditsButton"
CreditsButton.Size = UDim2.new(1, -40, 0, isMobile and 50 or 30)
CreditsButton.Position = UDim2.new(0, 20, 0, isMobile and 260 or 130)
CreditsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CreditsButton.BorderSizePixel = 0
CreditsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsButton.TextSize = isMobile and 18 or 14
CreditsButton.Font = Enum.Font.SourceSansBold
CreditsButton.Text = "Criado por Manus"
CreditsButton.Parent = Content

-- Adicionar cantos arredondados ao botão de créditos
local UICornerCredits = Instance.new("UICorner")
UICornerCredits.CornerRadius = UDim.new(0, 8)
UICornerCredits.Parent = CreditsButton

-- Adicionar botão de mostrar/esconder específico para mobile
if isMobile then
    local ShowHideButton = Instance.new("TextButton")
    ShowHideButton.Name = "ShowHideButton"
    ShowHideButton.Size = UDim2.new(0, 60, 0, 60)
    ShowHideButton.Position = UDim2.new(0, 20, 0, -80)
    ShowHideButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ShowHideButton.BorderSizePixel = 0
    ShowHideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShowHideButton.TextSize = 30
    ShowHideButton.Font = Enum.Font.SourceSansBold
    ShowHideButton.Text = "≡"
    ShowHideButton.Parent = ScreenGui
    
    -- Adicionar cantos arredondados ao botão
    local UICornerShowHide = Instance.new("UICorner")
    UICornerShowHide.CornerRadius = UDim.new(0, 30)
    UICornerShowHide.Parent = ShowHideButton
    
    -- Adicionar sombra para melhor visibilidade
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 0, 0)
    UIStroke.Thickness = 2
    UIStroke.Parent = ShowHideButton
    
    ShowHideButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
end

-- Eventos
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Para usuários de PC, manter a funcionalidade de tecla de atalho
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Settings.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Loop principal
RunService.Heartbeat:Connect(function()
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        Character = LocalPlayer.Character
        if Character then
            Humanoid = Character:WaitForChild("Humanoid")
        end
        return
    end
    
    if Settings.AutoGoal then
        AutoGoal()
    end
    
    if Settings.AutoSteal then
        AutoSteal()
    end
    
    if Settings.AutoDribble then
        AutoDribble()
    end
end)

-- Mensagem de carregamento adaptada para mobile
local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Size = UDim2.new(0, isMobile and 300 or 200, 0, isMobile and 80 or 50)
LoadingLabel.Position = UDim2.new(0.5, isMobile and -150 or -100, 0.5, isMobile and -40 or -25)
LoadingLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingLabel.TextSize = isMobile and 20 or 16
LoadingLabel.Font = Enum.Font.SourceSansBold
LoadingLabel.Text = "Script carregado com sucesso!\n" .. (isMobile and "Use o botão flutuante para abrir/fechar." or "Pressione RightControl para abrir/fechar.")
LoadingLabel.Parent = ScreenGui

-- Adicionar cantos arredondados à mensagem de carregamento
local UICornerLoading = Instance.new("UICorner")
UICornerLoading.CornerRadius = UDim.new(0, 10)
UICornerLoading.Parent = LoadingLabel

game:GetService("Debris"):AddItem(LoadingLabel, 5)

-- Notificação de carregamento
print("Script do Project Egoísta (Versão Mobile) carregado com sucesso!")
