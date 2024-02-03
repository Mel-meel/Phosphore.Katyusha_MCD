## Créé le 3/2/2024 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Nouvelle version des préféreces du logiciel
##

proc INTERFACE_Configurations_preferences {} {
    global IMG
    
    set f ".fen_preferences"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Titre général des préférences et icones
    ttk::frame $f.titre
        ttk::label $f.titre.logo -image $IMG(logo_x48)
        ttk::label $f.titre.texte -text [phgt::mc "Préférences de Katyusha MCD"]
        ttk::label $f.titre.icone -image $IMG(icone_preferences_x48)
        pack $f.titre.logo $f.titre.texte $f.titre.icone -fill x -pady 10 -padx 50 -side left
    pack $f.titre
    
    # Onglets de navigation pour les différents types de réglages
    ttk::notebook $f.onglets
    
    pack $f.onglets
    
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
}

##
# Configuration du logiciel
##
proc INTERFACE_preferences_a {} {
    global IMG
    global CONFIGS
    global STYLES
    global E_conf_att_pk
    global E_conf_att_nom
    global E_conf_att_type
    global E_conf_att_null
    global E_conf_att_defaut
    global E_conf_att_taille
    
    
    set f ".fen_preferences"
    
    # Liste des langues disponibles
    set langues [list "fr - Français"]
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    ttk::label $f.info -text [phgt::mc "Préférences de Katyusha MCD"]
    pack $f.info -fill x -pady 10 -padx 50
    ttk::frame $f.pref
        # Choix de la langue
        ttk::frame $f.pref.langues
            ttk::label $f.pref.langues.l -text [phgt::mc "Choix de la langue : "] -width 50 -anchor w
            ttk::combobox $f.pref.langues.lb -values [Katyusha_Configurations_liste_langues]
            $f.pref.langues.lb set "$CONFIGS(LANG) - [Katyusha_Configurations_langue_code $CONFIGS(LANG)]"
            pack $f.pref.langues.l $f.pref.langues.lb -side left -fill x
        pack $f.pref.langues -fill x -padx 10
        # Résolution
        ttk::frame $f.pref.resolution
            ttk::label $f.pref.resolution.l -text [phgt::mc "Taille de la fenêtre (auto pour une configuration automatique) : "] -width 50 -anchor w
            ttk::entry $f.pref.resolution.e -textvariable CONFIGS(RESOLUTION)
            ttk::label $f.pref.resolution.info -text [phgt::mc "Attention, la configuration automatique fonctionne mal avec les écrans multiples!"] -foreground red -anchor w
            pack $f.pref.resolution.info -side bottom
            pack $f.pref.resolution.l $f.pref.resolution.e -side left -fill x
        pack $f.pref.resolution -fill x -padx 10
        # Nom de la base par défaut
        ttk::frame $f.pref.base
            ttk::label $f.pref.base.l -text [phgt::mc "Nom par défaut de la base de donnée : "] -width 50 -anchor w
            ttk::entry $f.pref.base.e -textvariable CONFIGS(NOM_BDD_DEFAUT)
            pack $f.pref.base.l $f.pref.base.e -side left -fill x
        pack $f.pref.base -fill x -padx 10
        # SGBD par défaut
        ttk::frame $f.pref.sgbd
            ttk::label $f.pref.sgbd.l -text [phgt::mc "SGBD à utiliser par défaut : "] -width 50 -anchor w
            ttk::combobox $f.pref.sgbd.lb -values [liste_sgbd]
            pack $f.pref.sgbd.l $f.pref.sgbd.lb -side left -fill x
        pack $f.pref.sgbd -fill x -padx 10
        # Taille du canvas
        ttk::frame $f.pref.taille_canvas
            ttk::label $f.pref.taille_canvas.l -text [phgt::mc "Taille du canvas : "] -width 50 -anchor w
            ttk::entry $f.pref.taille_canvas.e -textvariable CONFIGS(TAILLE_CANVAS)
            pack $f.pref.taille_canvas.l $f.pref.taille_canvas.e -side left -fill x
        pack $f.pref.taille_canvas -fill x -padx 10
    pack $f.pref



    ##
    # Gestion de l'affichage au sein des objets
    ##
    
    foreach el $CONFIGS(AFFICHAGE_OBJETS) {
		if {$el == "pk"} {
			set E_conf_att_pk 1
		} elseif {$el == "nom"} {
			set E_conf_att_nom 1
		} elseif {$el == "type"} {
			set E_conf_att_type 1
		} elseif {$el == "null"} {
			set E_conf_att_null 1
		} elseif {$el == "defaut"} {
			set E_conf_att_defaut 1
		} elseif {$el == "taille"} {
			set E_conf_att_taille 1
		}
	}
	
    ttk::frame $f.aff_objets
		ttk::label $f.aff_objets.titre -text [phgt::mc "Choisir les propriétés des attributs à afficher à l'intérieur des objets du MCD"]
		pack $f.aff_objets.titre -fill x -pady 10 -padx 50
		ttk::frame $f.aff_objets.pk
			ttk::label $f.aff_objets.pk.f -text [phgt::mc "Clef primaire"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.pk.c -onvalue 1 -offvalue 0 -variable E_conf_att_pk
			pack $f.aff_objets.pk.f $f.aff_objets.pk.c -side left -anchor w
		pack $f.aff_objets.pk
		
		ttk::frame $f.aff_objets.nom
			ttk::label $f.aff_objets.nom.f -text [phgt::mc "Nom"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.nom.c -onvalue 1 -offvalue 0 -variable E_conf_att_nom
			pack $f.aff_objets.nom.f $f.aff_objets.nom.c -side left -anchor w
		pack $f.aff_objets.nom
		
		ttk::frame $f.aff_objets.type
			ttk::label $f.aff_objets.type.f -text [phgt::mc "Type"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.type.c -onvalue 1 -offvalue 0 -variable E_conf_att_type
			pack $f.aff_objets.type.f $f.aff_objets.type.c -side left -anchor w
		pack $f.aff_objets.type
			
		ttk::frame $f.aff_objets.taille
			ttk::label $f.aff_objets.taille.f -text [phgt::mc "Taille de l'attribut"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.taille.c -onvalue 1 -offvalue 0 -variable E_conf_att_taille
			pack $f.aff_objets.taille.f $f.aff_objets.taille.c -side left -anchor w
		pack $f.aff_objets.taille
		
		ttk::frame $f.aff_objets.null
			ttk::label $f.aff_objets.null.f -text [phgt::mc "Si l'attribut peut être nul"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.null.c -onvalue 1 -offvalue 0 -variable E_conf_att_null
			pack $f.aff_objets.null.f $f.aff_objets.null.c -side left -anchor w
		pack $f.aff_objets.null
			
		ttk::frame $f.aff_objets.defaut
			ttk::label $f.aff_objets.defaut.f -text [phgt::mc "Varleur par défaut"] -width 50 -anchor w
			ttk::checkbutton $f.aff_objets.defaut.c -onvalue 1 -offvalue 0 -variable E_conf_att_defaut
			pack $f.aff_objets.defaut.f $f.aff_objets.defaut.c -side left -anchor w
		pack $f.aff_objets.defaut
		
    pack $f.aff_objets -fill x
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
			global CONFIGS
			global E_conf_att_pk
			global E_conf_att_nom
			global E_conf_att_type
			global E_conf_att_null
			global E_conf_att_defaut
			global E_conf_att_taille
			
			
			set CONFIGS(AFFICHAGE_OBJETS) [list]
			
			if {$E_conf_att_pk == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "pk"
			}
			if {$E_conf_att_nom == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "nom"
			}
			if {$E_conf_att_type == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "type"
			}
			if {$E_conf_att_taille == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "taille"
			}
			if {$E_conf_att_null == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "null"
			}
			if {$E_conf_att_defaut == 1} {
				lappend CONFIGS(AFFICHAGE_OBJETS) "valeur"
			}
			
            set langue [.fen_preferences.pref.langues.lb get]
            Katyusha_Configurations_sauve $langue 1
            set res [tk_messageBox -type ok -message [phgt::mc "Le changement de certaines configurations ne prendra effet qu'au redémarrage de Katyusha MCD."]]
            destroy .fen_preferences
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy .fen_preferences}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.commandes
    
    wm title $f [phgt::mc "Préférences de Katyusha MCD"]
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # MAJ de l'affichage graphique
    update
}
