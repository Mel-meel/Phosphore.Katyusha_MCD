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
            set largeur [string length "! [dict get $methode nom]"]
        }
    }
    return $largeur
}

proc Katyusha_UML_Classes_creer_affichage_graphique {id classe} {
    global IMG
    global rpr
    global CONFIGS
    global ZONE_UML
    global ENV
    
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

##
# Créé une classes depuis le MCD
##
proc Katyusha_UML_Classes_creer_classe_depuis_entite {id entite} {
    global tables
    global classes
    global classes_graphique
    global ENV
    global ID_UML
    
    set classe [Katyusha_UML_Classes_init_classe]
    
    dict set classe "nom" [dict get $entite "nom"]
    dict set classe "attributs" [dict get $entite "attributs"]
    dict set classe "coords" [dict get $entite "coords"]
    
    set graph [Katyusha_UML_Classes_creer_affichage_graphique $ID_UML $classe]
    
    
    dict set classes $ID_UML $classe
    dict set classes_graphique $ID_UML $graph
    
    set ID_UML [expr $ID_UML + 1]
    
    Katyusha_UML_Objets_maj_arbre_objets
    
    unset graph id entite classe
}

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
# Ajout d'un attribut
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_UML_Classes_ajout_attribut {nom type nsigne complement_type taille null valeur auto pk unique acces description {graphique 1}} {
    global classe_tmp
    global IMG
    global LOCALE
    global STYLES
    
    set attributs [dict get $classe_tmp "attributs"]
    
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
        set f ".fen_ajout_classe"
        #
        frame $f.attributs.c.f.corps.$id_attribut_graphique
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text $nom -width 30 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.type -text $type -width 15 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.acces -text $acces -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text $taille -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text $valeur -width 20 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text $pk -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f.attributs.c.f.corps $id_attribut_graphique [expr $id_attribut_graphique + 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text $LOCALE(editer) -image $IMG(editer) -command "Katyusha_MCD_INTERFACE_Objets_ajout_attribut table $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.acces $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.haut $f.attributs.c.f.corps.$id_attribut_graphique.bas $f.attributs.c.f.corps.$id_attribut_graphique.edit -fill both -expand 1 -side left
        pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
        
        update
    }
}

##
# Met à jour les coordonnées d'une table par son ID
##
proc Katyusha_UML_Classes_MAJ_coords {id coords} {
    global classes
    puts $classes
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
    #dict set classe "couleurs" [dict create "fond_tete" $UML(couleur_fond_tete_table) "ligne" $UML(couleur_ligne_table) "fond_corps" $UML(couleur_fond_corps_table) "texte" $UML(couleur_texte_table)]
    
    return $classe
}
