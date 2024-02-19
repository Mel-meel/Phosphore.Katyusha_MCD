## Créé le 11/9/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Si aucune table n'est spécifiée en argument, il s'agira d'un ajout de table.
# Si une table est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc Katyusha_MCD_INTERFACE_Entite_ajout_entite {x y {id "null"}} {
    global coords
    global IMG
    global tables
    global table_tmp
    global id_attribut_graphique
    global E_nom_table
    
    # Couleurs
    set ddbackground [Katyusha_Configurations_couleurs "-ddbackground"]
    set dbackground [Katyusha_Configurations_couleurs "-dbackground"]
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set background [Katyusha_Configurations_couleurs "-frame"]
    set foreground [Katyusha_Configurations_couleurs "-foreground"]
    
    set f ".fen_ajout_table"
    
    # Initialise la table temporaire
    if {$id == "null"} {
        # Transfert des coordonnées
        set coords [list $x $y]
        set table_tmp [Katyusha_Tables_init_table]
        dict set table_tmp "coords" $coords
        set E_nom_table [phgt::mc "Entite_%s" [list [expr [dict size $tables] + 1]]]
    } else {
        set table [dict get $tables $id]
        set table_tmp $table
        set E_nom_table [dict get $table "nom"]
    }
    dict set table_tmp "id" $id
    set id_attribut_graphique 0
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de choix du nom de la table
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Nom de l'entité : "]
        ttk::entry $f.nom.e -textvariable E_nom_table
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    
    ttk::frame $f.attributs
        # Commandes des attributs
        ttk::frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_Interface_Objets_MCD_UML_ajout_attribut "table"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Objets_suppression_attribut "table"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x
        
        
        ttk::frame $f.attributs.table_tete
            ttk::frame $f.attributs.table_tete.f
                ttk::label $f.attributs.table_tete.f.titre -text [phgt::mc "Liste des attributs de l'entité"]
                pack $f.attributs.table_tete.f.titre -fill both -anchor center -padx 10 -pady 10 -expand 1
                ttk::frame $f.attributs.table_tete.f.tete
                    ttk::label $f.attributs.table_tete.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.type -text [phgt::mc "Type"] -width 15 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.signe -text [phgt::mc "Non signé?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.taille -text [phgt::mc "Taille"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.valeur -text [phgt::mc "Valeur\npar défaut"] -width 20 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.auto -text [phgt::mc "Incrémentation\nautomatique?"] -width 15 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.pk -text [phgt::mc "Clef\nprimaire?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.unique -text [phgt::mc "Unique?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.m -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.d -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.e -text "" -width 5 -background $background -relief solid
                    
                    pack $f.attributs.table_tete.f.tete.nom $f.attributs.table_tete.f.tete.type $f.attributs.table_tete.f.tete.signe $f.attributs.table_tete.f.tete.taille $f.attributs.table_tete.f.tete.valeur $f.attributs.table_tete.f.tete.auto $f.attributs.table_tete.f.tete.pk $f.attributs.table_tete.f.tete.unique $f.attributs.table_tete.f.tete.m $f.attributs.table_tete.f.tete.d $f.attributs.table_tete.f.tete.e -fill both -expand 1 -side left
                pack $f.attributs.table_tete.f.tete -fill both -anchor w -expand 1
            pack $f.attributs.table_tete.f -fill both -anchor w -expand 1
        pack $f.attributs.table_tete -anchor w -expand 1
        
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -background $lbackground -highlightbackground $lbackground
        ttk::frame $f.attributs.c.f
            # Liste des attributs
            ttk::frame $f.attributs.c.f.liste
                ttk::frame $f.attributs.c.f.corps
                
                pack $f.attributs.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'entité est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.attributs.c $table "entite"
                    }
            pack $f.attributs.c.f.liste -side left -fill both
        pack $f.attributs.c -side left -expand 1 -fill both
        $f.attributs.c create window 0 0 -anchor nw -window $f.attributs.c.f
        ttk::scrollbar $f.attributs.yscroll -command "$f.attributs.c yview"
        pack $f.attributs.yscroll -side right -fill y
        
    pack $f.attributs -fill both -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.attributs.c configure -yscrollcommand "$f.attributs.yscroll set"
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command Katyusha_MCD_INTERFACE_Entites_COMMANDE_ajout_table
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {
            if {[winfo exists .fen_ajout_attribut]} {
                destroy .fen_ajout_attribut
            }
            destroy .fen_ajout_table
        }
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f [phgt::mc "Ajouter une entité"]
    } else {
        wm title $f [phgt::mc "Éditer l'entité %s" [list $E_nom_table]]
    }
    
    # Couleur de fond de la fenêtre
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
    
    # Mise à jour forcée de l'affichage graphique
    update
}


##
# Action de la procédure INTERFACE_ajout_table
##
proc Katyusha_MCD_INTERFACE_Entites_COMMANDE_ajout_table {} {
    global table_tmp
    
    set f ".fen_ajout_table"
    set id [dict get $table_tmp "id"]
    dict set table_tmp "nom" [$f.nom.e get]
    dict set table_tmp "description" ""
    #set ok [Katyusha_Tables_controle_table $table_tmp]
    set ok 1
    if {$id == "null" && $ok == 1} {
        ajout_table $table_tmp
        destroy $f
    } elseif {$id != "null" && $ok == 1} {
        Katyusha_Tables_modification_table $id $table_tmp
        destroy $f
    }
}

proc INTERFACE_Tables_choix_table {nombre_tables_possibles} {
    global tables
    global IMG
    global table_choisie
    
    set f ".fen_choix_table"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    ttk::frame $f.table -padx 10 -pady 10
        ttk::label $f.table.l -text [phgt::mc "Choisir une entité :"]
        ttk::combobox $f.table.cb -values [liste_tables]
        pack $f.table.l $f.table.cb -fill both -side left
    pack $f.table -fill x
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
            set f ".fen_choix_table"
            global table_choisie
            set table_choisie [$f.table.cb get]
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Choisir une entité"]
    
    # Couleur de fond de la fenêtre
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
    
    # Mise à jour forcée de l'affichage graphique
    update
    
    # Attend qu'une valeur soit affectée à table_choisie
    vwait table_choisie
    destroy $f
    return $table_choisie
}
