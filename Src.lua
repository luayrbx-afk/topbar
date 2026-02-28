-- =========================================================================
--  🔥 TOPBAR PLUS++ (ULTIMATE EDITION) 🔥
--  Framework completo para criação de ícones no Topbar moderno do Roblox
-- =========================================================================

local TopbarPlusPlus = {}
TopbarPlusPlus.__index = TopbarPlusPlus

-- [ SERVIÇOS ]
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- [ CONFIGURAÇÕES GERAIS ]
local CONFIG = {
    IconSize = 45, -- Tamanho exigido
    Padding = 5,   -- Distância de 5 pixels exigida
    TopMargin = 4, -- Distância do topo da tela
    AnimationTime = 0.15,
    Colors = {
        Background = Color3.fromRGB(0, 0, 0),
        BackgroundHover = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(255, 255, 255),
        Badge = Color3.fromRGB(255, 50, 50)
    },
    Transparency = {
        Normal = 0.3,
        Hover = 0.1
    }
}

-- [ INICIALIZAÇÃO DA INTERFACE BASE ]
local screenGui = PlayerGui:FindFirstChild("TopbarPlusPlus_UI")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TopbarPlusPlus_UI"
    screenGui.DisplayOrder = 2147483647 -- Fica em cima de tudo
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true -- CRUCIAL: Ignora o recuo padrão para alinhar com o Roblox
    screenGui.Parent = PlayerGui
end

local container = screenGui:FindFirstChild("IconContainer")
if not container then
    container = Instance.new("Frame")
    container.Name = "IconContainer"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -200, 0, CONFIG.IconSize)
    container.Parent = screenGui

    -- O Layout que faz a mágica dos "5 pixels sempre respeitando o espaço"
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, CONFIG.Padding)
    layout.Parent = container
end

-- [ FUNÇÃO DE CÁLCULO DO ROBLOX CORE ]
-- Esta função calcula exatamente onde o container deve começar para não bater no chat do Roblox
local function CalcularOffsetInicial()
    local baseOffset = 54 -- Tamanho base do ícone do Roblox + margem
    
    local chatAtivo = false
    pcall(function()
        chatAtivo = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
    end)

    -- A nova barra do Roblox é dinâmica. Adicionamos espaço extra se o chat existir.
    if chatAtivo then
        baseOffset = baseOffset + 44 + CONFIG.Padding
    end

    -- Atualiza a posição do container dinamicamente
    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, baseOffset + CONFIG.Padding, 0, CONFIG.TopMargin)
    }):Play()
end

-- Calcula inicialmente e tenta recalcular se mudar
CalcularOffsetInicial()
spawn(function()
    while task.wait(5) do
        CalcularOffsetInicial() -- Checa de 5 em 5 segundos se o chat sumiu/apareceu
    end
end)

-- ==========================================
--  CLASSE DO ÍCONE (OOP)
-- ==========================================

function TopbarPlusPlus.new(nome, imageId)
    local self = setmetatable({}, TopbarPlusPlus)
    self.Name = nome
    
    -- Criando o botão principal
    local btn = Instance.new("TextButton")
    btn.Name = nome
    btn.Size = UDim2.new(0, CONFIG.IconSize, 0, CONFIG.IconSize)
    btn.BackgroundColor3 = CONFIG.Colors.Background
    btn.BackgroundTransparency = CONFIG.Transparency.Normal
    btn.Text = ""
    btn.AutoButtonColor = false -- Nós faremos nossa própria animação
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- Fica perfeitamente redondo (bolinha)
    corner.Parent = btn
    
    -- Criando a Imagem de dentro
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "IconImage"
    iconImage.BackgroundTransparency = 1
    iconImage.Size = UDim2.new(0.6, 0, 0.6, 0)
    iconImage.Position = UDim2.new(0.2, 0, 0.2, 0)
    iconImage.ImageColor3 = CONFIG.Colors.Icon
    iconImage.Image = imageId or ""
    iconImage.Parent = btn
    
    -- Adicionando um container para a Badge (Notificação)
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.Size = UDim2.new(0, 20, 0, 20)
    badge.Position = UDim2.new(0.7, 0, 0, 0)
    badge.BackgroundColor3 = CONFIG.Colors.Badge
    badge.Visible = false
    badge.ZIndex = 5
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badge
    
    local badgeText = Instance.new("TextLabel")
    badgeText.BackgroundTransparency = 1
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 12
    badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeText.Text = "0"
    badgeText.ZIndex = 6
    badgeText.Parent = badge
    
    badge.Parent = btn
    btn.Parent = container

    self.Instance = btn
    self.IconImage = iconImage
    self.BadgeText = badgeText
    self.BadgeFrame = badge
    self.Events = {} -- Para guardar conexões

    self:ConfigurarAnimacoes()

    return self
end

-- [ MÉTODOS DA CLASSE ]

-- Configura animações de Hover e Click
function TopbarPlusPlus:ConfigurarAnimacoes()
    local btn = self.Instance
    
    -- Efeito de Hover (Mouse em cima)
    table.insert(self.Events, btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(CONFIG.AnimationTime), {
            BackgroundColor3 = CONFIG.Colors.BackgroundHover,
            BackgroundTransparency = CONFIG.Transparency.Hover
        }):Play()
    end))
    
    -- Efeito de Leave (Mouse sai)
    table.insert(self.Events, btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(CONFIG.AnimationTime), {
            BackgroundColor3 = CONFIG.Colors.Background,
            BackgroundTransparency = CONFIG.Transparency.Normal
        }):Play()
    end))
    
    -- Efeito de Press (Clique)
    table.insert(self.Events, btn.MouseButton1Down:Connect(function()
        TweenService:Create(self.IconImage, TweenInfo.new(0.1), {
            Size = UDim2.new(0.5, 0, 0.5, 0),
            Position = UDim2.new(0.25, 0, 0.25, 0)
        }):Play()
    end))
    
    table.insert(self.Events, btn.MouseButton1Up:Connect(function()
        TweenService:Create(self.IconImage, TweenInfo.new(0.1), {
            Size = UDim2.new(0.6, 0, 0.6, 0),
            Position = UDim2.new(0.2, 0, 0.2, 0)
        }):Play()
    end))
end

-- Define uma função para quando o botão for clicado
function TopbarPlusPlus:AoClicar(funcao)
    table.insert(self.Events, self.Instance.MouseButton1Click:Connect(funcao))
end

-- Ativa ou desativa a bolinha vermelha de notificação (Badge)
function TopbarPlusPlus:SetNotificacao(numero)
    if numero > 0 then
        self.BadgeText.Text = tostring(numero)
        if numero > 99 then self.BadgeText.Text = "99+" end
        self.BadgeFrame.Visible = true
        
        -- Animação de pulo na notificação
        self.BadgeFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.BadgeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
            Size = UDim2.new(0, 20, 0, 20)
        }):Play()
    else
        self.BadgeFrame.Visible = false
    end
end

-- Função para destruir o botão e limpar a memória (Muito importante para libs completas)
function TopbarPlusPlus:Destruir()
    for _, conexao in ipairs(self.Events) do
        conexao:Disconnect()
    end
    self.Instance:Destroy()
end

return TopbarPlusPlus
