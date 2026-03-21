local _, te = ...
if GetLocale() ~= "ptBR" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Menu de Rastreamento"
L["TRACKING_MENU_DESC"] = "Veja uma lista de suas habilidades de rastreamento e defina a Habilidade de Rastreamento Persistente."

L["PERSISTENT_ABILITY"] = "Habilidade de Rastreamento Persistente"
L["NONE_SET"]           = "Nenhum definido"
L["CLEAR_TRACKING"]     = "Limpar Rastreamento"

L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
L["PERSISTENT_DESC"]      = "Relança automaticamente o feitiço de rastreamento após a ressurreição."

L["FARM_MODE"]    = "Modo de Coleta"
L["FARMING_DESC"] = "Alterna entre Ervas e Minérios enquanto montado ou em forma de viagem."

L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
L["PLACEMENT_DESC"] = "Substitui o botão do minimapa por um ícone independente que você pode mover para qualquer lugar."

L["ENABLED"]  = "Habilitado"
L["DISABLED"] = "Desabilitado"
L["TOGGLE"]   = "Alternar"

L["LEFT_CLICK"]   = "Clique Esquerdo"
L["RIGHT_CLICK"]  = "Clique Direito"
L["SHIFT_LEFT"]   = "Shift + Clique Esquerdo"
L["SHIFT_RIGHT"]  = "Shift + Clique Direito"
L["SHIFT_MIDDLE"] = "Shift + Clique do Meio"

L["TOOLTIP_OPTIONS_HINT"] = "Opções adicionais estão disponíveis em Opções > AddOns > Tracking Eye."

-- Options Panel
L["OPTIONS_ALWAYS_ON"]           = "(Sempre Ativo)"
L["OPTIONS_CYCLE_SPEED"]         = "Velocidade do Ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Com que frequência o Modo de Coleta alterna entre as habilidades de rastreamento (em segundos)."
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_ENABLE_FARM"]         = "Habilitar Modo de Coleta"
L["OPTIONS_ENABLE_FREE"]         = "Habilitar Posicionamento Livre"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Habilitar Rastreamento Persistente"
L["OPTIONS_FARM_ABILITIES"]      = "Habilidades do Modo de Coleta"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Selecione quais habilidades de rastreamento o Modo de Coleta alternará enquanto montado ou em forma de viagem."
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_ICON_SCALE"]          = "Tamanho do Ícone"
L["OPTIONS_ICON_SCALE_DESC"]     = "Escala do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_ICON_SHAPE"]          = "Forma do Ícone"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Forma da borda do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_LINKS"]               = "Feedback e Suporte"
L["OPTIONS_PERCENT"]             = "%d%%"
L["OPTIONS_RESET"]               = "Redefinir todas as opções"
L["OPTIONS_SECONDS"]             = "%.1f seg"
L["OPTIONS_SHAPE_CIRCLE"]        = "Círculo"
L["OPTIONS_SHAPE_SQUARE"]        = "Quadrado"