## Créé le 11/6/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Initialise le nouveau digramme de classes ULM
##
proc Katyusha_UML_init {} {
    global classes
    global classes_graphique
    global interfaces
    global interfaces_graphique
    global ID_UML
    global ID
    
    # Dictionnaire contenant toutes les classes et leurs informations, sauf graphiques
    set classes [dict create]
    #
    set classes_graphique [dict create]
    
    # Dictionnaire contenant toutes les interfaces et leurs informations, sauf graphiques
    set interfaces [dict create]
    #
    set interfaces_graphique [dict create]
    set ID_UML $ID
}

proc Katyusha_UML_canvas_effacer {} {
    global ZONE_UML
    $ZONE_MCD.modelisation.c delete "objet_uml"
}

proc Katyusha_UML_action_boutons_ajout {objet_select} {
    global ACTION_B1
    global NOTEBOOK_UML
    global ENV
    
    set objets [list "classe"]
    set ENV "uml"
    
    if {$ACTION_B1 == "ajout_$objet_select"} {
        set ACTION_B1 "null"
        $NOTEBOOK_UML.panel.commandes.ajout_$objet_select configure -relief raised
    } else {
        set ACTION_B1 "ajout_$objet_select"
        $NOTEBOOK_UML.panel.commandes.ajout_$objet_select configure -relief sunken
    }
    foreach objet $objets {
        if {$objet != $objet_select} {
            $NOTEBOOK_UML.panel.commandes.ajout_$objet configure -relief raised
        }
    }
}

##
# Remet sur off tous les boutons de commande
##
proc Katyusha_UML_boutons_ajout_off {} {
    global ACTION_B1
    global CONFIGS
    global NOTEBOOK_UML
    global ENV
    
    foreach bouton [list "ajout_classe"] {
        $NOTEBOOK_UML.panel.commandes.$bouton configure -relief raised
    }
    set ACTION_B1 "null"
    set ENV "null"
}
