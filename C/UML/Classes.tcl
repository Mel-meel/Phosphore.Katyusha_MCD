## Créé le 4/3/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Classes_ajout {} {
    Katyusha_UML_Objets_maj_arbre_objets
}

proc Katyusha_UML_Classes_maj_depuis_mld {mld} {
    global classes
}

proc Katyusha_UML_Classes_creer_affichage_graphique_attributs {attributs} {
    set res [list]
    
    foreach {k attribut} $attributs {
        set acces [dict get $attribut "acces"]
        set nom [dict get $attribut "nom"]
        
        if {$acces == "private"} {
            set acces_symbole "-"
        } elseif {$acces == "public"} {
            set acces_symbole "+"
        } elseif {$acces == "protected"} {
            set acces_symbole "#"
        }
        
        lappend res "$acces_symbole  $nom"
    }
    
    return $res
}

proc Katyusha_UML_Classes_creer_affichage_graphique_methodes {methodes} {
    set res [list]
    
    foreach {k methode} $methodes {
        set acces [dict get $methode "acces"]
        set nom [dict get $methode "nom"]
        
        if {$acces == "private"} {
            set acces_symbole "-"
        } elseif {$acces == "public"} {
            set acces_symbole "+"
        } elseif {$acces == "protected"} {
            set acces_symbole "#"
        }
        
        lappend res "$acces_symbole  $nom\(\)"
    }
    
    return $res
}

##
# 
##
proc Katyusha_UML_Classes_creer_affichage_graphique_taille_classe {nom attributs methodes} {
    set largeur [string length $nom]
    # Attrbituts
    foreach {k attribut} $attributs {
        if {[string length "! [dict get $attribut nom]"] > $largeur} {
            set largeur [string length "! [dict get $attribut nom]"]
        }
    }
    # Méthodes
    foreach {k methode} $methodes {
        if {[string length "! [dict get $methode nom]"] > $largeur} {
            set largeur [string length "! [dict get $methode nom]\(\)"]
        }
    }
    return $largeur
}

proc Katyusha_UML_Classes_creer_affichage_graphique {id classe} {
    global IMG
    global rpr
    global CONFIGS
    global ZONE_UML
    
    # Créé l'affichage graphique de la nouvelle table dans une liste temporaire
    set x [lindex [dict get $classe "coords"] 0]
    set y [lindex [dict get $classe "coords"] 1]
    
    set nom [dict get $classe "nom"]
    set attributs [dict get $classe "attributs"]
    set methodes [dict get $classe "methodes"]
    
    set largeur [expr [Katyusha_UML_Classes_creer_affichage_graphique_taille_classe $nom $attributs $methodes] * 10 + 20]
    set hauteur_attributs [expr ([llength $attributs] / 2) * 18 + 20]
    set hauteur_methodes [expr ([llength $methodes] / 2) * 18 + 20]
    
    set hauteur [expr $hauteur_attributs + $hauteur_methodes]
    
    lappend graph [$ZONE_UML.modelisation.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur / 2)] [expr $x + ($largeur / 2)] [expr $y + ($hauteur / 2)] -outline #ffbe6f -fill #ffffc0 -tag [list "objet_uml" "classe" $id]]
    lappend graph [$ZONE_UML.modelisation.c create text [expr $x - (([string length $nom] * 7.5) / 2)] [expr $y - ($hauteur / 2) + 20] -fill black -anchor w -text $nom -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list "objet_uml" "classe" $id]]
    lappend graph [$ZONE_UML.modelisation.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur_attributs / 2) + 40] [expr $x + ($largeur / 2)] [expr $y + ($hauteur_attributs / 2) + 40] -outline #ffbe6f -fill #ffffc0 -tag [list "objet_uml" "classe" $id]]
    lappend graph [$ZONE_UML.modelisation.c create rect [expr $x - ($largeur / 2)] [expr $y - ($hauteur_methodes / 2) + ($hauteur_attributs / 2) + 40] [expr $x + ($largeur / 2)] [expr $y + ($hauteur_methodes / 2) + ($hauteur_attributs / 2) + 40] -outline #ffbe6f -fill #ffffc0 -tag [list "objet_uml" "classe" $id]]
    
    set y2 [expr $y + 60]
    
    # Création de l'affichage des attributs
    foreach attribut [Katyusha_UML_Classes_creer_affichage_graphique_attributs $attributs] {
        lappend graph [$ZONE_UML.modelisation.c create text [expr $x - (([string length $nom] * 7.5) / 2) - 10] [expr $y2 - ($hauteur / 2)] -fill black -anchor w -text $attribut -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list "objet_uml" "classe" $id]]
        set y2 [expr $y2 + 18]
    }
    
    set y2 [expr $y2 + 20]
    
    # Création de l'affichage des méthodes
    foreach methode [Katyusha_UML_Classes_creer_affichage_graphique_methodes $methodes] {
        lappend graph [$ZONE_UML.modelisation.c create text [expr $x - (([string length $nom] * 7.5) / 2) - 10] [expr $y2 - ($hauteur / 2)] -fill black -anchor w -text $methode -font {-family "$rpr/libs/general_font.ttf" -size 12} -tag [list "objet_uml" "classe" $id]]
        set y2 [expr $y2 + 18]
    }
    
    unset id classe
    
    return $graph
}

proc Katysha_UML_Classes_creer_classe {classe_tmp} {
    # Charge la variable globale contenant toutes les tables
    global classes
    global classes_graphique
    global ID
    
    # Ajoute la nouvelle classe aux classes existantes
    dict set classes $ID $classe_tmp
    set graph [Katyusha_UML_Classes_creer_affichage_graphique $ID $classe_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des classes
    dict set classes_graphique $ID $graph
    puts [phgt::mc "Ajout de la classe : [dict get $classe_tmp nom]"]
    
    # Créé l'entité MCD
    Katyusha_MCD_Objets_creer_objet_depuis_classe $ID $classe_tmp
    
    set ID [expr $ID + 1]
    #puts [.mcd.canvas.c coords [lindex $graph 0]]
    unset graph
    # Met à jour l'arbre des entités
    Katyusha_UML_Objets_maj_arbre_objets
    
    puts $classes_graphique
    puts $classes
    #Katyusha_Historique_maj
}

##
# Créé une classes depuis le MCD
##
proc Katyusha_UML_Classes_creer_classe_depuis_entite {id entite} {
    global tables
    global classes
    global classes_graphique
    
    set classe [Katyusha_UML_Classes_init_classe]
    
    dict set classe "nom" [dict get $entite "nom"]
    dict set classe "attributs" [dict get $entite "attributs"]
    dict set classe "coords" [dict get $entite "coords"]
    
    set graph [Katyusha_UML_Classes_creer_affichage_graphique $id $classe]
    
    
    dict set classes $id $classe
    dict set classes_graphique $id $graph
    
    Katyusha_UML_Objets_maj_arbre_objets
    
    puts $classes
    
    unset graph id entite classe
}

##
# Met à joour une classe depuis le MCD
##
proc Katyusha_UML_Classes_maj_classe_depuis_entite {id entite} {
    global classes
    global classes_graphique
    global tables
    global ENV
    global ID_UML
    global ZONE_UML
    
    set classe [dict get $classes $id]
    
    dict set classe "nom" [dict get $entite "nom"]
    dict set classe "attributs" [dict get $entite "attributs"]
    dict set classe "coords" [dict get $entite "coords"]
    
    dict set classes $id $classe
    
    # Supprime l'affichage de la table
    foreach c [dict get $classes_graphique $id] {
        $ZONE_UML.modelisation.c delete $c
    }
    set graph [Katyusha_UML_Classes_creer_affichage_graphique $id $classe]
    
    # Remplace l'ancien affichage graphique par le nouveau
    dict set classes_graphique $id $graph
    
    Katyusha_UML_Objets_maj_arbre_objets
}

##
# Met à jour les coordonnées d'une table par son ID
##
proc Katyusha_UML_Classes_MAJ_coords {id coords} {
    global classes
    
    set classe [dict get $classes $id]
    dict set classe "coords" $coords
    dict set classes $id $classe
}

##
# Initialise une classe
##
proc Katyusha_UML_Classes_init_classe {} {
    global UML
    
    set classe [dict create]
    dict set classe "attributs" [dict create]
    dict set classe "methodes" [dict create]
    dict set classe "description" ""
    #dict set classe "couleurs" [dict create "fond_tete" $UML(couleur_fond_tete_table) "ligne" $UML(couleur_ligne_table) "fond_corps" $UML(couleur_fond_corps_table) "texte" $UML(couleur_texte_table)]
    
    return $classe
}

##
# Suppression d'une classe
##
proc Katyusha_UML_Classes_supprimer_classe {id} {
    global classes
    global classes_graphique
    global ZONE_UML
    
    # Récupère le nom de la classe
    set nom [dict get [dict get $classes $id] "nom"]
    # Supprime la relation du tableau général
    dict unset relations $id
    # Supprime l'affichage de la relation
    foreach c [dict get $classes_graphique $id] {
        $ZONE_UML.modelisation.c delete $c
    }
    
    Katyusha_UML_Objets_maj_arbre_objets
}

##
# Mise à jour d'une classe
##
proc Katysha_UML_Classes_modifier_classe {id classe_tmp} {
    global classes
    
    Katyusha_UML_Classes_supprimer_classe $id
    dict set classes $id $classe_tmp
    
    Katyusha_UML_Classes_creer_affichage_graphique $id $classe_tmp
    
    Katyusha_UML_Objets_maj_arbre_objets
}

###############################
#    MÉTHODES DE LA CLASSE    #
###############################



##
# Ajout d'une méthode
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_UML_Classes_ajout_methode {nom parametres type acces description {graphique 1}} {
    global classe_tmp
    global IMG
    
    set background [Katyusha_Configurations_couleurs "-frame"]
    
    set methodes [dict get $classe_tmp "methodes"]
    
    dict set methode "nom" $nom
    dict set methode "parametres" $parametres
    dict set methode "type" $type
    dict set methode "acces" $acces
    dict set methode "description" ""
    
    set ids [dict keys $methodes]
    set id_methode_graphique [expr [lindex $ids [expr [llength $ids] - 1]] + 1]
    dict set methodes $id_methode_graphique $methode
    
    dict set classe_tmp "methodes" $methodes
    
    if {$graphique == 1} {
        set f ".fen_ajout_classe.corps"
        #
        frame $f.methodes.c.f.corps.$id_methode_graphique
            ttk::label $f.methodes.c.f.corps.$id_methode_graphique.nom -text $nom -width 30 -background $background  -relief solid
            ttk::label $f.methodes.c.f.corps.$id_methode_graphique.parametres -text $parametres -width 30 -background $background  -relief solid
            ttk::label $f.methodes.c.f.corps.$id_methode_graphique.type -text $type -width 10 -background $background  -relief solid
            ttk::label $f.methodes.c.f.corps.$id_methode_graphique.acces -text $acces -width 10 -background $background  -relief solid
            ttk::button $f.methodes.c.f.corps.$id_methode_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_UML_Interface_Objets_deplacer_attribut $f.attributs.c.f.corps classe $id_methode_graphique [expr $id_methode_graphique - 1]"
            ttk::button $f.methodes.c.f.corps.$id_methode_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_UML_Interface_Objets_deplacer_attribut $f.attributs.c.f.corps classe $id_methode_graphique [expr $id_methode_graphique + 1]"
            ttk::button $f.methodes.c.f.corps.$id_methode_graphique.edit -text [phgt::mc "Éditer"] -image $IMG(editer) -command "Katyusha_MCD_INTERFACE_Objets_ajout_attribut classe $id_methode_graphique"
            pack $f.methodes.c.f.corps.$id_methode_graphique.nom $f.methodes.c.f.corps.$id_methode_graphique.parametres $f.methodes.c.f.corps.$id_methode_graphique.type $f.methodes.c.f.corps.$id_methode_graphique.acces $f.methodes.c.f.corps.$id_methode_graphique.haut $f.methodes.c.f.corps.$id_methode_graphique.bas $f.methodes.c.f.corps.$id_methode_graphique.edit -fill both -expand 1 -side left
        pack $f.methodes.c.f.corps.$id_methode_graphique -fill x
        
        update
    }
}
