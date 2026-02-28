-- ==========================================
--  BIBLIOTECA: COMPLETO TOPBAR PLUS++&
-- ==========================================
local CustomTopbar = {}
CustomTopbar.__index = CustomTopbar

-- Serviços do Roblox
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. CRIANDO A INTERFACE BASE (Sempre no topo de tudo)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TopbarPlusPlus_Lib"
-- ZIndex máximo para garantir que fique "em cima de tudo"
screenGui.DisplayOrder = 2147483647 
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- 2. CRIANDO O CONTAINER (Para organizar as bolinhas)
local container = Instance.new("Frame")
container.Name = "IconContainer"
container.BackgroundTransparency = 1
container.Size = UDim2.new(1, -100, 0, 45)
container.Parent = screenGui

-- 3. GERENCIADOR DE ESPAÇO (Identifica e respeita o espaço de outras GUIs)
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5) -- Distância exata de 5 pixels entre as coisas!
layout.Parent = container

-- Função Principal para criar a Bolinha
function CustomTopbar.CriarBolinha(nome, corFundo, imagemId)
    
    -- "Perguntar Roblox a chat?"
    local chatAtivo = false
    pcall(function()
        -- Pergunta ao sistema se o Chat Core está ativado
        chatAtivo = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
    end)

    -- Calcula a posição inicial baseada no chat
    -- O ícone do Roblox tem 44px + margens. Se o chat existir, damos mais espaço.
    local espacoRobloxIcon = 50 
    local espacoChat = 45
    local distanciaDesejada = 5

    local posInicialX = espacoRobloxIcon
    
    -- "Se o Roblox devolve TRUE move a bolinha para 5 pixeis para frente do chat"
    if chatAtivo then
        posInicialX = espacoRobloxIcon + espacoChat + distanciaDesejada
    else
        posInicialX = espacoRobloxIcon + distanciaDesejada
    end
    
    -- Ajusta a posição do container que guarda as bolinhas
    container.Position = UDim2.new(0, posInicialX, 0, 4)

    -- 4. CRIANDO A BOLINHA
    local bolinha = Instance.new("ImageButton")
    bolinha.Name = nome or "Bolinha"
    bolinha.Size = UDim2.new(0, 45, 0, 45) -- Tamanho exigido: 45x45
    bolinha.BackgroundColor3 = corFundo or Color3.fromRGB(35, 35, 35)
    bolinha.AutoButtonColor = true
    
    -- Deixando a GUI redonda (Formato de Bolinha)
    local canto = Instance.new("UICorner")
    canto.CornerRadius = UDim.new(1, 0)
    canto.Parent = bolinha
    
    -- Se você passar um ID de imagem, ele aplica
    if imagemId then
        bolinha.Image = imagemId
        bolinha.ImageRectSize = Vector2.new(0, 0)
    end

    -- Como estamos usando o UIListLayout no container, se você criar 
    -- "outra águia/GUI", ele automaticamente a coloca 5 pixels depois dessa, respeitando o espaço!
    bolinha.Parent = container

    -- Retorna o botão para você poder criar eventos de clique nele
    return bolinha
end

return CustomTopbar
