--[[
    Project Egoísta - Script Simplificado de Auto Goal
    Otimizado para Delta
    
    Este script usa métodos diretos e simplificados para teste
]]

-- Configurações
local enabled = false
local debugMode = true -- Ativa mensagens de debug

-- Variáveis
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Função de debug
local function debug(message)
    if debugMode then
        print("[AutoGoal Debug] " .. message)
        
        -- Tenta mostrar mensagem na tela também
        if game:GetService("CoreGui"):FindFirstChild("DebugLabel") then
            game:GetService("CoreGui").DebugLabel.Text = message
        end
    end
end

-- Criar label de debug na tela
local debugLabel = Instance.new("TextLabel")
debugLabel.Name = "DebugLabel"
debugLabel.Size = UDim2.new(0, 300, 0, 30)
debugLabel.Position = UDim2.new(0.5, -150, 0.8, 0)
debugLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
debugLabel.BackgroundTransparency = 0.5
debugLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
debugLabel.TextSize = 16
debugLabel.Font = Enum.Font.SourceSans
debugLabel.Text = "Auto Goal Debug"
debugLabel.Parent = game:GetService("CoreGui")

-- Funções de utilidade
local function GetBall()
    debug("Procurando bola...")
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Ball" or v.Name == "SoccerBall" or v.Name:lower():find("ball") then
            debug("Bola encontrada: " .. v.Name)
            return v
        end
    end
    debug("Bola não encontrada")
    return nil
end

local function IsNearBall()
    local ball = GetBall()
    if ball and Character:FindFirstChild("HumanoidRootPart") then
        local distance = (ball.Position - Character.HumanoidRootPart.Position).Magnitude
        debug("Distância até a bola: " .. distance)
        return distance <= 20
    end
    return false
end

local function HasBall()
    local ball = GetBall()
    if ball and Character:FindFirstChild("HumanoidRootPart") then
        local distance = (ball.Position - Character.HumanoidRootPart.Position).Magnitude
        debug("Distância para posse de bola: " .. distance)
        return distance <= 5
    end
    return false
end

-- Funções diretas para Delta
local function PressKey(key)
    debug("Tentando pressionar tecla: " .. key)
    
    -- Método 1: keypress (Delta)
    if keypress then
        debug("Usando keypress")
        keypress(key)
        wait(0.1)
        keyrelease(key)
        return true
    end
    
    -- Método 2: VirtualInputManager
    debug("Usando VirtualInputManager")
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[key], false, game)
    wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode[key], false, game)
    
    return true
end

local function ClickMouse()
    debug("Tentando clicar mouse")
    
    -- Método 1: mouse1press (Delta)
    if mouse1press then
        debug("Usando mouse1press")
        mouse1press()
        wait(0.1)
        mouse1release()
        return true
    end
    
    -- Método 2: VirtualInputManager
    debug("Usando VirtualInputManager para mouse")
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    wait(0.1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    return true
end

-- Função Auto Goal simplificada
local function AutoGoal()
    debug("Executando Auto Goal")
    
    local ball = GetBall()
    if not ball then 
        debug("Bola não encontrada, abortando")
        return 
    end
    
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        debug("Personagem válido")
        
        -- Se não tiver a bola e estiver perto, tenta roubar
        if not HasBall() and IsNearBall() then
            debug("Tentando roubar bola")
            PressKey("E") -- Tecla para roubar
        end
        
        -- Se tiver a bola, chuta
        if HasBall() then
            debug("Tentando chutar bola")
            ClickMouse() -- Clique para chutar
        end
    else
        debug("Personagem inválido")
    end
end

-- Interface simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoGoalUI"
ScreenGui.ResetOnSpawn = false

-- Definir o pai da GUI (otimizado para Delta)
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Botão simples
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.1, 0)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.BorderSizePixel = 0
Button.Text = "Auto Goal: OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 20
Button.Parent = ScreenGui

-- Arredondar cantos
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Button

-- Evento de clique
Button.MouseButton1Click:Connect(function()
    enabled = not enabled
    Button.Text = "Auto Goal: " .. (enabled and "ON" or "OFF")
    Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
    debug("Auto Goal " .. (enabled and "ativado" or "desativado"))
end)

-- Loop principal simplificado
RunService.Heartbeat:Connect(function()
    if enabled then
        local success, errorMsg = pcall(function()
            AutoGoal()
        end)
        
        if not success then
            debug("Erro: " .. errorMsg)
        end
    end
end)

debug("Script carregado com sucesso!")
