local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "frFR")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > Addons > Tracking Eye. Vous appréciez l'addon ? Parlez-en à un ami ! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu de pistage"
L["TRACKING_MENU_DESC"] = "Affiche une liste de vos capacités de pistage et définit la capacité de pistage persistant."

L["PERSISTENT_ABILITY"] = "Capacité de pistage persistant"
L["NONE_SET"] = "Aucun défini"
L["CLEAR_TRACKING"] = "Effacer le pistage"

L["PERSISTENT_TRACKING"] = "Pistage persistant"
L["PERSISTENT_DESC"] = "Relance automatiquement votre sort de pistage après une résurrection et un changement de forme."

L["FARM_MODE"] = "Mode de collecte"
L["FARM_MODE_DESC"] = "Alterne entre vos capacités de pistage sélectionnées lorsque vous êtes en mouvement."

L["PLACEMENT_MODE"] = "Mode de placement libre"
L["PLACEMENT_DESC"] = "Remplace le bouton de la mini-carte par une icône autonome que vous pouvez déplacer n'importe où."

L["ENABLED"] = "Activé"
L["DISABLED"] = "Désactivé"
L["TOGGLE"] = "Basculer"

L["LEFT_CLICK"] = "Clic gauche"
L["RIGHT_CLICK"] = "Clic droit"
L["SHIFT_LEFT"] = "Maj + Clic gauche"
L["SHIFT_RIGHT"] = "Maj + Clic droit"
L["SHIFT_MIDDLE"] = "Maj + Clic milieu"

L["TOOLTIP_OPTIONS_HINT"] = "Des paramètres supplémentaires se trouvent dans Options > Addons > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "Menu de pistage amélioré et commutateur automatique de pistage qui alterne entre Découverte d'herbes et Découverte de gisements pendant la collecte et réapplique le pistage après la mort. Prend en charge toutes les capacités de pistage. Ne perdez jamais la trace des ressources que vous chassez."
L["OPTIONS_ENABLE_WELCOME"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_DESC"] = "Affiche un message de bienvenue d'une ligne dans le chat au chargement de Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Activer le bouton de la mini-carte"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Affiche le bouton Tracking Eye sur la mini-carte ; le Mode de collecte et le Pistage persistant continuent de fonctionner lorsqu'il est masqué."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Commandes slash pour Tracking Eye. Le panneau d'options couvre tout ce dont vous avez besoin ; celles-ci sont là pour les adeptes du clavier."
L["OPTIONS_COMMAND_TE"] = "Ouvre l'interface des options de Tracking Eye."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Activer le pistage persistant"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Activer le mode de collecte"
L["OPTIONS_FARM_ACTIVATE"] = "Activer le mode de collecte pendant :"
L["OPTIONS_FARM_MOUNTED"] = "En monture"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formes de voyage et de vol"
L["OPTIONS_FARM_CHEETAH"] = "Aspect du guépard"
L["OPTIONS_FARM_GHOST_WOLF"] = "Loup fantôme"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Sans monture"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterne même sans monture ou forme de déplacement."
L["OPTIONS_FARM_NOTE"] = "Remarque : Le mode de collecte ne fonctionne que lorsque vous êtes hors combat, que vous ne lancez pas de sorts et en dehors des villes, auberges et instances."
L["OPTIONS_FARM_ABILITIES"] = "Capacités du mode de collecte"
L["OPTIONS_CYCLE_SPEED"] = "Vitesse de cycle"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Fréquence à laquelle le mode de collecte bascule entre les capacités de pistage (en secondes)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Activer le mode de placement libre"
L["OPTIONS_ICON_SCALE"] = "Taille de l'icône"
L["OPTIONS_ICON_SCALE_DESC"] = "Échelle de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_ICON_SHAPE"] = "Forme de l'icône"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forme de la bordure de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_SHAPE_CIRCLE"] = "Cercle"
L["OPTIONS_SHAPE_SQUARE"] = "Carré"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Réinitialiser"
L["OPTIONS_RESET_DESC"] = "Restaure chaque paramètre de Tracking Eye à sa valeur par défaut."
L["OPTIONS_RESET"] = "Réinitialiser toutes les options"
L["OPTIONS_RESET_CONFIRM"] = "Réinitialiser toutes les options de Tracking Eye aux valeurs par défaut ?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Commentaires et assistance"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"