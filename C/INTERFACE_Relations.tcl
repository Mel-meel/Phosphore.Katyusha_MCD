## Créé le 11/9/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Si aucune relation n'est spécifiée en argument, il s'agira d'un ajout de relation.
# Si une relations est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc INTERFACE_ajout_relation {x y {id "null"}} {
    global relation_tmp
    global relations
    global tables
    global LOCALE
    global IMG
    #global id_attribut_graphique
    global E_nom_relation
    
    set liste_type_relations [list "0.1" "1.1" "0.n" "1.n" "n.n"]
    
    set f ".fen_ajout_relation"
    
    # Initialise la relation temporaire
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
    
    # Frame de choix du nom de la table
    frame $f.nom
        label $f.nom.l -text $LOCALE(nom_relation)
        entry $f.nom.e -textvariable E_nom_relation
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    
    ##
    # Liens de la relation
    ##
    frame $f.liens
        # Commandes des liens
        frame $f.liens.commandes
            # Bouton d'ajout d'un nouveau lien
            button $f.liens.commandes.ajout -text "+" -image $IMG(ajouter) -command {INTERFACE_ajout_lien_relation}
            # Bouton de supression d'un lien
            button $f.liens.commandes.supp -text "-" -image $IMG(supprimer) -command {INTERFACE_suppression_lien_relation}
            pack $f.liens.commandes.ajout $f.liens.commandes.supp -padx 10
        pack $f.liens.commandes -side left -fill x
        # Liste des liens
        frame $f.liens.liste
            label $f.liens.liste.titre -text $LOCALE(liste_attributs_relation)
            pack $f.liens.liste.titre -fill x
            frame $f.liens.liste.tete
                label $f.liens.liste.tete.nom -text "Table concernée" -width 20 -height 2 -background white -relief solid
                label $f.liens.liste.tete.type -text "Type" -width 20 -height 2 -background white -relief solid
                label $f.liens.liste.tete.relatif -text "Identifiant relatif?" -width 25 -height 2 -background white -relief solid
                pack $f.liens.liste.tete.nom $f.liens.liste.tete.type $f.liens.liste.tete.relatif -fill x -side left
            pack $f.liens.liste.tete
            frame $f.liens.liste.corps
                ##
                # Ici viennent s'insérer les liens
                ##
                # Si la relation est en édition, on affiche la liste des liens déjà existants
                if {$id != "null"} {
                    set liens [dict get $relation "liens"]
                    foreach {k lien} $liens {
                        frame $f.liens.liste.corps.$k
                            label $f.liens.liste.corps.$k.table -text [lindex $lien 0] -width 20 -height 2 -background white -relief solid
                            label $f.liens.liste.corps.$k.type -text [lindex $lien 1] -width 20 -height 2 -background white -relief solid
                            label $f.liens.liste.corps.$k.relatif -text [lindex $lien 2] -width 20 -height 2 -background white -relief solid
                            button $f.liens.liste.corps.$k.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_lien_relation $k"
                            pack $f.liens.liste.corps.$k.table $f.liens.liste.corps.$k.type $f.liens.liste.corps.$k.relatif $f.liens.liste.corps.$k.edit -side left
                        pack $f.liens.liste.corps.$k
                    }
                }
                # TODO
            pack $f.liens.liste.corps -fill x
        pack $f.liens.liste -fill x
    pack $f.liens -fill x -padx 10
    
    ##
    # Attributs de la relation
    ##
    frame $f.attributs
        # Commandes des attributs
        frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {INTERFACE_ajout_attribut "relation"}
            # Bouton de supression d'un nouvel attribut
            button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {INTERFACE_suppression_attribut "relation"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x

        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -width 1032 -height 200 -yscrollcommand "$f.attributs.yscroll set"
        frame $f.attributs.c.f
            # Liste des attributs
            frame $f.attributs.c.f.liste
                label $f.attributs.c.f.titre -text "Liste des attributs de la table"
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
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si la table est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        set attributs [dict get $relation "attributs"]
                        foreach {id_attribut_graphique attribut} $attributs {
                            #set nom_attribut_graphique [dict get $attribut "nom"]
                            frame $f.attributs.c.f.corps.$id_attribut_graphique
                                label $f.attributs.c.f.corps.$id_attribut_graphique.nom -text [dict get $attribut "nom"] -width 20 -height 2 -background white -relief solid
                                label $f.attributs.c.f.corps.$id_attribut_graphique.type -text [dict get $attribut "type"] -width 20 -height 2 -background white -relief solid
                                label $f.attributs.c.f.corps.$id_attribut_graphique.taille -text [dict get $attribut "taille"] -width 20 -height 2 -background white -relief solid
                                label $f.attributs.c.f.corps.$id_attribut_graphique.valeur -text [dict get $attribut "valeur"] -width 20 -height 2 -background white -relief solid
                                label $f.attributs.c.f.corps.$id_attribut_graphique.auto -text [dict get $attribut "auto"] -width 20 -height 2 -background white -relief solid
                                label $f.attributs.c.f.corps.$id_attribut_graphique.pk -text [dict get $attribut "pk"] -width 20 -height 2 -background white -relief solid
                                button $f.attributs.c.f.corps.$id_attribut_graphique.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_attribut relation $id_attribut_graphique"
                                pack $f.attributs.c.f.corps.$id_attribut_graphique.nom $f.attributs.c.f.corps.$id_attribut_graphique.type $f.attributs.c.f.corps.$id_attribut_graphique.taille $f.attributs.c.f.corps.$id_attribut_graphique.valeur $f.attributs.c.f.corps.$id_attribut_graphique.auto $f.attributs.c.f.corps.$id_attribut_graphique.pk $f.attributs.c.f.corps.$id_attribut_graphique.edit -side left
                            pack $f.attributs.c.f.corps.$id_attribut_graphique -fill x
                        }
                    }
                pack $f.attributs.c.f.corps -fill x
            pack $f.attributs.c.f.liste -side left -fill x
        pack $f.attributs.c -side left
        $f.attributs.c create window 0 0 -anchor nw -window $f.attributs.c.f
        ttk::scrollbar $f.attributs.yscroll -command "$f.attributs.c yview"
        pack $f.attributs.yscroll -side right -fill y
        $f.attributs.c configure -scrollregion "0 0 1000 10000"
    pack $f.attributs -fill x -padx 10
    
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
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
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {
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
        wm title $f $LOCALE(ajouter_une_relation)
    } else {
        wm title $f "$LOCALE(editer_la_relation) : $E_nom_relation"
    }
    
    # Mise à jour forcée de l'affichage graphique
    update
}

##
# Fenêtre d'ajout de lien à une relation
##
proc INTERFACE_ajout_lien_relation {{id_lien "null"}} {
    global relation_tmp
    global tables
    global IMG
    global LOCALE
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
    # Choix des tables concernées par la relation
    frame $f.tables
        label $f.tables.info -text $LOCALE(table_concernee_lien)
        pack $f.tables.info
        frame $f.tables.tete
            label $f.tables.tete.ct -text $LOCALE(table_lien) -width 20
            label $f.tables.tete.cr -text $LOCALE(type_lien) -width 20
            label $f.tables.tete.cb -text $LOCALE(relatif_lien) -width 20
            pack $f.tables.tete.ct $f.tables.tete.cr $f.tables.tete.cb -side left
        pack $f.tables.tete -fill x
        frame $f.tables.r
            ttk::combobox $f.tables.r.ct -values [liste_tables] -width 20
            if {$id_lien != "null"} {
                $f.tables.r.ct set [lindex $lien 0]
            }
            ttk::combobox $f.tables.r.cr -values $liste_type_relations -width 20
            if {$id_lien != "null"} {
                $f.tables.r.cr set [lindex $lien 1]
            }
            checkbutton $f.tables.r.cb -onvalue 1 -offvalue 0 -variable E_relatif -width 20
            pack $f.tables.r.ct $f.tables.r.cr $f.tables.r.cb -side left
        pack $f.tables.r -fill x
        # Si il y a moins de deux tables, avertir l'utilisateur
        if {[dict size $tables] < 1} {
            label $f.tables.info_err -text $LOCALE(pas_assez_table) -justify left -foreground red
            pack $f.tables.info_err
        }
    pack $f.tables -pady 10 -padx 20
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "INTERFACE_COMMANDE_ajout_lien $id_lien"
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
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
}

proc INTERFACE_COMMANDE_ajout_lien {id_lien} {
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
        set res [tk_messageBox -message "Les informations saisies sont incomplètes"]
    }
}

##
# Supprime un lien de la relation temporaire
##
proc INTERFACE_suppression_lien_relation {} {
    global relation_tmp
    global LOCALE
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
    frame $f.nom
        label $f.nom.l -text "Sélectionner un lien à supprimer"
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    ttk::combobox $f.cb -value $liens -width 50
    pack $f.cb
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
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
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy .fen_supp_lien_relation}
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f "Supprimer un lien"
    update
}
