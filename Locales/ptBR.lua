local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "ptBR")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versão %s. Configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Tracking Eye. Curtindo o addon? Conte para um amigo! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu de Rastreamento"
L["TRACKING_MENU_DESC"] = "Veja uma lista de suas habilidades de rastreamento e defina a Habilidade de Rastreamento Persistente."

L["PERSISTENT_ABILITY"] = "Habilidade de Rastreamento Persistente"
L["NONE_SET"] = "Nenhum definido"
L["CLEAR_TRACKING"] = "Limpar Rastreamento"

L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
L["PERSISTENT_DESC"] = "Relança automaticamente o feitiço de rastreamento após a ressurreição e mudança de forma."

L["FARM_MODE"] = "Modo de Coleta"
L["FARM_MODE_DESC"] = "Alterna entre suas habilidades de rastreamento selecionadas enquanto você está em movimento."

L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
L["PLACEMENT_DESC"] = "Substitui o botão do minimapa por um ícone independente que você pode mover para qualquer lugar."

L["ENABLED"] = "Habilitado"
L["DISABLED"] = "Deshabilitado"
L["TOGGLE"] = "Alternar"

L["LEFT_CLICK"] = "Clique Esquerdo"
L["RIGHT_CLICK"] = "Clique Direito"
L["SHIFT_LEFT"] = "Shift + Clique Esquerdo"
L["SHIFT_RIGHT"] = "Shift + Clique Direito"
L["SHIFT_MIDDLE"] = "Shift + Clique do Meio"

L["TOOLTIP_OPTIONS_HINT"] = "Configurações adicionais podem ser encontradas em Opções > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "Menu de Rastreamento melhorado e alternador automático que cicla entre Encontrar Ervas e Encontrar Minérios durante a coleta e reaplica o rastreamento após a morte. Suporta todas as habilidades de rastreamento. Nunca perca de vista os recursos que você está caçando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_DESC"] = "Imprime uma saudação de uma linha no chat quando o Tracking Eye é carregado."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar Botão do Minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Mostra o botão do Tracking Eye no minimapa; o Modo de Coleta e o Rastreamento Persistente continuam funcionando quando está oculto."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Comandos de barra para o Tracking Eye. O painel de opções cobre tudo o que você precisa; estes estão aqui para quem prefere usar o teclado."
L["OPTIONS_COMMAND_TE"] = "Abre a interface de opções do Tracking Eye."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreamento Persistente"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de Coleta"
L["OPTIONS_FARM_ACTIVATE"] = "Ativar Modo de Coleta Enquanto:"
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formas de Viagem e Voo"
L["OPTIONS_FARM_CHEETAH"] = "Aspecto do Guepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lobo Fantasma"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Não Montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterna mesmo sem montaria ou forma de movimento."
L["OPTIONS_FARM_NOTE"] = "Nota: O Modo de Coleta só funciona enquanto você está fora de combate, não lançando feitiços, e fora de cidades, estalagens e instâncias."
L["OPTIONS_FARM_ABILITIES"] = "Habilidades do Modo de Coleta"
L["OPTIONS_CYCLE_SPEED"] = "Velocidade do Ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Com que frequência o Modo de Coleta alterna entre as habilidades de rastreamento (em segundos)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Habilitar Posicionamento Livre"
L["OPTIONS_ICON_SCALE"] = "Tamanho do Ícone"
L["OPTIONS_ICON_SCALE_DESC"] = "Escala do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_ICON_SHAPE"] = "Forma do Ícone"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma da borda do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrado"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Redefinir"
L["OPTIONS_RESET_DESC"] = "Restaura todas as configurações do Tracking Eye para seus valores padrão."
L["OPTIONS_RESET"] = "Redefinir todas as opções"
L["OPTIONS_RESET_CONFIRM"] = "Redefinir todas as opções do Tracking Eye para os padrões?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback e Suporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"