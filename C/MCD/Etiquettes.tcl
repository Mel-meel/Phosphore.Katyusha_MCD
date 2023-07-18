## Créé le 5/9/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Mise à jour graphique des étiquettes
##
proc Katyusha_Etiquettes_maj {} {
    global etiquettes
    global etiquettes_graphique
    
    foreach {id etiquette} $etiquettes {
        #set ID $id
        set graph [Katyusha_Etiquettes_creer_affichage_graphique $id $etiquette]
        # Ajoute la liste temporaire au dictionnaire graphique des étiquettes
        dict set etiquettes_graphique $id $graph
        puts "Ajout de l'étiquette : [dict get $etiquette nom]"
        unset graph id etiquette
        # Met à jour l'arbre des entités
        Katyusha_MCD_Objets_maj_arbre_objets
    }
}

##
# Ajoute une étiquette
##
proc Katyusha_Etiquettes_ajout_etiquette {etiquette_tmp} {
    # Charge la variable globale contenant toutes les etiquettes
    global etiquettes
    global etiquettes_graphique
    global ID
        
    # Créé un id pour la nouvelle table
    set id [expr [dict size $etiquettes]]
    # Ajoute la nouvelle table aux etiquettes existantes
    dict set etiquettes $ID $etiquette_tmp
    set graph [Katyusha_Etiquettes_creer_affichage_graphique $ID $etiquette_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des etiquettes
    dict set etiquettes_graphique $ID $graph
    puts "Ajout de l'étiquette : [dict get $etiquette_tmp nom]"
    set ID [expr $ID + 1]
    #unset graph id
    # Met à jour l'arbre des entités
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
}

proc Katyusha_Etiquettes_creer_affichage_graphique {ID etiquette} {
    global rpr
    global ZONE_MCD
    
    # Récupère le nom de l'étiquette
    set nom [dict get $etiquette "nom"]
    set texte [dict get $etiquette "texte"]
    # Calcul la taille de l'étiquette sur le canvas
    set hauteur [Katyusha_Etiquettes_hauteur $texte]
    set largeur [Katyusha_Etiquettes_largeur $texte]
    # Créé l'affichage graphique de la nouvelle étiquette dans une liste temporaire
    set x [lindex [dict get $etiquette "coords"] 0]
    set y [lindex [dict get $etiquette "coords"] 1]
    lappend graph [$ZONE_MCD.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2)] -outline #FF7000 -fill #FFE3CD -tag [list etiquette $ID]]
    lappend graph [$ZONE_MCD.canvas.c create text [expr $x] [expr $y + 10] -fill black -justify center -text $texte -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list etiquette $ID]]
    return $graph
}

proc Katyusha_Etiquettes_largeur {texte} {
    set largeur 0
    set lignes [split $texte "\n"]
    foreach ligne $lignes {
        if {[string length $ligne] > $largeur} {
            set largeur [string length $ligne]
        }
    }
    set largeur [expr ($largeur * 8) + 50]
    return $largeur
}

proc Katyusha_Etiquettes_hauteur {texte} {
    set hauteur 16
    set lignes [split $texte "\n"]
    foreach ligne $lignes {
        #set hauteur [expr $hauteur + 25]
    }
    set hauteur [expr [llength $lignes] * 20]
    set hauteur [expr $hauteur + 20]
    return $hauteur
}

##
# Mis à jour des coordonnées de l'étiquette passée en paramètre
##
proc Katyusha_Etiquettes_MAJ_coords {id_etiquette coords} {
    global etiquettes
    set etiquette [dict get $etiquettes $id_etiquette]
    dict set etiquette "coords" $coords
    dict set etiquettes $id_etiquette $etiquette
}

proc Etiquettes_supression_etiquette {etiquette} {
    global etiquettes
    global etiquettes_graphique
    global ZONE_MCD
    
    # Récupère le nom de l'étiquette
    set nom [dict get [dict get $etiquettes $etiquette] nom]
    # Supprime l'étiquette du tableau général
    dict unset etiquettes $etiquette
    # Supprime l'affichage de l'étiquette
    for {set c 0} {$c < 2} {incr c} {
        $ZONE_MCD.canvas.c delete [lindex [dict get $etiquettes_graphique $etiquette] $c]
    }
    dict unset etiquettes_graphique $etiquette
    Katyusha_MCD_Objets_maj_arbre_objets
    puts "Étiquette $nom supprimée"
    unset nom
}
