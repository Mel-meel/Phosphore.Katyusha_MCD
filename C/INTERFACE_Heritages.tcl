## Créé le 8/10/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc INTERFACE_Heritages_ajout {x y {id "null"}} {
    global heritage_tmp
    global heritages
    global tables
    global LOCALE
    global IMG
    
    # Initialise l'heritage temporaire
    if {$id == "null"} {
        set heritage_tmp [Katyusha_Heritages_init_heritage]
        dict set heritage_tmp "coords" [list $x $y]
        set table_mere $LOCALE(cliquer_choisir_table_mere)
        set contrainte ""
    } else {
        set heritage_tmp [dict get $heritages $id]
        set id_mere [dict get $heritage_tmp "mere"]
        if {$id_mere != ""} {
            set table_mere [dict get $tables $id_mere "nom"]
            set contrainte [dict get $heritage_tmp "contrainte"]
        } else {
            set table_mere $LOCALE(cliquer_choisir_table_mere)
            set contrainte ""
        }
    }
    set f ".fen_ajout_heritage"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Il doit y avoir au moins une table dans le MCD pour ajouter un héritage (la table mère)
    if {[dict size $tables] > 0} {
    frame $f.mere -padx 10 -pady 10
        #label $f.mere.l -text $LOCALE(table_mere)
        #ttk::combobox $f.mere.cb -values [liste_tables]
        #pack $f.mere.l $f.mere.cb -fill both -side left
        #if {$id != "null"} {
        #    $f.mere.cb set $table_mere
        #}
        button $f.mere.table -text $LOCALE(table_mere) -command INTERFACE_Heritages_ajout_table_mere
        label $f.mere.label -text $table_mere
        pack $f.mere.table $f.mere.label -side left -fill x
    pack $f.mere -fill x
    frame $f.filles -padx 10 -pady 10
            label $f.filles.tete -text $LOCALE(liste_tables_filles)
            pack $f.filles.tete -fill x
        frame $f.filles.commandes
            button $f.filles.commandes.ajout -text "+" -image $IMG(ajouter) -command {INTERFACE_Heritages_ajout_table_fille}
            button $f.filles.commandes.supp -text "-" -image $IMG(supprimer) -command {INTERFACE_Heritages_supp_table_fille}
            pack $f.filles.commandes.ajout $f.filles.commandes.supp -padx 10
        pack $f.filles.commandes -fill x -side left
        frame $f.filles.liste
            frame $f.filles.liste.corps
            ##
            # Ici, s'affiche la liste des tables filles de l'héritage
            ##
            if {$id != "null"} {
                foreach {k table_fille} [dict get $heritage_tmp "filles"] {
                    label $f.filles.liste.corps.$k -text [dict get [dict get $tables $table_fille] "nom"] -height 2 -width 40 -background white -relief solid
                    pack $f.filles.liste.corps.$k -fill x
                }
            }
            pack $f.filles.liste.corps -fill x
        pack $f.filles.liste -fill x -side left
    pack $f.filles -fill x
    ##
    # Constraintes de l'héitage
    # XT, X, T ou aucune contrainte
    ##
    frame $f.contrainte -padx 10 -pady 10
        label $f.contrainte.l -text "Contrainte de l'héritage"
        ttk::combobox $f.contrainte.cb -values [list "" "XT" "X" "T"]
        if {$id != "null"} {
            $f.contrainte.cb set $contrainte
        }
        pack $f.contrainte.l $f.contrainte.cb -fill both
    pack $f.contrainte -fill x
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "INTERFACE_COMMANDE_Heritage_ajout $x $y $id"
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    # S'il n'y a aucune table dans le MCD, erreur
    } else {
        puts $LOCALE(pas_assez_table)
        set rep [tk_messageBox -title "Oups!" -message $LOCALE(pas_assez_table) -type "ok" -icon warning]
    }
    
    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f $LOCALE(ajouter_un_heritage)
    } else {
        wm title $f "$LOCALE(editer_l_heritage)$id"
    }
    
    # Mise à jour forcée de l'affichage graphique
    update
}

proc INTERFACE_COMMANDE_Heritage_ajout {x y id} {
    global heritage_tmp

    dict set heritage_tmp "contrainte" [.fen_ajout_heritage.contrainte.cb get]
    
    if {$id == "null"} {
        Katyusha_Heritages_ajout $heritage_tmp
        dict set heritage_tmp "coords" [list $x $y]
    } else {
        Katyusha_Heritages_modification_heritage $id $heritage_tmp
    }
    destroy .fen_ajout_heritage
}

##
# Interface d'ajout d'une table mère à l'héritage
##
proc INTERFACE_Heritages_ajout_table_mere {} {
    global heritage_tmp
    global heritages
    global tables
    global LOCALE
    global IMG
    
    set f ".fen_heritage_ajout_table_mere"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    frame $f.table -padx 10 -pady 10
        label $f.table.l -text $LOCALE(table_mere)
        ttk::combobox $f.table.cb -values [liste_tables]
        pack $f.table.l $f.table.cb -fill both -side left
    pack $f.table -fill x
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            global heritage_tmp
            set f ".fen_heritage_ajout_table_mere"
            dict set heritage_tmp "mere" [Katyusha_Tables_ID_table [$f.table.cb get]]
            .fen_ajout_heritage.mere.label configure -text [$f.table.cb get]
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(ajouter_table_mere)
    
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Interface d'ajout d'une table fille à l'héritage
##
proc INTERFACE_Heritages_ajout_table_fille {} {
    global heritage_tmp
    global heritages
    global tables
    global LOCALE
    global IMG
    
    set f ".fen_heritage_ajout_table_fille"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    frame $f.table -padx 10 -pady 10
        label $f.table.l -text $LOCALE(table_fille)
        ttk::combobox $f.table.cb -values [liste_tables]
        pack $f.table.l $f.table.cb -fill both -side left
    pack $f.table -fill x
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            set f ".fen_heritage_ajout_table_fille"
            Katyusha_Heritages_ajout_table_fille [Katyusha_Tables_ID_table [$f.table.cb get]] [$f.table.cb get]
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(ajouter_table_fille)
    
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Interface de suppression d'une table fille d'un héritage
##
proc INTERFACE_Heritages_supp_table_fille {} {
    global heritage_tmp
    global tables
    global LOCALE
    global IMG
    
    set f ".fen_supp_table_fille"
    set defaut_valeur "null"
    set liste_filles [list]
    
    set filles [dict get $heritage_tmp "filles"]
    
    # Construit la liste des attributs
    foreach {k fille} $filles {
        lappend liste_filles "$k : [dict get [dict get $tables $fille] nom]"
    }
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de titre
    frame $f.nom
        label $f.nom.l -text $LOCALE(supprimer_table_fille_selection)
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    ttk::combobox $f.cb -value $liste_filles -width 50
    pack $f.cb
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command INTERFACE_COMMANDE_suppression_table_fille
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(supprimer_table_fille)
    update
}

proc INTERFACE_COMMANDE_suppression_table_fille {} {
    global heritage_tmp
    global LOCALE
    
    set f ".fen_supp_table_fille"
    # Récupère la valeur de la listbox de choix de la table fille à supprimer
    set fille [$f.cb get]
    
    # Si l'attribut n'est pas vide, on considère pour le moment qu'il existe bien dans la liste
    # TODO : contrôler la validité de l'attribut à supprimer
    if {$fille != ""} {
        set id_fille [lindex [split $fille " : "] 0]
        set heritage_tmp [Katyusha_Heritages_suppression_table_fille $heritage_tmp $id_fille]
        # Destruction de l'affichage de l'attribut supprimmé
        #destroy .fen_ajout_$entite.attributs.corps.[lsearch $attributs $attribut_dict]
        # Destruction de la fenêtre de choix
        destroy $f
    } else {
        set ok [tk_messageBox -icon error -message $LOCALE(aucune_table_selectionne) -type ok]
    }
    
    # Mise à jour de l'affichage graphique
    update
}
