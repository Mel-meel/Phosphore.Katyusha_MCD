## Créé le 3/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Met à jour l'affichage graphique des associations (après le chargement d'un projet par exemple)
##
proc Katyusha_Relations_maj {} {
    global relations
    global relations_graphique
    foreach {id relation} $relations {
        set graph [Katyusha_Relations_creer_affichage_graphique $id $relation]
        # Ajoute la liste temporaire au dictionnaire graphique des associations
        dict set relations_graphique $id $graph
        puts "Ajout de la relation : [dict get $relation nom]"
        # Créé les lignes reliant l'association aux entités concernées
        #Katyusha_Relations_lignes_relation_tables $relation $id
        Katyusha_Relations_MAJ_ligne_coords $id [list]
        unset graph id relation
        # Met à jour l'arbre des entités
        Katyusha_MCD_Objets_maj_arbre_objets
    }
}

##
# Met à jour les lignes reliant les associations aux entités
##
proc Katyusha_Relations_MAJ_lignes_relations {} {
    global relations
    foreach {k relation} $relations {
        Katyusha_Relations_lignes_relation_tables $relation $k
    }
}

##
# Créé l'affichage graphique d'une association
##
proc Katyusha_Relations_creer_affichage_graphique {ID relation} {
    global rpr
    global IMG
    global CONFIGS
    global ZONE_MCD
    
    # Récupère le nom de l'association
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
    # Calcul la taille de l'association sur le canvas
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
    
    # Créé l'affichage graphique de la nouvelle association dans une liste temporaire
    set x [lindex [dict get $relation "coords"] 0]
    set y [lindex [dict get $relation "coords"] 1]
    
    lappend graph [$ZONE_MCD.canvas.c create oval [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2) + 30] -width 2 -outline [dict get $couleurs "ligne"] -fill [dict get $couleurs "fond"] -tag [list relation $ID]]
    lappend graph [$ZONE_MCD.canvas.c create text [expr $x - (([string length $nom] * 7.5) / 2)] [expr $y - ($hauteur / 2) + 20] -fill [dict get $couleurs "texte"] -anchor w -text $nom -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
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
            set col [dict get $couleurs "fond"]
        } else {
            set col [dict get $couleurs "texte"]
        }
        lappend graph [$ZONE_MCD.canvas.c create text $x2 [expr $y + 30] -fill [dict get $couleurs "texte"] -justify left -text [dict get $colones $element] -fill $col -anchor w -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list relation $ID]]
        set taille [dict get $tailles_colones $element]
    }
    # Créé les images de clefs primaires
    foreach pk $pks {
        lappend graph [$ZONE_MCD.canvas.c create image [expr $x - ($largeur / 2) + 25] [expr $y - ($hauteur / 2) + 30 + $pk] -image $IMG(pk) -tag [list relation $ID]]
    }
    unset x y hauteur largeur nom relation ID
    return $graph
}

##
# Détermine la taille en nombre de caractères d'une association pour l'affichage graphique
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
# Ajout d'une association entre plusieurs entités
##
proc Katyusha_ajout_relation {relation_tmp} {
    # Charge les variables nécessaires à l'ajout d'une nouvelle association
    global relations
    global relations_graphique
    global ID
    # Créé un id pour la nouvelle association
    set id [expr [dict size $relations]]
    # Récupère le nom de l'association
    set nom [dict get $relation_tmp nom]
    # Si le nom est vide
    if {$nom == ""} {
        set nom "Relation_$id"
        dict set relation_tmp "nom" $nom
        dict unset $relation_tmp "id"
    }
    # Ajoute la nouvelle association aux associations existantes
    dict set relations $ID $relation_tmp
    # Créé le texte d'affichage des attributs
    set texte_attributs ""
    set hauteur 20
    # Calcul la taille de l'association sur le canvas
    set largeur [expr ([string length $nom] * 8) + 50]
    # Créé l'affichage graphique de la nouvelle association
    set graph [Katyusha_Relations_creer_affichage_graphique $ID $relation_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des entités
    dict set relations_graphique $ID $graph
    # Trace les lignes pour plus de visibilité
    Katyusha_Relations_lignes_relation_tables $relation_tmp $ID
    Katyusha_Relations_MAJ_ligne_coords $ID [dict get $relation_tmp "coords"]
    puts "Ajout de la relation : [dict get $relation_tmp nom]"
    set ID [expr $ID + 1]
    unset graph relation_tmp nom hauteur largeur texte_attributs
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
}

proc Katyusha_Relations_modification_graphique {id relation} {
    global relations
    global relations_graphique
    
    set graph [Katyusha_Relations_creer_affichage_graphique $id $relation]
    # Ajoute la liste temporaire au dictionnaire graphique des relations
    dict set relations_graphique $id $graph
    Katyusha_Historique_maj
}

##
# Enregistre les modifications d'une association
##
proc Katyusha_Relations_modification_relation {id relation} {
    global relations
    global lignes_graphique
    global textes_cardinalites
    global ZONE_MCD
    
    suppression_relation $id
    dict set relations $id $relation
    Katyusha_Relations_modification_graphique $id $relation
    # Recalcul les lignes entre la relation et les entités concernées
    foreach {k ligne} $lignes_graphique {
        set id_relation_tmp [lindex $ligne 2]
        if {$id == $id_relation_tmp} {
            $ZONE_MCD.canvas.c delete [lindex $ligne 0]
            dict unset lignes_graphique $k
            dict unset textes_cardinalites $k
        }
    }
    Katyusha_Relations_lignes_relation_tables $relation $id
    Katyusha_MCD_Objets_maj_arbre_objets
    Katyusha_Historique_maj
}

##
# Met à jour les coordonnées d'une association par son ID
##
proc Katyusha_Relations_MAJ_coords {id_relation coords} {
    global relations
    set relation [dict get $relations $id_relation]
    dict set relation "coords" $coords
    dict set relations $id_relation $relation
}

##
# Créé les lignes reliant l'association aux entités qu'elle concerne
##
proc Katyusha_Relations_lignes_relation_tables {relation id_relation} {
    global relations
    global relations_graphique
    global lignes_graphique
    global textes_cardinalites
    global MCD
    global ZONE_MCD
    
    # Détermine les coordonnées des lignes à tracer
    set id_graphique [lindex [dict get $relations_graphique $id_relation] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    # Taille de la relation en pixels
    set largeur_relation [expr [lindex $coords 2] - [lindex $coords 0]]
    set hauteur_relation [expr [lindex $coords 3] - [lindex $coords 1]]
    # Origines des lignes
    #set x_origine [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    #set y_origine [expr [lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)]
    set x_origine ""
    set y_origine ""
    
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
            dict set lignes_graphique $id [list "relation" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list "ligne" $id_table]] $id_table $id_relation]
            #dict set textes_cardinalites $id [list $id_table [$ZONE_MCD.canvas.c create text [expr ($x_arrivee + $x_origine) / 2] [expr ($y_arrivee + $y_origine) / 2] -text [Katyusha_Relations_cardinalite $id_relation $id_table] -tag [list "texte_cardinalite" $id_table]]]
            }
        }
    }
}

##
# Met à jour les coordonnées des lignes reliants l'association aux entités
# La mise à jour des coordonnées ne fonctionnant pas correctement, à chaque fois
# les lignes sont supprimées et remplacées par des lignes correspondants aux nouvelles coordonnées
##
proc Katyusha_Relations_MAJ_ligne_coords {id_relation coords} {
    global lignes_graphique
    global relations_graphique
    global textes_cardinalites
    global MCD
    global ZONE_MCD
    global relations
    
    # Détermine les coordonnées des lignes à tracer
    set id_graphique [lindex [dict get $relations_graphique $id_relation] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    # Taille de l'association en pixels
    set largeur_association [expr [lindex $coords 2] - [lindex $coords 0]]
    set hauteur_association [expr [lindex $coords 3] - [lindex $coords 1]]
    # Origines des lignes
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr [lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)]
    
    set relation [dict get $relations $id_relation]
    set dict_liens_doubles [Katyusha_Associations_double_entite $relation]
    set dict_liens_doubles_decompte [Katyusha_Associations_double_entite $relation]
    
    #set dict_liens_doubles [dict create]
    
    # Balayage des lignes à la recharche de celles concernants l'association spécifiée
    foreach {k ligne} $lignes_graphique {
        set id_relation_tmp [lindex $ligne 3]
        if {$id_relation_tmp == $id_relation} {
            # Récupère les anciennes coordonnées de la ligne
            set acoords [$ZONE_MCD.canvas.c coords [lindex $ligne 1]]
            # Créé les nouvelles coordonnées :
            #           [nouveau_x_origine nouveau_y_origine ancien_x_cible ancien_y_cible]
            set ncoords [list $x $y [lindex $acoords 2] [lindex $acoords 3]]
            set id_entite [lindex $ligne 2]
            set coords_table_lien [Katyusha_Tables_coords_ID $id_entite]
            # Taille de la table en pixels
            set largeur_entite [expr [lindex $coords_table_lien 4] - [lindex $coords_table_lien 2]]
            set hauteur_entite [expr [lindex $coords_table_lien 5] - [lindex $coords_table_lien 3]]
            set x_origine ""
            set y_origine ""
            set x_arrivee ""
            set y_arrivee ""
            
            if {[lsearch [dict keys $dict_liens_doubles] $id_entite] == -1} {
                if {[lindex $coords 2] < [lindex $coords_table_lien 2]} {
                    set x_origine [lindex $coords 2]
                    set y_origine [expr [lindex $coords 1] + ($hauteur_association / 2)]
                    set x_arrivee [lindex $coords_table_lien 2]
                    set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_entite / 2)]
                } elseif {[lindex $coords 0] > [lindex $coords_table_lien 4]} {
                    set x_origine [lindex $coords 0]
                    set y_origine [expr [lindex $coords 1] + ($hauteur_association / 2)]
                    set x_arrivee [lindex $coords_table_lien 4]
                    set y_arrivee [expr [lindex $coords_table_lien 3] + ($hauteur_entite / 2)]
                } else {
                    if {[lindex $coords 1] > [lindex $coords_table_lien 5]} {
                        set x_origine [expr [lindex $coords 0] + ($largeur_association / 2)]
                        set y_origine [lindex $coords 1]
                        set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_entite / 2)]
                        set y_arrivee [lindex $coords_table_lien 5]
                    } elseif {[lindex $coords 3] < [lindex $coords_table_lien 3]} {
                        set x_origine [expr [lindex $coords 0] + ($largeur_association / 2)]
                        set y_origine [lindex $coords 3]
                        set x_arrivee [expr [lindex $coords_table_lien 4] - ($largeur_entite / 2)]
                        set y_arrivee [lindex $coords_table_lien 3]
                    }
                }
            } else {
                
                set nombre_dict_liens_doubles [dict get $dict_liens_doubles $id_entite]
                set actuel_dict_liens_doubles [dict get $dict_liens_doubles_decompte $id_entite]
                
                
                if {$actuel_dict_liens_doubles > 0} {
                if {[lindex $coords 2] < [lindex $coords_table_lien 2]} {
                    set x_origine [lindex $coords 2]
                    set y_origine [expr [lindex $coords 1] + ($hauteur_association / 2)]
                    set x_arrivee [lindex $coords_table_lien 2]
                    set y_arrivee [expr [lindex $coords_table_lien 3] + $actuel_dict_liens_doubles * ($hauteur_entite / $nombre_dict_liens_doubles) - 0.5 * ($hauteur_entite / $nombre_dict_liens_doubles)]
                } elseif {[lindex $coords 0] > [lindex $coords_table_lien 4]} {
                    set x_origine [lindex $coords 0]
                    set y_origine [expr [lindex $coords 1] + ($hauteur_association / 2)]
                    set x_arrivee [lindex $coords_table_lien 4]
                    set y_arrivee [expr [lindex $coords_table_lien 3] + $actuel_dict_liens_doubles * ($hauteur_entite / $nombre_dict_liens_doubles) - 0.5 * ($hauteur_entite / $nombre_dict_liens_doubles)]
                } else {
                    if {[lindex $coords 1] > [lindex $coords_table_lien 5]} {
                        set x_origine [expr [lindex $coords 0] + ($largeur_association / 2)]
                        set y_origine [lindex $coords 1]
                        set x_arrivee [expr [lindex $coords_table_lien 4] - $actuel_dict_liens_doubles * ($largeur_entite / $nombre_dict_liens_doubles) + 0.5 * ($largeur_entite / $nombre_dict_liens_doubles)]
                        set y_arrivee [lindex $coords_table_lien 5]
                    } elseif {[lindex $coords 3] < [lindex $coords_table_lien 3]} {
                        set x_origine [expr [lindex $coords 0] + ($largeur_association / 2)]
                        set y_origine [lindex $coords 3]
                        set x_arrivee [expr [lindex $coords_table_lien 4] - $actuel_dict_liens_doubles * ($largeur_entite / $nombre_dict_liens_doubles) + 0.5 * ($largeur_entite / $nombre_dict_liens_doubles)]
                        set y_arrivee [lindex $coords_table_lien 3]
                    }
                }
                dict set dict_liens_doubles_decompte $id_entite [expr $actuel_dict_liens_doubles - 1]
                }
            }
            
            # Si l'association est par dessus l'entité ou touche l'entité auquel elle est liée, pas de ligne
            if {$x_origine != "" && $y_origine != "" && $x_arrivee != "" && $y_arrivee != ""} {
                # Créé la nouvelle ligne
                dict set lignes_graphique $k [list "relation" [$ZONE_MCD.canvas.c create line $x_origine $y_origine $x_arrivee $y_arrivee -width 2 -fill $MCD(couleur_liens_relation) -tag [list "ligne" $id_entite]] $id_entite $id_relation]
                # Et supprimme l'ancienne
                $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                # Créé les textes des cardinalités
                foreach {kk texte_cardinalite} $textes_cardinalites {
                    if {[lindex $texte_cardinalite 0] == $id_entite && [lindex $texte_cardinalite 1] == $id_relation} {
                        $ZONE_MCD.canvas.c delete [lindex $texte_cardinalite 2]
                        dict unset $textes_cardinalites $kk
                    }
                }
                dict set textes_cardinalites $k [list $id_entite $id_relation [$ZONE_MCD.canvas.c create text [expr ($x_arrivee + $x_origine) / 2] [expr ($y_arrivee + $y_origine) / 2] -text [Katyusha_Relations_cardinalite $id_relation $id_entite] -tag [list "texte_cardinalite" $id_entite]]]
            }
        }
    }
    # Mise à jour de l'affichage graphique
    update
}

##
# Recherche si l'association est liée à plusieurs entités
##
proc Katyusha_Associations_double_entite {association} {
    
    set liens [dict get $association "liens"]
    
    set liste_liens [list]
    set dict_liens_doubles [dict create]
    
    # Pour chaque lien :
    # Si l'entité n'est pas déjà présente dans la liste "liste_liens", elle y est ajoutée,
    # sinon, c'est que l'association est liée au moins deux fois à l'entité, donc le nom de l'entité est ajouté à le dictionnaire "dict_liens_doubles"
    foreach {k lien} $liens {
        
        set id_table [Katyusha_Tables_ID_table [lindex $lien 0]]
        
        if {[lsearch $liste_liens [lindex $lien 0]] == -1} {
            lappend liste_liens [lindex $lien 0]
        } else {
            if {[lsearch [dict keys $dict_liens_doubles] $id_table] == -1} {
                dict set dict_liens_doubles $id_table 2
            } else {
                dict set dict_liens_doubles $id_table [expr [dict get $dict_liens_doubles $id_table] + 1]
            }
        }
    }
    
    return $dict_liens_doubles
}

##
# Détruit les lignes graphiques en lien avec une association
# Et supprime leur liste du dictionnaire des lignes graphiques
##
proc Katyusha_Relations_suppression_lignes {id_relation} {
    global lignes_graphique
    global textes_cardinalites
    global ZONE_MCD
    
    # Supprime les lignes
    foreach {k ligne} $lignes_graphique {
        if {[lindex $ligne 0] == "relation"} {
            if {[lindex $ligne 3] == $id_relation} {
                $ZONE_MCD.canvas.c delete [lindex $ligne 1]
                dict unset lignes_graphique $k
            }
        }
    }
    # Supprime les cardinalités
    foreach {kk texte_cardinalite} $textes_cardinalites {
        if {[lindex $texte_cardinalite 1] == $id_relation} {
            $ZONE_MCD.canvas.c delete [lindex $texte_cardinalite 2]
            dict unset $textes_cardinalites $kk
        }
    }
}

##
# Ajout d'un attribut à l'association
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
            button $f.attributs.c.f.corps.$id_attribut_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps association $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            button $f.attributs.c.f.corps.$id_attribut_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps association $id_attribut_graphique [expr $id_attribut_graphique + 1]"
            button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_attribut relation $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.auto $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.haut $f.attributs.c.f.corps.$id_attribut_graphique.bas $f.attributs.c.f.corps.$id_attribut_graphique.edit -side left
        pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
    }
    update
}

##
# Renvoie la cardinalité liant une entité à une association grâce à leurs ID
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
# Ajout d'un nouveau lien à l'association tomporaire
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

##
# TODO : Tout
##
proc Katyusha_Relations_controle_relation {relation} {
    set ok 1
    
    return $ok
}

##
# Supprime l'association passée en paramètre
##
proc suppression_relation {relation} {
    global LOCALE
    global relations
    global relations_graphique
    global ZONE_MCD
    
    # Récupère le nom de la relation
    set nom [dict get [dict get $relations $relation] "nom"]
    # Supprime la relation du tableau général
    dict unset relations $relation
    # Supprime l'affichage de la relation
    foreach c [dict get $relations_graphique $relation] {
        $ZONE_MCD.canvas.c delete $c
    }
    # Supprime les lignes qui pointent vers la relation
    Katyusha_Relations_suppression_lignes $relation
    dict unset relations_graphique $relation
    Katyusha_MCD_Objets_maj_arbre_objets
    puts "Relation $nom supprimée"
    unset nom
}

##
# Initialise une association
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
    unset id_attribut nom type complement_type taille null valeur auto pk description graphique
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
# Supprime dans toutes les associations les liens concernant une table par son ID
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
