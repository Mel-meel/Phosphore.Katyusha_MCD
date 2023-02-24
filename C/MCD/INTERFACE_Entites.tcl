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
    global LOCALE
    global coords
    global IMG
    global tables
    global table_tmp
    global id_attribut_graphique
    global E_nom_table
    
    
    set f ".fen_ajout_table"
    
    # Initialise la table temporaire
    if {$id == "null"} {
        # Transfert des coordonnées
        set coords [list $x $y]
        set table_tmp [Katyusha_Tables_init_table]
        dict set table_tmp "coords" $coords
        set E_nom_table "Table_[expr [dict size $tables] + 1]"
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
    frame $f.nom
        label $f.nom.l -text $LOCALE(nom_table)
        entry $f.nom.e -textvariable E_nom_table
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    
    frame $f.attributs
        # Commandes des attributs
        frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_MCD_INTERFACE_Objets_ajout_attribut "table"}
            # Bouton de supression d'un nouvel attribut
            button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Objets_suppression_attribut "table"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -width 1200 -height 400
        frame $f.attributs.c.f
            # Liste des attributs
            frame $f.attributs.c.f.liste
                label $f.attributs.c.f.titre -text $LOCALE(liste_attributs_table)
                pack $f.attributs.c.f.titre -fill x
                frame $f.attributs.c.f.tete
                    label $f.attributs.c.f.tete.nom -text $LOCALE(nom) -width 20 -height 2 -background white -relief solid
                    label $f.attributs.c.f.tete.type -text $LOCALE(type) -width 20 -height 2 -background white -relief solid
                    label $f.attributs.c.f.tete.taille -text $LOCALE(taille) -width 20 -height 2 -background white -relief solid
                    label $f.attributs.c.f.tete.valeur -text $LOCALE(valeur) -width 20 -height 2 -background white -relief solid
                    label $f.attributs.c.f.tete.auto -text $LOCALE(auto) -width 20 -height 2 -background white -relief solid
                    label $f.attributs.c.f.tete.pk -text $LOCALE(pk) -width 20 -height 2 -background white -relief solid
                    
                    pack $f.attributs.c.f.tete.nom $f.attributs.c.f.tete.type $f.attributs.c.f.tete.taille $f.attributs.c.f.tete.valeur $f.attributs.c.f.tete.auto $f.attributs.c.f.tete.pk -fill x -side left
                pack $f.attributs.c.f.tete -fill x
                frame $f.attributs.c.f.corps
                
                pack $f.attributs.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'entité est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.attributs.c.f.corps $table "entite"
                    }
            pack $f.attributs.c.f.liste -side left -fill x
        pack $f.attributs.c -side left
        $f.attributs.c create window 0 0 -anchor nw -window $f.attributs.c.f
        ttk::scrollbar $f.attributs.yscroll -command "$f.attributs.c yview"
        pack $f.attributs.yscroll -side right -fill y
        $f.attributs.c configure -scrollregion "0 0 1000 10000"
    pack $f.attributs -fill x -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.attributs.c configure -yscrollcommand "$f.attributs.yscroll set"
    
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command Katyusha_MCD_INTERFACE_Entites_COMMANDE_ajout_table
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {
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
        wm title $f $LOCALE(ajouter_une_table)
    } else {
        wm title $f "$LOCALE(editer_la_table) : $E_nom_table"
    }
    
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
    set ok [Katyusha_Tables_controle_table $table_tmp]
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
    global LOCALE
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
    
    frame $f.table -padx 10 -pady 10
        label $f.table.l -text "Choisir une entité :"
        ttk::combobox $f.table.cb -values [liste_tables]
        pack $f.table.l $f.table.cb -fill both -side left
    pack $f.table -fill x
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            set f ".fen_choix_table"
            global table_choisie
            set table_choisie [$f.table.cb get]
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f "Choisir une entité"
    # Mise à jour forcée de l'affichage graphique
    update
    
    # Attend qu'une valeur soit affectée à table_choisie
    vwait table_choisie
    destroy $f
    return $table_choisie
}
