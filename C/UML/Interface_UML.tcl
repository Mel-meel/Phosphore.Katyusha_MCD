## Créé le 28/6/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Interface de la modélisation UML
##
proc Katyusha_Interface_editeur_UML {parent canvas_x canvas_y} {
    global IMG
    global CONFIGS
    global STYLES
    global ZONE_UML
    global OS
    global splash
    
    set f [ttk::frame $parent.notebook_uml]
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set dbackground [Katyusha_Configurations_couleurs "-dbackground"]
    
    ttk::frame $parent.notebook_uml.panel
        ttk::frame $parent.notebook_uml.panel.commandes
            # Bouton on/off d'ajout d'une classe
            button $parent.notebook_uml.panel.commandes.ajout_classe -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter une classe"] -image $IMG(ajouter_classe) -command {Katyusha_UML_action_boutons_ajout "classe"}
            tooltip::tooltip $parent.notebook_uml.panel.commandes.ajout_classe [phgt::mc "Ajouter une classe"]
            # Bouton on/off d'ajout d'une interface
            button $parent.notebook_uml.panel.commandes.ajout_interface -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter une interface"] -image $IMG(ajouter_interface) -command {Katyusha_UML_action_boutons_ajout "interface"}
            tooltip::tooltip $parent.notebook_uml.panel.commandes.ajout_interface [phgt::mc "Ajouter une interface"]
            pack $parent.notebook_uml.panel.commandes.ajout_classe $parent.notebook_uml.panel.commandes.ajout_interface -side left
        pack $parent.notebook_uml.panel.commandes
        ttk::label $parent.notebook_uml.panel.entites -text [phgt::mc "Objets du digramme de classes"] -justify left
        pack $parent.notebook_uml.panel.entites -fill x -pady 10 -padx 5
        # Arbre des objets du MCD
        ttk::frame $parent.notebook_uml.panel.arbre
            canvas $parent.notebook_uml.panel.arbre.c -height [expr $canvas_y - 30] -width 250 -yscrollcommand "$parent.notebook_uml.panel.arbre.vs set" -background $dbackground -highlightbackground $dbackground
            ttk::scrollbar $parent.notebook_uml.panel.arbre.vs -command "$parent.notebook_uml.panel.arbre.c yview"
            pack $parent.notebook_uml.panel.arbre.c $parent.notebook_uml.panel.arbre.vs -side left -fill both
        pack $parent.notebook_uml.panel.arbre
    pack $parent.notebook_uml.panel -side left
    ttk::frame $parent.notebook_uml.uml
        # Actions sur le canvas
        ttk::frame $parent.notebook_uml.uml.infos_bdd
            ttk::button $parent.notebook_uml.uml.infos_bdd.zoom_plus -text "+" -image $IMG(zoom_plus) -command "Katyusha_zoom_plus $ZONE_UML.canvas.c"
            ttk::button $parent.notebook_uml.uml.infos_bdd.zoom_moins -text "-" -image $IMG(zoom_moins) -command "Katyusha_zoom_moins $ZONE_UML.canvas.c"
            ttk::button $parent.notebook_uml.uml.infos_bdd.zoom_initial -text "1:1" -image $IMG(zoom_initial) -command "Katyusha_zoom_initial $ZONE_UML.canvas.c"
            ttk::button $parent.notebook_uml.uml.infos_bdd.defaire -text "défaire" -image $IMG(defaire) -command Katyusha_Historique_defaire
            ttk::button $parent.notebook_uml.uml.infos_bdd.refaire -text "refaire" -image $IMG(refaire) -command Katyusha_Historique_refaire
            pack $parent.notebook_uml.uml.infos_bdd.zoom_plus $parent.notebook_uml.uml.infos_bdd.zoom_moins $parent.notebook_uml.uml.infos_bdd.zoom_initial $parent.notebook_uml.uml.infos_bdd.defaire $parent.notebook_uml.uml.infos_bdd.refaire -side left -padx 10 -pady 5
        pack $parent.notebook_uml.uml.infos_bdd -fill x
        # Canvas principal
        ttk::frame $parent.notebook_uml.uml.modelisation
            # C'est pas parfait, mais ça marche
            # À revoir completement
            ttk::scrollbar $parent.notebook_uml.uml.modelisation.vs -command "$parent.notebook_uml.uml.modelisation.c yview"
            set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
            set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
            canvas $parent.notebook_uml.uml.modelisation.c -background $dbackground -height [expr $canvas_y] -width [expr $canvas_x - 50] -xscrollcommand "$parent.notebook_uml.uml.hs set" -yscrollcommand "$parent.notebook_uml.uml.modelisation.vs set" -scrollregion "0 0 $xbcanvas $ybcanvas" -highlightbackground $dbackground
            pack $parent.notebook_uml.uml.modelisation.c -side left -fill both -expand 1
            pack $parent.notebook_uml.uml.modelisation.vs -side left -fill y
            #.mcd.canvas.c configure -scrollregion [.mcd.canvas.c bbox all]
        pack $parent.notebook_uml.uml.modelisation -fill x -fill both -expand 1
        ttk::scrollbar $parent.notebook_uml.uml.hs -orient horiz -command "$parent.notebook_uml.uml.modelisation.c xview"
        pack $parent.notebook_uml.uml.hs -side top -fill x
    pack $parent.notebook_uml.uml -side left -fill both -expand 1
    
    return $f
}
