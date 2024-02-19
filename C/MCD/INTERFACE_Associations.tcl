## Créé le 11/9/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Si aucune association n'est spécifiée en argument, il s'agira d'un ajout d'association.
# Si une association est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc Katyusha_MCD_INTERFACE_Association_ajout_association {x y {id "null"}} {
    global relation_tmp
    global relations
    global tables
    global IMG
    global E_nom_relation
    
    set liste_type_relations [list "0.1" "1.1" "0.n" "1.n" "n.n"]
    
    # Couleurs
    set ddbackground [Katyusha_Configurations_couleurs "-ddbackground"]
    set dbackground [Katyusha_Configurations_couleurs "-dbackground"]
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set background [Katyusha_Configurations_couleurs "-frame"]
    set foreground [Katyusha_Configurations_couleurs "-foreground"]
    
    set f ".fen_ajout_relation"
    
    # Initialise l'association temporaire
    if {$id == "null"} {
        # Transfert des coordonnées
        set coords [list $x $y]
        set relation_tmp [Katyusha_Relations_init_relation]
        dict set relation_tmp "coords" $coords
        set E_nom_relation "Relation_[expr [dict size $relations] + 1]"
    } else {
        set relation [dict get $relations $id]
        set relation_tmp $relation
        set E_nom_relation [dict get $relation "nom"]
    }
    dict set relation_tmp "id" $id
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de choix du nom de l'entité
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Nom de l'association : "]
        ttk::entry $f.nom.e -textvariable E_nom_relation
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    
    ##
    # Liens de l'association
    ##
    ttk::frame $f.liens
        # Commandes des liens
        ttk::frame $f.liens.commandes
            # Bouton d'ajout d'un nouveau lien
            ttk::button $f.liens.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyuusha_MCD_INTERFACE_Association_ajout_lien_association}
            # Bouton de supression d'un lien
            ttk::button $f.liens.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Association_suppression_lien_association}
            pack $f.liens.commandes.ajout $f.liens.commandes.supp -padx 10
        pack $f.liens.commandes -side left -fill x
        # Liste des liens
        ttk::frame $f.liens.liste
            ttk::label $f.liens.liste.titre -text [phgt::mc "Liste des liens de l'association"]
            pack $f.liens.liste.titre -fill x
            ttk::frame $f.liens.liste.tete
                ttk::label $f.liens.liste.tete.nom -text [phgt::mc "Entité concernée"] -width 20 -background $background -relief solid
                ttk::label $f.liens.liste.tete.type -text [phgt::mc "Type de lien"] -width 20 -background $background -relief solid
                ttk::label $f.liens.liste.tete.relatif -text [phgt::mc "Identifiant relatif?"] -width 25 -background $background -relief solid
                pack $f.liens.liste.tete.nom $f.liens.liste.tete.type $f.liens.liste.tete.relatif -fill x -side left
            pack $f.liens.liste.tete
            ttk::frame $f.liens.liste.corps
                ##
                # Ici viennent s'insérer les liens
                ##
                # Si l'association est en édition, on affiche la liste des liens déjà existants
                if {$id != "null"} {
                    set liens [dict get $relation "liens"]
                    foreach {k lien} $liens {
                        ttk::frame $f.liens.liste.corps.$k
                            ttk::label $f.liens.liste.corps.$k.table -text [lindex $lien 0] -width 20 -background $background -relief solid
                            ttk::label $f.liens.liste.corps.$k.type -text [lindex $lien 1] -width 20 -background $background -relief solid
                            ttk::label $f.liens.liste.corps.$k.relatif -text [lindex $lien 2] -width 20 -background $background -relief solid
                            ttk::button $f.liens.liste.corps.$k.edit -text "Éditer" -image $IMG(editer) -command "Katyuusha_MCD_INTERFACE_Association_ajout_lien_association $k"
                            pack $f.liens.liste.corps.$k.table $f.liens.liste.corps.$k.type $f.liens.liste.corps.$k.relatif $f.liens.liste.corps.$k.edit -side left
                        pack $f.liens.liste.corps.$k
                    }
                }
            pack $f.liens.liste.corps -fill x
        pack $f.liens.liste -fill x
    pack $f.liens -fill x -padx 10
    
    ##
    # Attributs de l'association
    ##
    ttk::frame $f.attributs
        # Commandes des attributs
        ttk::frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_Interface_Objets_MCD_UML_ajout_attribut "relation"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Objets_suppression_attribut "relation"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x

        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -width 1200 -height 200 -background $background -highlightbackground $background
        ttk::frame $f.attributs.c.f
            # Liste des attributs
            ttk::frame $f.attributs.c.f.liste
                ttk::label $f.attributs.c.f.titre -text [phgt::mc "Liste des attributs de l'association"]
                pack $f.attributs.c.f.titre -fill x
                ttk::frame $f.attributs.c.f.tete
                    ttk::label $f.attributs.c.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.type -text [phgt::mc "Type"] -width 15 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.signe -text [phgt::mc "Non signé?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.taille -text [phgt::mc "Taille"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.valeur -text [phgt::mc "Valeur\npar défaut"] -width 20 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.auto -text [phgt::mc "Incrémentation\nautomatique?"] -width 15 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.pk -text [phgt::mc "Clef\nprimaire?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.unique -text [phgt::mc "Unique?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.m -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.d -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.c.f.tete.e -text "" -width 5 -background $background -relief solid
                    
                    pack $f.attributs.c.f.tete.nom $f.attributs.c.f.tete.type $f.attributs.c.f.tete.signe $f.attributs.c.f.tete.taille $f.attributs.c.f.tete.valeur $f.attributs.c.f.tete.auto $f.attributs.c.f.tete.pk $f.attributs.c.f.tete.unique $f.attributs.c.f.tete.m $f.attributs.c.f.tete.d $f.attributs.c.f.tete.e -fill both -expand 1 -side left
                pack $f.attributs.c.f.tete -fill x
                ttk::frame $f.attributs.c.f.corps
                    
                pack $f.attributs.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'association est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.attributs.c $relation "association"
                    }
                pack $f.attributs.c.f.corps -fill x
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
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
            global relation_tmp
            set f ".fen_ajout_relation"
            set id [dict get $relation_tmp "id"]
            dict set relation_tmp "nom" [$f.nom.e get]
            dict set relation_tmp "description" ""
            set ok [Katyusha_Relations_controle_relation $relation_tmp]
            if {$id == "null" && $ok == 1} {
                Katyusha_ajout_relation $relation_tmp
                destroy $f
            } elseif {$id != "null" && $ok == 1} {
                Katyusha_Relations_modification_relation $id $relation_tmp
                destroy $f
            }
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {
            if {[winfo exists .fen_ajout_attribut]} {
                destroy .fen_ajout_attribut
            }
            destroy .fen_ajout_relation
        }
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f [phgt::mc "Ajouter une association"]
    } else {
        wm title $f [phgt::mc "Éditer l'association : %s" [list $E_nom_relation]]
    }
    
    # Couleur de fond de la fenêtre
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
    
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre d'ajout de lien à une association
##
proc Katyuusha_MCD_INTERFACE_Association_ajout_lien_association {{id_lien "null"}} {
    global relation_tmp
    global tables
    global IMG
    global E_relatif
    
    set f ".fen_ajout_lien_relation"
    
    set liste_type_relations [list "0.1" "1.1" "0.n" "1.n" "n.n"]
    
    # Si on modifie un lien existant
    if {$id_lien != "null"} {
        set liens [dict get $relation_tmp "liens"]
        set lien [dict get $liens $id_lien]
        set E_relatif [lindex $lien 2]
    }
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    # Créé la fenêtre
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    # Choix des tables concernées par l'association
    ttk::frame $f.tables
        ttk::label $f.tables.info -text [phgt::mc "Sélectionner l'entité concernée par le lien :"]
        pack $f.tables.info
        ttk::frame $f.tables.tete
            ttk::label $f.tables.tete.ct -text [phgt::mc "Entité"] -width 20
            ttk::label $f.tables.tete.cr -text [phgt::mc "Type de lien"] -width 20
            ttk::label $f.tables.tete.cb -text [phgt::mc "Relatif?"] -width 20
            pack $f.tables.tete.ct $f.tables.tete.cr $f.tables.tete.cb -side left
        pack $f.tables.tete -fill x
        ttk::frame $f.tables.r
            ttk::combobox $f.tables.r.ct -values [liste_tables] -width 20
            if {$id_lien != "null"} {
                $f.tables.r.ct set [lindex $lien 0]
            }
            ttk::combobox $f.tables.r.cr -values $liste_type_relations -width 20
            if {$id_lien != "null"} {
                $f.tables.r.cr set [lindex $lien 1]
            }
            ttk::checkbutton $f.tables.r.cb -onvalue 1 -offvalue 0 -variable E_relatif -width 20
            pack $f.tables.r.ct $f.tables.r.cr $f.tables.r.cb -side left
        pack $f.tables.r -fill x
        # Si il y a moins de deux tables, avertir l'utilisateur
        if {[dict size $tables] < 1} {
            ttk::label $f.tables.info_err -text [phgt::mc "Il n'y a pas assez d'entités dans le MCD."] -justify left -foreground red
            pack $f.tables.info_err
        }
    pack $f.tables -pady 10 -padx 20
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command "Katyusha_MCD_INTERFACE_COMMANDE_Association_ajout_lien_association $id_lien"
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Rend impossible l'indentifiant relatif si autre que 1.1
    bind .fen_ajout_lien_relation.tables.r.cr <<ComboboxSelected>> {
        global E_relatif
        
        set f ".fen_ajout_lien_relation"
        if {[$f.tables.r.cr get] != "1.1"} {
            $f.tables.r.cb configure -state disabled
            set E_relatif 0
        } else {
            $f.tables.r.cb configure -state active
        }
        update
    }
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Sélectionner l'entité concernée par le lien"]
    
    # Couleur de fond de la fenêtre
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
}

proc Katyusha_MCD_INTERFACE_COMMANDE_Association_ajout_lien_association {id_lien} {
    global relation_tmp
    global E_relatif
    
    set f ".fen_ajout_lien_relation"
    # Vérifie qu'une table et un type de lien soient bien sélectionnés
    if {[$f.tables.r.ct get] != "" && [$f.tables.r.cr get] != ""} {
        if {$id_lien == "null"} {
            Katyusha_Relations_ajout_lien [$f.tables.r.ct get] [$f.tables.r.cr get] $E_relatif
        } else {
            Katyusha_Relations_modification_lien $id_lien [$f.tables.r.ct get] [$f.tables.r.cr get] $E_relatif
        }
        destroy $f
    } else {
        set res [tk_messageBox -message [phgt::mc "Les informations saisies sont incomplètes"]]
    }
}

##
# Supprime un lien de l'association temporaire
##
proc Katyusha_MCD_INTERFACE_Association_suppression_lien_association {} {
    global relation_tmp
    global IMG
    
    set f ".fen_supp_lien_relation"
    set liens [list]
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    foreach {k lien} [dict get $relation_tmp "liens"] {
        lappend liens "$k : $lien"
    }
    
    # Frame de titre
    ttk::frame $f.nom
        ttk::label $f.nom.l -text "Sélectionner un lien à supprimer"
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    ttk::combobox $f.cb -value $liens -width 50
    pack $f.cb
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
            global relation_tmp
            
            set f ".fen_supp_lien_relation"
            set lien [$f.cb get]
            if {$lien == ""} {
                set rep [tk_messageBox -message "Sélectionner un lien à supprimmer"]
            } else {
                set id_lien [lindex [split $lien " : "] 0]
                set liens [dict get $relation_tmp "liens"]
                dict unset liens $id_lien
                dict set relation_tmp "liens" $liens
            }
            destroy .fen_ajout_relation.liens.liste.corps.$id_lien
            destroy $f
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy .fen_supp_lien_relation}
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f "Supprimer un lien"
    
    # Couleur de fond de la fenêtre
    set tbg [ttk::style lookup TFrame -background]
    lassign [winfo rgb . $tbg] bg_r bg_g bg_b
    $f configure -background $tbg
    
    update
}
