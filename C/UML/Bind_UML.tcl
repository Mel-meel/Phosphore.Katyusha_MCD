## Créé le 18/6/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

# Clic gauche sur le canvase principal
bind $ZONE_UML.modelisation.c <Button-1> {
    global ACTION_B1
    global CONFIGS
    global LOCALE
    global ZONE_UML
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_UML.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_UML.modelisation.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set px [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set py [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    #$ZONE_UML.infos.s.position_curseur configure -text "x : $px / y : $py"
    if {$ACTION_B1 == "null"} {
        puts "Rien à faire en position $px : $py"
    } elseif {$ACTION_B1 == "ajout_classe"} {
        # Si la fenêtre d'ajout d'entité n'existe pas déjà, la créer
        if {![winfo exists ".fen_uml_ajout_classe"]} {
            Katyusha_UML_Interface_Classes_ajout_classe $px $py
            Katyusha_UML_boutons_ajout_off
        }
    }
}


##
# Bouger une classe avec la souris
##
$ZONE_UML.modelisation.c bind objet_uml <Button-1> {
    global classes_graphique
    global CONFIGS
    global ZONE_UML
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_UML.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_UML.modelisation.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_UML.modelisation.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_UML.modelisation.c gettags $id]
    set tag [lindex $selected 2]
    puts "$tag sélectionné"
    set id_graphique [lindex [dict get $classes_graphique [lindex $selected 2]] 0]
    set coords [$ZONE_UML.modelisation.c coords $id_graphique]
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
}

$ZONE_UML.modelisation.c bind objet_uml <B1-Motion> {
    global tables_graphique
    global classes_graphique
    global CONFIGS
    global ZONE_MCD
    global ZONE_UML
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    if {$tag != ""} {
        set changed_x [expr (%x + (($scrollbar_x_debut * $xbcanvas)) - $atx)]
        set changed_y [expr (%y + (($scrollbar_y_debut * $ybcanvas)) - $aty)]
        # Vérifie que l'entité ne dépasse pas les limites du mcd
        # TODO : À revoir, la limitation de déplacement ne fonctionne pas correctement
        #if {$changed_x < $xbcanvas && $changed_x > 0 && $changed_y < $ybcanvas && $changed_y > 0} {
            foreach c [dict get $tables_graphique $tag] {
                $ZONE_MCD.canvas.c move $c $changed_x $changed_y
            }
            foreach c [dict get $classes_graphique $tag] {
                $ZONE_UML.modelisation.c move $c $changed_x $changed_y
            }
            set coords [$ZONE_MCD.canvas.c coords $id_graphique]
            # MAJ des coordonnées de l'entité
            set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
            set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
            Katyusha_Tables_MAJ_coords $tag [list $x $y]
            
            # Répercute les changements sur la zone UML
            Katyusha_UML_Classes_MAJ_coords $tag [list $x $y]
            
            # MAJ de la ligne reliant l'entité à son association
            Katyusha_Tables_MAJ_ligne_coords $tag [list [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
        #}
        set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
        set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    } else {
        puts "Oups..."
    }
    update
}

##
# Menu de clic droit des classes
##
$ZONE_UML.modelisation.c bind objet_uml <Button-3> {
    global CONFIGS
    global ZONE_UML
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_UML.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_UML.modelisation.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_UML.modelisation.c gettags $id]
    
    # Type d'objet
    set objet [lindex $selected 1]
    
    set id_objet [lindex $selected 2]
    
    popupMenu .menu_clic_droit_objets_uml %x %y $objet $id_objet
}


##################
# Menu d'édition #
##################



proc popupMenu {menu X Y objet id_objet} {
    destroy .menu_clic_droit_objets_uml
    menu .menu_clic_droit_objets_uml -tearoff 0
    .menu_clic_droit_objets_uml add command -label [phgt::mc "Éditer"] -command "Katyusha_UML_Interface_Classes_ajout_$objet 0 0 $id_objet"
    .menu_clic_droit_objets_uml add command -label [phgt::mc "Supprimer"] -command {Katyusha_MCD_INTERFACE_Objets_suppression_objet "heritage" [lindex $selected 1]}
    global ZONE_UML
    set x [expr [winfo rootx $ZONE_UML.modelisation.c] + int($X)]
    set y [expr [winfo rooty $ZONE_UML.modelisation.c] + int($Y)]
    tk_popup $menu $x $y
}
