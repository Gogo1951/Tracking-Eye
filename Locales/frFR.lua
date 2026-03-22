-- frFR.lua
local _, te = ...
if GetLocale() ~= "frFR" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Menu de pistage"
L["TRACKING_MENU_DESC"] = "Affiche une liste de vos capacités de pistage et définit la capacité de pistage persistant."

L["PERSISTENT_ABILITY"] = "Capacité de pistage persistant"
L["NONE_SET"]           = "Aucun défini"
L["CLEAR_TRACKING"]     = "Effacer le pistage"

L["PERSISTENT_TRACKING"] = "Pistage persistant"
L["PERSISTENT_DESC"]      = "Relance automatiquement votre sort de pistage après une résurrection."

L["FARM_MODE"]    = "Mode de collecte"
L["FARMING_DESC"] = "Alterne entre Herbes, Minerais et Trésors lorsque vous êtes monté ou en forme de voyage."

L["PLACEMENT_MODE"] = "Mode de placement libre"
L["PLACEMENT_DESC"] = "Remplace le bouton de la mini-carte par une icône autonome que vous pouvez déplacer n'importe où."

L["ENABLED"]  = "Activé"
L["DISABLED"] = "Désactivé"
L["TOGGLE"]   = "Basculer"

L["LEFT_CLICK"]   = "Clic gauche"
L["RIGHT_CLICK"]  = "Clic droit"
L["SHIFT_LEFT"]   = "Maj + Clic gauche"
L["SHIFT_RIGHT"]  = "Maj + Clic droit"
L["SHIFT_MIDDLE"] = "Maj + Clic milieu"

L["TOOLTIP_OPTIONS_HINT"] = "Des options supplémentaires sont disponibles en tapant /te ou dans Options > Addons > Tracking Eye."

-- Options Panel
L["OPTIONS_RESET"]               = "Réinitialiser toutes les options"
L["OPTIONS_RESET_HEADER"]        = "Réinitialiser"
L["OPTIONS_RESET_CONFIRM"]       = "Réinitialiser toutes les options de Tracking Eye aux valeurs par défaut ?"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Activer le pistage persistant"
L["OPTIONS_ENABLE_FARM"]         = "Activer le mode de collecte"
L["OPTIONS_ENABLE_FREE"]         = "Activer le mode de placement libre"
L["OPTIONS_FARM_ABILITIES"]      = "Capacités du mode de collecte"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Sélectionnez les capacités de pistage que le mode de collecte fera défiler pendant que vous êtes sur une monture ou en forme de voyage."
L["OPTIONS_CYCLE_SPEED"]         = "Vitesse de cycle"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Fréquence à laquelle le mode de collecte bascule entre les capacités de pistage (en secondes)."
L["OPTIONS_ICON_SCALE"]          = "Taille de l'icône"
L["OPTIONS_ICON_SCALE_DESC"]     = "Échelle de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_ICON_SHAPE"]          = "Forme de l'icône"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Forme de la bordure de l'icône de pistage lors de l'utilisation du mode de placement libre."
L["OPTIONS_SHAPE_CIRCLE"]        = "Cercle"
L["OPTIONS_SHAPE_SQUARE"]        = "Carré"
L["OPTIONS_LINKS"]               = "Commentaires et assistance"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f sec"
L["OPTIONS_PERCENT"]             = "%d%%"