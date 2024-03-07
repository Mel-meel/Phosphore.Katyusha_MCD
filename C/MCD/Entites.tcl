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
        Katyusha_MCD_Objets_maj_arbre_objets
    }
}

##
# Retourne pour chaque élement des attributs, la plus grande taille de chaque
# Pas claire, description à revoir
##
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

##
# Formate les éléments des attributs en colonnes
# Exemple :
#    id     integer    12     0
#    nom    varchar    255    1
##
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
# Créé l'affichage graphique d'une table
##
proc Katyusha_Tables_creer_affichage_graphique {ID table} {
    global IMG
    global rpr
    global CONFIGS
    global ZONE_MCD
    global ENV
    
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
    set largeur_nom [expr ([string length $nom] * 10) + 20]
    set largeur_atts 0
    foreach {k el} $tailles_colones {
        set largeur_atts [expr $largeur_atts + $el]
    }
    set largeur_atts [expr ($largeur_atts * 10) + 90]
    
    if {$largeur_nom <= $largeur_atts} {
        set largeur $largeur_atts
    } else {
        set largeur $largeur_nom
    }
    
    # Créé l'affichage graphique de la nouvelle table dans une liste temporaire
    set x [lindex [dict get $table "coords"] 0]
    set y [lindex [dict get $table "coords"] 1]
    lappend graph [$ZONE_MCD.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_tete"] -tag [list table $ID]]
    lappend graph [$ZONE_MCD.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y - ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_corps"] -tag [list table $ID]]
    lappend graph [$ZONE_MCD.canvas.c create text [expr $x - (([string length $nom] * 7.5) / 2)] [expr $y - ($hauteur / 2) + 20] -fill [dict get $couleurs "texte"] -anchor w -text $nom -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list table $ID]]
    lappend graph [$ZONE_MCD.canvas.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2) + 40] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 40] -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond_tete"] -tag [list table $ID]]
    # Affiche les éléments des attributs selon la configuration
    set taille 0
    set x2 [expr $x - ($largeur / 2) + 10]
    foreach element $CONFIGS(AFFICHAGE_OBJETS) {
        set x2 [expr $x2 + ($taille * 10) + 10]
        # Pour palier au problème d'affichage de l'UTF8 avec TK, on créé ici
        # le symbole 🔑 en blanc si l'attribut est une clef primaire.
        # L'intérêt de l'afficher en blanc est que le symbole sera visible
        # lors de l'export en SVG.
        # Pour l'afficher sur le canvas, plus loin une image est collée par
        # dessus le symbole.
        if {$element == "pk"} {
            set col [dict get $couleurs "fond_tete"]
        } else {
            set col [dict get $couleurs "texte"]
        }
        set y2 [expr $y - ($hauteur / 2) + 40]
        foreach texte [split [dict get $colones $element] "\n"] {
            set y2 [expr $y2 + 18]
            lappend graph [$ZONE_MCD.canvas.c create text $x2 $y2 -fill [dict get $couleurs "texte"] -justify left -text $texte -fill $col -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list table $ID]]
        }
        set taille [dict get $tailles_colones $element]
    }
    # Créé les images de clefs primaires
    foreach pk $pks {
        lappend graph [$ZONE_MCD.canvas.c create image [expr $x - ($largeur / 2) + 25] [expr $y - ($hauteur / 2) + 40 + $pk] -image $IMG(pk) -tag [list table $ID]]
    }
    unset x y x2 y2 hauteur largeur nom table ID
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
# Ajoute une entité au MCD et appel la création de sa classes UML correspondante
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
    puts [phgt::mc "Ajout de l'entité : [dict get $table_tmp nom]"]
    
    # Créé la classe UML
    Katyusha_UML_Classes_creer_classe_depuis_entite $ID $table_tmp
    
    set ID [expr $ID + 1]
    #puts [.mcd.canvas.c coords [lindex $graph 0]]
    unset graph id
    # Met à jour l'arbre des entités
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
}

##
# Créé une entité depuis une classe UML
##
proc Katyusha_MCD_Entites_creer_entite_depuis_classe {id classe} {
    global classes
    global tables
    global tables_graphique
    
    set entite [Katyusha_Tables_init_table]
    
    dict set entite "nom" [dict get $classe "nom"]
    dict set entite "attributs" [dict get $classe "attributs"]
    dict set entite "coords" [dict get $classe "coords"]
    
    set graph [Katyusha_Tables_creer_affichage_graphique $id $entite]
    
    
    dict set tables $id $entite
    dict set tables_graphique $id $graph
    
    
    Katyusha_MCD_Objets_maj_arbre_objets
    
    unset graph id entite classe
}

##
# Enregistre les modifications d'une table
##
proc Katyusha_Tables_modification_table {id entite} {
    global tables
    global tables_graphique
    global ZONE_MCD
    
    # Supprime l'affichage de la table
    foreach c [dict get $tables_graphique $id] {
        $ZONE_MCD.canvas.c delete $c
    }
    Katyusha_Relations_modification_nom_table [dict get $tables $id] $entite
    dict set tables $id $entite
    dict unset tables_graphique $id
    Katyusha_Tables_modification_graphique $id $entite
    
    # Modifie la classe associée
    Katyusha_UML_Classes_maj_classe_depuis_entite $id $entite
    
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
}

##
# Supprime la table passée en paramètre
##
proc suppression_table {{table "null"}} {
    global tables
    global tables_graphique
    global id_entite
    global ZONE_MCD
    
    # Supprime les liens de la table dans toutes les relations
    Katyusha_Relations_suppression_table_toutes $table
    
    # Récupère le nom de la table
    set nom [dict get [dict get $tables $table] nom]
    # Supprime la table du tableau général
    dict unset tables $table
    # Supprime l'affichage de la table
    foreach c [dict get $tables_graphique $table] {
        $ZONE_MCD.canvas.c delete $c
    }
    # Supprime les lignes de la table
    Katyusha_Tables_suppression_lignes $table
    dict unset tables_graphique $table
    Katyusha_MCD_Objets_maj_arbre_objets
    puts [phgt::mc "Entité $nom supprimée"]
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
    global ZONE_MCD
    
    set id_graphique [lindex [dict get $tables_graphique $id_table] 0]
    set coords_g [$ZONE_MCD.canvas.c coords $id_graphique]
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
# Mise à jour des lignes entre une entité et les objets auxquels elle est reliée
##
proc Katyusha_Tables_MAJ_ligne_coords {id_entite coords} {
    global lignes_graphique
    global relations_graphique
    global heritages_graphique
    global textes_cardinalites
    global MCD
    global relations
    global ZONE_MCD
    
    
    set x [lindex $coords 0]
    set y [lindex $coords 1]
    set coords [Katyusha_Tables_coords_ID $id_entite]
    # Taille de la table en pixels
    set largeur_entite [expr [lindex $coords 4] - [lindex $coords 2]]
    set hauteur_entite [expr [lindex $coords 5] - [lindex $coords 3]]
    
    # Balayage des lignes à la recherche de celles concernants l'entité spécifiée
    foreach ligne [$ZONE_MCD.canvas.c find withtag "entite:$id_entite"] {
        set tags [$ZONE_MCD.canvas.c gettags $ligne]
        set type_ligne [lindex $tags 0]
        set k [lindex [split [lindex $tags 3] ":"] 1]
        set id_entite [lindex [split [lindex $tags 1] ":"] 1]
        set multiple [lindex [split [lindex $tags 4] ":"] 1]
        set n [lindex [split [lindex [split [lindex $tags 5] ":"] 1] "/"] 0]
        set nombre_liens [lindex [split [lindex [split [lindex $tags 5] ":"] 1] "/"] 1]
        # Créé les nouvelles coordonnées :
        # Lignes des relations
        if {$type_ligne == "ligne_association"} {
            set id_association [lindex [split [lindex $tags 2] ":"] 1]
            
            
            # Détermine les coordonnées des lignes à tracer
            set id_graphique [lindex [dict get $relations_graphique $id_association] 0]
            set coords_association_lien [$ZONE_MCD.canvas.c coords $id_graphique]
            # Taille de la relation en pixels
            set largeur_association [expr [lindex $coords_association_lien 2] - [lindex $coords_association_lien 0]]
            set hauteur_association [expr [lindex $coords_association_lien 3] - [lindex $coords_association_lien 1]]
            # Créé les nouvelles coordonnées
            
            set x_origine [expr [lindex $coords_association_lien 2] - ($largeur_association / 2)]
            set y_origine [expr [lindex $coords_association_lien 1] + ($hauteur_association / 2)]
            
            if {$multiple == 0} {
                set x_arrivee [expr [lindex $coords 2] + ($largeur_entite / 2)]
                set y_arrivee [expr [lindex $coords 3] + ($hauteur_entite / 2)]
            } else {
                set x_arrivee [expr [lindex $coords 2] + ($largeur_entite / 2)]
                set y_arrivee [expr [lindex $coords 3] + ($n * ($hauteur_entite / ($nombre_liens + 1)))]
            }
            
            # Créé la nouvelle ligne
            dict set lignes_graphique $k [list "entite" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list "ligne_association" "entite:$id_entite" "association:$id_association" "ligne:$k" "multiple:$multiple" "n:$n/$nombre_liens" "ligne"]] $id_entite $id_association]
            
            # Texte des cardinalités, temporaire à revoir
            foreach {kk texte_cardinalite} $textes_cardinalites {
                if {[lindex $texte_cardinalite 0] == $id_entite && [lindex $texte_cardinalite 1] == $id_association} {
                    $ZONE_MCD.canvas.c delete [lindex $texte_cardinalite 2]
                     dict unset $textes_cardinalites $kk
                }
            }
            dict set textes_cardinalites $k [list $id_entite $id_association [$ZONE_MCD.canvas.c create text [expr ($x_arrivee + $x_origine) / 2] [expr ($y_arrivee + $y_origine) / 2] -text [Katyusha_Relations_cardinalite $id_association $id_entite] -tag [list "texte_cardinalite" $id_entite]]]
            
        } elseif {$type_ligne == "ligne_heritage_mere"} {
            set id_heritage [lindex [split [lindex $tags 2] ":"] 1]
            
            # Détermine les coordonnées du triangle de l'héritage
            set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
            set coords_heritage [$ZONE_MCD.canvas.c coords $id_graphique]
            
            # Pour la table mere, on part du haut du triangle
            set x_arrivee [lindex $coords_heritage 4]
            set y_arrivee [lindex $coords_heritage 5]
            
            # Les coordonnées d'arrivées sont au milieu bas de la table mère
            set x_origine [expr [lindex $coords 2] + ($largeur_entite / 2)]
            set y_origine [lindex $coords 5]
            
            dict set lignes_graphique $k [list "heritage_mere" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow first -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_mere" "entite:$id_entite" "heritage:$id_heritage" "ligne:$k" "ligne"]] $id_entite $id_heritage]
        } elseif {$type_ligne == "ligne_heritage_fille"} {
            set id_heritage [lindex [split [lindex $tags 2] ":"] 1]
            
            # Détermine les coordonnées du triangle de l'héritage
            set id_graphique [lindex [dict get $heritages_graphique $id_heritage] 0]
            set coords_heritage [$ZONE_MCD.canvas.c coords $id_graphique]
            
            # Pour la table fille, on part du bas du triangle
            if {[lindex $coords_heritage 0] > [lindex $coords 2]} {
                set x_arrivee [lindex $coords_heritage 0]
            } elseif {[lindex $coords_heritage 2] < [lindex $coords 0]} {
                set x_arrivee [lindex $coords_heritage 2]
            } else {
                set x_arrivee [lindex $coords_heritage 4]
            }
            set y_arrivee [lindex $coords_heritage 1]
            
            # Les coordonnées d'arrivées sont au milieu haut de la table fille
            set x_origine [expr [lindex $coords 2] + ($largeur_entite / 2)]
            set y_origine [lindex $coords 3]
            
            dict set lignes_graphique $k [list "heritage_fille" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -arrow first -arrowshape [list 10 11 4] -width 2 -dash [list 15 5] -fill $MCD(couleur_liens_heritage) -tag [list "ligne_heritage_fille" "entite:$id_entite" "heritage:$id_heritage" "ligne:$k" "ligne"]] $id_entite $id_heritage]
        }
        # Passe la ligne dessous
        $ZONE_MCD.canvas.c lower [lindex [dict get $lignes_graphique $k] 1] "table"
        # Et supprimme l'ancienne
        $ZONE_MCD.canvas.c delete $ligne
    }
}


##
# Détruit les lignes graphiques en lien avec une table
# Et supprime leur liste du dictionnaire des lignes graphiques
##
proc Katyusha_Tables_suppression_lignes {id_table} {
    global lignes_graphique
    global textes_cardinalites
    global ZONE_MCD
    
    # SUpprime les lignes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "association"} {
            if {[lindex $ligne 2] == $id_table} {
                $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                dict unset lignes_graphique $k
            }
        }
    }
    # Supprime les cardinalités
    foreach {kk texte_cardinalite} $textes_cardinalites {
        if {[lindex $texte_cardinalite 0] == $id_table} {
            $ZONE_MCD.canvas.c delete [lindex $texte_cardinalite 2]
             dict unset $textes_cardinalites $kk
        }
    }
}

proc Katyusha_Tables_controle_table {table} {
    set ok 1
    
    return $ok
}

##
# Contrôle les éléments de l'attribut à ajouter
##
proc Katyusha_Tables_controle_attribut {nom type signe complement_type taille null valeur auto pk unique acces description} {
    set ok 1
    # Contrôle avant acceptation
    if {$nom == ""} {
        set ok 0
    }
    if {[lsearch -exact [Katyusha_SQL_liste_types] $type] < 0} {
        set ok 0
    }
    if {$signe != 0 && $signe != 1} {
        set ok 0
    }
    #if {[string first "," $taille] == -1} {
    #    if {$taille < 0 || $taille > 255} {
    #        set ok 0
    #    }
    #} else {
    #    foreach t set taille1 [split $taille ","] {
    #        if {$t < 0 || $t > 255} {
    #            set ok 0
    #        }
    #    }
    #}
    if {$auto != 0 && $auto != 1} {
        set ok 0
    }
    if {$pk != 0 && $pk != 1} {
        set ok 0
    }
    if {$unique != 0 && $unique != 1} {
        set ok 0
    }
    
    return $ok
}

##
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_Tables_ajout_attribut {nom type nsigne complement_type taille null valeur auto pk unique acces description {graphique 1}} {
    global table_tmp
    global IMG
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set background [Katyusha_Configurations_couleurs "-frame"]
    
    set attributs [dict get $table_tmp "attributs"]
    
    dict set attribut "nom" $nom
    dict set attribut "type" $type
    dict set attribut "signe" $nsigne
    dict set attribut "complement_type" $complement_type
    dict set attribut "taille" $taille
    dict set attribut "null" $null
    dict set attribut "valeur" $valeur
    dict set attribut "auto" $auto
    dict set attribut "pk" $pk
    dict set attribut "unique" $unique
    dict set attribut "acces" $acces
    dict set attribut "description" ""
    
    set ids [dict keys $attributs]
    set id_attribut_graphique [expr [lindex $ids [expr [llength $ids] - 1]] + 1]
    dict set attributs $id_attribut_graphique $attribut
    
    dict set table_tmp "attributs" $attributs
    
    if {$graphique == 1} {
        set f ".fen_ajout_table"
        #
        frame $f.attributs.c.f.corps.$id_attribut_graphique
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text $nom -width 30 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.type -text $type -width 15 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.signe -text $nsigne -width 10 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text $taille -width 10 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text $valeur -width 20 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.auto -text $auto -width 15 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text $pk -width 10 -background $background  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.unique -text $unique -width 10 -background $background  -relief solid
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps table $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps table $id_attribut_graphique [expr $id_attribut_graphique + 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text [phgt::mc "Éditer"] -image $IMG(editer) -command "Katyusha_MCD_INTERFACE_Objets_ajout_attribut table $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.signe $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.auto $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.unique $f.attributs.c.f.corps.$id_attribut_graphique.haut $f.attributs.c.f.corps.$id_attribut_graphique.bas $f.attributs.c.f.corps.$id_attribut_graphique.edit -fill both -expand 1 -side left
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
    
    set entite [dict create]
    dict set entite "attributs" [dict create]
    dict set entite "description" ""
    dict set entite "couleurs" [dict create "fond_tete" $MCD(couleur_fond_tete_table) "ligne" $MCD(couleur_ligne_table) "fond_corps" $MCD(couleur_fond_corps_table) "texte" $MCD(couleur_texte_table)]
    
    return $entite
}

##
# Modifie un attribut
##
proc Katyusha_Tables_modification_attribut {id_attribut nom type nsigne complement_type taille null valeur auto pk unique acces description {graphique 1}} {
    Katyusha_Objets_modification_attribut $id_attribut $nom $type $nsigne $complement_type $taille $null $valeur $auto $pk $unique $acces $description "table" $graphique
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
