## Créé le 8/10/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Mise à jour graphique des héritages
##
proc Katyusha_Heritages_maj {} {
    global heritages
    global heritages_graphique
    foreach {id heritage} $heritages {
        #set ID $id
        set graph [Katyusha_Heritages_creer_affichage_graphique $id $heritage]
        # Ajoute la liste temporaire au dictionnaire graphique des héritages
        dict set heritages_graphique $id $graph
        Katyusha_Heritages_lignes $id
        puts "Ajout de l'héritage : [dict get $heritage mere]"
        unset graph id heritage
        # Met à jour l'arbre des entités
        Katyusha_MCD_Objets_maj_arbre_objets
    }
}

##
# Créé l'affichage graphique de l'héritage passé en paramètre
##
proc Katyusha_Heritages_creer_affichage_graphique {ID heritage} {
    global MCD
    global rpr
    global ZONE_MCD
    
    set couleurs [dict get $heritage "couleurs"]
    # Créé l'affichage graphique du nouvel héritage dans une liste temporaire
    set x [lindex [dict get $heritage "coords"] 0]
    set y [lindex [dict get $heritage "coords"] 1]
    # Texte de l'haritage (ID + contrainte)
    set texte_heritage "$ID\n[dict get $heritage contrainte]"
    # Hop! Un petit triangle pour l'héritage
    lappend graph [$ZONE_MCD.canvas.c create polygon [list [expr $x - 40] [expr $y + 20] [expr $x + 40] [expr $y + 20] [expr $x - 0] [expr $y - 45]] -width 2 -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond"] -tag [list heritage $ID]]
    lappend graph [$ZONE_MCD.canvas.c create text [expr $x + 0] [expr $y - 0] -text $texte_heritage -fill [dict get $couleurs "texte"] -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list heritage $ID]]
    unset x y
    return $graph
}

proc Katyusha_Heritages_modification_graphique {id heritage} {
    global heritages_graphique
    
    set graph [Katyusha_Heritages_creer_affichage_graphique $id $heritage]
    # Ajoute la liste temporaire au dictionnaire graphique des héritages
    dict set heritages_graphique $id $graph
}

##
# Ajoute le nouvel héritage et créé son affichage graphique
##
proc Katyusha_Heritages_ajout {heritage_tmp} {
    global heritages
    global heritages_graphique
    global ID
    
    # Créé un id pour le nouvel héritage
    set id [expr [dict size $heritages]]
    # Ajoute le nouvel héritage aux tables existantes
    dict set heritages $ID $heritage_tmp
    set graph [Katyusha_Heritages_creer_affichage_graphique $ID $heritage_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des héritages
    dict set heritages_graphique $ID $graph
    puts "Ajout de l'héritage : $ID"
    set ID [expr $ID + 1]
    unset graph id
    # Met à jour l'arbre des entités
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
    # Créé les lignes vers les tables
    #Katyusha_Heritages_MAJ_lignes_table_mere [expr $ID - 1]
    Katyusha_Heritages_lignes [expr $ID - 1]
}

##
# Enregistre les modifications d'un héritage
##
proc Katyusha_Heritages_modification_heritage {id heritage} {
    global heritages
    
    Heritages_supression_heritage $id
    dict set heritages $id $heritage
    Katyusha_Heritages_modification_graphique $id $heritage
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
    Katyusha_Heritages_lignes $id
}

##
# Supprime l'héritage passé en oaramètre
##
proc Heritages_supression_heritage {id_heritage} {
    global LOCALE
    global heritages
    global heritages_graphique
    global ZONE_MCD
    
    # Supprime l'haritage du tableau général
    dict unset heritages $id_heritage
    # Supprime l'affichage de l'héritage
    foreach c [dict get $heritages_graphique $id_heritage] {
        $ZONE_MCD.canvas.c delete $c
    }
    Katyusha_Heritages_suppression_lignes $id_heritage
    dict unset heritages_graphique $id_heritage
    Katyusha_MCD_Objets_maj_arbre_objets
    puts "Héritage $id_heritage supprimée"
}

##
# Ajoute une table comme table fille à l'héritage concerné
##
proc Katyusha_Heritages_ajout_table_fille {id_table nom_table {graphique 1}} {
    global heritage_tmp
    
    set f ".fen_ajout_heritage"
    
    set tables_filles [dict get $heritage_tmp "filles"]
    set id_fille [expr [Dict_dernier_id $tables_filles] + 1]
    dict set tables_filles $id_fille $id_table
    dict set heritage_tmp "filles" $tables_filles
    
    # Affichage graphique de la table fille
    if {$graphique == 1} {
        label $f.filles.liste.corps.$id_fille -text $nom_table -height 2 -background white -relief solid
        pack $f.filles.liste.corps.$id_fille -fill x
        update
    }
}

##
# Initialise un nouvel héritage
##
proc Katyusha_Heritages_init_heritage {} {
    global MCD
    
    set heritage [dict create "mere" "" "filles" [list] "coords" [list] "contrainte" ""]
    dict set heritage "couleurs" [dict create "fond" $MCD(couleur_fond_heritage) "ligne" $MCD(couleur_ligne_heritage) "liens" $MCD(couleur_liens_heritage) "texte" $MCD(couleur_texte_heritage)]
    return $heritage
}

##
# Créé les lignes entre l'héritage et ses tables
##
proc Katyusha_Heritages_lignes {id_heritage} {
    global heritages
    global heritages_graphique
    global tables_graphique
    global lignes_graphique
    global MCD
    global ZONE_MCD
    
    set heritage [dict get $heritages $id_heritage]
    
    # Récupère l'ID canvas du triangle de l'affichage graphique de l'héritage pour récupérer ses coordonnées
    set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
    set coords_heritage [$ZONE_MCD.canvas.c coords $id_graphique]
    
    # Les entités :D
    set filles [dict get $heritage "filles"]
    set id_mere [dict get $heritage "mere"]
    
    ##
    # Entité mère
    ##
    
    # Pour l'entité mere, on part du haut du triangle
    set x_origine [lindex $coords_heritage 4]
    set y_origine [lindex $coords_heritage 5]
    
    # Récupère l'ID canvas de l'entité mère
    set id_mere [dict get $heritage "mere"]
    
    # Si l'héritage comporte une entité mère, on créé une ligne
    if {$id_mere != ""} {
        set id_graphique_mere [lindex [dict get $tables_graphique $id_mere] 0]
        set coords_mere [$ZONE_MCD.canvas.c coords $id_graphique_mere]
        
        # Les coordonnées d'arrivées sont au milieu bas de la table mère
        set x_arrivee [expr [lindex $coords_mere 0] + (([lindex $coords_mere 2] - [lindex $coords_mere 0]) / 2)]
        set y_arrivee [lindex $coords_mere 3]
        
        # Créé la nouvelle ligne
        set id [expr [lindex [dict keys $lignes_graphique] [expr [llength [dict keys $lignes_graphique]] - 1]] + 1]
        dict set lignes_graphique $id [list "heritage_mere" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow last -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_mere" "entite:$id_mere" "heritage:$id_heritage" "ligne:$id"]] $id_mere $id_heritage]
    }
    
    ##
    # Tables filles
    ##
    
    # Récupère le dictionnaire des tables filles pour la ligne
    set filles [dict get $heritage "filles"]
    
    foreach {k id_fille} $filles {
        # Pour les tables filles, on part du bas du triangle
        set y_origine [lindex $coords_heritage 1]
        
        set id_graphique_fille [lindex [dict get $tables_graphique $id_fille] 0]
        set coords_fille [$ZONE_MCD.canvas.c coords $id_graphique_fille]
        
        if {[lindex $coords_heritage 0] > [lindex $coords_fille 2]} {
            set x_origine [lindex $coords_heritage 0]
        } elseif {[lindex $coords_heritage 2] < [lindex $coords_fille 0]} {
            set x_origine [lindex $coords_heritage 2]
        } else {
            set x_origine [lindex $coords_heritage 4]
        }
        
        # Les coordonnées d'arrivées sont au milieu haut de la table fille
        set x_arrivee [expr [lindex $coords_fille 0] + (([lindex $coords_fille 2] - [lindex $coords_fille 0]) / 2)]
        set y_arrivee [lindex $coords_fille 1]
        
        # Créé la nouvelle ligne
        dict set lignes_graphique [expr [lindex [dict keys $lignes_graphique] [expr [llength [dict keys $lignes_graphique]] - 1]] + 1] [list "heritage_fille" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow first -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_fille" "entite:$id_fille" "heritage:$id_heritage"]] $id_fille $id_heritage]
    }
}

##
# Met à jour les lignes entre l'héritage et ses tables
##
proc Katyusha_Heritages_MAJ_lignes {id_heritage} {
    global heritages
    global heritages_graphique
    global tables_graphique
    global lignes_graphique
    global MCD
    global ZONE_MCD
    
    set heritage [dict get $heritages $id_heritage]
    
    # Récupère l'ID-canvas du triangle de l'affichage graphique de l'héritage pour récupérer ses coordonnées
    set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
    set coords_heritage [$ZONE_MCD.canvas.c coords $id_graphique]
    
    # Les tables :D
    set filles [dict get $heritage "filles"]
    set id_mere [dict get $heritage "mere"]
    
    ##
    # Table mère
    ##
    
    # Pour la table mere, on part du haut du triangle
    set x_origine [lindex $coords_heritage 4]
    set y_origine [lindex $coords_heritage 5]
    
    # Récupère l'ID-canvas de la table mère
    set id_mere [dict get $heritage "mere"]
    
    # Si l'héritage comporte une table mère, on créé une ligne
    if {$id_mere != ""} {
    set id_graphique_mere [lindex [dict get $tables_graphique $id_mere] 0]
    set coords_mere [$ZONE_MCD.canvas.c coords $id_graphique_mere]
    
    # Les coordonnées d'arrivées sont au milieu bas de la table mère
    set x_arrivee [expr [lindex $coords_mere 0] + (([lindex $coords_mere 2] - [lindex $coords_mere 0]) / 2)]
    set y_arrivee [lindex $coords_mere 3]
    
    # Recherche dans les lignes existantes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "heritage_mere"} {
            # Si c'est le cas, on la supprimme pour la recréer aux nouvelles coordonnées
            if {[lindex $ligne 3] == $id_heritage && [lindex $ligne 2] == $id_mere} {
                $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                # Créé la nouvelle ligne
                dict set lignes_graphique $k [list "heritage_mere" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow last -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_mere" "entite:$id_mere" "heritage:$id_heritage" "ligne:$k" "ligne"]] $id_mere $id_heritage]
            }
        }
    }
    $ZONE_MCD.canvas.c delete $k
    #unset ligne k
    }
    
    ##
    # Tables filles
    ##
    
    # Récupère le dictionnaire des tables filles pour la ligne
    set filles [dict get $heritage "filles"]
    
    foreach {k id_fille} $filles {
        # Pour les tables filles, on part du bas du triangle
        set y_origine [lindex $coords_heritage 1]
        
        set id_graphique_fille [lindex [dict get $tables_graphique $id_fille] 0]
        set coords_fille [$ZONE_MCD.canvas.c coords $id_graphique_fille]
        
        if {[lindex $coords_heritage 0] > [lindex $coords_fille 2]} {
            set x_origine [lindex $coords_heritage 0]
        } elseif {[lindex $coords_heritage 2] < [lindex $coords_fille 0]} {
            set x_origine [lindex $coords_heritage 2]
        } else {
            set x_origine [lindex $coords_heritage 4]
        }
        
        # Les coordonnées d'arrivées sont au milieu haut de la table fille
        set x_arrivee [expr [lindex $coords_fille 0] + (([lindex $coords_fille 2] - [lindex $coords_fille 0]) / 2)]
        set y_arrivee [lindex $coords_fille 1]
        
        # Recherche dans les lignes existantes si celle qu'on souhaite créer existe déjà
        foreach {kk ligne} $lignes_graphique {
            if {[lindex $ligne 0] == "heritage_fille"} {
                # Si c'est le cas, on la supprimme pour la recréer aux nouvelles coordonnées
                if {[lindex $ligne 3] == $id_heritage && [lindex $ligne 2] == $id_fille} {
                    $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                    # Créé la nouvelle ligne
                    dict set lignes_graphique $kk [list "heritage_fille" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow first -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_fille" "entite:$id_fille" "heritage:$id_heritage" "ligne:$kk" "ligne"]] $id_fille $id_heritage]
                }
            }
        $ZONE_MCD.canvas.c delete $kk
        }
    }
}

##
# Supprime toutes les lignes partant d'un héritage
##
proc Katyusha_Heritages_suppression_lignes {id_heritage} {
    global lignes_graphique
    global ZONE_MCD
    
    # Cherche les lignes corespondantes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "heritage_fille" || [lindex $ligne 0] == "heritage_mere"} {
            if {[lindex $ligne 3] == $id_heritage} {
                $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                dict unset lignes_graphique $k
            }
        }
    }
}

##
# Supprime une table fille de l'haritage passé en paramètres
##
proc Katyusha_Heritages_suppression_table_fille {heritage id_fille {graphique 1}} {
    set filles [dict get $heritage "filles"]
    dict unset filles $id_fille
    dict set heritage "filles" $filles
    
    # Modifie l'affichage graphique
    if {$graphique == 1} {
        set f ".fen_ajout_heritage"
        destroy label $f.filles.liste.corps.$id_fille
    }
    
    return $heritage
}


##
# Met à jour les coordonnées d'un héritage par son ID
##
proc Katyusha_Heritages_MAJ_coords {id_heritage coords} {
    global heritages
    set heritage [dict get $heritages $id_heritage]
    dict set heritage "coords" $coords
    dict set heritages $id_heritage $heritage
}
