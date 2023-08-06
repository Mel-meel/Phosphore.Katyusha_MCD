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
    global STYLES
    
    set c "$NOTEBOOK_UML.panel.arbre.c"
    set hauteur 20
    set x 20
    # Efface tout ce qui se trouve dans le canvas
    set classes_canvas [$c gettags "classe"]
    foreach e $classes_canvas {
        $c delete $e
    }
    # Affiche les classes
    $c create text [expr $x + 0] $hauteur -fill [dict get $STYLES "foreground"] -justify left -text [phgt::mc "Classes"] -anchor w -tag "classe"
    set hauteur [expr $hauteur + 20]
    set x [expr $x + 20]
    foreach {id classe} $classes {
        set nom [dict get $classe "nom"]
        $c create text [expr $x + 0] $hauteur -fill [dict get $STYLES "foreground"] -justify left -text "$id : $nom" -anchor w -tag "classe"
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
