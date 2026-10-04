local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "ptBR")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versão %s. Configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Tracking Eye. Curtindo o add-on? Conte para um amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a Interface de Opções não pode ser aberta durante o combate."
L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Por precaução, a lista de atalhos do teclado não pode ser aberta durante o combate."
L["KEY_BINDINGS_LOCATION"] = "Abra o menu do jogo, depois %s, depois %s, e encontre a seção do Tracking Eye."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Menu de Rastreamento"
L["TRACKING_MENU_DESCRIPTION"] = "Escolha a sua Habilidade de Rastreamento Persistente."
L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
L["TARGET_TRACKING"] = "Rastreamento Automático de Alvo"
L["TARGET_TRACKING_DESCRIPTION"] = "Rastreia a espécie de qualquer criatura que você tenha como alvo."
L["FARM_MODE"] = "Modo de Coleta"
L["FARM_MODE_DESCRIPTION"] = "Alterna suas habilidades de rastreamento enquanto você viaja."

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
L["FARM_PAUSED_NO_ABILITIES"] = "Nenhuma Habilidade do Modo de Coleta está marcada."
L["FARM_PAUSED_NOT_LEARNED"] = "Você não conhece nenhuma das Habilidades do Modo de Coleta que marcou."
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s: o rastreamento só alterna em %s."
L["FARM_PAUSED_NO_STATES"] = "Nenhuma das Condições do Modo de Coleta está ativada."
L["FARM_PAUSED_NOT_MOUNTED"] = "Não está montado."
L["FARM_PAUSED_NOT_TRAVEL"] = "Não está em uma forma de viagem."
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "Não está usando %s."
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "Não está na forma de %s."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Não está montado nem em uma forma de viagem."
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "Não está montado nem usando %s."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "Não está montado nem na forma de %s."
L["FARM_PAUSED_MOUNTED_OFF"] = "O Modo de Coleta não está configurado para funcionar montado."
L["FARM_PAUSED_TRAVEL_OFF"] = "O Modo de Coleta não está configurado para formas de viagem."
L["FARM_PAUSED_ASPECT_OFF_NAMED"] = "O Modo de Coleta não está configurado para funcionar com %s."
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] = "O Modo de Coleta não está configurado para funcionar na forma de %s."
L["FARM_PAUSED_COMBAT"] = "Em combate."
L["FARM_PAUSED_CASTING"] = "Conjurando."
L["FARM_PAUSED_STEALTHED"] = "Em furtividade."
L["FARM_PAUSED_LOOTING"] = "A janela de saque está aberta."
L["FARM_PAUSED_CURSOR"] = "Você tem algo no cursor."
L["FARM_PAUSED_OPTIONS"] = "A Interface de Opções está aberta."
L["FARM_PAUSED_WINDOW"] = "Uma janela está aberta."
L["FARM_PAUSED_TOOLTIP"] = "Você está lendo uma dica."
L["FARM_PAUSED_TARGET"] = "Você tem como alvo algo que pode atacar."
L["FARM_PAUSED_STANDING_STILL"] = "Você está parado."

L["PERSISTENT_ABILITY"] = "Habilidade de Rastreamento Persistente"
L["NONE_SET"] = "Nenhuma definida"
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
	"Nenhuma Habilidade do Modo de Coleta está marcada. Marque algumas em Opções > AddOns > Tracking Eye > Modo de Coleta."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"Menu de Rastreamento melhorado e alternador automático de rastreamento que alterna entre Localizar Plantas e Localizar Minérios durante a coleta, reaplica o rastreamento após a morte e rastreia as criaturas que você tem como alvo durante as missões. Suporta todas as habilidades de rastreamento. Nunca perca de vista o que você está caçando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar Mensagem de Boas-vindas"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] =
	"Exibe no bate-papo uma saudação de uma linha quando o Tracking Eye é carregado."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar Botão do Minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Tudo continua funcionando com o botão oculto."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a Interface de Opções deste add-on."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Atalhos do Teclado"
L["OPTIONS_KEY_SET"] = "Definir Tecla"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Abre a lista de atalhos do teclado do jogo, onde o Tracking Eye tem a sua própria seção."
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Pule para a próxima habilidade de rastreamento com uma só tecla, mesmo com o Modo de Coleta desligado."

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Todas as habilidades de rastreamento que você conhece, em um único menu em ordem alfabética. A que você escolher vira a sua Habilidade de Rastreamento Persistente."
L["OPTIONS_HOOK_BLIZZARD"] = "Usar o Botão de Rastreamento Padrão"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"O botão de rastreamento padrão também abre este menu. Deixe desativado se outro add-on já usa esse botão."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Nunca mais perca o seu rastreamento: ele volta na hora depois que você morre, muda de forma ou troca de zona."
L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreamento Persistente"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Espera você sair de combate, então nunca custa um tempo de recarga global no meio da luta."
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s ao Equipar %s"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "A sua escolha volta quando você guarda a vara."
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s: %s ao Mudar para %s"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"Espera você sair da furtividade, e a sua escolha volta quando você sai da forma."
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s: %s em Campos de Batalha"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] = "Arenas também contam, e a sua escolha volta quando você sai."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Escolha uma criatura como alvo e o resto da espécie dela se acende no seu minimapa. Ótimo para fazer missões!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Habilitar Rastreamento Automático de Alvo"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Nunca troca em combate, então inimigos que entram na luta não sequestram o seu rastreamento. Saquear um cadáver também não troca."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Minimapa lotado? Tire dele o ícone de rastreamento e coloque-o onde quiser na tela."
L["OPTIONS_ENABLE_FREE"] = "Habilitar Modo de Posicionamento Livre"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"A posição dele é compartilhada por todos os seus personagens e se mantém ao recarregar a interface ou mudar a escala dela."
L["OPTIONS_ICON_SHAPE"] = "Forma do Ícone"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"O círculo combina com o minimapa; o quadrado fica perfeito ao lado dos botões de ação."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrado"
L["OPTIONS_ICON_SCALE"] = "Tamanho do Ícone"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Redimensiona no lugar, então o ícone mantém a posição."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Comentários e Suporte"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versão %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modo de Coleta"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Plantas e minérios no mesmo minimapa. O Modo de Coleta alterna suas habilidades de rastreamento enquanto você viaja, para que nenhum ponto de coleta passe despercebido."
L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de Coleta"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Pausa sozinho em combate, em cidades, em instâncias e durante voos. Passe o mouse sobre o botão do Tracking Eye para ver o motivo."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Silenciar Sons das Conjurações de Rastreamento"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Só as trocas do próprio Modo de Coleta ficam em silêncio. O rastreamento que você mesmo escolhe continua com som."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Afastar o Zoom do Minimapa"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Com o zoom todo afastado, o minimapa mostra os pontos rastreados de muito mais longe."
L["OPTIONS_FARM_CONDITIONS"] = "Condições do Modo de Coleta"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Colete do seu jeito: montado, a pé ou na forma de viagem da sua classe. O Modo de Coleta alterna em qualquer estado que você marcar."
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "Desmonte perto de um ponto de coleta e o ciclo espera enquanto você coleta."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Não Montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] = "Pare para coletar ou comer e o ciclo espera até você seguir em frente."
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s: Formas de Viagem"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s também conta."
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s e %s também contam."
L["OPTIONS_FARM_CLASS_STATE"] = "%s: %s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "Só alterna enquanto você se move, como todas as outras condições."
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] =
	"Útil em rotas de coleta em grupo, quando o grupo inteiro acompanha o seu ritmo."
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Ótimo para rotas de coleta antes da sua primeira montaria."
L["OPTIONS_CYCLE_SPEED"] = "Velocidade do Ciclo"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Cada troca custa um tempo de recarga global, então um ciclo mais lento atrapalha menos as suas próprias conjurações."
L["OPTIONS_CYCLE_EVERY"] = "Alternar a Cada %s Segundos"
L["OPTIONS_FARM_ABILITIES"] = "Habilidades do Modo de Coleta"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Marque o que você quer encontrar. O Modo de Coleta alterna cada habilidade marcada que este personagem conhece e ignora o resto."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Profissões e Habilidades Raciais"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] = "Só alterna em %s, que conta como Não Montado."
L["OPTIONS_FARM_PERSISTENT"] = "Incluir Habilidade de Rastreamento Persistente"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Nunca aparece duas vezes, mesmo se também estiver marcada abaixo. O Rastreamento Automático de Alvo a substitui pela espécie do seu alvo."

--------------------------------------------------------------------------------
-- Come & Get It
--------------------------------------------------------------------------------

--[[
    Not display copy. MATCH_* must equal the profession skill names exactly as
    the game client displays them in this language: they are substring-matched
    against the client's error text, so a loose or stylized translation silently
    stops Come & Get It from detecting herbs and ore at all. Where this
    language's clients disagree on a name, list every one, separated by
    semicolons.
]]

L["MATCH_HERB"] = "Herborismo"
L["MATCH_MINE"] = "Mineração"

--[[
    Translator guidance. Each MSG_FORMAT_* string is the complete line drafted
    into the player's chat box, picked by what the player could not interact
    with. The code fills four %s placeholders in this fixed order: node name,
    x coordinate, y coordinate, zone name. Reorder the sentence freely for your
    language, but never reorder, add, or drop placeholders.

    The greeting closes on "!" so the node name starts a fresh clause with nothing
    in front of it. That is load-bearing, not stylistic: no article or adjective
    has to agree with a name whose gender and number are unknown until runtime, and
    English dodges a/an ("an Iron Deposit" vs "a Gold Vein") for free. If your
    language reads better with an article, attach it to a fixed word rather than to
    the placeholder.

    Don't add a raid marker or the add-on name: WoW Forever blocks raid markers
    in chat, and the line reads as the player talking.
]]

L["MSG_FORMAT_LOCKED"] = "Ei, Ladinos! %s (%s, %s) em %s."
L["MSG_FORMAT_HERB"] = "Ei, Herboristas! %s (%s, %s) em %s."
L["MSG_FORMAT_MINE"] = "Ei, Mineiros! %s (%s, %s) em %s."

L["CHAT_TOO_LONG"] =
	"Este rascunho tem %d bytes e ultrapassa o limite de %d bytes do bate-papo. Encurte-o antes de enviar."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Achou uma erva que não consegue colher, um veio de minério que não consegue minerar ou um baú do tesouro trancado sem nenhum Ladino por perto? Clique nele com o botão direito e o Come & Get It cria uma mensagem que você pode usar para compartilhar ou divulgar as coordenadas. Ser herói nunca foi tão fácil."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Habilitar Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Fica em silêncio em combate e em instâncias, para que a caixa de bate-papo nunca roube o seu teclado no meio da luta."
L["OPTIONS_OUTPUT_NAME"] = "Saída Padrão"
L["OPTIONS_OUTPUT_DESCRIPTION"] = "Guilda alcança todos os membros conectados, seja qual for a camada ou a zona deles."
L["OPTIONS_OUTPUT_NOTE"] = "Observação: Local (/1) só alcança jogadores na sua camada."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Local (/1)"
