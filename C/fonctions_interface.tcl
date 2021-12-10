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
    
    label $f.texte -text $LOCALE(selectionner_sgbd)
    pack $f.texte -fill x -pady 10 -padx 50
    ttk::combobox $f.lb -values $SGBD_dispo
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
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
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy ".fen_gen_sql"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -padx 50
    pack $f.lb -fill x
    pack $f.commandes -fill x -pady 10 -padx 50
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(generer_sql)
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
    
    set f ".fen_script_sql"
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
        text $f.texte.t -yscrollcommand {.fen_script_sql.texte.ysbar set}
        scrollbar $f.texte.ysbar -orient vertical -command {.fen_script_sql.texte.t yview}
        pack $f.texte.t -fill both -side left -expand 1
        pack $f.texte.ysbar -fill both -side left
    pack $f.texte -fill both -expand 1
    label $f.info -text "$LOCALE(script_enregistre)$fichier_script" -padx 10 -pady 10
    pack $f.info -fill x
    # Le script
    $f.texte.t insert end $script
    # Coloration de termes SQL
    Katyusha_SQL_coloration $f.texte.t $script
    # Titre le la présente fenêtre
    wm title $f $LOCALE(script_sql)
    # Mise à jour forcée de l'affichage graphique
    update
}
 
##
# Configuration du logiciel
##
proc INTERFACE_preferences {} {
    global IMG
    global LOCALE
    global CONFIGS
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
    
    label $f.info -text $LOCALE(prefs_titre)
    pack $f.info -fill x -pady 10 -padx 50
    frame $f.pref
        # Choix de la langue
        frame $f.pref.langues
            label $f.pref.langues.l -text $LOCALE(prefs_choix_langue) -width 50 -anchor w
            ttk::combobox $f.pref.langues.lb -values [Katyusha_Configurations_liste_langues]
            $f.pref.langues.lb set "$CONFIGS(LANG) - [Katyusha_Configurations_langue_code $CONFIGS(LANG)]"
            pack $f.pref.langues.l $f.pref.langues.lb -side left -fill x
        pack $f.pref.langues -fill x -padx 10
        # Résolution
        frame $f.pref.resolution
            label $f.pref.resolution.l -text $LOCALE(prefs_taille_fenetre) -width 50 -anchor w
            entry $f.pref.resolution.e -textvariable CONFIGS(RESOLUTION)
            label $f.pref.resolution.info -text $LOCALE(prefs_taille_fenetre_alerte) -foreground red -anchor w
            pack $f.pref.resolution.info -side bottom
            pack $f.pref.resolution.l $f.pref.resolution.e -side left -fill x
        pack $f.pref.resolution -fill x -padx 10
        # Nom de la base par défaut
        frame $f.pref.base
            label $f.pref.base.l -text $LOCALE(prefs_nom_bdd_defaut) -width 50 -anchor w
            entry $f.pref.base.e -textvariable CONFIGS(NOM_BDD_DEFAUT)
            pack $f.pref.base.l $f.pref.base.e -side left -fill x
        pack $f.pref.base -fill x -padx 10
        # SGBD par défaut
        frame $f.pref.sgbd
            label $f.pref.sgbd.l -text $LOCALE(prefs_sgbd_defaut) -width 50 -anchor w
            ttk::combobox $f.pref.sgbd.lb -values [liste_sgbd]
            pack $f.pref.sgbd.l $f.pref.sgbd.lb -side left -fill x
        pack $f.pref.sgbd -fill x -padx 10
        # Taille du canvas
        frame $f.pref.taille_canvas
            label $f.pref.taille_canvas.l -text $LOCALE(prefs_taille_canvas) -width 50 -anchor w
            entry $f.pref.taille_canvas.e -textvariable CONFIGS(TAILLE_CANVAS)
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
	
    frame $f.aff_objets
		label $f.aff_objets.titre -text $LOCALE(prefs_titre_choix_props_att)
		pack $f.aff_objets.titre -fill x -pady 10 -padx 50
		frame $f.aff_objets.pk
			label $f.aff_objets.pk.f -text $LOCALE(prefs_pk) -width 50 -anchor w
			checkbutton $f.aff_objets.pk.c -onvalue 1 -offvalue 0 -variable E_conf_att_pk
			pack $f.aff_objets.pk.f $f.aff_objets.pk.c -side left -anchor w
		pack $f.aff_objets.pk
		
		frame $f.aff_objets.nom
			label $f.aff_objets.nom.f -text $LOCALE(prefs_nom) -width 50 -anchor w
			checkbutton $f.aff_objets.nom.c -onvalue 1 -offvalue 0 -variable E_conf_att_nom
			pack $f.aff_objets.nom.f $f.aff_objets.nom.c -side left -anchor w
		pack $f.aff_objets.nom
		
		frame $f.aff_objets.type
			label $f.aff_objets.type.f -text $LOCALE(prefs_type) -width 50 -anchor w
			checkbutton $f.aff_objets.type.c -onvalue 1 -offvalue 0 -variable E_conf_att_type
			pack $f.aff_objets.type.f $f.aff_objets.type.c -side left -anchor w
		pack $f.aff_objets.type
			
		frame $f.aff_objets.taille
			label $f.aff_objets.taille.f -text $LOCALE(prefs_taille) -width 50 -anchor w
			checkbutton $f.aff_objets.taille.c -onvalue 1 -offvalue 0 -variable E_conf_att_taille
			pack $f.aff_objets.taille.f $f.aff_objets.taille.c -side left -anchor w
		pack $f.aff_objets.taille
		
		frame $f.aff_objets.null
			label $f.aff_objets.null.f -text $LOCALE(prefs_null) -width 50 -anchor w
			checkbutton $f.aff_objets.null.c -onvalue 1 -offvalue 0 -variable E_conf_att_null
			pack $f.aff_objets.null.f $f.aff_objets.null.c -side left -anchor w
		pack $f.aff_objets.null
			
		frame $f.aff_objets.defaut
			label $f.aff_objets.defaut.f -text $LOCALE(prefs_defaut) -width 50 -anchor w
			checkbutton $f.aff_objets.defaut.c -onvalue 1 -offvalue 0 -variable E_conf_att_defaut
			pack $f.aff_objets.defaut.f $f.aff_objets.defaut.c -side left -anchor w
		pack $f.aff_objets.defaut
		
    pack $f.aff_objets -fill x
    
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
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
            set res [tk_messageBox -type ok -message $LOCALE(prefs_alerte_configs_redemarrage)]
            destroy .fen_preferences
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy .fen_preferences}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.commandes
    
    wm title $f $LOCALE(prefs_titre)
    # MAJ de l'affichage graphique
    update
}
 
##
# Configuration du MCD
##
proc INTERFACE_config_bdd {} {
    global IMG
    global MCD
    global LOCALE
    
    set f ".fen_config_bdd"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    wm title $f $LOCALE(config_mcd_titre)
    
    frame $f.titre
        label $f.titre.l -text $LOCALE(config_mcd_titre)
        pack $f.titre.l -fill x -pady 10 -padx 50
    pack $f.titre -fill x
    # Entrées de configuration
    frame $f.conf
        # Nom de la base de données
        frame $f.conf.nom
            label $f.conf.nom.l -text $LOCALE(nom_projet) -width 25 -justify left
            entry $f.conf.nom.e -textvariable MCD(nom)
            pack $f.conf.nom.l $f.conf.nom.e -side left -fill x
        pack $f.conf.nom -fill x
        # Liste des SGBD pour la base de données
        frame $f.conf.sgbd
            label $f.conf.sgbd.l -text $LOCALE(liste_sgbd) -width 25 -justify left
            listbox $f.conf.sgbd.lb -selectmode multiple -height 4
            #pack $f.conf.sgbd.l $f.conf.sgbd.lb -side left -fill x
            # Insert la liste des SGBD disponibles pour la génération SQL
            #$f.conf.sgbd.lb insert 0 "mysql" "sqlite3"
        #pack $f.conf.sgbd -fill x
        # Répertoire du projet
        frame $f.conf.rep
            label $f.conf.rep.l -text "Répertoire du projet" -width 25 -justify left
            button $f.conf.rep.b -text $MCD(rep) -command {
                global MCD
                
                set MCD(rep) [tk_chooseDirectory -initialdir $MCD(rep)]
            }
            pack $f.conf.rep.l $f.conf.rep.b -side left -fill x
        pack $f.conf.rep -fill x
        # Si le script SQL doit contenir drop database ou non
        frame $f.conf.drop
            label $f.conf.drop.l -text "Drop? : " -width 25 -justify left
            checkbutton $f.conf.drop.cb -onvalue 1 -offvalue 0 -variable get_drop
            pack $f.conf.drop.l $f.conf.drop.cb -side left -fill x
        pack $f.conf.drop -fill x
    pack $f.conf -fill x
    # Valider, retour
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            global MCD
            
            set f ".fen_config_bdd"
            set nom [$f.conf.nom.e get]
            set liste_sgbd [$f.conf.sgbd.lb get 0 3]
            set drop_base $get_drop
            Katyusha_Configurations_MCD $nom $liste_sgbd $drop_base
            .mcd.infos_bdd.nom_bdd configure -text "$LOCALE(nom_projet) : $MCD(nom)"
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy .fen_config_bdd}
        pack $f.commandes.ok $f.commandes.ko -side left -fill x -padx 50
    pack $f.commandes -fill x
    # MAJ de l'affichage graphique
    update
}

proc INTERFACE_mise_en_garde {} {
    global OS
    global IMG
    global LOCALE
    
    set f ".fen_meg"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    label $f.l -text "Le système d'exploitation \"$OS\" sur lequel cette instance de Katyusha! MCD à été initiée n'est pas un système libre.\nLe code source n'ayant pas pu être vérifié par un tiers de confiance, votre VIE PRIVÉE est donc en DANGER.\nÉteignez immédiatement votre ordinateur afin de redémarer sur un système d'exploitation libre et donc sûr." -padx 10 -pady 10
    button $f.ok -text "J'ai compris" -padx 10 -pady 10 -command "destroy $f"
    pack $f.l $f.ok -fill x
    
    wm title $f "DANGER!"
    # MAJ de l'affichage graphique
    update
}

proc INTERFACE_license {} {
    global IMG
    global rpr
    global LOCALE
    
    set f ".fen_license"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    label $f.titre -padx 10 -pady 10 -image $IMG(GNU)
    pack $f.titre
    frame $f.texte
        text $f.texte.t -height 20 -padx 10 -pady 10 -yscrollcommand {.fen_license.texte.ysbar set}
        scrollbar $f.texte.ysbar -orient vertical -command {.fen_license.texte.t yview}
        $f.texte.t insert end [file_read "$rpr/gpl-3.0.txt" "r"]
        pack $f.texte.t -side left -fill both -expand 1
        pack $f.texte.ysbar -side left -fill y
    pack $f.texte -fill both -expand 1
    button $f.ok -text $LOCALE(jai_compris) -padx 10 -pady 10 -command "destroy $f"
    pack $f.ok -fill x
    
    wm title $f $LOCALE(licence)
    # MAJ de l'affichage graphique
    update
}

##
#
##
proc INTERFACE_exporter_svg {} {
    set fichier [tk_getSaveFile]
    if {$fichier != ""} {
        set svg [canvas2svg .mcd.canvas.c]
        set fp [open $fichier "w+"]
        puts $fp $svg
        close $fp
    }
}

##
#
##
proc INTERFACE_imprimer {} {
    set taille [Katyusha_SVG_taille_svg .mcd.canvas.c]
    set fichier [tk_getSaveFile]
    if {$fichier != ""} {
        set fp [open $fichier "w+"]
        .mcd.canvas.c postscript -channel $fp -width [lindex $taille 0] -height [lindex $taille 0]
        close $fp
    }
}
