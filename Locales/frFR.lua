local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "frFR")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > Tracking Eye. Vous appréciez l'addon ? Parlez-en à un ami ! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Par mesure de sécurité, l'interface des options ne peut pas être ouverte en combat."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu de pistage"
L["TRACKING_MENU_DESC"] =
	"Affiche la liste de vos capacités de pistage et vous permet de définir votre Capacité de pistage persistant."
L["PERSISTENT_TRACKING"] = "Pistage persistant"
L["PERSISTENT_DESC"] =
	"Relance automatiquement votre capacité de pistage après une résurrection et un changement de forme."
L["FARM_MODE"] = "Mode de collecte"
L["FARM_MODE_DESC"] = "Alterne entre vos capacités de pistage sélectionnées lorsque vous êtes en mouvement."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "État du mode de collecte"
L["FARM_STATUS_ACTIVE"] = "Actif"
L["FARM_STATUS_PAUSED"] = "En pause"

L["FARM_PAUSED_DEAD"] = "Vous êtes mort."
L["FARM_PAUSED_TAXI"] = "Sur un trajet aérien."
L["FARM_PAUSED_INSTANCE"] = "Dans une instance."
L["FARM_PAUSED_RESTING"] = "Dans une ville ou une auberge."
L["FARM_PAUSED_NO_ABILITIES"] = "Aucune capacité de pistage sélectionnée."
L["FARM_PAUSED_NO_STATES"] = "Aucune condition du mode de collecte n'est activée."
L["FARM_PAUSED_NOT_MOUNTED"] = "Sans monture."
L["FARM_PAUSED_NOT_TRAVEL"] = "Pas en Forme de voyage."
L["FARM_PAUSED_NOT_CHEETAH"] = "Aspect du guépard non actif."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Loup fantôme non actif."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Sans monture, pas en Forme de voyage."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Sans monture, Aspect du guépard non actif."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Sans monture, Loup fantôme non actif."
L["FARM_PAUSED_MOUNTED_OFF"] = "Le mode de collecte n'est pas configuré pour fonctionner en monture."
L["FARM_PAUSED_TRAVEL_OFF"] = "Le mode de collecte n'est pas configuré pour fonctionner en Forme de voyage."
L["FARM_PAUSED_CHEETAH_OFF"] = "Le mode de collecte n'est pas configuré pour fonctionner sous Aspect du guépard."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "Le mode de collecte n'est pas configuré pour fonctionner sous Loup fantôme."
L["FARM_PAUSED_COMBAT"] = "En combat."
L["FARM_PAUSED_CASTING"] = "Incantation en cours."
L["FARM_PAUSED_STEALTHED"] = "Camouflé."
L["FARM_PAUSED_LOOTING"] = "La fenêtre de butin est ouverte."
L["FARM_PAUSED_CURSOR"] = "Vous avez quelque chose sur le curseur."
L["FARM_PAUSED_OPTIONS"] = "L'interface des options est ouverte."
L["FARM_PAUSED_WINDOW"] = "Une fenêtre est ouverte."
L["FARM_PAUSED_TOOLTIP"] = "Vous lisez une infobulle."

L["PERSISTENT_ABILITY"] = "Capacité de pistage persistant"
L["SILENCE_TRACKING_SOUNDS"] = "Couper les sons de pistage"
L["NONE_SET"] = "Aucun défini"
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

L["BINDING_CYCLE_FARM_ABILITY"] = "Changer de capacité du mode de collecte"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Aucune capacité de pistage n'est sélectionnée pour le mode de collecte. Choisissez-en dans Options > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Menu de pistage amélioré et commutateur automatique de pistage qui alterne entre Découverte d'herbes et Découverte de gisements pendant la collecte et réapplique le pistage après la mort. Prend en charge toutes les capacités de pistage. Ne perdez jamais la trace des ressources que vous chassez."
L["OPTIONS_ENABLE_WELCOME"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_DESC"] = "Affiche un message de bienvenue d'une ligne dans le chat au chargement de Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Activer le bouton de la mini-carte"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Affiche le bouton Tracking Eye sur la mini-carte ; le Mode de collecte et le Pistage persistant continuent de fonctionner lorsqu'il est masqué."
L["OPTIONS_HOOK_BLIZZARD"] = "Utiliser le bouton de pistage par défaut"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"Lorsque cette option est activée, l'icône de pistage de Blizzard ouvre le menu de Tracking Eye, qui change uniquement ce que vous pistez. Tout le reste demeure ici, dans l'interface des options."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Ouvre le menu de pistage lorsque vous cliquez sur l'icône de pistage de Blizzard sur la mini-carte. Laissez cette option désactivée si un autre addon utilise déjà ce bouton."
L["OPTIONS_KEYBINDS"] = "Raccourcis clavier"
L["OPTIONS_KEYBINDS_DESC"] =
	"Fait passer le mode de collecte à sa capacité suivante à la demande. Définissez-le dans Raccourcis clavier depuis le menu du jeu, dans la section Tracking Eye."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Commande slash pour Tracking Eye. L'interface des options couvre tout ce dont vous avez besoin ; celle-ci est là pour les adeptes du clavier."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet addon."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Activer le pistage persistant"
L["OPTIONS_TARGET_TRACKING"] = "Pistage automatique de la cible"
L["OPTIONS_TARGET_TRACKING_DESC"] =
	"Piste ce que vous ciblez, afin que le reste de son espèce apparaisse sur votre mini-carte."
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "Remarque : le pistage automatique de la cible est idéal pour les quêtes !"

-- Farm Mode

L["TAB_FARM_MODE"] = "Mode de collecte"
L["OPTIONS_ENABLE_FARM"] = "Activer le mode de collecte"
L["OPTIONS_FARM_CONDITIONS"] = "Conditions du mode de collecte"
L["OPTIONS_FARM_MOUNTED"] = "En monture"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formes de voyage et de vol"
L["OPTIONS_FARM_CHEETAH"] = "Aspect du guépard"
L["OPTIONS_FARM_GHOST_WOLF"] = "Loup fantôme"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Sans monture"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterne même sans monture ou forme de déplacement."
L["OPTIONS_FARM_NOTE"] =
	"Remarque : Le mode de collecte ne fonctionne que lorsque vous êtes hors combat, que vous ne lancez pas de sorts et en dehors des villes, auberges, instances et trajets aériens."
L["OPTIONS_FARM_ABILITIES"] = "Capacités du mode de collecte"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Inclut votre Capacité de pistage persistant dans la rotation. Si elle est déjà cochée ci-dessous, elle n'apparaît quand même qu'une seule fois."
L["OPTIONS_CYCLE_EVERY"] = "Alterner toutes les %s secondes"
L["OPTIONS_CYCLE_EVERY_DESC"] =
	"Fréquence à laquelle le mode de collecte bascule entre les capacités de pistage (en secondes)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"Coupe le son d'incantation pendant que le mode de collecte alterne. Vos propres incantations ne sont pas affectées."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Mode de placement libre"
L["PLACEMENT_DESC"] =
	"Remplace le bouton de la mini-carte par une icône autonome que vous pouvez déplacer n'importe où."
L["OPTIONS_ENABLE_FREE"] = "Activer le mode de placement libre"
L["OPTIONS_ICON_SCALE"] = "Taille de l'icône"
L["OPTIONS_ICON_SCALE_DESC"] = "Taille de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_ICON_SHAPE"] = "Forme de l'icône"
L["OPTIONS_ICON_SHAPE_DESC"] =
	"Forme de la bordure de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_SHAPE_CIRCLE"] = "Cercle"
L["OPTIONS_SHAPE_SQUARE"] = "Carré"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Commentaires et assistance"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
