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
    label $f.texte -text [phgt::mc "À propos"]
    label $f.lien -text "http://katyusha-mcd.projet-phosphore.anazaar.org" -foreground blue -font Underline-Font
    button $f.ok -text "OK" -command "destroy $f"
    pack $f.titre $f.logo $f.texte $f.lien $f.ok -fill x
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "À propos"]
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre de paramètrage de la génération SQL
##
proc INTERFACE_generation_sql {} {
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
    
    ttk::label $f.texte -text [phgt::mc "Sélectionner un SGBD"]
    pack $f.texte -fill x -pady 10 -padx 50
    ttk::combobox $f.lb -values $SGBD_dispo
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
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
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy ".fen_gen_sql"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -padx 50
    pack $f.lb -fill x
    pack $f.commandes -fill x -pady 10 -padx 50
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Générer le script SQL"]
    
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
    wm title $f [phgt::mc "Erreurs du MCD"]
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre d'affichage du script SQL une fois généré
##
proc INTERFACE_script_SQL {script fichier_script} {
    global IMG
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
    ttk::label $f.info -text "[phgt::mc Préférences]$fichier_script"
    pack $f.info -fill x -padx 10 -pady 10
    # Le script
    $f.texte.t insert end $script
    # Coloration de termes SQL
    Katyusha_SQL_coloration $f.texte.t $script
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Script SQL"]
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # Mise à jour forcée de l'affichage graphique
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
