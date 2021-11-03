## Créé le 3/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
#
##
proc maj_tables {} {
    global tables
    global tables_graphique
    foreach {id table} $tables {
        #set ID $id
        set graph [Katyusha_Tables_creer_affichage_graphique $id $table]
        # Ajoute la liste temporaire au dictionnaire graphique des tables
        dict set tables_graphique $id $graph
        puts "Ajout de la table : [dict get $table nom]"
        unset graph id table
        # Met à jour l'arbre des entités
        maj_arbre_entites
    }
}

proc Katyusha_Tables_creer_texte_affichage_graphique_taille_colones {attributs} {
	global CONFIGS
	
    foreach el $CONFIGS(AFFICHAGE_OBJETS) {
		dict set tailles $el 0
	}
    
    foreach {k attribut} $attributs {
        foreach element $CONFIGS(AFFICHAGE_OBJETS) {
            set valeur [dict get $attribut $element]
            if {$element == "null"} {
                if {$valeur == 0} {
                    set valeur "not null"
                } else {
                    set valeur ""
                }
            } elseif {$element == "pk"} {
                if {$valeur == 0} {
                    set valeur ""
                } else {
                    set valeur "PK"
                }
            }
            if {[dict get $tailles $element] < [string length $valeur]} {
                dict set tailles $element [string length $valeur]
            }
        }
    }
    return $tailles
}

proc Katyusha_Tables_creer_affichage_graphique_format_colones {attributs} {
	global CONFIGS
	
    foreach el $CONFIGS(AFFICHAGE_OBJETS) {
		dict set colones $el ""
	}
	
    # Balayage des attributs
    foreach {k attribut} $attributs {
        foreach element $CONFIGS(AFFICHAGE_OBJETS) {
            set valeur [dict get $attribut $element]
            if {$element == "null"} {
                if {$valeur == 0} {
                    set valeur "not null"
                } else {
                    set valeur ""
                }
            } elseif {$element == "pk"} {
                if {$valeur == 0} {
                    set valeur ""
                } else {
                    set valeur "🔑"
                }
            }
            set texte_element "[dict get $colones $element]$valeur\n"
            dict set colones $element $texte_element
        }
    }
    return $colones
}

##
# Créé le texte de l'affichage graphique d'une table
# Ancienne version
##
proc Katyusha_Tables_creer_texte_affichage_graphique {table} {
    set texte [list]
    set attributs [dict get $table "attributs"]
    # Détermine la taille des colones
    set tailles_colones [Katyusha_Tables_creer_texte_affichage_graphique_taille_colones $attributs]
    set colones [Katyusha_Tables_creer_affichage_graphique_format_colones $attributs]
    foreach {k colone} $colones {
        set nom_colone [dict get $colone "nom"]
        set type_colone [dict get $colone "type"]
        set valeur_colone [dict get $colone "null"]
    }

    return $texte
}

##
# Créé l'affichage graphique d'une table
##
proc Katyusha_Tables_creer_affichage_graphique {ID table} {
    global IMG
    global rpr
    global CONFIGS
    
    # Récupère le nom de la table
    set nom [dict get $table "nom"]
    # Créé le texte d'affichage des attributs
    set texte_attributs ""
    set hauteur 18
    set pks [list]
    set attributs [dict get $table "attributs"]
    set couleurs [dict get $table "couleurs"]
    # Détermine la taille des colones
    set tailles_colones [Katyusha_Tables_creer_texte_affichage_graphique_taille_colones $attributs]
    set colones [Katyusha_Tables_creer_affichage_graphique_format_colones $attributs]
    foreach {k v} $attributs {
        if {[dict get $v "pk"] == 1} {
            lappend pks $hauteur
        }
        set hauteur [expr $hauteur + 18]
    }
    # Calcul la taille de la table sur le canvas
    set largeur 0
    foreach {k el} $tailles_colones {
		set largeur [expr $largeur + $el]
    }
    set largeur [expr ($largeur * 10) + 90]
    # Créé l'affichage graphique de la nouvelle table dans une liste temporaire
    set x [lindex [dict get $table "coords"] 0]
    set y [lindex [dict get $table "coords"] 1]
    lappend graph [.mcd.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_tete"] -tag [list table $ID]]
    if [dict exists $colones "pk"] {
		lappend graph [.mcd.canvas.c create text [expr $x - ($largeur / 2) + 20] [expr $y + 50] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones "pk"] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list table $ID]]
	}
    lappend graph [.mcd.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_tete"] -tag [list table $ID]]
    lappend graph [.mcd.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y - ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_corps"] -tag [list table $ID]]
    lappend graph [.mcd.canvas.c create text [expr $x - (([string length $nom] * 7.5) / 2)] [expr $y - ($hauteur / 2) + 20] -fill [dict get $couleurs "texte"] -anchor w -text $nom -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list table $ID]]
    lappend graph [.mcd.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2) + 40] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_tete"] -tag [list table $ID]]
    # Affiche les éléments des attributs selon la configuration
    set taille 0
    set x2 [expr $x - ($largeur / 2) + 50]
    puts $colones
    puts $tailles_colones
    foreach element $CONFIGS(AFFICHAGE_OBJETS) {
		set x2 [expr $x2 + ($taille * 10) + 10]
		lappend graph [.mcd.canvas.c create text $x2 [expr $y + 50] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones $element] -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list table $ID]]
		set taille [dict get $tailles_colones $element]
	}
    # Créé les images de clefs primaires
    foreach pk $pks {
        lappend graph [.mcd.canvas.c create image [expr $x - ($largeur / 2) + 25] [expr $y - ($hauteur / 2) + 40 + $pk] -image $IMG(pk) -tag [list table $ID]]
    }
    unset x y hauteur largeur nom table ID
    return $graph
}

proc Katyusha_Tables_modification_graphique {id table} {
    global tables
    global tables_graphique
    
    set graph [Katyusha_Tables_creer_affichage_graphique $id $table]
    # Ajoute la liste temporaire au dictionnaire graphique des tables
    dict set tables_graphique $id $graph
    Katyusha_Tables_MAJ_ligne_coords $id ""
}

##
# Ajoute une table
##
proc ajout_table {table_tmp} {
    # Charge la variable globale contenant toutes les tables
    global tables
    global tables_graphique
    global ID
    # Créé un id pour la nouvelle table
    set id [expr [dict size $tables]]
    # Ajoute la nouvelle table aux tables existantes
    dict set tables $ID $table_tmp
    set graph [Katyusha_Tables_creer_affichage_graphique $ID $table_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des tables
    dict set tables_graphique $ID $graph
    puts "Ajout de la table : [dict get $table_tmp nom]"
    set ID [expr $ID + 1]
    #puts [.mcd.canvas.c coords [lindex $graph 0]]
    unset graph id
    # Met à jour l'arbre des entités
    maj_arbre_entites
    Katyusha_Historique_maj
}

##
# Enregistre les modifications d'une table
##
proc Katyusha_Tables_modification_table {id table} {
    global tables
    global tables_graphique
    
    # Supprime l'affichage de la table
    foreach c [dict get $tables_graphique $id] {
        .mcd.canvas.c delete $c
    }
    Katyusha_Relations_modification_nom_table [dict get $tables $id] $table
    dict set tables $id $table
    dict unset tables_graphique $id
    Katyusha_Tables_modification_graphique $id $table
    maj_arbre_entites
    Katyusha_Historique_maj
}

##
# Supprime la table passée en paramètre
##
proc suppression_table {{table "null"}} {
    global LOCALE
    global tables
    global tables_graphique
    global id_entite
    
    # Supprime les liens de la table dans toutes les relations
    Katyusha_Relations_suppression_table_toutes $table
    
    # Récupère le nom de la table
    set nom [dict get [dict get $tables $table] nom]
    # Supprime la table du tableau général
    dict unset tables $table
    # Supprime l'affichage de la table
    foreach c [dict get $tables_graphique $table] {
        .mcd.canvas.c delete $c
    }
    # Supprime les lignes de la table
    Katyusha_Tables_suppression_lignes $table
    dict unset tables_graphique $table
    maj_arbre_entites
    puts "Table $nom supprimée"
    unset nom
}

##
# Détermine la taille en nombre de caractères d'une table pour l'affichage graphique
##
proc Katyusha_Tables_taille_table_graphique {table} {
    set taille 0
    set taille [string length [dict get $table "nom"]]
    set attributs [dict get $table "attributs"]
    foreach {k attribut} $attributs {
        set taille_tmp [string length "[dict get $attribut nom] | [dict get $attribut type]"]
        if {$taille_tmp > $taille} {
            set taille $taille_tmp
        }
    }
    return $taille
}

##
# Trouve l'ID d'une table par son nom
##
proc Katyusha_Tables_ID_table {nom_table} {
    global tables
    
    set id -1
    foreach {k table} $tables {
        set nom_table_tmp [dict get $table "nom"]
        if {$nom_table_tmp == $nom_table} {
            set id $k
        }
    }
    return $id
}

##
# Retourne les coordonnées de l'affichage graphique d'une table par son ID
# Ancienne version
##
proc Katyusha_Tables_coords_ID_a {id_table} {
    global tables
    set table [dict get $tables $id_table]
    set coords [dict get $table "coords"]
    return $coords
}

##
# Retourne les coordonnées de l'affichage graphique d'une table par son ID
##
proc Katyusha_Tables_coords_ID {id_table} {
    global tables
    global tables_graphique
    
    set id_graphique [lindex [dict get $tables_graphique $id_table] 0]
    set coords_g [.mcd.canvas.c coords $id_graphique]
    set table [dict get $tables $id_table]
    set coords [dict get $table "coords"]
    lappend coords [lindex $coords_g 0]
    lappend coords [lindex $coords_g 1]
    lappend coords [lindex $coords_g 2]
    lappend coords [lindex $coords_g 3]
    return $coords
}


##
# Met à jour les coordonnées d'une table par son ID
##
proc Katyusha_Tables_MAJ_coords {id_table coords} {
    global tables
    set table [dict get $tables $id_table]
    dict set table "coords" $coords
    dict set tables $id_table $table
}

##
# Mise à jour des lignes entre une table et les objets auxquels elle est reliée
# À revoir entièrement, procédure trop longue, pas assez performantes
##
proc Katyusha_Tables_MAJ_ligne_coords {id_table coords} {
    global lignes_graphique
    global relations_graphique
    global heritages_graphique
    global textes_cardinalites
    global MCD
    
    set x [lindex $coords 0]
    set y [lindex $coords 1]
    set coords [Katyusha_Tables_coords_ID $id_table]
    # Taille de la table en pixels
    set largeur_table [expr [lindex $coords 4] - [lindex $coords 2]]
    set hauteur_table [expr [lindex $coords 5] - [lindex $coords 3]]
    
    # Balayage des lignes à la recherche de celles concernants la table spécifiée
    foreach {k ligne} $lignes_graphique {
        # Lignes des relations
        if {[lindex $ligne 0] == "relation"} {
        set id_table_tmp [lindex $ligne 2]
        if {$id_table_tmp == $id_table} {
            set id_relation [lindex $ligne 3]
            # Détermine les coordonnées des lignes à tracer
            set id_graphique [lindex [dict get $relations_graphique $id_relation] 0]
            set coords_relation_lien [.mcd.canvas.c coords $id_graphique]
            # Taille de la relation en pixels
            set largeur_relation [expr [lindex $coords_relation_lien 2] - [lindex $coords_relation_lien 0]]
            set hauteur_relation [expr [lindex $coords_relation_lien 3] - [lindex $coords_relation_lien 1]]
            # Récupère les anciennes coordonnées de la ligne
            set acoords [.mcd.canvas.c coords [lindex $ligne 1]]
            # Créé les nouvelles coordonnées
            set ncoords [list $x $y [lindex $acoords 2] [lindex $acoords 3]]
            #set id_relation [lindex $ligne 1]
            set x_origine [lindex $ncoords 0]
            set y_origine [lindex $ncoords 1]
            set x_arrivee [lindex $ncoords 2]
            set y_arrivee [lindex $ncoords 3]
            if {[lindex $coords_relation_lien 2] < [lindex $coords 2]} {
                set x_origine [lindex $coords_relation_lien 2]
                set y_origine [expr [lindex $coords_relation_lien 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords 2]
                set y_arrivee [expr [lindex $coords 3] + ($hauteur_table / 2)]
            } elseif {[lindex $coords_relation_lien 0] > [lindex $coords 4]} {
                set x_origine [lindex $coords_relation_lien 0]
                set y_origine [expr [lindex $coords_relation_lien 1] + ($hauteur_relation / 2)]
                set x_arrivee [lindex $coords 4]
                set y_arrivee [expr [lindex $coords 3] + ($hauteur_table / 2)]
            } else {
                if {[lindex $coords_relation_lien 1] > [lindex $coords 5]} {
                    set x_origine [expr [lindex $coords_relation_lien 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords_relation_lien 1]
                    set x_arrivee [expr [lindex $coords 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords 5]
                } elseif {[lindex $coords_relation_lien 3] < [lindex $coords 3]} {
                    set x_origine [expr [lindex $coords_relation_lien 0] + ($largeur_relation / 2)]
                    set y_origine [lindex $coords_relation_lien 3]
                    set x_arrivee [expr [lindex $coords 4] - ($largeur_table / 2) ]
                    set y_arrivee [lindex $coords 3]
                }
            }
            # Si la table est par dessus l'objet ou touche l'objet auquel elle est liée, pas de ligne
            if {$x_origine != "" && $y_origine != "" && $x_arrivee != "" && $y_arrivee != ""} {
                # Créé la nouvelle ligne
                dict set lignes_graphique $k [list "relation" [.mcd.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list ligne $id_table]] $id_table $id_relation]
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
        
        ##
        # Si la table est table mère d'un héritage
        ##
        } elseif {[lindex $ligne 0] == "heritage_mere"} {
            set id_table_mere [lindex $ligne 2]
            set id_heritage [lindex $ligne 3]
            if {$id_table == $id_table_mere} {
                # Détermine les coordonnées du triangle de l'héritage
                set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
                set coords_heritage [.mcd.canvas.c coords $id_graphique]
                
                # Pour la table mere, on part du haut du triangle
                set x_origine [lindex $coords_heritage 4]
                set y_origine [lindex $coords_heritage 5]
                
                # Les coordonnées d'arrivées sont au milieu bas de la table mère
                set x_arrivee [expr [lindex $coords 2] + ($largeur_table / 2)]
                set y_arrivee [lindex $coords 5]
                
                dict set lignes_graphique $k [list "heritage_mere" [.mcd.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow last -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list ligne_heritage $id_table_mere $id_heritage]] $id_table_mere $id_heritage]
                # Et supprimme l'ancienne
                .mcd.canvas.c delete [lindex $ligne 1]
            }
        
        ##
        # Si la table est table fille d'un héritage
        ##
        } elseif {[lindex $ligne 0] == "heritage_fille"} {
            set id_table_fille [lindex $ligne 2]
            set id_heritage [lindex $ligne 3]
            if {$id_table == $id_table_fille} {
                # Détermine les coordonnées du triangle de l'héritage
                set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
                set coords_heritage [.mcd.canvas.c coords $id_graphique]
                
                # Pour la table fille, on part du bas du triangle
                if {[lindex $coords_heritage 0] > [lindex $coords 2]} {
                    set x_origine [lindex $coords_heritage 0]
                } elseif {[lindex $coords_heritage 2] < [lindex $coords 0]} {
                    set x_origine [lindex $coords_heritage 2]
                } else {
                    set x_origine [lindex $coords_heritage 4]
                }
                set y_origine [lindex $coords_heritage 1]
                
                # Les coordonnées d'arrivées sont au milieu haut de la table fille
                set x_arrivee [expr [lindex $coords 2] + ($largeur_table / 2)]
                set y_arrivee [lindex $coords 3]
                
                dict set lignes_graphique $k [list "heritage_fille" [.mcd.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow first -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list ligne_heritage $id_table_fille $id_heritage]] $id_table_fille $id_heritage]
                # Et supprimme l'ancienne
                .mcd.canvas.c delete [lindex $ligne 1]
            }

        }
    }
    # Mise à jour de l'affichage graphique
    update
}

##
# Détruit les lignes graphiques en lien avec une table
# Et supprime leur liste du dictionnaire des lignes graphiques
##
proc Katyusha_Tables_suppression_lignes {id_table} {
    global lignes_graphique
    global textes_cardinalites
    
    # SUpprime les lignes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "relation"} {
            if {[lindex $ligne 2] == $id_table} {
                .mcd.canvas.c delete [lindex $ligne 1]
                dict unset lignes_graphique $k
            }
        }
    }
    # Supprime les cardinalités
    foreach {kk texte_cardinalite} $textes_cardinalites {
        if {[lindex $texte_cardinalite 0] == $id_table} {
            .mcd.canvas.c delete [lindex $texte_cardinalite 2]
             dict unset $textes_cardinalites $kk
        }
    }
}

proc Katyusha_Tables_controle_table {table} {
    set ok 1
    
    return $ok
}

##
# TODO : contrôle du complément de type
##
proc Katyusha_Tables_controle_attribut {nom type complement_type taille null valeur auto pk description} {
    set ok 1
    # Contrôle avant acceptation
    if {$nom == ""} {
        set ok 0
    }
    if {[lsearch -exact [Katyusha_SQL_liste_types] $type] < 0} {
        set ok 0
    }
    if {[string first "," $taille] == -1} {
        if {$taille < 0 || $taille > 255} {
            set ok 0
        }
    } else {
        foreach t set taille1 [split $taille ","] {
            if {$t < 0 || $t > 255} {
                set ok 0
            }
        }
    }
    if {$valeur == ""} {
        set ok 0
    }
    if {$auto != 0 && $auto != 1} {
        set ok 0
    }
    if {$pk != 0 && $pk != 1} {
        set ok 0
    }
    
    return $ok
}

##
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_Tables_ajout_attribut {nom type complement_type taille null valeur auto pk description {graphique 1}} {
    global table_tmp
    global IMG
    global LOCALE
    
    set attributs [dict get $table_tmp "attributs"]
    
    dict set attribut "nom" $nom
    dict set attribut "type" $type
    dict set attribut "complement_type" $complement_type
    dict set attribut "taille" $taille
    dict set attribut "null" $null
    dict set attribut "valeur" $valeur
    dict set attribut "auto" $auto
    dict set attribut "pk" $pk
    dict set attribut "description" ""
    
    set ids [dict keys $attributs]
    set id_attribut_graphique [expr [lindex $ids [expr [llength $ids] - 1]] + 1]
    dict set attributs $id_attribut_graphique $attribut
    
    dict set table_tmp "attributs" $attributs
    
    if {$graphique == 1} {
        set f ".fen_ajout_table"
        #
        frame $f.attributs.c.f.corps.$id_attribut_graphique
            label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text $nom -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.type -text $type -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text $taille -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text $valeur -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.auto -text $auto -width 20 -height 2 -background white -relief solid
            label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text $pk -width 20 -height 2 -background white -relief solid
            button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text $LOCALE(editer) -image $IMG(editer) -command "INTERFACE_ajout_attribut table $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.auto $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.edit -side left
        pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
        
        update
    }
}

##
# Supprimme un attribut d'une table
##
proc Katyusha_Tables_suppression_attribut_table {table id_attribut {graphique 1}} {
    set table [Katyusha_Entites_suppression_attribut $table $id_attribut "table" $graphique]
    return $table
}

##
# Initialise une table
##
proc Katyusha_Tables_init_table {} {
    global MCD
    
    set table [dict create]
    dict set table "attributs" [dict create]
    dict set table "couleurs" [dict create "fond_tete" $MCD(couleur_fond_tete_table) "ligne" $MCD(couleur_ligne_table) "fond_corps" $MCD(couleur_fond_corps_table) "texte" $MCD(couleur_texte_table)]
    
    return $table
}

##
# Modifie un attribut
##
proc Katyusha_Tables_modification_attribut {id_attribut nom type complement_type taille null valeur auto pk description {graphique 1}} {
    Katyusha_Entites_modification_attribut $id_attribut $nom $type $complement_type $taille $null $valeur $auto $pk $description "table" $graphique
}

##
# Retourne le dernier ID des tables
##
proc Katyusha_Tables_dernier_id {tables} {
    set id 0
    foreach {k table} $tables {
        set id $k
    }
    return $id
}
