local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "ptBR")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versão %s. Configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Tracking Eye. Curtindo o addon? Conte para um amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a Interface de Opções não pode ser aberta durante o combate."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu de Rastreamento"
L["TRACKING_MENU_DESC"] =
	"Lista as suas habilidades de rastreamento e permite definir a sua Habilidade de Rastreamento Persistente."
L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
L["PERSISTENT_DESC"] =
	"Relança automaticamente a sua habilidade de rastreamento após a ressurreição e mudança de forma."
L["FARM_MODE"] = "Modo de Coleta"
L["FARM_MODE_DESC"] = "Alterna entre suas habilidades de rastreamento selecionadas enquanto você está em movimento."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Status do Modo de Coleta"
L["FARM_STATUS_ACTIVE"] = "Ativo"
L["FARM_STATUS_PAUSED"] = "Pausado"

L["FARM_PAUSED_DEAD"] = "Você está morto."
L["FARM_PAUSED_TAXI"] = "Em uma rota de voo."
L["FARM_PAUSED_INSTANCE"] = "Dentro de uma instância."
L["FARM_PAUSED_RESTING"] = "Em uma cidade ou estalagem."
L["FARM_PAUSED_NO_ABILITIES"] = "Nenhuma habilidade de rastreamento selecionada."
L["FARM_PAUSED_NO_STATES"] = "Nenhuma condição do Modo de Coleta está ativada."
L["FARM_PAUSED_NOT_MOUNTED"] = "Não está montado."
L["FARM_PAUSED_NOT_TRAVEL"] = "Não está em Forma de Viagem."
L["FARM_PAUSED_NOT_CHEETAH"] = "Não está usando Aspecto do Guepardo."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Não está usando Lobo Fantasma."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Não está montado nem em Forma de Viagem."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Não está montado nem usando Aspecto do Guepardo."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Não está montado nem usando Lobo Fantasma."
L["FARM_PAUSED_MOUNTED_OFF"] = "O Modo de Coleta não está configurado para funcionar enquanto montado."
L["FARM_PAUSED_TRAVEL_OFF"] = "O Modo de Coleta não está configurado para funcionar em Forma de Viagem."
L["FARM_PAUSED_CHEETAH_OFF"] = "O Modo de Coleta não está configurado para funcionar sob Aspecto do Guepardo."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "O Modo de Coleta não está configurado para funcionar sob Lobo Fantasma."
L["FARM_PAUSED_COMBAT"] = "Em combate."
L["FARM_PAUSED_CASTING"] = "Conjurando."
L["FARM_PAUSED_STEALTHED"] = "Camuflado."
L["FARM_PAUSED_LOOTING"] = "A janela de saque está aberta."
L["FARM_PAUSED_CURSOR"] = "Você tem algo no cursor."
L["FARM_PAUSED_OPTIONS"] = "A Interface de Opções está aberta."
L["FARM_PAUSED_WINDOW"] = "Uma janela está aberta."
L["FARM_PAUSED_TOOLTIP"] = "Você está lendo uma dica."

L["PERSISTENT_ABILITY"] = "Habilidade de Rastreamento Persistente"
L["SILENCE_TRACKING_SOUNDS"] = "Silenciar Sons de Rastreamento"
L["NONE_SET"] = "Nenhum definido"
L["CLEAR_TRACKING"] = "Limpar Rastreamento"

L["ENABLED"] = "Habilitado"
L["DISABLED"] = "Desabilitado"
L["TOGGLE"] = "Alternar"

L["OPEN"] = "Abrir"
L["LEFT_CLICK"] = "Clique Esquerdo"
L["RIGHT_CLICK"] = "Clique Direito"
L["SHIFT_LEFT"] = "Shift + Clique Esquerdo"
L["SHIFT_RIGHT"] = "Shift + Clique Direito"
L["SHIFT_MIDDLE"] = "Shift + Clique do Meio"

L["TOOLTIP_OPTIONS"] = "Opções do Tracking Eye"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Alternar Habilidade do Modo de Coleta"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Nenhuma habilidade de rastreamento está selecionada para o Modo de Coleta. Escolha algumas em Opções > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Menu de Rastreamento melhorado e alternador automático que cicla entre Encontrar Ervas e Encontrar Minérios durante a coleta e reaplica o rastreamento após a morte. Suporta todas as habilidades de rastreamento. Nunca perca de vista os recursos que você está caçando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_DESC"] = "Imprime uma saudação de uma linha no chat quando o Tracking Eye é carregado."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar Botão do Minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Mostra o botão do Tracking Eye no minimapa; o Modo de Coleta e o Rastreamento Persistente continuam funcionando quando está oculto."
L["OPTIONS_HOOK_BLIZZARD"] = "Usar o Botão de Rastreamento Padrão"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"Enquanto isto estiver ativado, o botão de rastreamento da Blizzard abre o Menu de Rastreamento, que apenas muda o que você está rastreando. Todo o resto permanece aqui, na Interface de Opções."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Abre o Menu de Rastreamento ao clicar no botão de rastreamento da Blizzard no minimapa. Deixe desativado se outro complemento já usa esse botão."
L["OPTIONS_KEYBINDS"] = "Atalhos de Teclado"
L["OPTIONS_KEYBINDS_DESC"] =
	"Avança o Modo de Coleta para a próxima habilidade quando você quiser. Configure em Atalhos de Teclado no menu do jogo, na seção Tracking Eye."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Comando de barra para o Tracking Eye. A Interface de Opções cobre tudo o que você precisa; este está aqui para quem prefere usar o teclado."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a Interface de Opções deste complemento."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreamento Persistente"
L["OPTIONS_TARGET_TRACKING"] = "Rastreamento Automático de Alvo"
L["OPTIONS_TARGET_TRACKING_DESC"] =
	"Rastreia o que você tem como alvo, para que o restante da espécie dele apareça no seu minimapa."
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "Nota: o Rastreamento Automático de Alvo é ótimo para fazer missões!"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modo de Coleta"
L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de Coleta"
L["OPTIONS_FARM_CONDITIONS"] = "Condições do Modo de Coleta"
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formas de Viagem e Voo"
L["OPTIONS_FARM_CHEETAH"] = "Aspecto do Guepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lobo Fantasma"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Não Montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterna mesmo sem montaria ou forma de movimento."
L["OPTIONS_FARM_NOTE"] =
	"Nota: O Modo de Coleta só funciona enquanto você está fora de combate, não lançando feitiços, e fora de cidades, estalagens, instâncias e rotas de voo."
L["OPTIONS_FARM_ABILITIES"] = "Habilidades do Modo de Coleta"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Inclui a sua Habilidade de Rastreamento Persistente na rotação. Se ela já estiver marcada abaixo, mesmo assim aparece apenas uma vez."
L["OPTIONS_CYCLE_EVERY"] = "Alternar a Cada %s Segundos"
L["OPTIONS_CYCLE_EVERY_DESC"] =
	"Com que frequência o Modo de Coleta alterna entre as habilidades de rastreamento (em segundos)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"Silencia o som de conjuração enquanto o Modo de Coleta alterna. As suas próprias conjurações não são afetadas."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
L["PLACEMENT_DESC"] =
	"Substitui o botão do minimapa por um ícone independente que você pode mover para qualquer lugar."
L["OPTIONS_ENABLE_FREE"] = "Habilitar Posicionamento Livre"
L["OPTIONS_ICON_SCALE"] = "Tamanho do Ícone"
L["OPTIONS_ICON_SCALE_DESC"] = "Tamanho do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_ICON_SHAPE"] = "Forma do Ícone"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma da borda do ícone de rastreamento ao usar o Modo de Posicionamento Livre."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrado"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback e Suporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
