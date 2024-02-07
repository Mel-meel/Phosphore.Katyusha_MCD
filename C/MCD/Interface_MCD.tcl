## Créé le 28/6/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Interface de la modélisation Merise
##
proc Katyusha_Interface_editeur_MCD {parent canvas_x canvas_y} {
    global IMG
    global CONFIGS
    global ZONE_MCD
    global OS
    global splash
    
    set f [ttk::frame $parent.notebook_mcd]
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set dbackground [Katyusha_Configurations_couleurs "-dbackground"]
    
    ttk::frame $parent.notebook_mcd.panel
        ttk::frame $parent.notebook_mcd.panel.commandes
            # Bouton on/off d'ajout d'une entité
            button $parent.notebook_mcd.panel.commandes.ajout_table -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter une entité"] -image $IMG(ajouter_table) -command {Katyusha_MCD_action_boutons_ajout "table"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_table [phgt::mc "Ajouter une table"]
            # Bouton on/off d'ajout d'une association
            button $parent.notebook_mcd.panel.commandes.ajout_relation -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter une association"] -image $IMG(ajouter_relation) -command {Katyusha_MCD_action_boutons_ajout "relation"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_relation [phgt::mc "Ajouter une association"]
            # Bouton on/off d'ajout d'un héritage
            button $parent.notebook_mcd.panel.commandes.ajout_heritage -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter un héritage"] -image $IMG(ajouter_heritage) -command {Katyusha_MCD_action_boutons_ajout "heritage"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_heritage [phgt::mc "Ajouter un héritage"]
            # Bouton on/off d'ajout d'une étiquette
            button $parent.notebook_mcd.panel.commandes.ajout_etiquette -background $lbackground -activebackground $dbackground -highlightbackground $dbackground -text [phgt::mc "Ajouter une étiquette"] -image $IMG(ajouter_etiquette) -command {Katyusha_MCD_action_boutons_ajout "etiquette"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_etiquette [phgt::mc "Ajouter une étiquette"]
            pack $parent.notebook_mcd.panel.commandes.ajout_table $parent.notebook_mcd.panel.commandes.ajout_relation $parent.notebook_mcd.panel.commandes.ajout_etiquette $parent.notebook_mcd.panel.commandes.ajout_heritage -side left
        pack $parent.notebook_mcd.panel.commandes
        ttk::label $parent.notebook_mcd.panel.entites -text [phgt::mc "Objets du MCD"] -justify left
        pack $parent.notebook_mcd.panel.entites -fill x -pady 10 -padx 5
        # Arbre des objets du MCD
        ttk::frame $parent.notebook_mcd.panel.arbre
            canvas $parent.notebook_mcd.panel.arbre.c -height [expr $canvas_y - 30] -width 250 -yscrollcommand "$parent.notebook_mcd.panel.arbre.vs set" -background $dbackground -highlightbackground $dbackground
            ttk::scrollbar $parent.notebook_mcd.panel.arbre.vs -command "$parent.notebook_mcd.panel.arbre.c yview"
            pack $parent.notebook_mcd.panel.arbre.c $parent.notebook_mcd.panel.arbre.vs -side left -fill both
        pack $parent.notebook_mcd.panel.arbre
    pack $parent.notebook_mcd.panel -side left
    ttk::frame $parent.notebook_mcd.mcd
        # Infos de la base de données
        ttk::frame $parent.notebook_mcd.mcd.infos_bdd
            ttk::button $parent.notebook_mcd.mcd.infos_bdd.zoom_plus -text "+" -image $IMG(zoom_plus) -command "Katyusha_zoom_plus $ZONE_MCD.canvas.c"
            ttk::button $parent.notebook_mcd.mcd.infos_bdd.zoom_moins -text "-" -image $IMG(zoom_moins) -command "Katyusha_zoom_moins $ZONE_MCD.canvas.c"
            ttk::button $parent.notebook_mcd.mcd.infos_bdd.zoom_initial -text "1:1" -image $IMG(zoom_initial) -command "Katyusha_zoom_initial $ZONE_MCD.canvas.c"
            ttk::button $parent.notebook_mcd.mcd.infos_bdd.defaire -text "défaire" -image $IMG(defaire) -command Katyusha_Historique_defaire
            ttk::button $parent.notebook_mcd.mcd.infos_bdd.refaire -text "refaire" -image $IMG(refaire) -command Katyusha_Historique_refaire
            pack $parent.notebook_mcd.mcd.infos_bdd.zoom_plus $parent.notebook_mcd.mcd.infos_bdd.zoom_moins $parent.notebook_mcd.mcd.infos_bdd.zoom_initial $parent.notebook_mcd.mcd.infos_bdd.defaire $parent.notebook_mcd.mcd.infos_bdd.refaire -side left -padx 10 -pady 5
        pack $parent.notebook_mcd.mcd.infos_bdd -fill x
        # Canvas principal
        ttk::frame $parent.notebook_mcd.mcd.canvas
            # C'est pas parfait, mais ça marche
            # À revoir completement
            ttk::scrollbar $parent.notebook_mcd.mcd.canvas.vs -command "$parent.notebook_mcd.mcd.canvas.c yview"
            set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
            set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
            canvas $parent.notebook_mcd.mcd.canvas.c -background $dbackground -xscrollcommand "$parent.notebook_mcd.mcd.hs set" -yscrollcommand "$parent.notebook_mcd.mcd.canvas.vs set" -scrollregion "0 0 $xbcanvas $ybcanvas" -highlightbackground $dbackground
            pack $parent.notebook_mcd.mcd.canvas.c -side left -fill both -expand 1
            pack $parent.notebook_mcd.mcd.canvas.vs -side left -fill y
            #.mcd.canvas.c configure -scrollregion [.mcd.canvas.c bbox all]
        pack $parent.notebook_mcd.mcd.canvas -fill both -expand 1
        ttk::scrollbar $parent.notebook_mcd.mcd.hs -orient horiz -command "$parent.notebook_mcd.mcd.canvas.c xview"
        pack $parent.notebook_mcd.mcd.hs -side top -fill x
    pack $parent.notebook_mcd.mcd -side left -fill both -expand 1
    
    return $f
}
