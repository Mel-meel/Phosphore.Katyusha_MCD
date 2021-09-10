## Créé le 3/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Met à jour l'affichage graphique des relations (après le chargement d'un projet par exemple)
##
proc Katyusha_Relations_maj {} {
    global relations
    global relations_graphique
    foreach {id relation} $relations {
        set graph [Katyusha_Relations_creer_affichage_graphique $id $relation]
        # Ajoute la liste temporaire au dictionnaire graphique des relations
        dict set relations_graphique $id $graph
        puts "Ajout de la relation : [dict get $relation nom]"
        # Créé les lignes reliant la relation aux tables concernées
        Katyusha_Relations_lignes_relation_tables $relation $id
        Katyusha_Relations_MAJ_ligne_coords $id [list]
        unset graph id relation
        # Met à jour l'arbre des entités
        maj_arbre_entites
    }
}

proc Katyusha_Relations_MAJ_lignes_relations {} {
    global relations
    foreach {k relation} $relations {
        Katyusha_Relations_lignes_relation_tables $relation $k
    }
}

##
# Créé l'affichage graphique d'une relation
##
proc Katyusha_Relations_creer_affichage_graphique {ID relation} {
    global MCD
    global IMG
    
    # Récupère le nom de la relation
    set nom [dict get $relation "nom"]
    set couleurs [dict get $relation "couleurs"]
    # Créé le texte d'affichage des attributs
    set texte_attributs ""
    set hauteur 16
    set pks [list]
    set attributs [dict get $relation "attributs"]
    set couleurs [dict get $relation "couleurs"]
    # Détermine la taille des colones
    set tailles_colones [Katyusha_Tables_creer_texte_affichage_graphique_taille_colones $attributs]
    set colones [Katyusha_Tables_creer_affichage_graphique_format_colones $attributs]
    foreach {k v} $attributs {
        if {[dict get $v "pk"] == 1} {
            lappend pks $hauteur
        }
        set hauteur [expr $hauteur + 18]
    }
    
    set hauteur [expr $hauteur + 18]
    # Calcul la taille de la relation sur le canvas
    set largeur_nom [expr ([string length $nom] * 10) + 20]
    set largeur_atts [expr (([dict get $tailles_colones "nom"] + [dict get $tailles_colones "type"] + [dict get $tailles_colones "null"]) * 10) + 90]
    if {$largeur_nom <= $largeur_atts} {
        set largeur $largeur_atts
    } else {
        set largeur $largeur_nom
    }
    # Créé l'affichage graphique de la nouvelle relation dans une liste temporaire
    set x [lindex [dict get $relation "coords"] 0]
    set y [lindex [dict get $relation "coords"] 1]
    # Rectangle invisible, sorte de "bound box" de la relation
    #lappend graph [.mcd.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 30] -state hidden -tag [list relation $ID]]
    
    lappend graph [.mcd.canvas.c create oval [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 30] -width 2 -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond"] -tag [list relation $ID]]
    lappend graph [.mcd.canvas.c create text [expr $x - ($largeur / 2) + 20] [expr $y + 30] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones "pk"] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
    lappend graph [.mcd.canvas.c create oval [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 30] -width 2 -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond"] -tag [list relation $ID]]
    lappend graph [.mcd.canvas.c create text [expr $x - (([string length $nom] * 7.5) / 2)] [expr $y - ($hauteur / 2) + 20] -fill [dict get $couleurs "texte"] -anchor w -text $nom -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]

    lappend graph [.mcd.canvas.c create text [expr $x - ($largeur / 2) + 50] [expr $y + 30] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones "nom"] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
    lappend graph [.mcd.canvas.c create text [expr $x - ($largeur / 2) + 50 + ([dict get $tailles_colones "nom"] * 10) + 10] [expr $y + 30] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones "type"] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
    lappend graph [.mcd.canvas.c create text [expr $x - ($largeur / 2) + 50 + (([dict get $tailles_colones "nom"] + [dict get $tailles_colones "type"]) * 10) + 20] [expr $y + 30] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones "null"] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
    # Créé les images de clefs primaires
    foreach pk $pks {
        lappend graph [.mcd.canvas.c create image [expr $x - ($largeur / 2) + 25] [expr $y - ($hauteur / 2) + 30 + $pk] -image $IMG(pk) -tag [list relation $ID]]
    }
    unset x y hauteur largeur nom relation ID
    return $graph
}

##
# Détermine la taille en nombre de caractères d'une relation pour l'affichage graphique
##
proc Katyusha_Relations_taille_table_graphique {relation} {
    set taille 0
    set taille [string length [dict get $relation "nom"]]
    set liens [dict get $relation "liens"]
    foreach {k lien} $liens {
        set taille_tmp [string length "$k : [lindex $lien 0] -> [lindex $lien 1]"]
        if {$taille_tmp > $taille} {
            set taille $taille_tmp
        }
    }
    set attributs [dict get $relation "attributs"]
    foreach {k attribut} $attributs {
        set taille_tmp [string length "[dict get $attribut nom] | [dict get $attribut type]"]
        if {$taille_tmp > $taille} {
            set taille $taille_tmp
        }
    }
    if {$taille == [string length [dict get $relation "nom"]]} {
        set taille [expr $taille * 1.5]
    }
    return $taille
}

##
# Ajout d'une relation entre plusieurs tables
##
proc Katyusha_ajout_relation {relation_tmp} {
    # Charge les variables nécessaires à l'ajout d'une nouvelle relation
    global relations
    global relations_graphique
    global ID
    # Créé un id pour la nouvelle relation
    set id [expr [dict size $relations]]
    # Récupère le nom de la relation
    set nom [dict get $relation_tmp nom]
    # Si le nom est vide
    if {$nom == ""} {
        set nom "Relation_$id"
        dict set relation_tmp "nom" $nom
        dict unset $relation_tmp "id"
    }
    # Ajoute la nouvelle relation aux relations existantes
    dict set relations $ID $relation_tmp
    # Créé le texte d'affichage des attributs
    set texte_attributs ""
    set hauteur 20
    # Calcul la taille de la relation sur le canvas
    set largeur [expr ([string length $nom] * 8) + 50]
    # Créé l'affichage graphique de la nouvelle relation
    set graph [Katyusha_Relations_creer_affichage_graphique $ID $relation_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des tables
    dict set relations_graphique $ID $graph
    # Trace les lignes pour plus de visibilité
    Katyusha_Relations_lignes_relation_tables $relation_tmp $ID
    puts "Ajout de la relation : [dict get $relation_tmp nom]"
    set ID [expr $ID + 1]
    unset graph relation_tmp nom hauteur largeur texte_attributs
    maj_arbre_entites
    Katyusha_Historique_maj
}

proc Katyusha_Relations_modification_graphique {id relation} {
    global relations
    global relations_graphique
    
    set graph [Katyusha_Relations_creer_affichage_graphique $id $relation]
    # Ajoute la liste temporaire au dictionnaire graphique des relations
    dict set relations_graphique $id $graph
}

##
# Enregistre les modifications d'une relation
##
proc Katyusha_Relations_modification_relation {id relation} {
    global relations
    global lignes_graphique
    global textes_cardinalites
    
    suppression_relation $id
    dict set relations $id $relation
    Katyusha_Relations_modification_graphique $id $relation
    # Recalcul les lignes entre la relation et les tables concernées
    foreach {k ligne} $lignes_graphique {
        set id_relation_tmp [lindex $ligne 2]
        if {$id == $id_relation_tmp} {
            .mcd.canvas.c delete [lindex $ligne 0]
            dict unset lignes_graphique $k
            dict unset textes_cardinalites $k
        }
            #.mcd.canvas.c delete [dict get $textes_cardinalites $k]
    }
    Katyusha_Relations_lignes_relation_tables $relation $id
    maj_arbre_entites
    Katyusha_Historique_maj
}

##
# Met à jour les coordonnées d'une relation par son ID
##
proc Katyusha_Relations_MAJ_coords {id_relation coords} {
    global relations
    set relation [dict get $relations $id_relation]
    dict set relation "coords" $coords
    dict set relations $id_relation $relation
}

##
# Créé les lignes reliant la relation aux tables qu'elle concerne
##
proc Katyusha_Relations_lignes_relation_tables {relation id_relation} {
    global relations
    global relations_graphique
    global lignes_graphique
    global textes_cardinalites
    global MCD
    
    # Détermine les coordonnées des lignes à tracer
    set id_graphique [lindex [dict get $relations_graphique $id_relation] 0]
    set coords [.mcd.canvas.c coords $id_graphique]
    # Taille de la relation en pixels
    set largeur_relation [expr [lindex $coords 2] - [lindex $coords 0]]
    set hauteur_relation [expr [lindex $coords 3] - [lindex $coords 1]]
    # Origines des lignes
    set x_origine [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y_origine [expr [lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)]
    
    set liens [dict get $relation "liens"]
    # Teste si les liens ne sont pas nuls
    if {$liens != ""} {
        foreach {k lien} $liens {
            # Teste si les liens concernent bien une table
            if {[lindex $lien 0] != ""} {
                set nom_table_lien [lindex $lien 0]
                # ID de la table par son nom
                set id_table [Katyusha_Tables_ID_table $nom_table_lien]
                # Récupère les coordonnées graphiques de l'affichage graphique de la table
                set coords_table_lien [Katyusha_Tables_coords_ID $id_table]
                # Taille de la table en pixels
                set largeur_table [expr [lindex $coords_table_lien 4] - [lindex $coords_table_lien 2]]
                set hauteur_table [expr [lindex $coords_table_lien 5] - [lindex $coords_table_lien 3]]
                set x_arrivee [lindex $coords_table_lien 0]
                set y_arrivee [lindex $coords_table_lien 1]
            if {[lindex $coords 2] < [lindex $coords_table_lien 2]} {
                set x_origine [lindex $coords 2]
                set y_origine [expr [lindex $coords 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords_table_lien 2]
                set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_table / 2)]
            } elseif {[lindex $coords 0] > [lindex $coords_table_lien 4]} {
                set x_origine [lindex $coords 0]
                set y_origine [expr [lindex $coords 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords_table_lien 4]
                set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_table / 2)]
            } else {
                if {[lindex $coords 1] > [lindex $coords_table_lien 5]} {
                    set x_origine [expr [lindex $coords 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords 1]
                    set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords_table_lien 5]
                } elseif {[lindex $coords 3] < [lindex $coords_table_lien 3]} {
                    set x_origine [expr [lindex $coords 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords 3]
                    set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords_table_lien 3]
                }
            }
            set id [expr [lindex [dict keys $lignes_graphique] [expr [llength [dict keys $lignes_graphique]] - 1]] + 1]
            dict set lignes_graphique $id [list "relation" [.mcd.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list "ligne" $id_table]] $id_table $id_relation]
            #dict set textes_cardinalites $id [list $id_table [.mcd.canvas.c create text [expr ($x_arrivee + $x_origine) / 2] [expr ($y_arrivee + $y_origine) / 2] -text [Katyusha_Relations_cardinalite $id_relation $id_table] -tag [list "texte_cardinalite" $id_table]]]
            }
        }
    }
}

##
# Met à jour les coordonnées des lignes reliants la relation aux tables
# La mise à jour des coordonnées ne fonctionnant pas correctement, à chaque fois
# les lignes sont supprimées et remplacées par des lignes correspondants aux nouvelles coordonnées
##
proc Katyusha_Relations_MAJ_ligne_coords {id_relation coords} {
    global lignes_graphique
    global relations_graphique
    global textes_cardinalites
    global MCD
    
    # Détermine les coordonnées des lignes à tracer
    set id_graphique [lindex [dict get $relations_graphique $id_relation] 0]
    set coords [.mcd.canvas.c coords $id_graphique]
    # Taille de la relation en pixels
    set largeur_relation [expr [lindex $coords 2] - [lindex $coords 0]]
    set hauteur_relation [expr [lindex $coords 3] - [lindex $coords 1]]
    # Origines des lignes
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr [lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)]
    
    # Balayage des lignes à la recharche de celles concernants la relation spécifiée
    foreach {k ligne} $lignes_graphique {
        set id_relation_tmp [lindex $ligne 3]
        if {$id_relation_tmp == $id_relation} {
            # Récupère les anciennes coordonnées de la ligne
            set acoords [.mcd.canvas.c coords [lindex $ligne 1]]
            # Créé les nouvelles coordonnées :
            #           [nouveau_x_origine nouveau_y_origine ancien_x_cible ancien_y_cible]
            set ncoords [list $x $y [lindex $acoords 2] [lindex $acoords 3]]
            set id_table [lindex $ligne 2]
            set coords_table_lien [Katyusha_Tables_coords_ID $id_table]
            #.mcd.canvas.c coords $ligne $x $y [lindex $acoords 2] [lindex $acoords 3]
            # Taille de la table en pixels
            set largeur_table [expr [lindex $coords_table_lien 4] - [lindex $coords_table_lien 2]]
            set hauteur_table [expr [lindex $coords_table_lien 5] - [lindex $coords_table_lien 3]]
            set x_origine [lindex $ncoords 0]
            set y_origine [lindex $ncoords 1]
            set x_arrivee [lindex $ncoords 2]
            set y_arrivee [lindex $ncoords 3]
            if {[lindex $coords 2] < [lindex $coords_table_lien 2]} {
                set x_origine [lindex $coords 2]
                set y_origine [expr [lindex $coords 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords_table_lien 2]
                set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_table / 2)]
            } elseif {[lindex $coords 0] > [lindex $coords_table_lien 4]} {
                set x_origine [lindex $coords 0]
                set y_origine [expr [lindex $coords 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords_table_lien 4]
                set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_table / 2)]
            } else {
                if {[lindex $coords 1] > [lindex $coords_table_lien 5]} {
                    set x_origine [expr [lindex $coords 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords 1]
                    set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords_table_lien 5]
                } elseif {[lindex $coords 3] < [lindex $coords_table_lien 3]} {
                    set x_origine [expr [lindex $coords 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords 3]
                    set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords_table_lien 3]
                }
            }
            # Si la relation est par dessus l'objet ou touche l'objet auquel elle est liée, pas de ligne
            if {$x_origine != "" && $y_origine != "" && $x_arrivee != "" && $y_arrivee != ""} {
                # Créé la nouvelle ligne
                dict set lignes_graphique $k [list "relation" [.mcd.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list "ligne" $id_table]] $id_table $id_relation]
                # Et supprimme l'ancienne
                .mcd.canvas.c delete [lindex $ligne 1]
                # Créé les textes des cardinalités
                #.mcd.canvas.c delete [dict get $textes_cardinalites $k]
                foreach {kk texte_cardinalite} $textes_cardinalites {
                    if {[lindex $texte_cardinalite 0] == $id_table && [lindex $texte_cardinalite 1] == $id_relation} {
                        .mcd.canvas.c delete [lindex $texte_cardinalite 2]
                        dict unset $textes_cardinalites $kk
                    }
                }
                dict set textes_cardinalites $k [list $id_table $id_relation [.mcd.canvas.c create text [expr ($x_arrivee + $x_origine) / 2] [expr ($y_arrivee + $y_origine) / 2] -text [Katyusha_Relations_cardinalite $id_relation $id_table] -tag [list "texte_cardinalite" $id_table]]]
            }
        }
    }
    # Mise à jour de l'affichage graphique
    update
}

##
# Détruit les lignes graphiques en lien avec une relation
# Et supprime leur liste du dictionnaire des lignes graphiques
##
proc Katyusha_Relations_suppression_lignes {id_relation} {
    global lignes_graphique
    global textes_cardinalites
    
    # Supprime les lignes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "relation"} {
            if {[lindex $ligne 3] == $id_relation} {
                .mcd.canvas.c delete [lindex $ligne 1]
                dict unset lignes_graphique $k
            }
        }
    }
    # Supprime les cardinalités
    foreach {kk texte_cardinalite} $textes_cardinalites {
        if {[lindex $texte_cardinalite 1] == $id_relation} {
            .mcd.canvas.c delete [lindex $texte_cardinalite 2]
             dict unset $textes_cardinalites $kk
        }
    }
}

##
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_Relations_ajout_attribut {nom type complement_type taille null valeur auto pk description {graphique 1}} {
    global relation_tmp
    global id_attribut_graphique
    global IMG
    global LOCALE
    
    set attributs [dict get $relation_tmp "attributs"]
    
    dict set attribut "nom" $nom
    dict set attribut "type" $type
    dict set attribut "complement_type" $complement_type
    dict set attribut "taille" $taille
    dict set attribut "null" $null
    dict set attribut "valeur" $valeur
    dict set attribut "auto" $auto
    dict set attribut "pk" $pk
    dict set attribut "description" $description
    
    set ids [dict keys $attributs]
    set id_attribut_graphique [expr [lindex $ids [expr [llength $ids] - 1]] + 1]
    dict set attributs $id_attribut_graphique $attribut
    
    dict set relation_tmp "attributs" $attributs
    
    if {$graphique == 1} {
        set f ".fen_ajout_relation"
        #
        frame $f.attributs.c.f.corps.$id_attribut_graphique
            label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text $nom -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.type -text $type -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text $taille -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text $valeur -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.auto -text $auto -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text $pk -width 20 -height 2 -background white -relief solid
            button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_attribut relation $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.auto $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.edit -side left
        pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
    }
    update
}

##
# Renvoie la cardinalité liant une table à une relation grâce à leurs ID
##
proc Katyusha_Relations_cardinalite {id_relation id_table} {
    global tables
    global relations
    
    set relation [dict get $relations $id_relation]
    set liens [dict get $relation "liens"]
    # Balaye les liens à la recherche de la bonne cardinalité
    foreach {k lien} $liens {
        set table [dict get [dict get $tables $id_table] "nom"]
        if {[lindex $lien 0] == $table} {
            set res [lindex $lien 1]
            if {[lindex $lien 2] == 1} {
                set res "($res)"
            }
        }
    }
    return $res
}

##
# Supprime l'attribut dont l'ID est passé en paramètre
##
proc Katyusha_Relations_suppression_attribut_relation {relation id_attribut {graphique 1}} {
    set relation [Katyusha_Entites_suppression_attribut $relation $id_attribut "relation" $graphique]
    return $relation
}

##
# Ajout d'un nouveau lien à la relation tomporaire
##
proc Katyusha_Relations_ajout_lien {table_liee lien relatif {graphique 1}} {
    global relation_tmp
    global LOCALE
    global IMG
    
    set liens [dict get $relation_tmp "liens"]
    set id_lien [dict size $liens]
    dict set liens $id_lien [list $table_liee $lien $relatif]
    dict set relation_tmp "liens" $liens

    if {$graphique == 1} {
        set f ".fen_ajout_relation"
        frame $f.liens.liste.corps.$id_lien
        label $f.liens.liste.corps.$id_lien.table -text $table_liee -width 20 -height 2 -background white -relief solid
        label $f.liens.liste.corps.$id_lien.type -text $lien -width 20 -height 2 -background white -relief solid
        label $f.liens.liste.corps.$id_lien.relatif -text $relatif -width 20 -height 2 -background white -relief solid
        button $f.liens.liste.corps.$id_lien.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_lien_relation $id_lien"
        pack $f.liens.liste.corps.$id_lien.table $f.liens.liste.corps.$id_lien.type $f.liens.liste.corps.$id_lien.relatif $f.liens.liste.corps.$id_lien.edit -side left
        pack $f.liens.liste.corps.$id_lien
    }
}

##
# Modifie un lien
##
proc Katyusha_Relations_modification_lien {id_lien table_liee lien relatif {graphique 1}} {
    global relation_tmp
    
    set liens [dict get $relation_tmp "liens"]
    dict set liens $id_lien [list $table_liee $lien $relatif]
    dict set relation_tmp "liens" $liens
    
    if {$graphique == 1} {
        set f ".fen_ajout_relation"
        $f.liens.liste.corps.$id_lien.table configure -text $table_liee
        $f.liens.liste.corps.$id_lien.type configure -text $lien
        $f.liens.liste.corps.$id_lien.relatif configure -text $relatif
    }
}

proc Katyusha_Relations_controle_relation {relation} {
    set ok 1
    
    return $ok
}

##
# Supprime la relation passée en paramètre
##
proc suppression_relation {relation} {
    global LOCALE
    global relations
    global relations_graphique
    # Récupère le nom de la relation
    set nom [dict get [dict get $relations $relation] "nom"]
    # Supprime la relation du tableau général
    dict unset relations $relation
    # Supprime l'affichage de la relation
    foreach c [dict get $relations_graphique $relation] {
        .mcd.canvas.c delete $c
    }
    # Supprime les lignes qui pointent vers la relation
    Katyusha_Relations_suppression_lignes $relation
    dict unset relations_graphique $relation
    maj_arbre_entites
    puts "Relation $nom supprimée"
    unset nom
}

##
# Initialise une relation
##
proc Katyusha_Relations_init_relation {} {
    global MCD
    
    set relation [dict create]
    dict set relation "attributs" [list]
    dict set relation "liens" [dict create]
    dict set relation "couleurs" [dict create "fond" $MCD(couleur_fond_relation) "ligne" $MCD(couleur_ligne_relation) "liens" $MCD(couleur_liens_relation) "texte" $MCD(couleur_texte_relation)]
    
    return $relation
}

##
# Modifie un attribut
##
proc Katyusha_Relations_modification_attribut {id_attribut nom type complement_type taille null valeur auto pk description {graphique 1}} {
    Katyusha_Entites_modification_attribut $id_attribut $nom $type $complement_type $taille $null $valeur $auto $pk $description "relation" $graphique
}

##
#
##
proc Katyusha_Relations_modification_nom_table {table ntable} {
    global relations
    
    set nom [dict get $table "nom"]
    set nnom [dict get $ntable "nom"]

    foreach {id relation} $relations {
        set liens [dict get $relation "liens"]
        foreach {k lien} $liens {
            if {[lindex $lien 0] == $nom} {
                # Enregistre les modifications des liens
                dict set liens $k [list $nnom [lindex $lien 1] [lindex $lien 2]]
                dict set relation "liens" $liens
                dict set relations $id $relation
            }
        }
    }
}

##
# Supprime dans toutes les relations les liens concernant une table par son ID
##
proc Katyusha_Relations_suppression_table_toutes {id_table} {
    global relations
    
    # Balaye les relations
    foreach {id relation} $relations {
        set liens [dict get $relation "liens"]
        # Balaye les liens
        foreach {k lien} $liens {
            # Récupère l'ID de la table du lien actuel par son nom
            set id_table_lien [Katyusha_Tables_ID_table [lindex $lien 0]]
            # Si les deux ID de table correspondent, on efface
            if {$id_table_lien == $id_table} {
                dict unset liens $k
                # Puis, réenregistre la relation
                dict set relation "liens" $liens
                dict set relations $id $relation
            }
        }
    }
}
