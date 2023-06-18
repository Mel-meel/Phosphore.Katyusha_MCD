## Créé le 18/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

# Clic gauche sur le canvase principal
bind $ZONE_UML.canvas.c <Button-1> {
    global ACTION_B1
    global CONFIGS
    global LOCALE
    global ZONE_UML
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    set scrollbar_x_coords [$ZONE_UML.hs get]
    set scrollbar_x_debut [lindex $scrollbar_x_coords 0]
    set scrollbar_x_fin [lindex $scrollbar_x_coords 1]
    set scrollbar_y_coords [$ZONE_UML.canvas.vs get]
    set scrollbar_y_debut [lindex $scrollbar_y_coords 0]
    set scrollbar_y_fin [lindex $scrollbar_y_coords 1]
    
    set px [expr %x + ($scrollbar_x_debut * $xbcanvas)]
    set py [expr %y + ($scrollbar_y_debut * $ybcanvas)]
    #$ZONE_UML.infos.s.position_curseur configure -text "x : $px / y : $py"
    if {$ACTION_B1 == "null"} {
        puts "Rien à faire en position $px : $py"
    } elseif {$ACTION_B1 == "ajout_classe"} {
        # Si la fenêtre d'ajout d'entité n'existe pas déjà, la créer
        if {![winfo exists .fen_uml_ajout_classe]} {
            Katyusha_UML_INTERFACE_Objets_ajout_entite $px $py
            Katyusha_UML_boutons_ajout_off
        }
    }
}
