## Créé le 2/3/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

###############################################################################
#                                                                             #
#   Fonctions qui génère un affichage graphique (hors canvas principal)       #
#                                                                             #
###############################################################################

##
# À propos du logiciel
##
proc INTERFACE_apropos {} {
    global LOCALE
    global version
    global IMG
    global IMG
    
    set f ".fen_a_propos"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    label $f.titre -text "Katyusha MCD v$version"
    label $f.logo -image $IMG(splash)
    label $f.texte -text $LOCALE(TEXTE_a_propos)
    label $f.lien -text "http://katyusha-mcd.projet-phosphore.anazaar.org" -foreground blue -font Underline-Font
    button $f.ok -text "OK" -command "destroy $f"
    pack $f.titre $f.logo $f.texte $f.lien $f.ok -fill x
    # Titre le la présente fenêtre
    wm title $f $LOCALE(TITRE_a_propos)
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre de paramètrage de la génération SQL
##
proc INTERFACE_generation_sql {} {
    global LOCALE
    global IMG
    global STYLES
    
    set f ".fen_gen_sql"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    # Liste les SGBD dont Katyusha peut générer un script
    set SGBD_dispo [liste_sgbd]
    
    ttk::label $f.texte -text $LOCALE(selectionner_sgbd)
    pack $f.texte -fill x -pady 10 -padx 50
    ttk::combobox $f.lb -values $SGBD_dispo
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            set sgbd [.fen_gen_sql.lb get]
            set lscript [Katyusha_verification_mcd_sql $sgbd]
            #set lscript [Katyusha_generation_sql $sgbd]
            set script [lindex $lscript 0]
            set fichier_script [lindex $lscript 1]
            set erreurs [lindex $lscript 2]
            if {$script != 0 && $fichier_script != 0 && $fichier_script != ""} {
                INTERFACE_script_SQL $script $fichier_script
            } else {
                INTERFACE_erreurs_MCD $erreurs
            }
            destroy ".fen_gen_sql"
        }
        ttk::button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy ".fen_gen_sql"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -padx 50
    pack $f.lb -fill x
    pack $f.commandes -fill x -pady 10 -padx 50
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(generer_sql)
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Affichage des erreurs du MCD
##
proc INTERFACE_erreurs_MCD {erreurs} {
    global IMG
    global LOCALE
    
    set texte ""
    
    foreach ligne $erreurs {
        set texte "$texte$ligne\n"
    }

    set f ".fen_erreurs_mcd"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    frame $f.commandes
    pack $f.commandes -fill x
    frame $f.texte
        text $f.texte.t -yscrollcommand {.fen_erreurs_mcd.texte.ysbar set}
        scrollbar $f.texte.ysbar -orient vertical -command {.fen_erreurs_mcd.texte.t yview}
        pack $f.texte.t -fill both -side left -expand 1
        pack $f.texte.ysbar -fill y -side left
    pack $f.texte -fill both -expand 1
    # Le script
    $f.texte.t insert end $texte
    # Titre le la présente fenêtre
    wm title $f $LOCALE(erreurs_mcd)
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre d'affichage du script SQL une fois généré
##
proc INTERFACE_script_SQL {script fichier_script} {
    global IMG
    global LOCALE
    global STYLES
    
    set f ".fen_script_sql"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    ttk::frame $f.commandes
    pack $f.commandes -fill x
    ttk::frame $f.texte
        text $f.texte.t -yscrollcommand {.fen_script_sql.texte.ysbar set} -background [dict get $STYLES "background"] -highlightbackground [dict get $STYLES "graphics"] -highlightcolor [dict get $STYLES "graphics"] -foreground [dict get $STYLES "foreground"] -insertbackground [dict get $STYLES "foreground"] -relief flat
        ttk::scrollbar $f.texte.ysbar -orient vertical -command {.fen_script_sql.texte.t yview}
        pack $f.texte.t -fill both -side left -expand 1
        pack $f.texte.ysbar -fill both -side left
    pack $f.texte -fill both -expand 1
    ttk::label $f.info -text "$LOCALE(script_enregistre)$fichier_script"
    pack $f.info -fill x -padx 10 -pady 10
    # Le script
    $f.texte.t insert end $script
    # Coloration de termes SQL
    Katyusha_SQL_coloration $f.texte.t $script
    # Titre le la présente fenêtre
    wm title $f $LOCALE(script_sql)
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # Mise à jour forcée de l'affichage graphique
    update
}
 
##
# Configuration du logiciel
##
proc INTERFACE_preferences {} {
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

##
# Petite mise en garde pour les utilisateurs de Windows, parce que Windows c'est mal
##
proc INTERFACE_mise_en_garde {} {
    global OS
    global IMG
    global STYLES
    
    set f ".fen_meg"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    ttk::label $f.l -text [phgt::mc "Le système d'exploitation \"%s\" sur lequel cette instance de Katyusha! MCD à été initiée n'est pas un système libre.\nLe code source n'ayant pas pu être vérifié par un tiers de confiance, votre VIE PRIVÉE est donc en DANGER.\nÉteignez immédiatement votre ordinateur afin de redémarer sur un système d'exploitation libre et donc sûr." [list $OS]]
    ttk::button $f.ok -text [phgt::mc "J'ai compris"] -command "destroy $f"
    pack $f.l $f.ok -fill x -padx 10 -pady 10
    
    wm title $f [phgt::mc "DANGER!"]
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # MAJ de l'affichage graphique
    update
}

##
# Affiche la license
##
proc INTERFACE_license {} {
    global IMG
    global rpr
    global STYLES
    
    set f ".fen_license"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    ttk::label $f.titre -image $IMG(GNU)
    pack $f.titre -padx 10 -pady 10
    ttk::frame $f.texte
        text $f.texte.t -yscrollcommand {.fen_license.texte.ysbar set} -background [dict get $STYLES "background"] -highlightbackground [dict get $STYLES "graphics"] -highlightcolor [dict get $STYLES "graphics"] -foreground [dict get $STYLES "foreground"] -insertbackground [dict get $STYLES "foreground"] -relief flat
        ttk::scrollbar $f.texte.ysbar -orient vertical -command {.fen_license.texte.t yview}
        $f.texte.t insert end [file_read "$rpr/gpl-3.0.txt" "r"]
        pack $f.texte.t -side left -fill both -expand 1 -padx 10 -pady 10 
        pack $f.texte.ysbar -side left -fill y
    pack $f.texte -fill both -expand 1
    ttk::button $f.ok -text [phgt::mc "J'ai compris"] -command "destroy $f"
    pack $f.ok -fill x -padx 10 -pady 10
    
    wm title $f [phgt::mc "Licence"]
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # MAJ de l'affichage graphique
    update
}

##
# Exporte en SVG le contenu du canvas
# TODO : À réécrire entièrement
##
proc INTERFACE_exporter_svg {} {
    set fichier [tk_getSaveFile]
    if {$fichier != ""} {
        set svg [canvas2svg .editeurs.notebook_mcd.mcd.canvas.c]
        set fp [open $fichier "w+"]
        puts $fp $svg
        close $fp
    }
}

##
#
##
proc INTERFACE_imprimer {} {
    set taille [Katyusha_SVG_taille_svg .editeurs.notebook_mcd.mcd.canvas.c]
    set fichier [tk_getSaveFile]
    if {$fichier != ""} {
        set fp [open $fichier "w+"]
        .mcd.canvas.c postscript -channel $fp -width [lindex $taille 0] -height [lindex $taille 0]
        close $fp
    }
}
