## Créé le 5/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

# Clic gauche sur le canvas principal
bind $ZONE_MCD.canvas.c <Button-1> {
    global ACTION_B1
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set px [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set py [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    #$ZONE_MCD.infos.s.position_curseur configure -text "x : $px / y : $py"
    if {$ACTION_B1 == "null"} {
        puts "Rien à faire en position $px : $py"
    } elseif {$ACTION_B1 == "ajout_table"} {
        # Si la fenêtre d'ajout d'entité n'existe pas déjà, la créer
        if {![winfo exists .fen_ajout_table]} {
            Katyusha_MCD_INTERFACE_Entite_ajout_entite $px $py
            Katyusha_boutons_ajout_off
        }
    } elseif {$ACTION_B1 == "ajout_relation"} {
        # Si la fenêtre d'ajout d'association n'existe pas déjà, la créer
        if {![winfo exists .fen_ajout_relation]} {
            Katyusha_MCD_INTERFACE_Association_ajout_association $px $py
            Katyusha_boutons_ajout_off
        }
    } elseif {$ACTION_B1 == "ajout_etiquette"} {
        # Si la fenêtre d'ajout d'étiquette n'existe pas déjà, la créer
        if {![winfo exists .fen_ajout_etiquette]} {
            INTERFACE_Etiquettes_ajout $px $py
            Katyusha_boutons_ajout_off
        }
    } elseif {$ACTION_B1 == "ajout_heritage"} {
        # Si la fenêtre d'ajout d'héritage n'existe pas déjà, la créer
        if {![winfo exists .fen_ajout_relation]} {
            INTERFACE_Heritages_ajout $px $py
            Katyusha_boutons_ajout_off
        }
    }
}


##
# Bouger une entité avec la souris
##
$ZONE_MCD.canvas.c bind table <Button-1> {
    global tables_graphique
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    set tag [lindex $selected 1]
    puts "$tag sélectionné"
    set id_graphique [lindex [dict get $tables_graphique [lindex $selected 1]] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
}

$ZONE_MCD.canvas.c bind table <B1-Motion> {
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
# Bouger une association avec la souris
##
$ZONE_MCD.canvas.c bind relation <Button-1> {
    global relations_graphique
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    set tag [lindex $selected 1]
    puts "$tag sélectionné"
    set id_graphique [lindex [dict get $relations_graphique [lindex $selected 1]] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
}

$ZONE_MCD.canvas.c bind relation <B1-Motion> {
    global relations_graphique
    global ZONE_MCD
    
    set changed_x [expr [expr %x + ($scrollbar_x_debut * $xbcanvas)] - $atx]
    set changed_y [expr [expr %y + ($scrollbar_y_debut * $ybcanvas)] - $aty]
    
    foreach c [dict get $relations_graphique $tag] {
        $ZONE_MCD.canvas.c move $c $changed_x $changed_y
    }
    
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    # MAJ des coordonnées de l'association
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
    Katyusha_Relations_MAJ_coords $tag [list $x $y]
    Katyusha_Relations_MAJ_ligne_coords $tag [list [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    update
}


##
# Bouger une etiquette avec la souris
##
$ZONE_MCD.canvas.c bind etiquette <Button-1> {
    global etiquettes_graphique
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    set tag [lindex $selected 1]
    set id_graphique [lindex [dict get $etiquettes_graphique [lindex $selected 1]] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    puts "$tag sélectionné"
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
}

$ZONE_MCD.canvas.c bind etiquette <B1-Motion> {
    global etiquettes_graphique
    global ZONE_MCD
    
    set changed_x [expr [expr %x + ($scrollbar_x_debut * $xbcanvas)] - $atx]
    set changed_y [expr [expr %y + ($scrollbar_y_debut * $ybcanvas)] - $aty]
    for {set c 0} {$c < 2} {incr c} {
        $ZONE_MCD.canvas.c move [lindex [dict get $etiquettes_graphique $tag] $c] $changed_x $changed_y
    }
    Katyusha_Etiquettes_MAJ_coords $tag [list $atx $aty]
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    update
}


##
# Bouger un héritage avec la souris
##
$ZONE_MCD.canvas.c bind heritage <Button-1> {
    global heritages_graphique
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    set tag [lindex $selected 1]
    set id_graphique [lindex [dict get $heritages_graphique [lindex $selected 1]] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    puts "$tag sélectionné"
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
}

$ZONE_MCD.canvas.c bind heritage <B1-Motion> {
    global heritages_graphique
    global ZONE_MCD
    
    set changed_x [expr [expr %x + ($scrollbar_x_debut * $xbcanvas)] - $atx]
    set changed_y [expr [expr %y + ($scrollbar_y_debut * $ybcanvas)] - $aty]
    for {set c 0} {$c < 2} {incr c} {
        $ZONE_MCD.canvas.c move [lindex [dict get $heritages_graphique $tag] $c] $changed_x $changed_y
    }
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    # MAJ des coordonnées de l'entité
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
    Katyusha_Heritages_MAJ_coords $tag [list $atx $aty]
    Katyusha_Heritages_MAJ_lignes $tag
    
    set atx [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set aty [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    update
}

##
# Menu de clic droit des entités
##
$ZONE_MCD.canvas.c bind table <Button-3> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_table %x %y
}

$ZONE_MCD.canvas.c bind table <Double-Button-1> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_table %x %y
}

menu .menu_table -tearoff 0
.menu_table add command -label [phgt::mc "Éditer"] -command {Katyusha_MCD_INTERFACE_Entite_ajout_entite 0 0 [lindex $selected 1]}
.menu_table add command -label [phgt::mc "Supprimer"] -command {Katyusha_MCD_INTERFACE_Objets_suppression_objet "table" [lindex $selected 1]}

##
# Menu de clic droit des associations
##
$ZONE_MCD.canvas.c bind relation <Button-3> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_relation %x %y
}

$ZONE_MCD.canvas.c bind relation <Double-Button-1> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_relation %x %y
}

menu .menu_relation -tearoff 0
.menu_relation add command -label [phgt::mc "Éditer"] -command {Katyusha_MCD_INTERFACE_Association_ajout_association 0 0 [lindex $selected 1]}
.menu_relation add command -label [phgt::mc "Supprimer"] -command {Katyusha_MCD_INTERFACE_Objets_suppression_objet "relation" [lindex $selected 1]}

##
# Menu de clic droit des étiquettes
##
$ZONE_MCD.canvas.c bind etiquette <Button-3> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_etiquette %x %y
}

$ZONE_MCD.canvas.c bind etiquette <Double-Button-1> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_etiquette %x %y
}

menu .menu_etiquette -tearoff 0
.menu_etiquette add command -label [phgt::mc "Éditer"] -command {INTERFACE_Etiquettes_ajout 0 0 [lindex $selected 1]}
.menu_etiquette add command -label [phgt::mc "Supprimer"] -command {Katyusha_MCD_INTERFACE_Objets_suppression_objet "etiquette" [lindex $selected 1]}


##
# Menu de clic droit des héritages
##
$ZONE_MCD.canvas.c bind heritage <Button-3> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_heritage %x %y
}

$ZONE_MCD.canvas.c bind heritage <Double-Button-1> {
    global CONFIGS
    global ZONE_MCD
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_MCD.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_MCD.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set id [$ZONE_MCD.canvas.c find closest [expr %x + ($scrollbar_x_debut * $xbcanvas)] [expr %y + ($scrollbar_y_debut * $ybcanvas)]]
    set selected [$ZONE_MCD.canvas.c gettags $id]
    popupMenu .menu_heritage %x %y
}

menu .menu_heritage -tearoff 0
.menu_heritage add command -label [phgt::mc "Éditer"] -command {INTERFACE_Heritages_ajout 0 0 [lindex $selected 1]}
.menu_heritage add command -label [phgt::mc "Supprimer"] -command {Katyusha_MCD_INTERFACE_Objets_suppression_objet "heritage" [lindex $selected 1]}

proc popupMenu {theMenu theX theY} {
    global ZONE_MCD
    set x [expr [winfo rootx $ZONE_MCD.canvas.c]+int($theX)]
    set y [expr [winfo rooty $ZONE_MCD.canvas.c]+int($theY)]
    tk_popup $theMenu $x $y
}
