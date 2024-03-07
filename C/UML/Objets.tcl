## Créé le 4/3/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Objets_maj_depuis_mld {mld} {
    Katyusha_UML_Classes_maj_depuis_mld $mld
}

##
# Met à jour l'arbre des classes
##
proc Katyusha_UML_Objets_maj_arbre_objets {} {
    global classes
    global interfaces
    global NOTEBOOK_UML
    
    set foreground [Katyusha_Configurations_couleurs "-foreground"]
    
    set c "$NOTEBOOK_UML.panel.arbre.c"
    set hauteur 20
    set x 20
    # Efface tout ce qui se trouve dans le canvas
    set classes_canvas [$c gettags "classe"]
    foreach e $classes_canvas {
        $c delete $e
    }
    # Affiche les classes
    $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text [phgt::mc "Classes"] -anchor w -tag "classe"
    set hauteur [expr $hauteur + 20]
    set x [expr $x + 20]
    foreach {id classe} $classes {
        set nom [dict get $classe "nom"]
        $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text "$id : $nom" -anchor w -tag "classe"
        set hauteur [expr $hauteur + 20]
    }
    # Saut de ligne
    set hauteur [expr $hauteur + 10]
    # Remet y à sa position initiale
    set x [expr $x - 20]
    $c configure -scrollregion [$c bbox all]
}

proc Katyusha_UML_Objets_controle_attribut {nom type signe complement_type taille null valeur auto pk unique acces description} {
    return 1
}

##
# Ajout d'un attribut
# Ici, on suppose que les données ont été controlée avant injection
##
proc Katyusha_UML_Objets_ajout_attribut {nom type nsigne complement_type taille null valeur auto pk unique acces description objet {graphique 1}} {
    global classe_tmp
    global interface_tmp
    global IMG
    global STYLES
    
    if {$objet == "classe"} {
        set attributs [dict get $classe_tmp "attributs"]
    } elseif {$objet == "interface"} {
        set attributs [dict get $interface_tmp "attributs"]
    }
    
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
    
    if {$objet == "classe"} {
        dict set classe_tmp "attributs" $attributs
    } elseif {$objet == "interface"} {
        dict set interface_tmp "attributs" $attributs
    }
    
    if {$graphique == 1} {
        set f ".fen_ajout_$objet.corps"
        #
        ttk::frame $f.attributs.c.f.corps.$id_attribut_graphique
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text $nom -width 30 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.type -text $type -width 15 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.acces -text $acces -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text $taille -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text $valeur -width 20 -background [dict get $STYLES "background"]  -relief solid
            ttk::label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text $pk -width 10 -background [dict get $STYLES "background"]  -relief solid
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_UML_Interface_Objets_deplacer_attribut $f.attributs.c.f.corps entite $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_UML_Interface_Objets_deplacer_attribut $f.attributs.c.f.corps entite $id_attribut_graphique [expr $id_attribut_graphique + 1]"
            ttk::button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text [phgt::mc "Éditer"] -image $IMG(editer) -command "Katyusha_MCD_INTERFACE_Objets_ajout_attribut table $id_attribut_graphique"
            pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.acces $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.haut $f.attributs.c.f.corps.$id_attribut_graphique.bas $f.attributs.c.f.corps.$id_attribut_graphique.edit -fill both -expand 1 -side left
        pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
        
        update
    }
}
