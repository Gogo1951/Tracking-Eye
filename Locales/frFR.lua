local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "frFR")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > Add-ons > Tracking Eye. Vous appréciez l'add-on ? Parlez-en à un ami ! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Par mesure de sécurité, l'interface des options ne peut pas être ouverte en combat."
L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Par mesure de sécurité, la liste des raccourcis clavier ne peut pas être ouverte en combat."
L["KEY_BINDINGS_LOCATION"] = "Ouvrez le menu du jeu, puis %s, puis %s, et trouvez la section Tracking Eye."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Menu de pistage"
L["TRACKING_MENU_DESCRIPTION"] = "Choisissez votre Capacité de pistage persistant."
L["PERSISTENT_TRACKING"] = "Pistage persistant"
L["TARGET_TRACKING"] = "Pistage automatique de la cible"
L["TARGET_TRACKING_DESCRIPTION"] = "Piste l'espèce de toute créature que vous ciblez."
L["FARM_MODE"] = "Mode de collecte"
L["FARM_MODE_DESCRIPTION"] = "Alterne vos capacités de pistage pendant vos déplacements."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "État du Mode de collecte"
L["FARM_STATUS_ACTIVE"] = "Actif"
L["FARM_STATUS_PAUSED"] = "En pause"

L["FARM_PAUSED_DEAD"] = "Vous êtes mort."
L["FARM_PAUSED_TAXI"] = "Sur un trajet aérien."
L["FARM_PAUSED_INSTANCE"] = "Dans une instance."
L["FARM_PAUSED_RESTING"] = "Dans une ville ou une auberge."
L["FARM_PAUSED_NO_ABILITIES"] = "Aucune des Capacités du Mode de collecte n'est cochée."
L["FARM_PAUSED_NOT_LEARNED"] = "Vous ne connaissez aucune des Capacités du Mode de collecte que vous avez cochées."
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s : le pistage n'alterne qu'en %s."
L["FARM_PAUSED_NO_STATES"] = "Aucune des Conditions du Mode de collecte n'est activée."
L["FARM_PAUSED_NOT_MOUNTED"] = "Sans monture."
L["FARM_PAUSED_NOT_TRAVEL"] = "Pas en forme de voyage."
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "Pas sous %s."
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "Pas en %s."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Ni sur une monture, ni en forme de voyage."
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "Ni sur une monture, ni sous %s."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "Ni sur une monture, ni en %s."
L["FARM_PAUSED_MOUNTED_OFF"] = "Le Mode de collecte n'est pas configuré pour fonctionner en monture."
L["FARM_PAUSED_TRAVEL_OFF"] = "Le Mode de collecte n'est pas configuré pour les formes de voyage."
L["FARM_PAUSED_ASPECT_OFF_NAMED"] = "Le Mode de collecte n'est pas configuré pour fonctionner sous %s."
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] = "Le Mode de collecte n'est pas configuré pour fonctionner en %s."
L["FARM_PAUSED_COMBAT"] = "En combat."
L["FARM_PAUSED_CASTING"] = "Incantation en cours."
L["FARM_PAUSED_STEALTHED"] = "Camouflé."
L["FARM_PAUSED_LOOTING"] = "La fenêtre de butin est ouverte."
L["FARM_PAUSED_CURSOR"] = "Vous avez quelque chose sur le curseur."
L["FARM_PAUSED_OPTIONS"] = "L'interface des options est ouverte."
L["FARM_PAUSED_WINDOW"] = "Une fenêtre est ouverte."
L["FARM_PAUSED_TOOLTIP"] = "Vous lisez une infobulle."
L["FARM_PAUSED_TARGET"] = "Vous ciblez quelque chose que vous pouvez attaquer."
L["FARM_PAUSED_STANDING_STILL"] = "Vous êtes immobile."

L["PERSISTENT_ABILITY"] = "Capacité de pistage persistant"
L["NONE_SET"] = "Aucune définie"
L["CLEAR_TRACKING"] = "Effacer le pistage"

L["ENABLED"] = "Activé"
L["DISABLED"] = "Désactivé"
L["TOGGLE"] = "Basculer"

L["OPEN"] = "Ouvrir"
L["LEFT_CLICK"] = "Clic gauche"
L["RIGHT_CLICK"] = "Clic droit"
L["SHIFT_LEFT"] = "Maj + Clic gauche"
L["SHIFT_RIGHT"] = "Maj + Clic droit"
L["SHIFT_MIDDLE"] = "Maj + Clic milieu"

L["TOOLTIP_OPTIONS"] = "Options de Tracking Eye"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Changer de capacité du Mode de collecte"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Aucune des Capacités du Mode de collecte n'est cochée. Cochez-en dans Options > Add-ons > Tracking Eye > Mode de collecte."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"Menu de pistage amélioré et commutateur de pistage automatique qui alterne entre Découverte d'herbes et Découverte de gisements pendant la collecte, réapplique le pistage après la mort et piste les créatures ciblées pendant les quêtes. Prend en charge toutes les capacités de pistage. Ne perdez plus jamais la trace de ce que vous chassez."
L["OPTIONS_ENABLE_WELCOME"] = "Activer le message de bienvenue"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] =
	"Affiche une ligne de bienvenue dans la fenêtre de discussion au chargement de Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Activer le bouton de la minicarte"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Tout continue de fonctionner quand le bouton est masqué."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Raccourcis clavier"
L["OPTIONS_KEY_SET"] = "Définir une touche"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "Ouvre la liste des raccourcis clavier du jeu, où Tracking Eye a sa propre section."
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Passez à la capacité de pistage suivante d'une seule touche, même avec le Mode de collecte désactivé."

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Toutes vos capacités de pistage, dans un seul menu alphabétique. Celle que vous choisissez devient votre Capacité de pistage persistant."
L["OPTIONS_HOOK_BLIZZARD"] = "Utiliser le bouton de pistage par défaut"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"Le bouton de pistage par défaut ouvre aussi ce menu. Laissez l'option désactivée si un autre add-on utilise déjà ce bouton."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Ne perdez plus jamais votre pistage : il revient aussitôt après une mort, un changement de forme ou un changement de zone."
L["OPTIONS_ENABLE_PERSISTENT"] = "Activer le Pistage persistant"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Attend que vous soyez hors combat, pour ne jamais vous coûter un temps de recharge global en plein affrontement."
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s en équipant votre %s"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "Votre propre choix revient quand vous rangez la canne."
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s : %s en passant en %s"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"Attend que vous sortiez du camouflage, et votre propre choix revient quand vous quittez la forme."
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s : %s en champ de bataille"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"Les arènes comptent aussi, et votre propre choix revient quand vous en sortez."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Ciblez une créature et le reste de son espèce s'illumine sur votre minicarte. Idéal pour les quêtes !"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Activer le Pistage automatique de la cible"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Ne change jamais en combat : les renforts ennemis ne peuvent pas détourner votre pistage. Fouiller un cadavre ne le change pas non plus."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Mode de placement libre"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Minicarte encombrée ? Détachez-en l'icône de pistage et placez-la où vous voulez sur l'écran."
L["OPTIONS_ENABLE_FREE"] = "Activer le Mode de placement libre"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"Sa position est partagée par tous vos personnages et tient bon après un rechargement ou un changement d'échelle de l'interface."
L["OPTIONS_ICON_SHAPE"] = "Forme de l'icône"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"Le cercle s'accorde avec la minicarte ; le carré se range proprement à côté des boutons d'action."
L["OPTIONS_SHAPE_CIRCLE"] = "Cercle"
L["OPTIONS_SHAPE_SQUARE"] = "Carré"
L["OPTIONS_ICON_SCALE"] = "Taille de l'icône"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Se redimensionne sur place : l'icône garde sa position."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Commentaires et assistance"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Version %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Mode de collecte"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Herbes et minerais sur la même minicarte. Le Mode de collecte alterne vos capacités de pistage pendant vos déplacements, pour qu'aucune ressource ne vous échappe."
L["OPTIONS_ENABLE_FARM"] = "Activer le Mode de collecte"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Se met en pause tout seul en combat, en ville, en instance et pendant les vols. Survolez le bouton Tracking Eye pour savoir pourquoi."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Couper le son des capacités de pistage"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Seuls les changements du Mode de collecte deviennent silencieux. Le pistage que vous choisissez vous-même garde son son."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Dézoomer la minicarte"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Dézoomée au maximum, la minicarte affiche les ressources pistées de bien plus loin."
L["OPTIONS_FARM_CONDITIONS"] = "Conditions du Mode de collecte"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Collectez à votre façon : en monture, à pied ou dans la forme de voyage de votre classe. Le Mode de collecte alterne dans chaque état coché."
L["OPTIONS_FARM_MOUNTED"] = "En monture"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] =
	"Descendez de monture près d'une ressource et le cycle attend pendant que vous récoltez."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Sans monture"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] =
	"Arrêtez-vous pour récolter ou manger, et le cycle attend que vous repartiez."
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s : Formes de voyage"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s compte aussi."
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s et %s comptent aussi."
L["OPTIONS_FARM_CLASS_STATE"] = "%s : %s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "N'alterne que pendant vos déplacements, comme toutes les autres conditions."
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] =
	"Pratique pour les tournées de récolte en groupe, où tout le groupe suit votre rythme."
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Idéal pour les tournées de récolte avant votre première monture."
L["OPTIONS_CYCLE_SPEED"] = "Vitesse du cycle"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Chaque changement coûte un temps de recharge global : un cycle plus lent gêne donc moins vos propres sorts."
L["OPTIONS_CYCLE_EVERY"] = "Alterner toutes les %s secondes"
L["OPTIONS_FARM_ABILITIES"] = "Capacités du Mode de collecte"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Cochez ce que vous voulez trouver. Le Mode de collecte alterne chaque capacité cochée que ce personnage connaît et ignore le reste."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Métiers et compétences raciales"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] = "N'alterne qu'en %s, qui compte comme Sans monture."
L["OPTIONS_FARM_PERSISTENT"] = "Inclure la Capacité de pistage persistant"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"N'apparaît jamais deux fois, même si elle est aussi cochée ci-dessous. Le Pistage automatique de la cible la remplace par l'espèce de votre cible."

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

L["MATCH_HERB"] = "Herboristerie"
L["MATCH_MINE"] = "Minage"

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

L["MSG_FORMAT_LOCKED"] = "Hé, Voleurs ! %s (%s, %s) dans %s."
L["MSG_FORMAT_HERB"] = "Hé, Herboristes ! %s (%s, %s) dans %s."
L["MSG_FORMAT_MINE"] = "Hé, Mineurs ! %s (%s, %s) dans %s."

L["CHAT_TOO_LONG"] =
	"Ce brouillon fait %d octets et dépasse la limite de %d octets par message. Raccourcissez-le avant de l'envoyer."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Vous avez trouvé une herbe que vous ne pouvez pas cueillir, un filon de minerai que vous ne pouvez pas miner ou un coffre au trésor verrouillé, sans aucun Voleur en vue ? Faites un clic droit dessus, et Come & Get It crée un message que vous pouvez utiliser pour partager ou diffuser les coordonnées. Être un héros n'a jamais été aussi facile."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Activer Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Reste silencieux en combat et en instance, pour que la zone de discussion ne vous vole jamais le clavier en plein affrontement."
L["OPTIONS_OUTPUT_NAME"] = "Sortie par défaut"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"Guilde atteint tous les membres connectés, quelles que soient leur strate et leur zone."
L["OPTIONS_OUTPUT_NOTE"] = "Remarque : Local (/1) n'atteint que les joueurs de votre strate."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Local (/1)"
